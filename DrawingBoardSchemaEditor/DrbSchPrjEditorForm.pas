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
  ObjectInspectorFrame, VirtualTrees, ImgList, Menus, ExtCtrls, IniFiles,
  StdCtrls, ComCtrls, DrawingBoardSchemaEditorUtils;

type

  { TfrmDrbSchPrjEditor }

  TfrmDrbSchPrjEditor = class(TForm)
    lblInfo: TLabel;
    MenuItem_Close: TMenuItem;
    N1: TMenuItem;
    MenuItem_SaveAs: TMenuItem;
    MenuItem_Save: TMenuItem;
    MenuItem_Open: TMenuItem;
    MenuItem_New: TMenuItem;
    MenuItem_File: TMenuItem;
    mmDrbSch: TMainMenu;
    pnlSchemaProjOI: TPanel;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem_CloseClick(Sender: TObject);
    procedure MenuItem_NewClick(Sender: TObject);
    procedure MenuItem_OpenClick(Sender: TObject);
    procedure MenuItem_SaveAsClick(Sender: TObject);
    procedure MenuItem_SaveClick(Sender: TObject);
  private
    FOIFrame: TfrObjectInspector;
    FDrawingBoardMetaSchema: TDrawingBoardMetaSchema; //this doesn't have to match the metaschema used in main window
    FProjectFilename: string;
    FModified: Boolean;

    procedure SetModified(Value: Boolean);

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
    procedure ClearContent;

    procedure LoadSettings(AIni: TMemIniFile);
    procedure SaveSettings(AIni: TMemIniFile);
  end;


var
  frmDrbSchPrjEditor: TfrmDrbSchPrjEditor;


implementation

{$R *.frm}


const
  CFileDescription_CatIdx = 0;
  CSettings_CatIdx = 1;
  PredefinedDataTypes = 2;


{ TfrmDrbSchPrjEditor }

procedure TfrmDrbSchPrjEditor.FormCreate(Sender: TObject);
begin
  FDrawingBoardMetaSchema.FileTitle := '';
  SetLength(FDrawingBoardMetaSchema.Categories, 0);
  FProjectFilename := '';
  FModified := False;

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
  FOIFrame.ColumnWidths[0] := 330;
  FOIFrame.ColumnWidths[1] := 800;
end;


procedure TfrmDrbSchPrjEditor.FormDestroy(Sender: TObject);
begin
  ClearContent;
end;


procedure TfrmDrbSchPrjEditor.SetModified(Value: Boolean);
begin
  if FModified <> Value then
  begin
    FModified := Value;
    StatusBar1.Panels.Items[0].Text := BoolToStr(Value, 'Modified', '');
  end;

  StatusBar1.Panels.Items[1].Text := FProjectFilename;
end;


procedure TfrmDrbSchPrjEditor.ClearContent;
begin
  ClearDrawingBoardMetaSchema(FDrawingBoardMetaSchema);
  FOIFrame.ReloadContent;
end;


procedure TfrmDrbSchPrjEditor.LoadSettings(AIni: TMemIniFile);
begin
  Left := AIni.ReadInteger('DrbSchPrjEditor.Settings', 'Left', Left);
  Top := AIni.ReadInteger('DrbSchPrjEditor.Settings', 'Top', Top);
  Width := AIni.ReadInteger('DrbSchPrjEditor.Settings', 'Width', Width);
  Height := AIni.ReadInteger('DrbSchPrjEditor.Settings', 'Height', Height);
end;


procedure TfrmDrbSchPrjEditor.SaveSettings(AIni: TMemIniFile);
begin
  AIni.WriteInteger('DrbSchPrjEditor.Settings', 'Left', Left);
  AIni.WriteInteger('DrbSchPrjEditor.Settings', 'Top', Top);
  AIni.WriteInteger('DrbSchPrjEditor.Settings', 'Width', Width);
  AIni.WriteInteger('DrbSchPrjEditor.Settings', 'Height', Height);
end;


procedure TfrmDrbSchPrjEditor.MenuItem_NewClick(Sender: TObject);
begin
  ClearContent;
  FProjectFilename := '';
  Modified := False;
