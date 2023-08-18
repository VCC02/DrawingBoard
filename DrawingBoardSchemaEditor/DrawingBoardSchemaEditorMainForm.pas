{
    Copyright (C) 2022 VCC
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

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem_ExitClick(Sender: TObject);
    procedure MenuItem_NewClick(Sender: TObject);
    procedure MenuItem_OpenClick(Sender: TObject);
    procedure MenuItem_OpenSchemaProjectEditorClick(Sender: TObject);
    procedure MenuItem_SaveAsClick(Sender: TObject);
    procedure MenuItem_SaveClick(Sender: TObject);
    procedure MenuItem_SetSchemaFromFileClick(Sender: TObject);
  private
    FfrDrawingBoardSchemaEditor: TfrDrawingBoardSchemaEditor;

    FModified: Boolean;

    procedure SetModified(Value: Boolean);
    procedure ClearProject;

    procedure HandleOnDrawingBoardModified;

    property Modified: Boolean read FModified write SetModified;
  public

  end;

var
  frmDrawingBoardSchemaEditorMain: TfrmDrawingBoardSchemaEditorMain;

{Schema Frame - ToDo
- Add splitter
- Implement adding and removing items from categories  -  Misc

//MetaSchema - ToDo
[in work] - Implement editor handlers
- There is a ToDo item in HandleOnOIGetEnumConst about using a chached list, to display the contents of an enum.
- Implement adding and removing items from various properties or list of properties or adding/removing categories of Cat_# type.
}

implementation

{$R *.frm}

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

