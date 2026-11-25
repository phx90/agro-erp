unit Produto.Model;

interface

type
  TProduto = record
    Id: Integer;
    Codigo: string;
    Descricao: string;
    Unidade: string;
    PrecoVenda: Double;
    EstoqueMinimo: Double;
    function EhNovo: Boolean;
    procedure Validar;
  end;

implementation

uses
  System.SysUtils, Comum.Validacao;

{ TProduto }

function TProduto.EhNovo: Boolean;
begin
  Result := Id = 0;
end;

procedure TProduto.Validar;
begin
  Exigir(Trim(Codigo) <> '', 'Informe o código do produto.');
  Exigir(Trim(Descricao) <> '', 'Informe a descrição do produto.');
  Exigir(Trim(Unidade) <> '', 'Informe a unidade (UN, SC, KG...).');
  Exigir(PrecoVenda >= 0, 'Preço de venda não pode ser negativo.');
  Exigir(EstoqueMinimo >= 0, 'Estoque mínimo não pode ser negativo.');
end;

end.
