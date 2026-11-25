// Cópia dos dados de exemplo do banco, usada quando a API não responde.
// Assim dá pra abrir o painel direto no navegador sem subir o Oracle.
const DADOS_DEMO = {
  pedidos: [
    {"id": 5, "data_pedido": "2026-11-24T16:10:00Z", "status": "CANCELADO", "valor_total": 840, "cliente": "Rural Center Andradina", "cidade": "Andradina", "uf": "SP", "qtd_itens": 1},
    {"id": 4, "data_pedido": "2026-11-24T10:42:00Z", "status": "ABERTO", "valor_total": 1466.64, "cliente": "João Batista Ferreira", "cidade": "Penápolis", "uf": "SP", "qtd_itens": 1},
    {"id": 3, "data_pedido": "2026-11-21T15:05:00Z", "status": "FATURADO", "valor_total": 17242, "cliente": "Fazenda Santa Helena", "cidade": "Guararapes", "uf": "SP", "qtd_itens": 2},
    {"id": 2, "data_pedido": "2026-11-13T09:20:00Z", "status": "FATURADO", "valor_total": 3420, "cliente": "Casa do Criador Birigui", "cidade": "Birigui", "uf": "SP", "qtd_itens": 2},
    {"id": 1, "data_pedido": "2026-11-10T11:37:00Z", "status": "FATURADO", "valor_total": 14598.6, "cliente": "Agropecuária Boa Vista Ltda", "cidade": "Araçatuba", "uf": "SP", "qtd_itens": 2}
  ],
  estoqueCritico: [
    {"codigo": "MOU005", "descricao": "Mourão de eucalipto tratado 2,2m", "unidade": "UN", "estoque_atual": 80, "estoque_minimo": 100, "falta": 20},
    {"codigo": "VAC004", "descricao": "Vacina aftosa 50 doses", "unidade": "FR", "estoque_atual": 20, "estoque_minimo": 30, "falta": 10},
    {"codigo": "ARA003", "descricao": "Arame farpado 500m", "unidade": "RL", "estoque_atual": 7, "estoque_minimo": 10, "falta": 3},
    {"codigo": "SEM006", "descricao": "Semente braquiária 20kg", "unidade": "SC", "estoque_atual": 12, "estoque_minimo": 15, "falta": 3}
  ],
  titulos: [
    {"id": 4, "pedido_id": 2, "parcela": 1, "vencimento": "2026-11-13T00:00:00Z", "saldo": 1710, "dias_atraso": 12, "cliente": "Casa do Criador Birigui"},
    {"id": 6, "pedido_id": 3, "parcela": 1, "vencimento": "2026-12-25T00:00:00Z", "saldo": 17242, "dias_atraso": 0, "cliente": "Fazenda Santa Helena"},
    {"id": 5, "pedido_id": 2, "parcela": 2, "vencimento": "2027-01-20T00:00:00Z", "saldo": 1710, "dias_atraso": 0, "cliente": "Casa do Criador Birigui"},
    {"id": 2, "pedido_id": 1, "parcela": 2, "vencimento": "2027-01-24T00:00:00Z", "saldo": 4866.2, "dias_atraso": 0, "cliente": "Agropecuária Boa Vista Ltda"},
    {"id": 3, "pedido_id": 1, "parcela": 3, "vencimento": "2027-02-23T00:00:00Z", "saldo": 4866.2, "dias_atraso": 0, "cliente": "Agropecuária Boa Vista Ltda"}
  ],
  resumo: [
    {"mes": "2026-11", "qtd_pedidos": 3, "total_vendido": 35260.6, "ticket_medio": 11753.53}
  ]
};
