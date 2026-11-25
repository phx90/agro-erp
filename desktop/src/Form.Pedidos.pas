unit Form.Pedidos;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, Vcl.Dialogs,
  Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmPedidos = class(TForm)
    pnlNovo: TPanel;
    lblCliente: TLabel;
    cbxCliente: TDBLookupComboBox;
    lblObservacao: TLabel;
    edtObservacao: TEdit;
    btnNovo: TButton;
    pnlFiltro: TPanel;
    lblStatus: TLabel;
    cbxStatus: TComboBox;
    btnAtualizar: TButton;
    btnFaturar: TButton;
    btnCancelar: TButton;
    grdPedidos: TDBGrid;
    pnlItem: TPanel;
    lblProduto: TLabel;
    cbxProduto: TDBLookupComboBox;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    lblDesconto: TLabel;
    edtDesconto: TEdit;
    btnAdicionar: TButton;
    btnRemover: TButton;
    grdItens: TDBGrid;
    pnlRodape: TPanel;
    lblTotal: TLabel;
    qryPedidos: TFDQuery;
    dsPedidos: TDataSource;
    qryItens: TFDQuery;
    dsItens: TDataSource;
    qryClientes: TFDQuery;
    dsClientes: TDataSource;
    qryProdutos: TFDQuery;
    dsProdutos: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure qryPedidosAfterScroll(DataSet: TDataSet);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFaturarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverClick(Sender: TObject);
    procedure cbxStatusChange(Sender: TObject);
  private
    function PedidoAtual: Integer;
    function StatusAtual: string;
    procedure CarregarPedidos(AFocarPedido: Integer = 0);
    procedure CarregarItens;
    procedure AtualizarBotoes;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes, Conexao.DataModule, Pedido.Service, Comum.Validacao;

const
  STATUS_ABERTO = 'ABERTO';

  SQL_PEDIDOS =
    'select id as "Pedido", data_pedido as "Data", cliente as "Cliente", cidade as "Cidade", ' +
    '       status as "Status", qtd_itens as "Itens", valor_total as "Total" ' +
    '  from vw_pedidos ' +
    ' where (:status = ''TODOS'' or status = :status) ' +
    ' order by id desc';

  SQL_ITENS =
    'select i.id as "ID", p.codigo as "Código", p.descricao as "Produto", ' +
    '       i.quantidade as "Qtd", i.preco_unitario as "Preço", ' +
    '       i.desconto_pct as "Desc. %", i.valor_total as "Total" ' +
    '  from pedido_itens i ' +
    '  join produtos p on p.id = i.produto_id ' +
    ' where i.pedido_id = :pedido ' +
    ' order by i.id';

  SQL_CLIENTES =
    'select id, nome from clientes where ativo = ''S'' order by nome';

  SQL_PRODUTOS =
    'select id, codigo || '' - '' || descricao || '' ('' || estoque_atual || '' '' || unidade || '')'' as descricao ' +
    '  from produtos where ativo = ''S'' order by descricao';

procedure TfrmPedidos.FormCreate(Sender: TObject);
begin
  qryPedidos.Connection := dmConexao.Conexao;
  qryItens.Connection := dmConexao.Conexao;
  qryClientes.Connection := dmConexao.Conexao;
  qryProdutos.Connection := dmConexao.Conexao;

  qryPedidos.SQL.Text := SQL_PEDIDOS;
  qryItens.SQL.Text := SQL_ITENS;
  qryClientes.SQL.Text := SQL_CLIENTES;
  qryProdutos.SQL.Text := SQL_PRODUTOS;

  qryClientes.Open;
  qryProdutos.Open;
  CarregarPedidos;
end;

function TfrmPedidos.PedidoAtual: Integer;
begin
  Result := 0;
  if qryPedidos.IsEmpty then
    Exit;

  Result := qryPedidos.FieldByName('Pedido').AsInteger;
end;

function TfrmPedidos.StatusAtual: string;
begin
  Result := '';
  if qryPedidos.IsEmpty then
    Exit;

  Result := qryPedidos.FieldByName('Status').AsString;
end;

procedure TfrmPedidos.CarregarPedidos(AFocarPedido: Integer);
begin
  qryPedidos.DisableControls;
  try
    qryPedidos.Close;
    qryPedidos.ParamByName('status').AsString := UpperCase(cbxStatus.Text);
    qryPedidos.Open;

    if AFocarPedido > 0 then
      qryPedidos.Locate('Pedido', AFocarPedido, []);
  finally
    qryPedidos.EnableControls;
  end;

  // o AfterScroll não dispara quando a consulta volta vazia
  CarregarItens;
  AtualizarBotoes;
