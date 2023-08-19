{
    Copyright (C) 2022 VCC
    creation date: Aug 2023   (2023.08.17)
    initial release date: 18 Aug 2023

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


unit DrawingBoardSchemaEditorFrame;

{$mode Delphi}{$H+}

interface

uses
  LCLIntf, LCLType, Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Graphics,
  IniFiles, VirtualTrees, ImgList, SynHighlighterPas, SynEdit, Menus,
  ObjectInspectorFrame, DrawingBoardSchemaEditorUtils;

type
  TDrawingBoardSchemaCategory = record
    Items: array of TStringArr; //e.g. 'Prop_', 'Const_', 'Line_', 'Comp_'  - every item is a group of properties
    CachedIndexOfName: Integer; //index of Name property (usually 0)
    //other fields
  end;

  TDrawingBoardProject = record
    DrawingBoardMetaSchemaFileName: string; //file name used when calling LoadDrawingBoardSchema
    ProjectFileName: string;
    DrawingBoardMetaSchema: TDrawingBoardMetaSchema;
    CategoryContents: array of TDrawingBoardSchemaCategory;   //Key=value pairs for every category and its group of properties
  end;

  TOnDrawingBoardModified = procedure of object;

  { TfrDrawingBoardSchemaEditor }

  TfrDrawingBoardSchemaEditor = class(TFrame)
    lblSpacingInfo: TLabel;
    MenuItem_RemoveAllProperties: TMenuItem;
    MenuItem_RemoveProperty: TMenuItem;
    MenuItem_AddProperty: TMenuItem;
    pnlHorizSplitter: TPanel;
    pnlSchemaOI: TPanel;
    pmCategories: TPopupMenu;
    pmProperties: TPopupMenu;
    synedtCode: TSynEdit;
    SynPasSyn1: TSynPasSyn;

    procedure FrameResize(Sender: TObject);
    procedure MenuItem_AddPropertyClick(Sender: TObject);
    procedure MenuItem_RemoveAllPropertiesClick(Sender: TObject);
    procedure MenuItem_RemovePropertyClick(Sender: TObject);
    procedure pnlHorizSplitterMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlHorizSplitterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnlHorizSplitterMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure synedtCodeChange(Sender: TObject);
  private
    FLastClickedCategory, FLastClickedProperty, FLastClickedPropertyItem: Integer;
    FPropertyNameString: string;
    FHold: Boolean;
    FSplitterMouseDownGlobalPos: TPoint;
    FSplitterMouseDownImagePos: TPoint;

    FProject: TDrawingBoardProject;
    FOIFrame: TfrObjectInspector;

    FOnDrawingBoardModified: TOnDrawingBoardModified;

    procedure DoOnDrawingBoardModified;

    procedure CreateRemainingComponents;
    procedure ResizeFrameSectionsBySplitter(NewLeft: Integer);
    procedure MoveProperty(CategoryIndex, SrcPropertyIndex, DestPropertyIndex: Integer);

    function HandleOnOIGetCategoryCount: Integer;
    function HandleOnOIGetCategory(AIndex: Integer): string;
    function HandleOnOIGetCategoryValue(ACategoryIndex: Integer; var AEditorType: TOIEditorType): string;
    function HandleOnOIGetPropertyCount(ACategoryIndex: Integer): Integer;
    function HandleOnOIGetPropertyName(ACategoryIndex, APropertyIndex: Integer): string;
    function HandleOnOIGetPropertyValue(ACategoryIndex, APropertyIndex: Integer; var AEditorType: TOIEditorType): string;
    function HandleOnOIGetListPropertyItemCount(ACategoryIndex, APropertyIndex: Integer): Integer;
    function HandleOnOIGetListPropertyItemName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
    function HandleOnOIGetListPropertyItemValue(ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AEditorType: TOIEditorType): string;
    function HandleOnUIGetDataTypeName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
    function HandleOnUIGetExtraInfo(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;

    procedure HandleOnOIGetImageIndexEx(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; Kind: TVTImageKind;
      Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList);
    procedure HandleOnOIEditedText(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; ANewText: string);
    function HandleOnOIEditItems(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewItems: string): Boolean;

    function HandleOnOIGetColorConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
    procedure HandleOnOIGetColorConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AColorItemIndex: Integer; var AColorName: string; var AColorValue: Int64);

    function HandleOnOIGetEnumConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
    procedure HandleOnOIGetEnumConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AEnumItemIndex: Integer; var AEnumItemName: string);

    procedure HandleOnOIPaintText(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
      const TargetCanvas: TCanvas; Column: TColumnIndex; var TextType: TVSTTextType);

    procedure HandleOnOIBeforeCellPaint(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
      TargetCanvas: TCanvas; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);

    procedure HandleOnTextEditorMouseDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    function HandleOnTextEditorMouseMove(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
      Sender: TObject; Shift: TShiftState; X, Y: Integer): Boolean;

    procedure HandleOnOITextEditorKeyUp(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
      Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure HandleOnOITextEditorKeyDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
      Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure HandleOnOIEditorAssignMenuAndTooltip(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
      Sender: TObject; var APopupMenu: TPopupMenu; var AHint: string; var AShowHint: Boolean);

    procedure HandleOnOIGetFileDialogSettings(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AFilter, AInitDir: string);
    procedure HandleOnOIArrowEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer);
    procedure HandleOnOIUserEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ARepaintValue: Boolean);

    function HandleOnOIBrowseFile(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
      AFilter, ADialogInitDir: string; var Handled: Boolean; AReturnMultipleFiles: Boolean = False): string;

    procedure HandleOnOIAfterSpinTextEditorChanging(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewValue: string);
    procedure HandleOnOISelectedNode(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure HandleOnOIDragAllowed(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex: Integer; var Allowed: Boolean);
    procedure HandleOnOIDragOver(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; State: TDragState; const Pt: TPoint; Mode: TDropMode; var Effect: DWORD; var Accept: Boolean);
    procedure HandleOnOIDragDrop(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; const Pt: TPoint; var Effect: DWORD; Mode: TDropMode);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearContent;

    procedure LoadDrawingBoardProject(AFnm: string); //for DynTFTCodeGen, this is a .dynscm file
    procedure SaveDrawingBoardProject(AFnm: string);
    procedure SetMetaSchemaFromFile(ADrbSchemaFnm: string);
    function GetIndexOfDrawingBoardMetaSchemaCategory: Integer;

    property Project: TDrawingBoardProject read FProject write FProject;
    property PropertyNameString: string read FPropertyNameString write FPropertyNameString;

    property OnDrawingBoardModified: TOnDrawingBoardModified write FOnDrawingBoardModified;
  end;

implementation

{$R *.frm}


procedure TfrDrawingBoardSchemaEditor.CreateRemainingComponents;
begin
  FOIFrame := TfrObjectInspector.Create(Self);
  FOIFrame.Left := 0;
  FOIFrame.Top := 0;
  FOIFrame.Width := pnlSchemaOI.Width;
  FOIFrame.Height := pnlSchemaOI.Height;
  FOIFrame.Anchors := [akBottom, akLeft, akRight, akTop];
  FOIFrame.Parent := pnlSchemaOI;

  FOIFrame.OnOIGetCategoryCount := HandleOnOIGetCategoryCount;
  FOIFrame.OnOIGetCategory := HandleOnOIGetCategory;
  FOIFrame.OnOIGetCategoryValue := HandleOnOIGetCategoryValue;
  FOIFrame.OnOIGetPropertyCount := HandleOnOIGetPropertyCount;
  FOIFrame.OnOIGetPropertyName := HandleOnOIGetPropertyName;
  FOIFrame.OnOIGetPropertyValue := HandleOnOIGetPropertyValue;
  FOIFrame.OnOIGetListPropertyItemCount := HandleOnOIGetListPropertyItemCount;
  FOIFrame.OnOIGetListPropertyItemName := HandleOnOIGetListPropertyItemName;
  FOIFrame.OnOIGetListPropertyItemValue := HandleOnOIGetListPropertyItemValue;
  FOIFrame.OnUIGetDataTypeName := HandleOnUIGetDataTypeName;
  FOIFrame.OnUIGetExtraInfo := HandleOnUIGetExtraInfo;
  FOIFrame.OnOIGetImageIndexEx := HandleOnOIGetImageIndexEx;
  FOIFrame.OnOIEditedText := HandleOnOIEditedText;
  FOIFrame.OnOIEditItems := HandleOnOIEditItems;
  FOIFrame.OnOIGetColorConstsCount := HandleOnOIGetColorConstsCount;
  FOIFrame.OnOIGetColorConst := HandleOnOIGetColorConst;
  FOIFrame.OnOIGetEnumConstsCount := HandleOnOIGetEnumConstsCount;
  FOIFrame.OnOIGetEnumConst := HandleOnOIGetEnumConst;
  FOIFrame.OnOIPaintText := HandleOnOIPaintText;
  FOIFrame.OnOIBeforeCellPaint := HandleOnOIBeforeCellPaint;
  FOIFrame.OnOITextEditorMouseDown := HandleOnTextEditorMouseDown;
  FOIFrame.OnOITextEditorMouseMove := HandleOnTextEditorMouseMove;
  FOIFrame.OnOITextEditorKeyUp := HandleOnOITextEditorKeyUp;
  FOIFrame.OnOITextEditorKeyDown := HandleOnOITextEditorKeyDown;
  FOIFrame.OnOIEditorAssignMenuAndTooltip := HandleOnOIEditorAssignMenuAndTooltip;
  FOIFrame.OnOIGetFileDialogSettings := HandleOnOIGetFileDialogSettings;
  FOIFrame.OnOIArrowEditorClick := HandleOnOIArrowEditorClick;
  FOIFrame.OnOIUserEditorClick := HandleOnOIUserEditorClick;
  FOIFrame.OnOIBrowseFile := HandleOnOIBrowseFile;
  FOIFrame.OnOIAfterSpinTextEditorChanging := HandleOnOIAfterSpinTextEditorChanging;
  FOIFrame.OnOISelectedNode := HandleOnOISelectedNode;
  FOIFrame.OnOIDragAllowed := HandleOnOIDragAllowed;
  FOIFrame.OnOIDragOver := HandleOnOIDragOver;
  FOIFrame.OnOIDragDrop := HandleOnOIDragDrop;

  FOIFrame.Visible := True;

  FOIFrame.ListItemsVisible := True;
  FOIFrame.DataTypeVisible := False;
  FOIFrame.ExtraInfoVisible := False;
  FOIFrame.PropertyItemHeight := 22; //50;  //this should be 50 for bitmaps
  FOIFrame.ColumnWidths[0] := 288;
  FOIFrame.ColumnWidths[1] := 800;
end;


constructor TfrDrawingBoardSchemaEditor.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FProject.DrawingBoardMetaSchema.FileTitle := '';
  SetLength(FProject.DrawingBoardMetaSchema.Categories, 0);
  SetLength(FProject.CategoryContents, 0);

  FHold := False;

  CreateRemainingComponents;
end;


destructor TfrDrawingBoardSchemaEditor.Destroy;
begin
  ClearContent;
  inherited Destroy;
end;


procedure TfrDrawingBoardSchemaEditor.DoOnDrawingBoardModified;
begin
  if not Assigned(FOnDrawingBoardModified) then
    raise Exception.Create('OnDrawingBoardModified is not assigned.');

  FOnDrawingBoardModified();
end;


procedure TfrDrawingBoardSchemaEditor.ClearContent;
var
  i, j: Integer;
begin
  ClearDrawingBoardMetaSchema(FProject.DrawingBoardMetaSchema);

  for i := 0 to Length(FProject.CategoryContents) - 1 do
  begin
    for j := 0 to Length(FProject.CategoryContents[i].Items) - 1 do
      SetLength(FProject.CategoryContents[i].Items[j], 0);

    SetLength(FProject.CategoryContents[i].Items, 0);
  end;

  SetLength(FProject.CategoryContents, 0);
  FOIFrame.ReloadContent;
  synedtCode.Clear;

  FProject.ProjectFileName := '';
  FProject.DrawingBoardMetaSchemaFileName := '';
  FLastClickedCategory := -1;
  FLastClickedProperty := -1;
  FLastClickedPropertyItem := -1;
end;


procedure TfrDrawingBoardSchemaEditor.LoadDrawingBoardProject(AFnm: string); //for DynTFTCodeGen, this is a .dynscm file
var
  Ini: TMemIniFile;
  i, j, k, CategoryCount, CountableCount: Integer;
  CatName, CountKey, ItemKey: string;
  InitialDBSchFileName, FullDBSchFileName: string;
begin
  ClearContent;

  Ini := TMemIniFile.Create(AFnm);
  try
    FProject.ProjectFileName := AFnm;
    InitialDBSchFileName := Ini.ReadString(CDrawingBoardMetaSchemaKeyName, 'FileName', '');
    FProject.DrawingBoardMetaSchemaFileName := InitialDBSchFileName;
    FullDBSchFileName := StringReplace(InitialDBSchFileName, CSelfDir, ExtractFileDir(AFnm), [rfReplaceAll]);

    if not FileExists(FullDBSchFileName) then
    begin
      MessageBox(Handle,
                 PChar('DrawingBoard schema file is not set in project file.' + #13#10 +
                       'It is expected to be of "FileName=<[PathToFile\]Filename>" format (without quotes), under the "DrawingBoardSchema" section.'),
                 PChar(Application.Title),
                 MB_ICONERROR);
      Exit;
    end;

    LoadDrawingBoardMetaSchema(FullDBSchFileName, FProject.DrawingBoardMetaSchema);

    CategoryCount := Length(FProject.DrawingBoardMetaSchema.Categories);
    SetLength(FProject.CategoryContents, CategoryCount);

    for i := 0 to CategoryCount - 1 do
    begin
      CatName := FProject.DrawingBoardMetaSchema.Categories[i].Name;  //e.g.: ComponentPropertiesSchema, ComponentEventsPropertiesSchema, Constants, ColorConstants
      CountKey := FProject.DrawingBoardMetaSchema.Categories[i].Item_CountKey;  //name of the "Count" key - this is usually "Count"

      case FProject.DrawingBoardMetaSchema.Categories[i].StructureType of
        stCountable:
        begin
          SetLength(FProject.CategoryContents[i].Items, Ini.ReadInteger(CatName, CountKey, 0));  //number of counted item groups, or lines of code, or misc keys
          CountableCount := Length(FProject.CategoryContents[i].Items);
        end;

        stCode:
        begin
          SetLength(FProject.CategoryContents[i].Items, 1);
          SetLength(FProject.CategoryContents[i].Items[0], Ini.ReadInteger(CatName, CountKey, 0));
          CountableCount := Length(FProject.CategoryContents[i].Items[0]);
        end;

        stMisc:
        begin
          SetLength(FProject.CategoryContents[i].Items, 1);
          SetLength(FProject.CategoryContents[i].Items[0], Length(FProject.DrawingBoardMetaSchema.Categories[i].Items));  //number of misc items
          CountableCount := Length(FProject.CategoryContents[i].Items[0]);
        end;   //SetLength commented, because there is a similar code below
      end;

      CountableCount := Length(FProject.DrawingBoardMetaSchema.Categories[i].Items);

      case FProject.DrawingBoardMetaSchema.Categories[i].StructureType of
        stCountable:
        begin
          for j := 0 to Length(FProject.CategoryContents[i].Items) - 1 do   //number of counted item groups
          begin
            SetLength(FProject.CategoryContents[i].Items[j], CountableCount);

            FProject.CategoryContents[i].CachedIndexOfName := -1;
            for k := 0 to Length(FProject.CategoryContents[i].Items[j]) - 1 do
            begin
              ItemKey := StringReplace(FProject.DrawingBoardMetaSchema.Categories[i].Items[k].Value, CIndexReplacement, IntToStr(j), [rfReplaceAll]);
              FProject.CategoryContents[i].Items[j][k] := Ini.ReadString(CatName, ItemKey, '');

              if Pos(FPropertyNameString, FProject.DrawingBoardMetaSchema.Categories[i].Items[k].Value) > 0 then
                FProject.CategoryContents[i].CachedIndexOfName := k;
            end;
          end;
        end;

        stCode:
        begin
          for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          begin
            ItemKey := FProject.DrawingBoardMetaSchema.Categories[i].Items[0].Value;
            ItemKey := StringReplace(ItemKey, CIndexReplacement, IntToStr(k), [rfReplaceAll]);
            FProject.CategoryContents[i].Items[0][k] := Ini.ReadString(CatName, ItemKey, '');
          end;
        end;

        stMisc:
        begin
          for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          begin
            ItemKey := FProject.DrawingBoardMetaSchema.Categories[i].Items[k].Value; //here it is Items[k]
            ItemKey := StringReplace(ItemKey, CIndexReplacement, IntToStr(k), [rfReplaceAll]);
            FProject.CategoryContents[i].Items[0][k] := Ini.ReadString(CatName, ItemKey, '');
          end;
        end;
      end; //case
    end;  //for i
  finally
    Ini.Free;
  end;

  FOIFrame.ReloadContent;
end;


function TfrDrawingBoardSchemaEditor.GetIndexOfDrawingBoardMetaSchemaCategory: Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(FProject.DrawingBoardMetaSchema.Categories) - 1 do
    if FProject.DrawingBoardMetaSchema.Categories[i].Name = CDrawingBoardMetaSchemaKeyName then
    begin
      Result := i;
      Exit;
    end;
end;


procedure TfrDrawingBoardSchemaEditor.SaveDrawingBoardProject(AFnm: string);
var
  s: string;
  i, j, k, n: Integer;
  Content: TMemoryStream;
begin
  if GetIndexOfDrawingBoardMetaSchemaCategory = -1 then
    s := '[' + CDrawingBoardMetaSchemaKeyName + ']' + #13#10 +
        'FileName=' + FProject.DrawingBoardMetaSchemaFileName + #13#10#13#10
  else
    s := '';

  n := Length(FProject.DrawingBoardMetaSchema.Categories);

  for i := 0 to n - 1 do
  begin
    s := s + '[' + FProject.DrawingBoardMetaSchema.Categories[i].Name + ']' + #13#10;
    s := s + ';' + FProject.DrawingBoardMetaSchema.Categories[i].CategoryComment + #13#10;

    case FProject.DrawingBoardMetaSchema.Categories[i].StructureType of
      stCountable:
        s := s + FProject.DrawingBoardMetaSchema.Categories[i].Item_CountKey + '=' + IntToStr(Length(FProject.CategoryContents[i].Items)) + #13#10;

      stCode:
        s := s + FProject.DrawingBoardMetaSchema.Categories[i].Item_CountKey + '=' + IntToStr(Length(FProject.CategoryContents[i].Items[0])) + #13#10;

      stMisc:;
    end;

    case FProject.DrawingBoardMetaSchema.Categories[i].StructureType of
      stCountable:
      begin
        for j := 0 to Length(FProject.CategoryContents[i].Items) - 1 do
          for k := 0 to Length(FProject.CategoryContents[i].Items[j]) - 1 do
            s := s + StringReplace(FProject.DrawingBoardMetaSchema.Categories[i].Items[k].Value, CIndexReplacement, IntToStr(j), [rfReplaceAll]) + '=' + FProject.CategoryContents[i].Items[j][k] + #13#10;
      end;

      stCode:
      begin
        for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          s := s + StringReplace(FProject.DrawingBoardMetaSchema.Categories[i].Items[0].Value, CIndexReplacement, IntToStr(k), [rfReplaceAll]) + '=' + FProject.CategoryContents[i].Items[0][k] + #13#10;
      end;

      stMisc:
      begin
        for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          s := s + StringReplace(FProject.DrawingBoardMetaSchema.Categories[i].Items[k].Value, CIndexReplacement, IntToStr(k), [rfReplaceAll]) + '=' + FProject.CategoryContents[i].Items[0][k] + #13#10;
      end;
    end; //case

    if i < n - 1 then
      s := s + #13#10;
  end;

  Content := TMemoryStream.Create;
  try
    Content.Write(s[1], Length(s));
  finally
    FProject.ProjectFileName := AFnm;
    Content.SaveToFile(AFnm);
  end;
end;


procedure TfrDrawingBoardSchemaEditor.SetMetaSchemaFromFile(ADrbSchemaFnm: string);
var
  CategoryCount, i, CategoryIndex: Integer;
begin
  ClearContent;

  FProject.DrawingBoardMetaSchemaFileName := StringReplace(ADrbSchemaFnm, ExtractFileDir(FProject.ProjectFileName), CSelfDir, [rfReplaceAll]);
  LoadDrawingBoardMetaSchema(ADrbSchemaFnm, FProject.DrawingBoardMetaSchema);

  CategoryIndex := GetIndexOfDrawingBoardMetaSchemaCategory;
  if CategoryIndex <> -1 then
  begin                /////////////// ToDo  get index of FileName property and update AItemIndex    (it is usually 0)
    //FProject.CategoryContents[CategoryIndex].Items[0][AItemIndex] := FProject.DrawingBoardMetaSchemaFileName;   //AItemIndex should be the index of FileName property
    MessageBox(Handle, PChar('Make sure you update the FilePath property, under ' + CDrawingBoardMetaSchemaKeyName + ' category.'), PChar(Application.Title), MB_ICONINFORMATION);
  end;

  CategoryCount := Length(FProject.DrawingBoardMetaSchema.Categories);
  SetLength(FProject.CategoryContents, CategoryCount);

  for i := 0 to CategoryCount - 1 do
  begin
    case FProject.DrawingBoardMetaSchema.Categories[i].StructureType of
      stCountable:
      begin
        SetLength(FProject.CategoryContents[i].Items, 0);  //number of counted item groups, or lines of code, or misc keys
      end;

      stCode:
      begin
        SetLength(FProject.CategoryContents[i].Items, 1);
        SetLength(FProject.CategoryContents[i].Items[0], 0);
      end;

      stMisc:
      begin
        SetLength(FProject.CategoryContents[i].Items, 1);
        SetLength(FProject.CategoryContents[i].Items[0], Length(FProject.DrawingBoardMetaSchema.Categories[i].Items));  //number of misc items
      end;   //SetLength commented, because there is a similar code below
    end;
  end; //for

  DoOnDrawingBoardModified;
  FOIFrame.ReloadContent;
end;


procedure TfrDrawingBoardSchemaEditor.synedtCodeChange(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  DoOnDrawingBoardModified;

  if FLastClickedCategory = -1 then
    Exit;

  SetLength(FProject.CategoryContents[FLastClickedCategory].Items[0], synedtCode.Lines.Count);
  for i := 0 to Length(FProject.CategoryContents[FLastClickedCategory].Items[0]) - 1 do
  begin
    s := synedtCode.Lines.Strings[i];
    s := StringReplace(s, #7, '', [rfReplaceAll]);
    FProject.CategoryContents[FLastClickedCategory].Items[0][i] := s;
  end;
end;


procedure TfrDrawingBoardSchemaEditor.MenuItem_AddPropertyClick(Sender: TObject);
var
  TempCategoryIndex, n: Integer;
begin
  TempCategoryIndex := MenuItem_AddProperty.Tag;

  case FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].StructureType of
    stCountable:
    begin
      n := Length(FProject.CategoryContents[TempCategoryIndex].Items);
      SetLength(FProject.CategoryContents[TempCategoryIndex].Items, n + 1);

      SetLength(FProject.CategoryContents[TempCategoryIndex].Items[n], Length(FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].Items));

      if Length(FProject.CategoryContents[TempCategoryIndex].Items[n]) > 0 then
        FProject.CategoryContents[TempCategoryIndex].Items[n][0] := 'New property';

      FOIFrame.ReloadContent;
      FOIFrame.SelectNode(1, TempCategoryIndex, n, -1, True, True);

      DoOnDrawingBoardModified;
    end;

    stMisc:  //The code is somewhat valid, but the misc properties should be added from metaschema.
    begin    //The property name cannot be edited from here (currently, the object inspector does not support editing property names i.e. the left column)
      n := Length(FProject.CategoryContents[TempCategoryIndex].Items[0]);
      SetLength(FProject.CategoryContents[TempCategoryIndex].Items[0], n + 1);

      SetLength(FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].Items, n + 1);

      FProject.CategoryContents[TempCategoryIndex].Items[0][n] := 'New property value';
      FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].Items[n].Value := 'PropertyNotFoundInMetaSchema';
      FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].Items[n].EditorType := 'etText';

      FOIFrame.ReloadContent;
      FOIFrame.SelectNode(1, TempCategoryIndex, 0, n, True, True);

      DoOnDrawingBoardModified;
    end;

    else
      ;
  end;  //case
