object FSelArm: TFSelArm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1079#1080#1088#1086#1074#1072#1085#1085#1086#1077' '#1088#1072#1073#1086#1095#1077#1077' '#1084#1077#1089#1090#1086
  ClientHeight = 112
  ClientWidth = 251
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 16
  object Bt_oper: TBitBtn
    Tag = 20
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 245
    Height = 49
    Align = alTop
    Caption = '"'#1054#1087#1077#1088#1072#1090#1086#1088'"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = Select
  end
  object Bt_stat: TBitBtn
    Tag = 21
    AlignWithMargins = True
    Left = 3
    Top = 58
    Width = 245
    Height = 49
    Align = alTop
    Caption = '"'#1057#1090#1072#1090#1080#1089#1090'"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Select
  end
end