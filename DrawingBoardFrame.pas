{
    Copyright (C) 2023 VCC
    creation date: Jul 2023  (parts of the code: 2013-2019, from DynTFTCodeGen)
    initial release date: 08 Aug 2023

    author: VCC
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

{ Extra disclaimer/info:
  The code in this file is extracted from DynTFTCodeGen's main form.
  It is intended to be decoupled as much as possible from that form.
  Since the original code was not very clean and organized, the current API
  (what the class exposes) is still messy, i.e. does't make much sense.
  There are also references and concepts from the DynTFT project, which should
  be removed/replaced or abstracted.

  The drawing board requires complex structures to manage its components, so
  the class ended up exposing those structures, because they are required in the
  existing code generator from DynTFTCodeGen. They should be avoided in other
  projects, as they should be removed eventually and replaced by accessors.
  For the first versions of this file, it is still unclear if this class should
  own the mentioned structures (FAllComponents, FAllVisualComponents, FAllScreens).
  For starters, the intention is to have a working code for DynTFTCodeGen.

  This file should be further split into two files, one which has no structure
  of visual components (it uses callbacks) and the other, which works with all
  these structures and has mostly the current API.

  Another limiation of the bad code is that users won't know when to call certain
  methods, or if they required them. This is also the case for callbacks.

  There is a lot of decoupling to be done and a lot of refactoring.

  The plugins, mentioned both in API and code, are a DynTFTCodeGen feature, which
  is not completely separated from the DrawingBoard.
  A plugin implements a set of components. The API handles component indexing.
}


{$IFDEF FPC}
  {$mode objfpc} {$H+}
{$ENDIF}


unit DrawingBoardFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Types,
  Dialogs, ExtCtrls, Menus, StdCtrls, VirtualTrees, ComCtrls, ImgList, IniFiles
  , DrawingBoardDataTypes
  , DrawingBoardUtils
  , DynTFTCodeGenSharedDataTypes
  ;

type
  TOnDrawComponentOnPanel = procedure(APanel: TMountPanel; var AAllComponents: TDynTFTDesignAllComponentsArr; var AAllVisualComponents: TProjectVisualComponentArr) of object;
  TOnAddItemToSelCompListInOI = procedure(ACompName: string) of object;  //Adds an item to the combobox, right above the ObjectInspector.
  TOnCancelObjectInspectorEditing = procedure of object;
  TOnClearObjectInspector = procedure of object;
  TOnDrawingBoardModified = procedure of object;
  TOnRefreshObjectInspector = procedure of object;
  TOnGetDefaultScreenColor = procedure(var AColor: TColor; var AColorName: string) of object;
  TOnLookupColorConstantInBaseSchema = function(ConstName: string; DefaultValue: TColor): TColor of object;
  TOnSelectAllPanels = procedure(AMsg, AHint: string) of object;
  TOnDeleteComponentByPanel = procedure(APanel: TMountPanel) of object;
  TOnGetComponentIndexFromPlugin = procedure(ACompTypeIndex: Integer; var ACategoryIndex, AComponentIndex: Integer) of object;

  TOnAddNewHandlerToAllHandlersByHandlerType = procedure(ATypeName, AHandlerName: string) of object;
  TOnEditScreen = function(var AScreen: TScreenInfo): Boolean of object;
  TOnDrawingBoardMouseMove = procedure(X, Y: Integer) of object;
  TOnDrawingBoardCanFocus = function: Boolean of object;
  TOnDisplayScreenSize = procedure(AWidth, AHeight: Integer) of object;
  TOnDrawingBoardRemoveFocus = procedure of object;
  TOnSetCustomPropertyValueOnLoading = procedure(APropertyName: string; ACompType: Integer; var APropertyValue: string) of object;
  TOnResolveColorConst = function(AColorName: string): TColor of object;

  TOnAfterMovingMountPanel = procedure(APanel: TMountPanel) of object;

  TPropertyGroup = record
    GroupName: string;
    UsedCount: Integer; //Number of components from this group. - Field updated and used by project settings on form show
    UsedComponents: string; //TStringList.Text - Field updated and used by project settings on form show (and editing)
  end;

  TPropertyGroupArr = array of TPropertyGroup;


  TfrDrawingBoard = class(TFrame)
    pnlDrawingBoard: TPanel;
    lblCurrentScreen: TLabel;
    lblTestBuild: TLabel;
    scrboxScreen: TScrollBox;
    pnlBackground: TPanel;
    pnlScroll: TPanel;
    sttxtSelectionTop: TStaticText;
    sttxtSelectionLeft: TStaticText;
    sttxtSelectionRight: TStaticText;
    sttxtSelectionBottom: TStaticText;
    sttxtVertical: TStaticText;
    sttxtHorizontal: TStaticText;
    sttxtIntersection: TStaticText;
    sttxtMatchTop: TStaticText;
    sttxtMatchBottom: TStaticText;
    sttxtMatchLeft: TStaticText;
    sttxtMatchRight: TStaticText;
    PageControlScreen: TPageControl;
    ts: TTabSheet;
    pnlSearchForScreen: TPanel;
    lbeScreenNumber: TLabeledEdit;
    lbeScreenName: TLabeledEdit;
    pmScreens: TPopupMenu;
    AddNewScreen1: TMenuItem;
    AddNewScreenandswitchtoit1: TMenuItem;
    Addnewscreenandsetitsname1: TMenuItem;
    N1: TMenuItem;
    Editscreensettings1: TMenuItem;
    N2: TMenuItem;
    DeleteCurrentScreen1: TMenuItem;
    N3: TMenuItem;
    Setcurrentscreento1: TMenuItem;
    SetcurrentscreentoInactive1: TMenuItem;
    N11: TMenuItem;
    Searchforscreen1: TMenuItem;
    N14: TMenuItem;
    Persistcurrentscreen1: TMenuItem;
    Donotpersistcurrentscreen1: TMenuItem;
    imglstScreens: TImageList;
    pmDrawingBoard: TPopupMenu;
    Paste1: TMenuItem;
    N12: TMenuItem;
    SelectAllFromCurrentScreen1: TMenuItem;
    SelectAllFromAllScreens1: TMenuItem;
    pmScreenEdges: TPopupMenu;
    Lockscreenedges1: TMenuItem;
    Screenedgesareunlocked1: TMenuItem;
    pmComponent: TPopupMenu;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Delete1: TMenuItem;
    N4: TMenuItem;
    BringtoFront1: TMenuItem;
    SendtoBack1: TMenuItem;
    N6: TMenuItem;
    Refreshselected1: TMenuItem;
    procedure AddNewScreen1Click(Sender: TObject);
    procedure AddNewScreenandswitchtoit1Click(Sender: TObject);
    procedure Addnewscreenandsetitsname1Click(Sender: TObject);
    procedure Editscreensettings1Click(Sender: TObject);
    procedure DeleteCurrentScreen1Click(Sender: TObject);
    procedure Setcurrentscreento1Click(Sender: TObject);
    procedure SetcurrentscreentoInactive1Click(Sender: TObject);
    procedure Searchforscreen1Click(Sender: TObject);
    procedure Persistcurrentscreen1Click(Sender: TObject);
    procedure Donotpersistcurrentscreen1Click(Sender: TObject);
    procedure pmScreensPopup(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure SelectAllFromCurrentScreen1Click(Sender: TObject);
    procedure SelectAllFromAllScreens1Click(Sender: TObject);
    procedure pnlScrollClick(Sender: TObject);
    procedure pnlScrollMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlScrollMouseEnter(Sender: TObject);
    procedure pnlScrollMouseLeave(Sender: TObject);
    procedure pnlScrollMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnlScrollMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Lockscreenedges1Click(Sender: TObject);
    procedure Screenedgesareunlocked1Click(Sender: TObject);
    procedure sttxtVerticalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sttxtVerticalMouseEnter(Sender: TObject);
    procedure sttxtVerticalMouseLeave(Sender: TObject);
    procedure sttxtVerticalMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sttxtVerticalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sttxtHorizontalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sttxtHorizontalMouseEnter(Sender: TObject);
    procedure sttxtHorizontalMouseLeave(Sender: TObject);
    procedure sttxtHorizontalMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sttxtHorizontalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sttxtIntersectionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sttxtIntersectionMouseEnter(Sender: TObject);
    procedure sttxtIntersectionMouseLeave(Sender: TObject);
    procedure sttxtIntersectionMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sttxtIntersectionMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControlScreenChange(Sender: TObject);
    procedure PageControlScreenEnter(Sender: TObject);
    procedure PageControlScreenGetImageIndex(Sender: TObject; TabIndex: Integer;
      var ImageIndex: Integer);
    procedure PageControlScreenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControlScreenMouseEnter(Sender: TObject);
    procedure PageControlScreenMouseLeave(Sender: TObject);
    procedure vstScreensDblClick(Sender: TObject);
    procedure vstScreensGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: {$IFnDEF FPC}WideString{$ELSE}string{$ENDIF});
    procedure vstScreensGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstScreensKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbeScreenNumberChange(Sender: TObject);
    procedure lbeScreenNumberKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbeScreenNumberKeyPress(Sender: TObject; var Key: Char);
    procedure lbeScreenNameChange(Sender: TObject);
    procedure lbeScreenNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure BringtoFront1Click(Sender: TObject);
    procedure SendtoBack1Click(Sender: TObject);
    procedure Refreshselected1Click(Sender: TObject);
    procedure pmComponentPopup(Sender: TObject);
    procedure scrboxScreenMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }

    FAllComponents: TDynTFTDesignAllComponentsArr;
    FAllVisualComponents: TProjectVisualComponentArr; //pointers (i.e. indexes) to FAllComponents
    FVisibleComponents: array of Integer; //indexes in FAllVisualComponents   (visible panels on DrawingBoard), used to display component guide lines

    FAllScreens: TScreenInfoArr;
    FSelectionContent: TSelectionContent;

    FCompSelectionMinLeft: Integer;
    FCompSelectionMinTop: Integer;
    FCompSelectionMaxRight: Integer;
    FCompSelectionMaxBottom: Integer;

    FVisibleCompUnSelMinLeft: Integer;
    FVisibleCompUnSelMinTop: Integer;
    FVisibleCompUnSelMaxRight: Integer;
    FVisibleCompUnSelMaxBottom: Integer;

    FMouseDownGlobalPos: TPoint;
    FMouseDownComponentPos: TPoint;
    FMouseDownSttxtPos: TPoint;
    //FRightClickComponent: TComponent;
    FRightClickPanel: TMountPanel;

    FPanelHold: Boolean;
    FDragLocked: Boolean;
    FSttxtHold: Boolean;
    FCornerHold: Boolean;
    FPanelDoubleClick: Boolean;

    FWinSelX1: Integer;
    FWinSelY1: Integer;
    FSelX1, FSelX2, FSelY1, FSelY2: Integer;
    FPasteX, FPasteY: Integer;

    FMinPxToUnlockDrag: Integer;
    FShouldFocusDrawingBoardOnMouseEnter: Boolean;

    FPageMouseIn: Boolean;
    FDrawingBoardMouseHold: Boolean;

    FOnDrawComponentOnPanel: TOnDrawComponentOnPanel;
    FOnAddItemToSelCompListInOI: TOnAddItemToSelCompListInOI;
    FOnCancelObjectInspectorEditing: TOnCancelObjectInspectorEditing;
    FOnClearObjectInspector: TOnClearObjectInspector;
    FOnDrawingBoardModified: TOnDrawingBoardModified;
    FOnRefreshObjectInspector: TOnRefreshObjectInspector;
    FOnGetDefaultScreenColor: TOnGetDefaultScreenColor;
    FOnLookupColorConstantInBaseSchema: TOnLookupColorConstantInBaseSchema;
    FOnBeforeSelectAllPanels: TOnSelectAllPanels;
    FOnAfterSelectAllPanels: TOnSelectAllPanels;
    FOnDeleteComponentByPanel: TOnDeleteComponentByPanel;
    FOnGetComponentIndexFromPlugin: TOnGetComponentIndexFromPlugin;
    FOnUpdateSpecialProperty: TOnUpdateSpecialProperty;
    FOnAddNewHandlerToAllHandlersByHandlerType: TOnAddNewHandlerToAllHandlersByHandlerType;
    FOnEditScreen: TOnEditScreen;
    FOnDrawingBoardMouseMove: TOnDrawingBoardMouseMove;
    FOnDrawingBoardCanFocus: TOnDrawingBoardCanFocus;
    FOnDisplayScreenSize: TOnDisplayScreenSize;
    FOnDrawingBoardRemoveFocus: TOnDrawingBoardRemoveFocus;
    FOnSetCustomPropertyValueOnLoading: TOnSetCustomPropertyValueOnLoading;
    FOnResolveColorConst: TOnResolveColorConst;
    FOnAfterMovingMountPanel: TOnAfterMovingMountPanel;

    vstScreens: TVirtualStringTree;

    procedure SetModified(Value: Boolean);

    function GetAllComponentsLength: Integer;
    procedure SetAllComponentsLength(ANewLength: Integer);

    function GetAllScreensLength: Integer;
    function GetDrawingBoardFocused: Boolean;
    procedure SetDrawingBoardFocused(Value: Boolean);

    function GetAllComponents: PDynTFTDesignAllComponentsArr;
    function GetAllVisualComponents: PProjectVisualComponentArr;
    function GetAllScreens: PScreenInfoArr;

    procedure DoOnDrawComponentOnPanel(APanel: TMountPanel; var AAllComponents: TDynTFTDesignAllComponentsArr; var AAllVisualComponents: TProjectVisualComponentArr);
    procedure DoOnAddItemToSelCompListInOI(ACompName: string);
    procedure DoOnCancelObjectInspectorEditing;
    procedure DoOnClearObjectInspector;
    procedure DoOnDrawingBoardModified;
    procedure DoOnRefreshObjectInspector;
    procedure DoOnGetDefaultScreenColor(var AColor: TColor; var AColorName: string);
    function DoOnLookupColorConstantInBaseSchema(ConstName: string; DefaultValue: TColor): TColor;
    procedure DoOnBeforeSelectAllPanels(AMsg, AHint: string);
    procedure DoOnAfterSelectAllPanels(AMsg, AHint: string);
    procedure DoOnDeleteComponentByPanel(APanel: TMountPanel);
    procedure DoOnGetComponentIndexFromPlugin(ACompTypeIndex: Integer; var ACategoryIndex, AComponentIndex: Integer);
    procedure DoOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);
    procedure DoOnAddNewHandlerToAllHandlersByHandlerType(ATypeName, AHandlerName: string);
    function DoOnEditScreen(var AScreen: TScreenInfo): Boolean;
    procedure DoOnDrawingBoardMouseMove(X, Y: Integer);
    function DoOnDrawingBoardCanFocus: Boolean;
    procedure DoOnDisplayScreenSize(AWidth, AHeight: Integer);
    procedure DoOnDrawingBoardRemoveFocus;
    procedure DoOnSetCustomPropertyValueOnLoading(APropertyName: string; ACompType: Integer; var APropertyValue: string);
    function DoOnResolveColorConst(AColorName: string): TColor;
    procedure DoOnAfterMovingMountPanel(APanel: TMountPanel);

    procedure SetHandlersToCornerLabels(ALabel: TLabel);
    function CreateBasePanel(AParent: TWinControl; X, Y: Integer; DynTFTComponentTypeIndex: Integer; ShowPanelName, ShowEditCorners: Boolean; CornerColor: TColor; IdxInTProjectVisualComponentArr, APluginIndex, AComponentIndexInPlugin: Integer; AUserData: Pointer = nil): TMountPanel;
    function GetMaxNumberForComponentName(ComponentTypeIndex: Integer): Integer;

    procedure SetPanelGeneralHint(APanel: TMountPanel; Locked: Boolean = False);
    procedure SetScreenEdgesHint;

    procedure GenericPanelDblClick(Sender: TObject);
    procedure GenericPanelClick(Sender: TObject);
    procedure GenericPanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GenericPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GenericPanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GenericPanelResize(Sender: TObject);

    procedure GenericPanelImageDblClick(Sender: TObject);
    procedure GenericPanelImageClick(Sender: TObject);
    procedure GenericPanelImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GenericPanelImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GenericPanelImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure GenericCornerLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GenericCornerLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GenericCornerLabelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure AddNewScreen;

    function GetActiveAndPersistedImageIndex(AScreen: TScreenInfo): Integer;

    procedure EnableDisableActiveItemsInScreenMenu(AMenuItem: TMenuItem);

    procedure SearchForScreen;
    procedure SearchForScreenAllControlsOnKeyDown(Key: Word);

    procedure DeleteComponentByPanel(APanel: TMountPanel);

    procedure UpdateSelectionRectangleSttxt(X, Y: Integer);

    procedure LockScreenEdges;
    procedure UnlockScreenEdges;
    procedure AdjustVisibleCompUnSelLimits(ACurrentPanel: TMountPanel);

    function GetOwnerFormFocus: Boolean;
    procedure SetImageIndexToActivePage;

    procedure LoadDrawingBoardFromFile(Ini: TMemIniFile; var ComponentsDest: TDynTFTDesignAllComponentsArr; var AllVisualComponentsDest: TProjectVisualComponentArr; var ScreensDest: TScreenInfoArr; var IndexInSchemaArr: TIntegerDynArray; var tk1, tk2, tk3, tk4: Int64);
    procedure SaveDrawingBoardContent(AStringList: TSaveFileStringList; var ComponentsSrc: TDynTFTDesignAllComponentsArr; var AllVisualComponentsSrc: TProjectVisualComponentArr; var ScreensSrc: TScreenInfoArr);

    procedure CreateRemainingComponents;
    procedure HandleOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);

    property PanelHold: Boolean read FPanelHold write FPanelHold;
    property SttxtHold: Boolean read FSttxtHold write FSttxtHold;
    property CornerHold: Boolean read FCornerHold write FCornerHold;

    property Modified: Boolean write SetModified;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    function GetComponentSchemaByIndex(ACompIndex: Integer): PComponentSchema; //The result is valid until the next reallocation of FAllComponents array, i.e. by setting AllComponentsLength. It is used to load the component schemas.
    procedure HideAlignmentGuideLines;
    procedure DisplayAlignmentGuideLines;

    procedure PopulateScreenMenu(ScreenMenuItem: TMenuItem);
    procedure UpdateComponentPopupMenu(MenuItems: TMenuItem);
    procedure ClearSelection;
    procedure HideSearchForScreenPanel;
    procedure ClearDrawingBoard;
    procedure BringRedLimitsToFront;
    procedure HandleMouseWheel(RawWheelDelta: Integer; SwapPages: Boolean);
    procedure UpdateIdexesInVisualStructureAtSave;

    procedure DrawComponentOnPanelOnDemand(APanel: TMountPanel);
    procedure RepaintAllComponents;
    function GetScreenNameByIndex(AIndex: Integer): string;
    procedure UpdateComponentUsageByProperty(const ASearchedPropertyUpperCaseName: string; var AAllPropertyGroups: TPropertyGroupArr);
    procedure UpdateAllComponentsToNewPropertyValue(const ASearchedPropertyUpperCaseName: string; OldValue, NewValue: string);
    procedure SelectSinglePanel(APanel: TMountPanel);
    procedure PopulateItemsWithConstantsByPropertyName(Items: TStrings; PropertyName, SpacePrefix: string);
    function AddComponentToDrawingBoard(ComponentTypeIndex, X, Y, APluginIndex, AComponentIndexInPlugin: Integer; AParentComponent: TWinControl = nil; AUserData: Pointer = nil): TMountPanel;
    procedure SelectAllPanelsThenUpdateObjectInspector(SelectFromAllScreens: Boolean);
    procedure DeleteAllSelectedPanelsThenUpdateSelection;
    procedure GenerateListOfVisibleComponents;
    function ComponentIsLocked(APanel: TMountPanel): Boolean;

    procedure CutSelectionToClipboard;
    procedure CopySelectionToClipboard;
    procedure PasteSelectionFromClipboard;
    
    procedure UpdateComponentsWithPropertyValue(ObjectInspectorType: Integer; IndexInSel: Integer; NewValue: string);
    procedure SetGeneralHintToSelectedPanels;
    procedure UpdateComponentLeftAndTopFromAPanel(APanel: TMountPanel);

    function GetComponentsLengthOfOneKind(ACompType: Integer): Integer;

    function GetVisualComponentsLength: Integer;
    function GetVisualComponentByIndex(AIndex: Integer): TProjectVisualComponent;
    function GetPropertiesArrayByIndex(AComponentType, AVisualComponentIndex: Integer): TDynTFTDesignPropertyArr;
    function GetObjectNamePropertyByIndex(AComponentType, AVisualComponentIndex: Integer): string;

    function GetScreenByIndex(AIndex: Integer): TScreenInfo;
    function GetActiveScreenIndex: Integer;
    procedure SwitchScreenByIndex(AIndex: Integer);

    procedure SetDisplayedPanelProperties(APanel: TMountPanel);
    procedure UpdateDisplayedPanelProperties(APanel: TMountPanel);
    procedure ChagePageControlHandler;
    function GetPropertyValueFromPropertiesByNameAndPanel(APropertyName: string; APanel: TMountPanel): string;

    function GetDrawingBoardScreenLeft: Integer;
    function GetDrawingBoardScreenTop: Integer;
    function GetDrawingBoardScreenWidth: Integer;
    function GetDrawingBoardScreenHeight: Integer;
    function GetDrawingBoardScreenHScrBarPos: Integer;
    function GetDrawingBoardScreenVScrBarPos: Integer;

    procedure ShowBorder;
    procedure HideBorder;
    procedure SetPanelFocus(APanel: TMountPanel; ShifState: TShiftState);
    procedure AddPanelToSelected(APanel: TMountPanel);
    function AtLeastOneSelectedPanelExists: Boolean;

    procedure ResetCurrentSelectionRectangle;
    procedure SetCurrentSelectionRectangleByPanel(APanel: TMountPanel);

    procedure BringPanelToFront(APanel: TMountPanel);
    procedure SendPanelToBack(APanel: TMountPanel);

    function IsDraggingBothScreenEdges: Boolean;  //returns True if both edges are being dragged (using the red intersection rectangle)
    procedure RecolorScreensAndComponentsByTheme;

    procedure LoadDrawingBoardFromIniFile(AIni: TMemIniFile; var IndexInSchemaArr: TIntegerDynArray; var tk1, tk2, tk3, tk4: Int64);
    procedure SaveDrawingBoardToFile(AStringList: TSaveFileStringList);

    property MinPxToUnlockDrag: Integer write FMinPxToUnlockDrag;
    property ShouldFocusDrawingBoardOnMouseEnter: Boolean write FShouldFocusDrawingBoardOnMouseEnter;
    property DrawingBoardFocused: Boolean read GetDrawingBoardFocused write SetDrawingBoardFocused;

    property AllComponentsLength: Integer read GetAllComponentsLength write SetAllComponentsLength;
    property AllScreensLength: Integer read GetAllScreensLength;
    property SelectionContent: TSelectionContent read FSelectionContent;

    property AllComponents: PDynTFTDesignAllComponentsArr read GetAllComponents;          //fast and ugly way of making the structure available
    property AllVisualComponents: PProjectVisualComponentArr read GetAllVisualComponents; //fast and ugly way of making the structure available
    property AllScreens: PScreenInfoArr read GetAllScreens;                               //fast and ugly way of making the structure available

    property OnDrawComponentOnPanel: TOnDrawComponentOnPanel write FOnDrawComponentOnPanel;
    property OnAddItemToSelCompListInOI: TOnAddItemToSelCompListInOI write FOnAddItemToSelCompListInOI;
    property OnCancelObjectInspectorEditing: TOnCancelObjectInspectorEditing write FOnCancelObjectInspectorEditing;
    property OnClearObjectInspector: TOnClearObjectInspector write FOnClearObjectInspector;
    property OnDrawingBoardModified: TOnDrawingBoardModified write FOnDrawingBoardModified;
    property OnRefreshObjectInspector: TOnRefreshObjectInspector write FOnRefreshObjectInspector;
    property OnGetDefaultScreenColor: TOnGetDefaultScreenColor write FOnGetDefaultScreenColor;
    property OnLookupColorConstantInBaseSchema: TOnLookupColorConstantInBaseSchema write FOnLookupColorConstantInBaseSchema;
    property OnBeforeSelectAllPanels: TOnSelectAllPanels write FOnBeforeSelectAllPanels;
    property OnAfterSelectAllPanels: TOnSelectAllPanels write FOnAfterSelectAllPanels;
    property OnDeleteComponentByPanel: TOnDeleteComponentByPanel write FOnDeleteComponentByPanel;
    property OnGetComponentIndexFromPlugin: TOnGetComponentIndexFromPlugin write FOnGetComponentIndexFromPlugin;
    property OnUpdateSpecialProperty: TOnUpdateSpecialProperty write FOnUpdateSpecialProperty;
    property OnAddNewHandlerToAllHandlersByHandlerType: TOnAddNewHandlerToAllHandlersByHandlerType write FOnAddNewHandlerToAllHandlersByHandlerType;
    property OnEditScreen: TOnEditScreen write FOnEditScreen;
    property OnDrawingBoardMouseMove: TOnDrawingBoardMouseMove write FOnDrawingBoardMouseMove;
    property OnDrawingBoardCanFocus: TOnDrawingBoardCanFocus write FOnDrawingBoardCanFocus;
    property OnDisplayScreenSize: TOnDisplayScreenSize write FOnDisplayScreenSize;
    property OnDrawingBoardRemoveFocus: TOnDrawingBoardRemoveFocus write FOnDrawingBoardRemoveFocus;
    property OnSetCustomPropertyValueOnLoading: TOnSetCustomPropertyValueOnLoading write FOnSetCustomPropertyValueOnLoading;
    property OnResolveColorConst: TOnResolveColorConst write FOnResolveColorConst;
    property OnAfterMovingMountPanel: TOnAfterMovingMountPanel write FOnAfterMovingMountPanel;
  end;