end;


procedure TfrDrawingBoardSchemaEditor.MenuItem_RemoveAllPropertiesClick(
  Sender: TObject);
var
  TempCategoryIndex, n, i: Integer;
begin
  if FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].StructureType <> stCountable then
  begin
    MessageBox(Handle, 'Removing properties from this category type, is not supported.', PChar(Application.Title), MB_ICONINFORMATION);
    Exit;
  end;

  if MessageBox(Handle, 'Are you sure you want to remove all properties from this category?', PChar(Application.Title), MB_ICONQUESTION + MB_YESNO) = IDNO then
    Exit;

  TempCategoryIndex := MenuItem_AddProperty.Tag;

  n := Length(FProject.CategoryContents[TempCategoryIndex].Items);
  for i := 0 to Length(FProject.CategoryContents[TempCategoryIndex].Items[n - 1]) - 1 do
    SetLength(FProject.CategoryContents[TempCategoryIndex].Items[n - 1], 0);

  SetLength(FProject.CategoryContents[TempCategoryIndex].Items, 0);

  FOIFrame.ReloadContent;
  FOIFrame.SelectNode(1, TempCategoryIndex, n, -1, True, True);

  DoOnDrawingBoardModified;
end;


procedure TfrDrawingBoardSchemaEditor.MenuItem_RemovePropertyClick(
  Sender: TObject);
