unit Produto.Repository;

interface

uses
  Produto.Model;

type
  TProdutoRepository = class
  public
    class function Buscar(AId: Integer): TProduto;
    class procedure Salvar(var AProduto: TProduto);
    class procedure Inativar(AId: Integer);
    class procedure EntradaEstoque(AId: Integer; AQuantidade: Double);
  end;

implementation

uses
  System.SysUtils, FireDAC.Comp.Client, Data.DB, Conexao.DataModule, Comum.Validacao;

{ TProdutoRepository }

class function TProdutoRepository.Buscar(AId: Integer): TProduto;
var
  Query: TFDQuery;
begin
  Query := dmConexao.NovaQuery(
    'select id, codigo, descricao, unidade, preco_venda, estoque_minimo ' +
    '  from produtos where id = :id');
  try
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if Query.IsEmpty then
      raise EValidacao.CreateFmt('Produto %d não encontrado.', [AId]);

    Result.Id := Query.FieldByName('id').AsInteger;
    Result.Codigo := Query.FieldByName('codigo').AsString;
    Result.Descricao := Query.FieldByName('descricao').AsString;
    Result.Unidade := Query.FieldByName('unidade').AsString;
    Result.PrecoVenda := Query.FieldByName('preco_venda').AsFloat;
    Result.EstoqueMinimo := Query.FieldByName('estoque_minimo').AsFloat;
  finally
    Query.Free;
  end;
end;

class procedure TProdutoRepository.Salvar(var AProduto: TProduto);
const
  SQL_INSERT =
    'insert into produtos (codigo, descricao, unidade, preco_venda, estoque_minimo) ' +
    'values (:codigo, :descricao, :unidade, :preco, :minimo) ' +
    'returning id into :id';
  SQL_UPDATE =
    'update produtos set codigo = :codigo, descricao = :descricao, unidade = :unidade, ' +
    '       preco_venda = :preco, estoque_minimo = :minimo ' +
    ' where id = :id';
var
  Query: TFDQuery;
begin
  AProduto.Validar;

  Query := dmConexao.NovaQuery(SQL_UPDATE);
  try
    if AProduto.EhNovo then
      Query.SQL.Text := SQL_INSERT;

    Query.ParamByName('codigo').AsString := UpperCase(Trim(AProduto.Codigo));
    Query.ParamByName('descricao').AsString := Trim(AProduto.Descricao);
    Query.ParamByName('unidade').AsString := UpperCase(Trim(AProduto.Unidade));
    Query.ParamByName('preco').AsFloat := AProduto.PrecoVenda;
    Query.ParamByName('minimo').AsFloat := AProduto.EstoqueMinimo;

    Query.ParamByName('id').DataType := ftInteger;
    Query.ParamByName('id').AsInteger := AProduto.Id;
    if AProduto.EhNovo then
      Query.ParamByName('id').ParamType := ptOutput;

    Query.ExecSQL;
    AProduto.Id := Query.ParamByName('id').AsInteger;
  finally
    Query.Free;
  end;
end;

class procedure TProdutoRepository.Inativar(AId: Integer);
begin
  dmConexao.Executar('update produtos set ativo = ''N'' where id = :id', [AId]);
end;

class procedure TProdutoRepository.EntradaEstoque(AId: Integer; AQuantidade: Double);
begin
  Exigir(AQuantidade > 0, 'Quantidade deve ser maior que zero.');

  dmConexao.Executar(
    'begin pkg_estoque.registrar_entrada(:produto, :qtd, ''COMPRA''); end;',
    [AId, AQuantidade]);
end;

end.
