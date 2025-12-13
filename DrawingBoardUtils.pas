{
    Copyright (C) 2023 VCC
    creation date: Jul 2023  (parts of the code: 2019, from DynTFTCodeGen)
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



unit DrawingBoardUtils;

interface

uses
  Classes, Controls, ExtCtrls, StdCtrls, Graphics, Forms, VirtualTrees,
  Menus,
  DrawingBoardDataTypes, DynTFTCodeGenSharedDataTypes;

type
  TDeleteDynTFTOwnerCallback = procedure(APanel: TMountPanel) of object;
  TOnUpdateSpecialProperty = procedure(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string) of object;

  TSelectionOperation = (soAdd, soRemove, soUpdateProp, soSetSelToComponent);
  TResetMixedValues = (rmvReset, rmvLeave);

  
  TSelectionContent = class(TComponent)
  private
    //FSelectedRefComps: TRefPanelComponentArr;
    FSelectedPanels: TMountPanelArr;

    FDisplayedProperties: TDynTFTExtendedDesignPropertyArr;
    FDisplayedEvents: TDynTFTExtendedDesignPropertyArr;
    FSelectedTypes: array of string;

    FOnUpdateSpecialProperty: TOnUpdateSpecialProperty;

    procedure DoOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);

    function GetTypeIndexInSelection(NewType: string): Integer;
    procedure AddTypeToSelection(NewType: string);
    //procedure RemoveTypeFromSelection(NewType: string);
    //function CountSelectedComponentsByType(AType: string): Integer;

    //function GetEventIndexFromComponentByType(ComponentTypeIndex: Integer; EventName: string): Integer; //Returns -1 if component does not have that event

    procedure PerformAddToSelOperation(var PropertiesOrEventsSchemaArr: TComponentPropertiesSchemaArr; var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; var AddedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr; TypeIndexInSel: Integer);
    //procedure PerformRemoveFromSelOperation(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; var RemovedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr; TypeIndexInSel, SelectedComponentsCountOfRemovingType: Integer);
    
    procedure UpdateDisplayedProperties(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentType: string; Operation: TSelectionOperation; VisualComponent: TProjectVisualComponent);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddPanelToSelected(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
    procedure RemovePanelFromSelected(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
    procedure UpdateDisplayedPanelProperties(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
    procedure SetDisplayedPanelProperties(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
    procedure ClearSelection;

    function GetPropertyIndexByName(ObjectInspectorType: Integer; PropertyName: string): Integer;
    function GetPropertyName(ObjectInspectorType: Integer; Index: Integer): string;
    function GetPropertyValue(ObjectInspectorType: Integer; Index: Integer): string;
    function GetPropertyDataType(ObjectInspectorType: Integer; Index: Integer): string;
    function GetPropertyAvailableOnCompilerDirectives(ObjectInspectorType: Integer; Index: Integer): string;
    function GetPropertyDescription(ObjectInspectorType: Integer; Index: Integer): string;
    function GetPropertyDesignTimeOnly(ObjectInspectorType: Integer; Index: Integer): string;
    function GetPropertyReadOnly(ObjectInspectorType: Integer; Index: Integer): string;

    procedure UpdateComponentsWithPropertyValue(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ObjectInspectorType: Integer; IndexInSel: Integer; NewValue: string);

    function GetDisplayedPropertiesCount: Integer; //used by ObjectInspector
    function GetDisplayedEventsCount: Integer;    //used by ObjectInspector

    function GetSelectedCount: Integer;
    function GetSelectedPanelByIndex(AIndex: Integer): TMountPanel;
    function PanelInSelection(APanel: TMountPanel): Boolean;

    property OnUpdateSpecialProperty: TOnUpdateSpecialProperty write FOnUpdateSpecialProperty;
    //Do not cache indexes for AllVisualComponents array, because they will change when calling "Bring to Front" and "Send to Back" !!!
  end;


  TSaveFileStringList = class(TObject)
  private
    FString: string;
  public
    constructor Create;
    procedure Add(s: string);
    procedure SaveToFile(AFileName: string);  
  end;


const
  CObjectInspector_Undefined = -1;
  CObjectInspector_PropertySel = 0; //used by TSelectionContent to return properties
  CObjectInspector_EventSel = 1;    //used by TSelectionContent to return events

  CMixedValues = '(...)';
  CReinitDisplayedPropertyValue = 'x0.{|_._|).0x';


procedure SetFocusToAPanel(AOwnerObject: TComponent; APanel: TMountPanel; ShifState: TShiftState);
procedure RemoveFocusFromAPanel(APanel: TMountPanel);
procedure RemoveFocusFromAllPanels(AScrollPanel: TPanel);
procedure SetMountPanelCoords(APanel: TMountPanel; ALeft, ATop: Integer);
procedure SelectMountPanelsFromYellowSelection(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; OwnerObject: TComponent; FSelX1, FSelY1, FSelX2, FSelY2: Integer; ShifState: TShiftState; SelectionContent: TSelectionContent);

procedure DeleteComponentFrom_TDynTFTDesignAllComponentsArr(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentTypeIndex, IndexInDesignComponentOneKind: Integer);
procedure DeleteComponentFrom_TProjectVisualComponentArr(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentTypeIndex, IndexInTProjectVisualComponentArr: Integer);

procedure DeletePanel(PanelToDelete: TMountPanel; DeleteDynTFTOwnerCallback: TDeleteDynTFTOwnerCallback);
procedure DeleteSelectedPanels(OwnerObject: TComponent; DeleteDynTFTOwnerCallback: TDeleteDynTFTOwnerCallback);
procedure DeleteAllPanels(OwnerObject: TComponent; DeleteDynTFTOwnerCallback: TDeleteDynTFTOwnerCallback);
procedure SelectAllPanels(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; OwnerObject: TComponent; SelectionContent: TSelectionContent; OnlyScreenIndex: Integer);
function SelectedPanelsExist(OwnerObject: TComponent): Boolean;

procedure UpdateComponentWidthAndHeightFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
procedure UpdateComponentLeftAndTopFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
procedure UpdateComponentScreenIndex(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel; NewScreenIndex: Integer);
procedure UpdateComponentPropertyByNameAndPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel; PropertyName: string; NewValue: string);

function GetVisualComponentFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel): TProjectVisualComponent;
function GetTypeFromVisualComponent(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; AVisualComponent: TProjectVisualComponent): string;
function GetPropertyIndexInSchema(var SchemaProperties: TComponentPropertiesSchemaArr; PropertyName: string): Integer;
function GetPropertyIndexInSchemaFromComponentByType(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentTypeIndex: Integer; PropertyName: string): Integer; //Returns -1 if component does not have that property
function GetPropertyValueInPropertiesByNameAndPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; PropertyName: string; APanel: TMountPanel): string;

function GetScreenIndexFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel): Integer;
procedure SetMountPanelScreenIndex(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel; NewScreenIndex: Integer);


function ComponentInstanceExistsByName(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; InstanceName: string): Boolean;

procedure GetComponentDefaultSize(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; var ComponentDefaultSize: TComponentDefaultSize);
procedure AdjustComponentPosition(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; NewLeft, NewTop: Integer);
procedure AdjustComponentName(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; NewName: string);
procedure AdjustComponentScreenIndex(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; NewScreenIndex: Integer);
procedure SetPanelDefaultSize(APanel: TMountPanel; ComponentDefaultSize: TComponentDefaultSize);

procedure UpdateIdxInVisualAtSave(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr);

function FastReplace_ReturnTo45(s: string): string;
function FastReplace_45ToReturn(s: string): string;
function FastReplace_ReturnToCSV(s: string): string;
function Ascii127_To_Ascii32(s: string): string;


implementation


uses
  SysUtils, Math, DynTFTSharedUtils;


procedure SetLabelVisibility(ALabel: TLabel; AVisible: Boolean);
begin
  if ALabel <> nil then
    ALabel.Visible := AVisible;
end;


procedure BringLabelToFront(ALabel: TLabel);
begin
  if ALabel <> nil then
    ALabel.BringToFront;
end;


procedure UpdatePanelCorners(APanel: TMountPanel; AVisible: Boolean);
begin
  if not Assigned(APanel) then
    Exit;

  SetLabelVisibility(APanel.TopLeftLabel, AVisible);
  SetLabelVisibility(APanel.TopRightLabel, AVisible);
  SetLabelVisibility(APanel.BotLeftLabel, AVisible);
  SetLabelVisibility(APanel.BotRightLabel, AVisible);

  SetLabelVisibility(APanel.LeftLabel, AVisible);
  SetLabelVisibility(APanel.TopLabel, AVisible);
  SetLabelVisibility(APanel.RightLabel, AVisible);
  SetLabelVisibility(APanel.BotLabel, AVisible);


  if AVisible then
  begin
    BringLabelToFront(APanel.TopLeftLabel);
    BringLabelToFront(APanel.TopRightLabel);
    BringLabelToFront(APanel.BotLeftLabel);
    BringLabelToFront(APanel.BotRightLabel);

    BringLabelToFront(APanel.LeftLabel);
    BringLabelToFront(APanel.TopLabel);
    BringLabelToFront(APanel.RightLabel);
    BringLabelToFront(APanel.BotLabel);
  end;