var
  TempCategoryIndex, TempPropertyIndex, n, i, j: Integer;
begin
  if MessageBox(Handle, 'Are you sure you want to remove the selected property?', PChar(Application.Title), MB_ICONQUESTION + MB_YESNO) = IDNO then
    Exit;

  TempCategoryIndex := pmProperties.Tag;
  TempPropertyIndex := MenuItem_RemoveProperty.Tag;

  if FProject.DrawingBoardMetaSchema.Categories[TempCategoryIndex].StructureType <> stCountable then
    Exit;

  n := Length(FProject.CategoryContents[TempCategoryIndex].Items);

  for i := TempPropertyIndex to n - 2 do
    for j := 0 to Length(FProject.CategoryContents[TempCategoryIndex].Items[i]) - 1 do
      FProject.CategoryContents[TempCategoryIndex].Items[i][j] := FProject.CategoryContents[TempCategoryIndex].Items[i + 1][j];

  SetLength(FProject.CategoryContents[TempCategoryIndex].Items[n - 1], 0); //clear property items
  SetLength(FProject.CategoryContents[TempCategoryIndex].Items, n - 1);

  FOIFrame.ReloadContent;
  FOIFrame.SelectNode(1, TempCategoryIndex, TempPropertyIndex - 1, -1, True, True);

  DoOnDrawingBoardModified;
