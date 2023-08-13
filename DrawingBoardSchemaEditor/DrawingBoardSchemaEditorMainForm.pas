{
    Copyright (C) 2022 VCC
    creation date: Jan 2023   (2023.08.10)
    initial release date: 13 Aug 2023

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


unit DrawingBoardSchemaEditorMainForm;

{$mode Delphi}{$H+}

interface

uses
  LCLIntf, LCLType, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Menus, IniFiles, ObjectInspectorFrame, VirtualTrees, ImgList,
  ComCtrls, StdCtrls, SynEdit, SynHighlighterPas, DrbSchPrjEditorForm;

type
  TDrawingBoardSchemaCategory = record
    Items: array of TStringArr; //e.g. 'Prop_', 'Const_', 'Line_', 'Comp_'  - every item is a group of properties
    //other fields
  end;

  TDrawingBoardProject = record
    DrawingBoardSchemaFileName: string; //file name used when calling LoadDrawingBoardSchema
    ProjectFileName: string;
    DrawingBoardSchema: TDrawingBoardSchema;
    CategoryContents: array of TDrawingBoardSchemaCategory;   //Key=value pairs for every category and its group of properties
  end;

  { TfrmDrawingBoardSchemaEditorMain }

  TfrmDrawingBoardSchemaEditorMain = class(TForm)
    lblSpacingInfo: TLabel;
    N2: TMenuItem;
    MenuItem_OpenSchemaProjectEditor: TMenuItem;
    MenuItem_SetSchemaFromFile: TMenuItem;
    MenuItem_SchemaProject: TMenuItem;
    MenuItem_Exit: TMenuItem;
    N1: TMenuItem;
    MenuItem_SaveAs: TMenuItem;
    MenuItem_Save: TMenuItem;
    MenuItem_Open: TMenuItem;
    MenuItem_New: TMenuItem;
    MenuItem_File: TMenuItem;
    mmMain: TMainMenu;
    pnlSchemaOI: TPanel;
    StatusBar1: TStatusBar;
    synedtCode: TSynEdit;
    SynPasSyn1: TSynPasSyn;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem_ExitClick(Sender: TObject);
    procedure MenuItem_NewClick(Sender: TObject);
    procedure MenuItem_OpenClick(Sender: TObject);
    procedure MenuItem_OpenSchemaProjectEditorClick(Sender: TObject);
    procedure MenuItem_SaveAsClick(Sender: TObject);
    procedure MenuItem_SaveClick(Sender: TObject);
    procedure MenuItem_SetSchemaFromFileClick(Sender: TObject);
    procedure synedtCodeChange(Sender: TObject);
  private
    FOIFrame: TfrObjectInspector;
    FProject: TDrawingBoardProject;
    FModified: Boolean;
    FLastClickedCategory, FLastClickedProperty, FLastClickedPropertyItem: Integer;

    procedure SetModified(Value: Boolean);

    procedure LoadDrawingBoardSchema(AFnm: string);
    procedure LoadDrawingBoardProject(AFnm: string); //for DynTFTCodeGen, this is a .dynscm file
    procedure SaveDrawingBoardProject(AFnm: string);
    procedure ClearProject;

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

    property Modified: Boolean read FModified write SetModified;
  public

  end;

var
  frmDrawingBoardSchemaEditorMain: TfrmDrawingBoardSchemaEditorMain;

{ToDo
- The code, which cleans the project, should be split. The part, used for cleaning the schema, should be moved to the other editor unit.
- Implement editor handlers
- Implement saving .drbsch files
- Add splitter
}

implementation

{$R *.frm}


{ TfrmDrawingBoardSchemaEditorMain }

procedure TfrmDrawingBoardSchemaEditorMain.FormCreate(Sender: TObject);
begin
  FProject.DrawingBoardSchema.FileTitle := '';
  SetLength(FProject.DrawingBoardSchema.Categories, 0);
  SetLength(FProject.CategoryContents, 0);

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


procedure TfrmDrawingBoardSchemaEditorMain.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
  TempSaveDialog: TSaveDialog;
  MsgResult: Integer;
begin
  if Modified then
    MsgResult := MessageBox(Handle, 'The project is modified. Do you want to save?', PChar(Application.Title), MB_ICONQUESTION + MB_YESNOCANCEL);

  if MsgResult = IDCANCEL then
  begin
    CloseAction := caNone;
    Exit;
  end;

  if MsgResult = IDNO then
    Exit;

  if Modified then
  begin
    if FProject.ProjectFileName = '' then
    begin
      TempSaveDialog := TSaveDialog.Create(Self);
      try
        if not TempSaveDialog.Execute then
          Exit;

        SaveDrawingBoardProject(TempSaveDialog.FileName);
      finally
        TempSaveDialog.Free;
      end;
    end
    else
      SaveDrawingBoardProject(FProject.ProjectFileName);
  end;

  Modified := False;
end;


procedure TfrmDrawingBoardSchemaEditorMain.SetModified(Value: Boolean);
begin
  if FModified <> Value then
  begin
    FModified := Value;
    StatusBar1.Panels.Items[0].Text := BoolToStr(Value, 'Modified', '');
  end;

  StatusBar1.Panels.Items[1].Text := FProject.ProjectFileName;
end;


procedure TfrmDrawingBoardSchemaEditorMain.LoadDrawingBoardSchema(AFnm: string);
begin
  LoadDrawingBoardSchemaProject(AFnm, FProject.DrawingBoardSchema);
end;


procedure TfrmDrawingBoardSchemaEditorMain.LoadDrawingBoardProject(AFnm: string); //for DynTFTCodeGen, this is a .dynscm file
var
  Ini: TMemIniFile;
  i, j, k, CategoryCount, CountableCount: Integer;
  CatName, CountKey, ItemKey: string;
  InitialDBSchFileName, FullDBSchFileName: string;
begin
  Ini := TMemIniFile.Create(AFnm);
  try
    FProject.ProjectFileName := AFnm;
    InitialDBSchFileName := Ini.ReadString('DrawingBoardSchema', 'FileName', '');
    FProject.DrawingBoardSchemaFileName := InitialDBSchFileName;
    FullDBSchFileName := ExtractFilePath(AFnm) + InitialDBSchFileName;

    if not FileExists(FullDBSchFileName) then
    begin
      MessageBox(Handle,
                 PChar('DrawingBoard schema file is not set in project file.' + #13#10 +
                       'It is expected to be of "FileName=<[PathToFile\]Filename>" format (without quotes), under the "DrawingBoardSchema" section.'),
                 PChar(Application.Title),
                 MB_ICONERROR);
      Exit;
    end;

    LoadDrawingBoardSchema(FullDBSchFileName);

    CategoryCount := Length(FProject.DrawingBoardSchema.Categories);
    SetLength(FProject.CategoryContents, CategoryCount);

    for i := 0 to CategoryCount - 1 do
    begin
      CatName := FProject.DrawingBoardSchema.Categories[i].Name;  //e.g.: ComponentPropertiesSchema, ComponentEventsPropertiesSchema, Constants, ColorConstants
      CountKey := FProject.DrawingBoardSchema.Categories[i].Item_CountKey;  //name of the "Count" key - this is usually "Count"

      case FProject.DrawingBoardSchema.Categories[i].StructureType of
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
          SetLength(FProject.CategoryContents[i].Items[0], Length(FProject.DrawingBoardSchema.Categories[i].Items));  //number of misc items
          CountableCount := Length(FProject.CategoryContents[i].Items[0]);
        end;   //SetLength commented, because there is a similar code below
      end;

      CountableCount := Length(FProject.DrawingBoardSchema.Categories[i].Items);

      case FProject.DrawingBoardSchema.Categories[i].StructureType of
        stCountable:
        begin
          for j := 0 to Length(FProject.CategoryContents[i].Items) - 1 do   //number of counted item groups
          begin
            SetLength(FProject.CategoryContents[i].Items[j], CountableCount);

            for k := 0 to Length(FProject.CategoryContents[i].Items[j]) - 1 do
            begin
              ItemKey := StringReplace(FProject.DrawingBoardSchema.Categories[i].Items[k].Value, CIndexReplacement, IntToStr(j), [rfReplaceAll]);
              FProject.CategoryContents[i].Items[j][k] := Ini.ReadString(CatName, ItemKey, '');
            end;
          end;
        end;

        stCode:
        begin
          for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          begin
            ItemKey := FProject.DrawingBoardSchema.Categories[i].Items[0].Value;
            ItemKey := StringReplace(ItemKey, CIndexReplacement, IntToStr(k), [rfReplaceAll]);
            FProject.CategoryContents[i].Items[0][k] := Ini.ReadString(CatName, ItemKey, '');
          end;
        end;

        stMisc:
        begin
          for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          begin
            ItemKey := FProject.DrawingBoardSchema.Categories[i].Items[k].Value; //here it is Items[k]
            ItemKey := StringReplace(ItemKey, CIndexReplacement, IntToStr(k), [rfReplaceAll]);
            FProject.CategoryContents[i].Items[0][k] := Ini.ReadString(CatName, ItemKey, '');
          end;
        end;
      end; //case
    end;  //for i
  finally
    Ini.Free;
  end;
end;


procedure TfrmDrawingBoardSchemaEditorMain.SaveDrawingBoardProject(AFnm: string);
var
  s: string;
  i, j, k, n: Integer;
  Content: TMemoryStream;
begin
  s := '[DrawingBoardSchema]' + #13#10 + 'FileName=' + FProject.DrawingBoardSchemaFileName + #13#10#13#10;
  n := Length(FProject.DrawingBoardSchema.Categories);

  for i := 0 to n - 1 do
  begin
    s := s + '[' + FProject.DrawingBoardSchema.Categories[i].Name + ']' + #13#10;
    s := s + ';' + FProject.DrawingBoardSchema.Categories[i].CategoryComment + #13#10;

    case FProject.DrawingBoardSchema.Categories[i].StructureType of
      stCountable:
        s := s + FProject.DrawingBoardSchema.Categories[i].Item_CountKey + '=' + IntToStr(Length(FProject.CategoryContents[i].Items)) + #13#10;

      stCode:
        s := s + FProject.DrawingBoardSchema.Categories[i].Item_CountKey + '=' + IntToStr(Length(FProject.CategoryContents[i].Items[0])) + #13#10;

      stMisc:;
    end;

    case FProject.DrawingBoardSchema.Categories[i].StructureType of
      stCountable:
      begin
        for j := 0 to Length(FProject.CategoryContents[i].Items) - 1 do
          for k := 0 to Length(FProject.CategoryContents[i].Items[j]) - 1 do
            s := s + StringReplace(FProject.DrawingBoardSchema.Categories[i].Items[k].Value, CIndexReplacement, IntToStr(j), [rfReplaceAll]) + '=' + FProject.CategoryContents[i].Items[j][k] + #13#10;
      end;

      stCode:
      begin
        for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          s := s + StringReplace(FProject.DrawingBoardSchema.Categories[i].Items[0].Value, CIndexReplacement, IntToStr(k), [rfReplaceAll]) + '=' + FProject.CategoryContents[i].Items[0][k] + #13#10;
      end;

      stMisc:
      begin
        for k := 0 to Length(FProject.CategoryContents[i].Items[0]) - 1 do
          s := s + StringReplace(FProject.DrawingBoardSchema.Categories[i].Items[k].Value, CIndexReplacement, IntToStr(k), [rfReplaceAll]) + '=' + FProject.CategoryContents[i].Items[0][k] + #13#10;
      end;
    end; //case

    if i < n - 1 then
      s := s + #13#10;
  end;

  Content := TMemoryStream.Create;
  try
    Content.Write(s[1], Length(s));
  finally
    Content.SaveToFile(AFnm);
  end;
end;


procedure TfrmDrawingBoardSchemaEditorMain.ClearProject;
var
  i, j: Integer;
begin
  for i := 0 to Length(FProject.DrawingBoardSchema.Categories) - 1 do
  begin
    SetLength(FProject.DrawingBoardSchema.Categories[i].Items, 0);
    FProject.DrawingBoardSchema.Categories[i].Item_CountKey := '';
  end;

  SetLength(FProject.DrawingBoardSchema.Categories, 0);

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
  FProject.DrawingBoardSchemaFileName := '';
  FLastClickedCategory := -1;
  FLastClickedProperty := -1;
  FLastClickedPropertyItem := -1;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_SetSchemaFromFileClick(
  Sender: TObject);
var
  TempOpenDialog: TOpenDialog;
  CategoryCount, i: Integer;
begin
  if Modified then
  begin
    MessageBox(Handle, 'The project is modified. Please save or discard it, before loading a new schema file.', PChar(Application.Title), MB_ICONINFORMATION);
    Exit;
  end;

  TempOpenDialog := TOpenDialog.Create(Self);
  try
    TempOpenDialog.Filter := 'DrawingBoard schema file (*.drbsch)|*.drbsch|All Files (*.*)|*.*';
    if not TempOpenDialog.Execute then
      Exit;

    ClearProject;

    FProject.DrawingBoardSchemaFileName := ExtractFileName(TempOpenDialog.FileName);
    LoadDrawingBoardSchema(TempOpenDialog.FileName);
  finally
    TempOpenDialog.Free;
  end;

  CategoryCount := Length(FProject.DrawingBoardSchema.Categories);
  SetLength(FProject.CategoryContents, CategoryCount);

  for i := 0 to CategoryCount - 1 do
  begin
    case FProject.DrawingBoardSchema.Categories[i].StructureType of
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
        SetLength(FProject.CategoryContents[i].Items[0], Length(FProject.DrawingBoardSchema.Categories[i].Items));  //number of misc items
      end;   //SetLength commented, because there is a similar code below
    end;
  end; //for

  Modified := True;
  FOIFrame.ReloadContent;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_NewClick(Sender: TObject);
begin
  ClearProject;
  Modified := False;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_OpenClick(Sender: TObject);
var
  TempOpenDialog: TOpenDialog;
begin
  TempOpenDialog := TOpenDialog.Create(Self);
  try
    if not TempOpenDialog.Execute then
      Exit;

    ClearProject;
    LoadDrawingBoardProject(TempOpenDialog.FileName);
    FOIFrame.ReloadContent;
  finally
    TempOpenDialog.Free;
  end;

  Modified := False;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_OpenSchemaProjectEditorClick
  (Sender: TObject);
begin
  frmDrbSchPrjEditor.Show;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_SaveClick(Sender: TObject);
var
  TempSaveDialog: TSaveDialog;
begin
  if FProject.ProjectFileName = '' then
  begin
    TempSaveDialog := TSaveDialog.Create(Self);
    try
      if not TempSaveDialog.Execute then
        Exit;

      SaveDrawingBoardProject(TempSaveDialog.FileName);
    finally
      TempSaveDialog.Free;
    end;
  end
  else
    SaveDrawingBoardProject(FProject.ProjectFileName);

  Modified := False;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_SaveAsClick(Sender: TObject);
var
  TempSaveDialog: TSaveDialog;
begin
  TempSaveDialog := TSaveDialog.Create(Self);
  try
    if not TempSaveDialog.Execute then
      Exit;

    SaveDrawingBoardProject(TempSaveDialog.FileName);
  finally
    TempSaveDialog.Free;
  end;

  Modified := False;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_ExitClick(Sender: TObject);
begin
  ClearProject;
  Close;
end;


procedure TfrmDrawingBoardSchemaEditorMain.synedtCodeChange(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  Modified := True;

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

////////////////////////////

function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetCategoryCount: Integer;
begin
  Result := Length(FProject.DrawingBoardSchema.Categories);
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetCategory(AIndex: Integer): string;
begin
  Result := '[' + FProject.DrawingBoardSchema.Categories[AIndex].Name + ']';
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetCategoryValue(ACategoryIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  Result := '';
  AEditorType := etTextWithArrow;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetPropertyCount(ACategoryIndex: Integer): Integer;
begin
  case FProject.DrawingBoardSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := Length(FProject.CategoryContents[ACategoryIndex].Items);

    stCode:
      Result := 1;

    stMisc:
      Result := 1;
  end;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetPropertyName(ACategoryIndex, APropertyIndex: Integer): string;
begin
  case FProject.DrawingBoardSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := 'Prop ' + IntToStr(APropertyIndex);

    stCode:
      Result := 'Code:  ' + IntToStr(Length(FProject.CategoryContents[ACategoryIndex].Items[0])) + ' line(s)';

    stMisc:
      Result := 'Misc';
  end;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetPropertyValue(ACategoryIndex, APropertyIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  case FProject.DrawingBoardSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := '';

    stCode, stMisc:
      Result := FProject.CategoryContents[ACategoryIndex].Items[0][APropertyIndex];
  end;

  AEditorType := etTextWithArrow;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetListPropertyItemCount(ACategoryIndex, APropertyIndex: Integer): Integer;
begin
  case FProject.DrawingBoardSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := Length(FProject.DrawingBoardSchema.Categories[ACategoryIndex].Items);

    stCode:
      Result := 0;

    stMisc:
      Result := Length(FProject.CategoryContents[ACategoryIndex].Items[APropertyIndex]);
  end;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetListPropertyItemName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
var
  KeyCount: Integer;
begin
  Result := '';

  case FProject.DrawingBoardSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
    begin
      KeyCount := Length(FProject.DrawingBoardSchema.Categories[ACategoryIndex].Items);
      Result := FProject.DrawingBoardSchema.Categories[ACategoryIndex].Items[AItemIndex mod KeyCount].Value;
      //Result := StringReplace(Result, CIndexReplacement, IntToStr(APropertyIndex), [rfReplaceAll]);
      Result := StringReplace(Result, 'Prop_' + CIndexReplacement + '_', '', [rfReplaceAll]);
      Result := StringReplace(Result, 'Const_' + CIndexReplacement + '_', '', [rfReplaceAll]);
      Result := StringReplace(Result, 'Line_' + CIndexReplacement + '_', '', [rfReplaceAll]);
    end;

    stCode:
      Result := 'Line ' + IntToStr(AItemIndex);

    stMisc:
      Result := FProject.DrawingBoardSchema.Categories[ACategoryIndex].Items[AItemIndex].Value;
  end;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetListPropertyItemValue(ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  Result := '';

  case FProject.DrawingBoardSchema.Categories[ACategoryIndex].StructureType of
    stCountable:
      Result := FProject.CategoryContents[ACategoryIndex].Items[APropertyIndex][AItemIndex];

    stCode, stMisc:
      Result := FProject.CategoryContents[ACategoryIndex].Items[0][AItemIndex];
  end;

  AEditorType := etTextWithArrow;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnUIGetDataTypeName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  Result := '';
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnUIGetExtraInfo(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  Result := '';
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetImageIndexEx(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList);
begin
  //
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIEditedText(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; ANewText: string);
begin
  //DoOnTriggerOnControlsModified;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIEditItems(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewItems: string): Boolean;
begin
  Result := False;
end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetColorConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
begin
  Result := 0;
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetColorConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AColorItemIndex: Integer; var AColorName: string; var AColorValue: Int64);
begin

end;



function TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetEnumConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
begin
  Result := 0;

end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetEnumConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AEnumItemIndex: Integer; var AEnumItemName: string);
begin
  AEnumItemName := '';

end;



procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIPaintText(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
  const TargetCanvas: TCanvas; Column: TColumnIndex; var TextType: TVSTTextType);
begin
  if ANodeData.Level = 0 then
  begin
    TargetCanvas.Font.Style := [fsBold];
    Exit;
  end;
end;



procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIBeforeCellPaint(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
  TargetCanvas: TCanvas; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin

end;



procedure TfrmDrawingBoardSchemaEditorMain.HandleOnTextEditorMouseDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;


function TfrmDrawingBoardSchemaEditorMain.HandleOnTextEditorMouseMove(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
end;



procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOITextEditorKeyUp(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;



procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOITextEditorKeyDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;



procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIEditorAssignMenuAndTooltip(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var APopupMenu: TPopupMenu; var AHint: string; var AShowHint: Boolean);
begin
  //
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIGetFileDialogSettings(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AFilter, AInitDir: string);
begin

end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIArrowEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer);
begin

end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIUserEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ARepaintValue: Boolean);
begin

end;



function TfrmDrawingBoardSchemaEditorMain.HandleOnOIBrowseFile(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  AFilter, ADialogInitDir: string; var Handled: Boolean; AReturnMultipleFiles: Boolean = False): string;
begin
  Handled := False;
  Result := '';
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIAfterSpinTextEditorChanging(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewValue: string);
begin

end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOISelectedNode(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  s: string;
begin
  synedtCode.Clear;

  if FProject.DrawingBoardSchema.Categories[CategoryIndex].StructureType = stCode then
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


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIDragAllowed(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex: Integer; var Allowed: Boolean);
begin
  Allowed := (CategoryIndex = 0) and
             (((NodeLevel = CPropertyLevel) and (PropertyItemIndex = -1)) or
             ((NodeLevel = CPropertyItemLevel) and (PropertyItemIndex > -1)));
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIDragOver(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; State: TDragState; const Pt: TPoint; Mode: TDropMode; var Effect: DWORD; var Accept: Boolean);
var
  MatchingCategory: Boolean;
  SameSrcAndDest: Boolean;
  DraggingName, DraggingItem: Boolean;
  IsPropertyLevel, IsPropertyItemLevel: Boolean;
  DraggingFromTheSame: Boolean;
begin
  MatchingCategory := CategoryIndex = 0;
  SameSrcAndDest := NodeLevel = SrcNodeLevel;
  IsPropertyLevel := NodeLevel = CPropertyLevel;
  IsPropertyItemLevel := NodeLevel = CPropertyItemLevel;

  DraggingName := IsPropertyLevel and (PropertyItemIndex = -1);
  DraggingItem := IsPropertyItemLevel and (PropertyItemIndex > -1);
  DraggingFromTheSame := (PropertyIndex = SrcPropertyIndex) and IsPropertyItemLevel;

  Accept := MatchingCategory and
            SameSrcAndDest and
            (DraggingName or (DraggingItem and DraggingFromTheSame));
end;


procedure TfrmDrawingBoardSchemaEditorMain.HandleOnOIDragDrop(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; const Pt: TPoint; var Effect: DWORD; Mode: TDropMode);
begin
  if not ((CategoryIndex = 0) and (SrcCategoryIndex = 0)) then
    Exit;

  //dragging a property
  if (NodeLevel = CPropertyLevel) and (SrcNodeLevel = CPropertyLevel) then
    if (PropertyItemIndex = -1) and (SrcPropertyItemIndex = -1) then
      if PropertyIndex <> SrcPropertyIndex then
      begin
        //MoveProperty(SrcPropertyIndex, PropertyIndex);

        FOIFrame.ReloadPropertyItems(CategoryIndex, PropertyIndex, True);
        FOIFrame.ReloadPropertyItems(SrcCategoryIndex, SrcPropertyIndex, True);
        //DoOnTriggerOnControlsModified;
      end;

  //dragging a property item
  if (NodeLevel = CPropertyItemLevel) and (SrcNodeLevel = CPropertyItemLevel) then
    if (PropertyItemIndex > -1) and (SrcPropertyItemIndex > -1) then
      if PropertyIndex = SrcPropertyIndex then
        if PropertyItemIndex <> SrcPropertyItemIndex then
        begin
          //MovePropertyItem(PropertyIndex, SrcPropertyItemIndex, PropertyItemIndex);

          FOIFrame.ReloadPropertyItems(CategoryIndex, PropertyIndex, True);
          //DoOnTriggerOnControlsModified;
        end;
end;


end.

