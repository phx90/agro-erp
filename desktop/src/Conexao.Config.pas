unit Conexao.Config;

interface

type
  TConfigBanco = record
    Host: string;
    Porta: Integer;
    Servico: string;
    Usuario: string;
    Senha: string;
    function StringConexao: string;
    class function Carregar: TConfigBanco; static;
  end;

implementation

uses
  System.SysUtils, System.IniFiles;

const
  ARQUIVO_CONFIG = 'config.ini';
  SECAO = 'Banco';

{ TConfigBanco }

class function TConfigBanco.Carregar: TConfigBanco;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + ARQUIVO_CONFIG);
  try
    Result.Host := Ini.ReadString(SECAO, 'Host', 'localhost');
    Result.Porta := Ini.ReadInteger(SECAO, 'Porta', 1521);
    Result.Servico := Ini.ReadString(SECAO, 'Servico', 'FREEPDB1');
    Result.Usuario := Ini.ReadString(SECAO, 'Usuario', 'erp');
    Result.Senha := Ini.ReadString(SECAO, 'Senha', 'erp');
  finally
    Ini.Free;
  end;
end;

function TConfigBanco.StringConexao: string;
begin
  // formato EZConnect, dispensa tnsnames.ora
  Result := Format('//%s:%d/%s', [Host, Porta, Servico]);
end;

end.
