{
    Copyright (C) 2023 VCC
    creation date: Aug 2023   (2023.08.10)
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
  ExtCtrls, Menus, ComCtrls, DrbSchPrjEditorForm, DrawingBoardSchemaEditorFrame;

type
  { TfrmDrawingBoardSchemaEditorMain }

  TfrmDrawingBoardSchemaEditorMain = class(TForm)
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
    pnlSchemaFrame: TPanel;
    StatusBar1: TStatusBar;
    tmrStartup: TTimer;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem_ExitClick(Sender: TObject);
    procedure MenuItem_NewClick(Sender: TObject);
    procedure MenuItem_OpenClick(Sender: TObject);
    procedure MenuItem_OpenSchemaProjectEditorClick(Sender: TObject);
    procedure MenuItem_SaveAsClick(Sender: TObject);
    procedure MenuItem_SaveClick(Sender: TObject);
    procedure MenuItem_SetSchemaFromFileClick(Sender: TObject);
    procedure tmrStartupTimer(Sender: TObject);
  private
    FfrDrawingBoardSchemaEditor: TfrDrawingBoardSchemaEditor;

    FModified: Boolean;

    procedure LoadSettings;
    procedure SaveSettings;

    procedure SetModified(Value: Boolean);
    procedure ClearProject;

    procedure HandleOnDrawingBoardModified;

    property Modified: Boolean read FModified write SetModified;
  public

  end;

var
  frmDrawingBoardSchemaEditorMain: TfrmDrawingBoardSchemaEditorMain;

{Schema Frame - ToDo
- The DataType attribute should have a menu with predefined datatypes
- DynTFTCG knows how to inherit datatypes from baseschema (it concatenates two lists). The editor should solve this somehow, because it has to display a list as Enum.
- there should be a new extension for schema files (in addition to .dynscm) which should be used as filter in open/save dialogs. Based on this extension the app should add it to files which have no extension on save.
- The [OneTimeComponentInitCode] section is not used by CG. It has to be removed from dynscm files.
- the DrawingBoardMetaSchemaFileName field has to be updated when updating the FileName property of DrawingBoard category  and <->   - see SetMetaSchemaFromFile - there is a ToDo item

//MetaSchema - ToDo
[in work] - Implement editor handlers
- There is a ToDo item in HandleOnOIGetEnumConst about using a cached list, to display the contents of an enum.
- all procedures for moving categories, properties and items, should be rewritten to shift array items, instead of swapping src and dest
}

implementation

{$R *.frm}

uses
  IniFiles, DrawingBoardSchemaEditorUtils;

const
  CPropertyNameString = '~Index~_Name'; //should be moved to a variable, read from app's settings file


{ TfrmDrawingBoardSchemaEditorMain }

procedure TfrmDrawingBoardSchemaEditorMain.FormCreate(Sender: TObject);
begin
  FfrDrawingBoardSchemaEditor := TfrDrawingBoardSchemaEditor.Create(Self);
  FfrDrawingBoardSchemaEditor.Parent := pnlSchemaFrame;
  FfrDrawingBoardSchemaEditor.Left := 0;
  FfrDrawingBoardSchemaEditor.Top := 0;
  FfrDrawingBoardSchemaEditor.Width := pnlSchemaFrame.Width;
  FfrDrawingBoardSchemaEditor.Height := pnlSchemaFrame.Height;
  FfrDrawingBoardSchemaEditor.Anchors := [akLeft, akTop, akRight, akBottom];
  FfrDrawingBoardSchemaEditor.Visible := True;

  FfrDrawingBoardSchemaEditor.PropertyNameString := CPropertyNameString;
  FfrDrawingBoardSchemaEditor.OnDrawingBoardModified := HandleOnDrawingBoardModified;

  tmrStartup.Enabled := True;
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
    if FfrDrawingBoardSchemaEditor.Project.ProjectFileName = '' then
    begin
      TempSaveDialog := TSaveDialog.Create(Self);
      try
        if not TempSaveDialog.Execute then
          Exit;

        FfrDrawingBoardSchemaEditor.SaveDrawingBoardProject(TempSaveDialog.FileName);
      finally
        TempSaveDialog.Free;
      end;
    end
    else
      FfrDrawingBoardSchemaEditor.SaveDrawingBoardProject(FfrDrawingBoardSchemaEditor.Project.ProjectFileName);
  end;

  Modified := False;

  try
    SaveSettings;
  except
  end;
end;


procedure TfrmDrawingBoardSchemaEditorMain.SetModified(Value: Boolean);
begin
  if FModified <> Value then
  begin
    FModified := Value;
    StatusBar1.Panels.Items[0].Text := BoolToStr(Value, 'Modified', '');
  end;

  StatusBar1.Panels.Items[1].Text := FfrDrawingBoardSchemaEditor.Project.ProjectFileName;
end;


procedure TfrmDrawingBoardSchemaEditorMain.LoadSettings;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + 'DrawingBoardSchemaEditor.ini');
  try
    Left := Ini.ReadInteger('Settings', 'Left', Left);
    Top := Ini.ReadInteger('Settings', 'Top', Top);
    Width := Ini.ReadInteger('Settings', 'Width', Width);
    Height := Ini.ReadInteger('Settings', 'Height', Height);

    frmDrbSchPrjEditor.LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;