end;


procedure TfrmDrbSchPrjEditor.MenuItem_OpenClick(Sender: TObject);
var
  TempOpenDialog: TOpenDialog;
begin
  if Modified then
  begin
    MessageBox(Handle, 'The file is modified. Please save or discard it, before loading a new metaschema file.', PChar(Application.Title), MB_ICONINFORMATION);
    Exit;
  end;

  TempOpenDialog := TOpenDialog.Create(Self);
  try
    TempOpenDialog.Filter := 'DrawingBoard metaschema (*.drbsch)|*.drbsch|All Files (*.*)|*.*';
    if not TempOpenDialog.Execute then
      Exit;

    FProjectFilename := TempOpenDialog.FileName;

    ClearContent;
    LoadDrawingBoardMetaSchema(FProjectFilename, FDrawingBoardMetaSchema);
  finally
    TempOpenDialog.Free;
  end;

  FOIFrame.ReloadContent;
end;


procedure TfrmDrbSchPrjEditor.MenuItem_SaveClick(Sender: TObject);
var
  TempSaveDialog: TSaveDialog;
begin
  if FProjectFilename = '' then
  begin
    TempSaveDialog := TSaveDialog.Create(Self);
    try
      if not TempSaveDialog.Execute then
        Exit;

      FProjectFilename := TempSaveDialog.FileName;
      SaveDrawingBoardMetaSchema(TempSaveDialog.FileName, FDrawingBoardMetaSchema);
    finally
      TempSaveDialog.Free;
    end;
  end
  else
    SaveDrawingBoardMetaSchema(FProjectFilename, FDrawingBoardMetaSchema);

  Modified := False;
end;


procedure TfrmDrbSchPrjEditor.MenuItem_SaveAsClick(Sender: TObject);
var
  TempSaveDialog: TSaveDialog;
begin
  TempSaveDialog := TSaveDialog.Create(Self);
  try
    if not TempSaveDialog.Execute then
      Exit;

    FProjectFilename := TempSaveDialog.FileName;
    SaveDrawingBoardMetaSchema(FProjectFilename, FDrawingBoardMetaSchema);
  finally
    TempSaveDialog.Free;
  end;

  Modified := False;
end;


procedure TfrmDrbSchPrjEditor.MenuItem_CloseClick(Sender: TObject);
begin
  Close;
end;


////////////////////////////

function TfrmDrbSchPrjEditor.HandleOnOIGetCategoryCount: Integer;
begin
  Result := Length(FDrawingBoardMetaSchema.Categories) + 3; //3: [FileDescription], [Settings], [PredefinedDataTypes]
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
      Result := '[Cat_' + IntToStr(AIndex - 3) + ']   ' + FDrawingBoardMetaSchema.Categories[AIndex - 3].Name;
  end;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetCategoryValue(ACategoryIndex: Integer; var AEditorType: TOIEditorType): string;
begin
  Result := '';
  AEditorType := etUserEditor;
end;


