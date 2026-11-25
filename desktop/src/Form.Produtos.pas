unit Form.Produtos;

interface

uses
  System.SysUtils, System.Classes, System.Types, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Dialogs, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Produto.Model;

type
  TfrmProdutos = class(TForm)
    pnlBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TButton;
    chkSoCriticos: TCheckBox;
    grdLista: TDBGrid;
    pnlEdicao: TPanel;
    lblCodigo: TLabel;
    edtCodigo: TEdit;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lblUnidade: TLabel;
    edtUnidade: TEdit;
    lblPreco: TLabel;
    edtPreco: TEdit;
    lblMinimo: TLabel;
    edtMinimo: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnInativar: TButton;
    btnEntrada: TButton;
    qryLista: TFDQuery;
    dsLista: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnInativarClick(Sender: TObject);
    procedure btnEntradaClick(Sender: TObject);
    procedure grdListaCellClick(Column: TColumn);
    procedure grdListaDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    FIdAtual: Integer;
    procedure CarregarLista;
    procedure PreencherTela(const AProduto: TProduto);
    procedure LimparTela;
    function LerTela: TProduto;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes, Vcl.Graphics, Conexao.DataModule, Produto.Repository, Comum.Validacao;

const
  SQL_LISTA =
    'select id as "ID", codigo as "Código", descricao as "Descrição", unidade as "Un", ' +
    '       preco_venda as "Preço", estoque_atual as "Estoque", estoque_minimo as "Mínimo" ' +
    '  from produtos ' +
    ' where ativo = ''S'' ' +
    '   and (upper(descricao) like upper(:busca) or upper(codigo) like upper(:busca)) ' +
    '   and (:criticos = 0 or estoque_atual <= estoque_minimo) ' +
    ' order by descricao';

procedure TfrmProdutos.FormCreate(Sender: TObject);
begin
  qryLista.Connection := dmConexao.Conexao;
  qryLista.SQL.Text := SQL_LISTA;
  CarregarLista;
  LimparTela;
end;

procedure TfrmProdutos.CarregarLista;
begin
  qryLista.Close;
  qryLista.ParamByName('busca').AsString := '%' + Trim(edtBusca.Text) + '%';
  qryLista.ParamByName('criticos').AsInteger := Ord(chkSoCriticos.Checked);
  qryLista.Open;
end;

procedure TfrmProdutos.PreencherTela(const AProduto: TProduto);
begin
  FIdAtual := AProduto.Id;
  edtCodigo.Text := AProduto.Codigo;
  edtDescricao.Text := AProduto.Descricao;
  edtUnidade.Text := AProduto.Unidade;
  edtPreco.Text := FormatFloat('0.00', AProduto.PrecoVenda);
  edtMinimo.Text := FormatFloat('0.###', AProduto.EstoqueMinimo);
end;

procedure TfrmProdutos.LimparTela;
var
  Novo: TProduto;
begin
  Novo := Default(TProduto);
  Novo.Unidade := 'UN';
  PreencherTela(Novo);
  btnInativar.Enabled := False;
  btnEntrada.Enabled := False;
end;

function TfrmProdutos.LerTela: TProduto;
begin
  Result.Id := FIdAtual;
  Result.Codigo := edtCodigo.Text;
  Result.Descricao := edtDescricao.Text;
  Result.Unidade := edtUnidade.Text;
  Result.PrecoVenda := TextoParaValor(edtPreco.Text, 'Preço de venda');
  Result.EstoqueMinimo := TextoParaValor(edtMinimo.Text, 'Estoque mínimo');
end;

procedure TfrmProdutos.grdListaCellClick(Column: TColumn);
begin
  if qryLista.IsEmpty then
    Exit;

  PreencherTela(TProdutoRepository.Buscar(qryLista.FieldByName('ID').AsInteger));
  btnInativar.Enabled := True;
  btnEntrada.Enabled := True;
end;

procedure TfrmProdutos.grdListaDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  // destaca em vermelho o que está abaixo do mínimo
  if qryLista.FieldByName('Estoque').AsFloat <= qryLista.FieldByName('Mínimo').AsFloat then
    grdLista.Canvas.Font.Color := clRed;

  grdLista.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmProdutos.btnBuscarClick(Sender: TObject);
begin
  CarregarLista;
end;

procedure TfrmProdutos.btnNovoClick(Sender: TObject);
begin
  LimparTela;
  edtCodigo.SetFocus;
end;

procedure TfrmProdutos.btnSalvarClick(Sender: TObject);
var
  Produto: TProduto;
begin
  Produto := LerTela;
  TProdutoRepository.Salvar(Produto);

  CarregarLista;
  qryLista.Locate('ID', Produto.Id, []);
  PreencherTela(Produto);
  btnInativar.Enabled := True;
  btnEntrada.Enabled := True;
end;

procedure TfrmProdutos.btnInativarClick(Sender: TObject);
begin
  if FIdAtual = 0 then
    Exit;

  if MessageDlg('Inativar o produto "' + edtDescricao.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  TProdutoRepository.Inativar(FIdAtual);
  CarregarLista;
  LimparTela;
end;

procedure TfrmProdutos.btnEntradaClick(Sender: TObject);
var
  Texto: string;
begin
  if FIdAtual = 0 then
    Exit;

  Texto := '';
  if not InputQuery('Entrada de estoque', 'Quantidade recebida:', Texto) then
    Exit;

  TProdutoRepository.EntradaEstoque(FIdAtual, TextoParaValor(Texto, 'Quantidade'));
  CarregarLista;
  qryLista.Locate('ID', FIdAtual, []);
end;

end.
