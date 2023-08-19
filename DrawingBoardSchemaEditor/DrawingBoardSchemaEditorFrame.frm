object frDrawingBoardSchemaEditor: TfrDrawingBoardSchemaEditor
  Left = 0
  Height = 475
  Top = 0
  Width = 1190
  Anchors = [akTop, akLeft, akRight]
  ClientHeight = 475
  ClientWidth = 1190
  OnResize = FrameResize
  TabOrder = 0
  DesignLeft = 86
  DesignTop = 85
  object pnlSchemaOI: TPanel
    Left = 0
    Height = 448
    Top = 0
    Width = 608
    Anchors = [akTop, akLeft, akBottom]
    Caption = 'pnlSchemaOI'
    TabOrder = 0
  end
  inline synedtCode: TSynEdit
    Left = 621
    Height = 448
    Top = 0
    Width = 563
    Anchors = [akTop, akLeft, akRight, akBottom]
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Pitch = fpFixed
    Font.Quality = fqNonAntialiased
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    Gutter.Width = 57
    Gutter.MouseActions = <>
    RightGutter.Width = 0
    RightGutter.MouseActions = <>
    Highlighter = SynPasSyn1
    Keystrokes = <    
      item
        Command = ecUp
        ShortCut = 38
      end    
      item
        Command = ecSelUp
        ShortCut = 8230
      end    
      item
        Command = ecScrollUp
        ShortCut = 16422
      end    
      item
        Command = ecDown
        ShortCut = 40
      end    
      item
        Command = ecSelDown
        ShortCut = 8232
      end    
      item
        Command = ecScrollDown
        ShortCut = 16424
      end    
      item
        Command = ecLeft
        ShortCut = 37
      end    
      item
        Command = ecSelLeft
        ShortCut = 8229
      end    
      item
        Command = ecWordLeft
        ShortCut = 16421
      end    
      item
        Command = ecSelWordLeft
        ShortCut = 24613
      end    
      item
        Command = ecRight
        ShortCut = 39
      end    
      item
        Command = ecSelRight
        ShortCut = 8231
      end    
      item
        Command = ecWordRight
        ShortCut = 16423
      end    
      item
        Command = ecSelWordRight
        ShortCut = 24615
      end    
      item
        Command = ecPageDown
        ShortCut = 34
      end    
      item
        Command = ecSelPageDown
        ShortCut = 8226
      end    
      item
        Command = ecPageBottom
        ShortCut = 16418
      end    
      item
        Command = ecSelPageBottom
        ShortCut = 24610
      end    
      item
        Command = ecPageUp
        ShortCut = 33
      end    
      item
        Command = ecSelPageUp
        ShortCut = 8225
      end    
      item
        Command = ecPageTop
        ShortCut = 16417
      end    
      item
        Command = ecSelPageTop
        ShortCut = 24609
      end    
      item
        Command = ecLineStart
        ShortCut = 36
      end    
      item
        Command = ecSelLineStart
        ShortCut = 8228
      end    
      item
        Command = ecEditorTop
        ShortCut = 16420
      end    
      item
        Command = ecSelEditorTop
        ShortCut = 24612
      end    
      item
        Command = ecLineEnd
        ShortCut = 35
      end    
      item
        Command = ecSelLineEnd
        ShortCut = 8227
      end    
      item
        Command = ecEditorBottom
        ShortCut = 16419
      end    
      item
        Command = ecSelEditorBottom
        ShortCut = 24611
      end    
      item
        Command = ecToggleMode
        ShortCut = 45
      end    
      item
        Command = ecCopy
        ShortCut = 16429
      end    
      item
        Command = ecPaste
        ShortCut = 8237
      end    
      item
        Command = ecDeleteChar
        ShortCut = 46
      end    
      item
        Command = ecCut
        ShortCut = 8238
      end    
      item
        Command = ecDeleteLastChar
        ShortCut = 8
      end    
      item
        Command = ecDeleteLastChar
        ShortCut = 8200
      end    
      item
        Command = ecDeleteLastWord
        ShortCut = 16392
      end    
      item
        Command = ecUndo
        ShortCut = 32776
      end    
      item
        Command = ecRedo
        ShortCut = 40968
      end    
      item
        Command = ecLineBreak
        ShortCut = 13
      end    
      item
        Command = ecSelectAll
        ShortCut = 16449
      end    
      item
        Command = ecCopy
        ShortCut = 16451
      end    
      item
        Command = ecBlockIndent
        ShortCut = 24649
      end    
      item
        Command = ecLineBreak
        ShortCut = 16461
      end    
      item
        Command = ecInsertLine
        ShortCut = 16462
      end    
      item
        Command = ecDeleteWord
        ShortCut = 16468
      end    
      item
        Command = ecBlockUnindent
        ShortCut = 24661
      end    
      item
        Command = ecPaste
        ShortCut = 16470
      end    
      item
        Command = ecCut
        ShortCut = 16472
      end    
      item
        Command = ecDeleteLine
        ShortCut = 16473
      end    
      item
        Command = ecDeleteEOL
        ShortCut = 24665
      end    
      item
        Command = ecUndo
        ShortCut = 16474
      end    
      item
        Command = ecRedo
        ShortCut = 24666
      end    
      item
        Command = ecGotoMarker0
        ShortCut = 16432
      end    
      item
        Command = ecGotoMarker1
        ShortCut = 16433
      end    
      item
        Command = ecGotoMarker2
        ShortCut = 16434
      end    
      item
        Command = ecGotoMarker3
        ShortCut = 16435
      end    
      item
        Command = ecGotoMarker4
        ShortCut = 16436
      end    
      item
        Command = ecGotoMarker5
        ShortCut = 16437
      end    
      item
        Command = ecGotoMarker6
        ShortCut = 16438
      end    
      item
        Command = ecGotoMarker7
        ShortCut = 16439
      end    
      item
        Command = ecGotoMarker8
        ShortCut = 16440
      end    
      item
        Command = ecGotoMarker9
        ShortCut = 16441
      end    
      item
        Command = ecSetMarker0
        ShortCut = 24624
      end    
      item
        Command = ecSetMarker1
        ShortCut = 24625
      end    
      item
        Command = ecSetMarker2
        ShortCut = 24626
      end    
      item
        Command = ecSetMarker3
        ShortCut = 24627
      end    
      item
        Command = ecSetMarker4
        ShortCut = 24628
      end    
      item
        Command = ecSetMarker5
        ShortCut = 24629
      end    
      item
        Command = ecSetMarker6
        ShortCut = 24630
      end    
      item
        Command = ecSetMarker7
        ShortCut = 24631
      end    
      item
        Command = ecSetMarker8
        ShortCut = 24632
      end    
      item
        Command = ecSetMarker9
        ShortCut = 24633
      end    
      item
        Command = EcFoldLevel1
        ShortCut = 41009
      end    
      item
        Command = EcFoldLevel2
        ShortCut = 41010
      end    
      item
        Command = EcFoldLevel3
        ShortCut = 41011
      end    
      item
        Command = EcFoldLevel4
        ShortCut = 41012
      end    
      item
        Command = EcFoldLevel5
        ShortCut = 41013
      end    
      item
        Command = EcFoldLevel6
        ShortCut = 41014
      end    
      item
        Command = EcFoldLevel7
        ShortCut = 41015
      end    
      item
        Command = EcFoldLevel8
        ShortCut = 41016
      end    
      item
        Command = EcFoldLevel9
        ShortCut = 41017
      end    
      item
        Command = EcFoldLevel0
        ShortCut = 41008
      end    
      item
        Command = EcFoldCurrent
        ShortCut = 41005
      end    
      item
        Command = EcUnFoldCurrent
        ShortCut = 41003
      end    
      item
        Command = EcToggleMarkupWord
        ShortCut = 32845
      end    
      item
        Command = ecNormalSelect
        ShortCut = 24654
      end    
      item
        Command = ecColumnSelect
        ShortCut = 24643
      end    
      item
        Command = ecLineSelect
        ShortCut = 24652
      end    
      item
        Command = ecTab
        ShortCut = 9
      end    
      item
        Command = ecShiftTab
        ShortCut = 8201
      end    
      item
        Command = ecMatchBracket
        ShortCut = 24642
      end    
      item
        Command = ecColSelUp
        ShortCut = 40998
      end    
      item
        Command = ecColSelDown
        ShortCut = 41000
      end    
      item
        Command = ecColSelLeft
        ShortCut = 40997
      end    
      item
        Command = ecColSelRight
        ShortCut = 40999
      end    
      item
        Command = ecColSelPageDown
        ShortCut = 40994
      end    
      item
        Command = ecColSelPageBottom
        ShortCut = 57378
      end    
      item
        Command = ecColSelPageUp
        ShortCut = 40993
      end    
      item
        Command = ecColSelPageTop
        ShortCut = 57377
      end    
      item
        Command = ecColSelLineStart
        ShortCut = 40996
      end    
      item
        Command = ecColSelLineEnd
        ShortCut = 40995
      end    
      item
        Command = ecColSelEditorTop
        ShortCut = 57380
      end    
      item
        Command = ecColSelEditorBottom
        ShortCut = 57379
      end>
    MouseActions = <>
    MouseTextActions = <>
    MouseSelActions = <>
    VisibleSpecialChars = [vscSpace, vscTabAtLast]
    SelectedColor.BackPriority = 50
    SelectedColor.ForePriority = 50
    SelectedColor.FramePriority = 50
    SelectedColor.BoldPriority = 50
    SelectedColor.ItalicPriority = 50
    SelectedColor.UnderlinePriority = 50
    SelectedColor.StrikeOutPriority = 50
    BracketHighlightStyle = sbhsBoth
    BracketMatchColor.Background = clNone
    BracketMatchColor.Foreground = clNone
    BracketMatchColor.Style = [fsBold]
    FoldedCodeColor.Background = clNone
    FoldedCodeColor.Foreground = clGray
    FoldedCodeColor.FrameColor = clGray
    MouseLinkColor.Background = clNone
    MouseLinkColor.Foreground = clBlue
    LineHighlightColor.Background = clNone
    LineHighlightColor.Foreground = clNone
    OnChange = synedtCodeChange
    inline SynLeftGutterPartList1: TSynGutterPartList
      object SynGutterMarks1: TSynGutterMarks
        Width = 24
        MouseActions = <>
      end
      object SynGutterLineNumber1: TSynGutterLineNumber
        Width = 17
        MouseActions = <>
        MarkupInfo.Background = clBtnFace
        MarkupInfo.Foreground = clNone
        DigitCount = 2
        ShowOnlyLineNumbersMultiplesOf = 1
        ZeroStart = False
        LeadingZeros = False
      end
      object SynGutterChanges1: TSynGutterChanges
        Width = 4
        MouseActions = <>
        ModifiedColor = 59900
        SavedColor = clGreen
      end
      object SynGutterSeparator1: TSynGutterSeparator
        Width = 2
        MouseActions = <>
        MarkupInfo.Background = clWhite
        MarkupInfo.Foreground = clGray
      end
      object SynGutterCodeFolding1: TSynGutterCodeFolding
        MouseActions = <>
        MarkupInfo.Background = clNone
        MarkupInfo.Foreground = clGray
        MouseActionsExpanded = <>
        MouseActionsCollapsed = <>
      end
    end
  end
  object lblSpacingInfo: TLabel
    Left = 546
    Height = 15
    Top = 456
    Width = 638
    Anchors = [akLeft, akBottom]
    Caption = 'The "'#7'" character is used at the beginning of a line, instead of a blank, because starting blanks are trimmed by ini parsing.'
  end
  object pnlHorizSplitter: TPanel
    Cursor = crHSplit
    Left = 609
    Height = 448
    Top = 0
    Width = 11
    Anchors = [akTop, akLeft, akBottom]
    Color = 13041606
    ParentColor = False
    TabOrder = 2
    OnMouseDown = pnlHorizSplitterMouseDown
    OnMouseMove = pnlHorizSplitterMouseMove
    OnMouseUp = pnlHorizSplitterMouseUp
  end
  object SynPasSyn1: TSynPasSyn
    Enabled = False
    CommentAttri.Foreground = clGray
    NumberAttri.Foreground = clBlue
    StringAttri.Foreground = clGreen
    DirectiveAttri.Foreground = clTeal
    CompilerMode = pcmDelphi
    NestedComments = False
    TypeHelpers = True
    Left = 932
    Top = 124
  end
  object pmCategories: TPopupMenu
    Left = 448
    Top = 144
    object MenuItem_AddProperty: TMenuItem
      Caption = 'Add property'
      OnClick = MenuItem_AddPropertyClick
    end
    object MenuItem_RemoveAllProperties: TMenuItem
      Caption = 'Remove all properties...'
      OnClick = MenuItem_RemoveAllPropertiesClick
    end
  end
  object pmProperties: TPopupMenu
    Left = 448
    Top = 216
    object MenuItem_RemoveProperty: TMenuItem
      Caption = 'Remove property...'
      OnClick = MenuItem_RemovePropertyClick
    end
  end
end
