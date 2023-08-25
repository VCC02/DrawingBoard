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


unit DrawingBoardDataTypes;

interface


uses
  Classes, Controls, StdCtrls, ExtCtrls, Graphics, DynTFTCodeGenSharedDataTypes;


type
  //Used for reading RunTimeComponentPropertiesSchema section from a Schema file.
  //Please update LoadComponentSchemaFromFile and LoadComponentSchema when adding or removing fields!
  TComponentPropertiesSchema = record
    PropertyName: string;
    PropertyDataType: string;
    PropertyDefaultValue: string;
    PropertyDescription: string;
    AvailableOnCompilerDirectives: string;
    DesignTimeOnly: Boolean;
    DesignTimeOnlyOverride: string;
    FromBaseSchema: Boolean;
    SkipAssignOnCodeGeneration: Boolean;
    SkipAssignOnCodeGenerationOverride: string;
    PropertyDataTypeDefinition: string;
    ReadOnly: Boolean;
    ReadOnlyOverride: string;
    //UseEnum: Integer; // Ignored if negative. If 0 or greater, it identifies a group of constants.      example of component schema entry:  Prop_1_UseEnum=1
  end;

  TComponentPropertiesSchemaArr = array of TComponentPropertiesSchema;
  PComponentPropertiesSchemaArr = ^TComponentPropertiesSchemaArr;


  TComponentInitCode = record
    Code: string;
    //Location: string;
  end;
                                 

  TStringArr = array of string;
  TStringListArr = array of TStringList;
  TBooleanArr = array of Boolean;

  TComponentSchema = record
    ComponentTypeName: string;             //PDynTFTButton, PDynTFTLabel, PDynTFTProgressBar etc
    ComponentTypeRegistrationIndex: Integer; //computed at code generation, by AddRegisterAllComponentsEvents procedure and used at generating RTTI code
    SchemaFile: string;
    Properties: TComponentPropertiesSchemaArr;
    Events: TComponentPropertiesSchemaArr;
    //EventDataTypes: TStringArr;
    Constants: TComponentConstantArr;
    ColorConstants: TComponentConstantArr;
    OneTimeInitCode_Interface: TComponentInitCode;
    OneTimeInitCode_Implementation: TComponentInitCode;
    PerInstanceInitCode: TComponentInitCode;
    PerInstanceInitConstants: TComponentInitCode;
    CreateComponentCode: TComponentInitCode;
    ComponentDependencies: TStringArr;
    RegisterEventsProc: string;
    GetComponentTypeFunc: string;
  end;



  TDynTFTExtendedDesignProperty = record
    PropertyName: string;
    PropertyValue: string;

    DisplayAsMixedValues: Boolean; // display "(...)" instead of the actual value, because multiple components have different values for this property

    PropertyDataType: string;
    PropertyDescription: string;
    AvailableOnCompilerDirectives: string;
    DesignTimeOnly: Boolean;
    ReadOnly: Boolean;

    DisplayAsMixedDataTypes: Boolean;
    DisplayAsMixedDescription: Boolean;
    DisplayAsMixedDirectiveAvailability: Boolean;
    DisplayAsMixedLocation: Boolean;
    DisplayAsMixedReadOnly: Boolean;

    //UseEnum: Integer;
  end;
                                      
  TDynTFTExtendedDesignPropertyArr = array of TDynTFTExtendedDesignProperty;


  
  //component instances on designer
  TDynTFTDesignComponentOneKind = record               /////////////// update DeleteComponentFrom_TDynTFTDesignAllComponentsArr and PasteSelectionFromClipboard if modifying structure
    ObjectName: string;                //DesignTime
    CreatedAtStartup: Boolean;         //DesignTime
    HasVariableInGUIObjects: Boolean;  //DesignTime
    IdxInVisualAtSave: Integer;        //same as IndexInTProjectVisualComponentArr, but updated and used only on save

    CustomProperties: TDynTFTDesignPropertyArr;
    CustomEvents: TDynTFTDesignPropertyArr;
  end;

  //this array holds components of the same kind, like PDynTFTButtons or PDynTFTLabels. This is required, because schemas are kept in separate arrays
  TDynTFTDesignComponentOneKindArr = array of TDynTFTDesignComponentOneKind;
  

  TDynTFTAllDesignComponentsByType = record
    //ComponentTypeIndexInComponentsTypeArr: Integer;  //index in TDynTFTSchemaFileArr, to indicate what [0] means, what [1] means etc
    DesignComponentsOneKind: TDynTFTDesignComponentOneKindArr; //[0] is a component from one type, [1] is another component of the same type etc
    Schema: TComponentSchema;
  end;

  PComponentSchema = ^TComponentSchema;

  //e.g. [0] is all PDynTFTButton(s), [1] is all PDynTFTLabel(s), [2] is all PDynTFTProgressBar(s)
  TDynTFTDesignAllComponentsArr = array of TDynTFTAllDesignComponentsByType; //all components from Designer, structured by component types
  PDynTFTDesignAllComponentsArr = ^TDynTFTDesignAllComponentsArr;

  TRefPanelComponentArr = array of Integer;

  TCompPluginIndex = record  //since all components are numbered top to bottom, this record provides a way to organize them by category
    CategoryIndex: Integer; // a.k.a. plugin index
    IndexInCategory: Integer; //a.k.a. index in plugin
  end;

  TCompPluginIndexArr = array of TCompPluginIndex;

  
  TMountPanel = class(TWinControl)
  private
    FIndexInTProjectVisualComponentArr: Integer;
    FCaption: TCaption;
    FImage: TImage;

    FTopLeftLabel: TLabel;
    FTopRightLabel: TLabel;
    FBotLeftLabel: TLabel;
    FBotRightLabel: TLabel;

    FLeftLabel: TLabel;
    FTopLabel: TLabel;
    FRightLabel: TLabel;
    FBotLabel: TLabel;

    FDynTFTComponentType: Integer; //0 = Button, 1 = ArrowButton  etc           //this is an overall index, used when all components from all plugins, are concatenated in one list
    FPluginIndex: Integer;
    FComponentIndexInPlugin: Integer;       // per plugin component index
    FUserData: Pointer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property IndexInTProjectVisualComponentArr: Integer read FIndexInTProjectVisualComponentArr write FIndexInTProjectVisualComponentArr;
    property Caption: TCaption read FCaption write FCaption;
    property Image: TImage read FImage write FImage;

    property TopLeftLabel: TLabel read FTopLeftLabel write FTopLeftLabel;
    property TopRightLabel: TLabel read FTopRightLabel write FTopRightLabel;
    property BotLeftLabel: TLabel read FBotLeftLabel write FBotLeftLabel;
    property BotRightLabel: TLabel read FBotRightLabel write FBotRightLabel;

    property LeftLabel: TLabel read FLeftLabel write FLeftLabel;
    property TopLabel: TLabel read FTopLabel write FTopLabel;
    property RightLabel: TLabel read FRightLabel write FRightLabel;
    property BotLabel: TLabel read FBotLabel write FBotLabel;

    property DynTFTComponentType: Integer read FDynTFTComponentType write FDynTFTComponentType;
    property PluginIndex: Integer read FPluginIndex write FPluginIndex;
    property ComponentIndexInPlugin: Integer read FComponentIndexInPlugin write FComponentIndexInPlugin;
    property UserData: Pointer read FUserData write FUserData;

    property PopupMenu;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TMountPanelArr = array of TMountPanel;

  TProjectVisualComponent = record    ///////////////////////// update DeleteComponentFrom_TProjectVisualComponentArr if modifying structure
    ScreenPanel: TMountPanel;   //This is a base panel, on which the component is "displayed". It is also the parent for those small dragging squares, used on moving and resizing.
    IndexInTDynTFTDesignAllComponentsArr: Integer;  // a.k.a type index or schema index
    IndexInDesignComponentOneKindArr: Integer;      // index in TDynTFTDesignComponentOneKindArr, stored by DesignComponentsOneKind field from TDynTFTAllDesignComponentsByType
  end;                                                 

  TProjectVisualComponentArr = array of TProjectVisualComponent;  //all displayed components of all types
  PProjectVisualComponentArr = ^TProjectVisualComponentArr;

  TComponentDefaultSize = record
    Width, Height: Integer;
    MinWidth, MaxWidth, MinHeight, MaxHeight: Integer;
  end;

  TScreenInfo = record
    Name: string;
    Color: TColor;
    ColorName: string; //used when resolving constants like CL_DynTFTScreen_Background
    Active: Boolean;
    Persisted: Boolean;
  end;

  TScreenInfoArr = array of TScreenInfo;
  PScreenInfoArr = ^TScreenInfoArr;


const
  CCustomColorName = 'Custom...';  //do not change this!!! It is required by ColorBox (color combo box)
  

implementation


constructor TMountPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImage := nil;
  FCaption := '';
  FIndexInTProjectVisualComponentArr := -10; //just an invalid number
end;


destructor TMountPanel.Destroy;
begin
  FImage.Free;

  FTopLeftLabel.Free;
  FTopRightLabel.Free;
  FBotLeftLabel.Free;
  FBotRightLabel.Free;

  FLeftLabel.Free;
  FTopLabel.Free;
  FRightLabel.Free;
  FBotLabel.Free;

  inherited Destroy;
end;

end.
