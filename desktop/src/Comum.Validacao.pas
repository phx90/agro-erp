unit Comum.Validacao;

interface

uses
  System.SysUtils;

type
  EValidacao = class(Exception);

procedure Exigir(ACondicao: Boolean; const AMensagem: string);
function SomenteNumeros(const ATexto: string): string;
function TextoParaValor(const ATexto, ACampo: string): Double;

implementation

procedure Exigir(ACondicao: Boolean; const AMensagem: string);
begin
  if ACondicao then
    Exit;

  raise EValidacao.Create(AMensagem);
end;

function SomenteNumeros(const ATexto: string): string;
var
  C: Char;
begin
  Result := '';
  for C in ATexto do
    if CharInSet(C, ['0'..'9']) then
      Result := Result + C;
end;

function TextoParaValor(const ATexto, ACampo: string): Double;
begin
  if TryStrToFloat(Trim(ATexto), Result) then
    Exit;

  raise EValidacao.CreateFmt('Valor inválido em "%s".', [ACampo]);
end;

end.
