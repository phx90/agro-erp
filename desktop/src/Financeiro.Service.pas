unit Financeiro.Service;

interface

type
  TFinanceiroService = class
  public
    class procedure BaixarTitulo(ATituloId: Integer; AValor: Double);
  end;

implementation

uses
  Conexao.DataModule, Comum.Validacao;

{ TFinanceiroService }

class procedure TFinanceiroService.BaixarTitulo(ATituloId: Integer; AValor: Double);
begin
  Exigir(ATituloId > 0, 'Selecione um título.');
  Exigir(AValor > 0, 'Valor do pagamento deve ser maior que zero.');

  dmConexao.Executar('begin pkg_financeiro.baixar_titulo(:titulo, :valor); end;',
    [ATituloId, AValor]);
end;

end.
