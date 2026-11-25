-- Endpoints REST pro painel web, usando ORDS (o mesmo que roda por baixo do APEX).
-- Só precisa rodar se o ORDS estiver instalado. Sem ele o painel abre em modo demo.
--
-- Depois de rodar, os endpoints ficam em:
--   http://localhost:8080/ords/<schema>/erp/pedidos
--   http://localhost:8080/ords/<schema>/erp/estoque-critico
--   http://localhost:8080/ords/<schema>/erp/titulos-abertos
--   http://localhost:8080/ords/<schema>/erp/resumo

begin
  ords.enable_schema(p_enabled => true, p_url_mapping_type => 'BASE_PATH', p_url_mapping_pattern => lower(user));

  ords.define_module(p_module_name => 'erp', p_base_path => '/erp/');

  ords.define_template(p_module_name => 'erp', p_pattern => 'pedidos');
  ords.define_handler(
    p_module_name    => 'erp',
    p_pattern        => 'pedidos',
    p_method         => 'GET',
    p_source_type    => ords.source_type_collection_feed,
    p_items_per_page => 50,
    p_source         => q'[
      select id, data_pedido, status, valor_total, cliente, cidade, uf, qtd_itens
        from vw_pedidos
       order by id desc]'
  );

  ords.define_template(p_module_name => 'erp', p_pattern => 'estoque-critico');
  ords.define_handler(
    p_module_name    => 'erp',
    p_pattern        => 'estoque-critico',
    p_method         => 'GET',
    p_source_type    => ords.source_type_collection_feed,
    p_items_per_page => 100,
    p_source         => q'[
      select codigo, descricao, unidade, estoque_atual, estoque_minimo, falta
        from vw_estoque_critico
       order by falta desc]'
  );

  ords.define_template(p_module_name => 'erp', p_pattern => 'titulos-abertos');
  ords.define_handler(
    p_module_name    => 'erp',
    p_pattern        => 'titulos-abertos',
    p_method         => 'GET',
    p_source_type    => ords.source_type_collection_feed,
    p_items_per_page => 100,
    p_source         => q'[
      select id, pedido_id, parcela, vencimento, saldo, dias_atraso, cliente
        from vw_titulos_abertos
       order by vencimento]'
  );

  ords.define_template(p_module_name => 'erp', p_pattern => 'resumo');
  ords.define_handler(
    p_module_name    => 'erp',
    p_pattern        => 'resumo',
    p_method         => 'GET',
    p_source_type    => ords.source_type_collection_feed,
    p_items_per_page => 100,
    p_source         => q'[
      select to_char(mes, 'YYYY-MM') as mes, qtd_pedidos, total_vendido, ticket_medio
        from vw_resumo_vendas
       order by mes]'
  );

  commit;
end;
/