end;


procedure TfrDrawingBoardSchemaEditor.pnlHorizSplitterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Shift <> [ssLeft] then
    Exit;

  if not FHold then
  begin
    GetCursorPos(FSplitterMouseDownGlobalPos);

    FSplitterMouseDownImagePos.X := pnlHorizSplitter.Left;
    FHold := True;
  end;
end;


procedure TfrDrawingBoardSchemaEditor.pnlHorizSplitterMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  tp: TPoint;
  NewLeft: Integer;
begin
  if Shift <> [ssLeft] then
    Exit;

  if not FHold then
    Exit;

  GetCursorPos(tp);
  NewLeft := FSplitterMouseDownImagePos.X + tp.X - FSplitterMouseDownGlobalPos.X;

  ResizeFrameSectionsBySplitter(NewLeft);
end;


procedure TfrDrawingBoardSchemaEditor.pnlHorizSplitterMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHold := False;
end;


procedure TfrDrawingBoardSchemaEditor.FrameResize(Sender: TObject);
var
  NewLeft: Integer;
begin
  NewLeft := pnlHorizSplitter.Left;

  if NewLeft > Width - 260 then
    NewLeft := Width - 260;

  ResizeFrameSectionsBySplitter(NewLeft);
end;


procedure TfrDrawingBoardSchemaEditor.ResizeFrameSectionsBySplitter(NewLeft: Integer);
begin
  if NewLeft < pnlSchemaOI.Constraints.MinWidth then
    NewLeft := pnlSchemaOI.Constraints.MinWidth;

  if NewLeft > Width - 260 then
    NewLeft := Width - 260;

  if NewLeft < 300 then
    NewLeft := 300;

  pnlHorizSplitter.Left := NewLeft;

  synedtCode.Left := pnlHorizSplitter.Left + pnlHorizSplitter.Width;
  synedtCode.Width := Width - synedtCode.Left;
  pnlSchemaOI.Width := pnlHorizSplitter.Left;
