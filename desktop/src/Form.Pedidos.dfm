object frmPedidos: TfrmPedidos
  Left = 0
  Top = 0
  Caption = 'Pedidos de venda'
  ClientHeight = 640
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlNovo: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblCliente: TLabel
      Left = 12
      Top = 6
      Width = 60
      Height = 15
      Caption = 'Cliente'
    end
    object cbxCliente: TDBLookupComboBox
      Left = 12
      Top = 24
      Width = 320
      Height = 23
      KeyField = 'ID'
      ListField = 'NOME'
      ListSource = dsClientes
      TabOrder = 0
    end
    object lblObservacao: TLabel
      Left = 344
      Top = 6
      Width = 60
      Height = 15
      Caption = 'Observa'#231#227'o'
    end
    object edtObservacao: TEdit
      Left = 344
      Top = 24
      Width = 400
      Height = 23
      TabOrder = 1
      Text = ''
    end
    object btnNovo: TButton
      Left = 756
      Top = 20
      Width = 120
      Height = 30
      Caption = 'Novo pedido'
      TabOrder = 2
      OnClick = btnNovoClick
    end
  end
  object pnlFiltro: TPanel
    Left = 0
    Top = 60
    Width = 1000
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblStatus: TLabel
      Left = 12
      Top = 14
      Width = 60
      Height = 15
      Caption = 'Status:'
    end
    object cbxStatus: TComboBox
      Left = 60
      Top = 10
      Width = 140
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Todos'
      OnChange = cbxStatusChange
      Items.Strings = (
        'Todos'
        'Aberto'
        'Faturado'
        'Cancelado')
    end
    object btnAtualizar: TButton
      Left = 212
      Top = 7
      Width = 84
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 1
      OnClick = btnAtualizarClick
    end
    object btnFaturar: TButton
      Left = 576
      Top = 7
      Width = 110
      Height = 30
      Caption = 'Faturar...'
      TabOrder = 2
      OnClick = btnFaturarClick
    end
    object btnCancelar: TButton
      Left = 694
      Top = 7
      Width = 130
      Height = 30
      Caption = 'Cancelar pedido'
      TabOrder = 3
      OnClick = btnCancelarClick
    end
  end
  object grdPedidos: TDBGrid
    Left = 0
    Top = 104
    Width = 400
    Height = 230
    Align = alTop
    DataSource = dsPedidos
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlItem: TPanel
    Left = 0
    Top = 334
    Width = 1000
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object lblProduto: TLabel
      Left = 12
      Top = 6
      Width = 60
      Height = 15
      Caption = 'Produto'
    end
    object cbxProduto: TDBLookupComboBox
      Left = 12
      Top = 24
      Width = 430
      Height = 23
      KeyField = 'ID'
      ListField = 'DESCRICAO'
      ListSource = dsProdutos
      TabOrder = 0
    end
    object lblQuantidade: TLabel
      Left = 454
      Top = 6
      Width = 60
      Height = 15
      Caption = 'Quantidade'
    end
    object edtQuantidade: TEdit
      Left = 454
      Top = 24
      Width = 90
      Height = 23
      TabOrder = 1
      Text = '1'
    end
    object lblDesconto: TLabel
      Left = 556
      Top = 6
      Width = 60
      Height = 15
      Caption = 'Desconto %'
    end
    object edtDesconto: TEdit
      Left = 556
      Top = 24
      Width = 90
      Height = 23
      TabOrder = 2
      Text = '0'
    end
    object btnAdicionar: TButton
      Left = 658
      Top = 20
      Width = 120
      Height = 30
      Caption = 'Adicionar item'
      TabOrder = 3
      OnClick = btnAdicionarClick
    end
    object btnRemover: TButton
      Left = 786
      Top = 20
      Width = 120
      Height = 30
      Caption = 'Remover item'
      TabOrder = 4
      OnClick = btnRemoverClick
    end
  end
  object grdItens: TDBGrid
    Left = 0
    Top = 394
    Width = 400
    Height = 300
    Align = alClient
    DataSource = dsItens
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 604
    Width = 1000
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    object lblTotal: TLabel
      Left = 12
      Top = 9
      Width = 200
      Height = 20
      Caption = 'Total do pedido: R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object qryPedidos: TFDQuery
    AfterScroll = qryPedidosAfterScroll
    Left = 40
    Top = 440
  end
  object dsPedidos: TDataSource
    DataSet = qryPedidos
    Left = 120
    Top = 440
  end
  object qryItens: TFDQuery
    Left = 200
    Top = 440
  end
  object dsItens: TDataSource
    DataSet = qryItens
    Left = 280
    Top = 440
  end
  object qryClientes: TFDQuery
    Left = 360
    Top = 440
  end
  object dsClientes: TDataSource
    DataSet = qryClientes
    Left = 440
    Top = 440
  end
  object qryProdutos: TFDQuery
    Left = 520
    Top = 440
  end
  object dsProdutos: TDataSource
    DataSet = qryProdutos
    Left = 600
    Top = 440
  end
end
