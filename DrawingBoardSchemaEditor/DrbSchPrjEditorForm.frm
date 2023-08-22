object frmDrbSchPrjEditor: TfrmDrbSchPrjEditor
  Left = 387
  Height = 483
  Top = 43
  Width = 700
  Caption = 'DrawingBoard - MetaSchema Editor'
  ClientHeight = 463
  ClientWidth = 700
  Menu = mmDrbSch
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  LCLVersion = '7.5'
  object pnlSchemaProjOI: TPanel
    Left = 0
    Height = 406
    Top = 0
    Width = 696
    Anchors = [akTop, akLeft, akRight, akBottom]
    Caption = 'pnlSchemaProjOI'
    TabOrder = 0
  end
  object lblInfo: TLabel
    Left = 0
    Height = 15
    Top = 416
    Width = 653
    Anchors = [akLeft, akBottom]
    Caption = 'This is an editor for metaschema files (*.drbsch), which are metadata schemas for DrawingBoard schemafiles (e.g. *.dynsch).'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Height = 23
    Top = 440
    Width = 700
    Panels = <    
      item
        Width = 65
      end    
      item
        Width = 500
      end>
    SimplePanel = False
  end
  object mmDrbSch: TMainMenu
    Left = 499
    Top = 388
    object MenuItem_File: TMenuItem
      Caption = 'File'
      object MenuItem_New: TMenuItem
        Caption = 'New'
        OnClick = MenuItem_NewClick
      end
      object MenuItem_Open: TMenuItem
        Caption = 'Open...'
        OnClick = MenuItem_OpenClick
      end
      object MenuItem_Save: TMenuItem
        Caption = 'Save'
        OnClick = MenuItem_SaveClick
      end
      object MenuItem_SaveAs: TMenuItem
        Caption = 'Save As...'
        OnClick = MenuItem_SaveAsClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object MenuItem_Close: TMenuItem
        Caption = 'Close'
        OnClick = MenuItem_CloseClick
      end
    end
  end
  object pmCategories: TPopupMenu
    Left = 304
    Top = 320
    object MenuItem_AddCategory: TMenuItem
      Caption = 'Add category'
      OnClick = MenuItem_AddCategoryClick
    end
  end
  object pmCategoryContent: TPopupMenu
    Left = 424
    Top = 320
    object MenuItem_AddCountableItem: TMenuItem
      Caption = 'Add countable item'
      OnClick = MenuItem_AddCountableItemClick
    end
    object MenuItem_RemoveAllCountableItems: TMenuItem
      Caption = 'Remove all countable items'
      OnClick = MenuItem_RemoveAllCountableItemsClick
    end
  end
  object pmProperty: TPopupMenu
    Left = 560
    Top = 320
    object MenuItem_RemoveProperty: TMenuItem
      Caption = 'Remove property'
      OnClick = MenuItem_RemovePropertyClick
    end
  end
end
