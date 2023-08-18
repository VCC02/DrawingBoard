{
    Copyright (C) 2022 VCC
    creation date: Aug 2023   (2023.08.18)
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


unit DrawingBoardSchemaEditorUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

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

  TDrawingBoardMetaSchema = record
    FileTitle: string;
    Categories: TSchemaCategoryArr;
    FileDescription: TStringArr;
    PredefinedDataTypes: TStringArr;
  end;


procedure LoadDrawingBoardMetaSchema(AFnm: string; var ADrawingBoardMetaSchema: TDrawingBoardMetaSchema);
procedure SaveDrawingBoardMetaSchema(AFnm: string; var ADrawingBoardMetaSchema: TDrawingBoardMetaSchema);
procedure ClearDrawingBoardMetaSchema(var ADrawingBoardMetaSchema: TDrawingBoardMetaSchema);

function StrToTStructureType(AStr: string): TStructureType;

const
  CStructureTypeStr: array[TStructureType] of string = ('Countable', 'Code', 'Misc');
  CIndexReplacement = '~Index~';


implementation

uses
  IniFiles;


procedure LoadDrawingBoardMetaSchema(AFnm: string; var ADrawingBoardMetaSchema: TDrawingBoardMetaSchema);
var
  Ini: TMemIniFile;
  i, j: Integer;
  TempIndent, Prefix: string;
begin
  Ini := TMemIniFile.Create(AFnm);
  try
    SetLength(ADrawingBoardMetaSchema.FileDescription, Ini.ReadInteger('FileDescription', 'Count', 0));
    for i := 0 to Length(ADrawingBoardMetaSchema.FileDescription) - 1 do
    begin
      TempIndent := 'Line_' + IntToStr(i);
      ADrawingBoardMetaSchema.FileDescription[i] := Ini.ReadString('FileDescription', TempIndent, '');
    end;

    ADrawingBoardMetaSchema.FileTitle := Ini.ReadString('Settings', 'Title', 'File title');
    SetLength(ADrawingBoardMetaSchema.Categories, Ini.ReadInteger('Settings', 'CategoryCount', 0));

    SetLength(ADrawingBoardMetaSchema.PredefinedDataTypes, Ini.ReadInteger('PredefinedDataTypes', 'Count', 0));
    for i := 0 to Length(ADrawingBoardMetaSchema.PredefinedDataTypes) - 1 do
    begin
      TempIndent := 'DT_' + IntToStr(i);
      ADrawingBoardMetaSchema.PredefinedDataTypes[i] := Ini.ReadString('PredefinedDataTypes', TempIndent, '');
    end;

    for i := 0 to Length(ADrawingBoardMetaSchema.Categories) - 1 do
    begin
      TempIndent := 'Cat_' + IntToStr(i);
      ADrawingBoardMetaSchema.Categories[i].Name := Ini.ReadString(TempIndent, 'Name', TempIndent);
      ADrawingBoardMetaSchema.Categories[i].CategoryComment := Ini.ReadString(TempIndent, 'CategoryComment', '');
      ADrawingBoardMetaSchema.Categories[i].Item_CountKey := Ini.ReadString(TempIndent, 'Item_CountKey', 'Count');
      ADrawingBoardMetaSchema.Categories[i].CategoryEnabled := Ini.ReadBool(TempIndent, 'CategoryEnabled', True);
      ADrawingBoardMetaSchema.Categories[i].StructureType := TStructureType(Ini.ReadInteger(TempIndent, 'StructureType', Ord(stCountable)) and 3);
      SetLength(ADrawingBoardMetaSchema.Categories[i].Items, Ini.ReadInteger(TempIndent, 'CountableCount', 0));

      for j := 0 to Length(ADrawingBoardMetaSchema.Categories[i].Items) - 1 do
      begin
        Prefix := 'Item_' + IntToStr(j);
        ADrawingBoardMetaSchema.Categories[i].Items[j].Value := Ini.ReadString(TempIndent, Prefix, Prefix);
        ADrawingBoardMetaSchema.Categories[i].Items[j].EditorType := Ini.ReadString(TempIndent, Prefix + '_EditorType', 'Text');
      end;
    end;
  finally
    Ini.Free;
  end;
end;


procedure SaveDrawingBoardMetaSchema(AFnm: string; var ADrawingBoardMetaSchema: TDrawingBoardMetaSchema);
var
  Content: TStringList;
  i, j: Integer;
  TempIndent, Prefix: string;
begin
  Content := TStringList.Create;
  try
    Content.Add('[FileDescription]');
    Content.Add('Count=' + IntToStr(Length(ADrawingBoardMetaSchema.FileDescription)));

    for i := 0 to Length(ADrawingBoardMetaSchema.FileDescription) - 1 do
    begin
      TempIndent := 'Line_' + IntToStr(i);
      Content.Add(TempIndent + '=' + ADrawingBoardMetaSchema.FileDescription[i]);
    end;

    Content.Add('');

    Content.Add('[Settings]');
    Content.Add('Title=' + ADrawingBoardMetaSchema.FileTitle);
    Content.Add('CategoryCount=' + IntToStr(Length(ADrawingBoardMetaSchema.Categories)));

    Content.Add('');

    Content.Add('[PredefinedDataTypes]');
    Content.Add('Count=' + IntToStr(Length(ADrawingBoardMetaSchema.PredefinedDataTypes)));

    for i := 0 to Length(ADrawingBoardMetaSchema.PredefinedDataTypes) - 1 do
    begin
      TempIndent := 'DT_' + IntToStr(i);
      Content.Add(TempIndent + '=' + ADrawingBoardMetaSchema.PredefinedDataTypes[i]);
    end;

    Content.Add('');

    for i := 0 to Length(ADrawingBoardMetaSchema.Categories) - 1 do
    begin
      TempIndent := 'Cat_' + IntToStr(i);
      Content.Add('[' + TempIndent + ']');

      Content.Add('Name=' + ADrawingBoardMetaSchema.Categories[i].Name);
      Content.Add('CategoryComment=' + ADrawingBoardMetaSchema.Categories[i].CategoryComment);
      Content.Add('Item_CountKey=' + ADrawingBoardMetaSchema.Categories[i].Item_CountKey);
      Content.Add('CategoryEnabled=' + IntToStr(Ord(ADrawingBoardMetaSchema.Categories[i].CategoryEnabled)));
      Content.Add('StructureType=' + IntToStr(Ord(ADrawingBoardMetaSchema.Categories[i].StructureType)));
      Content.Add('CountableCount=' + IntToStr(Length(ADrawingBoardMetaSchema.Categories[i].Items)));

      for j := 0 to Length(ADrawingBoardMetaSchema.Categories[i].Items) - 1 do
      begin
        Prefix := 'Item_' + IntToStr(j);
        Content.Add(Prefix + '=' + ADrawingBoardMetaSchema.Categories[i].Items[j].Value);
      end;

      for j := 0 to Length(ADrawingBoardMetaSchema.Categories[i].Items) - 1 do
      begin
        Prefix := 'Item_' + IntToStr(j) + '_EditorType';
        Content.Add(Prefix + '=' + ADrawingBoardMetaSchema.Categories[i].Items[j].EditorType);
      end;

      Content.Add('');
    end;

    Content.SaveToFile(AFnm);
  finally
    Content.Free;
  end;
end;


procedure ClearDrawingBoardMetaSchema(var ADrawingBoardMetaSchema: TDrawingBoardMetaSchema);
var
  i: Integer;
begin
  for i := 0 to Length(ADrawingBoardMetaSchema.Categories) - 1 do
  begin
    SetLength(ADrawingBoardMetaSchema.Categories[i].Items, 0);
    ADrawingBoardMetaSchema.Categories[i].Item_CountKey := '';
  end;

  SetLength(ADrawingBoardMetaSchema.Categories, 0);
  SetLength(ADrawingBoardMetaSchema.FileDescription, 0);
  SetLength(ADrawingBoardMetaSchema.PredefinedDataTypes, 0);
end;


function StrToTStructureType(AStr: string): TStructureType;
var
  i: TStructureType;
begin
  Result := Low(TStructureType);
  for i := Low(TStructureType) to High(TStructureType) do
    if AStr = CStructureTypeStr[i] then
    begin
      Result := i;
      Exit;
    end;
end;

end.