end;

procedure TfrmPedidos.CarregarItens;
begin
  qryItens.Close;
  qryItens.ParamByName('pedido').AsInteger := PedidoAtual;
  qryItens.Open;

  lblTotal.Caption := 'Total do pedido: ' +
    FormatFloat('R$ #,##0.00', qryPedidos.FieldByName('Total').AsFloat);
end;

procedure TfrmPedidos.AtualizarBotoes;
var
  Aberto: Boolean;
begin
  Aberto := StatusAtual = STATUS_ABERTO;

  btnFaturar.Enabled := Aberto;
  btnCancelar.Enabled := (StatusAtual <> '') and (StatusAtual <> 'CANCELADO');
  pnlItem.Enabled := Aberto;
  btnAdicionar.Enabled := Aberto;
  btnRemover.Enabled := Aberto and not qryItens.IsEmpty;
end;

procedure TfrmPedidos.qryPedidosAfterScroll(DataSet: TDataSet);
begin
  if qryPedidos.ControlsDisabled then
    Exit;

  CarregarItens;
  AtualizarBotoes;
end;

procedure TfrmPedidos.cbxStatusChange(Sender: TObject);
begin
  CarregarPedidos;
end;

procedure TfrmPedidos.btnAtualizarClick(Sender: TObject);
begin
  qryProdutos.Refresh;
  CarregarPedidos(PedidoAtual);
end;

procedure TfrmPedidos.btnNovoClick(Sender: TObject);
var
  PedidoId: Integer;
begin
  Exigir(not VarIsNull(cbxCliente.KeyValue), 'Selecione o cliente.');

  PedidoId := TPedidoService.Criar(cbxCliente.KeyValue, edtObservacao.Text);
  edtObservacao.Clear;

  cbxStatus.ItemIndex := cbxStatus.Items.IndexOf('Aberto');
  CarregarPedidos(PedidoId);
  cbxProduto.SetFocus;
end;

procedure TfrmPedidos.btnAdicionarClick(Sender: TObject);
var
  Pedido: Integer;
begin
  Exigir(not VarIsNull(cbxProduto.KeyValue), 'Selecione o produto.');

  Pedido := PedidoAtual;
  TPedidoService.AdicionarItem(
    Pedido,
    cbxProduto.KeyValue,
    TextoParaValor(edtQuantidade.Text, 'Quantidade'),
    TextoParaValor(edtDesconto.Text, 'Desconto'));

  edtQuantidade.Text := '1';
  edtDesconto.Text := '0';
  CarregarPedidos(Pedido);
end;

procedure TfrmPedidos.btnRemoverClick(Sender: TObject);
var
  Pedido: Integer;
begin
  if qryItens.IsEmpty then
    Exit;

  Pedido := PedidoAtual;
  TPedidoService.RemoverItem(qryItens.FieldByName('ID').AsInteger);
  CarregarPedidos(Pedido);
end;

procedure TfrmPedidos.btnFaturarClick(Sender: TObject);
var
  Pedido: Integer;
  Valores: array of string;
begin
  Pedido := PedidoAtual;
  Valores := ['1', '30'];

  if not InputQuery('Faturar pedido ' + Pedido.ToString,
    ['Quantidade de parcelas (1 a 12):', 'Dias entre parcelas:'], Valores) then
    Exit;

  TPedidoService.Faturar(Pedido,
    Trunc(TextoParaValor(Valores[0], 'Parcelas')),
    Trunc(TextoParaValor(Valores[1], 'Dias entre parcelas')));

  qryProdutos.Refresh;
  CarregarPedidos(Pedido);
  MessageDlg('Pedido faturado. Estoque baixado e parcelas geradas no contas a receber.',
    mtInformation, [mbOK], 0);
end;

procedure TfrmPedidos.btnCancelarClick(Sender: TObject);
var
  Pedido: Integer;
begin
  Pedido := PedidoAtual;

  if MessageDlg('Cancelar o pedido ' + Pedido.ToString + '? Se já foi faturado, o estoque volta e as parcelas são canceladas.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  TPedidoService.Cancelar(Pedido);
  qryProdutos.Refresh;
  CarregarPedidos(Pedido);
end;

end.
