object frmProdutos: TfrmProdutos
  Left = 0
  Top = 0
  Caption = 'Produtos e estoque'
  ClientHeight = 520
  ClientWidth = 940
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlBusca: TPanel
    Left = 0
    Top = 0
    Width = 940
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblBusca: TLabel
      Left = 12
      Top = 15
      Width = 40
      Height = 15
      Caption = 'Buscar:'
    end
    object edtBusca: TEdit
      Left = 60
      Top = 11
      Width = 300
      Height = 23
      TabOrder = 0
    end
    object btnBuscar: TButton
      Left = 368
      Top = 8
      Width = 84
      Height = 30
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
    object chkSoCriticos: TCheckBox
      Left = 470
      Top = 14
      Width = 220
      Height = 17
      Caption = 'Somente abaixo do m'#237'nimo'
      TabOrder = 2
    end
  end
  object pnlEdicao: TPanel
    Left = 640
    Top = 45
    Width = 300
    Height = 475
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    object lblCodigo: TLabel
      Left = 16
      Top = 16
      Width = 140
      Height = 15
      Caption = 'C'#243'digo'
    end
    object edtCodigo: TEdit
      Left = 16
      Top = 34
      Width = 140
      Height = 23
      TabOrder = 0
    end
    object lblDescricao: TLabel
      Left = 16
      Top = 68
      Width = 268
      Height = 15
      Caption = 'Descri'#231#227'o'
    end
    object edtDescricao: TEdit
      Left = 16
      Top = 86
      Width = 268
      Height = 23
      TabOrder = 1
    end
    object lblUnidade: TLabel
      Left = 16
      Top = 120
      Width = 60
      Height = 15
      Caption = 'Unidade'
    end
    object edtUnidade: TEdit
      Left = 16
      Top = 138
      Width = 60
      Height = 23
      TabOrder = 2
    end
    object lblPreco: TLabel
      Left = 16
      Top = 172
      Width = 140
      Height = 15
      Caption = 'Pre'#231'o de venda'
    end
    object edtPreco: TEdit
      Left = 16
      Top = 190
      Width = 140
      Height = 23
      TabOrder = 3
    end
    object lblMinimo: TLabel
      Left = 16
      Top = 224
      Width = 140
      Height = 15
      Caption = 'Estoque m'#237'nimo'
    end
    object edtMinimo: TEdit
      Left = 16
      Top = 242
      Width = 140
      Height = 23
      TabOrder = 4
    end
    object btnNovo: TButton
      Left = 16
      Top = 280
      Width = 84
      Height = 30
      Caption = 'Novo'
      TabOrder = 5
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 108
      Top = 280
      Width = 84
      Height = 30
      Caption = 'Salvar'
      TabOrder = 6
      OnClick = btnSalvarClick
    end
    object btnInativar: TButton
      Left = 200
      Top = 280
      Width = 84
      Height = 30
      Caption = 'Inativar'
      TabOrder = 7
      OnClick = btnInativarClick
    end
    object btnEntrada: TButton
      Left = 16
      Top = 320
      Width = 268
      Height = 30
      Caption = 'Entrada de estoque...'
      TabOrder = 8
      OnClick = btnEntradaClick
    end
  end
  object grdLista: TDBGrid
    Left = 0
    Top = 45
    Width = 400
    Height = 300
    Align = alClient
    DataSource = dsLista
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnCellClick = grdListaCellClick
    OnDrawColumnCell = grdListaDrawColumnCell
  end
  object qryLista: TFDQuery
    Left = 40
    Top = 200
  end
  object dsLista: TDataSource
    DataSet = qryLista
    Left = 120
    Top = 200
  end
end
