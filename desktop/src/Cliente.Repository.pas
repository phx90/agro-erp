unit Cliente.Repository;

interface

uses
  Cliente.Model;

type
  TClienteRepository = class
  public
    class function Buscar(AId: Integer): TCliente;
    class procedure Salvar(var ACliente: TCliente);
    class procedure Inativar(AId: Integer);
  end;

implementation

uses
  System.SysUtils, FireDAC.Comp.Client, Data.DB, Conexao.DataModule, Comum.Validacao;

{ TClienteRepository }

class function TClienteRepository.Buscar(AId: Integer): TCliente;
var
  Query: TFDQuery;
begin
  Query := dmConexao.NovaQuery(
    'select id, nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito ' +
    '  from clientes where id = :id');
  try
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if Query.IsEmpty then
      raise EValidacao.CreateFmt('Cliente %d não encontrado.', [AId]);

    Result.Id := Query.FieldByName('id').AsInteger;
    Result.Nome := Query.FieldByName('nome').AsString;
    Result.CpfCnpj := Query.FieldByName('cpf_cnpj').AsString;
    Result.Cidade := Query.FieldByName('cidade').AsString;
    Result.UF := Query.FieldByName('uf').AsString;
    Result.Telefone := Query.FieldByName('telefone').AsString;
    Result.Email := Query.FieldByName('email').AsString;
    Result.LimiteCredito := Query.FieldByName('limite_credito').AsFloat;
  finally
    Query.Free;
  end;
end;

class procedure TClienteRepository.Salvar(var ACliente: TCliente);
const
  SQL_INSERT =
    'insert into clientes (nome, cpf_cnpj, cidade, uf, telefone, email, limite_credito) ' +
    'values (:nome, :doc, :cidade, :uf, :telefone, :email, :limite) ' +
    'returning id into :id';
  SQL_UPDATE =
    'update clientes set nome = :nome, cpf_cnpj = :doc, cidade = :cidade, uf = :uf, ' +
    '       telefone = :telefone, email = :email, limite_credito = :limite ' +
    ' where id = :id';
var
  Query: TFDQuery;
begin
  ACliente.Validar;

  Query := dmConexao.NovaQuery(SQL_UPDATE);
  try
    if ACliente.EhNovo then
      Query.SQL.Text := SQL_INSERT;

    Query.ParamByName('nome').AsString := Trim(ACliente.Nome);
    Query.ParamByName('doc').AsString := SomenteNumeros(ACliente.CpfCnpj);
    Query.ParamByName('cidade').AsString := Trim(ACliente.Cidade);
    Query.ParamByName('uf').AsString := UpperCase(ACliente.UF);
    Query.ParamByName('telefone').AsString := Trim(ACliente.Telefone);
    Query.ParamByName('email').AsString := Trim(ACliente.Email);
    Query.ParamByName('limite').AsFloat := ACliente.LimiteCredito;

    Query.ParamByName('id').DataType := ftInteger;
    Query.ParamByName('id').AsInteger := ACliente.Id;
    if ACliente.EhNovo then
      Query.ParamByName('id').ParamType := ptOutput;

    Query.ExecSQL;
    ACliente.Id := Query.ParamByName('id').AsInteger;
  finally
    Query.Free;
  end;
end;

class procedure TClienteRepository.Inativar(AId: Integer);
begin
  dmConexao.Executar('update clientes set ativo = ''N'' where id = :id', [AId]);
end;

end.