const
  CMaxComponentLeftAndTop = 65535;  


implementation

{$IFDEF FPC}
  {$R *.frm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}  

uses
  Math, ClipBrd
  {DUIIStandardDialogWrapper}
  , DynTFTSharedUtils
  ;


const
  CMaxScreenCount = 255;


function MessageBoxWrapper(hWnd: Cardinal; lpText, lpCaption: PChar; uType: Cardinal): Integer;
begin
  {$IFDEF TestBuild}
    Result := DUIIFakeMessageBox(hWnd, lpText, lpCaption, uType);
  {$ELSE}
    Result := MessageBox(hWnd, lpText, lpCaption, uType);
  {$ENDIF}
end;


procedure TfrDrawingBoard.CreateRemainingComponents;
var
  NewColum: TVirtualTreeColumn;
begin
  vstScreens := TVirtualStringTree.Create(Self);
  vstScreens.Parent := pnlSearchForScreen;

  vstScreens.Left := 8;
  vstScreens.Top := 12;
  vstScreens.Width := 265;
  vstScreens.Height := 189;
  vstScreens.Hint := 'Double-click, to go to selected screen.';
  vstScreens.Anchors := [akLeft, akTop, akRight, akBottom];
  vstScreens.Header.AutoSizeIndex := 0;
  vstScreens.Header.DefaultHeight := 17;
  vstScreens.Header.Font.Charset := DEFAULT_CHARSET;
  vstScreens.Header.Font.Color := clWindowText;
  vstScreens.Header.Font.Height := -11;
  vstScreens.Header.Font.Name := 'Tahoma';
  vstScreens.Header.Font.Style := [];
  vstScreens.Header.Height := 25;
  vstScreens.Header.Options := [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible];
  vstScreens.Header.Style := hsFlatButtons;
  vstScreens.ParentShowHint := False;
  vstScreens.ShowHint := True;
  vstScreens.StateImages := imglstScreens;
  vstScreens.TabOrder := 0;
  vstScreens.TreeOptions.PaintOptions := [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages];
  vstScreens.TreeOptions.SelectionOptions := [toFullRowSelect, toMiddleClickSelect, toRightClickSelect];
  vstScreens.OnDblClick := {$IFDEF FPC}@{$ENDIF}vstScreensDblClick;
  vstScreens.OnGetText := {$IFDEF FPC}@{$ENDIF}vstScreensGetText;
  vstScreens.OnGetImageIndex := {$IFDEF FPC}@{$ENDIF}vstScreensGetImageIndex;
  vstScreens.OnKeyDown := {$IFDEF FPC}@{$ENDIF}vstScreensKeyDown;
  vstScreens.Colors.UnfocusedSelectionColor := clGradientInactiveCaption;

  NewColum := vstScreens.Header.Columns.Add;
  NewColum.MinWidth := 115;
  NewColum.Position := 0;
  NewColum.Width := 115;
  NewColum.Text := 'Screen Number';

  NewColum := vstScreens.Header.Columns.Add;
  NewColum.MinWidth := 140;
  NewColum.Position := 1;
  NewColum.Width := 140;
  NewColum.Text := 'Screen Name';
end;


constructor TfrDrawingBoard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  SetLength(FAllComponents, 0);
  SetLength(FAllVisualComponents, 0);
  SetLength(FVisibleComponents, 0);

  SetLength(FAllScreens, 1); //at least one screen has to exist
  FAllScreens[0].Active := True;
  FAllScreens[0].Persisted := False;
  FAllScreens[0].Color := clWhite; // can't resolve constant by BaseSchema here, because it is not loaded at this point
  FAllScreens[0].ColorName := 'CL_DynTFTScreen_Background';
  FAllScreens[0].Name := 'Screen';

  FMinPxToUnlockDrag := 5;
  FPageMouseIn := False;
  FDrawingBoardMouseHold := False;
  FShouldFocusDrawingBoardOnMouseEnter := True;

  FPasteX := 0;
  FPasteY := 0;

  FPanelHold := False;
  FDragLocked := False;
  FSttxtHold := False;
  FCornerHold := False;
  FPanelDoubleClick := False;

  FSelectionContent := TSelectionContent.Create(Self);
  FSelectionContent.OnUpdateSpecialProperty := {$IFDEF FPC}@{$ENDIF}HandleOnUpdateSpecialProperty;

  sttxtMatchTop.Height := 1;
  sttxtMatchBottom.Height := 1;
  sttxtMatchLeft.Width := 1;
  sttxtMatchRight.Width := 1;

  FOnDrawComponentOnPanel := nil;
  FOnAddItemToSelCompListInOI := nil;
  FOnCancelObjectInspectorEditing := nil;
  FOnClearObjectInspector := nil;
  FOnDrawingBoardModified := nil;
  FOnRefreshObjectInspector := nil;
  FOnGetDefaultScreenColor := nil;
  FOnLookupColorConstantInBaseSchema := nil;
  FOnBeforeSelectAllPanels := nil;
  FOnAfterSelectAllPanels := nil;
  FOnDeleteComponentByPanel := nil;
  FOnGetComponentIndexFromPlugin := nil;
  FOnUpdateSpecialProperty := nil;
  FOnEditScreen := nil;
  FOnDrawingBoardCanFocus := nil;
  FOnDisplayScreenSize := nil;
  FOnDrawingBoardRemoveFocus := nil;
  FOnSetCustomPropertyValueOnLoading := nil;
  FOnResolveColorConst := nil;
  FOnAfterMovingMountPanel := nil;

  CreateRemainingComponents;

  SetScreenEdgesHint;

  PageControlScreen.Hint := 'Right-click for menu.'#13#10'Ctrl-Wheel to swap screens.';
  lbeScreenName.Hint := 'Type to search.'#13#10'Press Enter to go to selected screen and close.'#13#10'Press Escape to close.';
  lbeScreenNumber.Hint := lbeScreenName.Hint;
end;


destructor TfrDrawingBoard.Destroy;
var
  i, j, IdxI, IdxJ: Integer;
begin
  FSelectionContent.Free;

  IdxI := -1;
  IdxJ := -1;
  try
    for i := 0 to Length(FAllComponents) - 1 do
    begin
      IdxI := i;
      SetLength(FAllComponents[i].Schema.Properties, 0);
      SetLength(FAllComponents[i].Schema.Events, 0);
      SetLength(FAllComponents[i].Schema.Constants, 0);
      SetLength(FAllComponents[i].Schema.ColorConstants, 0);
      SetLength(FAllComponents[i].Schema.ComponentDependencies, 0);

      for j := 0 to Length(FAllComponents[i].DesignComponentsOneKind) - 1 do
      begin
        IdxJ := j;
        SetLength(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties, 0);   //CustomProperties can be corrupted  by editing Items/Strings property of components (Items, ListBox, RadioGroup, PageControl)
        SetLength(FAllComponents[i].DesignComponentsOneKind[j].CustomEvents, 0);
      end;

      SetLength(FAllComponents[i].DesignComponentsOneKind, 0);
    end;
  except
    on E: Exception do
      MessageBoxWrapper(0, PChar('Ex on app cleanup: ' + E.Message + '"  on index ' + IntToStr(IdxI) + ':' + IntToStr(IdxJ)), 'DrawingBoard', MB_ICONERROR);
  end;

  SetLength(FAllComponents, 0);
  SetLength(FAllVisualComponents, 0);

  SetLength(FAllScreens, 0);
  SetLength(FVisibleComponents, 0);
  
  inherited Destroy;
end;


function TfrDrawingBoard.GetComponentSchemaByIndex(ACompIndex: Integer): PComponentSchema;
begin
  Result := @FAllComponents[ACompIndex].Schema;
end;


procedure TfrDrawingBoard.SetModified(Value: Boolean);
begin
  DoOnDrawingBoardModified;
end;


function TfrDrawingBoard.GetAllComponentsLength: Integer;
begin
  Result := Length(FAllComponents);
end;


procedure TfrDrawingBoard.SetAllComponentsLength(ANewLength: Integer);
begin
  if Length(FAllComponents) <> ANewLength then
    SetLength(FAllComponents, ANewLength);
end;


function TfrDrawingBoard.GetAllScreensLength: Integer;
begin
  Result := Length(FAllScreens);
end;


function TfrDrawingBoard.GetDrawingBoardFocused: Boolean;
begin
  Result := scrboxScreen.Focused;
end;


procedure TfrDrawingBoard.SetDrawingBoardFocused(Value: Boolean);
begin
  if Value then
    scrboxScreen.SetFocus
  else
    PageControlScreen.SetFocus;    
end;


function TfrDrawingBoard.GetAllComponents: PDynTFTDesignAllComponentsArr;
begin
  Result := @FAllComponents;
end;


function TfrDrawingBoard.GetAllVisualComponents: PProjectVisualComponentArr;
begin
  Result := @FAllVisualComponents;
end;


function TfrDrawingBoard.GetAllScreens: PScreenInfoArr;
begin
  Result := @FAllScreens;
end;


procedure TfrDrawingBoard.DoOnDrawComponentOnPanel(APanel: TMountPanel; var AAllComponents: TDynTFTDesignAllComponentsArr; var AAllVisualComponents: TProjectVisualComponentArr);
begin
  if not Assigned(FOnDrawComponentOnPanel) then
    raise Exception.Create('OnDrawComponentOnPanel not assigned.');

  FOnDrawComponentOnPanel(APanel, AAllComponents, AAllVisualComponents);
end;


procedure TfrDrawingBoard.DoOnAddItemToSelCompListInOI(ACompName: string);
begin
  if not Assigned(FOnAddItemToSelCompListInOI) then
    raise Exception.Create('OnAddItemToSelCompListInOI not assigned.');

  FOnAddItemToSelCompListInOI(ACompName);
end;


procedure TfrDrawingBoard.DoOnCancelObjectInspectorEditing;
begin
  if not Assigned(FOnCancelObjectInspectorEditing) then
    raise Exception.Create('OnCancelObjectInspectorEditing not assigned.');

  FOnCancelObjectInspectorEditing;
end;


procedure TfrDrawingBoard.DoOnClearObjectInspector;
begin
  if not Assigned(FOnClearObjectInspector) then
    raise Exception.Create('OnClearObjectInspector not assigned.');

  FOnClearObjectInspector;
end;


procedure TfrDrawingBoard.DoOnDrawingBoardModified;
begin
  if not Assigned(FOnDrawingBoardModified) then
    raise Exception.Create('OnDrawingBoardModified not assigned.');

  FOnDrawingBoardModified;
end;


procedure TfrDrawingBoard.DoOnRefreshObjectInspector;
begin
  if not Assigned(FOnRefreshObjectInspector) then
    raise Exception.Create('OnRefreshObjectInspector not assigned.');

  FOnRefreshObjectInspector;
end;


procedure TfrDrawingBoard.DoOnGetDefaultScreenColor(var AColor: TColor; var AColorName: string);
begin
  if not Assigned(FOnGetDefaultScreenColor) then
    raise Exception.Create('OnGetDefaultScreenColor not assigned.');

  FOnGetDefaultScreenColor(AColor, AColorName);
end;


function TfrDrawingBoard.DoOnLookupColorConstantInBaseSchema(ConstName: string; DefaultValue: TColor): TColor;
begin
  if not Assigned(FOnLookupColorConstantInBaseSchema) then
    raise Exception.Create('OnLookupColorConstantInBaseSchema not assigned.');

  Result := FOnLookupColorConstantInBaseSchema(ConstName, DefaultValue);
end;


procedure TfrDrawingBoard.DoOnBeforeSelectAllPanels(AMsg, AHint: string);
begin
  if not Assigned(FOnBeforeSelectAllPanels) then
    raise Exception.Create('OnBeforeSelectAllPanels not assigned.');

  FOnBeforeSelectAllPanels(AMsg, AHint);
end;


procedure TfrDrawingBoard.DoOnAfterSelectAllPanels(AMsg, AHint: string);
begin
  if not Assigned(FOnAfterSelectAllPanels) then
    raise Exception.Create('OnAfterSelectAllPanels not assigned.');

  FOnAfterSelectAllPanels(AMsg, AHint);
end;


procedure TfrDrawingBoard.DoOnDeleteComponentByPanel(APanel: TMountPanel);
begin
  if not Assigned(FOnDeleteComponentByPanel) then
    raise Exception.Create('OnDeleteComponentByPanel not assigned.');

  FOnDeleteComponentByPanel(APanel);
end;


procedure TfrDrawingBoard.DoOnGetComponentIndexFromPlugin(ACompTypeIndex: Integer; var ACategoryIndex, AComponentIndex: Integer);
begin
  if not Assigned(FOnGetComponentIndexFromPlugin) then
    raise Exception.Create('OnGetComponentIndexFromPlugin not assigned.');

  FOnGetComponentIndexFromPlugin(ACompTypeIndex, ACategoryIndex, AComponentIndex);
end;


procedure TfrDrawingBoard.DoOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);
begin
  if not Assigned(FOnUpdateSpecialProperty) then
    raise Exception.Create('OnUpdateSpecialProperty not assigned.');

  FOnUpdateSpecialProperty(APropertyIndex, ADesignComponentInAll, APropertyName, APropertyNewValue);
end;


procedure TfrDrawingBoard.DoOnAddNewHandlerToAllHandlersByHandlerType(ATypeName, AHandlerName: string);
begin
  if not Assigned(FOnAddNewHandlerToAllHandlersByHandlerType) then
    raise Exception.Create('OnAddNewHandlerToAllHandlersByHandlerType not assigned.');

  FOnAddNewHandlerToAllHandlersByHandlerType(ATypeName, AHandlerName);
end;


function TfrDrawingBoard.DoOnEditScreen(var AScreen: TScreenInfo): Boolean;
begin
  if not Assigned(FOnEditScreen) then
    raise Exception.Create('OnEditScreen not assigned.');

  Result := FOnEditScreen(AScreen);
end;


procedure TfrDrawingBoard.DoOnDrawingBoardMouseMove(X, Y: Integer);
begin
  if not Assigned(FOnDrawingBoardMouseMove) then
    raise Exception.Create('OnDrawingBoardMouseMove not assigned.');

  FOnDrawingBoardMouseMove(X, Y);
end;


function TfrDrawingBoard.DoOnDrawingBoardCanFocus: Boolean;
begin
  if not Assigned(FOnDrawingBoardCanFocus) then
    raise Exception.Create('OnDrawingBoardCanFocus not assigned.');

  Result := FOnDrawingBoardCanFocus();
end;


procedure TfrDrawingBoard.DoOnDisplayScreenSize(AWidth, AHeight: Integer);
begin
  if not Assigned(FOnDisplayScreenSize) then
    raise Exception.Create('OnDisplayScreenSize not assigned.');

  FOnDisplayScreenSize(AWidth, AHeight);
end;


procedure TfrDrawingBoard.DoOnDrawingBoardRemoveFocus;
begin
  if not Assigned(FOnDrawingBoardRemoveFocus) then
    raise Exception.Create('OnDrawingBoardRemoveFocus not assigned.');

  FOnDrawingBoardRemoveFocus;
end;


procedure TfrDrawingBoard.DoOnSetCustomPropertyValueOnLoading(APropertyName: string; ACompType: Integer; var APropertyValue: string);
begin
  if not Assigned(FOnSetCustomPropertyValueOnLoading) then
    raise Exception.Create('OnSetCustomPropertyValueOnLoading not assigned.');

  FOnSetCustomPropertyValueOnLoading(APropertyName, ACompType, APropertyValue);
end;


function TfrDrawingBoard.DoOnResolveColorConst(AColorName: string): TColor;
begin
  if not Assigned(FOnResolveColorConst) then
    raise Exception.Create('OnResolveColorConst not assigned.');

  Result := FOnResolveColorConst(AColorName);
end;


procedure TfrDrawingBoard.DoOnAfterMovingMountPanel(APanel: TMountPanel);
begin
  if Assigned(FOnAfterMovingMountPanel) then
    FOnAfterMovingMountPanel(APanel);
end;


procedure TfrDrawingBoard.SetHandlersToCornerLabels(ALabel: TLabel);
begin
  ALabel.OnMouseDown := {$IFDEF FPC}@{$ENDIF}GenericCornerLabelMouseDown;
  ALabel.OnMouseMove := {$IFDEF FPC}@{$ENDIF}GenericCornerLabelMouseMove;
  ALabel.OnMouseUp := {$IFDEF FPC}@{$ENDIF}GenericCornerLabelMouseUp;
end;


function TfrDrawingBoard.CreateBasePanel(AParent: TWinControl; X, Y: Integer; DynTFTComponentTypeIndex: Integer; ShowPanelName, ShowEditCorners: Boolean; CornerColor: TColor; IdxInTProjectVisualComponentArr, APluginIndex, AComponentIndexInPlugin: Integer; AUserData: Pointer = nil): TMountPanel;
var
  APanel: TMountPanel;                        
