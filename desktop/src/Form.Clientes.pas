unit Form.Clientes;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Dialogs, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Cliente.Model;

type
  TfrmClientes = class(TForm)
    pnlBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TButton;
    grdLista: TDBGrid;
    pnlEdicao: TPanel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblDocumento: TLabel;
    edtDocumento: TEdit;
    lblCidade: TLabel;
    edtCidade: TEdit;
    lblUF: TLabel;
    edtUF: TEdit;
    lblTelefone: TLabel;
    edtTelefone: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblLimite: TLabel;
    edtLimite: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnInativar: TButton;
    qryLista: TFDQuery;
    dsLista: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnInativarClick(Sender: TObject);
    procedure grdListaCellClick(Column: TColumn);
  private
    FIdAtual: Integer;
    procedure CarregarLista;
    procedure PreencherTela(const ACliente: TCliente);
    procedure LimparTela;
    function LerTela: TCliente;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes, Conexao.DataModule, Cliente.Repository, Comum.Validacao;

const
  SQL_LISTA =
    'select id as "ID", nome as "Nome", cpf_cnpj as "Documento", cidade as "Cidade", ' +
    '       uf as "UF", telefone as "Telefone", limite_credito as "Limite" ' +
    '  from clientes ' +
    ' where ativo = ''S'' ' +
    '   and upper(nome) like upper(:busca) ' +
    ' order by nome';

procedure TfrmClientes.FormCreate(Sender: TObject);
begin
  qryLista.Connection := dmConexao.Conexao;
  qryLista.SQL.Text := SQL_LISTA;
  CarregarLista;
  LimparTela;
end;

procedure TfrmClientes.CarregarLista;
begin
  qryLista.Close;
  qryLista.ParamByName('busca').AsString := '%' + Trim(edtBusca.Text) + '%';
  qryLista.Open;
end;

procedure TfrmClientes.PreencherTela(const ACliente: TCliente);
begin
  FIdAtual := ACliente.Id;
  edtNome.Text := ACliente.Nome;
  edtDocumento.Text := ACliente.CpfCnpj;
  edtCidade.Text := ACliente.Cidade;
  edtUF.Text := ACliente.UF;
  edtTelefone.Text := ACliente.Telefone;
  edtEmail.Text := ACliente.Email;
  edtLimite.Text := FormatFloat('0.00', ACliente.LimiteCredito);
end;

procedure TfrmClientes.LimparTela;
begin
  PreencherTela(Default(TCliente));
  btnInativar.Enabled := False;
end;

function TfrmClientes.LerTela: TCliente;
begin
  Result.Id := FIdAtual;
  Result.Nome := edtNome.Text;
  Result.CpfCnpj := edtDocumento.Text;
  Result.Cidade := edtCidade.Text;
  Result.UF := edtUF.Text;
  Result.Telefone := edtTelefone.Text;
  Result.Email := edtEmail.Text;
  Result.LimiteCredito := TextoParaValor(edtLimite.Text, 'Limite de crédito');
end;

procedure TfrmClientes.grdListaCellClick(Column: TColumn);
begin
  if qryLista.IsEmpty then
    Exit;

  PreencherTela(TClienteRepository.Buscar(qryLista.FieldByName('ID').AsInteger));
  btnInativar.Enabled := True;
end;

procedure TfrmClientes.btnBuscarClick(Sender: TObject);
begin
  CarregarLista;
end;

procedure TfrmClientes.btnNovoClick(Sender: TObject);
begin
  LimparTela;
  edtNome.SetFocus;
end;

procedure TfrmClientes.btnSalvarClick(Sender: TObject);
var
  Cliente: TCliente;
begin
  Cliente := LerTela;
  TClienteRepository.Salvar(Cliente);

  CarregarLista;
  qryLista.Locate('ID', Cliente.Id, []);
  PreencherTela(Cliente);
  btnInativar.Enabled := True;
end;

procedure TfrmClientes.btnInativarClick(Sender: TObject);
begin
  if FIdAtual = 0 then
    Exit;

  if MessageDlg('Inativar o cliente "' + edtNome.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  TClienteRepository.Inativar(FIdAtual);
  CarregarLista;
  LimparTela;
end;

end.
