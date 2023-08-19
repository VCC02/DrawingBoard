object frmDrawingBoardSchemaEditorMain: TfrmDrawingBoardSchemaEditorMain
  Left = 387
  Height = 536
  Top = 43
  Width = 1189
  Caption = 'DrawingBoard - SchemaEditor'
  ClientHeight = 516
  ClientWidth = 1189
  Menu = mmMain
  OnClose = FormClose
  OnCreate = FormCreate
  LCLVersion = '7.5'
  object pnlSchemaFrame: TPanel
    Left = 0
    Height = 488
    Top = 0
    Width = 1184
    Anchors = [akTop, akLeft, akRight, akBottom]
    Caption = 'pnlSchemaFrame'
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Height = 23
    Top = 493
    Width = 1189
    Panels = <    
      item
        Width = 65
      end    
      item
        Width = 500
      end>
    SimplePanel = False
  end
  object mmMain: TMainMenu
    Left = 496
    Top = 80
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
      object MenuItem_Exit: TMenuItem
        Caption = 'Exit'
        OnClick = MenuItem_ExitClick
      end
    end
    object MenuItem_SchemaProject: TMenuItem
      Caption = 'MetaSchema'
      object MenuItem_SetSchemaFromFile: TMenuItem
        Caption = 'Set metaschema from file...'
        OnClick = MenuItem_SetSchemaFromFileClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MenuItem_OpenSchemaProjectEditor: TMenuItem
        Caption = 'Open metaschema editor...'
        OnClick = MenuItem_OpenSchemaProjectEditorClick
      end
    end
  end
  object tmrStartup: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrStartupTimer
    Left = 616
    Top = 80
  end
end