begin
  APanel := TMountPanel.CreateParented(AParent.Handle);
  APanel.Parent := AParent;
  APanel.Visible := False;
  APanel.Left := X;
  APanel.Top := Y;
  APanel.Width := 30;
  APanel.Height := 30;
  APanel.OnMouseDown := {$IFDEF FPC}@{$ENDIF}GenericPanelMouseDown;
  APanel.OnMouseMove := {$IFDEF FPC}@{$ENDIF}GenericPanelMouseMove;
  APanel.OnMouseUp := {$IFDEF FPC}@{$ENDIF}GenericPanelMouseUp;
  APanel.OnClick := {$IFDEF FPC}@{$ENDIF}GenericPanelClick;
  APanel.OnDblClick := {$IFDEF FPC}@{$ENDIF}GenericPanelDblClick;
  APanel.Constraints.MinHeight := 2;
  APanel.Constraints.MinWidth := 2;
  APanel.DynTFTComponentType := DynTFTComponentTypeIndex;
  APanel.IndexInTProjectVisualComponentArr := IdxInTProjectVisualComponentArr;
  pnlScroll.InsertComponent(APanel);
  APanel.OnResize := {$IFDEF FPC}@{$ENDIF}GenericPanelResize;

  APanel.PluginIndex := APluginIndex;
  APanel.ComponentIndexInPlugin := AComponentIndexInPlugin;
  APanel.UserData := AUserData;

  APanel.Image := TImage.Create(APanel);
  APanel.Image.Parent := APanel;
  APanel.Image.AutoSize := False;
  APanel.Image.Top := 0;
  APanel.Image.Left := 0;
  APanel.Image.Width := APanel.Width;
  APanel.Image.Height := APanel.Height;
  APanel.Image.Anchors := [akLeft, akTop, akRight, akBottom];
  APanel.Image.Picture.Bitmap := TBitmap.Create;
  APanel.Image.Picture.Bitmap.Width := APanel.Image.Width;
  APanel.Image.Picture.Bitmap.Height := APanel.Image.Height;
  APanel.Image.OnMouseDown := {$IFDEF FPC}@{$ENDIF}GenericPanelImageMouseDown;
  APanel.Image.OnMouseMove := {$IFDEF FPC}@{$ENDIF}GenericPanelImageMouseMove;
  APanel.Image.OnMouseUp := {$IFDEF FPC}@{$ENDIF}GenericPanelImageMouseUp;
  APanel.Image.OnClick := {$IFDEF FPC}@{$ENDIF}GenericPanelImageClick;
  APanel.Image.OnDblClick := {$IFDEF FPC}@{$ENDIF}GenericPanelImageDblClick;
  APanel.InsertComponent(APanel.Image);

  try
    DoOnDrawComponentOnPanel(APanel, FAllComponents, FAllVisualComponents);
  except
    on E: Exception do
    begin
      APanel.Width := 300;
      APanel.Image.Width := APanel.Width;
      APanel.Image.Canvas.TextOut(0, 0, 'Drawing exception: ');
      APanel.Image.Canvas.TextOut(0, 15, E.Message);
    end;
  end;

  APanel.TopLeftLabel := TLabel.Create(APanel);
  APanel.TopLeftLabel.Parent := APanel;
  APanel.TopLeftLabel.AutoSize := False;
  APanel.TopLeftLabel.Caption := '';
  APanel.TopLeftLabel.Top := 0;
  APanel.TopLeftLabel.Left := 0;
  APanel.TopLeftLabel.Width := 5;
  APanel.TopLeftLabel.Height := 5;
  APanel.TopLeftLabel.Color := CornerColor;
  APanel.TopLeftLabel.Transparent := False;
  APanel.TopLeftLabel.Tag := 20;
  APanel.TopLeftLabel.Visible := False;
  APanel.TopLeftLabel.Cursor := crSizeNWSE;
  SetHandlersToCornerLabels(APanel.TopLeftLabel);
  APanel.TopLeftLabel.Anchors := [akLeft, akTop];
  APanel.Parent.InsertComponent(APanel.TopLeftLabel);

  APanel.TopRightLabel := TLabel.Create(APanel);
  APanel.TopRightLabel.Parent := APanel;
  APanel.TopRightLabel.AutoSize := False;
  APanel.TopRightLabel.Caption := '';
  APanel.TopRightLabel.Top := 0;
  APanel.TopRightLabel.Left := APanel.Width - 5;
  APanel.TopRightLabel.Width := 5;
  APanel.TopRightLabel.Height := 5;
  APanel.TopRightLabel.Color := CornerColor;
  APanel.TopRightLabel.Transparent := False;
  APanel.TopRightLabel.Tag := 21;
  APanel.TopRightLabel.Visible := False;
  APanel.TopRightLabel.Cursor := crSizeNESW;
  SetHandlersToCornerLabels(APanel.TopRightLabel);
  APanel.TopRightLabel.Anchors := [akRight, akTop];
  APanel.InsertComponent(APanel.TopRightLabel);

  APanel.BotLeftLabel := TLabel.Create(APanel);
  APanel.BotLeftLabel.Parent := APanel;
  APanel.BotLeftLabel.AutoSize := False;
  APanel.BotLeftLabel.Caption := '';
  APanel.BotLeftLabel.Top := APanel.Height - 5;
  APanel.BotLeftLabel.Left := 0;
  APanel.BotLeftLabel.Width := 5;
  APanel.BotLeftLabel.Height := 5;
  APanel.BotLeftLabel.Color := CornerColor;
  APanel.BotLeftLabel.Transparent := False;
  APanel.BotLeftLabel.Tag := 22;
  APanel.BotLeftLabel.Visible := False;
  APanel.BotLeftLabel.Cursor := crSizeNESW;
  SetHandlersToCornerLabels(APanel.BotLeftLabel);
  APanel.BotLeftLabel.Anchors := [akLeft, akBottom];
  APanel.InsertComponent(APanel.BotLeftLabel);

  APanel.BotRightLabel := TLabel.Create(APanel);
  APanel.BotRightLabel.Parent := APanel;
  APanel.BotRightLabel.AutoSize := False;
  APanel.BotRightLabel.Caption := '';
  APanel.BotRightLabel.Top := APanel.Height - 5;
  APanel.BotRightLabel.Left := APanel.Width - 5;
  APanel.BotRightLabel.Width := 5;
  APanel.BotRightLabel.Height := 5;
  APanel.BotRightLabel.Color := CornerColor;
  APanel.BotRightLabel.Transparent := False;
  APanel.BotRightLabel.Tag := 23;
  APanel.BotRightLabel.Visible := False;
  APanel.BotRightLabel.Cursor := crSizeNWSE;
  SetHandlersToCornerLabels(APanel.BotRightLabel);
  APanel.BotRightLabel.Anchors := [akRight, akBottom];
  APanel.InsertComponent(APanel.BotRightLabel);

  APanel.LeftLabel := TLabel.Create(APanel);
  APanel.LeftLabel.Parent := APanel;
  APanel.LeftLabel.AutoSize := False;
  APanel.LeftLabel.Caption := '';
  APanel.LeftLabel.Top := APanel.Height shr 1 - 2; // - 2.5
  APanel.LeftLabel.Left := 0;
  APanel.LeftLabel.Width := 5;
  APanel.LeftLabel.Height := 5;
  APanel.LeftLabel.Color := CornerColor;
  APanel.LeftLabel.Transparent := False;
  APanel.LeftLabel.Tag := 24;
  APanel.LeftLabel.Visible := False;
  APanel.LeftLabel.Cursor := crSizeWE;
  SetHandlersToCornerLabels(APanel.LeftLabel);
  APanel.LeftLabel.Anchors := [akLeft{, akTop}];
  APanel.Parent.InsertComponent(APanel.LeftLabel);

  APanel.TopLabel := TLabel.Create(APanel);
  APanel.TopLabel.Parent := APanel;
  APanel.TopLabel.AutoSize := False;
  APanel.TopLabel.Caption := '';
  APanel.TopLabel.Top := 0;
  APanel.TopLabel.Left := APanel.Width shr 1 - 2; // - 2.5
  APanel.TopLabel.Width := 5;
  APanel.TopLabel.Height := 5;
  APanel.TopLabel.Color := CornerColor;
  APanel.TopLabel.Transparent := False;
  APanel.TopLabel.Tag := 25;
  APanel.TopLabel.Visible := False;
  APanel.TopLabel.Cursor := crSizeNS;
  SetHandlersToCornerLabels(APanel.TopLabel);
  APanel.TopLabel.Anchors := [{akLeft,} akTop];
  APanel.Parent.InsertComponent(APanel.TopLabel);

  APanel.RightLabel := TLabel.Create(APanel);
  APanel.RightLabel.Parent := APanel;
  APanel.RightLabel.AutoSize := False;
  APanel.RightLabel.Caption := '';
  APanel.RightLabel.Top := APanel.Height shr 1 - 2;  // - 2.5
  APanel.RightLabel.Left := APanel.Width - 5;
  APanel.RightLabel.Width := 5;
  APanel.RightLabel.Height := 5;
  APanel.RightLabel.Color := CornerColor;
  APanel.RightLabel.Transparent := False;
  APanel.RightLabel.Tag := 26;
  APanel.RightLabel.Visible := False;
  APanel.RightLabel.Cursor := crSizeWE;
  SetHandlersToCornerLabels(APanel.RightLabel);
  APanel.RightLabel.Anchors := [akRight{, akBottom}];
  APanel.InsertComponent(APanel.RightLabel);

  APanel.BotLabel := TLabel.Create(APanel);
  APanel.BotLabel.Parent := APanel;
  APanel.BotLabel.AutoSize := False;
  APanel.BotLabel.Caption := '';
  APanel.BotLabel.Top := APanel.Height - 5;
  APanel.BotLabel.Left := APanel.Width shr 1 - 2;  // - 2.5
  APanel.BotLabel.Width := 5;
  APanel.BotLabel.Height := 5;
  APanel.BotLabel.Color := CornerColor;
  APanel.BotLabel.Transparent := False;
  APanel.BotLabel.Tag := 27;
  APanel.BotLabel.Visible := False;
  APanel.BotLabel.Cursor := crSizeNS;
  SetHandlersToCornerLabels(APanel.BotLabel);
  APanel.BotLabel.Anchors := [{akRight,} akBottom];
  APanel.InsertComponent(APanel.BotLabel);

  APanel.TopLeftLabel.Enabled := ShowEditCorners;
  APanel.TopRightLabel.Enabled := ShowEditCorners;
  APanel.BotLeftLabel.Enabled := ShowEditCorners;
  APanel.BotRightLabel.Enabled := ShowEditCorners;

  APanel.LeftLabel.Enabled := ShowEditCorners;
  APanel.TopLabel.Enabled := ShowEditCorners;
  APanel.RightLabel.Enabled := ShowEditCorners;
  APanel.BotLabel.Enabled := ShowEditCorners;

  APanel.Visible := True; //APanel.Show;
  Result := APanel;
end;


function TfrDrawingBoard.GetMaxNumberForComponentName(ComponentTypeIndex: Integer): Integer;
var
  i, j, Number, MaxNumber: Integer;
  NumberStr, s: string;
begin
  MaxNumber := -1;
  for i := 0 to Length(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind) - 1 do
  begin
    s := FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].ObjectName;
    Number := -1;
    if s <> '' then
      if (s[Length(s)] in ['0'..'9']) and (Pos(FAllComponents[ComponentTypeIndex].Schema.ComponentTypeName, s) = 1) then
      begin
        NumberStr := '';
        for j := Length(s) downto 1 do
          if s[j] in ['0'..'9'] then
            NumberStr := s[j] + NumberStr
          else
            Break;

        Number := StrToInt(NumberStr);    
      end;

    if Number > -1 then
      if MaxNumber < Number then
        MaxNumber := Number;
  end;

  Result := MaxNumber;
end;


function TfrDrawingBoard.AddComponentToDrawingBoard(ComponentTypeIndex, X, Y, APluginIndex, AComponentIndexInPlugin: Integer; AParentComponent: TWinControl = nil; AUserData: Pointer = nil): TMountPanel;
var
  vn, dn, NameSuffix, i: Integer;
  ComponentDefaultSize: TComponentDefaultSize;
begin
  if (ComponentTypeIndex < 0) or (ComponentTypeIndex > Length(FAllComponents) -1) then
    raise Exception.Create('Component type out of range. Make sure this component type is installed (this should come from plugin).');

  dn := Length(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind);
  SetLength(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind, dn + 1);

  NameSuffix := GetMaxNumberForComponentName(ComponentTypeIndex) + 1;
  FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].ObjectName := FAllComponents[ComponentTypeIndex].Schema.ComponentTypeName + IntToStr(NameSuffix);
  FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CreatedAtStartup := True;
  FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].HasVariableInGUIObjects := True;

  SetLength(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties, Length(FAllComponents[ComponentTypeIndex].Schema.Properties));
  SetLength(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomEvents, Length(FAllComponents[ComponentTypeIndex].Schema.Events));

  ComponentDefaultSize.MinWidth := 2;
  ComponentDefaultSize.MaxWidth := 0;
  ComponentDefaultSize.MinHeight := 2;
  ComponentDefaultSize.MaxHeight := 0;
  ComponentDefaultSize.Width := -1;
  ComponentDefaultSize.Height := -1;

  for i := 0 to Length(FAllComponents[ComponentTypeIndex].Schema.Properties) - 1 do
  begin
    FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyName := FAllComponents[ComponentTypeIndex].Schema.Properties[i].PropertyName;
    FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyValue := FAllComponents[ComponentTypeIndex].Schema.Properties[i].PropertyDefaultValue;

    GetComponentDefaultSize(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties, i, ComponentDefaultSize);
    AdjustComponentPosition(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties, i, X, Y);
    AdjustComponentScreenIndex(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties, i, PageControlScreen.ActivePageIndex);
    AdjustComponentName(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties, i, FAllComponents[ComponentTypeIndex].Schema.ComponentTypeName + IntToStr(NameSuffix));

    if FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyName = 'CreatedAtStartup' then
      FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CreatedAtStartup := UpperCase(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyValue) = 'TRUE';

    if FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyName = 'HasVariableInGUIObjects' then
      FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].HasVariableInGUIObjects := UpperCase(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyValue) = 'TRUE';

    DoOnSetCustomPropertyValueOnLoading(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyName, ComponentTypeIndex, FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomProperties[i].PropertyValue);
  end;

  for i := 0 to Length(FAllComponents[ComponentTypeIndex].Schema.Events) - 1 do
  begin
    FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomEvents[i].PropertyName := FAllComponents[ComponentTypeIndex].Schema.Events[i].PropertyName;
    FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].CustomEvents[i].PropertyValue := FAllComponents[ComponentTypeIndex].Schema.Events[i].PropertyDefaultValue;
  end;

  vn := Length(FAllVisualComponents);
  SetLength(FAllVisualComponents, vn + 1);
  FAllVisualComponents[vn].IndexInTDynTFTDesignAllComponentsArr := ComponentTypeIndex;
  FAllVisualComponents[vn].IndexInDesignComponentOneKindArr := dn;

  if AParentComponent = nil then
    FAllVisualComponents[vn].ScreenPanel := CreateBasePanel(pnlScroll, X, Y, ComponentTypeIndex, True, True, clNavy, vn, APluginIndex, AComponentIndexInPlugin, AUserData)
  else
  begin
    FAllVisualComponents[vn].ScreenPanel := CreateBasePanel(AParentComponent, X, Y, ComponentTypeIndex, True, True, clNavy, vn, APluginIndex, AComponentIndexInPlugin, AUserData);

    //if AParentComponent is TMountPanel then
    //begin
    //  (AParentComponent as TMountPanel).TopLeftLabel.BringToFront;
    //  (AParentComponent as TMountPanel).TopRightLabel.BringToFront;
    //  (AParentComponent as TMountPanel).BotLeftLabel.BringToFront;
    //  (AParentComponent as TMountPanel).BotRightLabel.BringToFront;
    //  (AParentComponent as TMountPanel).LeftLabel.BringToFront;
    //  (AParentComponent as TMountPanel).TopLabel.BringToFront;
    //  (AParentComponent as TMountPanel).RightLabel.BringToFront;
    //  (AParentComponent as TMountPanel).BotLabel.BringToFront;
    //end;
  end;

  FAllVisualComponents[vn].ScreenPanel.Caption := FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].ObjectName;

  SetPanelDefaultSize(FAllVisualComponents[vn].ScreenPanel, ComponentDefaultSize);

  SetPanelGeneralHint(FAllVisualComponents[vn].ScreenPanel);
  FAllVisualComponents[vn].ScreenPanel.ShowHint := True;
  FAllVisualComponents[vn].ScreenPanel.Repaint;

  DoOnAddItemToSelCompListInOI(FAllComponents[ComponentTypeIndex].DesignComponentsOneKind[dn].ObjectName);

  Result := FAllVisualComponents[vn].ScreenPanel;
end;


procedure TfrDrawingBoard.SetPanelGeneralHint(APanel: TMountPanel; Locked: Boolean = False);
begin
  APanel.Hint := APanel.Caption + ': P' + FAllComponents[APanel.DynTFTComponentType].Schema.ComponentTypeName + #13#10 +
                      'Origin: ' + IntToStr(APanel.Left) + ', ' + IntToStr(APanel.Top) + '; ' +
                      'Size: ' + IntToStr(APanel.Width) + ' x ' + IntToStr(APanel.Height) + #13#10 +
                      'Global Z index: ' + IntToStr(APanel.IndexInTProjectVisualComponentArr);

  if Locked then
    APanel.Hint := APanel.Hint + #13#10 + 'Locked';
end;


procedure TfrDrawingBoard.SetScreenEdgesHint;
var
  s: string;
begin
  s := 'Screen size: ' + IntToStr(sttxtVertical.Left) + ' x ' + IntToStr(sttxtHorizontal.Top) + #13#10 +
       'While holding the mouse button, use arrow keys for fine adjustments.' + #13#10;

  if sttxtIntersection.Tag = 0 then
    s := s + 'Currently unlocked.'
  else
    s := s + 'Currently locked.';

  s := s + ' Use right-click menu for locking/unlocking.';

  sttxtHorizontal.Hint := s;
  sttxtVertical.Hint := s;
  sttxtIntersection.Hint := s;
end;


procedure TfrDrawingBoard.GenerateListOfVisibleComponents;
var
  i, n: Integer;
  WorkPanel: TMountPanel;
begin
  SetLength(FVisibleComponents, 0);
  
  for i := 0 to Length(FAllVisualComponents) - 1 do
  begin
    WorkPanel := FAllVisualComponents[i].ScreenPanel;
    
    if (WorkPanel <> nil) and WorkPanel.Visible and (WorkPanel.Tag <> 1) then
    begin
      n := Length(FVisibleComponents);
      SetLength(FVisibleComponents, n + 1);
      FVisibleComponents[n] := i;
    end;
  end;
end;


procedure TfrDrawingBoard.AdjustVisibleCompUnSelLimits(ACurrentPanel: TMountPanel);
begin
  FVisibleCompUnSelMinLeft := Min(FVisibleCompUnSelMinLeft, ACurrentPanel.Left);
  FVisibleCompUnSelMinTop := Min(FVisibleCompUnSelMinTop, ACurrentPanel.Top);
  FVisibleCompUnSelMaxRight := Max(FVisibleCompUnSelMaxRight, ACurrentPanel.Left + ACurrentPanel.Width - 1);
  FVisibleCompUnSelMaxBottom := Max(FVisibleCompUnSelMaxBottom, ACurrentPanel.Top + ACurrentPanel.Height - 1);
end;


procedure TfrDrawingBoard.DisplayAlignmentGuideLines;
var
  MatchingLeft, MatchingTop, MatchingRight, MatchingBottom: Boolean;
  CurrentPanel: TMountPanel;
  i: Integer;
begin
  MatchingLeft := False;
  MatchingTop := False;
  MatchingRight := False;
  MatchingBottom := False;
  
  FVisibleCompUnSelMinLeft := MaxInt;
  FVisibleCompUnSelMinTop := MaxInt;
  FVisibleCompUnSelMaxRight := 0;
  FVisibleCompUnSelMaxBottom := 0;

  for i := 0 to Length(FVisibleComponents) - 1 do  //all unselected visible components
  begin
    CurrentPanel := FAllVisualComponents[FVisibleComponents[i]].ScreenPanel;
    
    if CurrentPanel.Left = FCompSelectionMinLeft then
    begin
      sttxtMatchLeft.Left := FCompSelectionMinLeft;
      MatchingLeft := True;

      AdjustVisibleCompUnSelLimits(CurrentPanel);
    end;

    if CurrentPanel.Top = FCompSelectionMinTop then
    begin
      sttxtMatchTop.Top := FCompSelectionMinTop;
      MatchingTop := True;

      AdjustVisibleCompUnSelLimits(CurrentPanel);
    end;

    if CurrentPanel.Left + CurrentPanel.Width - 1 = FCompSelectionMaxRight then
    begin
      sttxtMatchRight.Left := FCompSelectionMaxRight;
      MatchingRight := True;

      AdjustVisibleCompUnSelLimits(CurrentPanel);
    end;

    if CurrentPanel.Top + CurrentPanel.Height - 1 = FCompSelectionMaxBottom then
    begin
      sttxtMatchBottom.Top := FCompSelectionMaxBottom;
      MatchingBottom := True;

      AdjustVisibleCompUnSelLimits(CurrentPanel);
    end;
  end;

  if MatchingLeft then
  begin
    sttxtMatchLeft.Top := Min(FCompSelectionMinTop, FVisibleCompUnSelMinTop);
    sttxtMatchLeft.Height := Max(FCompSelectionMaxBottom, FVisibleCompUnSelMaxBottom) - sttxtMatchLeft.Top;
      
    if not sttxtMatchLeft.Visible then
    begin
      sttxtMatchLeft.Visible := True;
      sttxtMatchLeft.BringToFront;
    end;
  end
  else
    sttxtMatchLeft.Visible := False;

  if MatchingTop then
  begin
    sttxtMatchTop.Left := Min(FCompSelectionMinLeft, FVisibleCompUnSelMinLeft);
    sttxtMatchTop.Width := Max(FCompSelectionMaxRight, FVisibleCompUnSelMaxRight) - sttxtMatchTop.Left;

    if not sttxtMatchTop.Visible then
    begin
      sttxtMatchTop.Visible := True;
      sttxtMatchTop.BringToFront;
    end;
  end
  else
    sttxtMatchTop.Visible := False;

  if MatchingRight then
  begin
    sttxtMatchRight.Top := Min(FCompSelectionMinTop, FVisibleCompUnSelMinTop);
    sttxtMatchRight.Height := Max(FCompSelectionMaxBottom, FVisibleCompUnSelMaxBottom) - sttxtMatchLeft.Top;

    if not sttxtMatchRight.Visible then
    begin
      sttxtMatchRight.Visible := True;
      sttxtMatchRight.BringToFront;
    end;
  end
  else
    sttxtMatchRight.Visible := False;

  if MatchingBottom then
  begin
    sttxtMatchBottom.Left := Min(FCompSelectionMinLeft, FVisibleCompUnSelMinLeft);
    sttxtMatchBottom.Width := Max(FCompSelectionMaxRight, FVisibleCompUnSelMaxRight) - sttxtMatchBottom.Left;
      
    if not sttxtMatchBottom.Visible then
    begin
      sttxtMatchBottom.Visible := True;
      sttxtMatchBottom.BringToFront;
    end;
  end
  else
    sttxtMatchBottom.Visible := False;
end;


procedure TfrDrawingBoard.HideAlignmentGuideLines;
begin
  sttxtMatchLeft.Visible := False;
  sttxtMatchTop.Visible := False;
  sttxtMatchRight.Visible := False;
  sttxtMatchBottom.Visible := False;
end;


procedure TfrDrawingBoard.PopulateScreenMenu(ScreenMenuItem: TMenuItem);
var
  i: Integer;
  AMenuItem: TMenuItem;
