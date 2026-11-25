unit Cliente.Model;

interface

type
  TCliente = record
    Id: Integer;
    Nome: string;
    CpfCnpj: string;
    Cidade: string;
    UF: string;
    Telefone: string;
    Email: string;
    LimiteCredito: Double;
    function EhNovo: Boolean;
    procedure Validar;
  end;

implementation

uses
  System.SysUtils, Comum.Validacao;

{ TCliente }

function TCliente.EhNovo: Boolean;
begin
  Result := Id = 0;
end;

procedure TCliente.Validar;
var
  Documento: string;
begin
  Documento := SomenteNumeros(CpfCnpj);

  Exigir(Trim(Nome) <> '', 'Informe o nome do cliente.');
  Exigir(Length(Documento) in [11, 14], 'CPF/CNPJ deve ter 11 ou 14 dígitos.');
  Exigir((UF = '') or (Length(UF) = 2), 'UF deve ter 2 letras.');
  Exigir(LimiteCredito >= 0, 'Limite de crédito não pode ser negativo.');
end;

end.
