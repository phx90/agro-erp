-- Roda tudo na ordem. Use no SQL*Plus ou SQLcl conectado no schema do sistema:
--   sql erp/erp@localhost:1521/FREEPDB1 @instalar.sql

set define off
whenever sqlerror exit failure rollback

prompt Criando tabelas...
@@01_tabelas.sql

prompt Criando packages...
@@02_pkg_estoque.sql
@@03_pkg_pedido.sql
@@04_pkg_financeiro.sql

prompt Criando views...
@@05_views.sql

prompt Carregando dados de exemplo...
@@07_dados_exemplo.sql

prompt Pronto. Se tiver ORDS, rode o 06_api_ords.sql separado.
