object frDrawingBoard: TfrDrawingBoard
  Left = 0
  Height = 399
  Top = 0
  Width = 520
  Anchors = [akTop, akLeft, akRight, akBottom]
  ClientHeight = 399
  ClientWidth = 520
  TabOrder = 0
  TabStop = True
  DesignLeft = 86
  DesignTop = 85
  object pnlDrawingBoard: TPanel
    Left = 0
    Height = 399
    Top = 0
    Width = 520
    Alignment = taLeftJustify
    Anchors = [akTop, akLeft, akRight, akBottom]
    Caption = 'Drawing Board'
    ClientHeight = 399
    ClientWidth = 520
    Color = clWindow
    Constraints.MinHeight = 353
    Constraints.MinWidth = 520
    ParentColor = False
    PopupMenu = pmScreens
    TabOrder = 0
    object lblCurrentScreen: TLabel
      Left = 6
      Height = 15
      Top = 24
      Width = 121
      Caption = 'Current Screen Index: 0'
    end
    object lblTestBuild: TLabel
      Left = 97
      Height = 13
      Top = 0
      Width = 43
      Caption = 'TestBuild'
      Color = clRed
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      ParentFont = False
      Transparent = False
      Visible = False
    end
    object scrboxScreen: TScrollBox
      Left = 2
      Height = 353
      Top = 43
      Width = 516
      HorzScrollBar.Increment = 49
      HorzScrollBar.Page = 495
      HorzScrollBar.Smooth = True
      HorzScrollBar.Tracking = True
      VertScrollBar.Increment = 33
      VertScrollBar.Page = 332
      VertScrollBar.Smooth = True
      VertScrollBar.Tracking = True
      Anchors = [akTop, akLeft, akRight, akBottom]
      ClientHeight = 332
      ClientWidth = 495
      Color = clWhite
      ParentColor = False
      TabOrder = 0
      OnMouseWheel = scrboxScreenMouseWheel
      object pnlBackground: TPanel
        Left = 0
        Height = 1080
        Top = 0
        Width = 1920
        Color = clWhite
        FullRepaint = False
        ParentColor = False
        TabOrder = 1
      end
      object pnlScroll: TPanel
        Left = 0
        Height = 1080
        Top = 0
        Width = 1920
        ClientHeight = 1080
        ClientWidth = 1920
        Color = clWhite
        FullRepaint = False
        ParentColor = False
        PopupMenu = pmDrawingBoard
        TabOrder = 0
        OnClick = pnlScrollClick
        OnMouseDown = pnlScrollMouseDown
        OnMouseEnter = pnlScrollMouseEnter
        OnMouseLeave = pnlScrollMouseLeave
        OnMouseMove = pnlScrollMouseMove
        OnMouseUp = pnlScrollMouseUp
        object sttxtSelectionTop: TStaticText
          Left = 94
          Height = 5
          Top = 24
          Width = 50
          Color = 5622015
          ParentColor = False
          TabOrder = 0
          Visible = False
        end
        object sttxtSelectionLeft: TStaticText
          Left = 88
          Height = 50
          Top = 32
          Width = 5
          Color = 5622015
          ParentColor = False
          TabOrder = 1
          Visible = False
        end
        object sttxtSelectionRight: TStaticText
          Left = 144
          Height = 50
          Top = 32
          Width = 5
          Color = 5622015
          ParentColor = False
          TabOrder = 2
          Visible = False
        end
        object sttxtSelectionBottom: TStaticText
          Left = 93
          Height = 5
          Top = 84
          Width = 50
          Color = 5622015
          ParentColor = False
          TabOrder = 3
          Visible = False
        end
        object sttxtVertical: TStaticText
          Cursor = crSizeWE
          Left = 480
          Height = 1080
          Top = 0
          Width = 5
          Color = 11777023
          OnMouseDown = sttxtVerticalMouseDown
          OnMouseEnter = sttxtVerticalMouseEnter
          OnMouseLeave = sttxtVerticalMouseLeave
          OnMouseMove = sttxtVerticalMouseMove
          OnMouseUp = sttxtVerticalMouseUp
          ParentColor = False
          ParentShowHint = False
          PopupMenu = pmScreenEdges
          ShowHint = True
          TabOrder = 4
        end
        object sttxtHorizontal: TStaticText
          Cursor = crSizeNS
          Left = 0
          Height = 5
          Top = 272
          Width = 1920
          Color = 11777023
          OnMouseDown = sttxtHorizontalMouseDown
          OnMouseEnter = sttxtHorizontalMouseEnter
          OnMouseLeave = sttxtHorizontalMouseLeave
          OnMouseMove = sttxtHorizontalMouseMove
          OnMouseUp = sttxtHorizontalMouseUp
          ParentColor = False
          ParentShowHint = False
          PopupMenu = pmScreenEdges
          ShowHint = True
          TabOrder = 5
        end
        object sttxtIntersection: TStaticText
          Cursor = crSizeNWSE
          Left = 480
          Height = 5
          Top = 272
          Width = 5
          Color = clRed
          OnMouseDown = sttxtIntersectionMouseDown
          OnMouseEnter = sttxtIntersectionMouseEnter
          OnMouseLeave = sttxtIntersectionMouseLeave
          OnMouseMove = sttxtIntersectionMouseMove
          OnMouseUp = sttxtIntersectionMouseUp
          ParentColor = False
          ParentShowHint = False
          PopupMenu = pmScreenEdges
          ShowHint = True
          TabOrder = 6
        end
        object sttxtMatchTop: TStaticText
          Left = 16
          Height = 10
          Top = 136
          Width = 120
          Color = 9358336
          ParentColor = False
          TabOrder = 7
          Visible = False
        end
        object sttxtMatchBottom: TStaticText
          Left = 16
          Height = 10
          Top = 160
          Width = 120
          Color = 9358336
          ParentColor = False
          TabOrder = 8
          Visible = False
        end
        object sttxtMatchLeft: TStaticText
          Left = 48
          Height = 120
          Top = 96
          Width = 10
          Color = 9358336
          ParentColor = False
          TabOrder = 9
          Visible = False
        end
        object sttxtMatchRight: TStaticText
          Left = 72
          Height = 120
          Top = 96
          Width = 10
          Color = 9358336
          ParentColor = False
          TabOrder = 10
          Visible = False
        end
      end
    end
    object PageControlScreen: TPageControl
      Left = 229
      Height = 39
      Top = 3
      Width = 289
      TabStop = False
      ActivePage = ts
      Anchors = [akTop, akLeft, akRight]
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Images = imglstScreens
      ParentFont = False
      ParentShowHint = False
      PopupMenu = pmScreens
      ShowHint = True
      TabIndex = 0
      TabOrder = 1
      OnChange = PageControlScreenChange
      OnEnter = PageControlScreenEnter
      OnGetImageIndex = PageControlScreenGetImageIndex
      OnMouseDown = PageControlScreenMouseDown
      OnMouseEnter = PageControlScreenMouseEnter
      OnMouseLeave = PageControlScreenMouseLeave
      object ts: TTabSheet
        Caption = 'Screen'
        ImageIndex = 1
        OnMouseEnter = PageControlScreenMouseEnter
        OnMouseLeave = PageControlScreenMouseLeave
      end
    end
    object pnlSearchForScreen: TPanel
      Left = 176
      Height = 249
      Top = 32
      Width = 281
      ClientHeight = 249
      ClientWidth = 281
      TabOrder = 2
      Visible = False
      object lbeScreenNumber: TLabeledEdit
        Left = 8
        Height = 23
        Top = 220
        Width = 105
        Anchors = [akLeft, akBottom]
        EditLabel.Height = 15
        EditLabel.Width = 105
        EditLabel.Caption = 'Screen Number'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = lbeScreenNumberChange
        OnKeyDown = lbeScreenNumberKeyDown
        OnKeyPress = lbeScreenNumberKeyPress
      end
      object lbeScreenName: TLabeledEdit
        Left = 128
        Height = 23
        Top = 220
        Width = 145
        Anchors = [akLeft, akRight, akBottom]
        EditLabel.Height = 15
        EditLabel.Width = 145
        EditLabel.Caption = 'Screen Name'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = lbeScreenNameChange
        OnKeyDown = lbeScreenNameKeyDown
      end
    end
  end
  object pmScreens: TPopupMenu
    Images = imglstScreens
    OnPopup = pmScreensPopup
    Left = 371
    Top = 8
    object AddNewScreen1: TMenuItem
      Caption = 'Add new screen'
      OnClick = AddNewScreen1Click
    end
    object AddNewScreenandswitchtoit1: TMenuItem
      Caption = 'Add new screen and switch to it'
      OnClick = AddNewScreenandswitchtoit1Click
    end
    object Addnewscreenandsetitsname1: TMenuItem
      Caption = 'Add new screen and set its properties...'
      OnClick = Addnewscreenandsetitsname1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Editscreensettings1: TMenuItem
      Caption = 'Edit screen settings...'
      OnClick = Editscreensettings1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DeleteCurrentScreen1: TMenuItem
      Caption = 'Delete current screen...'
      OnClick = DeleteCurrentScreen1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Setcurrentscreento1: TMenuItem
      Tag = 10
      Caption = 'Set current screen to "Active"'
      ImageIndex = 1
      OnClick = Setcurrentscreento1Click
    end
    object SetcurrentscreentoInactive1: TMenuItem
      Tag = 11
      Caption = 'Set current screen to "Inactive"'
      ImageIndex = 0
      OnClick = SetcurrentscreentoInactive1Click
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object Searchforscreen1: TMenuItem
      Caption = 'Search for screen...'
      OnClick = Searchforscreen1Click
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object Persistcurrentscreen1: TMenuItem
      Tag = 20
      Caption = 'Persist current screen'
      ImageIndex = 3
      OnClick = Persistcurrentscreen1Click
    end
    object Donotpersistcurrentscreen1: TMenuItem
      Tag = 21
      Caption = 'Do not persist current screen'
      ImageIndex = 2
      OnClick = Donotpersistcurrentscreen1Click
    end
  end
  object imglstScreens: TImageList
    Left = 336
    Top = 8
    Bitmap = {
      4C7A060000001000000010000000930300000000000078DAED97DF4B145114C7
      F79F880AA21783827C100CFA413D444165E6AFF661D5D4FC91821A2459911064
      208A6EBB9ADBEA063D08E60F4C494ACDA21429CCF2452DA1B6148B90DD552CD6
      C5DDD5FC36F7CECE785DC7F1CE1284B5035FCEBD73CEE7FE9C337074BABFFF4C
      4E4EA2ADAD0D2D2D2D686E6EA66A6A6A92FBA4DDD8D828B75B5B5B697F646404
      125F5555A5A8CACA4AB96DB3D960B55A5157570793C984AEAE2ECA0F0D0D616E
      6E0E2E970B333333D406B7891C0E0795D3E9C4F4F4341A1A1A283F3E3E8EF6F6
      766E9179896A6B6B293F363626FBEC76FB1A91FDB192622D16CB2A9EF894E295
      44E2A5F947474743E26B6A6AFE084FEE51DA132F4B545D5DBD86D77207123F3C
      3C2CDF891699CD66F9FB331A8D282B2BE356797939952EFCE830F108A83F0E58
      8F00964382DD2FD883823D2CF6EF460377A2047B40E80B3EEB31A02201E87B08
      99CF8D002E44885612E9E7042C518930E615619C4BB178A72F12C612BF7F74DF
      03A6BCC0971FC0C44FC106C4B689EC2E4133C06787A04F982D2916F9573D407B
      04BF2C462A676E8AC8F73F967D27E73EAC11DD1FAB40EC745E7A80EF16DF093E
      C5782509F153B901FEE5D390F8C9ACF322FFE25948BC3D3353E47B9FAF9C0D27
      4BF43143E2FBB59D7FE00EDEA7E7887C67AF7C275A349E96237F7F2E831EDFE2
      63A9BE06EC7A9A883B8DEF896730909016CE7F8E67D78E59B00A951FEA007DB4
      8C11CC6DD15570F14A73F2EE41E28858469A5B8967E394E6E459B7DA7A79CF4C
      89E33D33A5314261251B2A1BBC8E50D88DDE6B8D09E7BC36EEC175AC126FDE05
      C7B3E3559D55FF7748716CFEB279ACC607B3243658C497BD15EBE6FF66E683C7
      D0CA4A3C1BCF8AB01BF1ECF723C5B35CA8FFB0707E6F9EFA9F5DD77DDB026EDD
      F08058F6BD5AFD4FFAEFDE2C22F9841B457A2FAE197CD4EA8FBAF1767091FAD5
      EA7FD22FCC76A334C38FD28B5E984A7CD45E8EF1233FD34DFD6AF57FF7131FAE
      1ABC2848F1C0960F985380DB0620719F07713BBDE811FC6AF57F67878FAEB920
      D583FADC95FC4B10F8D8ED3EEA57ABFF075FFB519CBA80428307A6B465CA9625
      2C232ED2037DE402F5ABD5FFA45F90E5C6CDA425C447CFE354941B317BE791BC
      6D097969ABF7AF54FFD3FB71FCA26795B4C74BD79CB4DB8BBC736E381DCB32BF
      5EFDCFDEF3409F9FEE9758F67DB8FEFF3FEA7F36FFB5D4FF6AF9CF53FFABE5FF
      46F53F4FFEABD5FF3CF9AF56FFF3E4FF46F5BF5AFEF3D4FF6AF9AFA5FE67F3FF
      5FADFF7F038586238E
    }
  end
  object pmDrawingBoard: TPopupMenu
    Left = 336
    Top = 136
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object SelectAllFromCurrentScreen1: TMenuItem
      Caption = 'Select All From Current Screen'
      OnClick = SelectAllFromCurrentScreen1Click
    end
    object SelectAllFromAllScreens1: TMenuItem
      Caption = 'Select All From All Screens'
      OnClick = SelectAllFromAllScreens1Click
    end
  end
  object pmScreenEdges: TPopupMenu
    Left = 464
    Top = 240
    object Lockscreenedges1: TMenuItem
      AutoCheck = True
      Caption = 'Screen edges are locked'
      RadioItem = True
      OnClick = Lockscreenedges1Click
    end
    object Screenedgesareunlocked1: TMenuItem
      AutoCheck = True
      Caption = 'Screen edges are unlocked'
      Checked = True
      RadioItem = True
      OnClick = Screenedgesareunlocked1Click
    end
  end
  object pmComponent: TPopupMenu
    OnPopup = pmComponentPopup
    Left = 400
    Top = 192
    object Cut1: TMenuItem
      Caption = 'Cut'
      OnClick = Cut1Click
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Delete1: TMenuItem
      Caption = 'Delete Selected'
      OnClick = Delete1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object BringtoFront1: TMenuItem
      Caption = 'Bring to Front'
      OnClick = BringtoFront1Click
    end
    object SendtoBack1: TMenuItem
      Caption = 'Send to Back'
      OnClick = SendtoBack1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Refreshselected1: TMenuItem
      Caption = 'Refresh selected'
      OnClick = Refreshselected1Click
    end
  end
end