end;


procedure SetFocusToAPanel(AOwnerObject: TComponent; APanel: TMountPanel; ShifState: TShiftState);
var
  i: Integer;
begin
  if not (ssCtrl in ShifState) and not (ssShift in ShifState) then
    for i := 0 to AOwnerObject.ComponentCount - 1 do   //searches the whole scrollbox
      if AOwnerObject.Components[i] is TMountPanel then
      begin
        (AOwnerObject.Components[i] as TMountPanel).Tag := 0;
        UpdatePanelCorners(AOwnerObject.Components[i] as TMountPanel, False);
      end;

  if not Assigned(APanel) then
    Exit;
    
  APanel.Tag := 1;
  UpdatePanelCorners(APanel, True);
end;


procedure RemoveFocusFromAPanel(APanel: TMountPanel);
begin
  if not Assigned(APanel) then
    Exit;
    
  APanel.Tag := 0;
  UpdatePanelCorners(APanel, False);
end;


procedure RemoveFocusFromAllPanels(AScrollPanel: TPanel);
var
  i: Integer;
  APanel: TMountPanel;
begin
  for i := 0 to AScrollPanel.ComponentCount - 1 do
    if AScrollPanel.Components[i] is TMountPanel then
    begin
      APanel := AScrollPanel.Components[i] as TMountPanel;
      RemoveFocusFromAPanel(APanel);
    end;
end;


procedure SelectMountPanelsFromYellowSelection(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; OwnerObject: TComponent; FSelX1, FSelY1, FSelX2, FSelY2: Integer; ShifState: TShiftState; SelectionContent: TSelectionContent);
var
  i: Integer;
  WorkPanel: TMountPanel;
  LeftLineOnPanel, RightLineOnPanel, TopLineOnPanel, BottomLineOnPanel: Boolean;
  Condition1, Condition2, Condition3: Boolean;
begin
  SetFocusToAPanel(OwnerObject, nil, ShifState);
  SelectionContent.ClearSelection;

  if (FSelX1 = FSelX2) and (FSelY1 = FSelY2) then
    Exit;

  for i := 0 to OwnerObject.ComponentCount - 1 do
    if OwnerObject.Components[i] is TMountPanel then
    begin
      WorkPanel := OwnerObject.Components[i] as TMountPanel;
      if not WorkPanel.Visible then
        Continue;

      Condition1 := (FSelY1 <= WorkPanel.Top) and (FSelY2 >= WorkPanel.Top);                                       //the line is higher than the panel
      Condition2 := (FSelY1 <= WorkPanel.Top + WorkPanel.Height) and (FSelY2 >= WorkPanel.Top + WorkPanel.Height); //the line is lower than the panel
      Condition3 := (FSelY1 >= WorkPanel.Top) and (FSelY2 <= WorkPanel.Top + WorkPanel.Height);                    //the line is inside than the panel

      LeftLineOnPanel := BelongsTo(FSelX1, WorkPanel.Left, WorkPanel.Left + WorkPanel.Width) and (Condition1 or Condition2 or Condition3);
      if LeftLineOnPanel then
      begin
        WorkPanel.Tag := 1;
        UpdatePanelCorners(WorkPanel, True);
        SelectionContent.AddPanelToSelected(AllComponents, AllVisualComponents, WorkPanel);
        Continue;
      end;

      RightLineOnPanel := BelongsTo(FSelX2, WorkPanel.Left, WorkPanel.Left + WorkPanel.Width) and (Condition1 or Condition2 or Condition3);
      if RightLineOnPanel then
      begin
        WorkPanel.Tag := 1;
        UpdatePanelCorners(WorkPanel, True);
        SelectionContent.AddPanelToSelected(AllComponents, AllVisualComponents, WorkPanel);
        Continue;
      end;

      Condition1 := (FSelX1 <= WorkPanel.Left) and (FSelX2 >= WorkPanel.Left);                                       //the line is left to the panel
      Condition2 := (FSelX1 <= WorkPanel.Left + WorkPanel.Width) and (FSelX2 >= WorkPanel.Left + WorkPanel.Width);   //the line is right to the panel
      Condition3 := (FSelX1 >= WorkPanel.Left) and (FSelX2 <= WorkPanel.Left + WorkPanel.Width);                     //the line is inside than the panel

      TopLineOnPanel := BelongsTo(FSelY1, WorkPanel.Top, WorkPanel.Top + WorkPanel.Height) and (Condition1 or Condition2 or Condition3);
      if TopLineOnPanel then
      begin
        WorkPanel.Tag := 1;
        UpdatePanelCorners(WorkPanel, True);
        SelectionContent.AddPanelToSelected(AllComponents, AllVisualComponents, WorkPanel);
        Continue;
      end;

      BottomLineOnPanel := BelongsTo(FSelY2, WorkPanel.Top, WorkPanel.Top + WorkPanel.Height) and (Condition1 or Condition2 or Condition3);
      if BottomLineOnPanel then
      begin
        WorkPanel.Tag := 1;
        UpdatePanelCorners(WorkPanel, True);
        SelectionContent.AddPanelToSelected(AllComponents, AllVisualComponents, WorkPanel);
        Continue;
      end;

      if (FSelX1 <= WorkPanel.Left) and (FSelX2 >= WorkPanel.Left + WorkPanel.Width) and (FSelY1 <= WorkPanel.Top) and (FSelY2 >= WorkPanel.Top + WorkPanel.Height) then
      begin
        WorkPanel.Tag := 1;
        UpdatePanelCorners(WorkPanel, True);
        SelectionContent.AddPanelToSelected(AllComponents, AllVisualComponents, WorkPanel);
        Continue;
      end;
    end;      
end;


procedure SetMountPanelCoords(APanel: TMountPanel; ALeft, ATop: Integer);
var
  ParentScrollPanel: TPanel;
  ParentMountPanel: TMountPanel;
begin
  if APanel.Parent is TPanel then
  begin
    ParentScrollPanel := APanel.Parent as TPanel;
    if not Assigned(ParentScrollPanel) then
      Exit;

    APanel.Left := Max(0, Min(ALeft, ParentScrollPanel.Width - 20));
    APanel.Top := Max(0, Min(ATop, ParentScrollPanel.Height - 20));
  end;

  if APanel.Parent is TMountPanel then
  begin
    ParentMountPanel := APanel.Parent as TMountPanel;
    if not Assigned(ParentMountPanel) then
      Exit;

    APanel.Left := Max(0, Min(ALeft, ParentMountPanel.Width - 20));
    APanel.Top := Max(0, Min(ATop, ParentMountPanel.Height - 20));
  end;
end;


procedure DeleteComponentFrom_TDynTFTDesignAllComponentsArr(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentTypeIndex, IndexInDesignComponentOneKind: Integer);
var
  i, j: Integer;
begin
  for i := 0 to Length(AllVisualComponents) -1 do
    if AllVisualComponents[i].IndexInTDynTFTDesignAllComponentsArr = ComponentTypeIndex then
      if AllVisualComponents[i].IndexInDesignComponentOneKindArr > IndexInDesignComponentOneKind then
        Dec(AllVisualComponents[i].IndexInDesignComponentOneKindArr);

  for i := IndexInDesignComponentOneKind to Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind) - 2 do
  begin
    AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].ObjectName := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].ObjectName;
    AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CreatedAtStartup := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].CreatedAtStartup;
    AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].HasVariableInGUIObjects := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].HasVariableInGUIObjects;
   
    SetLength(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CustomProperties, Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].CustomProperties));
    SetLength(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CustomEvents, Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].CustomEvents));

    for j := 0 to Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CustomProperties) - 1 do
      AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CustomProperties[j] := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].CustomProperties[j];

    for j := 0 to Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CustomEvents) - 1 do
      AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i].CustomEvents[j] := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[i + 1].CustomEvents[j];
  end;

  SetLength(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind) - 1].CustomProperties, 0);
  SetLength(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind) - 1].CustomEvents, 0);
  SetLength(AllComponents[ComponentTypeIndex].DesignComponentsOneKind, Length(AllComponents[ComponentTypeIndex].DesignComponentsOneKind) - 1);
end;


procedure DeleteComponentFrom_TProjectVisualComponentArr(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentTypeIndex, IndexInTProjectVisualComponentArr: Integer);
var
  i: Integer;
begin
  for i := IndexInTProjectVisualComponentArr to Length(AllVisualComponents) - 2 do
  begin
    AllVisualComponents[i].ScreenPanel := AllVisualComponents[i + 1].ScreenPanel;
    AllVisualComponents[i].IndexInTDynTFTDesignAllComponentsArr := AllVisualComponents[i + 1].IndexInTDynTFTDesignAllComponentsArr;  // a.k.a type index or schema index

    AllVisualComponents[i].ScreenPanel.IndexInTProjectVisualComponentArr := i;
    AllVisualComponents[i].IndexInDesignComponentOneKindArr := AllVisualComponents[i + 1].IndexInDesignComponentOneKindArr;
  end;  

  SetLength(AllVisualComponents, Length(AllVisualComponents) - 1);
end;


