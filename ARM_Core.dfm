object ARMCore: TARMCore
  Left = 0
  Top = 0
  Caption = #1052#1048#1057
  ClientHeight = 615
  ClientWidth = 910
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object MainMenu1: TMainMenu
    Left = 96
    Top = 24
    object M_arm: TMenuItem
      Caption = #1040#1056#1052
      Hint = #1040#1074#1090#1086#1084#1072#1090#1080#1079#1080#1088#1086#1074#1072#1085#1099#1077' '#1088#1072#1073#1086#1095#1077#1077' '#1084#1077#1089#1090#1086'..'
      object M_arm_oper: TMenuItem
        Tag = 1
        Caption = #1040#1056#1052' "'#1054#1087#1077#1088#1072#1090#1086#1088'"'
        Hint = #1040#1074#1090#1086#1084#1072#1090#1080#1079#1080#1088#1086#1074#1072#1085#1099#1077' '#1088#1072#1073#1086#1095#1077#1077' '#1084#1077#1089#1090#1086' '#1086#1087#1077#1088#1072#1090#1086#1088#1072'..'
        OnClick = MenuClick
      end
      object M_arm_stat: TMenuItem
        Tag = 2
        Caption = #1040#1056#1052' "'#1057#1090#1072#1090#1080#1089#1090'"'
        Hint = #1040#1074#1090#1086#1084#1072#1090#1080#1079#1080#1088#1086#1074#1072#1085#1099#1077' '#1088#1072#1073#1086#1095#1077#1077' '#1084#1077#1089#1090#1086' '#1089#1090#1072#1090#1080#1089#1072'..'
        OnClick = MenuClick
      end
    end
    object M_setting: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      object M_set_bd: TMenuItem
        Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
        OnClick = MenuClick
      end
    end
  end
end