begin
  EnableDisableActiveItemsInScreenMenu(pmScreens.Items);

  for i := 0 to pmScreens.Items.Count - 1 do
  begin
    AMenuItem := TMenuItem.Create(Self);
    AMenuItem.Caption := pmScreens.Items.Items[i].Caption;
    AMenuItem.Enabled := pmScreens.Items.Items[i].Enabled;
    AMenuItem.ImageIndex := pmScreens.Items.Items[i].ImageIndex;
    AMenuItem.OnClick := pmScreens.Items.Items[i].OnClick;

    if AMenuItem.ImageIndex > -1 then
    begin
      AMenuItem.Bitmap := TBitmap.Create;
      AMenuItem.Bitmap.Width := 16;
      AMenuItem.Bitmap.Height := 16;
      imglstScreens.Draw(AMenuItem.Bitmap.Canvas, 0, 0, AMenuItem.ImageIndex, dsNormal, itImage);
    end;

    ScreenMenuItem.Add(AMenuItem);
  end;
end;


procedure TfrDrawingBoard.GenericPanelDblClick(Sender: TObject);
begin
  GetCursorPos(FMouseDownGlobalPos);  //mouse coordinates
  FRightClickPanel := Sender as TMountPanel;
  //FRightClickComponent := FindComponentOnPanel(FRightClickPanel);
  FPanelDoubleClick := True;
end;


procedure TfrDrawingBoard.GenericPanelClick(Sender: TObject);
begin
  HideSearchForScreenPanel;
  DoOnCancelObjectInspectorEditing;

  if not scrboxScreen.Focused then
    scrboxScreen.SetFocus;
end;


procedure TfrDrawingBoard.GenericPanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  WorkPanel: TMountPanel;
  Locked: Boolean;
begin
  GetCursorPos(FMouseDownGlobalPos);  //mouse coordinates

  if not (Sender is TMountPanel) then
    raise Exception.Create('Bug in GenericPanelMouseDown. Sender is ' + Sender.ClassName);

  WorkPanel := Sender as TMountPanel;

  if WorkPanel.Tag <> 1 then
  begin
    SetFocusToAPanel(pnlScroll, WorkPanel, Shift);

    if not (ssCtrl in Shift) and not (ssShift in Shift) then
      FSelectionContent.ClearSelection;

    FSelectionContent.AddPanelToSelected(FAllComponents, FAllVisualComponents, WorkPanel);
    //lstLog.Items.Add('AddPanelToSelected GenericPanelMouseDown');
  end
  else   //selected
    if (ssCtrl in Shift) or (ssShift in Shift) then
    begin
      RemoveFocusFromAPanel(WorkPanel);
      FSelectionContent.RemovePanelFromSelected(FAllComponents, FAllVisualComponents, WorkPanel);
      //lstLog.Items.Add('RemovePanelFromSelected GenericPanelMouseDown');
    end;

  DoOnClearObjectInspector;

  ////
  if Shift = [ssRight] then
  begin
    FRightClickPanel := Sender as TMountPanel;  //do not replace with WorkPanel !!!
    //FRightClickComponent := FindComponentOnPanel(FRightClickPanel);
    pmComponent.Popup(FMouseDownGlobalPos.X, FMouseDownGlobalPos.Y);   // menu
  end;

  if not (ssLeft in Shift) then
    Exit;
  ////

  if not PanelHold then
  begin
    FMouseDownComponentPos.X := WorkPanel.Left; //component coordinates on the window
    FMouseDownComponentPos.Y := WorkPanel.Top;

    Locked := ComponentIsLocked(WorkPanel);
    if not Locked then
    begin
      PanelHold := True;
      Application.HintHidePause := 5000;
      Application.HintPause := 100;
    end;

    SetPanelGeneralHint(WorkPanel, Locked);
    FDragLocked := True;
    GenerateListOfVisibleComponents;
  end;
end;


function HasAtLeastOneSelectedParent(APanel: TMountPanel): Boolean;
begin
  Result := False;

  if (APanel.Parent <> nil) and (APanel.Parent is TMountPanel) and (APanel.Parent.Tag = 1) then
  begin
    Result := True;
    Exit;
  end;

  while (APanel.Parent <> nil) and (APanel.Parent is TMountPanel) do
  begin
    APanel := TMountPanel(APanel.Parent);

    if APanel.Tag = 1 then
    begin
      Result := True;
      Break;
    end;
  end;
end;


function HasAtLeastOneSelectedChildPanel(APanel: TMountPanel): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to APanel.ComponentCount - 1 do
    if APanel.Components[i] is TMountPanel then
    begin
      Result := Result and HasAtLeastOneSelectedChildPanel(APanel.Components[i] as TMountPanel);   //Recursion here
      if Result then
        Break;
    end;
end;


procedure TfrDrawingBoard.GenericPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  tp: TPoint;
  OldLeft, OldTop: Integer;
  i: Integer;
  WorkPanel, SenderPanel: TMountPanel;
  //PanelsToBeMovedArr: array of TMountPanel;
  NewLeft, NewTop: Integer;
begin
  if not (ssLeft in Shift) then
    Exit;

  if not PanelHold then
    Exit;

  if (ssCtrl in Shift) or (ssShift in Shift) then
    Exit;

  GetCursorPos(tp);
  if Sender is TMountPanel then
  begin
    SenderPanel := Sender as TMountPanel;

    if HasAtLeastOneSelectedParent(SenderPanel) then
      Exit;

    NewLeft := FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X;
    NewTop := FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y;

    if FDragLocked then
      if (Abs(NewLeft - SenderPanel.Left) >= FMinPxToUnlockDrag) or (Abs(NewTop - SenderPanel.Top) >= FMinPxToUnlockDrag) then
        FDragLocked := False
      else
        if not (ssAlt in Shift) then
          Exit;

    if (NewLeft <> SenderPanel.Left) or (NewTop <> SenderPanel.Top) then
      Modified := True;

    {FCompSelectionMinLeft := SenderPanel.Left;
    FCompSelectionMinTop := SenderPanel.Top;
    FCompSelectionMaxRight := SenderPanel.Left + SenderPanel.Width - 1;
    FCompSelectionMaxBottom := SenderPanel.Top + SenderPanel.Height - 1;}

    OldLeft := SenderPanel.Left;
    OldTop := SenderPanel.Top;
    SetMountPanelCoords(SenderPanel, {FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X} NewLeft, {FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y} NewTop);

    FCompSelectionMinLeft := SenderPanel.Left;
    FCompSelectionMinTop := SenderPanel.Top;
    FCompSelectionMaxRight := SenderPanel.Left + SenderPanel.Width - 1;
    FCompSelectionMaxBottom := SenderPanel.Top + SenderPanel.Height - 1;

    SenderPanel.ShowHint := True;
    SenderPanel.Hint := IntToStr(SenderPanel.Left) + ', ' + IntToStr(SenderPanel.Top);

    UpdateComponentLeftAndTopFromPanel(FAllComponents, FAllVisualComponents, SenderPanel);
    FSelectionContent.SetDisplayedPanelProperties(FAllComponents, FAllVisualComponents, SenderPanel);

    for i := 0 to pnlScroll.ComponentCount - 1 do
      if (pnlScroll.Components[i] is TMountPanel) and ((pnlScroll.Components[i] as TMountPanel) <> SenderPanel) then
      begin
        WorkPanel := pnlScroll.Components[i] as TMountPanel;

        if (WorkPanel.Tag = 1) then //it is selected, it can be moved
          if not HasAtLeastOneSelectedChildPanel(WorkPanel) and not HasAtLeastOneSelectedParent(WorkPanel) then  //this will prevent dragging a panel from its children
          begin
            if not ComponentIsLocked(WorkPanel) then
            begin
              SetMountPanelCoords(WorkPanel, WorkPanel.Left + SenderPanel.Left - OldLeft, WorkPanel.Top + SenderPanel.Top - OldTop);

              UpdateComponentLeftAndTopFromPanel(FAllComponents, FAllVisualComponents, WorkPanel);
            end;

            FSelectionContent.UpdateDisplayedPanelProperties(FAllComponents, FAllVisualComponents, WorkPanel);

            FCompSelectionMinLeft := Min(FCompSelectionMinLeft, WorkPanel.Left);
            FCompSelectionMinTop := Min(FCompSelectionMinTop, WorkPanel.Top);
            FCompSelectionMaxRight := Max(FCompSelectionMaxRight, WorkPanel.Left + WorkPanel.Width - 1);
            FCompSelectionMaxBottom := Max(FCompSelectionMaxBottom, WorkPanel.Top + WorkPanel.Height - 1);
          end;
      end;

    if FSelectionContent.GetDisplayedPropertiesCount > 0 then
      DoOnRefreshObjectInspector;

    DisplayAlignmentGuideLines;
  end; //panel
end;


procedure TfrDrawingBoard.GenericPanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SenderPanel: TMountPanel;
  WasHolding: Boolean;
begin
  WasHolding := PanelHold;
  PanelHold := False;

  FPanelDoubleClick := False;

  SenderPanel := Sender as TMountPanel;
  Application.HintHidePause := 2500;
  Application.HintPause := 500;
  SetPanelGeneralHint(SenderPanel, ComponentIsLocked(SenderPanel));

  HideAlignmentGuideLines;

  if WasHolding then
    DoOnAfterMovingMountPanel(SenderPanel);
end;


procedure TfrDrawingBoard.GenericPanelResize(Sender: TObject);
var
  APanel, WorkPanel: TMountPanel;
  i: Integer;
begin
  APanel := Sender as TMountPanel;

  if APanel.Image = nil then
  begin
    MessageBoxWrapper(Handle, 'Image is nil in GenericPanelResize.', PChar(Caption), MB_ICONERROR);
    Exit;
  end;

  {$IFDEF FPC}
    APanel.Image.Picture.Bitmap.Clear;
  {$ENDIF}

  APanel.Image.Picture.Bitmap.Width := APanel.Image.Width;   //"Out of system resources." here if not writing to plugin console
  APanel.Image.Picture.Bitmap.Height := APanel.Image.Height;

  DoOnDrawComponentOnPanel(APanel, FAllComponents, FAllVisualComponents);

  if not FSelectionContent.PanelInSelection(APanel) then //this happens when creating the panel, right before setting its properties and stuff
    Exit;

  UpdateComponentWidthAndHeightFromPanel(FAllComponents, FAllVisualComponents, APanel);
  UpdateComponentLeftAndTopFromPanel(FAllComponents, FAllVisualComponents, APanel);

  if CornerHold then
  begin
    Modified := True;
    FSelectionContent.SetDisplayedPanelProperties(FAllComponents, FAllVisualComponents, APanel);

    for i := 0 to FSelectionContent.GetSelectedCount - 1 do
    begin
      WorkPanel := FSelectionContent.GetSelectedPanelByIndex(i);

      if WorkPanel <> APanel then
        FSelectionContent.UpdateDisplayedPanelProperties(FAllComponents, FAllVisualComponents, WorkPanel);
    end;
  end;

  if FSelectionContent.GetDisplayedPropertiesCount > 0 then
    DoOnRefreshObjectInspector;
end;


procedure TfrDrawingBoard.GenericPanelImageDblClick(Sender: TObject);
begin
  GenericPanelDblClick((Sender as TImage).Parent as TMountPanel);
end;


procedure TfrDrawingBoard.GenericPanelImageClick(Sender: TObject);
begin
  GenericPanelClick((Sender as TImage).Parent as TMountPanel);
end;


procedure TfrDrawingBoard.GenericPanelImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  GenericPanelMouseDown((Sender as TImage).Parent as TMountPanel, Button, Shift, X, Y);
end;


procedure TfrDrawingBoard.GenericPanelImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  GenericPanelMouseMove((Sender as TImage).Parent as TMountPanel, Shift, X, Y);
end;


procedure TfrDrawingBoard.GenericPanelImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  GenericPanelMouseUp((Sender as TImage).Parent as TMountPanel, Button, Shift, X, Y);
end;


procedure TfrDrawingBoard.GenericCornerLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  WorkLabel: TLabel;
  WorkPanel: TMountPanel;
  Locked: Boolean;
begin
  GetCursorPos(FMouseDownGlobalPos);  //mouse coordinates

  if Shift <> [ssLeft] then
    Exit;

  WorkLabel := Sender as TLabel;
  WorkPanel := WorkLabel.Parent as TMountPanel;

  Locked := ComponentIsLocked(WorkPanel);

  if not CornerHold and not Locked then
  begin
    case WorkLabel.Tag of
      20:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left; //top left
        FMouseDownComponentPos.Y := WorkPanel.Top;
      end;

      21:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left + WorkPanel.Width; //top right
        FMouseDownComponentPos.Y := WorkPanel.Top;
      end;

      22:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left; //bottom left
        FMouseDownComponentPos.Y := WorkPanel.Top + WorkPanel.Height;
      end;

      23:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left + WorkPanel.Width; //bottom right
        FMouseDownComponentPos.Y := WorkPanel.Top + WorkPanel.Height;
      end;

      24:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left; //left
        FMouseDownComponentPos.Y := WorkPanel.Top + WorkPanel.Height shr 1;
      end;

      25:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left + WorkPanel.Width shr 1; //top
        FMouseDownComponentPos.Y := WorkPanel.Top;
      end;

      26:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left + WorkPanel.Width; //right
        FMouseDownComponentPos.Y := WorkPanel.Top + WorkPanel.Height shr 1;
      end;

      27:
      begin
        FMouseDownComponentPos.X := WorkPanel.Left + WorkPanel.Width shr 1; //bottom
        FMouseDownComponentPos.Y := WorkPanel.Top + WorkPanel.Height;
      end;
    end;
    
    CornerHold := True;
    Application.HintHidePause := 5000;
    Application.HintPause := 100;
  end;
  
  SetPanelGeneralHint(WorkPanel, Locked);
end;


procedure TfrDrawingBoard.GenericCornerLabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  tp: TPoint;
  WorkLabel: TLabel;
  WorkPanel: TMountPanel;
  OldLeft, OldTop: Integer;
begin
  if Shift <> [ssLeft] then
    Exit;

  if not CornerHold then
    Exit;

  GetCursorPos(tp);
  if Sender is TLabel then
  begin
    WorkLabel := Sender as TLabel;
    WorkPanel := WorkLabel.Parent as TMountPanel;
    OldLeft := WorkPanel.Left;
    OldTop := WorkPanel.Top;
    
    case WorkLabel.Tag of
      20: //TopLeft
        begin
          WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          WorkPanel.Width := Min(WorkPanel.Width - WorkPanel.Left + OldLeft, 65535);
          WorkPanel.Height := Min(WorkPanel.Height - WorkPanel.Top + OldTop, 65535);
        end;

      21: //TopRight
        begin
          //WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          WorkPanel.Width := Min(FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X - WorkPanel.Left, 65535);
          WorkPanel.Height := Min(WorkPanel.Height - WorkPanel.Top + OldTop, 65535);
        end;

      22: //BotLeft
        begin
          WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          //WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          WorkPanel.Width := Min(WorkPanel.Width - WorkPanel.Left + OldLeft, 65535);
          WorkPanel.Height := Min(FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y - WorkPanel.Top, 65535);
        end;

      23: //BotRight
        begin
          //WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          //WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          WorkPanel.Width := Min(FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X - WorkPanel.Left, 65535);
          WorkPanel.Height := Min(FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y - WorkPanel.Top, 65535);
        end;

      24: //Left
        begin
          WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          //WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          WorkPanel.Width := Min(WorkPanel.Width - WorkPanel.Left + OldLeft, 65535);
          //WorkPanel.Height := Min(WorkPanel.Height - WorkPanel.Top + OldTop, 65535);
        end;

      25: //Top
        begin
          //WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          //WorkPanel.Width := Min(FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X - WorkPanel.Left, 65535);
          WorkPanel.Height := Min(WorkPanel.Height - WorkPanel.Top + OldTop, 65535);
        end;

      26: //Right
        begin
          //WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          //WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          WorkPanel.Width := Min(FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X - WorkPanel.Left, 65535);
          //WorkPanel.Height := Min(WorkPanel.Height - WorkPanel.Top + OldTop, 65535);
        end;

      27: //Bot
        begin
          //WorkPanel.Left := Min(Max(0, FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X), pnlScroll.Width - 20);
          //WorkPanel.Top := Min(Max(0, FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y), pnlScroll.Height - 20);
          //WorkPanel.Width := Min(FMouseDownComponentPos.X + tp.X - FMouseDownGlobalPos.X - WorkPanel.Left, 65535);
          WorkPanel.Height := Min(FMouseDownComponentPos.Y + tp.Y - FMouseDownGlobalPos.Y - WorkPanel.Top, 65535);
        end;
    end; //case

    WorkPanel.Hint := IntToStr(WorkPanel.Width) + ' x ' + IntToStr(WorkPanel.Height);

    //FDrawingBoard.Repaint;
    //FModified := True; 
  end;
end;


procedure TfrDrawingBoard.GenericCornerLabelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SenderPanel: TMountPanel;
begin
  CornerHold := False;
  //FDrawingBoard.Repaint;

  SenderPanel := (Sender as TLabel).Parent as TMountPanel;
  Application.HintHidePause := 2500;
  Application.HintPause := 500;
  SetPanelGeneralHint(SenderPanel, ComponentIsLocked(SenderPanel));
end;


procedure TfrDrawingBoard.AddNewScreen;
var
  ATabSheet: TTabSheet;
  TempColor: TColor;
  TempColorName: string;
begin
  if Length(FAllScreens) >= CMaxScreenCount then //verification required by Paste, which directly calls AddNewScreen
    Exit;

  TempColor := 0;
  TempColorName := '';
  DoOnGetDefaultScreenColor(TempColor, TempColorName);

  SetLength(FAllScreens, PageControlScreen.PageCount + 1);
  FAllScreens[PageControlScreen.PageCount].Name := 'Screen';
  FAllScreens[PageControlScreen.PageCount].ColorName := TempColorName;
  FAllScreens[PageControlScreen.PageCount].Color := TempColor;
  FAllScreens[PageControlScreen.PageCount].Active := False;
  FAllScreens[PageControlScreen.PageCount].Persisted := False;
  
  ATabSheet := TTabSheet.Create(PageControlScreen);
  ATabSheet.PageControl := PageControlScreen;
  ATabSheet.PageIndex := PageControlScreen.PageCount - 1;
  
  ATabSheet.Caption := FAllScreens[PageControlScreen.PageCount - 1].Name;
  ATabSheet.Brush.Color := FAllScreens[PageControlScreen.PageCount - 1].Color;
  ATabSheet.ImageIndex := GetActiveAndPersistedImageIndex(FAllScreens[PageControlScreen.PageCount - 1]);
  ATabSheet.Repaint;

  ATabSheet.OnMouseEnter := PageControlScreen.OnMouseEnter;
  ATabSheet.OnMouseLeave := PageControlScreen.OnMouseLeave;
end;


procedure TfrDrawingBoard.ChagePageControlHandler;
var
  i, CompScreenIndex: Integer;
  WorkPanel: TMountPanel;
begin
  for i := 0 to pnlScroll.ComponentCount - 1 do
    if pnlScroll.Components[i] is TMountPanel then
    begin
      WorkPanel := pnlScroll.Components[i] as TMountPanel;
      CompScreenIndex := GetScreenIndexFromPanel(FAllComponents, FAllVisualComponents, WorkPanel);
      WorkPanel.Visible := (CompScreenIndex = PageControlScreen.ActivePageIndex) or FAllScreens[CompScreenIndex].Persisted;
    end;

  pnlScroll.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;
  lblCurrentScreen.Caption := 'Current Screen Index: ' + IntToStr(PageControlScreen.ActivePageIndex);
end;


function TfrDrawingBoard.GetPropertyValueFromPropertiesByNameAndPanel(APropertyName: string; APanel: TMountPanel): string;
begin
  Result := GetPropertyValueInPropertiesByNameAndPanel(FAllComponents, FAllVisualComponents, APropertyName, APanel);
end;


function TfrDrawingBoard.GetDrawingBoardScreenLeft: Integer;
begin
  Result := scrboxScreen.Left;
end;


function TfrDrawingBoard.GetDrawingBoardScreenTop: Integer;
begin
  Result := scrboxScreen.Top;
end;


function TfrDrawingBoard.GetDrawingBoardScreenWidth: Integer;
begin
  Result := scrboxScreen.Width;
end;


function TfrDrawingBoard.GetDrawingBoardScreenHeight: Integer;
begin
  Result := scrboxScreen.Height;
end;


function TfrDrawingBoard.GetDrawingBoardScreenHScrBarPos: Integer;
begin
  Result := scrboxScreen.HorzScrollBar.ScrollPos;
end;


function TfrDrawingBoard.GetDrawingBoardScreenVScrBarPos: Integer;
begin
  Result := scrboxScreen.VertScrollBar.ScrollPos;
end;


procedure TfrDrawingBoard.ShowBorder;
begin
  {$IFnDEF FPC}
    scrboxScreen.BevelKind := bkSoft;
  {$ENDIF}
end;


procedure TfrDrawingBoard.HideBorder;
begin
  {$IFnDEF FPC}
    scrboxScreen.BevelKind := bkNone;
  {$ENDIF}
end;


procedure TfrDrawingBoard.SetPanelFocus(APanel: TMountPanel; ShifState: TShiftState);
begin
  SetFocusToAPanel(pnlScroll, APanel, ShifState);
end;


procedure TfrDrawingBoard.AddPanelToSelected(APanel: TMountPanel);
begin
  FSelectionContent.AddPanelToSelected(FAllComponents, FAllVisualComponents, APanel);
end;


function TfrDrawingBoard.AtLeastOneSelectedPanelExists: Boolean;
begin
  Result := SelectedPanelsExist(pnlScroll);
end;


procedure TfrDrawingBoard.HandleMouseWheel(RawWheelDelta: Integer; SwapPages: Boolean);
var
  OldIndex, NewIndex: Integer;
  Ph: string;
  PhInt: Integer;
  PhScreen: TScreenInfo;
  PanelScreenIndex: Integer;
  WorkPanel: TMountPanel;
  i: Integer;
