object frmDrawingBoardScreenEditor: TfrmDrawingBoardScreenEditor
  Left = 0
  Top = 0
  Caption = 'DrawingBoard - ScreenEditor'
  ClientHeight = 171
  ClientWidth = 506
  Color = clBtnFace
  Constraints.MinHeight = 210
  Constraints.MinWidth = 522
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    506
    171)
  PixelsPerInch = 96
  TextHeight = 13
  object lblR: TLabel
    Left = 423
    Top = 64
    Width = 17
    Height = 13
    Caption = 'lblR'
  end
  object lblG: TLabel
    Left = 423
    Top = 83
    Width = 17
    Height = 13
    Caption = 'lblG'
  end
  object lblB: TLabel
    Left = 423
    Top = 102
    Width = 16
    Height = 13
    Caption = 'lblB'
  end
  object lblColor: TLabel
    Left = 8
    Top = 61
    Width = 25
    Height = 13
    Caption = 'Color'
  end
  object lbeScreenName: TLabeledEdit
    Left = 8
    Top = 24
    Width = 306
    Height = 21
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = 'Screen Name'
    TabOrder = 0
    OnKeyDown = lbeScreenNameKeyDown
  end
  object colcmbScreen: TColorBox
    Left = 8
    Top = 80
    Width = 306
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbCustomColor]
    DropDownCount = 15
    ItemHeight = 16
    TabOrder = 1
    OnKeyDown = colcmbScreenKeyDown
    OnSelect = colcmbScreenSelect
  end
  object chkActive: TCheckBox
    Left = 320
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Active'
    TabOrder = 2
    OnKeyDown = chkActiveKeyDown
  end
  object btnOK: TButton
    Left = 144
    Top = 128
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'OK'
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 262
    Top = 128
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object pnlPreview: TPanel
    Left = 320
    Top = 64
    Width = 97
    Height = 51
    Caption = 'Preview'
    TabOrder = 5
  end
  object chkPersisted: TCheckBox
    Left = 320
    Top = 41
    Width = 97
    Height = 17
    Hint = 'Keeps components visible, regardles of their screen.'
    Caption = 'Persisted'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnKeyDown = chkPersistedKeyDown
  end
end