end;


procedure TfrDrawingBoardSchemaEditor.MoveProperty(CategoryIndex, SrcPropertyIndex, DestPropertyIndex: Integer);
var
  k: Integer;
  ph: string;
begin
  for k := 0 to Length(FProject.CategoryContents[CategoryIndex].Items[SrcPropertyIndex]) - 1 do
  begin
    ph := FProject.CategoryContents[CategoryIndex].Items[SrcPropertyIndex][k];
    FProject.CategoryContents[CategoryIndex].Items[SrcPropertyIndex][k] := FProject.CategoryContents[CategoryIndex].Items[DestPropertyIndex][k];
    FProject.CategoryContents[CategoryIndex].Items[DestPropertyIndex][k] := ph;
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetCategoryCount: Integer;
begin
  Result := Length(FProject.DrawingBoardMetaSchema.Categories);
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetCategory(AIndex: Integer): string;
begin
  Result := '[' + FProject.DrawingBoardMetaSchema.Categories[AIndex].Name + ']';
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetCategoryValue(ACategoryIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  Result := '';
  AEditorType := etUserEditor;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetPropertyCount(ACategoryIndex: Integer): Integer;
begin
  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := Length(FProject.CategoryContents[ACategoryIndex].Items);

    stCode:
      Result := 1;

    stMisc:
      Result := 1;
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetPropertyName(ACategoryIndex, APropertyIndex: Integer): string;
var
  PropName: string;
  PropIdx: Integer;
begin
  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      Result := 'Prop ' + IntToStr(APropertyIndex);

      PropIdx := FProject.CategoryContents[ACategoryIndex].CachedIndexOfName;
      if PropIdx <> -1 then
      begin
        try
          PropName := FProject.CategoryContents[ACategoryIndex].Items[APropertyIndex][PropIdx];
        except
          PropName := '???';
        end;

        Result := Result + ':    ' + PropName;
      end;
    end;

    stCode:
      Result := 'Code:  ' + IntToStr(Length(FProject.CategoryContents[ACategoryIndex].Items[0])) + ' line(s)';

    stMisc:
      Result := 'Misc';
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetPropertyValue(ACategoryIndex, APropertyIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      Result := '';
      AEditorType := etUserEditor;
    end;

    stCode:
    begin
      Result := '<click to load code into editor>';
      AEditorType := etNone;
    end;

    stMisc:
    begin
      Result := '';
      AEditorType := etNone;
    end;
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetListPropertyItemCount(ACategoryIndex, APropertyIndex: Integer): Integer;
begin
  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := Length(FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items);

    stCode:
      Result := 0;

    stMisc:
      Result := Length(FProject.CategoryContents[ACategoryIndex].Items[APropertyIndex]);
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetListPropertyItemName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
var
  KeyCount: Integer;
begin
  Result := '';

  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      KeyCount := Length(FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items);
      Result := FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex mod KeyCount].Value;
      //Result := StringReplace(Result, CIndexReplacement, IntToStr(APropertyIndex), [rfReplaceAll]);
      Result := StringReplace(Result, 'Prop_' + CIndexReplacement + '_', '', [rfReplaceAll]);
      Result := StringReplace(Result, 'Const_' + CIndexReplacement + '_', '', [rfReplaceAll]);
      Result := StringReplace(Result, 'Line_' + CIndexReplacement + '_', '', [rfReplaceAll]);
    end;

    stCode:
      Result := 'Line ' + IntToStr(AItemIndex);

    stMisc:
      Result := FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].Value;
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetListPropertyItemValue(ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  Result := '';

  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      Result := FProject.CategoryContents[ACategoryIndex].Items[APropertyIndex][AItemIndex];
      AEditorType := StrToTOIEditorType('et' + FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].EditorType);
    end;

    stCode:
    begin
      Result := FProject.CategoryContents[ACategoryIndex].Items[0][AItemIndex];
      AEditorType := etNone;
    end;

    stMisc:
    begin
      Result := FProject.CategoryContents[ACategoryIndex].Items[0][AItemIndex];
      AEditorType := StrToTOIEditorType('et' + FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].EditorType);
    end;
  end;
