create or replace package pkg_financeiro as

  procedure baixar_titulo(
    p_titulo_id in number,
    p_valor     in number,
    p_data      in date default sysdate
  );

  function saldo_cliente(p_cliente_id in number) return number;

end pkg_financeiro;
/

create or replace package body pkg_financeiro as

  procedure baixar_titulo(
    p_titulo_id in number,
    p_valor     in number,
    p_data      in date default sysdate
  ) is
    v_titulo contas_receber%rowtype;
  begin
    if p_valor is null or p_valor <= 0 then
      raise_application_error(-20030, 'Valor do pagamento deve ser maior que zero.');
    end if;

    select *
      into v_titulo
      from contas_receber
     where id = p_titulo_id
       for update;

    if v_titulo.status <> 'ABERTO' then
      raise_application_error(-20031, 'Título ' || p_titulo_id || ' não está em aberto.');
    end if;

    if v_titulo.valor_pago + p_valor > v_titulo.valor then
      raise_application_error(-20032,
        'Pagamento maior que o saldo do título. Saldo: ' || (v_titulo.valor - v_titulo.valor_pago));
    end if;

    update contas_receber
       set valor_pago = valor_pago + p_valor,
           data_pagamento = trunc(p_data)
     where id = p_titulo_id;

    update contas_receber
       set status = 'PAGO'
     where id = p_titulo_id
       and valor_pago >= valor;
  exception
    when no_data_found then
      raise_application_error(-20033, 'Título ' || p_titulo_id || ' não encontrado.');
  end;

  function saldo_cliente(p_cliente_id in number) return number is
    v_saldo number;
  begin
    select nvl(sum(valor - valor_pago), 0)
      into v_saldo
      from contas_receber
     where cliente_id = p_cliente_id
       and status = 'ABERTO';

    return v_saldo;
  end;

end pkg_financeiro;
/