function TfrmDrbSchPrjEditor.HandleOnOIGetPropertyCount(ACategoryIndex: Integer): Integer;
begin
  case ACategoryIndex of
    CFileDescription_CatIdx:
      Result := Length(FDrawingBoardMetaSchema.FileDescription);

    CSettings_CatIdx:
      Result := 2; // Title, CategoryCount

    PredefinedDataTypes:
      Result := Length(FDrawingBoardMetaSchema.PredefinedDataTypes);

    else
    begin
      ACategoryIndex := ACategoryIndex - 3;
      Result := Length(FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items) + 5;
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

          TempAttr := FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].Value;
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
      Result := FDrawingBoardMetaSchema.FileDescription[APropertyIndex];
      AEditorType := etTextWithArrow;
    end;

    CSettings_CatIdx:
    begin
      case APropertyIndex of
        0:
        begin
          Result := FDrawingBoardMetaSchema.FileTitle;
          AEditorType := etTextWithArrow;
        end;

        1:
        begin
          Result := IntToStr(Length(FDrawingBoardMetaSchema.Categories));
          AEditorType := etNone;
        end;
      end;
    end;

    PredefinedDataTypes:
    begin
      Result := FDrawingBoardMetaSchema.PredefinedDataTypes[APropertyIndex];
      AEditorType := etEnumCombo;
    end

    else
    begin
      ACategoryIndex := ACategoryIndex - 3;
      case APropertyIndex of
        0:
        begin
          Result := FDrawingBoardMetaSchema.Categories[ACategoryIndex].Name;
          AEditorType := etTextWithArrow;
        end;

        1:
        begin
          Result := FDrawingBoardMetaSchema.Categories[ACategoryIndex].CategoryComment;
          AEditorType := etTextWithArrow;
        end;

        2:
        begin
          Result := FDrawingBoardMetaSchema.Categories[ACategoryIndex].Item_CountKey;
          AEditorType := etTextWithArrow;
        end;

        3:
        begin
          Result := BoolToStr(FDrawingBoardMetaSchema.Categories[ACategoryIndex].CategoryEnabled, 'True', 'False');
          AEditorType := etBooleanCombo;
        end;

        4:
        begin
          Result := CStructureTypeStr[FDrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType];
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

      TempEditorType := FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].EditorType;
      TempAttr := FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].Value;
      Result := BoolToStr(AItemIndex and 1 = 1, TempEditorType, TempAttr);

      if AItemIndex and 1 = 1 then
        AEditorType := etEnumCombo
      else
        AEditorType := etTextWithArrow;
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
  case ANodeLevel of
    0:;

    1: //property
    begin
      case ACategoryIndex of
        CFileDescription_CatIdx:
        begin
          FDrawingBoardMetaSchema.FileDescription[APropertyIndex] := ANewText;
          //AEditorType := etUserEditor;
        end;

        CSettings_CatIdx:
        begin
          case APropertyIndex of
            0:
            begin
              FDrawingBoardMetaSchema.FileTitle := ANewText;
              //AEditorType := etTextWithArrow;
            end;

            1:
            begin
              //no editor here  (number of categories)
              //AEditorType := etNone;
            end;
          end;
        end;

        PredefinedDataTypes:
        begin
          FDrawingBoardMetaSchema.PredefinedDataTypes[APropertyIndex] := ANewText;
          //AEditorType := etEnumCombo;
        end

        else
        begin
          ACategoryIndex := ACategoryIndex - 3;
          case APropertyIndex of
            0:
            begin
              FDrawingBoardMetaSchema.Categories[ACategoryIndex].Name := ANewText;
              //AEditorType := etTextWithArrow;
            end;

            1:
            begin
              FDrawingBoardMetaSchema.Categories[ACategoryIndex].CategoryComment := ANewText;
              //AEditorType := etTextWithArrow;
            end;

            2:
            begin
              FDrawingBoardMetaSchema.Categories[ACategoryIndex].Item_CountKey := ANewText;
              //AEditorType := etTextWithArrow;
            end;

            3:
            begin
              FDrawingBoardMetaSchema.Categories[ACategoryIndex].CategoryEnabled := ANewText = 'True';
              //AEditorType := etBooleanCombo;
            end;

            4:
            begin
              FDrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType := StrToTStructureType(ANewText);
              //AEditorType := etEnumCombo;
            end;

            else
              ;
          end;
        end;
      end;
    end; //1:

    2: //property item
    begin
      case ACategoryIndex of
        CFileDescription_CatIdx:
          ;

        CSettings_CatIdx:
          ;

        PredefinedDataTypes:
          ;

        else
        begin
          ACategoryIndex := ACategoryIndex - 3;
          APropertyIndex := APropertyIndex - 5;

          if AItemIndex and 1 = 1 then
            FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].EditorType := ANewText
          else
            FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].Value := ANewText;

          //AEditorType := etEnumCombo;
        end;
      end;
    end; //2:
  end;

  Modified := True;
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

  case ANodeLevel of
    0:;

    1: //property
    begin
      case ACategoryIndex of
        CFileDescription_CatIdx:
          ;

        CSettings_CatIdx:
          ;

        PredefinedDataTypes:
          Result := Length(FDrawingBoardMetaSchema.PredefinedDataTypes);  //////////////////ToDo this should be the length of the cached list

        else
        begin
          ACategoryIndex := ACategoryIndex - 3;
          case APropertyIndex of
            3:
              Result := 2;   //CategoryEnabled

            4:
              Result := Integer(High(TStructureType)) + 1;   //StructureType

            else
              ;
          end;
        end;
      end;
    end; //1:

    2: //property item
    begin
      case ACategoryIndex of
        CFileDescription_CatIdx:
          ;

        CSettings_CatIdx:
          ;

        PredefinedDataTypes:
          ;

        else
        begin
          //ACategoryIndex := ACategoryIndex - 3;
          //APropertyIndex := APropertyIndex - 5;

          if AItemIndex and 1 = 1 then
            Result := 13    //EditorType
          else
            Result := 0;  //probably these strings can be cached and displayed as Enum, but for now, they have to be filled-in manually
        end;
      end;
    end; //2:
  end;