procedure TfrmDrawingBoardSchemaEditorMain.SaveSettings;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + 'DrawingBoardSchemaEditor.ini');
  try
    Ini.WriteInteger('Settings', 'Left', Left);
    Ini.WriteInteger('Settings', 'Top', Top);
    Ini.WriteInteger('Settings', 'Width', Width);
    Ini.WriteInteger('Settings', 'Height', Height);

    frmDrbSchPrjEditor.SaveSettings(Ini);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;


procedure TfrmDrawingBoardSchemaEditorMain.ClearProject;
begin
  FfrDrawingBoardSchemaEditor.ClearContent;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_SetSchemaFromFileClick(
  Sender: TObject);
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

    FfrDrawingBoardSchemaEditor.SetMetaSchemaFromFile(TempOpenDialog.FileName);
  finally
    TempOpenDialog.Free;
  end;
end;


procedure TfrmDrawingBoardSchemaEditorMain.tmrStartupTimer(Sender: TObject);
begin
  tmrStartup.Enabled := False;
  LoadSettings;
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
    TempOpenDialog.Filter := 'All Files (*.*)|*.*|DynTFT schema file (*.dynscm)|*.dynscm';

    if not TempOpenDialog.Execute then
      Exit;

    FfrDrawingBoardSchemaEditor.LoadDrawingBoardProject(TempOpenDialog.FileName);
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
  if FfrDrawingBoardSchemaEditor.Project.ProjectFileName = '' then
  begin
    TempSaveDialog := TSaveDialog.Create(Self);
    try
      if not TempSaveDialog.Execute then
        Exit;

      FfrDrawingBoardSchemaEditor.SaveDrawingBoardProject(TempSaveDialog.FileName);
    finally
      TempSaveDialog.Free;
    end;
  end
  else
    FfrDrawingBoardSchemaEditor.SaveDrawingBoardProject(FfrDrawingBoardSchemaEditor.Project.ProjectFileName);

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

    FfrDrawingBoardSchemaEditor.SaveDrawingBoardProject(TempSaveDialog.FileName);
    MessageBox(Handle, PChar('Make sure you update the FilePath property, under ' + CDrawingBoardMetaSchemaKeyName + ' category.'), PChar(Application.Title), MB_ICONINFORMATION);
  finally
    TempSaveDialog.Free;
  end;

  Modified := False;
end;


procedure TfrmDrawingBoardSchemaEditorMain.MenuItem_ExitClick(Sender: TObject);
begin
  Close;
end;


////////////////////////////

procedure TfrmDrawingBoardSchemaEditorMain.HandleOnDrawingBoardModified;
begin
  Modified := True;
end;

end.