procedure DeletePanel(PanelToDelete: TMountPanel; DeleteDynTFTOwnerCallback: TDeleteDynTFTOwnerCallback);
begin
  PanelToDelete.Visible := False;
  DeleteDynTFTOwnerCallback(PanelToDelete);

  {$IFnDEF FPC}  //disabled for now in FPC, because of an AV when deleting panels (it looks like a double free)
    PanelToDelete.Parent.RemoveControl(PanelToDelete);  /////////////////////  added later  - sets Parent to nil, position and size to 0, Handle and WindowHandle to 0, resets WinControlFlags
    PanelToDelete.Caption := 'DeletedPanel';
    FreeAndNil(PanelToDelete);
  {$ENDIF}
end;


procedure DeleteSelectedPanels(OwnerObject: TComponent; DeleteDynTFTOwnerCallback: TDeleteDynTFTOwnerCallback);
var
  i: Integer;
  AScrollPanel: TPanel;
  PanelToDelete: TMountPanel;
begin
  AScrollPanel := OwnerObject as TPanel;
  
  for i := AScrollPanel.ComponentCount - 1 downto 0 do
    if Assigned(AScrollPanel.Components[i]) then
      if AScrollPanel.Components[i] is TMountPanel then
      begin
        PanelToDelete := (AScrollPanel.Components[i] as TMountPanel);
        if PanelToDelete.Tag = 1 then
          DeletePanel(PanelToDelete, DeleteDynTFTOwnerCallback);
      end;
end;


procedure DeleteAllPanels(OwnerObject: TComponent; DeleteDynTFTOwnerCallback: TDeleteDynTFTOwnerCallback);
var
  i: Integer;
  AScrollPanel: TPanel;
  PanelToDelete: TMountPanel;
begin
  AScrollPanel := OwnerObject as TPanel;
  
  for i := AScrollPanel.ComponentCount - 1 downto 0 do
    if Assigned(AScrollPanel.Components[i]) then
      if AScrollPanel.Components[i] is TMountPanel then
      begin
        PanelToDelete := (AScrollPanel.Components[i] as TMountPanel);
        DeletePanel(PanelToDelete, DeleteDynTFTOwnerCallback);
      end;
end;


function SelectedPanelsExist(OwnerObject: TComponent): Boolean;
var
  i: Integer;
  AScrollPanel: TPanel;
  PanelToDelete: TMountPanel;
begin
  Result := False;
  AScrollPanel := OwnerObject as TPanel;
  
  for i := AScrollPanel.ComponentCount - 1 downto 0 do
    if Assigned(AScrollPanel.Components[i]) then
      if AScrollPanel.Components[i] is TMountPanel then
      begin
        PanelToDelete := (AScrollPanel.Components[i] as TMountPanel);
        if PanelToDelete.Tag = 1 then
        begin
          Result := True;
          Exit;
        end;
      end;
end;


function GetScreenIndexFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel): Integer;
var
  VisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, ScreenIndexPropIdx: Integer;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;

  ScreenIndexPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'ScreenIndex');
  
  Result := StrToIntDef(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[ScreenIndexPropIdx].PropertyValue, -2);
end;


procedure SetMountPanelScreenIndex(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel; NewScreenIndex: Integer);
var
  VisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, ScreenIndexPropIdx: Integer;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;

  ScreenIndexPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'ScreenIndex');
  
  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[ScreenIndexPropIdx].PropertyValue := IntToStr(NewScreenIndex);
end;


procedure SelectAllPanels(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; OwnerObject: TComponent; SelectionContent: TSelectionContent; OnlyScreenIndex: Integer);
var
  i: Integer;
  WorkPanel: TMountPanel;
begin
  for i := 0 to OwnerObject.ComponentCount - 1 do
    if OwnerObject.Components[i] is TMountPanel then
    begin
      WorkPanel := OwnerObject.Components[i] as TMountPanel;

      if (OnlyScreenIndex = -1) or (GetScreenIndexFromPanel(AllComponents, AllVisualComponents, WorkPanel) = OnlyScreenIndex) then
      begin
        WorkPanel.Tag := 1;
        UpdatePanelCorners(WorkPanel, True);
        SelectionContent.AddPanelToSelected(AllComponents, AllVisualComponents, WorkPanel);
      end;
    end;
end;


procedure UpdateComponentWidthAndHeightFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
var
  VisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, WidthPropIdx, HeightPropIdx: Integer;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;

  WidthPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'Width');
  HeightPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'Height');
  
  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[WidthPropIdx].PropertyValue := IntToStr(APanel.Width);
  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[HeightPropIdx].PropertyValue := IntToStr(APanel.Height);
end;


procedure UpdateComponentLeftAndTopFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
var
  VisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, LeftPropIdx, TopPropIdx: Integer;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;

  LeftPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'Left');
  TopPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'Top');
  
  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[LeftPropIdx].PropertyValue := IntToStr(APanel.Left);
  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[TopPropIdx].PropertyValue := IntToStr(APanel.Top);
end;


procedure UpdateComponentScreenIndex(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel; NewScreenIndex: Integer);
var
  VisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, ScreenIndexPropIdx: Integer;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;

  ScreenIndexPropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, 'ScreenIndex');

  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[ScreenIndexPropIdx].PropertyValue := IntToStr(NewScreenIndex);
end;


procedure UpdateComponentPropertyByNameAndPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel; PropertyName: string; NewValue: string);
var
  VisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, PropIdx: Integer;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;
  PropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties, PropertyName);

  AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[PropIdx].PropertyValue := NewValue;
end;


function ComponentInstanceExistsByName(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; InstanceName: string): Boolean;
var
  i, ComponentTypeIndex: Integer;
  UpperCaseInstanceName: string;
begin
  Result := False;
  UpperCaseInstanceName := UpperCase(InstanceName);

  for i := 0 to Length(AllVisualComponents) - 1 do
  begin
    ComponentTypeIndex := AllVisualComponents[i].IndexInTDynTFTDesignAllComponentsArr;
    if UpperCase(AllComponents[ComponentTypeIndex].DesignComponentsOneKind[AllVisualComponents[i].IndexInDesignComponentOneKindArr].ObjectName) = UpperCaseInstanceName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


constructor TSelectionContent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetLength(FSelectedPanels, 0);
  SetLength(FSelectedTypes, 0);
  SetLength(FDisplayedProperties, 0);
  SetLength(FDisplayedEvents, 0);
  SetLength(FSelectedTypes, 0);

  FOnUpdateSpecialProperty := nil;
end;


destructor TSelectionContent.Destroy; 
begin
  SetLength(FSelectedPanels, 0);
  SetLength(FSelectedTypes, 0);
  SetLength(FDisplayedProperties, 0);
  SetLength(FDisplayedEvents, 0);
  SetLength(FSelectedTypes, 0);
  inherited Destroy;
end;


procedure TSelectionContent.DoOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);
begin
  if not Assigned(FOnUpdateSpecialProperty) then
    raise Exception.Create('OnUpdateSpecialProperty not assigned.');

  FOnUpdateSpecialProperty(APropertyIndex, ADesignComponentInAll, APropertyName, APropertyNewValue);
end;


