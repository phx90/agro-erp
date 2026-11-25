create or replace package pkg_estoque as

  procedure registrar_entrada(
    p_produto_id   in number,
    p_quantidade   in number,
    p_origem       in varchar2 default 'AJUSTE',
    p_documento_id in number   default null
  );

  procedure registrar_saida(
    p_produto_id   in number,
    p_quantidade   in number,
    p_origem       in varchar2 default 'AJUSTE',
    p_documento_id in number   default null
  );

  function saldo(p_produto_id in number) return number;

end pkg_estoque;
/

create or replace package body pkg_estoque as

  procedure validar_quantidade(p_quantidade in number) is
  begin
    if p_quantidade is null or p_quantidade <= 0 then
      raise_application_error(-20001, 'Quantidade deve ser maior que zero.');
    end if;
  end;

  procedure registrar_movimento(
    p_produto_id   in number,
    p_tipo         in char,
    p_quantidade   in number,
    p_origem       in varchar2,
    p_documento_id in number
  ) is
  begin
    insert into movimentos_estoque (produto_id, tipo, quantidade, origem, documento_id)
    values (p_produto_id, p_tipo, p_quantidade, p_origem, p_documento_id);
  end;

  procedure registrar_entrada(
    p_produto_id   in number,
    p_quantidade   in number,
    p_origem       in varchar2 default 'AJUSTE',
    p_documento_id in number   default null
  ) is
  begin
    validar_quantidade(p_quantidade);

    update produtos
       set estoque_atual = estoque_atual + p_quantidade
     where id = p_produto_id;

    if sql%rowcount = 0 then
      raise_application_error(-20002, 'Produto ' || p_produto_id || ' não encontrado.');
    end if;

    registrar_movimento(p_produto_id, 'E', p_quantidade, p_origem, p_documento_id);
  end;

  procedure registrar_saida(
    p_produto_id   in number,
    p_quantidade   in number,
    p_origem       in varchar2 default 'AJUSTE',
    p_documento_id in number   default null
  ) is
    v_saldo produtos.estoque_atual%type;
  begin
    validar_quantidade(p_quantidade);

    -- trava a linha do produto pra evitar duas vendas do mesmo saldo
    select estoque_atual
      into v_saldo
      from produtos
     where id = p_produto_id
       for update;

    if v_saldo < p_quantidade then
      raise_application_error(-20003,
        'Estoque insuficiente para o produto ' || p_produto_id ||
        '. Saldo: ' || v_saldo || ', solicitado: ' || p_quantidade);
    end if;

    update produtos
       set estoque_atual = estoque_atual - p_quantidade
     where id = p_produto_id;

    registrar_movimento(p_produto_id, 'S', p_quantidade, p_origem, p_documento_id);
  exception
    when no_data_found then
      raise_application_error(-20002, 'Produto ' || p_produto_id || ' não encontrado.');
  end;

  function saldo(p_produto_id in number) return number is
    v_saldo produtos.estoque_atual%type;
  begin
    select estoque_atual into v_saldo from produtos where id = p_produto_id;
    return v_saldo;
  exception
    when no_data_found then
      return null;
  end;

end pkg_estoque;
/
