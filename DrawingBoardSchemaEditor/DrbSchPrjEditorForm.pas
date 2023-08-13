{
    Copyright (C) 2022 VCC
    creation date: Jan 2023   (2023.08.13)
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


unit DrbSchPrjEditorForm;

{$mode Delphi}{$H+}

interface

uses
  LCLIntf, LCLType, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  IniFiles, ObjectInspectorFrame, VirtualTrees, ImgList, Menus, ExtCtrls,
  StdCtrls;

type
  TStringArr = array of string;
  TStructureType = (stCountable, stCode, stMisc);
  //-  0 = Countable (i.e. array of structure. See ComponentPropertiesSchema).
  //-  1 = Code (flat lines of code, no structure).
  //-  2 = Misc keys (see ComponentRegistration).

  TSchemaAttrItem = record
    Value: string;
    EditorType: string;
  end;

  TSchemaAttrItemArr = array of TSchemaAttrItem;

  TSchemaCategory = record
    Name: string;
    CategoryComment: string;
    Item_CountKey: string; //name of the "Count" key
    CategoryEnabled: Boolean;
    Items: TSchemaAttrItemArr;
    StructureType: TStructureType;
  end;

  TSchemaCategoryArr = array of TSchemaCategory;

  TDrawingBoardSchema = record
    FileTitle: string;
    Categories: TSchemaCategoryArr;
    FileDescription: TStringArr;
    PredefinedDataTypes: TStringArr;
  end;


  { TfrmDrbSchPrjEditor }

  TfrmDrbSchPrjEditor = class(TForm)
    lblInfo: TLabel;
    MenuItem_Open: TMenuItem;
    MenuItem_New: TMenuItem;
    MenuItem_File: TMenuItem;
    mmDrbSch: TMainMenu;
    pnlSchemaProjOI: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem_OpenClick(Sender: TObject);
  private
    FOIFrame: TfrObjectInspector;
    FDrawingBoardSchemaProject: TDrawingBoardSchema; //this doesn't have to match the schema project from the main window

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

  end;

procedure LoadDrawingBoardSchemaProject(AFnm: string; var ADrawingBoardSchema: TDrawingBoardSchema);

var
  frmDrbSchPrjEditor: TfrmDrbSchPrjEditor;

const
  CStructureTypeStr: array[TStructureType] of string = ('Countable', 'Code', 'Misc');
  CIndexReplacement = '~Index~';


implementation

{$R *.frm}


const
  CFileDescription_CatIdx = 0;
  CSettings_CatIdx = 1;
  PredefinedDataTypes = 2;


procedure LoadDrawingBoardSchemaProject(AFnm: string; var ADrawingBoardSchema: TDrawingBoardSchema);
var
  Ini: TMemIniFile;
  i, j: Integer;
  TempIndent, Prefix: string;
begin
  Ini := TMemIniFile.Create(AFnm);
  try
    ADrawingBoardSchema.FileTitle := Ini.ReadString('Settings', 'Title', 'File title');
    SetLength(ADrawingBoardSchema.Categories, Ini.ReadInteger('Settings', 'CategoryCount', 0));

    for i := 0 to Length(ADrawingBoardSchema.Categories) - 1 do
    begin
      TempIndent := 'Cat_' + IntToStr(i);
      ADrawingBoardSchema.Categories[i].Name := Ini.ReadString(TempIndent, 'Name', TempIndent);
      ADrawingBoardSchema.Categories[i].CategoryComment := Ini.ReadString(TempIndent, 'CategoryComment', '');
      ADrawingBoardSchema.Categories[i].Item_CountKey := Ini.ReadString(TempIndent, 'Item_CountKey', 'Count');
      ADrawingBoardSchema.Categories[i].CategoryEnabled := Ini.ReadBool(TempIndent, 'CategoryEnabled', True);
      ADrawingBoardSchema.Categories[i].StructureType := TStructureType(Ini.ReadInteger(TempIndent, 'StructureType', Ord(stCountable)) and 3);
      SetLength(ADrawingBoardSchema.Categories[i].Items, Ini.ReadInteger(TempIndent, 'CountableCount', 0));

      for j := 0 to Length(ADrawingBoardSchema.Categories[i].Items) - 1 do
      begin
        Prefix := 'Item_' + IntToStr(j);
        ADrawingBoardSchema.Categories[i].Items[j].Value := Ini.ReadString(TempIndent, Prefix, Prefix);
        ADrawingBoardSchema.Categories[i].Items[j].EditorType := Ini.ReadString(TempIndent, Prefix + '_EditorType', 'Text');
      end;
    end;

    SetLength(ADrawingBoardSchema.FileDescription, Ini.ReadInteger('FileDescription', 'Count', 0));
    for i := 0 to Length(ADrawingBoardSchema.FileDescription) - 1 do
    begin
      TempIndent := 'Line_' + IntToStr(i);
      ADrawingBoardSchema.FileDescription[i] := Ini.ReadString('FileDescription', TempIndent, '');
    end;

    SetLength(ADrawingBoardSchema.PredefinedDataTypes, Ini.ReadInteger('PredefinedDataTypes', 'Count', 0));
    for i := 0 to Length(ADrawingBoardSchema.PredefinedDataTypes) - 1 do
    begin
      TempIndent := 'DT_' + IntToStr(i);
      ADrawingBoardSchema.PredefinedDataTypes[i] := Ini.ReadString('PredefinedDataTypes', TempIndent, '');
    end;
  finally
    Ini.Free;
  end;
end;


{ TfrmDrbSchPrjEditor }

procedure TfrmDrbSchPrjEditor.FormCreate(Sender: TObject);
begin
  FDrawingBoardSchemaProject.FileTitle := '';
  SetLength(FDrawingBoardSchemaProject.Categories, 0);

  FOIFrame := TfrObjectInspector.Create(Self);
  FOIFrame.Left := 0;
  FOIFrame.Top := 0;
  FOIFrame.Width := pnlSchemaProjOI.Width;
  FOIFrame.Height := pnlSchemaProjOI.Height;
  FOIFrame.Anchors := [akBottom, akLeft, akRight, akTop];
  FOIFrame.Parent := pnlSchemaProjOI;

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


procedure TfrmDrbSchPrjEditor.MenuItem_OpenClick(Sender: TObject);
var
  TempOpenDialog: TOpenDialog;
begin
  //if Modified then
  //begin
  //  MessageBox(Handle, 'The project is modified. Please save or discard it, before loading a new schema file.', PChar(Application.Title), MB_ICONINFORMATION);
  //  Exit;
  //end;

  TempOpenDialog := TOpenDialog.Create(Self);
  try
    TempOpenDialog.Filter := 'DrawingBoard schema file (*.drbsch)|*.drbsch|All Files (*.*)|*.*';
    if not TempOpenDialog.Execute then
      Exit;

    //ClearProject;

    LoadDrawingBoardSchemaProject(TempOpenDialog.FileName, FDrawingBoardSchemaProject);
  finally
    TempOpenDialog.Free;
  end;

  FOIFrame.ReloadContent;
end;


////////////////////////////

function TfrmDrbSchPrjEditor.HandleOnOIGetCategoryCount: Integer;
begin
  Result := Length(FDrawingBoardSchemaProject.Categories) + 3; //3: [FileDescription], [Settings], [PredefinedDataTypes]
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetCategory(AIndex: Integer): string;
begin
  case AIndex of
    CFileDescription_CatIdx:
      Result := '[FileDescription]';

    CSettings_CatIdx:
      Result := '[Title]';

    PredefinedDataTypes:
      Result := '[PredefinedDataTypes]';

    else
      Result := '[Cat_' + IntToStr(AIndex - 3) + ']   ' + FDrawingBoardSchemaProject.Categories[AIndex - 3].Name;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetCategoryValue(ACategoryIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  Result := '';
  AEditorType := etTextWithArrow;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetPropertyCount(ACategoryIndex: Integer): Integer;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
      Result := Length(FDrawingBoardSchemaProject.FileDescription);

    CSettings_CatIdx:
      Result := 2; // Title, CategoryCount

    PredefinedDataTypes:
      Result := Length(FDrawingBoardSchemaProject.PredefinedDataTypes);

    else
    begin
      ACategoryIndex := ACategoryIndex - 3;
      Result := Length(FDrawingBoardSchemaProject.Categories[ACategoryIndex].Items) + 5;
    end;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetPropertyName(ACategoryIndex, APropertyIndex: Integer): string;
var
  TempAttr: string;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
      Result := 'Line_' + IntToStr(APropertyIndex);

    CSettings_CatIdx:
    begin
      case APropertyIndex of
        0: Result := 'File Title';
        1: Result := 'CategoryCount';
      end;
    end;

    PredefinedDataTypes:
      Result := 'DT_' + IntToStr(APropertyIndex);

    else
    begin
      case APropertyIndex of
        0: Result := 'Name';
        1: Result := 'CategoryComment';
        2: Result := 'Item_CountKey';
        3: Result := 'CategoryEnabled';
        4: Result := 'StructureType';
        else
        begin
          ACategoryIndex := ACategoryIndex - 3;
          APropertyIndex := APropertyIndex - 5;

          TempAttr := FDrawingBoardSchemaProject.Categories[ACategoryIndex].Items[APropertyIndex].Value;
          Result := StringReplace(TempAttr, CIndexReplacement, IntToStr(APropertyIndex), [rfReplaceAll]);
        end;
      end;
    end;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetPropertyValue(ACategoryIndex, APropertyIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
    begin
      Result := FDrawingBoardSchemaProject.FileDescription[APropertyIndex];
      AEditorType := etUserEditor;
    end;

    CSettings_CatIdx:
    begin
      case APropertyIndex of
        0:
        begin
          Result := FDrawingBoardSchemaProject.FileTitle;
          AEditorType := etTextWithArrow;
        end;

        1:
        begin
          Result := IntToStr(Length(FDrawingBoardSchemaProject.Categories));
          AEditorType := etNone;
        end;
      end;
    end;

    PredefinedDataTypes:
    begin
      Result := FDrawingBoardSchemaProject.PredefinedDataTypes[APropertyIndex];
      AEditorType := etEnumCombo;
    end

    else
    begin
      ACategoryIndex := ACategoryIndex - 3;
      case APropertyIndex of
        0:
        begin
          Result := FDrawingBoardSchemaProject.Categories[ACategoryIndex].Name;
          AEditorType := etTextWithArrow;
        end;

        1:
        begin
          Result := FDrawingBoardSchemaProject.Categories[ACategoryIndex].CategoryComment;
          AEditorType := etTextWithArrow;
        end;

        2:
        begin
          Result := FDrawingBoardSchemaProject.Categories[ACategoryIndex].Item_CountKey;
          AEditorType := etTextWithArrow;
        end;

        3:
        begin
          Result := BoolToStr(FDrawingBoardSchemaProject.Categories[ACategoryIndex].CategoryEnabled, 'True', 'False');
          AEditorType := etBooleanCombo;
        end;

        4:
        begin
          Result := CStructureTypeStr[FDrawingBoardSchemaProject.Categories[ACategoryIndex].StructureType];
          AEditorType := etEnumCombo;
        end;

        else
          Result := '';
      end;
    end;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetListPropertyItemCount(ACategoryIndex, APropertyIndex: Integer): Integer;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
      Result := 0;

    CSettings_CatIdx:
      Result := 0;

    PredefinedDataTypes:
      Result := 0;

    else
    begin
      if APropertyIndex < 5 then
        Result := 0
      else
        Result := 2;
    end;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetListPropertyItemName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
      Result := '';

    CSettings_CatIdx:
      Result := '';

    PredefinedDataTypes:
      Result := '';

    else
      Result := BoolToStr(AItemIndex and 1 = 1, 'Editor type', 'Attribute');
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetListPropertyItemValue(ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AEditorType: TOIEditorType): string;
var
  TempEditorType: string;
  TempAttr: string;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
      Result := '';

    CSettings_CatIdx:
      Result := '';

    PredefinedDataTypes:
      Result := '';

    else
    begin
      ACategoryIndex := ACategoryIndex - 3;
      APropertyIndex := APropertyIndex - 5;

      TempEditorType := FDrawingBoardSchemaProject.Categories[ACategoryIndex].Items[APropertyIndex].EditorType;
      TempAttr := FDrawingBoardSchemaProject.Categories[ACategoryIndex].Items[APropertyIndex].Value;
      Result := BoolToStr(AItemIndex and 1 = 1, TempEditorType, TempAttr);
      AEditorType := etEnumCombo;
    end;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnUIGetDataTypeName(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  Result := '';
end;


function TfrmDrbSchPrjEditor.HandleOnUIGetExtraInfo(ACategoryIndex, APropertyIndex, AItemIndex: Integer): string;
begin
  Result := '';
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIGetImageIndexEx(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList);
begin
  //
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIEditedText(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; ANewText: string);
begin
  //DoOnTriggerOnControlsModified;
end;


function TfrmDrbSchPrjEditor.HandleOnOIEditItems(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewItems: string): Boolean;
begin
  Result := False;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetColorConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
begin
  Result := 0;
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIGetColorConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AColorItemIndex: Integer; var AColorName: string; var AColorValue: Int64);
begin

end;



function TfrmDrbSchPrjEditor.HandleOnOIGetEnumConstsCount(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer): Integer;
begin
  Result := 0;

end;


procedure TfrmDrbSchPrjEditor.HandleOnOIGetEnumConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AEnumItemIndex: Integer; var AEnumItemName: string);
begin
  AEnumItemName := '';

end;



procedure TfrmDrbSchPrjEditor.HandleOnOIPaintText(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
  const TargetCanvas: TCanvas; Column: TColumnIndex; var TextType: TVSTTextType);
begin
  if ANodeData.Level = 0 then
  begin
    TargetCanvas.Font.Style := [fsBold];
    Exit;
  end;
end;



procedure TfrmDrbSchPrjEditor.HandleOnOIBeforeCellPaint(ANodeData: TNodeDataPropertyRec; ACategoryIndex, APropertyIndex, APropertyItemIndex: Integer;
  TargetCanvas: TCanvas; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin

end;



procedure TfrmDrbSchPrjEditor.HandleOnTextEditorMouseDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;


function TfrmDrbSchPrjEditor.HandleOnTextEditorMouseMove(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
end;



procedure TfrmDrbSchPrjEditor.HandleOnOITextEditorKeyUp(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;



procedure TfrmDrbSchPrjEditor.HandleOnOITextEditorKeyDown(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;



procedure TfrmDrbSchPrjEditor.HandleOnOIEditorAssignMenuAndTooltip(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  Sender: TObject; var APopupMenu: TPopupMenu; var AHint: string; var AShowHint: Boolean);
begin
  //
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIGetFileDialogSettings(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var AFilter, AInitDir: string);
begin

end;


procedure TfrmDrbSchPrjEditor.HandleOnOIArrowEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer);
begin

end;


procedure TfrmDrbSchPrjEditor.HandleOnOIUserEditorClick(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ARepaintValue: Boolean);
begin

end;



function TfrmDrbSchPrjEditor.HandleOnOIBrowseFile(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer;
  AFilter, ADialogInitDir: string; var Handled: Boolean; AReturnMultipleFiles: Boolean = False): string;
begin
  Handled := False;
  Result := '';
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIAfterSpinTextEditorChanging(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex: Integer; var ANewValue: string);
begin

end;


procedure TfrmDrbSchPrjEditor.HandleOnOISelectedNode(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//var
//  i: Integer;
//  s: string;
begin
  //
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIDragAllowed(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex: Integer; var Allowed: Boolean);
begin
  Allowed := (CategoryIndex = 0) and
             (((NodeLevel = CPropertyLevel) and (PropertyItemIndex = -1)) or
             ((NodeLevel = CPropertyItemLevel) and (PropertyItemIndex > -1)));
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIDragOver(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; State: TDragState; const Pt: TPoint; Mode: TDropMode; var Effect: DWORD; var Accept: Boolean);
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


procedure TfrmDrbSchPrjEditor.HandleOnOIDragDrop(NodeLevel, CategoryIndex, PropertyIndex, PropertyItemIndex, SrcNodeLevel, SrcCategoryIndex, SrcPropertyIndex, SrcPropertyItemIndex: Integer; Shift: TShiftState; const Pt: TPoint; var Effect: DWORD; Mode: TDropMode);
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