procedure TSelectionContent.AddPanelToSelected(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
var
  ComponentType: string;
  VisualComponent: TProjectVisualComponent;
  i: Integer;
begin
  for i := 0 to Length(FSelectedPanels) - 1 do
    if FSelectedPanels[i] = APanel then
      Exit; //panel already selected
    
  SetLength(FSelectedPanels, Length(FSelectedPanels) + 1);
  FSelectedPanels[Length(FSelectedPanels) - 1] := APanel;

  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentType := GetTypeFromVisualComponent(AllComponents, AllVisualComponents, VisualComponent);
  UpdateDisplayedProperties(AllComponents, AllVisualComponents, ComponentType, soAdd, VisualComponent);
end;


procedure TSelectionContent.RemovePanelFromSelected(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
var
  i, idx: Integer;
  ComponentType: string;
  VisualComponent: TProjectVisualComponent;
begin
  idx := -1;
  for i := 0 to Length(FSelectedPanels) - 1 do
    if FSelectedPanels[i] = APanel then
    begin
      idx := i;
      Break;
    end;

  if idx > -1 then
  begin
    for i := idx to Length(FSelectedPanels) - 2 do
      FSelectedPanels[i] := FSelectedPanels[i + 1];

    SetLength(FSelectedPanels, Length(FSelectedPanels) - 1);

    VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
    ComponentType := GetTypeFromVisualComponent(AllComponents, AllVisualComponents, VisualComponent);
    UpdateDisplayedProperties(AllComponents, AllVisualComponents, ComponentType, soRemove, VisualComponent);
  end;
end;


procedure TSelectionContent.UpdateDisplayedPanelProperties(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
var
  ComponentType: string;
  VisualComponent: TProjectVisualComponent;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentType := GetTypeFromVisualComponent(AllComponents, AllVisualComponents, VisualComponent);
  UpdateDisplayedProperties(AllComponents, AllVisualComponents, ComponentType, soUpdateProp, VisualComponent);
end;


procedure TSelectionContent.SetDisplayedPanelProperties(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel);
var
  ComponentType: string;
  VisualComponent: TProjectVisualComponent;
begin
  VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, APanel);
  ComponentType := GetTypeFromVisualComponent(AllComponents, AllVisualComponents, VisualComponent);
  UpdateDisplayedProperties(AllComponents, AllVisualComponents, ComponentType, soSetSelToComponent, VisualComponent);
end;


procedure TSelectionContent.ClearSelection;
var
  i: Integer;
begin
  for i := 0 to Length(FSelectedPanels) - 1 do
    FSelectedPanels[i] := nil;
  
  SetLength(FSelectedPanels, 0);
  SetLength(FSelectedTypes, 0);
  SetLength(FDisplayedProperties, 0);
  SetLength(FDisplayedEvents, 0);
end;


function TSelectionContent.GetTypeIndexInSelection(NewType: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(FSelectedTypes) - 1 do
    if FSelectedTypes[i] = NewType then
    begin
      Result := i;
      Break;
    end;
end;


procedure TSelectionContent.AddTypeToSelection(NewType: string);
begin
  if GetTypeIndexInSelection(NewType) > -1 then
    Exit;

  SetLength(FSelectedTypes, Length(FSelectedTypes) + 1);
  FSelectedTypes[Length(FSelectedTypes) - 1] := NewType; 
end;


{procedure TSelectionContent.RemoveTypeFromSelection(NewType: string);
var
  i, Found: Integer;
begin
  Found := GetTypeIndexInSelection(NewType);

  if Found > -1 then
    for i := Found to Length(FSelectedTypes) - 2 do
      FSelectedTypes[i] := FSelectedTypes[i + 1];
end;


function TSelectionContent.CountSelectedComponentsByType(AType: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(FSelectedTypes) - 1 do
    if FSelectedTypes[i] = AType then
      Inc(Result);
end;}


function GetVisualComponentFromPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; APanel: TMountPanel): TProjectVisualComponent;
begin
  try
    Result := AllVisualComponents[APanel.IndexInTProjectVisualComponentArr];
  except
    on E: Exception do
    begin
      raise Exception.Create(E.Message + #13#10 +
                             'APanel = ' + IntToStr(Integer(APanel)) + #13#10 +
                             'APanel.Caption = ' + APanel.Caption + #13#10 +
                             'IdxInTProjectVisualComponentArr = ' + IntToStr(Integer(APanel.IndexInTProjectVisualComponentArr)));
    end;
  end;
end;


function GetTypeFromVisualComponent(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; AVisualComponent: TProjectVisualComponent): string;
var
  ComponentTypeIndex: Integer; //there might be many types selected
begin
  ComponentTypeIndex := AVisualComponent.IndexInTDynTFTDesignAllComponentsArr;
  Result := AllComponents[ComponentTypeIndex].Schema.ComponentTypeName;
end;


function GetPropertyIndexInSchema(var SchemaProperties: TComponentPropertiesSchemaArr; PropertyName: string): Integer; //Returns -1 if component does not have that property
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(SchemaProperties) - 1 do
    if SchemaProperties[i].PropertyName = PropertyName then
    begin
      Result := i;
      Break;
    end;
end;


function GetPropertyIndexInSchemaFromComponentByType(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentTypeIndex: Integer; PropertyName: string): Integer; //Returns -1 if component does not have that property
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(AllComponents[ComponentTypeIndex].Schema.Properties) - 1 do
    if AllComponents[ComponentTypeIndex].Schema.Properties[i].PropertyName = PropertyName then
    begin
      Result := i;
      Break;
    end;
end;


function GetPropertyValueInPropertiesByNameAndPanel(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; PropertyName: string; APanel: TMountPanel): string;
var
  IdxInAll, IdxInVisual, IdxInOneKind: Integer;
begin
  IdxInVisual := APanel.IndexInTProjectVisualComponentArr;
  IdxInAll := AllVisualComponents[IdxInVisual].IndexInTDynTFTDesignAllComponentsArr;
  IdxInOneKind := AllVisualComponents[IdxInVisual].IndexInDesignComponentOneKindArr;
  Result := GetPropertyValueInPropertiesOrEventsByName(AllComponents[IdxInAll].DesignComponentsOneKind[IdxInOneKind].CustomProperties, PropertyName);
end;


{function GetPropertyValueInAllComponents(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentType: string; PropertyName: string): Integer; //Returns 'PropertyNotFound' if component does not have that property
var
  AVisualComponent: TProjectVisualComponent;
  ComponentTypeIndex, i, j, IdxInOneKind, PropIdx: Integer;
begin
  for i := 0 to Length(AllVisualComponents) - 1 do
  begin
    ComponentTypeIndex := AllVisualComponents[i].IndexInTDynTFTDesignAllComponentsArr;
    IdxInOneKind := AllVisualComponents[i].IndexInDesignComponentOneKindArr;        

    for j := 0 to Length(AllComponents[IdxInOneKind].DesignComponentsOneKind) - 1 do
    begin                                                           
      PropIdx := GetPropertyIndexInPropertiesOrEventsByName(AllComponents[IdxInOneKind].DesignComponentsOneKind[j].CustomProperties, PropertyName);
    end;
  end;
  AVisualComponent := GetVisualComponentFromPanel()
  Result := -1;
end;}
{
function TSelectionContent.GetEventIndexFromComponentByType(ComponentTypeIndex: Integer; EventName: string): Integer; //Returns -1 if component does not have that event
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(FAllComponents[ComponentTypeIndex].Schema.Events) - 1 do
    if FAllComponents[ComponentTypeIndex].Schema.Events[i].PropertyName = EventName then
    begin
      Result := i;
      Break;
    end;
end;}


//Returns -1 if component does not have that property
function GetPropertyIndexInDisplayedPropertiesFromComponentByName(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; PropertyOrEventName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(DisplayedPropertiesOrEvents) - 1 do
    if DisplayedPropertiesOrEvents[i].PropertyName = PropertyOrEventName then
    begin
      Result := i;
      Break;
    end;
end;


function GetPropertyIndexInAddedComponentPropertiesFromComponentByName(var AddedComponentPropertiesOrEvents: TDynTFTDesignPropertyArr; PropertyOrEventName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(AddedComponentPropertiesOrEvents) - 1 do
    if AddedComponentPropertiesOrEvents[i].PropertyName = PropertyOrEventName then
    begin
      Result := i;
      Break;
    end;
end;


{procedure AddPropertyOrEventToDisplayed(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; ADesignProperty: TDynTFTDesignProperty);
var
  n: Integer;
begin
  n := Length(DisplayedPropertiesOrEvents);
  SetLength(DisplayedPropertiesOrEvents, n + 1);
  DisplayedPropertiesOrEvents[n].PropertyName := ADesignProperty.PropertyName;
  DisplayedPropertiesOrEvents[n].PropertyValue := ADesignProperty.PropertyValue;
  DisplayedPropertiesOrEvents[n].PropertyDataType := '';
  DisplayedPropertiesOrEvents[n].DisplayAsMixedValues := False;
end; }


procedure RemovePropertyOrEventFromDisplayed(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; PropertyNameToBeRemoved: string);
var
  n, i, Found: Integer;
begin
  n := Length(DisplayedPropertiesOrEvents);
  Found := -1;
  for i := 0 to n - 1 do
    if DisplayedPropertiesOrEvents[i].PropertyName = PropertyNameToBeRemoved then
    begin
      Found := i;
      Break;
    end;

  if Found > -1 then
  begin
    for i := Found to n - 2 do
      DisplayedPropertiesOrEvents[i] := DisplayedPropertiesOrEvents[i + 1];

    SetLength(DisplayedPropertiesOrEvents, Length(DisplayedPropertiesOrEvents) - 1);  
  end;
end;


procedure RemoveUncommonPropertiesOrEventsFromDisplayed(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; var AddedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr);
var
  i: Integer;
  PropertyIndexInDisplayed, PropertyIndexInAddedComponent: Integer;
begin
  for i := 0 to Length(AddedComponentPropertyOrEventArr) - 1 do
  begin
    PropertyIndexInDisplayed := GetPropertyIndexInDisplayedPropertiesFromComponentByName(DisplayedPropertiesOrEvents, AddedComponentPropertyOrEventArr[i].PropertyName);
    if PropertyIndexInDisplayed = -1 then  //property not found, because of adding a new type
      RemovePropertyOrEventFromDisplayed(DisplayedPropertiesOrEvents, AddedComponentPropertyOrEventArr[i].PropertyName); //selection will not have this property
  end;

  for i := Length(DisplayedPropertiesOrEvents) - 1 downto 0 do
  begin
    PropertyIndexInAddedComponent := GetPropertyIndexInAddedComponentPropertiesFromComponentByName(AddedComponentPropertyOrEventArr, DisplayedPropertiesOrEvents[i].PropertyName);
    if PropertyIndexInAddedComponent = -1 then  //property not found, because of adding a new type
      RemovePropertyOrEventFromDisplayed(DisplayedPropertiesOrEvents, DisplayedPropertiesOrEvents[i].PropertyName) //selection will not have this property
  end;
end;


function GetComponentPropertiesSchemaIndexByPropertyName(var PropertiesOrEventsSchemaArr: TComponentPropertiesSchemaArr; APropertyName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(PropertiesOrEventsSchemaArr) - 1 do
    if PropertiesOrEventsSchemaArr[i].PropertyName = APropertyName then
    begin
      Result := i;
      Break;
    end;
end;


procedure TSelectionContent.PerformAddToSelOperation(var PropertiesOrEventsSchemaArr: TComponentPropertiesSchemaArr; var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; var AddedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr; TypeIndexInSel: Integer);
var
  i, SchemaIndex: Integer;
begin
  case Length(FSelectedTypes) of
    0:
    begin   //the list is empty
      SetLength(DisplayedPropertiesOrEvents, Length(AddedComponentPropertyOrEventArr));
      for i := 0 to Length(AddedComponentPropertyOrEventArr) - 1 do
      begin
        DisplayedPropertiesOrEvents[i].PropertyName := AddedComponentPropertyOrEventArr[i].PropertyName;
        DisplayedPropertiesOrEvents[i].PropertyValue := AddedComponentPropertyOrEventArr[i].PropertyValue;
        DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := False;
        DisplayedPropertiesOrEvents[i].DisplayAsMixedReadOnly := False;

        DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes := False;
        DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription := False;
        DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability := False;
        DisplayedPropertiesOrEvents[i].DesignTimeOnly := False;
        DisplayedPropertiesOrEvents[i].ReadOnly := False;

        SchemaIndex := GetComponentPropertiesSchemaIndexByPropertyName(PropertiesOrEventsSchemaArr, AddedComponentPropertyOrEventArr[i].PropertyName);
        if SchemaIndex > -1 then
        begin
          DisplayedPropertiesOrEvents[i].PropertyDataType := PropertiesOrEventsSchemaArr[SchemaIndex].PropertyDataType;
          DisplayedPropertiesOrEvents[i].PropertyDescription := PropertiesOrEventsSchemaArr[SchemaIndex].PropertyDescription;
          DisplayedPropertiesOrEvents[i].AvailableOnCompilerDirectives := PropertiesOrEventsSchemaArr[SchemaIndex].AvailableOnCompilerDirectives;
          DisplayedPropertiesOrEvents[i].DesignTimeOnly := PropertiesOrEventsSchemaArr[SchemaIndex].DesignTimeOnly;
          DisplayedPropertiesOrEvents[i].ReadOnly := PropertiesOrEventsSchemaArr[SchemaIndex].ReadOnly;
        end;
      end; //for
    end;

    1:     //there is at least one type   (one or more selected panels)
    begin
      if TypeIndexInSel > -1 then //Type already exists. The list of properties stays the same. Only their values might be "converted" to DisplayAsMixedValues.
      begin  //adding a component of the same type with different property values
        for i := 0 to Length(AddedComponentPropertyOrEventArr) - 1 do
        begin
          DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := DisplayedPropertiesOrEvents[i].DisplayAsMixedValues or (DisplayedPropertiesOrEvents[i].PropertyValue <> AddedComponentPropertyOrEventArr[i].PropertyValue);

          SchemaIndex := GetComponentPropertiesSchemaIndexByPropertyName(PropertiesOrEventsSchemaArr, AddedComponentPropertyOrEventArr[i].PropertyName);
          if SchemaIndex > -1 then
          begin
            DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes := DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes or (DisplayedPropertiesOrEvents[i].PropertyDataType <> PropertiesOrEventsSchemaArr[SchemaIndex].PropertyDataType);
            DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription := DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription or (DisplayedPropertiesOrEvents[i].PropertyDescription <> PropertiesOrEventsSchemaArr[SchemaIndex].PropertyDescription);
            DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability := DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability or (DisplayedPropertiesOrEvents[i].AvailableOnCompilerDirectives <> PropertiesOrEventsSchemaArr[SchemaIndex].AvailableOnCompilerDirectives);
            DisplayedPropertiesOrEvents[i].DesignTimeOnly := DisplayedPropertiesOrEvents[i].DesignTimeOnly or (DisplayedPropertiesOrEvents[i].DesignTimeOnly <> PropertiesOrEventsSchemaArr[SchemaIndex].DesignTimeOnly);
            DisplayedPropertiesOrEvents[i].ReadOnly := DisplayedPropertiesOrEvents[i].ReadOnly or (DisplayedPropertiesOrEvents[i].ReadOnly <> PropertiesOrEventsSchemaArr[SchemaIndex].ReadOnly);
          end;
        end; //for 
      end
      else   //TypeIndexInSel = -1, adding new type
        RemoveUncommonPropertiesOrEventsFromDisplayed(DisplayedPropertiesOrEvents, AddedComponentPropertyOrEventArr);  //then recompute DisplayAsMixedValues
    end;
        
    else
      RemoveUncommonPropertiesOrEventsFromDisplayed(DisplayedPropertiesOrEvents, AddedComponentPropertyOrEventArr);    //then recompute DisplayAsMixedValues
  end;
end;


procedure RebuildDisplayedMixedValues(var SelectedPanels: TMountPanelArr; var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; PropOrEvent: Boolean);
var
  ComponentTypeIndex: Integer;
  AddedComponent: TDynTFTDesignComponentOneKind;
  i, j: Integer;
  PropertyIndexInAddedComponent, SchemaIndex: Integer;
  CurrentVisualComponent: TProjectVisualComponent;
  AddedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr;
begin
  for j := 0 to Length(SelectedPanels) - 1 do
  begin
    CurrentVisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, SelectedPanels[j]);
    ComponentTypeIndex := CurrentVisualComponent.IndexInTDynTFTDesignAllComponentsArr;
    
    AddedComponent := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[CurrentVisualComponent.IndexInDesignComponentOneKindArr];

    if not PropOrEvent then
      AddedComponentPropertyOrEventArr := AddedComponent.CustomProperties
    else
      AddedComponentPropertyOrEventArr := AddedComponent.CustomEvents;

    for i := 0 to Length(DisplayedPropertiesOrEvents) - 1 do
    begin
      PropertyIndexInAddedComponent := GetPropertyIndexInAddedComponentPropertiesFromComponentByName(AddedComponentPropertyOrEventArr, DisplayedPropertiesOrEvents[i].PropertyName);

      if j = 0 then //first panel in selection
      begin
        if PropertyIndexInAddedComponent <> -1 then  //property found
          DisplayedPropertiesOrEvents[i].PropertyValue := AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyValue;

        DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := False;
        
        DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes := False;
        DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription := False;
        DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability := False;
        DisplayedPropertiesOrEvents[i].DesignTimeOnly := False;
        DisplayedPropertiesOrEvents[i].ReadOnly := False;
      end
      else
      begin
        if PropertyIndexInAddedComponent <> -1 then  //property found
        begin
          if not PropOrEvent then
          begin
            DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := DisplayedPropertiesOrEvents[i].DisplayAsMixedValues or (DisplayedPropertiesOrEvents[i].PropertyValue <> AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyValue);

            SchemaIndex := GetComponentPropertiesSchemaIndexByPropertyName(AllComponents[ComponentTypeIndex].Schema.Properties, AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyName);
            if SchemaIndex > -1 then
            begin
              DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes := DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes or (DisplayedPropertiesOrEvents[i].PropertyDataType <> AllComponents[ComponentTypeIndex].Schema.Properties[SchemaIndex].PropertyDataType);
              DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription := DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription or (DisplayedPropertiesOrEvents[i].PropertyDescription <> AllComponents[ComponentTypeIndex].Schema.Properties[SchemaIndex].PropertyDescription);
              DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability := DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability or (DisplayedPropertiesOrEvents[i].AvailableOnCompilerDirectives <> AllComponents[ComponentTypeIndex].Schema.Properties[SchemaIndex].AvailableOnCompilerDirectives);
              DisplayedPropertiesOrEvents[i].DesignTimeOnly := DisplayedPropertiesOrEvents[i].DesignTimeOnly or (DisplayedPropertiesOrEvents[i].DesignTimeOnly <> AllComponents[ComponentTypeIndex].Schema.Properties[SchemaIndex].DesignTimeOnly);
              DisplayedPropertiesOrEvents[i].ReadOnly := DisplayedPropertiesOrEvents[i].ReadOnly or (DisplayedPropertiesOrEvents[i].ReadOnly <> AllComponents[ComponentTypeIndex].Schema.Properties[SchemaIndex].ReadOnly);
            end;
          end //if
          else
          begin
            DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := DisplayedPropertiesOrEvents[i].DisplayAsMixedValues or (DisplayedPropertiesOrEvents[i].PropertyValue <> AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyValue);

            SchemaIndex := GetComponentPropertiesSchemaIndexByPropertyName(AllComponents[ComponentTypeIndex].Schema.Events, AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyName);
            if SchemaIndex > -1 then
            begin
              DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes := DisplayedPropertiesOrEvents[i].DisplayAsMixedDataTypes or (DisplayedPropertiesOrEvents[i].PropertyDataType <> AllComponents[ComponentTypeIndex].Schema.Events[SchemaIndex].PropertyDataType);
              DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription := DisplayedPropertiesOrEvents[i].DisplayAsMixedDescription or (DisplayedPropertiesOrEvents[i].PropertyDescription <> AllComponents[ComponentTypeIndex].Schema.Events[SchemaIndex].PropertyDescription);
              DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability := DisplayedPropertiesOrEvents[i].DisplayAsMixedDirectiveAvailability or (DisplayedPropertiesOrEvents[i].AvailableOnCompilerDirectives <> AllComponents[ComponentTypeIndex].Schema.Events[SchemaIndex].AvailableOnCompilerDirectives);
              DisplayedPropertiesOrEvents[i].DesignTimeOnly := DisplayedPropertiesOrEvents[i].DesignTimeOnly or (DisplayedPropertiesOrEvents[i].DesignTimeOnly <> AllComponents[ComponentTypeIndex].Schema.Events[SchemaIndex].DesignTimeOnly);
              DisplayedPropertiesOrEvents[i].ReadOnly := DisplayedPropertiesOrEvents[i].ReadOnly or (DisplayedPropertiesOrEvents[i].ReadOnly <> AllComponents[ComponentTypeIndex].Schema.Events[SchemaIndex].ReadOnly);
            end;
          end; //else
        end; /////  property found
      end; //j > 0
    end; //for i
  end; //for j
end;


//procedure TSelectionContent.PerformRemoveFromSelOperation(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; var RemovedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr; TypeIndexInSel, SelectedComponentsCountOfRemovingType: Integer);
//var
//  i: Integer;
//  PropertyIndexInDisplayed: Integer;
//begin
//  if SelectedComponentsCountOfRemovingType > 1 then  //more than one components of this type; the array stays the same; only the DisplayAsMixedValues might change
//  begin
//    for i := 0 to Length(DisplayedPropertiesOrEvents) - 1 do
//      DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := False; //Reset all
//  end
//  else
//  begin
//    //RemovePropertyOrEventFromDisplayed
//  end;
//end;


procedure SetSelToComponent(var DisplayedPropertiesOrEvents: TDynTFTExtendedDesignPropertyArr; var AddedComponentPropertyOrEventArr: TDynTFTDesignPropertyArr; ResetMixedValues: TResetMixedValues);
var
  i, PropertyIndexInAddedComponent: Integer;
begin
  case ResetMixedValues of
    rmvReset:
    begin
      for i := 0 to Length(DisplayedPropertiesOrEvents) - 1 do
      begin
        PropertyIndexInAddedComponent := GetPropertyIndexInAddedComponentPropertiesFromComponentByName(AddedComponentPropertyOrEventArr, DisplayedPropertiesOrEvents[i].PropertyName);
        if PropertyIndexInAddedComponent <> -1 then  //property found
          DisplayedPropertiesOrEvents[i].PropertyValue := AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyValue;

        DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := False;
      end;
    end;

    rmvLeave:
    begin
      for i := 0 to Length(DisplayedPropertiesOrEvents) - 1 do
      begin
        PropertyIndexInAddedComponent := GetPropertyIndexInAddedComponentPropertiesFromComponentByName(AddedComponentPropertyOrEventArr, DisplayedPropertiesOrEvents[i].PropertyName);
        if PropertyIndexInAddedComponent <> -1 then  //property found
          DisplayedPropertiesOrEvents[i].DisplayAsMixedValues := DisplayedPropertiesOrEvents[i].DisplayAsMixedValues or (DisplayedPropertiesOrEvents[i].PropertyValue <> AddedComponentPropertyOrEventArr[PropertyIndexInAddedComponent].PropertyValue);
      end;
    end;
  end;   
end;


procedure GetComponentDefaultSize(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; var ComponentDefaultSize: TComponentDefaultSize);
begin
  if ComponentProperties[PropertyIndex].PropertyName = 'Width' then
  begin
    ComponentDefaultSize.Width := StrToIntDef(ComponentProperties[PropertyIndex].PropertyValue, 150);
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'Height' then
  begin
    ComponentDefaultSize.Height := StrToIntDef(ComponentProperties[PropertyIndex].PropertyValue, 30);
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'MinWidth' then
  begin
    ComponentDefaultSize.MinWidth := StrToIntDef(ComponentProperties[PropertyIndex].PropertyValue, 2);
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'MinHeight' then
  begin
    ComponentDefaultSize.MinHeight := StrToIntDef(ComponentProperties[PropertyIndex].PropertyValue, 2);
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'MaxWidth' then
  begin
    ComponentDefaultSize.MaxWidth := StrToIntDef(ComponentProperties[PropertyIndex].PropertyValue, 0);
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'MaxHeight' then
  begin
    ComponentDefaultSize.MaxHeight := StrToIntDef(ComponentProperties[PropertyIndex].PropertyValue, 0);
    Exit;
  end;
end;


procedure AdjustComponentPosition(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; NewLeft, NewTop: Integer);
begin
  if ComponentProperties[PropertyIndex].PropertyName = 'Left' then
  begin
    ComponentProperties[PropertyIndex].PropertyValue := IntToStr(NewLeft);
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'Top' then
  begin
    ComponentProperties[PropertyIndex].PropertyValue := IntToStr(NewTop);
    Exit;
  end;
end;


procedure AdjustComponentName(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; NewName: string);
begin
  if ComponentProperties[PropertyIndex].PropertyName = 'ObjectName' then
  begin
    ComponentProperties[PropertyIndex].PropertyValue := NewName;
    Exit;
  end;

  if ComponentProperties[PropertyIndex].PropertyName = 'Name' then
  begin
    ComponentProperties[PropertyIndex].PropertyValue := NewName;
    Exit;
  end;  

  if ComponentProperties[PropertyIndex].PropertyName = 'Caption' then
  begin
    if ComponentProperties[PropertyIndex].PropertyValue = '' then
      ComponentProperties[PropertyIndex].PropertyValue := NewName;
    Exit;
  end;
end;


procedure AdjustComponentScreenIndex(var ComponentProperties: TDynTFTDesignPropertyArr; PropertyIndex: Integer; NewScreenIndex: Integer);
begin
  if ComponentProperties[PropertyIndex].PropertyName = 'ScreenIndex' then
    ComponentProperties[PropertyIndex].PropertyValue := IntToStr(NewScreenIndex);
end;


procedure SetPanelDefaultSize(APanel: TMountPanel; ComponentDefaultSize: TComponentDefaultSize);
begin
  if ComponentDefaultSize.Width <> -1 then
    APanel.Width := ComponentDefaultSize.Width;

  if ComponentDefaultSize.Height <> -1 then
    APanel.Height := ComponentDefaultSize.Height;

  if ComponentDefaultSize.MinWidth <> 2 then
    APanel.Constraints.MinWidth := Max(ComponentDefaultSize.MinWidth, 2);

  if ComponentDefaultSize.MinHeight <> 2 then
    APanel.Constraints.MinHeight := Max(ComponentDefaultSize.MinHeight, 2);

  if ComponentDefaultSize.MaxWidth <> 0 then
    APanel.Constraints.MaxWidth := ComponentDefaultSize.MaxWidth;

  if ComponentDefaultSize.MaxHeight <> 0 then
    APanel.Constraints.MaxHeight := ComponentDefaultSize.MaxHeight;
end;


procedure UpdateIdxInVisualAtSave(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr);
var
  i: Integer;
  CompType: Integer;
begin
  for i := 0 to Length(AllVisualComponents) - 1 do
  begin
    CompType := AllVisualComponents[i].IndexInTDynTFTDesignAllComponentsArr;
    AllComponents[CompType].DesignComponentsOneKind[AllVisualComponents[i].IndexInDesignComponentOneKindArr].IdxInVisualAtSave := i;
  end;
end;


{#13#10 -> #4#5}
function FastReplace_ReturnTo45(s: string): string;
var
  i, n: Integer;
begin
  n := Pos(#13, s);
  if n = 0 then
  begin
    Result := s;
    Exit;
  end;

  for i := n to Length(s) do
    if s[i] = #13 then
      s[i] := #4
    else
      if s[i] = #10 then
        s[i] := #5;
  Result := s;
end;


function FastReplace_45ToReturn(s: string): string;
var
  i, n: Integer;
begin
  n := Pos(#4, s);
  if n = 0 then
  begin
    Result := s;
    Exit;
  end;

  for i := n to Length(s) do
    if s[i] = #4 then
      s[i] := #13
    else
      if s[i] = #5 then
        s[i] := #10;
  Result := s;
end;


function FastReplace_ReturnToCSV(s: string): string;
var
  i, n: Integer;
begin
  n := Pos(#13, s);
  if n = 0 then
  begin
    Result := s;
    Exit;
  end;

  for i := n to Length(s) do
    if s[i] = #13 then
      s[i] := ','
    else
      if s[i] = #10 then
        s[i] := ' ';
  Result := s;
end;


function Ascii127_To_Ascii32(s: string): string;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
    if s[i] = #127 then
      s[i] := #32;

  Result := s;    
end;


{TSelectionContent}

procedure TSelectionContent.UpdateDisplayedProperties(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ComponentType: string; Operation: TSelectionOperation; VisualComponent: TProjectVisualComponent);
var
  TypeIndexInSel: Integer;
  ComponentTypeIndex: Integer;
  AddedComponent: TDynTFTDesignComponentOneKind;
  i: Integer;
  CurrentVisualComponent: TProjectVisualComponent;
begin
  case Operation of
    soAdd:
    begin
      TypeIndexInSel := GetTypeIndexInSelection(ComponentType);
      ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;
      AddedComponent := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr];

      PerformAddToSelOperation(AllComponents[ComponentTypeIndex].Schema.Properties, FDisplayedProperties, AddedComponent.CustomProperties, TypeIndexInSel);
      PerformAddToSelOperation(AllComponents[ComponentTypeIndex].Schema.Events, FDisplayedEvents, AddedComponent.CustomEvents, TypeIndexInSel);
      AddTypeToSelection(ComponentType);

      if (Length(FSelectedTypes) > 1) or (Length(FSelectedPanels) > 1) then
      begin
        RebuildDisplayedMixedValues(FSelectedPanels, AllComponents, AllVisualComponents, FDisplayedProperties, False);
        RebuildDisplayedMixedValues(FSelectedPanels, AllComponents, AllVisualComponents, FDisplayedEvents, True);
      end;
    end; //soAdd

    soRemove:
    begin
      {SelectedComponentsCountOfRemovingType := CountSelectedComponentsByType(ComponentType);
      if SelectedComponentsCountOfRemovingType = 1 then
        RemoveTypeFromSelection(ComponentType);}
        
      SetLength(FSelectedTypes, 0);
      SetLength(FDisplayedProperties, 0);
      SetLength(FDisplayedEvents, 0);
  
      for i := 0 to Length(FSelectedPanels) - 1 do
      begin
        CurrentVisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, FSelectedPanels[i]);
        ComponentTypeIndex := CurrentVisualComponent.IndexInTDynTFTDesignAllComponentsArr;
        ComponentType := GetTypeFromVisualComponent(AllComponents, AllVisualComponents, CurrentVisualComponent);
        TypeIndexInSel := GetTypeIndexInSelection(ComponentType);
        AddedComponent := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[CurrentVisualComponent.IndexInDesignComponentOneKindArr];

        PerformAddToSelOperation(AllComponents[ComponentTypeIndex].Schema.Properties, FDisplayedProperties, AddedComponent.CustomProperties, TypeIndexInSel);
        PerformAddToSelOperation(AllComponents[ComponentTypeIndex].Schema.Events, FDisplayedEvents, AddedComponent.CustomEvents, TypeIndexInSel);
        AddTypeToSelection(ComponentType);
      end;

      RebuildDisplayedMixedValues(FSelectedPanels, AllComponents, AllVisualComponents, FDisplayedProperties, False);
      RebuildDisplayedMixedValues(FSelectedPanels, AllComponents, AllVisualComponents, FDisplayedEvents, True);
    end;

    soUpdateProp:
    begin
      ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;
      AddedComponent := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr];
      
      SetSelToComponent(FDisplayedProperties, AddedComponent.CustomProperties, rmvLeave);
      SetSelToComponent(FDisplayedEvents, AddedComponent.CustomEvents, rmvLeave);
    end;

    soSetSelToComponent:
    begin
      ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;
      AddedComponent := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr];
      
      SetSelToComponent(FDisplayedProperties, AddedComponent.CustomProperties, rmvReset);
      SetSelToComponent(FDisplayedEvents, AddedComponent.CustomEvents, rmvReset);
    end;
  end;
end;


function TSelectionContent.GetPropertyIndexByName(ObjectInspectorType: Integer; PropertyName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  case ObjectInspectorType of
    CObjectInspector_PropertySel:
      for i := 0 to Length(FDisplayedProperties) do
        if FDisplayedProperties[i].PropertyName = PropertyName then
        begin
          Result := i;
          Exit;
        end;

    CObjectInspector_EventSel:
      for i := 0 to Length(FDisplayedEvents) do
        if FDisplayedEvents[i].PropertyName = PropertyName then
        begin
          Result := i;
          Exit;
        end;
  end;
end;


function TSelectionContent.GetPropertyName(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;

  try
    case ObjectInspectorType of
      CObjectInspector_PropertySel:
        Result := FDisplayedProperties[Index].PropertyName;

      CObjectInspector_EventSel:
        Result := FDisplayedEvents[Index].PropertyName;
    else
      Result := 'PropertyName';
    end;
  except
    Result := 'Bug'; //There is a bug, that causes FDisplayedProperties / FDisplayedEvents to be empty.
  end;
end;


function TSelectionContent.GetPropertyValue(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;

  try
    case ObjectInspectorType of
      CObjectInspector_PropertySel:
        if FDisplayedProperties[Index].DisplayAsMixedValues then
          Result := CMixedValues
        else
          Result := FDisplayedProperties[Index].PropertyValue;

      CObjectInspector_EventSel:
        if FDisplayedEvents[Index].DisplayAsMixedValues then
          Result := CMixedValues
        else
          Result := FDisplayedEvents[Index].PropertyValue;
    else
      Result := 'PropertyValue';
    end;
  except
    Result := 'Bug'; //There is a bug, that causes FDisplayedProperties / FDisplayedEvents to be empty.
  end;
end;


function TSelectionContent.GetPropertyDataType(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;

  try
    case ObjectInspectorType of
      CObjectInspector_PropertySel:
        Result := FDisplayedProperties[Index].PropertyDataType;

      CObjectInspector_EventSel:
        Result := FDisplayedEvents[Index].PropertyDataType;
    else
      Result := 'PropertyDataType';
    end;
  except
    Result := 'Unknown'; //There is a bug, that causes FDisplayedProperties / FDisplayedEvents to be empty.
  end;
end;


function TSelectionContent.GetPropertyAvailableOnCompilerDirectives(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;
  
  case ObjectInspectorType of
    CObjectInspector_PropertySel:
      if FDisplayedProperties[Index].DisplayAsMixedDirectiveAvailability then
        Result := CMixedValues
      else
        Result := FDisplayedProperties[Index].AvailableOnCompilerDirectives;

    CObjectInspector_EventSel:
      if FDisplayedEvents[Index].DisplayAsMixedDirectiveAvailability then
        Result := CMixedValues
      else
        Result := FDisplayedEvents[Index].AvailableOnCompilerDirectives;
  else
    Result := 'AvailableOnCompilerDirectives';
  end;
end;


function TSelectionContent.GetPropertyDescription(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;

  case ObjectInspectorType of
    CObjectInspector_PropertySel:
      if FDisplayedProperties[Index].DisplayAsMixedDescription then
        Result := CMixedValues
      else
        Result := FDisplayedProperties[Index].PropertyDescription;

    CObjectInspector_EventSel:
      if FDisplayedEvents[Index].DisplayAsMixedDescription then
        Result := CMixedValues
      else
        Result := FDisplayedEvents[Index].PropertyDescription;
  else
    Result := 'PropertyDescription';
  end;
end;


function TSelectionContent.GetPropertyDesignTimeOnly(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;

  case ObjectInspectorType of
    CObjectInspector_PropertySel:
      if FDisplayedProperties[Index].DisplayAsMixedLocation then
        Result := CMixedValues
      else
        Result := BoolToStr(FDisplayedProperties[Index].DesignTimeOnly, True);

    CObjectInspector_EventSel:
      if FDisplayedEvents[Index].DisplayAsMixedLocation then
        Result := CMixedValues
      else
        Result := BoolToStr(FDisplayedEvents[Index].DesignTimeOnly, True);
  else
    Result := 'PropertyLocation';
  end;
end;


function TSelectionContent.GetPropertyReadOnly(ObjectInspectorType: Integer; Index: Integer): string;
begin
  if (Length(FDisplayedProperties) = 0) or (Length(FDisplayedEvents) = 0) then
  begin
    Result := 'bug';
    Exit;
  end;

  case ObjectInspectorType of
    CObjectInspector_PropertySel:
      if FDisplayedProperties[Index].DisplayAsMixedReadOnly then
        Result := CMixedValues
      else
        Result := BoolToStr(FDisplayedProperties[Index].ReadOnly, True);

    CObjectInspector_EventSel:
      if FDisplayedEvents[Index].DisplayAsMixedReadOnly then
        Result := CMixedValues
      else
        Result := BoolToStr(FDisplayedEvents[Index].ReadOnly, True);
  else
    Result := 'PropertyReadOnly';
  end;
end;


procedure TSelectionContent.UpdateComponentsWithPropertyValue(var AllComponents: TDynTFTDesignAllComponentsArr; var AllVisualComponents: TProjectVisualComponentArr; ObjectInspectorType: Integer; IndexInSel: Integer; NewValue: string);
var
  i, j: Integer;
  ComponentTypeIndex: Integer;
  VisualComponent: TProjectVisualComponent;
  AComp: TDynTFTDesignComponentOneKind;
  //CompScreenIndex: Integer;
  ConstraintIndexInSel: Integer;
begin
  for i := 0 to Length(FSelectedPanels) - 1 do
  begin
    VisualComponent := GetVisualComponentFromPanel(AllComponents, AllVisualComponents, FSelectedPanels[i]);
    ComponentTypeIndex := VisualComponent.IndexInTDynTFTDesignAllComponentsArr;
    AComp := AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr];

    case ObjectInspectorType of
      CObjectInspector_PropertySel:
      begin
        {CompScreenIndex := -2;

        for j := 0 to Length(AComp.CustomProperties) - 1 do
          if AComp.CustomProperties[j].PropertyName = 'ScreenIndex' then
          begin
            CompScreenIndex := StrToIntDef(AComp.CustomProperties[j].PropertyValue, -3);
            Break;
          end;}

        for j := 0 to Length(AComp.CustomProperties) - 1 do
          if AComp.CustomProperties[j].PropertyName = FDisplayedProperties[IndexInSel].PropertyName then
          begin
            AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomProperties[j].PropertyValue := NewValue;
            FDisplayedProperties[IndexInSel].PropertyValue := NewValue;
            FDisplayedProperties[IndexInSel].DisplayAsMixedValues := False;

            if AComp.CustomProperties[j].PropertyName = 'Left' then
              FSelectedPanels[i].Left := StrToIntDef(NewValue, FSelectedPanels[i].Left);

            if AComp.CustomProperties[j].PropertyName = 'Top' then
              FSelectedPanels[i].Top := StrToIntDef(NewValue, FSelectedPanels[i].Top);

            if AComp.CustomProperties[j].PropertyName = 'Width' then
            begin
              FSelectedPanels[i].Width := StrToIntDef(NewValue, FSelectedPanels[i].Width);  //constrained by panel
              AComp.CustomProperties[GetPropertyIndexInPropertiesOrEventsByName(AComp.CustomProperties, 'Width')].PropertyValue := IntToStr(FSelectedPanels[i].Width);
            end;

            if AComp.CustomProperties[j].PropertyName = 'Height' then
            begin
              FSelectedPanels[i].Height := StrToIntDef(NewValue, FSelectedPanels[i].Height); //constrained by panel
              AComp.CustomProperties[GetPropertyIndexInPropertiesOrEventsByName(AComp.CustomProperties, 'Height')].PropertyValue := IntToStr(FSelectedPanels[i].Height);
            end;

            if AComp.CustomProperties[j].PropertyName = 'MinWidth' then
            begin
              FSelectedPanels[i].Constraints.MinWidth := StrToIntDef(NewValue, FSelectedPanels[i].Constraints.MinWidth);
              if FSelectedPanels[i].Constraints.MinWidth <> 0 then
              begin
                ConstraintIndexInSel := GetPropertyIndexByName(ObjectInspectorType, 'Width');

                if StrToIntDef(FDisplayedProperties[ConstraintIndexInSel].PropertyValue, 2) < FSelectedPanels[i].Constraints.MinWidth then
                begin
                  AComp.CustomProperties[GetPropertyIndexInPropertiesOrEventsByName(AComp.CustomProperties, 'Width')].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MinWidth);
                  FDisplayedProperties[ConstraintIndexInSel].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MinWidth);
                end;
              end;
            end;

            if AComp.CustomProperties[j].PropertyName = 'MaxWidth' then
            begin
              FSelectedPanels[i].Constraints.MaxWidth := StrToIntDef(NewValue, FSelectedPanels[i].Constraints.MaxWidth);
              if FSelectedPanels[i].Constraints.MaxWidth <> 0 then
              begin
                ConstraintIndexInSel := GetPropertyIndexByName(ObjectInspectorType, 'Width');

                if StrToIntDef(FDisplayedProperties[ConstraintIndexInSel].PropertyValue, 2) > FSelectedPanels[i].Constraints.MaxWidth then
                begin
                  AComp.CustomProperties[GetPropertyIndexInPropertiesOrEventsByName(AComp.CustomProperties, 'Width')].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MaxWidth);
                  FDisplayedProperties[ConstraintIndexInSel].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MaxWidth);
                end;
              end;
            end;

            if AComp.CustomProperties[j].PropertyName = 'MinHeight' then
            begin
              FSelectedPanels[i].Constraints.MinHeight := StrToIntDef(NewValue, FSelectedPanels[i].Constraints.MinHeight);
              if FSelectedPanels[i].Constraints.MinHeight <> 0 then
              begin
                ConstraintIndexInSel := GetPropertyIndexByName(ObjectInspectorType, 'Height');

                if StrToIntDef(FDisplayedProperties[ConstraintIndexInSel].PropertyValue, 2) < FSelectedPanels[i].Constraints.MinHeight then
                begin
                  AComp.CustomProperties[GetPropertyIndexInPropertiesOrEventsByName(AComp.CustomProperties, 'Height')].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MinHeight);
                  FDisplayedProperties[ConstraintIndexInSel].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MinHeight);
                end;
              end;
            end;

            if AComp.CustomProperties[j].PropertyName = 'MaxHeight' then
            begin
              FSelectedPanels[i].Constraints.MaxHeight := StrToIntDef(NewValue, FSelectedPanels[i].Constraints.MaxHeight);
              if FSelectedPanels[i].Constraints.MaxHeight <> 0 then
              begin
                ConstraintIndexInSel := GetPropertyIndexByName(ObjectInspectorType, 'Height');

                if StrToIntDef(FDisplayedProperties[ConstraintIndexInSel].PropertyValue, 2) > FSelectedPanels[i].Constraints.MaxHeight then
                begin
                  AComp.CustomProperties[GetPropertyIndexInPropertiesOrEventsByName(AComp.CustomProperties, 'Height')].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MaxHeight);
                  FDisplayedProperties[ConstraintIndexInSel].PropertyValue := IntToStr(FSelectedPanels[i].Constraints.MaxHeight);
                end;
              end;
            end;

            if AComp.CustomProperties[j].PropertyName = 'ObjectName' then
            begin
              FSelectedPanels[i].Caption := NewValue;
              AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].ObjectName := NewValue;
            end;

            DoOnUpdateSpecialProperty(j,
                                      AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr],
                                      AComp.CustomProperties[j].PropertyName,
                                      NewValue);

            if AComp.CustomProperties[j].PropertyName = 'Locked' then
            begin
              if NewValue = 'True' then
              begin
                FSelectedPanels[i].Cursor := crNo;

                FSelectedPanels[i].TopLeftLabel.Enabled := False;
                FSelectedPanels[i].TopRightLabel.Enabled := False;
                FSelectedPanels[i].BotLeftLabel.Enabled := False;
                FSelectedPanels[i].BotRightLabel.Enabled := False;

                FSelectedPanels[i].LeftLabel.Enabled := False;
                FSelectedPanels[i].TopLabel.Enabled := False;
                FSelectedPanels[i].RightLabel.Enabled := False;
                FSelectedPanels[i].BotLabel.Enabled := False;
              end
              else
              begin
                if FSelectedPanels[i].Cursor <> crDefault then
                  FSelectedPanels[i].Cursor := crDefault;

                FSelectedPanels[i].TopLeftLabel.Enabled := True;
                FSelectedPanels[i].TopRightLabel.Enabled := True;
                FSelectedPanels[i].BotLeftLabel.Enabled := True;
                FSelectedPanels[i].BotRightLabel.Enabled := True;

                FSelectedPanels[i].LeftLabel.Enabled := True;
                FSelectedPanels[i].TopLabel.Enabled := True;
                FSelectedPanels[i].RightLabel.Enabled := True;
                FSelectedPanels[i].BotLabel.Enabled := True;
              end;
            end;
                
            Break;
          end;
      end;

      CObjectInspector_EventSel:
      begin
        for j := 0 to Length(AComp.CustomEvents) - 1 do
          if AComp.CustomEvents[j].PropertyName = FDisplayedEvents[IndexInSel].PropertyName then
          begin
            //AComp.CustomEvents[j].PropertyValue := NewValue;
            AllComponents[ComponentTypeIndex].DesignComponentsOneKind[VisualComponent.IndexInDesignComponentOneKindArr].CustomEvents[j].PropertyValue := NewValue;
            FDisplayedEvents[IndexInSel].PropertyValue := NewValue;
            FDisplayedEvents[IndexInSel].DisplayAsMixedValues := False;
            
            Break;
          end;
      end;
    end; //case
  end;
end;


function TSelectionContent.GetDisplayedPropertiesCount: Integer; //used by ObjectInspector
begin
  Result := Length(FDisplayedProperties);
end;


function TSelectionContent.GetDisplayedEventsCount: Integer;    //used by ObjectInspector
begin
  Result := Length(FDisplayedEvents);
end;


function TSelectionContent.GetSelectedCount: Integer;
begin
  Result := Length(FSelectedPanels);
end;


function TSelectionContent.GetSelectedPanelByIndex(AIndex: Integer): TMountPanel;
begin
  if (AIndex < 0) or (AIndex > Length(FSelectedPanels) - 1) then
    raise Exception.Create('Index out of bound when getting selected panel by index.');

  Result := FSelectedPanels[AIndex];
end;


function TSelectionContent.PanelInSelection(APanel: TMountPanel): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Length(FSelectedPanels) - 1 do
    if FSelectedPanels[i] = APanel then
    begin
      Result := True;
      Exit;
    end;
end;



constructor TSaveFileStringList.Create;
begin
  FString := '';
end;


procedure TSaveFileStringList.Add(s: string);
begin
  FString := FString + s + #13#10;
end;


procedure TSaveFileStringList.SaveToFile(AFileName: string);   //no unicode support so far
var
  AStream: TFileStream;   
begin
  AStream := TFileStream.Create(AFileName, fmOpenWrite or fmCreate);
  try
    AStream.Position := 0;
    AStream.Write(FString[1], Length(FString));
    AStream.Position := 0;
  finally
    AStream.Free;
  end;
end;


end.