end;


function TfrDrawingBoardSchemaEditor.HandleOnUIGetDataTypeName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  Result := '';
end;


function TfrDrawingBoardSchemaEditor.HandleOnUIGetExtraInfo(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  Result := '';
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIGetImageIndexEx(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList);
begin
  //
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIEditedText(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; ANewText: string);
begin
  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      FProject.CategoryContents[ACategoryIndex].Items[APropertyIndex][AItemIndex] := ANewText;

    stCode:;

    stMisc:
    begin
      FProject.CategoryContents[ACategoryIndex].Items[0][AItemIndex] := ANewText;

      if FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Name = CDrawingBoardMetaSchemaKeyName then
      begin
        FProject.DrawingBoardMetaSchemaFileName := ANewText;
        //FProject.DrawingBoardMetaSchemaFileName := resolve path in FProject.DrawingBoardMetaSchemaFileName by replacing ExtractFileDir(FProject.ProjectFileName) with CSelfDir
        //FProject.CategoryContents[ACategoryIndex].Items[0][AItemIndex] := FProject.DrawingBoardMetaSchemaFileName;
      end;
    end;
  end;

  FOIFrame.RepaintNodeByLevel(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, False);
  DoOnDrawingBoardModified;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIEditItems(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewItems: string): Boolean;
begin
  Result := False;
end;


function TfrDrawingBoardSchemaEditor.HandleOnOIGetColorConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
begin
  Result := 0;
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIGetColorConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AColorItemIndex: Integer; var AColorName: string; var AColorValue: Int64);
begin
  //additional user colors
