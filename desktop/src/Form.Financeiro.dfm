object frmFinanceiro: TfrmFinanceiro
  Left = 0
  Top = 0
  Caption = 'Contas a receber'
  ClientHeight = 500
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object chkSoVencidos: TCheckBox
      Left = 12
      Top = 14
      Width = 160
      Height = 17
      Caption = 'Somente vencidos'
      TabOrder = 0
      OnClick = btnAtualizarClick
    end
    object btnAtualizar: TButton
      Left = 190
      Top = 8
      Width = 84
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 1
      OnClick = btnAtualizarClick
    end
    object btnBaixar: TButton
      Left = 290
      Top = 8
      Width = 150
      Height = 30
      Caption = 'Receber / baixar...'
      TabOrder = 2
      OnClick = btnBaixarClick
    end
  end
  object grdTitulos: TDBGrid
    Left = 0
    Top = 45
    Width = 400
    Height = 300
    Align = alClient
    DataSource = dsTitulos
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDrawColumnCell = grdTitulosDrawColumnCell
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 464
    Width = 900
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblResumo: TLabel
      Left = 12
      Top = 9
      Width = 200
      Height = 20
      Caption = 'A receber: R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object qryTitulos: TFDQuery
    Left = 40
    Top = 200
  end
  object dsTitulos: TDataSource
    DataSet = qryTitulos
    Left = 120
    Top = 200
  end
end
