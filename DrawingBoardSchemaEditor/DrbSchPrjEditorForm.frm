object frmDrbSchPrjEditor: TfrmDrbSchPrjEditor
  Left = 387
  Height = 483
  Top = 43
  Width = 700
  Caption = 'DrawingBoard - Schema Project Editor'
  ClientHeight = 463
  ClientWidth = 700
  Menu = mmDrbSch
  OnCreate = FormCreate
  LCLVersion = '7.5'
  object pnlSchemaProjOI: TPanel
    Left = 0
    Height = 406
    Top = 0
    Width = 688
    Anchors = [akTop, akLeft, akBottom]
    Caption = 'pnlSchemaProjOI'
    TabOrder = 0
  end
  object lblInfo: TLabel
    Left = 0
    Height = 15
    Top = 416
    Width = 666
    Anchors = [akLeft, akBottom]
    Caption = 'This is an editor for schema project files (*.drbsch), which are metadata schemas for DrawingBoard schemafiles (e.g. *.dynsch).'
  end
  object mmDrbSch: TMainMenu
    Left = 499
    Top = 388
    object MenuItem_File: TMenuItem
      Caption = 'File'
      object MenuItem_New: TMenuItem
        Caption = 'New'
      end
      object MenuItem_Open: TMenuItem
        Caption = 'Open...'
        OnClick = MenuItem_OpenClick
      end
    end
  end
end
