unit Form.Financeiro;

interface

uses
  System.SysUtils, System.Classes, System.Types, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Dialogs, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmFinanceiro = class(TForm)
    pnlTopo: TPanel;
    chkSoVencidos: TCheckBox;
    btnAtualizar: TButton;
    btnBaixar: TButton;
    grdTitulos: TDBGrid;
    pnlRodape: TPanel;
    lblResumo: TLabel;
    qryTitulos: TFDQuery;
    dsTitulos: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnBaixarClick(Sender: TObject);
    procedure grdTitulosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    procedure CarregarTitulos;
    procedure AtualizarResumo;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes, Vcl.Graphics, Conexao.DataModule, Financeiro.Service, Comum.Validacao;

const
  SQL_TITULOS =
    'select id as "Título", pedido_id as "Pedido", parcela as "Parcela", cliente as "Cliente", ' +
    '       vencimento as "Vencimento", valor as "Valor", valor_pago as "Pago", ' +
    '       saldo as "Saldo", dias_atraso as "Atraso (dias)" ' +
    '  from vw_titulos_abertos ' +
    ' where (:vencidos = 0 or dias_atraso > 0) ' +
    ' order by vencimento, cliente';

procedure TfrmFinanceiro.FormCreate(Sender: TObject);
begin
  qryTitulos.Connection := dmConexao.Conexao;
  qryTitulos.SQL.Text := SQL_TITULOS;
  CarregarTitulos;
end;

procedure TfrmFinanceiro.CarregarTitulos;
begin
  qryTitulos.Close;
  qryTitulos.ParamByName('vencidos').AsInteger := Ord(chkSoVencidos.Checked);
  qryTitulos.Open;
  AtualizarResumo;
end;

procedure TfrmFinanceiro.AtualizarResumo;
var
  Total, Vencido: Double;
begin
  Total := 0;
  Vencido := 0;

  qryTitulos.DisableControls;
  try
    qryTitulos.First;
    while not qryTitulos.Eof do
    begin
      Total := Total + qryTitulos.FieldByName('Saldo').AsFloat;
      if qryTitulos.FieldByName('Atraso (dias)').AsInteger > 0 then
        Vencido := Vencido + qryTitulos.FieldByName('Saldo').AsFloat;
      qryTitulos.Next;
    end;
    qryTitulos.First;
  finally
    qryTitulos.EnableControls;
  end;

  lblResumo.Caption := Format('A receber: %s     Vencido: %s', [
    FormatFloat('R$ #,##0.00', Total),
    FormatFloat('R$ #,##0.00', Vencido)]);
end;

procedure TfrmFinanceiro.grdTitulosDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if qryTitulos.FieldByName('Atraso (dias)').AsInteger > 0 then
    grdTitulos.Canvas.Font.Color := clRed;

  grdTitulos.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmFinanceiro.btnAtualizarClick(Sender: TObject);
begin
  CarregarTitulos;
end;

procedure TfrmFinanceiro.btnBaixarClick(Sender: TObject);
var
  TituloId: Integer;
  Valor: string;
begin
  if qryTitulos.IsEmpty then
    Exit;

  TituloId := qryTitulos.FieldByName('Título').AsInteger;
  Valor := FormatFloat('0.00', qryTitulos.FieldByName('Saldo').AsFloat);

  if not InputQuery('Baixar título ' + TituloId.ToString, 'Valor recebido:', Valor) then
    Exit;

  TFinanceiroService.BaixarTitulo(TituloId, TextoParaValor(Valor, 'Valor recebido'));
  CarregarTitulos;
end;

end.
