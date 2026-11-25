unit Pedido.Service;

interface

type
  TPedidoService = class
  public
    class function Criar(AClienteId: Integer; const AObservacao: string): Integer;
    class procedure AdicionarItem(APedidoId, AProdutoId: Integer; AQuantidade, ADesconto: Double);
    class procedure RemoverItem(AItemId: Integer);
    class procedure Faturar(APedidoId, AParcelas, AIntervaloDias: Integer);
    class procedure Cancelar(APedidoId: Integer);
  end;

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, Conexao.DataModule, Comum.Validacao;

{ TPedidoService }

// As regras ficam nas packages do banco. Aqui só valida o básico pra
// não ir ao banco à toa e repassa a chamada.

class function TPedidoService.Criar(AClienteId: Integer; const AObservacao: string): Integer;
var
  Query: TFDQuery;
begin
  Exigir(AClienteId > 0, 'Selecione o cliente.');

  Query := dmConexao.NovaQuery('begin :id := pkg_pedido.criar(:cliente, :obs); end;');
  try
    Query.ParamByName('id').DataType := ftInteger;
    Query.ParamByName('id').ParamType := ptOutput;
    Query.ParamByName('cliente').AsInteger := AClienteId;
    Query.ParamByName('obs').AsString := Trim(AObservacao);
    Query.ExecSQL;

    Result := Query.ParamByName('id').AsInteger;
  finally
    Query.Free;
  end;
end;

class procedure TPedidoService.AdicionarItem(APedidoId, AProdutoId: Integer; AQuantidade, ADesconto: Double);
var
  Query: TFDQuery;
begin
  Exigir(APedidoId > 0, 'Selecione um pedido.');
  Exigir(AProdutoId > 0, 'Selecione o produto.');
  Exigir(AQuantidade > 0, 'Quantidade deve ser maior que zero.');

  Query := dmConexao.NovaQuery(
    'begin :item := pkg_pedido.adicionar_item(:pedido, :produto, :qtd, :desconto); end;');
  try
    Query.ParamByName('item').DataType := ftInteger;
    Query.ParamByName('item').ParamType := ptOutput;
    Query.ParamByName('pedido').AsInteger := APedidoId;
    Query.ParamByName('produto').AsInteger := AProdutoId;
    Query.ParamByName('qtd').AsFloat := AQuantidade;
    Query.ParamByName('desconto').AsFloat := ADesconto;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

class procedure TPedidoService.RemoverItem(AItemId: Integer);
begin
  Exigir(AItemId > 0, 'Selecione o item.');
  dmConexao.Executar('begin pkg_pedido.remover_item(:item); end;', [AItemId]);
end;

class procedure TPedidoService.Faturar(APedidoId, AParcelas, AIntervaloDias: Integer);
begin
  Exigir(APedidoId > 0, 'Selecione um pedido.');
  Exigir((AParcelas >= 1) and (AParcelas <= 12), 'Parcelas deve ser entre 1 e 12.');

  dmConexao.Executar('begin pkg_pedido.faturar(:pedido, :parcelas, :intervalo); end;',
    [APedidoId, AParcelas, AIntervaloDias]);
end;

class procedure TPedidoService.Cancelar(APedidoId: Integer);
begin
  Exigir(APedidoId > 0, 'Selecione um pedido.');
  dmConexao.Executar('begin pkg_pedido.cancelar(:pedido); end;', [APedidoId]);
end;

end.
