object frmDrawingBoardScreenEditor: TfrmDrawingBoardScreenEditor
  Left = 301
  Height = 170
  Top = 298
  Width = 522
  Caption = 'DrawingBoard - ScreenEditor'
  ClientHeight = 170
  ClientWidth = 522
  Color = clBtnFace
  Constraints.MinHeight = 170
  Constraints.MinWidth = 522
  OnClose = FormClose
  LCLVersion = '7.5'
  object lblR: TLabel
    Left = 423
    Height = 15
    Top = 64
    Width = 20
    Caption = 'lblR'
  end
  object lblG: TLabel
    Left = 423
    Height = 15
    Top = 83
    Width = 21
    Caption = 'lblG'
  end
  object lblB: TLabel
    Left = 423
    Height = 15
    Top = 102
    Width = 20
    Caption = 'lblB'
  end
  object lblColor: TLabel
    Left = 8
    Height = 15
    Top = 61
    Width = 29
    Caption = 'Color'
  end
  object lbeScreenName: TLabeledEdit
    Left = 8
    Height = 23
    Top = 24
    Width = 306
    EditLabel.Height = 15
    EditLabel.Width = 306
    EditLabel.Caption = 'Screen Name'
    TabOrder = 0
    OnKeyDown = lbeScreenNameKeyDown
  end
  object colcmbScreen: TColorBox
    Left = 8
    Height = 22
    Top = 80
    Width = 306
    Style = [cbStandardColors, cbExtendedColors, cbCustomColor]
    DropDownCount = 15
    ItemHeight = 16
    OnKeyDown = colcmbScreenKeyDown
    OnSelect = colcmbScreenSelect
    TabOrder = 1
  end
  object chkActive: TCheckBox
    Left = 320
    Height = 19
    Top = 8
    Width = 53
    Caption = 'Active'
    OnKeyDown = chkActiveKeyDown
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 150
    Height = 25
    Top = 128
    Width = 75
    Anchors = [akBottom]
    Caption = 'OK'
    OnClick = btnOKClick
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 271
    Height = 25
    Top = 128
    Width = 75
    Anchors = [akBottom]
    Caption = 'Cancel'
    OnClick = btnCancelClick
    TabOrder = 4
  end
  object pnlPreview: TPanel
    Left = 320
    Height = 51
    Top = 64
    Width = 97
    Caption = 'Preview'
    TabOrder = 5
  end
  object chkPersisted: TCheckBox
    Left = 320
    Height = 19
    Hint = 'Keeps components visible, regardles of their screen.'
    Top = 41
    Width = 67
    Caption = 'Persisted'
    OnKeyDown = chkPersistedKeyDown
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
end
