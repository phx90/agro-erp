-- Dados pra testar. Os documentos são fictícios.

insert into clientes (nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito)
values ('Agropecuária Boa Vista Ltda', '11222333000181', 'Araçatuba', 'SP', '(18) 3621-1020', 'compras@boavista.com.br', 20000);
insert into clientes (nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito)
values ('Casa do Criador Birigui', '22333444000192', 'Birigui', 'SP', '(18) 3642-5511', 'contato@casadocriador.com.br', 8000);
insert into clientes (nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito)
values ('João Batista Ferreira', '12345678909', 'Penápolis', 'SP', '(18) 99711-2030', null, 3000);
insert into clientes (nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito)
values ('Fazenda Santa Helena', '33444555000103', 'Guararapes', 'SP', '(18) 3606-7788', 'adm@santahelena.agr.br', 0);
insert into clientes (nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito)
values ('Rural Center Andradina', '44555666000114', 'Andradina', 'SP', '(18) 3722-4040', 'financeiro@ruralcenter.com.br', 15000);

insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('RAC001', 'Ração bovina engorda 40kg', 'SC', 89.90, 50);
insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('SAL002', 'Sal mineral 30kg', 'SC', 72.50, 40);
insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('ARA003', 'Arame farpado 500m', 'RL', 389.00, 10);
insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('VAC004', 'Vacina aftosa 50 doses', 'FR', 54.00, 30);
insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('MOU005', 'Mourão de eucalipto tratado 2,2m', 'UN', 32.00, 100);
insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('SEM006', 'Semente braquiária 20kg', 'SC', 210.00, 15);
insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo)
values ('ADU007', 'Adubo NPK 20-05-20 50kg', 'SC', 189.00, 20);

-- entrada inicial de estoque passando pela package, pra ficar registrado o movimento
begin
  for p in (select id, codigo from produtos) loop
    pkg_estoque.registrar_entrada(
      p.id,
      case p.codigo
        when 'RAC001' then 300
        when 'SAL002' then 180
        when 'ARA003' then 25
        when 'VAC004' then 60
        when 'MOU005' then 400
        when 'SEM006' then 18
        when 'ADU007' then 90
      end,
      'COMPRA'
    );
  end loop;
end;
/

-- alguns pedidos em situações diferentes
declare
  v_pedido number;
  v_item   number;

  function cliente(p_doc varchar2) return number is
    v_id number;
  begin
    select id into v_id from clientes where cpf_cnpj = p_doc;
    return v_id;
  end;

  function produto(p_codigo varchar2) return number is
    v_id number;
  begin
    select id into v_id from produtos where codigo = p_codigo;
    return v_id;
  end;
begin
  v_pedido := pkg_pedido.criar(cliente('11222333000181'), 'Entrega na fazenda, estrada vicinal km 4');
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('RAC001'), 120, 5);
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('SAL002'), 60);
  pkg_pedido.faturar(v_pedido, 3, 30);

  v_pedido := pkg_pedido.criar(cliente('22333444000192'));
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('VAC004'), 40);
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('SEM006'), 6);
  pkg_pedido.faturar(v_pedido, 2, 28);

  v_pedido := pkg_pedido.criar(cliente('33444555000103'), 'Retira no balcão');
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('ARA003'), 18);
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('MOU005'), 320);
  pkg_pedido.faturar(v_pedido);

  v_pedido := pkg_pedido.criar(cliente('12345678909'));
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('ADU007'), 8, 3);

  v_pedido := pkg_pedido.criar(cliente('44555666000114'));
  v_item   := pkg_pedido.adicionar_item(v_pedido, produto('SEM006'), 4);
  pkg_pedido.cancelar(v_pedido);
end;
/

-- simula o pagamento da primeira parcela do primeiro pedido
begin
  for t in (select id, valor
              from contas_receber
             where parcela = 1
               and pedido_id = (select min(id) from pedidos)) loop
    pkg_financeiro.baixar_titulo(t.id, t.valor);
  end loop;
end;
/

-- joga a primeira parcela do segundo pedido pro passado, pra ter algo vencido na tela
update contas_receber
   set vencimento = trunc(sysdate) - 12
 where parcela = 1
   and pedido_id = (select min(id) + 1 from pedidos);

commit;
