create or replace view vw_pedidos as
select p.id,
       p.data_pedido,
       p.status,
       p.valor_total,
       p.data_faturamento,
       p.observacao,
       c.id   as cliente_id,
       c.nome as cliente,
       c.cidade,
       c.uf,
       (select count(*) from pedido_itens i where i.pedido_id = p.id) as qtd_itens
  from pedidos p
  join clientes c on c.id = p.cliente_id;

create or replace view vw_estoque_critico as
select id,
       codigo,
       descricao,
       unidade,
       estoque_atual,
       estoque_minimo,
       estoque_minimo - estoque_atual as falta
  from produtos
 where ativo = 'S'
   and estoque_atual <= estoque_minimo;

create or replace view vw_titulos_abertos as
select t.id,
       t.pedido_id,
       t.parcela,
       t.vencimento,
       t.valor,
       t.valor_pago,
       t.valor - t.valor_pago             as saldo,
       greatest(trunc(sysdate) - t.vencimento, 0) as dias_atraso,
       c.id   as cliente_id,
       c.nome as cliente
  from contas_receber t
  join clientes c on c.id = t.cliente_id
 where t.status = 'ABERTO';

-- usada no painel web
create or replace view vw_resumo_vendas as
select trunc(data_faturamento, 'MM')  as mes,
       count(*)                       as qtd_pedidos,
       sum(valor_total)               as total_vendido,
       round(avg(valor_total), 2)     as ticket_medio
  from pedidos
 where status = 'FATURADO'
 group by trunc(data_faturamento, 'MM');