begin
  if FPageMouseIn then
  begin
    if (PageControlScreen.ActivePageIndex = -1) and (PageControlScreen.PageCount > 0) then
      PageControlScreen.ActivePageIndex := 0;

    OldIndex := PageControlScreen.ActivePageIndex;

    NewIndex := PageControlScreen.ActivePageIndex;
    NewIndex := NewIndex - Sign(RawWheelDelta);
    if (NewIndex > -1) and (NewIndex < PageControlScreen.PageCount) then
      PageControlScreen.ActivePageIndex := NewIndex;

    if (PageControlScreen.ActivePageIndex = -1) and (PageControlScreen.PageCount > 0) then
      PageControlScreen.ActivePageIndex := 0;

    if (PageControlScreen.ActivePageIndex > PageControlScreen.PageCount - 1) and (PageControlScreen.PageCount > 0) then
      PageControlScreen.ActivePageIndex := PageControlScreen.PageCount - 1;

    if (PageControlScreen.ActivePageIndex <> OldIndex) and (PageControlScreen.ActivePageIndex <> -1) then
    begin
      if SwapPages then
      begin
        PhScreen := FAllScreens[PageControlScreen.ActivePageIndex];
        FAllScreens[PageControlScreen.ActivePageIndex] := FAllScreens[OldIndex];
        FAllScreens[OldIndex] := PhScreen;

        Ph := PageControlScreen.Pages[PageControlScreen.ActivePageIndex].Caption;
        PageControlScreen.Pages[PageControlScreen.ActivePageIndex].Caption := PageControlScreen.Pages[OldIndex].Caption;
        PageControlScreen.Pages[OldIndex].Caption := Ph;

        PhInt := PageControlScreen.Pages[PageControlScreen.ActivePageIndex].ImageIndex;
        PageControlScreen.Pages[PageControlScreen.ActivePageIndex].ImageIndex := PageControlScreen.Pages[OldIndex].ImageIndex;
        PageControlScreen.Pages[OldIndex].ImageIndex := PhInt;

        FSelectionContent.ClearSelection;
        RemoveFocusFromAllPanels(pnlScroll);

        DoOnClearObjectInspector;

        for i := pnlScroll.ComponentCount - 1 downto 0 do
          if pnlScroll.Components[i] is TMountPanel then
          begin
            WorkPanel := pnlScroll.Components[i] as TMountPanel;
            PanelScreenIndex := GetScreenIndexFromPanel(FAllComponents, FAllVisualComponents, WorkPanel);

            if PanelScreenIndex = PageControlScreen.ActivePageIndex then
              SetMountPanelScreenIndex(FAllComponents, FAllVisualComponents, WorkPanel, OldIndex);

            if PanelScreenIndex = OldIndex then
              SetMountPanelScreenIndex(FAllComponents, FAllVisualComponents, WorkPanel, PageControlScreen.ActivePageIndex);
          end;
      end; //swap

      ChagePageControlHandler;
    end;
  end;
end;


procedure TfrDrawingBoard.SelectAllPanelsThenUpdateObjectInspector(SelectFromAllScreens: Boolean);
var
  SelectedComponentCount: Integer;
  HorzScrollBar_Position, VertScrollBar_Position: Integer;
  TempMsg, TempHint: string;
begin
  TempMsg := 'Building selection...';
  TempHint := '';
  DoOnBeforeSelectAllPanels(TempMsg, TempHint);

  HorzScrollBar_Position := scrboxScreen.HorzScrollBar.Position;
  VertScrollBar_Position := scrboxScreen.VertScrollBar.Position;
  pnlScroll.Visible := False;
  try
    if SelectFromAllScreens then  //select all, no matter the ScreenIndex
    begin
      SelectAllPanels(FAllComponents, FAllVisualComponents, pnlScroll, FSelectionContent, -1);
      SelectedComponentCount := FSelectionContent.GetSelectedCount;

      if SelectedComponentCount = 1 then
        TempMsg := 'Selection: one component from all screens.'
      else
        TempMsg := 'Selection: ' + IntToStr(SelectedComponentCount) + ' components from all screens.';

      TempHint := '';  
    end
    else                 //select only from current ScreenIndex
    begin
      SetFocusToAPanel(pnlScroll, nil, []);
      FSelectionContent.ClearSelection;

      SelectAllPanels(FAllComponents, FAllVisualComponents, pnlScroll, FSelectionContent, PageControlScreen.ActivePageIndex);
      SelectedComponentCount := FSelectionContent.GetSelectedCount;

      if SelectedComponentCount = 1 then
        TempMsg := 'Selection: one component from current screen.'
      else
        TempMsg := 'Selection: ' + IntToStr(SelectedComponentCount) + ' components from current screen.';
      
      TempHint := 'Use Ctrl-Shift-A to select all components from all screens.';
    end;
  finally
    pnlScroll.Visible := True;
    scrboxScreen.HorzScrollBar.Position := HorzScrollBar_Position;
    scrboxScreen.VertScrollBar.Position := VertScrollBar_Position;
  end;
  
  DoOnClearObjectInspector;
  DoOnAfterSelectAllPanels(TempMsg, TempHint);

  GenerateListOfVisibleComponents;
end;


function TfrDrawingBoard.GetActiveAndPersistedImageIndex(AScreen: TScreenInfo): Integer;
begin
  //Result := -1;
  if AScreen.Active then
  begin
    if AScreen.Persisted then
      Result := 5
    else
      Result := 1;
  end
  else
  begin
    if AScreen.Persisted then
      Result := 4
    else
      Result := 0;
  end;
end;


function TfrDrawingBoard.ComponentIsLocked(APanel: TMountPanel): Boolean;
begin
  Result := GetPropertyValueInPropertiesOrEventsByName(FAllComponents[APanel.DynTFTComponentType].DesignComponentsOneKind[FAllVisualComponents[APanel.IndexInTProjectVisualComponentArr].IndexInDesignComponentOneKindArr].CustomProperties, 'Locked') = 'True';
end;


procedure TfrDrawingBoard.BringRedLimitsToFront;
begin
  sttxtVertical.BringToFront;
  sttxtHorizontal.BringToFront;
  sttxtIntersection.BringToFront;
end;


procedure TfrDrawingBoard.EnableDisableActiveItemsInScreenMenu(AMenuItem: TMenuItem);
var
  IndexOfActive, IndexOfInactive, IndexOfPersisted, IndexOfNotPersisted, i: Integer;
begin
  IndexOfActive := -1;
  IndexOfInactive := -1;
  IndexOfPersisted := -1;
  IndexOfNotPersisted := -1;

  for i := AMenuItem.Count - 1 downto 0 do
    if AMenuItem[i].Tag = 10 then
    begin
      IndexOfActive := i;
      Break;
    end;

  for i := AMenuItem.Count - 1 downto 0 do
    if AMenuItem[i].Tag = 11 then
    begin
      IndexOfInactive := i;
      Break;
    end;

  for i := AMenuItem.Count - 1 downto 0 do
    if AMenuItem[i].Tag = 20 then
    begin
      IndexOfPersisted := i;
      Break;
    end;

  for i := AMenuItem.Count - 1 downto 0 do
    if AMenuItem[i].Tag = 21 then
    begin
      IndexOfNotPersisted := i;
      Break;
    end;

  if IndexOfActive > -1 then
    AMenuItem[IndexOfActive].Enabled := not FAllScreens[PageControlScreen.ActivePageIndex].Active;

  if IndexOfInactive > -1 then
    AMenuItem[IndexOfInactive].Enabled := FAllScreens[PageControlScreen.ActivePageIndex].Active;

  if IndexOfPersisted > -1 then
    AMenuItem[IndexOfPersisted].Enabled := not FAllScreens[PageControlScreen.ActivePageIndex].Persisted;

  if IndexOfNotPersisted > -1 then
    AMenuItem[IndexOfNotPersisted].Enabled := FAllScreens[PageControlScreen.ActivePageIndex].Persisted;
end;


procedure TfrDrawingBoard.SelectSinglePanel(APanel: TMountPanel);
begin
  //SetFocusToAPanel(pnlScroll, nil, []); //unfocuses all selected panels
  FSelectionContent.ClearSelection;

  SetFocusToAPanel(pnlScroll, APanel, []);
  FSelectionContent.AddPanelToSelected(FAllComponents, FAllVisualComponents, APanel);
  DoOnClearObjectInspector;
end;


function TfrDrawingBoard.GetActiveScreenIndex: Integer;
begin
  Result := PageControlScreen.ActivePageIndex;
end;


procedure TfrDrawingBoard.SwitchScreenByIndex(AIndex: Integer);
begin
  if AIndex <> PageControlScreen.ActivePageIndex then
  begin
    if AIndex <= -1 then
      PageControlScreen.ActivePageIndex := 0
    else
      PageControlScreen.ActivePageIndex := AIndex;

    ChagePageControlHandler;
  end;
end;


procedure TfrDrawingBoard.UpdateComponentsWithPropertyValue(ObjectInspectorType: Integer; IndexInSel: Integer; NewValue: string);
begin
  SelectionContent.UpdateComponentsWithPropertyValue(FAllComponents, FAllVisualComponents, ObjectInspectorType, IndexInSel, NewValue);
end;


procedure TfrDrawingBoard.SetGeneralHintToSelectedPanels;
var
  i: Integer;
begin
  for i := 0 to SelectionContent.GetSelectedCount - 1 do
    SetPanelGeneralHint(FSelectionContent.GetSelectedPanelByIndex(i), ComponentIsLocked(FSelectionContent.GetSelectedPanelByIndex(i)));
end;


procedure TfrDrawingBoard.UpdateComponentLeftAndTopFromAPanel(APanel: TMountPanel);
begin
  UpdateComponentLeftAndTopFromPanel(FAllComponents, FAllVisualComponents, APanel);
end;


function TfrDrawingBoard.GetComponentsLengthOfOneKind(ACompType: Integer): Integer;
begin
  Result := Length(FAllComponents[ACompType].DesignComponentsOneKind);
end;


function TfrDrawingBoard.GetVisualComponentsLength: Integer;
begin
  Result := Length(FAllVisualComponents);
end;


function TfrDrawingBoard.GetVisualComponentByIndex(AIndex: Integer): TProjectVisualComponent;
begin
  Result := FAllVisualComponents[AIndex];
end;


function TfrDrawingBoard.GetPropertiesArrayByIndex(AComponentType, AVisualComponentIndex: Integer): TDynTFTDesignPropertyArr;
begin
  Result := FAllComponents[AComponentType].DesignComponentsOneKind[FAllVisualComponents[AVisualComponentIndex].IndexInDesignComponentOneKindArr].CustomProperties;
end;


function TfrDrawingBoard.GetObjectNamePropertyByIndex(AComponentType, AVisualComponentIndex: Integer): string;
begin
  Result := FAllComponents[AComponentType].DesignComponentsOneKind[FAllVisualComponents[AVisualComponentIndex].IndexInDesignComponentOneKindArr].ObjectName;
end;


function TfrDrawingBoard.GetScreenByIndex(AIndex: Integer): TScreenInfo;
begin
  Result := FAllScreens[AIndex];
end;


procedure TfrDrawingBoard.SetDisplayedPanelProperties(APanel: TMountPanel);
begin
  SelectionContent.SetDisplayedPanelProperties(FAllComponents, FAllVisualComponents, APanel);
end;


procedure TfrDrawingBoard.UpdateDisplayedPanelProperties(APanel: TMountPanel);
begin
  SelectionContent.UpdateDisplayedPanelProperties(FAllComponents, FAllVisualComponents, APanel);
end;


procedure TfrDrawingBoard.SearchForScreen;
var
  Node, OldNode, LastNode: PVirtualNode;
  VisibilityFromNumber, VisibilityFromName: Boolean;
begin
  Node := vstScreens.GetFirst;
  if Node = nil then
    Exit;

  vstScreens.Enabled := False;
  try
    vstScreens.ClearSelection;
    
    LastNode := vstScreens.GetLast;
    repeat
      VisibilityFromNumber := ((lbeScreenNumber.Text = '') or (StrToIntDef(lbeScreenNumber.Text, -1) = Integer(Node^.Index)));
      try
        VisibilityFromName := (lbeScreenName.Text = '') or (Pos(UpperCase(lbeScreenName.Text), UpperCase(FAllScreens[Node^.Index].Name)) > 0);
      except
        VisibilityFromName := False; //hide if bug
      end;
      vstScreens.IsVisible[Node] := VisibilityFromNumber and VisibilityFromName;

      OldNode := Node;
      Node := Node^.NextSibling;
    until OldNode = LastNode;
  finally
    vstScreens.Enabled := True;
  end;
end;


procedure TfrDrawingBoard.SearchForScreenAllControlsOnKeyDown(Key: Word);
var
  Node: PVirtualNode;
begin
  if Key = VK_RETURN then
  begin
    Node := vstScreens.GetFirstSelected;
    if Node <> nil then
    begin
      PageControlScreen.ActivePageIndex := Node^.Index;
      ChagePageControlHandler;
      pnlSearchForScreen.Hide;
    end;
  end;

  if Key = VK_ESCAPE then
    pnlSearchForScreen.Hide;
end;


procedure TfrDrawingBoard.DeleteComponentByPanel(APanel: TMountPanel);
var
  ComponentTypeIndex: Integer;
  IndexInDesignComponentOneKind: Integer;
  IndexInVisual: Integer;
begin
  ComponentTypeIndex := FAllVisualComponents[APanel.IndexInTProjectVisualComponentArr].IndexInTDynTFTDesignAllComponentsArr;
  IndexInVisual := APanel.IndexInTProjectVisualComponentArr;
  IndexInDesignComponentOneKind := FAllVisualComponents[IndexInVisual].IndexInDesignComponentOneKindArr;

  DeleteComponentFrom_TDynTFTDesignAllComponentsArr(FAllComponents, FAllVisualComponents, ComponentTypeIndex, IndexInDesignComponentOneKind);
  DeleteComponentFrom_TProjectVisualComponentArr(FAllComponents, FAllVisualComponents, ComponentTypeIndex, IndexInVisual);

  DoOnDeleteComponentByPanel(APanel);
end;


procedure TfrDrawingBoard.DeleteAllSelectedPanelsThenUpdateSelection;
begin
  DeleteSelectedPanels(pnlScroll, {$IFDEF FPC}@{$ENDIF}DeleteComponentByPanel);
  FSelectionContent.ClearSelection;

  DoOnClearObjectInspector;

  Modified := True;
end;


procedure TfrDrawingBoard.UpdateComponentPopupMenu(MenuItems: TMenuItem);
var
  i: Integer;
  En: Boolean;
  s: string;
begin
  En := FSelectionContent.GetSelectedCount > 0;
  for i := 0 to pmComponent.Items.Count - 1 do
  begin
    s := StringReplace(MenuItems.Items[i].Caption, '&', '', [rfReplaceAll]);
    if (Pos('Select All', s) = 0) and (s <> 'Paste') then
      MenuItems.Items[i].Enabled := En;
  end;
end;


procedure TfrDrawingBoard.CutSelectionToClipboard;
begin
  CopySelectionToClipboard;
  DeleteAllSelectedPanelsThenUpdateSelection;

  Modified := True;
end;


procedure TfrDrawingBoard.CopySelectionToClipboard;
var
  AStringList: TStringList;
  i, j: Integer;
  SelectedTypeNames: array of string; //all selected components
  SelectedDesignComponentsVariousKinds: TDynTFTDesignComponentOneKindArr;  //Every item can be of any kind. Just look at SelectedTypeNames for details.

  APanel: TMountPanel;
  IdxInVisualComponents: Integer;
  IdxInTDynTFTDesignAllComponentsArr: Integer;
  IdxInDesignComponentOneKindArr: Integer;
  FoundMultipleScreens: Boolean;
  FirstFoundScreenIndex: string;
  PropValue: string;
begin
  AStringList := TStringList.Create;
  try
    SetLength(SelectedTypeNames, FSelectionContent.GetSelectedCount);
    SetLength(SelectedDesignComponentsVariousKinds, FSelectionContent.GetSelectedCount);

    AStringList.Add('[SelectionInfo]');
    AStringList.Add('SelectionCount=' + IntToStr(FSelectionContent.GetSelectedCount));

    AStringList.Add('');

    FoundMultipleScreens := False;
    FirstFoundScreenIndex := '';  //do not init with 0 !!!

    for i := 0 to FSelectionContent.GetSelectedCount - 1 do
    begin
      APanel := FSelectionContent.GetSelectedPanelByIndex(i);
      IdxInVisualComponents := APanel.IndexInTProjectVisualComponentArr;
      IdxInTDynTFTDesignAllComponentsArr := FAllVisualComponents[IdxInVisualComponents].IndexInTDynTFTDesignAllComponentsArr;
      IdxInDesignComponentOneKindArr := FAllVisualComponents[IdxInVisualComponents].IndexInDesignComponentOneKindArr;

      SelectedTypeNames[i] := FAllComponents[IdxInTDynTFTDesignAllComponentsArr].Schema.ComponentTypeName;
      SelectedDesignComponentsVariousKinds := FAllComponents[IdxInTDynTFTDesignAllComponentsArr].DesignComponentsOneKind;

      AStringList.Add('[Component_' + IntToStr(i) + '_' + SelectedTypeNames[i] + ']'); //section
      AStringList.Add('TypeIndex=' + IntToStr(IdxInTDynTFTDesignAllComponentsArr));  //used for fast search. It should be prevalidated on paste. If doesn't match, it has to be searched for.
      AStringList.Add('ObjectName=' + SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].ObjectName);

      AStringList.Add('PropertyCount=' + IntToStr(Length(SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomProperties)));
      AStringList.Add('EventCount=' + IntToStr(Length(SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomEvents)));

      for j := 0 to Length(SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomProperties) - 1 do
      begin
        AStringList.Add('Property_' + IntToStr(j) + '_Name=' + SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomProperties[j].PropertyName); //used for index verification

        PropValue := FastReplace_ReturnTo45(SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomProperties[j].PropertyValue);
        AStringList.Add('Property_' + IntToStr(j) + '_Value=' + PropValue);

        if not FoundMultipleScreens then
        begin
          if SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomProperties[j].PropertyName = 'ScreenIndex' then
          begin
            if FirstFoundScreenIndex = '' then
              FirstFoundScreenIndex := PropValue
            else
              if FirstFoundScreenIndex <> PropValue then
                FoundMultipleScreens := True;
          end;
        end;
      end;

      for j := 0 to Length(SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomEvents) - 1 do
      begin
        AStringList.Add('Event_' + IntToStr(j) + '_Name=' + SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomEvents[j].PropertyName);  //used for index verification
        AStringList.Add('Event_' + IntToStr(j) + '_Value=' + FastReplace_ReturnTo45(SelectedDesignComponentsVariousKinds[IdxInDesignComponentOneKindArr].CustomEvents[j].PropertyValue));
      end;

      AStringList.Add('');
    end; //for

    if FoundMultipleScreens then
    begin
      AStringList.Add('[ScreenInfo]');
      AStringList.Add('FoundMultipleScreens=1');
      AStringList.Add('');
    end;

    //make sure to delete new sections on paste if adding new sections here (see below paste code)

    Clipboard.AsText := AStringList.Text;
  finally
    AStringList.Free;
  end;
end;


procedure TfrDrawingBoard.PasteSelectionFromClipboard;
var
  Ini: TMemIniFile;
  AStringList: TStringList;
  i, j, k: Integer;
  SelectedTypeNames: array of record
    Name: string; //all selected components
    TypeIndex: Integer;
  end;  
  SelectedDesignComponentsVariousKinds: TDynTFTDesignComponentOneKindArr;  //Every item can be of any kind. Just look at SelectedTypeNames for details.

  APanel: TMountPanel;
  IdxInVisualComponents: Integer;
  IdxInTDynTFTDesignAllComponentsArr: Integer;
  IdxInDesignComponentOneKindArr: Integer;

  SelectionCount: Integer;
  Sections: TStringList;

  FoundUnknownIndex: Boolean;
  UnknownTypeName: string;
  Res: Integer;
  SectionName: string;
  CompScreenIndex, CompLeft, CompTop, CompWidth, CompHeight: Integer;
  LenComp: Integer;
  HorzScrollBar_Position, VertScrollBar_Position: Integer;
  PropIndex: Integer;
  MinLeft, MinTop: Integer;
  PastedPanels: TMountPanelArr;
  FoundMultipleScreens: Boolean;
  SelectionInfoIndex: Integer;
  ScreenInfoIndex: Integer;
  EventDataType: string;
  FoundLocked, Locked: Boolean;
  TempCategoryIndex, TempComponentIndex: Integer;
