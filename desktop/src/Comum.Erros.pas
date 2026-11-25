unit Comum.Erros;

interface

uses
  System.SysUtils;

/// Extrai a mensagem de negócio de um erro ORA-20xxx levantado pelas packages.
/// Pra qualquer outro erro devolve a mensagem original.
function MensagemAmigavel(E: Exception): string;

implementation

uses
  System.StrUtils;

const
  PREFIXO_ERRO_NEGOCIO = 'ORA-20';

function MensagemAmigavel(E: Exception): string;
var
  Inicio, Fim: Integer;
begin
  Result := E.Message;

  Inicio := Pos(PREFIXO_ERRO_NEGOCIO, Result);
  if Inicio = 0 then
    Exit;

  // pula o "ORA-20011: "
  Inicio := PosEx(': ', Result, Inicio) + 2;
  Fim := PosEx(sLineBreak, Result, Inicio);
  if Fim = 0 then
    Fim := PosEx(#10, Result, Inicio);
  if Fim = 0 then
    Fim := Length(Result) + 1;

  Result := Trim(Copy(Result, Inicio, Fim - Inicio));
end;

end.
