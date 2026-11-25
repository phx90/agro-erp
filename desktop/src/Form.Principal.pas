unit Form.Principal;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs;

type
  TfrmPrincipal = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    btnClientes: TButton;
    btnProdutos: TButton;
    btnPedidos: TButton;
    btnFinanceiro: TButton;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnPedidosClick(Sender: TObject);
    procedure btnFinanceiroClick(Sender: TObject);
  private
    procedure TratarErro(Sender: TObject; E: Exception);
    procedure Abrir(AClasse: TFormClass);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses
  System.UITypes, Conexao.DataModule, Comum.Erros, Comum.Validacao,
  Form.Clientes, Form.Produtos, Form.Pedidos, Form.Financeiro;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  Application.OnException := TratarErro;
  StatusBar.SimpleText := 'Conectado em ' + dmConexao.Conexao.Params.Database +
    ' como ' + dmConexao.Conexao.Params.UserName;
end;

procedure TfrmPrincipal.TratarErro(Sender: TObject; E: Exception);
begin
  if E is EValidacao then
  begin
    MessageDlg(E.Message, mtWarning, [mbOK], 0);
    Exit;
  end;

  MessageDlg(MensagemAmigavel(E), mtError, [mbOK], 0);
end;

procedure TfrmPrincipal.Abrir(AClasse: TFormClass);
var
  Form: TForm;
begin
  Form := AClasse.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipal.btnClientesClick(Sender: TObject);
begin
  Abrir(TfrmClientes);
end;

procedure TfrmPrincipal.btnProdutosClick(Sender: TObject);
begin
  Abrir(TfrmProdutos);
end;

procedure TfrmPrincipal.btnPedidosClick(Sender: TObject);
begin
  Abrir(TfrmPedidos);
end;

procedure TfrmPrincipal.btnFinanceiroClick(Sender: TObject);
begin
  Abrir(TfrmFinanceiro);
end;

end.