begin
  ClearSelection;
  DoOnClearObjectInspector;
  
  Ini := TMemIniFile.Create('');
  try
    AStringList := TStringList.Create;
    Sections := TStringList.Create;
    try
      AStringList.Text := Clipboard.AsText;
      Ini.SetStrings(AStringList);

      SelectionCount := Ini.ReadInteger('SelectionInfo', 'SelectionCount', 0);
      if SelectionCount = 0 then
        Exit;

      FoundMultipleScreens := Ini.ReadBool('ScreenInfo', 'FoundMultipleScreens', False);
        
      Ini.ReadSections(Sections);
      
      SelectionInfoIndex := Sections.IndexOf('SelectionInfo');
      if SelectionInfoIndex > - 1 then
        Sections.Delete(SelectionInfoIndex);

      ScreenInfoIndex := Sections.IndexOf('ScreenInfo');
      if ScreenInfoIndex > - 1 then
        Sections.Delete(ScreenInfoIndex);

      if Sections.Count <> SelectionCount then
      begin
        MessageBoxWrapper(Handle, 'Component count does not match selection count in clipboard data. Aborting paste operation.', PChar(Caption), MB_ICONERROR);
        Exit;
      end;

      LenComp := Length('Component_') + 1;
      SetLength(SelectedTypeNames, SelectionCount);
      for i := 0 to SelectionCount - 1 do  //number of components in clipboard
      begin
        SelectedTypeNames[i].Name := Copy(Sections.Strings[i], LenComp, MaxInt);  //this includes the component index
        SelectedTypeNames[i].Name := Copy(SelectedTypeNames[i].Name, Pos('_', SelectedTypeNames[i].Name) + 1, MaxInt);
        SelectedTypeNames[i].TypeIndex := Ini.ReadInteger(Sections.Strings[i], 'TypeIndex', -1);
      end;

      UnknownTypeName := '';
      FoundUnknownIndex := False;
      try
        for i := 0 to SelectionCount - 1 do
          if SelectedTypeNames[i].Name <> FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.ComponentTypeName then
          begin
            FoundUnknownIndex := True;

            for j := 0 to Length(FAllComponents) - 1 do
              if FAllComponents[j].Schema.ComponentTypeName = SelectedTypeNames[i].Name then  //found at different index
              begin
                SelectedTypeNames[i].TypeIndex := j;
                FoundUnknownIndex := False; //found elsewhere, so reset flag
                Break;
              end;

            if FoundUnknownIndex then
              UnknownTypeName := UnknownTypeName + SelectedTypeNames[i].Name + #13#10;
          end;
      except
        on E: Exception do
        begin
          FoundUnknownIndex := True;
          UnknownTypeName := E.Message;
        end;
      end;

      Res := IDYES;
      if FoundUnknownIndex then
        Res := MessageBoxWrapper(Handle,
                                 PChar('Found component(s) of unknown type(s): ' + #13#10 + UnknownTypeName + #13#10 + #13#10 + 'Continue pasting the others?'),
                                 PChar(Caption),
                                 MB_ICONQUESTION + MB_YESNO)
      {else
        MessageBoxWrapper(Handle, 'All good.', PChar(Caption), MB_ICONINFORMATION)};

      if Res = IDNO then
        Exit
      else
      begin
        MinLeft := MaxInt;
        MinTop := MaxInt;

        FSelectionContent.ClearSelection;

        if SelectionCount > 0 then
          Modified := True;

        SetLength(SelectedDesignComponentsVariousKinds, SelectionCount);
        SetLength(PastedPanels, SelectionCount);
        for i := 0 to SelectionCount - 1 do
        begin
          SectionName := 'Component_' + IntToStr(i) + '_' + SelectedTypeNames[i].Name;

          SelectedDesignComponentsVariousKinds[i].ObjectName := Ini.ReadString(SectionName, 'ObjectName', 'UnknownObjectName_' + IntToStr(i));
          SetLength(SelectedDesignComponentsVariousKinds[i].CustomProperties, Ini.ReadInteger(SectionName, 'PropertyCount', 0));
          SetLength(SelectedDesignComponentsVariousKinds[i].CustomEvents, Ini.ReadInteger(SectionName, 'EventCount', 0));

          for j := 0 to Length(SelectedDesignComponentsVariousKinds[i].CustomProperties) - 1 do
          begin
            SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName := Ini.ReadString(SectionName, 'Property_' + IntToStr(j) + '_Name', 'UnknownProperty_' + IntToStr(j));
            SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue := FastReplace_45ToReturn(Ini.ReadString(SectionName, 'Property_' + IntToStr(j) + '_Value', 'UnknownValue_' + IntToStr(j)));
          end;

          for j := 0 to Length(SelectedDesignComponentsVariousKinds[i].CustomEvents) - 1 do
          begin
            SelectedDesignComponentsVariousKinds[i].CustomEvents[j].PropertyName := Ini.ReadString(SectionName, 'Event_' + IntToStr(j) + '_Name', 'UnknownEvent_' + IntToStr(j));
            SelectedDesignComponentsVariousKinds[i].CustomEvents[j].PropertyValue := FastReplace_45ToReturn(Ini.ReadString(SectionName, 'Event_' + IntToStr(j) + '_Value', 'UnknownValue_' + IntToStr(j)));
          end;
        end; //for ..  number of selected components

        HorzScrollBar_Position := scrboxScreen.HorzScrollBar.Position;
        VertScrollBar_Position := scrboxScreen.VertScrollBar.Position;
        pnlScroll.Visible := False;
        //DoOnSetOIComboBoxVisibility(False);
        try
          //create components
          for i := 0 to Length(SelectedDesignComponentsVariousKinds) - 1 do
          begin
            //CompLeft := GetPropertyIndexInPropertiesOrEventsByName(SelectedDesignComponentsVariousKinds[i].CustomProperties, 'Left');
            CompLeft := 0;
            CompTop := 0;
            CompWidth := 10;
            CompHeight := 10;

            if FoundMultipleScreens then
              CompScreenIndex := 0  //assume first screen
            else
            begin
              //AddNewScreen;
              CompScreenIndex := PageControlScreen.ActivePageIndex;  //paste all components from all screens to the active screen
            end;

            FoundLocked := False;
            for j := 0 to Length(SelectedDesignComponentsVariousKinds[i].CustomProperties) - 1 do
            begin
              if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'Left' then
                CompLeft := StrToIntDef(SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue, 0);

              if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'Top' then
                CompTop := StrToIntDef(SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue, 0);

              if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'Width' then
                CompWidth := StrToIntDef(SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue, 20);

              if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'Height' then
                CompHeight := StrToIntDef(SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue, 20);

              if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'ScreenIndex' then
              begin
                if FoundMultipleScreens then
                begin
                  CompScreenIndex := StrToIntDef(SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue, 0);

                  if CompScreenIndex >= PageControlScreen.PageCount - 1 then
                  begin
                    for k := 0 to CompScreenIndex - PageControlScreen.PageCount do //no +1
                    begin
                      if PageControlScreen.PageCount >= CMaxScreenCount then
                        Break;

                      AddNewScreen;
                    end;

                    if CompScreenIndex >= PageControlScreen.PageCount - 1 then
                      CompScreenIndex := PageControlScreen.PageCount - 1; //move all components with "out of range ScreenIndex" to the last screen
                  end;
                end //FoundMultipleScreens
                else
                begin
                  SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue := IntToStr(CompScreenIndex);
                end; //single screen
              end; //if SelectedDesignComponentsVariousKinds

              if not FoundLocked then
                if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'Locked' then
                begin
                  Locked := SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue = 'True';
                  FoundLocked := True;
                end;
            end;  //for j

            if MinLeft > CompLeft then
              MinLeft := CompLeft;

            if MinTop > CompTop then
              MinTop := CompTop;

            DoOnGetComponentIndexFromPlugin(SelectedTypeNames[i].TypeIndex, TempCategoryIndex, TempComponentIndex);
            APanel := AddComponentToDrawingBoard(SelectedTypeNames[i].TypeIndex, CompLeft, CompTop, TempCategoryIndex, TempComponentIndex);
            PastedPanels[i] := APanel;

            if scrboxScreen.Focused then
            begin
              Inc(CompLeft, FPasteX - MinLeft);
              Inc(CompTop, FPasteY - MinTop);

              CompLeft := Max(0, Min(CompLeft, CMaxComponentLeftAndTop));
              CompTop := Max(0, Min(CompTop, CMaxComponentLeftAndTop));

              APanel.Left := CompLeft;
              APanel.Top := CompTop;
            end;

            UpdateComponentLeftAndTopFromPanel(FAllComponents, FAllVisualComponents, APanel);

            APanel.Width := CompWidth;
            APanel.Height := CompHeight;
            UpdateComponentWidthAndHeightFromPanel(FAllComponents, FAllVisualComponents, APanel);
            APanel.Visible := ((PageControlScreen.ActivePageIndex = CompScreenIndex) or FAllScreens[CompScreenIndex].Persisted);
            UpdateComponentScreenIndex(FAllComponents, FAllVisualComponents, APanel, CompScreenIndex);

            IdxInVisualComponents := APanel.IndexInTProjectVisualComponentArr;
            IdxInDesignComponentOneKindArr := FAllVisualComponents[IdxInVisualComponents].IndexInDesignComponentOneKindArr;

            if Locked then
              APanel.Cursor := crNo;

            SetPanelGeneralHint(APanel, Locked);

            for j := 0 to Length(SelectedDesignComponentsVariousKinds[i].CustomProperties) - 1 do
            begin
              if (SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName <> 'Left') and
                 (SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName <> 'Top') and
                 (SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName <> 'Width') and
                 (SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName <> 'Height') and
                 (SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName <> 'ScreenIndex') then
              begin  //excluded properties
                PropIndex := -1;
                if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Properties[j].PropertyName then
                  PropIndex := j
                else
                begin
                  for k := 0 to Length(FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Properties) - 1 do
                    if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Properties[k].PropertyName then
                    begin
                      PropIndex := k;
                      Break;
                    end;
                end;

                if PropIndex > -1 then
                begin
                  FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr].CustomProperties[PropIndex].PropertyValue := SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue;

                  if SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName = 'ObjectName' then
                  begin
                    if ComponentInstanceExistsByName(FAllComponents, FAllVisualComponents, FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr].CustomProperties[PropIndex].PropertyValue) then
                      FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr].CustomProperties[PropIndex].PropertyValue := APanel.Caption
                    else
                      APanel.Caption := FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr].CustomProperties[PropIndex].PropertyValue;

                    FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr].ObjectName := APanel.Caption;
                  end;

                  DoOnUpdateSpecialProperty(j,
                                            FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr],
                                            SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyName,
                                            SelectedDesignComponentsVariousKinds[i].CustomProperties[j].PropertyValue);
                end //PropIndex > -1
              end; //excluded properties
            end; //for

            for j := 0 to Length(SelectedDesignComponentsVariousKinds[i].CustomEvents) - 1 do
            begin
              PropIndex := -1;
              EventDataType := 'Unknown_type_on_paste';
              if SelectedDesignComponentsVariousKinds[i].CustomEvents[j].PropertyName = FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Events[j].PropertyName then
              begin
                PropIndex := j;
                EventDataType := FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Events[j].PropertyDataType;
              end
              else
              begin
                for k := 0 to Length(FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Events) - 1 do
                  if SelectedDesignComponentsVariousKinds[i].CustomEvents[j].PropertyName = FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Events[k].PropertyName then
                  begin
                    PropIndex := k;
                    EventDataType := FAllComponents[SelectedTypeNames[i].TypeIndex].Schema.Events[k].PropertyDataType;
                    Break;
                  end;
              end;

              if PropIndex > -1 then
              begin
                FAllComponents[SelectedTypeNames[i].TypeIndex].DesignComponentsOneKind[IdxInDesignComponentOneKindArr].CustomEvents[PropIndex].PropertyValue := SelectedDesignComponentsVariousKinds[i].CustomEvents[j].PropertyValue;  //this is handler name
                DoOnAddNewHandlerToAllHandlersByHandlerType(EventDataType, SelectedDesignComponentsVariousKinds[i].CustomEvents[j].PropertyValue);
              end;
            end; //for

            DoOnDrawComponentOnPanel(APanel, FAllComponents, FAllVisualComponents);
            FSelectionContent.AddPanelToSelected(FAllComponents, FAllVisualComponents, APanel);
            SetFocusToAPanel(pnlScroll, APanel, [ssShift]);
          end;  //for  //create components
        finally
          pnlScroll.Visible := True;
          //DoOnSetOIComboBoxVisibility(True);
          scrboxScreen.HorzScrollBar.Position := HorzScrollBar_Position;
          scrboxScreen.VertScrollBar.Position := VertScrollBar_Position;
        end;

        BringRedLimitsToFront;

        DoOnClearObjectInspector;

        SetLength(SelectedDesignComponentsVariousKinds, 0);
        SetLength(PastedPanels, 0);
      end;
    finally
      AStringList.Free;
      Sections.Free;
    end;
  finally
    Ini.Free;
  end;
end;


procedure TfrDrawingBoard.ClearSelection;
begin
  SetFocusToAPanel(pnlScroll, nil, []); //unfocuses all selected panels
  FSelectionContent.ClearSelection;

  if Visible then
    scrboxScreen.SetFocus;
end;


procedure TfrDrawingBoard.HideSearchForScreenPanel;
begin
  if pnlSearchForScreen.Visible then
    pnlSearchForScreen.Hide;
end;


procedure TfrDrawingBoard.ClearDrawingBoard;
var
  i: Integer;
  TempColor: TColor;
  TempColorName: string;
begin
  for i := PageControlScreen.PageCount - 1 downto 1 do
    PageControlScreen.Pages[i].Free;

  TempColor := 0;
  TempColorName := '';
  DoOnGetDefaultScreenColor(TempColor, TempColorName);

  SetLength(FAllScreens, 1); //content is reset below
  FAllScreens[0].Name := 'Screen';
  FAllScreens[0].ColorName := TempColorName;
  FAllScreens[0].Color := TempColor;
  FAllScreens[0].Active := True;
  FAllScreens[0].Persisted := False;

  PageControlScreen.Pages[0].Brush.Color := FAllScreens[0].Color;  //does not seem to have any effect when themed
  PageControlScreen.Pages[0].Caption := FAllScreens[0].Name;
  PageControlScreen.Pages[0].ImageIndex := 1;
  PageControlScreen.Pages[0].Repaint;
  pnlScroll.Color := PageControlScreen.Pages[0].Brush.Color;

  pnlSearchForScreen.Visible := False;
  lblCurrentScreen.Caption := 'Current Screen Index: 0';

  DeleteAllPanels(pnlScroll, {$IFDEF FPC}@{$ENDIF}DeleteComponentByPanel);

  sttxtVertical.Left := 470;
  sttxtHorizontal.Top := 272;
  sttxtIntersection.Left := sttxtVertical.Left;
  sttxtIntersection.Top := sttxtHorizontal.Top;

  UnlockScreenEdges;
  pmScreenEdges.Items.Items[1].Checked := True;
end;


procedure TfrDrawingBoard.BringPanelToFront(APanel: TMountPanel);
var
  i: Integer;
  ph: TProjectVisualComponent;
begin
  APanel.BringToFront;

  ph := FAllVisualComponents[APanel.IndexInTProjectVisualComponentArr];
  for i := APanel.IndexInTProjectVisualComponentArr to Length(FAllVisualComponents) - 2 do
  begin
    FAllVisualComponents[i] := FAllVisualComponents[i + 1];
    FAllVisualComponents[i].ScreenPanel.IndexInTProjectVisualComponentArr := i;
    SetPanelGeneralHint(FAllVisualComponents[i].ScreenPanel);
  end;

  ph.ScreenPanel.IndexInTProjectVisualComponentArr := Length(FAllVisualComponents) - 1;
  FAllVisualComponents[Length(FAllVisualComponents) - 1] := ph;
  SetPanelGeneralHint(FAllVisualComponents[Length(FAllVisualComponents) - 1].ScreenPanel);
end;


procedure TfrDrawingBoard.SendPanelToBack(APanel: TMountPanel);
var
  i: Integer;
  ph: TProjectVisualComponent;
begin
  APanel.SendToBack;

  ph := FAllVisualComponents[APanel.IndexInTProjectVisualComponentArr];
  for i := APanel.IndexInTProjectVisualComponentArr downto 1 do
  begin
    FAllVisualComponents[i] := FAllVisualComponents[i - 1];
    FAllVisualComponents[i].ScreenPanel.IndexInTProjectVisualComponentArr := i;
    SetPanelGeneralHint(FAllVisualComponents[i].ScreenPanel);
  end;

  ph.ScreenPanel.IndexInTProjectVisualComponentArr := 0;
  FAllVisualComponents[0] := ph;
  SetPanelGeneralHint(FAllVisualComponents[0].ScreenPanel);
end;


procedure TfrDrawingBoard.UpdateSelectionRectangleSttxt(X, Y: Integer);
var
  ph: Integer;
begin
  FSelX1 := FWinSelX1;
  FSelY1 := FWinSelY1;
  FSelX2 := X;
  FSelY2 := Y;

  if FSelX1 > FSelX2 then
  begin
    ph := FSelX1;
    FSelX1 := FSelX2;
    FSelX2 := ph;
  end;

  if FSelY1 > FSelY2 then
  begin
    ph := FSelY1;
    FSelY1 := FSelY2;
    FSelY2 := ph;
  end;

  sttxtSelectionLeft.Left := FSelX1;
  sttxtSelectionLeft.Top := FSelY1;
  sttxtSelectionLeft.Height := FSelY2 - FSelY1;

  sttxtSelectionTop.Left := FSelX1;
  sttxtSelectionTop.Top := FSelY1;
  sttxtSelectionTop.Width := FSelX2 - FSelX1;

  sttxtSelectionRight.Left := FSelX2;
  sttxtSelectionRight.Top := FSelY1;
  sttxtSelectionRight.Height := FSelY2 - FSelY1;

  sttxtSelectionBottom.Left := FSelX1;
  sttxtSelectionBottom.Top := FSelY2;
  sttxtSelectionBottom.Width := FSelX2 - FSelX1 + sttxtSelectionRight.Width;
end;


procedure TfrDrawingBoard.LockScreenEdges;
begin
  sttxtVertical.Tag := 2;
  sttxtHorizontal.Tag := 2;
  sttxtIntersection.Tag := 2;

  sttxtVertical.Cursor := crDefault;
  sttxtHorizontal.Cursor := crDefault;
  sttxtIntersection.Cursor := crDefault;

  SetScreenEdgesHint;
end;


procedure TfrDrawingBoard.UnlockScreenEdges;
begin
  sttxtVertical.Tag := 0;
  sttxtHorizontal.Tag := 0;
  sttxtIntersection.Tag := 0;

  sttxtVertical.Cursor := crSizeWE;
  sttxtHorizontal.Cursor := crSizeNS;
  sttxtIntersection.Cursor := crSizeNWSE;

  SetScreenEdgesHint;
end;


procedure TfrDrawingBoard.pmComponentPopup(Sender: TObject);
begin
  UpdateComponentPopupMenu(pmComponent.Items);
end;


procedure TfrDrawingBoard.pmScreensPopup(Sender: TObject);
begin
  pnlSearchForScreen.Hide;
  EnableDisableActiveItemsInScreenMenu(pmScreens.Items);
end;


procedure TfrDrawingBoard.AddNewScreen1Click(Sender: TObject);
begin
  if Length(FAllScreens) >= CMaxScreenCount then
  begin
    MessageBoxWrapper(Handle, PChar('The maximum number of screens is limited to ' + IntToStr(CMaxScreenCount)), PChar(Caption), MB_ICONINFORMATION);
    Exit;
  end;
  
  AddNewScreen;
  Modified := True;
end;


procedure TfrDrawingBoard.AddNewScreenandswitchtoit1Click(Sender: TObject);
begin
  if Length(FAllScreens) >= CMaxScreenCount then
  begin
    MessageBoxWrapper(Handle, PChar('The maximum number of screens is limited to ' + IntToStr(CMaxScreenCount)), PChar(Caption), MB_ICONINFORMATION);
    Exit;
  end;
  
  AddNewScreen;
  PageControlScreen.ActivePageIndex := PageControlScreen.PageCount - 1;
  ChagePageControlHandler;
  Modified := True;
end;


procedure TfrDrawingBoard.Addnewscreenandsetitsname1Click(Sender: TObject);
begin
  if Length(FAllScreens) >= CMaxScreenCount then
  begin
    MessageBoxWrapper(Handle, PChar('The maximum number of screens is limited to ' + IntToStr(CMaxScreenCount)), PChar(Caption), MB_ICONINFORMATION);
    Exit;
  end;
  
  AddNewScreen;
  PageControlScreen.ActivePageIndex := PageControlScreen.PageCount - 1;
  ChagePageControlHandler;

  if DoOnEditScreen(FAllScreens[PageControlScreen.ActivePageIndex]) then
  begin
    PageControlScreen.ActivePage.Caption := FAllScreens[PageControlScreen.ActivePageIndex].Name;
    PageControlScreen.ActivePage.Brush.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;
    PageControlScreen.ActivePage.ImageIndex := GetActiveAndPersistedImageIndex(FAllScreens[PageControlScreen.ActivePageIndex]);
    PageControlScreen.ActivePage.Repaint;

    pnlScroll.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;  //set again because of editing color
  end;
  Modified := True;
end;


procedure TfrDrawingBoard.Editscreensettings1Click(Sender: TObject);
var
  Info: string;
begin
  if (PageControlScreen.ActivePageIndex < 0) or (PageControlScreen.ActivePageIndex > Length(FAllScreens) - 1) then
  begin
    Info := 'editing screen ' + IntToStr(PageControlScreen.ActivePageIndex) + ' / ' + IntToStr(Length(FAllScreens));
    raise Exception.Create('Bug in ' + Info + '.');
  end;

  if DoOnEditScreen(FAllScreens[PageControlScreen.ActivePageIndex]) then
  begin
    PageControlScreen.ActivePage.Caption := FAllScreens[PageControlScreen.ActivePageIndex].Name;
    PageControlScreen.ActivePage.Brush.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;
    PageControlScreen.ActivePage.ImageIndex := GetActiveAndPersistedImageIndex(FAllScreens[PageControlScreen.ActivePageIndex]);
    PageControlScreen.ActivePage.Repaint;

    pnlScroll.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;
    Modified := True;
  end;
end;


procedure TfrDrawingBoard.DeleteCurrentScreen1Click(Sender: TObject);
var
  CurrentScreenIndex, i, PanelScreenIndex: Integer;
  WorkPanel: TMountPanel;
begin
  if PageControlScreen.PageCount <= 1 then
  begin
    MessageBoxWrapper(Handle, 'At least one screen has to exist.', PChar(Caption), MB_ICONINFORMATION);
    Exit;
  end;

  if MessageBoxWrapper(Handle, 'Are you sure you want to delete the current screen?', PChar(Caption), MB_ICONQUESTION + MB_YESNO) = IDNO then
    Exit;

  CurrentScreenIndex := PageControlScreen.ActivePageIndex;
  PageControlScreen.Pages[CurrentScreenIndex].Free;
  FSelectionContent.ClearSelection;
  RemoveFocusFromAllPanels(pnlScroll);

  DoOnClearObjectInspector;

  for i := pnlScroll.ComponentCount - 1 downto 0 do
    if pnlScroll.Components[i] is TMountPanel then
    begin
      WorkPanel := pnlScroll.Components[i] as TMountPanel;
      PanelScreenIndex := GetScreenIndexFromPanel(FAllComponents, FAllVisualComponents, WorkPanel);

      if PanelScreenIndex = CurrentScreenIndex then
        DeletePanel(WorkPanel, {$IFDEF FPC}@{$ENDIF}DeleteComponentByPanel)
      else
        if PanelScreenIndex > CurrentScreenIndex then
          SetMountPanelScreenIndex(FAllComponents, FAllVisualComponents, WorkPanel, PanelScreenIndex - 1);
    end;

  for i := CurrentScreenIndex to Length(FAllScreens) - 2 do
    FAllScreens[i] := FAllScreens[i + 1];
  SetLength(FAllScreens, Length(FAllScreens) - 1);  

  ChagePageControlHandler;
  Modified := True;
end;


procedure TfrDrawingBoard.SetImageIndexToActivePage;
begin
  PageControlScreen.ActivePage.ImageIndex := GetActiveAndPersistedImageIndex(FAllScreens[PageControlScreen.ActivePageIndex]);
  PageControlScreen.ActivePage.Repaint;
  PageControlScreen.Repaint;
  Modified := True;
end;


procedure TfrDrawingBoard.Setcurrentscreento1Click(Sender: TObject);
begin
  FAllScreens[PageControlScreen.ActivePageIndex].Active := True;
  SetImageIndexToActivePage;