end;



function TfrDrawingBoardSchemaEditor.HandleOnOIGetEnumConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
begin
  Result := 0;

  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      Result := 0;

      if FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].EditorType = 'BooleanCombo' then
        Result := 2;

      if FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].EditorType = 'IntBooleanCombo' then
        Result := 2;
    end;

    else
      ;
  end;
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIGetEnumConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AEnumItemIndex: Integer; var AEnumItemName: string);
begin
  AEnumItemName := '';

  case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      if FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].EditorType = 'BooleanCombo' then
        AEnumItemName := BoolToStr(AEnumItemIndex = 1, 'Yes', 'No');

      if FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].Items[AItemIndex].EditorType = 'IntBooleanCombo' then
        AEnumItemName := BoolToStr(AEnumItemIndex = 1, '1', '0');
    end;

    else
      ;
  end;
end;



procedure TfrDrawingBoardSchemaEditor.HandleOnOIPaintText(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
  const TargetCanvas: TCanvas; Column: TColumnIndex; var TextType: TVSTTextType);
begin
  if ANodeData.Level = 0 then
  begin
    TargetCanvas.Font.Style := [fsBold];
    Exit;
  end;
end;



procedure TfrDrawingBoardSchemaEditor.HandleOnOIBeforeCellPaint(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
  TargetCanvas: TCanvas; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin

end;



procedure TfrDrawingBoardSchemaEditor.HandleOnTextEditorMouseDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;


function TfrDrawingBoardSchemaEditor.HandleOnTextEditorMouseMove(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
end;



procedure TfrDrawingBoardSchemaEditor.HandleOnOITextEditorKeyUp(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;



procedure TfrDrawingBoardSchemaEditor.HandleOnOITextEditorKeyDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;



procedure TfrDrawingBoardSchemaEditor.HandleOnOIEditorAssignMenuAndTooltip(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var APopupMenu: TPopupMenu; var AHint: string; var AShowHint: Boolean);
begin

end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIGetFileDialogSettings(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AFilter, AInitDir: string);
begin

end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIArrowEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer);
begin

end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIUserEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ARepaintValue: Boolean);
begin
  case ANodeLevel of
    0:
    begin
      case FProject.DrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType of
        stCountable:
        begin
          MenuItem_AddProperty.Tag := ACategoryIndex;
          pmCategories.PopUp;
        end;

        stCode:
          ;

        stMisc:
          MessageBox(Handle, 'Adding/removing misc properties should be done from metaschema editor.', PChar(Application.Title), MB_ICONINFORMATION);
      end;
    end;

    1:
    begin
      pmProperties.Tag := ACategoryIndex;
      MenuItem_RemoveProperty.Tag := APropertyIndex;
      pmProperties.PopUp;
    end;
  end;
end;



function TfrDrawingBoardSchemaEditor.HandleOnOIBrowseFile(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  AFilter, ADialogInitDir: string; var Handled: Boolean; AReturnMultipleFiles: Boolean = False): string;
begin
  Handled := False;
  Result := '';
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIAfterSpinTextEditorChanging(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewValue: string);
begin

end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOISelectedNode(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  s: string;
begin
  synedtCode.Clear;

  if FProject.DrawingBoardMetaSchema.Categories[CategoryIndex].StructureType = stCode then
  begin
    FLastClickedCategory := CategoryIndex;
    FLastClickedProperty := PropertyIndex;
    FLastClickedPropertyItem := PropertyItemIndex;

    for i := 0 to Length(FProject.CategoryContents[CategoryIndex].Items[0]) - 1 do
    begin
      s := FProject.CategoryContents[CategoryIndex].Items[0][i];
      s := StringReplace(s, '', #7, [rfReplaceAll]);
      synedtCode.Lines.Add(s);
    end;
  end
  else
  begin
    FLastClickedCategory := -1;
    FLastClickedProperty := -1;
    FLastClickedPropertyItem := -1;
  end;
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIDragAllowed(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex: Integer; var Allowed: Boolean);
begin
  Allowed := (FProject.DrawingBoardMetaSchema.Categories[CategoryIndex].StructureType = stCountable) and
             (((NodeLevel = CPropertyLevel) and (PropertyItemIndex = -1)) {or
             ((NodeLevel = CPropertyItemLevel) and (PropertyItemIndex > -1))} );
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIDragOver(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; State: TDragState; const Pt: TPoint; Mode: TDropMode; var Effect: DWORD; var Accept: Boolean);
var
  MatchingCategory: Boolean;
  SameSrcAndDest: Boolean;
  DraggingName, DraggingItem: Boolean;
  IsPropertyLevel: Boolean;
  //IsPropertyItemLevel: Boolean;
  DraggingFromTheSame: Boolean;
begin
  MatchingCategory := (FProject.DrawingBoardMetaSchema.Categories[CategoryIndex].StructureType = stCountable) and (CategoryIndex = SrcCategoryIndex);
  SameSrcAndDest := NodeLevel = SrcNodeLevel;
  IsPropertyLevel := NodeLevel = CPropertyLevel;
  //IsPropertyItemLevel := NodeLevel = CPropertyItemLevel;

  DraggingName := IsPropertyLevel and (PropertyItemIndex = -1);
  DraggingItem := {IsPropertyItemLevel and} (PropertyItemIndex > -1);
  DraggingFromTheSame := (PropertyIndex = SrcPropertyIndex) {and IsPropertyItemLevel};

  Accept := MatchingCategory and
            SameSrcAndDest and
            (DraggingName or (DraggingItem and DraggingFromTheSame));
end;


procedure TfrDrawingBoardSchemaEditor.HandleOnOIDragDrop(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; const Pt: TPoint; var Effect: DWORD; Mode: TDropMode);
begin
  if not ((FProject.DrawingBoardMetaSchema.Categories[CategoryIndex].StructureType = stCountable) and (CategoryIndex = SrcCategoryIndex)) then
    Exit;

  //dragging a property
  if (NodeLevel = CPropertyLevel) and (SrcNodeLevel = CPropertyLevel) then
    if (PropertyItemIndex = -1) and (SrcPropertyItemIndex = -1) then
      if PropertyIndex <> SrcPropertyIndex then
      begin
        MoveProperty(CategoryIndex, SrcPropertyIndex, PropertyIndex);

        FOIFrame.ReloadPropertyItems(CategoryIndex, PropertyIndex, True);
        FOIFrame.ReloadPropertyItems(SrcCategoryIndex, SrcPropertyIndex, True);
        DoOnDrawingBoardModified;
      end;

  ////dragging a property item
  //if (NodeLevel = CPropertyItemLevel) and (SrcNodeLevel = CPropertyItemLevel) then
  //  if (PropertyItemIndex > -1) and (SrcPropertyItemIndex > -1) then
  //    if PropertyIndex = SrcPropertyIndex then
  //      if PropertyItemIndex <> SrcPropertyItemIndex then
  //      begin
  //        //MovePropertyItem(PropertyIndex, SrcPropertyItemIndex, PropertyItemIndex);
  //
  //        FOIFrame.ReloadPropertyItems(CategoryIndex, PropertyIndex, True);
  //        //DoOnTriggerOnControlsModified;
  //      end;
end;

end.