end;


procedure TfrmDrbSchPrjEditor.HandleOnOIGetEnumConst(ANodeLevel, ACategoryIndex, APropertyIndex, AItemIndex, AEnumItemIndex: Integer; var AEnumItemName: string);
begin
  AEnumItemName := '';
  case ANodeLevel of
    1: //property
    begin
      case ACategoryIndex of
        CFileDescription_CatIdx:
        begin
          //AEditorType := etUserEditor;
        end;

        CSettings_CatIdx:
        begin
          case APropertyIndex of
            0:
            begin
              //AEditorType := etTextWithArrow;
            end;

            1:
            begin
              //no editor here  (number of categories)
              //AEditorType := etNone;
            end;
          end;
        end;

        PredefinedDataTypes:
        begin
          //FDrawingBoardMetaSchema.PredefinedDataTypes[APropertyIndex] := ANewText;
          //AEditorType := etEnumCombo;
          //Result := Length(FDrawingBoardMetaSchema.PredefinedDataTypes);
          AEnumItemName := FDrawingBoardMetaSchema.PredefinedDataTypes[AEnumItemIndex];  //////////////////ToDo: this should be a cached list, not the "live" one (i.e. .PredefinedDataTypes), because when editing the live list, the items may be lost
        end

        else
        begin
          ACategoryIndex := ACategoryIndex - 3;
          case APropertyIndex of
            3:
            begin
              //FDrawingBoardMetaSchema.Categories[ACategoryIndex].CategoryEnabled := ANewText = 'True';
              //Result := 2;
              //AEditorType := etBooleanCombo;
              AEnumItemName := BoolToStr(AEnumItemIndex = 1);
            end;

            4:
            begin
              //FDrawingBoardMetaSchema.Categories[ACategoryIndex].StructureType := StrToTStructureType(ANewText);
              //Result := Integer(High(TStructureType)) + 1;
              //AEditorType := etEnumCombo;
              AEnumItemName := CStructureTypeStr[TStructureType(AEnumItemIndex)];
            end;

            else
              ;
          end;
        end;
      end;
    end; //1:

    2: //property item
    begin
      case ACategoryIndex of
        CFileDescription_CatIdx:
          ;

        CSettings_CatIdx:
          ;

        PredefinedDataTypes:
          ;

        else
        begin
          ACategoryIndex := ACategoryIndex - 3;
          APropertyIndex := APropertyIndex - 5;

          if AItemIndex and 1 = 1 then
          begin
            //FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].EditorType := ANewText
            //probably these strings can be cached and displayed as Enum, but for now, they have to be filled-in manually
            AEnumItemName := Copy(COIEditorTypeStr[TOIEditorType(AEnumItemIndex)], 3, MaxInt);
          end
          else
          begin
            //FDrawingBoardMetaSchema.Categories[ACategoryIndex].Items[APropertyIndex].Value := ANewText;
          end;


          //AEditorType := etEnumCombo;
        end;
      end;
    end; //2:
  end;
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