end;


procedure TfrDrawingBoard.SetcurrentscreentoInactive1Click(Sender: TObject);
begin
  FAllScreens[PageControlScreen.ActivePageIndex].Active := False;
  SetImageIndexToActivePage;
end;


procedure TfrDrawingBoard.Persistcurrentscreen1Click(Sender: TObject);
begin
  FAllScreens[PageControlScreen.ActivePageIndex].Persisted := True;
  SetImageIndexToActivePage;
end;


procedure TfrDrawingBoard.Donotpersistcurrentscreen1Click(Sender: TObject);
begin
  FAllScreens[PageControlScreen.ActivePageIndex].Persisted := False;
  SetImageIndexToActivePage;
end;


procedure TfrDrawingBoard.Searchforscreen1Click(Sender: TObject);
begin
  pnlSearchForScreen.Left := PageControlScreen.Left;
  pnlSearchForScreen.Top := scrboxScreen.Top;
  vstScreens.RootNodeCount := Length(FAllScreens);
  vstScreens.ClearSelection;
  pnlSearchForScreen.Show;
  vstScreens.Repaint;
  lbeScreenName.SetFocus;
end;


procedure TfrDrawingBoard.Paste1Click(Sender: TObject);
begin
  PasteSelectionFromClipboard;
end;


procedure TfrDrawingBoard.SelectAllFromCurrentScreen1Click(Sender: TObject);
begin
  SelectAllPanelsThenUpdateObjectInspector(False);
end;


procedure TfrDrawingBoard.SelectAllFromAllScreens1Click(Sender: TObject);
begin
  SelectAllPanelsThenUpdateObjectInspector(True);
end;


function TfrDrawingBoard.GetOwnerFormFocus: Boolean;
var
  Cnt: Integer;
  AComp: TControl;
begin
  Result := False;
  AComp := Self;
  Cnt := 0;
  repeat
    AComp := AComp.Parent;
    Inc(Cnt);
  until (AComp is TForm) or (Cnt > 100);

  if AComp is TForm then
    Result := (AComp as TForm).Active;
end;


procedure TfrDrawingBoard.pnlScrollClick(Sender: TObject);
begin
  SetFocusToAPanel(pnlScroll, nil, []); //unfocuses all selected panels

  DoOnCancelObjectInspectorEditing;
  FSelectionContent.ClearSelection;
  DoOnClearObjectInspector;
  
  scrboxScreen.SetFocus;
end;


procedure TfrDrawingBoard.pnlScrollMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    FWinSelX1 := X;
    FWinSelY1 := Y;
    
    UpdateSelectionRectangleSttxt(X, Y);

    sttxtSelectionLeft.Show;
    sttxtSelectionRight.Show;
    sttxtSelectionTop.Show;
    sttxtSelectionBottom.Show;
    sttxtSelectionLeft.BringToFront;
    sttxtSelectionRight.BringToFront;
    sttxtSelectionTop.BringToFront;
    sttxtSelectionBottom.BringToFront;
    //scrboxSchematic.AutoScroll := False;

    DoOnAfterSelectAllPanels('', '');
    FDrawingBoardMouseHold := True;
  end;

  if pnlSearchForScreen.Visible then
    pnlSearchForScreen.Hide;
end;


procedure TfrDrawingBoard.pnlScrollMouseEnter(Sender: TObject);
begin
  if FShouldFocusDrawingBoardOnMouseEnter and Visible and GetOwnerFormFocus then
    scrboxScreen.SetFocus;
end;


procedure TfrDrawingBoard.pnlScrollMouseLeave(Sender: TObject);
begin
  //memObjectInspectorDescription.SetFocus;
end;


procedure TfrDrawingBoard.pnlScrollMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  FPasteX := X;
  FPasteY := Y;
  DoOnDrawingBoardMouseMove(X, Y);

  if FDrawingBoardMouseHold then
    UpdateSelectionRectangleSttxt(X, Y);              

  if FShouldFocusDrawingBoardOnMouseEnter and DoOnDrawingBoardCanFocus then
    scrboxScreen.SetFocus;
end;


procedure TfrDrawingBoard.pnlScrollMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FDrawingBoardMouseHold then
  begin
    SelectMountPanelsFromYellowSelection(FAllComponents, FAllVisualComponents, pnlScroll, FSelX1, FSelY1, FSelX2, FSelY2, Shift, FSelectionContent);
    sttxtSelectionLeft.Hide;
    sttxtSelectionRight.Hide;
    sttxtSelectionTop.Hide;
    sttxtSelectionBottom.Hide;

    DoOnClearObjectInspector;
    GenerateListOfVisibleComponents;
  end;
end;


procedure TfrDrawingBoard.Lockscreenedges1Click(Sender: TObject);
begin
  LockScreenEdges;
end;


procedure TfrDrawingBoard.Screenedgesareunlocked1Click(Sender: TObject);
begin
  UnlockScreenEdges;
end;


procedure TfrDrawingBoard.sttxtVerticalMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if pnlSearchForScreen.Visible then
    pnlSearchForScreen.Hide;
    
  if not (ssLeft in Shift) then
    Exit;
    
  GetCursorPos(FMouseDownGlobalPos);
                           
  if not SttxtHold and (sttxtVertical.Tag = 0) then
  begin
    FMouseDownSttxtPos.X := sttxtVertical.Left; //component coordinates on the window
    SttxtHold := True;
    Application.HintHidePause := 5000;
    Application.HintPause := 100;
  end;
end;


procedure TfrDrawingBoard.sttxtVerticalMouseEnter(Sender: TObject);
begin
  if sttxtVertical.Tag = 0 then  //unlocked
    sttxtVertical.Color := clRed;
end;


procedure TfrDrawingBoard.sttxtVerticalMouseLeave(Sender: TObject);
begin
  sttxtVertical.Color := $00B3B3FF;
end;


procedure TfrDrawingBoard.sttxtVerticalMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  NewLeft: Integer;
  Sttxt: TStaticText;
  tp: TPoint;
begin
  if not SttxtHold then
    Exit;

  GetCursorPos(tp);
  if Sender is TStaticText then
  begin
    Sttxt := Sender as TStaticText;
    NewLeft := FMouseDownSttxtPos.X + tp.X - FMouseDownGlobalPos.X;
    if NewLeft <> Sttxt.Left then
      Modified := True;

    Sttxt.Left := Max(10, Min(pnlScroll.Width - 2, NewLeft));
    sttxtIntersection.Left := Sttxt.Left;
    DoOnDisplayScreenSize(sttxtVertical.Left, sttxtHorizontal.Top);

    SetScreenEdgesHint;
  end;
end;


procedure TfrDrawingBoard.sttxtVerticalMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SttxtHold := False;
  Application.HintHidePause := 2500;
  Application.HintPause := 500;
end;


procedure TfrDrawingBoard.sttxtHorizontalMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if pnlSearchForScreen.Visible then
    pnlSearchForScreen.Hide;

  if not (ssLeft in Shift) then
    Exit;

  GetCursorPos(FMouseDownGlobalPos);

  if not SttxtHold and (sttxtHorizontal.Tag = 0) then
  begin
    FMouseDownSttxtPos.Y := sttxtHorizontal.Top; //component coordinates on the window
    SttxtHold := True;
    Application.HintHidePause := 5000;
    Application.HintPause := 100;
  end;
end;


procedure TfrDrawingBoard.sttxtHorizontalMouseEnter(Sender: TObject);
begin
  if sttxtHorizontal.Tag = 0 then  //unlocked
    sttxtHorizontal.Color := clRed;
end;


procedure TfrDrawingBoard.sttxtHorizontalMouseLeave(Sender: TObject);
begin
  sttxtHorizontal.Color := $00B3B3FF;
end;


procedure TfrDrawingBoard.sttxtHorizontalMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  NewTop: Integer;
  Sttxt: TStaticText;
  tp: TPoint;
begin
  if not SttxtHold then
    Exit;

  GetCursorPos(tp);
  if Sender is TStaticText then
  begin
    Sttxt := Sender as TStaticText;
    NewTop := FMouseDownSttxtPos.Y + tp.Y - FMouseDownGlobalPos.Y;

    if NewTop <> Sttxt.Top then
      Modified := True;

    Sttxt.Top := Max(10, Min(pnlScroll.Height - 2, NewTop));
    sttxtIntersection.Top := Sttxt.Top;
    DoOnDisplayScreenSize(sttxtVertical.Left, sttxtHorizontal.Top);

    SetScreenEdgesHint;
  end;
end;


procedure TfrDrawingBoard.sttxtHorizontalMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SttxtHold := False;
  Application.HintHidePause := 2500;
  Application.HintPause := 500;
end;


procedure TfrDrawingBoard.sttxtIntersectionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if pnlSearchForScreen.Visible then
    pnlSearchForScreen.Hide;
    
  if not (ssLeft in Shift) then
    Exit;

  GetCursorPos(FMouseDownGlobalPos);

  if not SttxtHold and (sttxtIntersection.Tag = 0) then
  begin
    FMouseDownSttxtPos.X := sttxtIntersection.Left; //component coordinates on the window
    FMouseDownSttxtPos.Y := sttxtIntersection.Top;
    SttxtHold := True;
    Application.HintHidePause := 5000;
    Application.HintPause := 100;
  end;
end;


procedure TfrDrawingBoard.sttxtIntersectionMouseEnter(Sender: TObject);
begin
  if sttxtIntersection.Tag = 0 then  //unlocked
  begin
    sttxtIntersection.Color := clBlack;
    sttxtVertical.Color := clRed;
    sttxtHorizontal.Color := clRed;
  end;
end;


procedure TfrDrawingBoard.sttxtIntersectionMouseLeave(Sender: TObject);
begin
  sttxtIntersection.Color := clRed;
  sttxtVertical.Color := $00B3B3FF;
  sttxtHorizontal.Color := $00B3B3FF;
end;


procedure TfrDrawingBoard.sttxtIntersectionMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  NewLeft, NewTop: Integer;
  Sttxt: TStaticText;
  tp: TPoint;
begin
  if not SttxtHold then
    Exit;

  GetCursorPos(tp);
  if Sender is TStaticText then
  begin
    Sttxt := Sender as TStaticText;
    NewLeft := FMouseDownSttxtPos.X + tp.X - FMouseDownGlobalPos.X;
    NewTop := FMouseDownSttxtPos.Y + tp.Y - FMouseDownGlobalPos.Y;

    if (NewLeft <> Sttxt.Left) or (NewTop <> Sttxt.Top) then
      Modified := True;

    Sttxt.Left := Max(10, Min(pnlScroll.Width - 2, NewLeft));
    Sttxt.Top := Max(10, Min(pnlScroll.Height - 2, NewTop));

    sttxtVertical.Left := Sttxt.Left;
    sttxtHorizontal.Top := Sttxt.Top;
    DoOnDisplayScreenSize(sttxtVertical.Left, sttxtHorizontal.Top);

    SetScreenEdgesHint;
  end;
end;


procedure TfrDrawingBoard.sttxtIntersectionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SttxtHold := False;
  Application.HintHidePause := 2500;
  Application.HintPause := 500;
end;


procedure TfrDrawingBoard.PageControlScreenChange(Sender: TObject);
begin
  ChagePageControlHandler;
end;


procedure TfrDrawingBoard.PageControlScreenEnter(Sender: TObject);
begin
  if Visible and GetOwnerFormFocus then
    scrboxScreen.SetFocus; //Prevent the tab buttons from having focus. This does not interfere with FPageMouseIn logic
end;


procedure TfrDrawingBoard.PageControlScreenGetImageIndex(Sender: TObject;
  TabIndex: Integer; var ImageIndex: Integer);
begin
  if Length(FAllScreens) = 0 then
  begin
    ImageIndex := 0;
    Exit;
  end;
  
  ImageIndex := GetActiveAndPersistedImageIndex(FAllScreens[TabIndex]);
end;


procedure TfrDrawingBoard.PageControlScreenMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    PageControlScreen.ActivePageIndex := PageControlScreen.IndexOfTabAt(X, Y);
    ChagePageControlHandler;
    PageControlScreen.Repaint;
  end;
end;


procedure TfrDrawingBoard.PageControlScreenMouseEnter(Sender: TObject);
begin
  FPageMouseIn := True;
  if Visible and GetOwnerFormFocus then
    DoOnDrawingBoardRemoveFocus; //remove focus from scrboxScreen
end;


procedure TfrDrawingBoard.PageControlScreenMouseLeave(Sender: TObject);
begin
  FPageMouseIn := False;
end;


procedure TfrDrawingBoard.vstScreensDblClick(Sender: TObject);
var
  Node: PVirtualNode;
begin
  Node := vstScreens.GetFirstSelected;
  if Node <> nil then
  begin
    PageControlScreen.ActivePageIndex := Node^.Index;
    ChagePageControlHandler;
    pnlSearchForScreen.Hide;
  end;
end;


procedure TfrDrawingBoard.vstScreensGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: {$IFnDEF FPC}WideString{$ELSE}string{$ENDIF});
begin
  try
    case Column of
      0: CellText := IntToStr(Node^.Index);
      1: CellText := FAllScreens[Node^.Index].Name;
    end;
  except
    CellText := 'bug';
  end;
end;


procedure TfrDrawingBoard.vstScreensGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  try
    ImageIndex := GetActiveAndPersistedImageIndex(FAllScreens[Node^.Index]);
  except
  end;
end;


procedure TfrDrawingBoard.vstScreensKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  SearchForScreenAllControlsOnKeyDown(Key);
end;


procedure TfrDrawingBoard.lbeScreenNumberChange(Sender: TObject);
begin
  SearchForScreen;
end;


procedure TfrDrawingBoard.lbeScreenNumberKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  SearchForScreenAllControlsOnKeyDown(Key);
end;


procedure TfrDrawingBoard.lbeScreenNumberKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;


procedure TfrDrawingBoard.lbeScreenNameChange(Sender: TObject);
begin
  SearchForScreen;
end;


procedure TfrDrawingBoard.lbeScreenNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  SearchForScreenAllControlsOnKeyDown(Key);
end;


procedure TfrDrawingBoard.Cut1Click(Sender: TObject);
begin
  CutSelectionToClipboard;
end;


procedure TfrDrawingBoard.Copy1Click(Sender: TObject);
begin
  CopySelectionToClipboard;
end;


procedure TfrDrawingBoard.Delete1Click(Sender: TObject);
begin
  if GetOwnerFormFocus and scrboxScreen.Focused then
    if MessageBoxWrapper(Handle, 'Are you sure you want to delete the selected components?', PChar(Application.Title), MB_ICONQUESTION + MB_YESNO) = IDYES then
      DeleteAllSelectedPanelsThenUpdateSelection;
end;


procedure TfrDrawingBoard.BringtoFront1Click(Sender: TObject);
var
  i: Integer;
begin
  if Length(FAllVisualComponents) <= 1 then
    Exit;

  {if FSelectionContent.GetSelectedCount = 0 then
    BringPanelToFront(FRightClickPanel)
  else}
    if FSelectionContent.GetSelectedCount < Length(FAllVisualComponents) then //Do this only if some of the panels are selected.
    begin
      for i:= FSelectionContent.GetSelectedCount - 1 downto 0 do
        BringPanelToFront(FSelectionContent.GetSelectedPanelByIndex(i));

      BringRedLimitsToFront;
      Modified := True;
    end;
end;


procedure TfrDrawingBoard.SendtoBack1Click(Sender: TObject);
var
  i: Integer;
begin
  if Length(FAllVisualComponents) <= 1 then
    Exit;

  {if FSelectionContent.GetSelectedCount = 0 then
    SendPanelToBack(FRightClickPanel)
  else}
    if FSelectionContent.GetSelectedCount < Length(FAllVisualComponents) then //Do this only if some of the panels are selected.
    begin
      for i:= 0 to FSelectionContent.GetSelectedCount - 1 do
        SendPanelToBack(FSelectionContent.GetSelectedPanelByIndex(i));

      Modified := True;  
    end;
end;


procedure TfrDrawingBoard.Refreshselected1Click(Sender: TObject);
var
  i: Integer;
  CurrentPanel: TMountPanel;
begin
  if Length(FAllVisualComponents) = 0 then
    Exit;

  for i:= FSelectionContent.GetSelectedCount - 1 downto 0 do
  begin
    CurrentPanel := FSelectionContent.GetSelectedPanelByIndex(i);
    if CurrentPanel <> nil then
    begin
      try
        DoOnDrawComponentOnPanel(CurrentPanel, FAllComponents, FAllVisualComponents);
      except
        on E: Exception do
        begin
          CurrentPanel.Width := 300;
          CurrentPanel.Image.Width := CurrentPanel.Width;
          CurrentPanel.Image.Canvas.TextOut(0, 0, 'Drawing exception: ');
          CurrentPanel.Image.Canvas.TextOut(0, 15, E.Message);
        end;
      end;
    end;
  end;
end;


procedure TfrDrawingBoard.LoadDrawingBoardFromIniFile(AIni: TMemIniFile; var IndexInSchemaArr: TIntegerDynArray; var tk1, tk2, tk3, tk4: Int64);
begin
  LoadDrawingBoardFromFile(AIni, FAllComponents, FAllVisualComponents, FAllScreens, IndexInSchemaArr, tk1, tk2, tk3, tk4);
end;


procedure TfrDrawingBoard.LoadDrawingBoardFromFile(Ini: TMemIniFile; var ComponentsDest: TDynTFTDesignAllComponentsArr; var AllVisualComponentsDest: TProjectVisualComponentArr; var ScreensDest: TScreenInfoArr; var IndexInSchemaArr: TIntegerDynArray; var tk1, tk2, tk3, tk4: Int64);
var
  i, j, k: Integer;
  n, ScreenCount, FontCount, CreationGroupCount: Integer;
  IndexInSchema: Integer;
  IndexInAllVisual: Integer;
  PropName, CompTypeName: string;
  Error: string;
  AllComponentsCount: Integer;
  X, Y: Integer;
  CompType: Integer;
  CompProperties: TDynTFTDesignPropertyArr;
  FoundX, FoundY, FoundScreenIdx, FoundLocked: Boolean;
  ComponentDefaultSize: TComponentDefaultSize;
  ScreenIdx: Integer;
  Prefix, Suffix: string;
  EdgesLeft: Integer;
  EdgesTop: Integer;
  EdgesLocked: Boolean;
  Locked: Boolean;
  TkInt64_1, TkInt64_2, TkDiff: Int64;
  LoadTime, DisplayTime: Int64;
  LoadTimeStr, DisplayTimeStr: string;
  ErrMsg: string;
  InstanceCount: Integer;
  TempCategoryIndex, TempComponentIndex: Integer;
