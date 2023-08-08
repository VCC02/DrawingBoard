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


{$IFDEF FPC}
  {$mode objfpc} {$H+}
{$ENDIF}


unit DrawingBoardScreenEditorForm;

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  {$IFDEF FPC}
    ColorBox,
  {$ENDIF}
  DynTFTCodeGenSharedDataTypes, DrawingBoardDataTypes;

type
  TfrmDrawingBoardScreenEditor = class(TForm)
    lbeScreenName: TLabeledEdit;
    colcmbScreen: TColorBox;
    chkActive: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    pnlPreview: TPanel;
    lblR: TLabel;
    lblG: TLabel;
    lblB: TLabel;
    chkPersisted: TCheckBox;
    lblColor: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {$IFDEF FPC}CloseAction{$ELSE}Action{$ENDIF}: TCloseAction);
    procedure colcmbScreenSelect(Sender: TObject);
    procedure lbeScreenNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure colcmbScreenKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chkActiveKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chkPersistedKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure SetPreviewTextColor;
    procedure HandleDismissFromKeys(Key: Word);
  public
    { Public declarations }
  end;


function EditScreen(var ScreenInfo: TScreenInfo; var ColorConsts: TColorConstArr): Boolean;


implementation

{$IFDEF FPC}
  {$R *.frm}
{$ELSE}
  {$R *.dfm}
{$ENDIF} 


function EditScreen(var ScreenInfo: TScreenInfo; var ColorConsts: TColorConstArr): Boolean;
var
  frmDrawingBoardScreenEditor: TfrmDrawingBoardScreenEditor;
  i, ColorIndex: Integer;
begin
  Application.CreateForm(TfrmDrawingBoardScreenEditor, frmDrawingBoardScreenEditor);

  frmDrawingBoardScreenEditor.colcmbScreen.Clear;

  if ScreenInfo.ColorName = CCustomColorName then
    frmDrawingBoardScreenEditor.colcmbScreen.AddItem(CCustomColorName, TObject(ScreenInfo.Color))
  else
    frmDrawingBoardScreenEditor.colcmbScreen.AddItem(CCustomColorName, TObject(clBlack));

  for i := 0 to Length(ColorConsts) - 1 do
    frmDrawingBoardScreenEditor.colcmbScreen.AddItem(ColorConsts[i].Name, TObject(ColorConsts[i].Value));

  frmDrawingBoardScreenEditor.lbeScreenName.Text := ScreenInfo.Name;

  ColorIndex := frmDrawingBoardScreenEditor.colcmbScreen.Items.IndexOf(ScreenInfo.ColorName);
  if ColorIndex = -1 then
    frmDrawingBoardScreenEditor.colcmbScreen.Selected := ScreenInfo.Color
  else
    frmDrawingBoardScreenEditor.colcmbScreen.ItemIndex := ColorIndex;
    
  frmDrawingBoardScreenEditor.chkActive.Checked := ScreenInfo.Active;
  frmDrawingBoardScreenEditor.chkPersisted.Checked := ScreenInfo.Persisted;

  frmDrawingBoardScreenEditor.SetPreviewTextColor;

  frmDrawingBoardScreenEditor.ShowModal;
  Result := frmDrawingBoardScreenEditor.Tag = 1;

  if Result then
  begin
    ScreenInfo.Name := frmDrawingBoardScreenEditor.lbeScreenName.Text;
    ScreenInfo.Color := frmDrawingBoardScreenEditor.colcmbScreen.Selected;
    ScreenInfo.ColorName := frmDrawingBoardScreenEditor.colcmbScreen.Items.Strings[frmDrawingBoardScreenEditor.colcmbScreen.ItemIndex];
    ScreenInfo.Active := frmDrawingBoardScreenEditor.chkActive.Checked;
    ScreenInfo.Persisted := frmDrawingBoardScreenEditor.chkPersisted.Checked;
  end;
end;


{TfrmDrawingBoardScreenEditor}


procedure TfrmDrawingBoardScreenEditor.btnCancelClick(Sender: TObject);
begin
  Tag := 0;
  Close;
end;


procedure TfrmDrawingBoardScreenEditor.btnOKClick(Sender: TObject);
begin
  Tag := 1;
  Close;
end;


procedure TfrmDrawingBoardScreenEditor.chkActiveKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  HandleDismissFromKeys(Key);
end;


procedure TfrmDrawingBoardScreenEditor.chkPersistedKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  HandleDismissFromKeys(Key);
end;


procedure TfrmDrawingBoardScreenEditor.colcmbScreenKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  HandleDismissFromKeys(Key);
end;


procedure TfrmDrawingBoardScreenEditor.colcmbScreenSelect(Sender: TObject);
begin
  SetPreviewTextColor;
end;


procedure TfrmDrawingBoardScreenEditor.FormClose(Sender: TObject;
  var {$IFDEF FPC}CloseAction{$ELSE}Action{$ENDIF}: TCloseAction);
begin
  {$IFDEF FPC}CloseAction{$ELSE}Action{$ENDIF} := caFree;
end;


procedure TfrmDrawingBoardScreenEditor.HandleDismissFromKeys(Key: Word);
begin
  if Key = VK_RETURN then
  begin
    Tag := 1;
    Close;
  end;

  if Key = VK_ESCAPE then
  begin
    Tag := 0;
    Close;
  end;
end;


procedure TfrmDrawingBoardScreenEditor.lbeScreenNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  HandleDismissFromKeys(Key);
end;


function RGB(R, G, B: Byte): Integer;  //define a function for RGB, to avoid using compiler directives
begin
  Result := DWord(B) shl 16 + DWord(G) shl 8 + R;
end;
                                      

procedure TfrmDrawingBoardScreenEditor.SetPreviewTextColor;
var
  R, G, B: Byte;
  FontColor: TColor;
begin
  pnlPreview.Color := colcmbScreen.Selected;
  
  R := pnlPreview.Color and $FF;
  G := (pnlPreview.Color shr 8) and $FF;
  B := (pnlPreview.Color shr 16) and $FF;

  FontColor := RGB(Byte(G + 170), Byte(B - 170), Byte(R - 85));
  pnlPreview.Font.Color := FontColor;

  lblR.Caption := 'R: ' + IntToStr(R) + '  ($' + IntToHex(R, 2) + ')';
  lblG.Caption := 'G: ' + IntToStr(G) + '  ($' + IntToHex(G, 2) + ')';
  lblB.Caption := 'B: ' + IntToStr(B) + '  ($' + IntToHex(B, 2) + ')';
end;

end.
