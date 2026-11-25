object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'ERP Comercial'
  ClientHeight = 330
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Color = 7024384
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 14
      Width = 180
      Height = 30
      Caption = 'ERP Comercial'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -22
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 24
      Top = 48
      Width = 300
      Height = 15
      Caption = 'Pedidos, estoque e contas a receber'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 15132390
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object btnClientes: TButton
    Left = 24
    Top = 104
    Width = 225
    Height = 70
    Caption = 'Clientes'
    TabOrder = 1
    OnClick = btnClientesClick
  end
  object btnProdutos: TButton
    Left = 271
    Top = 104
    Width = 225
    Height = 70
    Caption = 'Produtos e estoque'
    TabOrder = 2
    OnClick = btnProdutosClick
  end
  object btnPedidos: TButton
    Left = 24
    Top = 192
    Width = 225
    Height = 70
    Caption = 'Pedidos de venda'
    TabOrder = 3
    OnClick = btnPedidosClick
  end
  object btnFinanceiro: TButton
    Left = 271
    Top = 192
    Width = 225
    Height = 70
    Caption = 'Contas a receber'
    TabOrder = 4
    OnClick = btnFinanceiroClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 311
    Width = 520
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