begin
  Error := '';

  QueryPerformanceCounter(TkInt64_1);
  n := Ini.ReadInteger('ComponentTypes', 'Count', 0);

  if n > Length(ComponentsDest) then
  begin
    MessageBox(Handle, PChar('This project contains more component types (' + IntToStr(n) + ') than are currently installed in schema files (' + IntToStr(Length(ComponentsDest)) + '). Out of index component types will be ignored.' + #13#10 + 'Every time you see this message, please restart the application to avoid creating bad projects.'), PChar(Caption), MB_ICONINFORMATION);
    n := Length(ComponentsDest);
  end;

  n := Length(ComponentsDest);

  //SetLength(ComponentsDest, n); //Do not uncomment this line. It has to stay commented, to show that this length should not be touched here.   ComponentsDest comes from installed component. It should not be modified.
  SetLength(IndexInSchemaArr, n);

  AllComponentsCount := 0;
  for i := 0 to n - 1 do  //for each component type
  begin
    CompTypeName := {Ini.ReadString('ComponentTypes', 'Component_' + IntToStr(i) + '_Name', 'UnknownComponentType');  //to be replaced with} ComponentsDest[i].Schema.ComponentTypeName;  //- this requires more fixes
    IndexInSchema := -1;
    if ComponentsDest[i].Schema.ComponentTypeName <> CompTypeName then
    begin
      for j := 0 to n - 1 do
        if ComponentsDest[j].Schema.ComponentTypeName = CompTypeName then
        begin
          IndexInSchema := j;
          Break;
        end;
    end
    else
      IndexInSchema := i;

    //if IndexInSchema = -1 then
    //  raise Exception.Create('Component type not found: ' + CompTypeName + #13#10 + 'It should be installed in schema files in order to be used.');

    IndexInSchemaArr[i] := IndexInSchema;

    if IndexInSchema = -1 then //component type not found in schema. Ignoring loading.
    begin
      Error := Error + 'Component type not found: ' + CompTypeName; 
      Continue;
    end;
                                                        
    InstanceCount := Ini.ReadInteger(CompTypeName, 'Count', 0);
    SetLength(ComponentsDest[IndexInSchema].DesignComponentsOneKind, InstanceCount);
    Inc(AllComponentsCount, Length(ComponentsDest[IndexInSchema].DesignComponentsOneKind));

    for j := 0 to Length(ComponentsDest[IndexInSchema].DesignComponentsOneKind) - 1 do
    begin
      Prefix := 'Comp_' + IntToStr(j) + '_';
      ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].ObjectName := Ini.ReadString(CompTypeName, Prefix + 'ObjectName', 'UnknownName');
      ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CreatedAtStartup := Ini.ReadString(CompTypeName, Prefix + 'CreatedAtStartup', 'True') = 'True';
      ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].HasVariableInGUIObjects := Ini.ReadString(CompTypeName, Prefix + 'HasVariableInGUIObjects', 'True') = 'True';

      SetLength(ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomProperties, Length(ComponentsDest[IndexInSchema].Schema.Properties));
      SetLength(ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomEvents, Length(ComponentsDest[IndexInSchema].Schema.Events));
                                                                                            
      for k := 0 to Length(ComponentsDest[IndexInSchema].Schema.Properties) - 1 do
      begin
        PropName := ComponentsDest[IndexInSchema].Schema.Properties[k].PropertyName;
        ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomProperties[k].PropertyName := PropName;

        if Pos('ARRAY', UpperCase(ComponentsDest[IndexInSchema].Schema.Properties[k].PropertyDataType)) > 0 then
          ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue := FastReplace_45ToReturn(Ini.ReadString(CompTypeName, Prefix + PropName, ''))
        else
          ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue := Ini.ReadString(CompTypeName, Prefix + PropName, '');
      end;

      for k := 0 to Length(ComponentsDest[IndexInSchema].Schema.Events) - 1 do
      begin
        PropName := ComponentsDest[IndexInSchema].Schema.Events[k].PropertyName;
        ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomEvents[k].PropertyName := PropName;

        if Pos('ARRAY', UpperCase(ComponentsDest[IndexInSchema].Schema.Events[k].PropertyDataType)) > 0 then
          ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomEvents[k].PropertyValue := FastReplace_45ToReturn(Ini.ReadString(CompTypeName, Prefix + PropName, ''))
        else
          ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomEvents[k].PropertyValue := Ini.ReadString(CompTypeName, Prefix + PropName, '');

        DoOnAddNewHandlerToAllHandlersByHandlerType(ComponentsDest[IndexInSchema].Schema.Events[k].PropertyDataType, ComponentsDest[IndexInSchema].DesignComponentsOneKind[j].CustomEvents[k].PropertyValue);
      end;
    end;
  end; //for each component

  SetLength(AllVisualComponentsDest, AllComponentsCount);

  for i := 0 to n - 1 do  //for each component type
  begin
    IndexInSchema := IndexInSchemaArr[i];
    if IndexInSchema > -1 then
    begin
      for j := 0 to Length(ComponentsDest[IndexInSchema].DesignComponentsOneKind) - 1 do
      begin
        Prefix := 'Comp_' + IntToStr(j) + '_';
        IndexInAllVisual := Ini.ReadInteger(ComponentsDest[i].Schema.ComponentTypeName, Prefix + 'GlobalIndex', -1);
        if (IndexInAllVisual < 0) or (IndexInAllVisual > AllComponentsCount - 1) then
        begin
          ErrMsg := 'Global index, read from project, is out of bounds: GlobalCompIndex=' + IntToStr(IndexInAllVisual) + ' / AllCompCount=' + IntToStr(AllComponentsCount) + ' / CompType=' + IntToStr(i) + ' / TypeCompIndex=' + IntToStr(j) + '  CompTypeName=' + ComponentsDest[i].Schema.ComponentTypeName + '.' + #13#10;
          ErrMsg := ErrMsg + 'This may happen when the number of installed components does not match the number of components in project or there are installed components, which are not indexed in project.';
          ErrMsg := ErrMsg + ' Also, it may be caused by having multiple plugins with the same components (duplicates) or the file was saved with a different plugin order (a limitation of the current version of the application).' + #13#10;
          ErrMsg := ErrMsg + 'For now, you can open the project (.dyntftcg file) with a text editor and look for the "ComponentTypes" section.';
          ErrMsg := ErrMsg + ' Either make sure the installed plugins are installed in the proper order to match the component order from that section, or manually edit the section to have the components in the order they are defined by installed plugins.' + #13#10;
          ErrMsg := ErrMsg + 'You may have to restart the application now, to properly clear the internal structures.';
          raise Exception.Create(ErrMsg);
        end;

        AllVisualComponentsDest[IndexInAllVisual].IndexInTDynTFTDesignAllComponentsArr := IndexInSchema;
        AllVisualComponentsDest[IndexInAllVisual].IndexInDesignComponentOneKindArr := j;
      end;
    end;
  end;

  QueryPerformanceCounter(TkInt64_2);
  TkDiff := TkInt64_2 - TkInt64_1;
  tk1 := tk1 + TkDiff;

  QueryPerformanceCounter(TkInt64_1);
  pnlScroll.Visible := False;
  try
    //create panels by their Z order  (index in AllVisualComponentsDest)
    for i := 0 to Length(AllVisualComponentsDest) - 1 do
    begin
      X := 10;
      Y := 10;
      ScreenIdx := 0;
      Locked := False;
      CompType := AllVisualComponentsDest[i].IndexInTDynTFTDesignAllComponentsArr;
      CompProperties := ComponentsDest[CompType].DesignComponentsOneKind[AllVisualComponentsDest[i].IndexInDesignComponentOneKindArr].CustomProperties;
      FoundX := False;
      FoundY := False;
      FoundScreenIdx := False;
      FoundLocked := False;
      
      ComponentDefaultSize.MinWidth := 2;
      ComponentDefaultSize.MaxWidth := 0;
      ComponentDefaultSize.MinHeight := 2;
      ComponentDefaultSize.MaxHeight := 0;
      ComponentDefaultSize.Width := -1;
      ComponentDefaultSize.Height := -1;
  
      for j := 0 to Length(CompProperties) - 1 do
      begin
        if not FoundX then
          if CompProperties[j].PropertyName = 'Left' then
          begin
            X := StrToIntDef(CompProperties[j].PropertyValue, X);
            FoundX := True;
            Continue;
          end;

        if not FoundY then
          if CompProperties[j].PropertyName = 'Top' then
          begin
            Y := StrToIntDef(CompProperties[j].PropertyValue, Y);
            FoundY := True;
          end;

        if not FoundScreenIdx then
          if CompProperties[j].PropertyName = 'ScreenIndex' then
          begin
            ScreenIdx := StrToIntDef(CompProperties[j].PropertyValue, ScreenIdx);
            FoundScreenIdx := True;
          end;

        if not FoundLocked then
          if CompProperties[j].PropertyName = 'Locked' then
          begin
            Locked := CompProperties[j].PropertyValue = 'True';
            FoundLocked := True;
          end;

        {if FoundX and FoundY then
          Break;}
        GetComponentDefaultSize(CompProperties, j, ComponentDefaultSize);

        DoOnSetCustomPropertyValueOnLoading(CompProperties[j].PropertyName, CompType, CompProperties[j].PropertyValue);
      end;   //for j

      DoOnGetComponentIndexFromPlugin(CompType, TempCategoryIndex, TempComponentIndex);  ///////////////////////////////////////// verify if CompType has the proper value here
      AllVisualComponentsDest[i].ScreenPanel := CreateBasePanel(pnlScroll, X, Y, CompType, True, True, clNavy, i, TempCategoryIndex, TempComponentIndex);
      AllVisualComponentsDest[i].ScreenPanel.Caption := ComponentsDest[CompType].DesignComponentsOneKind[AllVisualComponentsDest[i].IndexInDesignComponentOneKindArr].ObjectName;

      SetPanelDefaultSize(AllVisualComponentsDest[i].ScreenPanel, ComponentDefaultSize);
      if Locked then
        AllVisualComponentsDest[i].ScreenPanel.Cursor := crNo;

      SetPanelGeneralHint(AllVisualComponentsDest[i].ScreenPanel, Locked);
      AllVisualComponentsDest[i].ScreenPanel.ShowHint := True;
      //AllVisualComponentsDest[i].ScreenPanel.Repaint;
      AllVisualComponentsDest[i].ScreenPanel.Visible := ScreenIdx = 0;

      DoOnAddItemToSelCompListInOI(ComponentsDest[CompType].DesignComponentsOneKind[AllVisualComponentsDest[i].IndexInDesignComponentOneKindArr].ObjectName);
    end; //for i in visual components
  finally
    pnlScroll.Visible := True;
  end;

  QueryPerformanceCounter(TkInt64_2);
  TkDiff := TkInt64_2 - TkInt64_1;
  tk2 := tk2 + TkDiff;

  QueryPerformanceCounter(TkInt64_1);
  ScreenCount := Ini.ReadInteger('Screens', 'Count', 0);
  EdgesLeft := Ini.ReadInteger('Screens', 'Width', 470);
  EdgesTop := Ini.ReadInteger('Screens', 'Height', 272);
  EdgesLocked := Ini.ReadBool('Screens', 'EdgesLocked', False);
  QueryPerformanceCounter(TkInt64_2);
  TkDiff := TkInt64_2 - TkInt64_1;
  tk3 := tk3 + TkDiff;

  QueryPerformanceCounter(TkInt64_1);
  sttxtVertical.Left := EdgesLeft;
  sttxtHorizontal.Top := EdgesTop;
  sttxtIntersection.Left := sttxtVertical.Left;
  sttxtIntersection.Top := sttxtHorizontal.Top;
      
  if EdgesLocked then  
  begin
    LockScreenEdges;
    pmScreenEdges.Items.Items[0].Checked := True;
  end
  else
  begin
    UnlockScreenEdges;
    pmScreenEdges.Items.Items[1].Checked := True;
  end;

  if PageControlScreen.PageCount = 1 then
    PageControlScreen.Pages[0].Destroy;
  QueryPerformanceCounter(TkInt64_2);
  TkDiff := TkInt64_2 - TkInt64_1;
  tk4 := tk4 + TkDiff;

  for i := 0 to ScreenCount - 1 do  //for each screen
  begin
    QueryPerformanceCounter(TkInt64_1);
    AddNewScreen;
    QueryPerformanceCounter(TkInt64_2);
    TkDiff := TkInt64_2 - TkInt64_1;
    tk4 := tk4 + TkDiff;

    QueryPerformanceCounter(TkInt64_1);
    Suffix := IntToStr(i);
    ScreensDest[i].Name := Ini.ReadString('Screens', 'Screen_' + Suffix + '_Name', '');
    ScreensDest[i].Color := Ini.ReadInteger('Screens', 'Screen_' + Suffix + '_Color', clWhite);
    ScreensDest[i].ColorName := Ini.ReadString('Screens', 'Screen_' + Suffix + '_ColorName', 'CL_DynTFTScreen_Background');
    ScreensDest[i].Active := Ini.ReadBool('Screens', 'Screen_' + Suffix + '_Active', True);
    ScreensDest[i].Persisted := Ini.ReadBool('Screens', 'Screen_' + Suffix + '_Persisted', False);
    QueryPerformanceCounter(TkInt64_2);
    TkDiff := TkInt64_2 - TkInt64_1;
    tk3 := tk3 + TkDiff;

    QueryPerformanceCounter(TkInt64_1);
    ScreensDest[i].Color := DoOnLookupColorConstantInBaseSchema(ScreensDest[i].ColorName, ScreensDest[i].Color);
    PageControlScreen.Pages[i].Caption := ScreensDest[i].Name;
    PageControlScreen.Pages[i].Brush.Color := ScreensDest[i].Color;
    PageControlScreen.Pages[i].ImageIndex := GetActiveAndPersistedImageIndex(ScreensDest[i]);
    PageControlScreen.Pages[i].Repaint;
    QueryPerformanceCounter(TkInt64_2);
    TkDiff := TkInt64_2 - TkInt64_1;
    tk4 := tk4 + TkDiff;
  end;

  pnlScroll.Color := FAllScreens[0].Color;  //duration not measured

  if Error <> '' then
    raise Exception.Create(Error);
end;


procedure TfrDrawingBoard.SaveDrawingBoardToFile(AStringList: TSaveFileStringList);
begin
  SaveDrawingBoardContent(AStringList, FAllComponents, FAllVisualComponents, FAllScreens);
end;


procedure TfrDrawingBoard.scrboxScreenMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  Factor: Integer;
begin
  if ssCtrl in Shift then
    Factor := 1
  else
    Factor := 3;

  if ssShift in Shift then
    scrboxScreen.HorzScrollBar.Position := scrboxScreen.HorzScrollBar.Position - WheelDelta div Factor
  else
    scrboxScreen.VertScrollBar.Position := scrboxScreen.VertScrollBar.Position - WheelDelta div Factor;
    
  Handled := True;  
end;


procedure TfrDrawingBoard.SaveDrawingBoardContent(AStringList: TSaveFileStringList; var ComponentsSrc: TDynTFTDesignAllComponentsArr; var AllVisualComponentsSrc: TProjectVisualComponentArr; var ScreensSrc: TScreenInfoArr);
var
  i, j, k, n: Integer;
  PropName: string;
  Prefix, Suffix: string;
begin
  n := Length(ComponentsSrc);
  AStringList.Add('[ComponentTypes]');
  AStringList.Add('Count=' + IntToStr(n));

  for i := 0 to n - 1 do  //for each component type
    AStringList.Add('Component_' + IntToStr(i) + '_Name=' + ComponentsSrc[i].Schema.ComponentTypeName);

  AStringList.Add('');
    
  for i := 0 to n - 1 do  //for each component type
  begin
    AStringList.Add('[' + ComponentsSrc[i].Schema.ComponentTypeName + ']');
    AStringList.Add('Count=' + IntToStr(Length(ComponentsSrc[i].DesignComponentsOneKind)));

    for j := 0 to Length(ComponentsSrc[i].DesignComponentsOneKind) - 1 do
    begin
      Prefix := 'Comp_' + IntToStr(j) + '_';
        
      AStringList.Add(Prefix + 'GlobalIndex=' + IntToStr(ComponentsSrc[i].DesignComponentsOneKind[j].IdxInVisualAtSave));  //index in visual
      {AStringList.Add(Prefix + 'ObjectName=' + ComponentsSrc[i].DesignComponentsOneKind[j].ObjectName);
      AStringList.Add(Prefix + 'CreatedAtStartup=' + BoolToStr(ComponentsSrc[i].DesignComponentsOneKind[j].CreatedAtStartup, True));
      AStringList.Add(Prefix + 'HasVariableInGUIObjects=' + BoolToStr(ComponentsSrc[i].DesignComponentsOneKind[j].HasVariableInGUIObjects, True)); }

      for k := 0 to Length(ComponentsSrc[i].DesignComponentsOneKind[j].CustomProperties) - 1 do
      begin
        PropName := Prefix + ComponentsSrc[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyName;
        if ComponentsSrc[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyName = 'Plugin' then
          AStringList.Add(PropName + '=') //discard value, because it contains plugin path
        else
        begin
          if Pos('ARRAY', UpperCase(ComponentsSrc[i].Schema.Properties[k].PropertyDataType)) > 0 then
            AStringList.Add(PropName + '=' + FastReplace_ReturnTo45(ComponentsSrc[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue))
          else
            AStringList.Add(PropName + '=' + ComponentsSrc[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue);
        end;
      end;

      for k := 0 to Length(ComponentsSrc[i].DesignComponentsOneKind[j].CustomEvents) - 1 do
      begin
        PropName := Prefix + ComponentsSrc[i].DesignComponentsOneKind[j].CustomEvents[k].PropertyName;

        if Pos('ARRAY', UpperCase(ComponentsSrc[i].Schema.Events[k].PropertyDataType)) > 0 then
          AStringList.Add(PropName + '=' + FastReplace_ReturnTo45(ComponentsSrc[i].DesignComponentsOneKind[j].CustomEvents[k].PropertyValue))
        else
          AStringList.Add(PropName + '=' + ComponentsSrc[i].DesignComponentsOneKind[j].CustomEvents[k].PropertyValue);
      end;
    end; //for j

    AStringList.Add('');
  end;  //for components

  //AStringList.Add('');
  AStringList.Add('[Screens]');

  n := Length(ScreensSrc);
  AStringList.Add('Count=' + IntToStr(n));
  AStringList.Add('Width=' + IntToStr(sttxtVertical.Left));
  AStringList.Add('Height=' + IntToStr(sttxtHorizontal.Top));
  AStringList.Add('EdgesLocked=' + IntToStr(Ord(sttxtIntersection.Tag <> 0)));

  for i := 0 to n - 1 do  //for each screen
  begin
    Suffix := IntToStr(i);
    AStringList.Add('Screen_' + Suffix + '_Name=' + ScreensSrc[i].Name);
    AStringList.Add('Screen_' + Suffix + '_Color=' + IntToStr(ScreensSrc[i].Color));
    AStringList.Add('Screen_' + Suffix + '_ColorName=' + ScreensSrc[i].ColorName);
    AStringList.Add('Screen_' + Suffix + '_Active=' + IntToStr(Ord(ScreensSrc[i].Active)));
    AStringList.Add('Screen_' + Suffix + '_Persisted=' + IntToStr(Ord(ScreensSrc[i].Persisted)));
  end;

  AStringList.Add('');
end;


procedure TfrDrawingBoard.UpdateIdexesInVisualStructureAtSave;
begin
  UpdateIdxInVisualAtSave(FAllComponents, FAllVisualComponents);
end;


procedure TfrDrawingBoard.DrawComponentOnPanelOnDemand(APanel: TMountPanel);
begin
  DoOnDrawComponentOnPanel(APanel, FAllComponents, FAllVisualComponents);
end;


procedure TfrDrawingBoard.RepaintAllComponents;
var
  i: Integer;
begin
  pnlScroll.Visible := False;
    try
      for i := 0 to pnlScroll.ComponentCount - 1 do
        if pnlScroll.Components[i] is TMountPanel then
          DoOnDrawComponentOnPanel(pnlScroll.Components[i] as TMountPanel, FAllComponents, FAllVisualComponents);
    finally
      pnlScroll.Visible := True;
    end;
end;


function TfrDrawingBoard.GetScreenNameByIndex(AIndex: Integer): string;
begin
  Result := FAllScreens[AIndex].Name;
end;


procedure TfrDrawingBoard.UpdateComponentUsageByProperty(const ASearchedPropertyUpperCaseName: string; var AAllPropertyGroups: TPropertyGroupArr);
var
  i, j, k, ii, kk: Integer;
  PropVal, ObjName: string;
begin
  for ii := 0 to Length(AAllPropertyGroups) - 1 do
  begin
    AAllPropertyGroups[ii].UsedCount := 0;
    AAllPropertyGroups[ii].UsedComponents := '';
  end;

  for i := 0 to Length(FAllComponents) - 1 do
    for j := 0 to Length(FAllComponents[i].DesignComponentsOneKind) - 1 do
    begin
      ObjName := '';
      for k := 0 to Length(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties) - 1 do
      begin
        if FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyName = 'ObjectName' then
          ObjName := FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue;

        if UpperCase(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyName) = ASearchedPropertyUpperCaseName then
        begin
          PropVal := Trim(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue);
          for ii := 0 to Length(AAllPropertyGroups) - 1 do
            if AAllPropertyGroups[ii].GroupName = PropVal then
            begin
              Inc(AAllPropertyGroups[ii].UsedCount);
              if ObjName <> '' then
                AAllPropertyGroups[ii].UsedComponents := AAllPropertyGroups[ii].UsedComponents + ObjName + #13#10
              else
                for kk := k + 1 to Length(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties) - 1 do
                  if FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyName = 'ObjectName' then
                  begin
                    ObjName := FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue;
                    if ObjName <> '' then
                      AAllPropertyGroups[ii].UsedComponents := AAllPropertyGroups[ii].UsedComponents + ObjName + #13#10
                  end;
            end;

          Break;
        end; //CUpperCaseManGroup
      end; //for k
    end; //for j
end;


procedure TfrDrawingBoard.UpdateAllComponentsToNewPropertyValue(const ASearchedPropertyUpperCaseName: string; OldValue, NewValue: string);
var
  i, j, k: Integer;
  PropVal: string;
begin
  for i := 0 to Length(FAllComponents) - 1 do
    for j := 0 to Length(FAllComponents[i].DesignComponentsOneKind) - 1 do
    begin
      for k := 0 to Length(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties) - 1 do
        if UpperCase(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyName) = ASearchedPropertyUpperCaseName then
        begin
          PropVal := Trim(FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue);
          if PropVal = OldValue then
            FAllComponents[i].DesignComponentsOneKind[j].CustomProperties[k].PropertyValue := NewValue;
        end;
    end; //for j
end;


procedure TfrDrawingBoard.PopulateItemsWithConstantsByPropertyName(Items: TStrings; PropertyName, SpacePrefix: string);
var
  i, j: Integer;
  UpperCasePropertyName: string;
  Found: Boolean;
begin
  UpperCasePropertyName := UpperCase(PropertyName);
  for i := 0 to Length(FAllComponents) - 1 do   //all component types
  begin
    Found := False;
    for j := 0 to Length(FAllComponents[i].Schema.Properties) - 1 do
      if UpperCase(FAllComponents[i].Schema.Properties[j].PropertyName) = UpperCasePropertyName then
      begin
        Found := True;
        Break;
      end;

    if Found then
    begin
      for j := 0 to Length(FAllComponents[i].Schema.Constants) - 1 do
        Items.Add(SpacePrefix + FAllComponents[i].Schema.Constants[j].ConstantName);
        
      //Break;
    end;
  end;
end;


procedure TfrDrawingBoard.ResetCurrentSelectionRectangle;
begin
  FCompSelectionMinLeft := pnlScroll.Width; //avoid maxint here, because it can draw very long lines. Use something reasonable, like the DrawingBoard
  FCompSelectionMinTop := pnlScroll.Height; //avoid maxint here, because it can draw very long lines. Use something reasonable, like the DrawingBoard
  FCompSelectionMaxRight := 0;
  FCompSelectionMaxBottom := 0;
end;


procedure TfrDrawingBoard.SetCurrentSelectionRectangleByPanel(APanel: TMountPanel);
begin
  FCompSelectionMinLeft := Min(FCompSelectionMinLeft, APanel.Left);
  FCompSelectionMinTop := Min(FCompSelectionMinTop, APanel.Top);
  FCompSelectionMaxRight := Max(FCompSelectionMaxRight, APanel.Left + APanel.Width - 1);
  FCompSelectionMaxBottom := Max(FCompSelectionMaxBottom, APanel.Top + APanel.Height - 1);
end;


function TfrDrawingBoard.IsDraggingBothScreenEdges: Boolean;
begin
  Result := SttxtHold and (sttxtIntersection.Tag = 0);
end;


procedure TfrDrawingBoard.RecolorScreensAndComponentsByTheme;
var
  i: Integer;
begin
  for i := 0 to Length(FAllScreens) - 1 do
    if FAllScreens[i].ColorName <> 'Custom...' then
      FAllScreens[i].Color := DoOnResolveColorConst(FAllScreens[i].ColorName);

  //PageControlScreen.ActivePage.Brush.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;

  for i := 0 to PageControlScreen.PageCount - 1 do
    PageControlScreen.Pages[i].Brush.Color := FAllScreens[i].Color;

  PageControlScreen.ActivePage.Repaint;
  pnlScroll.Color := FAllScreens[PageControlScreen.ActivePageIndex].Color;

  for i := 0 to pnlScroll.ComponentCount - 1 do
    if pnlScroll.Components[i] is TMountPanel then
    begin
      DoOnDrawComponentOnPanel(pnlScroll.Components[i] as TMountPanel, FAllComponents, FAllVisualComponents);
      (pnlScroll.Components[i] as TMountPanel).Image.Repaint;
    end;
end;


procedure TfrDrawingBoard.HandleOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);
begin
  DoOnUpdateSpecialProperty(APropertyIndex, ADesignComponentInAll, APropertyName, APropertyNewValue);
end;

end.

