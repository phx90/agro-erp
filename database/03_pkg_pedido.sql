create or replace package pkg_pedido as

  function criar(
    p_cliente_id in number,
    p_observacao in varchar2 default null
  ) return number;

  function adicionar_item(
    p_pedido_id    in number,
    p_produto_id   in number,
    p_quantidade   in number,
    p_desconto_pct in number default 0
  ) return number;

  procedure remover_item(p_item_id in number);

  procedure faturar(
    p_pedido_id      in number,
    p_parcelas       in number default 1,
    p_intervalo_dias in number default 30
  );

  procedure cancelar(p_pedido_id in number);

end pkg_pedido;
/

create or replace package body pkg_pedido as

  c_aberto    constant varchar2(10) := 'ABERTO';
  c_faturado  constant varchar2(10) := 'FATURADO';
  c_cancelado constant varchar2(10) := 'CANCELADO';

  function status_com_lock(p_pedido_id in number) return varchar2 is
    v_status pedidos.status%type;
  begin
    select status
      into v_status
      from pedidos
     where id = p_pedido_id
       for update;

    return v_status;
  exception
    when no_data_found then
      raise_application_error(-20010, 'Pedido ' || p_pedido_id || ' não encontrado.');
  end;

  procedure exigir_aberto(p_pedido_id in number) is
  begin
    if status_com_lock(p_pedido_id) <> c_aberto then
      raise_application_error(-20011, 'Pedido ' || p_pedido_id || ' não está em aberto.');
    end if;
  end;

  procedure recalcular_total(p_pedido_id in number) is
  begin
    update pedidos p
       set p.valor_total = (select nvl(sum(i.valor_total), 0)
                              from pedido_itens i
                             where i.pedido_id = p.id)
     where p.id = p_pedido_id;
  end;

  function criar(
    p_cliente_id in number,
    p_observacao in varchar2 default null
  ) return number is
    v_ativo     clientes.ativo%type;
    v_pedido_id pedidos.id%type;
  begin
    select ativo into v_ativo from clientes where id = p_cliente_id;

    if v_ativo <> 'S' then
      raise_application_error(-20012, 'Cliente inativo não pode fazer pedidos.');
    end if;

    insert into pedidos (cliente_id, observacao)
    values (p_cliente_id, p_observacao)
    returning id into v_pedido_id;

    return v_pedido_id;
  exception
    when no_data_found then
      raise_application_error(-20013, 'Cliente ' || p_cliente_id || ' não encontrado.');
  end;

  function adicionar_item(
    p_pedido_id    in number,
    p_produto_id   in number,
    p_quantidade   in number,
    p_desconto_pct in number default 0
  ) return number is
    v_preco   produtos.preco_venda%type;
    v_ativo   produtos.ativo%type;
    v_item_id pedido_itens.id%type;
    v_total   pedido_itens.valor_total%type;
  begin
    exigir_aberto(p_pedido_id);

    if p_quantidade is null or p_quantidade <= 0 then
      raise_application_error(-20014, 'Quantidade deve ser maior que zero.');
    end if;

    if nvl(p_desconto_pct, 0) not between 0 and 100 then
      raise_application_error(-20015, 'Desconto deve estar entre 0 e 100%.');
    end if;

    begin
      select preco_venda, ativo
        into v_preco, v_ativo
        from produtos
       where id = p_produto_id;
    exception
      when no_data_found then
        raise_application_error(-20016, 'Produto ' || p_produto_id || ' não encontrado.');
    end;

    if v_ativo <> 'S' then
      raise_application_error(-20017, 'Produto inativo não pode ser vendido.');
    end if;

    v_total := round(p_quantidade * v_preco * (1 - nvl(p_desconto_pct, 0) / 100), 2);

    insert into pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, desconto_pct, valor_total)
    values (p_pedido_id, p_produto_id, p_quantidade, v_preco, nvl(p_desconto_pct, 0), v_total)
    returning id into v_item_id;

    recalcular_total(p_pedido_id);
    return v_item_id;
  end;

  procedure remover_item(p_item_id in number) is
    v_pedido_id pedido_itens.pedido_id%type;
  begin
    select pedido_id into v_pedido_id from pedido_itens where id = p_item_id;

    exigir_aberto(v_pedido_id);

    delete from pedido_itens where id = p_item_id;
    recalcular_total(v_pedido_id);
  exception
    when no_data_found then
      raise_application_error(-20018, 'Item ' || p_item_id || ' não encontrado.');
  end;

  procedure validar_credito(p_cliente_id in number, p_valor_pedido in number) is
    v_limite     clientes.limite_credito%type;
    v_em_aberto  number;
  begin
    select limite_credito into v_limite from clientes where id = p_cliente_id;

    -- limite zerado = cliente sem restrição de crédito
    if v_limite = 0 then
      return;
    end if;

    select nvl(sum(valor - valor_pago), 0)
      into v_em_aberto
      from contas_receber
     where cliente_id = p_cliente_id
       and status = c_aberto;

    if v_em_aberto + p_valor_pedido > v_limite then
      raise_application_error(-20019,
        'Limite de crédito excedido. Limite: ' || v_limite ||
        ', em aberto: ' || v_em_aberto || ', pedido: ' || p_valor_pedido);
    end if;
  end;

  procedure gerar_parcelas(
    p_pedido_id      in number,
    p_cliente_id     in number,
    p_valor_total    in number,
    p_parcelas       in number,
    p_intervalo_dias in number
  ) is
    v_valor_parcela number(12,2) := trunc(p_valor_total / p_parcelas, 2);
    -- sobra de centavos vai pra primeira parcela
    v_diferenca     number(12,2) := p_valor_total - v_valor_parcela * p_parcelas;
  begin
    for i in 1 .. p_parcelas loop
      insert into contas_receber (pedido_id, cliente_id, parcela, vencimento, valor)
      values (
        p_pedido_id,
        p_cliente_id,
        i,
        trunc(sysdate) + p_intervalo_dias * i,
        v_valor_parcela
      );
    end loop;

    update contas_receber
       set valor = valor + v_diferenca
     where pedido_id = p_pedido_id
       and parcela = 1;
  end;

  procedure faturar(
    p_pedido_id      in number,
    p_parcelas       in number default 1,
    p_intervalo_dias in number default 30
  ) is
    v_cliente_id pedidos.cliente_id%type;
    v_total      pedidos.valor_total%type;
    v_qtd_itens  number;
  begin
    exigir_aberto(p_pedido_id);

    if p_parcelas is null or p_parcelas not between 1 and 12 then
      raise_application_error(-20020, 'Número de parcelas deve ser entre 1 e 12.');
    end if;

    select cliente_id, valor_total
      into v_cliente_id, v_total
      from pedidos
     where id = p_pedido_id;

    select count(*) into v_qtd_itens from pedido_itens where pedido_id = p_pedido_id;

    if v_qtd_itens = 0 then
      raise_application_error(-20021, 'Pedido sem itens não pode ser faturado.');
    end if;

    validar_credito(v_cliente_id, v_total);

    for item in (select produto_id, quantidade
                   from pedido_itens
                  where pedido_id = p_pedido_id
                  order by produto_id) loop
      pkg_estoque.registrar_saida(item.produto_id, item.quantidade, 'VENDA', p_pedido_id);
    end loop;

    gerar_parcelas(p_pedido_id, v_cliente_id, v_total, p_parcelas, nvl(p_intervalo_dias, 30));

    update pedidos
       set status = c_faturado,
           data_faturamento = sysdate
     where id = p_pedido_id;
  end;

  procedure estornar_faturamento(p_pedido_id in number) is
    v_pagos number;
  begin
    select count(*)
      into v_pagos
      from contas_receber
     where pedido_id = p_pedido_id
       and valor_pago > 0;

    if v_pagos > 0 then
      raise_application_error(-20022,
        'Pedido possui parcelas com pagamento. Estorne os pagamentos antes de cancelar.');
    end if;

    for item in (select produto_id, quantidade
                   from pedido_itens
                  where pedido_id = p_pedido_id) loop
      pkg_estoque.registrar_entrada(item.produto_id, item.quantidade, 'CANCELAMENTO', p_pedido_id);
    end loop;

    update contas_receber
       set status = c_cancelado
     where pedido_id = p_pedido_id;
  end;

  procedure cancelar(p_pedido_id in number) is
    v_status pedidos.status%type := status_com_lock(p_pedido_id);
  begin
    if v_status = c_cancelado then
      raise_application_error(-20023, 'Pedido ' || p_pedido_id || ' já está cancelado.');
    end if;

    if v_status = c_faturado then
      estornar_faturamento(p_pedido_id);
    end if;

    update pedidos set status = c_cancelado where id = p_pedido_id;
  end;

end pkg_pedido;
/
