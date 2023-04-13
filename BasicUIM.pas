unit BasicUIM;

interface

uses
  SysUtils;
{$message 'descriptions'}
{===============================================================================
    Library-specific exceptions
===============================================================================}
type
  EUIMException = class(Exception);

  EUIMIndexOutOfBounds  = class(EUIMException);
  EUIMInvalidValue      = class(EUIMException);
  EUIMDuplicateItem     = class(EUIMException);
  EUIMInvalidIdentifier = class(EUIMException);

{===============================================================================
    Auxiliary functions - declaration
===============================================================================}
{
  Use this function to create a TMethod variable from separate code and data
  pointers - see TUIMImplementedObject.Add methods for further details and
  possible use case.
}
Function Method(Code,Data: Pointer): TMethod;

{===============================================================================
--------------------------------------------------------------------------------
                                 TUIMCommonClass
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TUIMCommonClass - class declaration
===============================================================================}
{
  TUIMCommonClass is here to remove a need for AuxClasses library, as it is not
  desirable for this library to have any dependencies.
}
type
  TUIMCommonClass = class(TObject)
  protected
    Function GetCapacity: Integer; virtual; abstract;
    procedure SetCapacity(Value: Integer); virtual; abstract;
    Function GetCount: Integer; virtual; abstract;
    class Function GrowDelta: Integer; virtual; abstract;
    procedure Grow; virtual;
  public
    Function LowIndex: Integer; virtual; abstract;
    Function HighIndex: Integer; virtual; abstract;
    Function CheckIndex(Index: Integer): Boolean; virtual;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                              TUIMImplementedObject
--------------------------------------------------------------------------------
===============================================================================}
type
  TUIMIdentifier = type Integer;

  TUIMObjectType = (otFunction,otMethod,otObject,otClass);

  TUIMImplementationFlag = (ifSelect,ifAvailable,ifSupported);
  TUIMImplementationFlags = set of TUIMImplementationFlag;  

type
  TUIMImplementation = record
    ImplementationID:     TUIMIdentifier;
    ImplementationFlags:  TUIMImplementationFlags;
    case ImplementorType: TUIMObjectType of
      otFunction: (FunctionImplementor: Pointer);
      otMethod:   (MethodImplementor:   TMethod);
      otObject:   (ObjectImplementor:   TObject);
      otClass:    (ClassImplementor:    TClass);
  end;

{===============================================================================
    TUIMImplementedObject - class declaration
===============================================================================}
type
  TUIMImplementedObject = class(TUIMCommonClass)
  protected
    fImplementedObjectID:       TUIMIdentifier;
    fImplementedObjectType:     TUIMObjectType;
    fImplementedObjectVarAddr:  Pointer;
    fImplementations:           array of TUIMImplementation;
    fImplementationCount:       Integer;
    fSelectedIndex:             Integer;
    Function GetImplementation(Index: Integer): TUIMImplementation; virtual;
    Function GetImplementationFlags(Index: Integer): TUIMImplementationFlags; virtual;
    procedure SetImplementationFlags(Index: Integer; Value: TUIMImplementationFlags); virtual;
    Function GetSelectedIndex: Integer; virtual;
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    class Function GrowDelta: Integer; override;
    procedure Initialize(ImplementedObjectID: TUIMIdentifier; ImplementedObjectType: TUIMObjectType; VarAddr: Pointer); virtual;
    procedure Finalize; virtual;
    Function Add(ImplementationID: TUIMIdentifier; ImplementorType: TUIMObjectType; ImplementorPtr: Pointer; ImplementationFlags: TUIMImplementationFlags): Integer; overload; virtual;
  public
    constructor Create(ImplementedObjectID: TUIMIdentifier; var FunctionVariable: Pointer); overload;
    constructor Create(ImplementedObjectID: TUIMIdentifier; var MethodVariable: TMethod); overload;
    constructor Create(ImplementedObjectID: TUIMIdentifier; var ObjectVariable: TObject); overload;
    constructor Create(ImplementedObjectID: TUIMIdentifier; var ClassVariable: TClass); overload;
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function IndexOf(ImplementationID: TUIMIdentifier): Integer; virtual;
    Function Find(ImplementationID: TUIMIdentifier; out Index: Integer): Boolean; virtual;
    Function Add(ImplementationID: TUIMIdentifier; FunctionImplementor: Pointer; ImplementationFlags: TUIMImplementationFlags = []): Integer; overload; virtual;
    Function Add(ImplementationID: TUIMIdentifier; MethodImplementor: TMethod; ImplementationFlags: TUIMImplementationFlags = []): Integer; overload; virtual;
    Function Add(ImplementationID: TUIMIdentifier; MethodImplementorCode,MethodImplementorData: Pointer; ImplementationFlags: TUIMImplementationFlags = []): Integer; overload; virtual;
    Function Add(ImplementationID: TUIMIdentifier; ObjectImplementor: TObject; ImplementationFlags: TUIMImplementationFlags = []): Integer; overload; virtual;
    Function Add(ImplementationID: TUIMIdentifier; ClassImplementor: TClass; ImplementationFlags: TUIMImplementationFlags = []): Integer; overload; virtual;
  {
    If an implementation is removed or deleted, it is NOT automatically
    deselected, value in routing variable stays as is.
  }
    Function Remove(ImplementationID: TUIMIdentifier): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    Function FlagsGet(ImplementationID: TUIMIdentifier): TUIMImplementationFlags; virtual;
    Function FlagsSet(ImplementationID: TUIMIdentifier; ImplementationFlags: TUIMImplementationFlags): TUIMImplementationFlags; virtual;
    Function FlagAdd(ImplementationID: TUIMIdentifier; ImplementationFlag: TUIMImplementationFlag): Boolean; virtual;
    Function FlagRemove(ImplementationID: TUIMIdentifier; ImplementationFlag: TUIMImplementationFlag): Boolean; virtual;
    Function Selected(out SelectedImplementationID: TUIMIdentifier): Boolean; overload; virtual;
    Function Selected: TUIMIdentifier; overload; virtual;
    Function IsSelected(ImplementationID: TUIMIdentifier): Boolean; overload; virtual;
    Function SelectIndex(Index: Integer): TUIMIdentifier; virtual;
    procedure Select(ImplementationID: TUIMIdentifier); virtual;
    procedure Deselect; virtual;
    Function CheckRouting: Boolean; virtual;
    property ImplementedObjectID: TUIMIdentifier read fImplementedObjectID;
    property ImplementedObjectType: TUIMObjectType read fImplementedObjectType;
    property ImplementedObjectVariableAddress: Pointer read fImplementedObjectVarAddr;
    property Implementations[Index: Integer]: TUIMImplementation read GetImplementation; default;
    property ImplementationsFlags[Index: Integer]: TUIMImplementationFlags read GetImplementationFlags write SetImplementationFlags;
    property ImplementationCount: Integer read GetCount;
    property SelectedIndex: Integer read GetSelectedIndex;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                             TImplementationManager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TImplementationManager - class declaration
===============================================================================}
type
  TImplementationManager = class(TUIMCommonClass)
  protected
    fImplementedObjects:      array of TUIMImplementedObject;
    fImplementedObjectCount:  Integer;
    Function GetImplementedObject(Index: Integer): TUIMImplementedObject; virtual;
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    class Function GrowDelta: Integer; override;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    Function Add(ImplementedObjectID: TUIMIdentifier; ObjectType: TUIMObjectType; VarAddr: Pointer): Integer; overload; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function IndexOf(ImplementedObjectID: TUIMIdentifier): Integer; virtual;
    Function Find(ImplementedObjectID: TUIMIdentifier; out Index: Integer): Boolean; virtual;
    Function FindObj(ImplementedObjectID: TUIMIdentifier): TUIMImplementedObject; virtual;
    Function Add(ImplementedObjectID: TUIMIdentifier; var FunctionVariable: Pointer): Integer; overload; virtual;
    Function Add(ImplementedObjectID: TUIMIdentifier; var MethodVariable: TMethod): Integer; overload; virtual;
    Function Add(ImplementedObjectID: TUIMIdentifier; var ObjectVariable: TObject): Integer; overload; virtual;
    Function Add(ImplementedObjectID: TUIMIdentifier; var ClassVariable: TClass): Integer; overload; virtual;
    Function AddObj(ImplementedObjectID: TUIMIdentifier; var FunctionVariable: Pointer): TUIMImplementedObject; overload; virtual;
    Function AddObj(ImplementedObjectID: TUIMIdentifier; var MethodVariable: TMethod): TUIMImplementedObject; overload; virtual;
    Function AddObj(ImplementedObjectID: TUIMIdentifier; var ObjectVariable: TObject): TUIMImplementedObject; overload; virtual;
    Function AddObj(ImplementedObjectID: TUIMIdentifier; var ClassVariable: TClass): TUIMImplementedObject; overload; virtual;
    Function Remove(ImplementedObjectID: TUIMIdentifier): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    property ImplementedObjects[Index: Integer]: TUIMImplementedObject read GetImplementedObject; default;
    property ImplementedObjectCount: Integer read GetCount;
  end;

type
  // some aliases
  TUnitImplementationManager = TImplementationManager;
  TUnitImplManager = TImplementationManager;

implementation

{===============================================================================
    Auxiliary functions - implementation
===============================================================================}

Function Method(Code,Data: Pointer): TMethod;
begin
Result.Code := Code;
Result.Data := Data;
end;

{===============================================================================
--------------------------------------------------------------------------------
                                 TUIMCommonClass
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TUIMCommonClass - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TUIMCommonClass - protectecd methods
-------------------------------------------------------------------------------}

procedure TUIMCommonClass.Grow;
begin
If Count >= Capacity then
  Capacity := Capacity + GrowDelta; 
end;

{-------------------------------------------------------------------------------
    TUIMCommonClass - public methods
-------------------------------------------------------------------------------}

Function TUIMCommonClass.CheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= LowIndex) and (Index <= HighIndex);
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TUIMImplementedObject
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TUIMImplementedObject - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TUIMImplementedObject - protectecd methods
-------------------------------------------------------------------------------}

Function TUIMImplementedObject.GetImplementation(Index: Integer): TUIMImplementation;
begin
If CheckIndex(Index) then
  Result := fImplementations[Index]
else
  raise EUIMIndexOutOfBounds.CreateFmt('TUIMImplementedObject.GetImplementation: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.GetImplementationFlags(Index: Integer): TUIMImplementationFlags;
begin
If CheckIndex(Index) then
  Result := fImplementations[Index].ImplementationFlags
else
  raise EUIMIndexOutOfBounds.CreateFmt('TUIMImplementedObject.GetImplementationFlags: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.SetImplementationFlags(Index: Integer; Value: TUIMImplementationFlags);
begin
If CheckIndex(Index) then
  fImplementations[Index].ImplementationFlags := Value
else
  raise EUIMIndexOutOfBounds.CreateFmt('TUIMImplementedObject.SetImplementationFlags: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.GetSelectedIndex: Integer;
begin
If not CheckRouting then
  fSelectedIndex := -1;
Result := fSelectedIndex;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.GetCapacity: Integer;
begin
Result := Length(fImplementations);
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.SetCapacity(Value: Integer);
begin
If Value >= 0 then
  begin
    // there is no need for per-item initialization or finalization
    SetLength(fImplementations,Value);
    If Value < fImplementationCount then
      fImplementationCount := Value;
  end
else raise EUIMInvalidValue.CreateFmt('TUIMImplementedObject.SetCapacity: Invalid capacity value (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.GetCount: Integer;
begin
Result := fImplementationCount;
end;

//------------------------------------------------------------------------------

class Function TUIMImplementedObject.GrowDelta: Integer;
begin
Result := 4;
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.Initialize(ImplementedObjectID: TUIMIdentifier; ImplementedObjectType: TUIMObjectType; VarAddr: Pointer);
begin
fImplementedObjectID := ImplementedObjectID;
fImplementedObjectType := ImplementedObjectType;
fImplementedObjectVarAddr := VarAddr;
SetLength(fImplementations,0);
fImplementationCount := 0;
fSelectedIndex := -1;
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.Finalize;
begin
// nothing to do atm. (do NOT deselect implementations)
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.Add(ImplementationID: TUIMIdentifier; ImplementorType: TUIMObjectType; ImplementorPtr: Pointer; ImplementationFlags: TUIMImplementationFlags): Integer;
begin
If fImplementedObjectType = ImplementorType then
  begin
    If not Find(ImplementationID,Result) then
      begin
        Grow;
        Result := fImplementationCount;
        fImplementations[Result].ImplementationID := ImplementationID;
        fImplementations[Result].ImplementationFlags := ImplementationFlags;
        fImplementations[Result].ImplementorType := ImplementorType;
        case ImplementorType of
          otFunction: fImplementations[Result].FunctionImplementor := Pointer(ImplementorPtr^);
          otMethod:   fImplementations[Result].MethodImplementor := TMethod(ImplementorPtr^);
          otObject:   fImplementations[Result].ClassImplementor := TClass(ImplementorPtr^);
          otClass:    fImplementations[Result].ClassImplementor := TClass(ImplementorPtr^);
        else
          raise EUIMInvalidValue.CreateFmt('TUIMImplementedObject.Add: Invalid implementor type (%d).',[Ord(ImplementorType)]);
        end;
        Inc(fImplementationCount);
        If ifSelect in ImplementationFlags then
          begin
            SelectIndex(Result);
            Exclude(fImplementations[Result].ImplementationFlags,ifSelect);
          end;
      end
    else raise EUIMDuplicateItem.CreateFmt('TUIMImplementedObject.Add: Implementation with selected id (%d) already exists.',[ImplementationID]);
  end
else raise EUIMInvalidValue.CreateFmt('TUIMImplementedObject.Add: Wrong implementor type (%d), required %d.',[Ord(ImplementorType),Ord(fImplementedObjectType)]);
end;

{-------------------------------------------------------------------------------
    TUIMImplementedObject - public methods
-------------------------------------------------------------------------------}

constructor TUIMImplementedObject.Create(ImplementedObjectID: TUIMIdentifier; var FunctionVariable: Pointer);
begin
inherited Create;
Initialize(ImplementedObjectID,otFunction,@FunctionVariable);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TUIMImplementedObject.Create(ImplementedObjectID: TUIMIdentifier; var MethodVariable: TMethod);
begin
inherited Create;
Initialize(ImplementedObjectID,otMethod,@MethodVariable);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TUIMImplementedObject.Create(ImplementedObjectID: TUIMIdentifier; var ObjectVariable: TObject);
begin
inherited Create;
Initialize(ImplementedObjectID,otObject,@ObjectVariable);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TUIMImplementedObject.Create(ImplementedObjectID: TUIMIdentifier; var ClassVariable: TClass);
begin
inherited Create;
Initialize(ImplementedObjectID,otClass,@ClassVariable);
end;

//------------------------------------------------------------------------------

destructor TUIMImplementedObject.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.LowIndex: Integer;
begin
Result := Low(fImplementations);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.HighIndex: Integer;
begin
Result := Pred(fImplementationCount);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.IndexOf(ImplementationID: TUIMIdentifier): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If fImplementations[i].ImplementationID = ImplementationID then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.Find(ImplementationID: TUIMIdentifier; out Index: Integer): Boolean;
begin
Index := IndexOf(ImplementationID);
Result := CheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.Add(ImplementationID: TUIMIdentifier; FunctionImplementor: Pointer; ImplementationFlags: TUIMImplementationFlags = []): Integer;
begin
Result := Add(ImplementationID,otFunction,@FunctionImplementor,ImplementationFlags);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUIMImplementedObject.Add(ImplementationID: TUIMIdentifier; MethodImplementor: TMethod; ImplementationFlags: TUIMImplementationFlags = []): Integer;
begin
Result := Add(ImplementationID,otMethod,@MethodImplementor,ImplementationFlags);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUIMImplementedObject.Add(ImplementationID: TUIMIdentifier; MethodImplementorCode,MethodImplementorData: Pointer; ImplementationFlags: TUIMImplementationFlags = []): Integer;
var
  MethodTemp: TMethod;
begin
MethodTemp.Code := MethodImplementorCode;
MethodTemp.Data := MethodImplementorData;
Result := Add(ImplementationID,otMethod,@MethodTemp,ImplementationFlags);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUIMImplementedObject.Add(ImplementationID: TUIMIdentifier; ObjectImplementor: TObject; ImplementationFlags: TUIMImplementationFlags = []): Integer;
begin
Result := Add(ImplementationID,otObject,@ObjectImplementor,ImplementationFlags);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUIMImplementedObject.Add(ImplementationID: TUIMIdentifier; ClassImplementor: TClass; ImplementationFlags: TUIMImplementationFlags = []): Integer;
begin
Result := Add(ImplementationID,otClass,@ClassImplementor,ImplementationFlags);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.Remove(ImplementationID: TUIMIdentifier): Integer;
begin
If Find(ImplementationID,Result) then
  Delete(Result)
else
  Result := -1;
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    If fSelectedIndex = Index then
      fSelectedIndex := -1;
    For i := Index to Pred(HighIndex) do
      begin
        fImplementations[i] := fImplementations[i + 1];
        If fSelectedIndex = (i + 1) then
          Dec(fSelectedIndex);
      end;
    Dec(fImplementationCount);
  end
else raise EUIMIndexOutOfBounds.CreateFmt('TUIMImplementedObject.Delete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.Clear;
begin
SetCapacity(0);
fSelectedIndex := -1;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.FlagsGet(ImplementationID: TUIMIdentifier): TUIMImplementationFlags;
var
  Index:  Integer;
begin
If Find(ImplementationID,Index) then
  Result := fImplementations[Index].ImplementationFlags
else
  raise EUIMInvalidIdentifier.CreateFmt('TUIMImplementedObject.FlagsGet: Implementation with selected ID (%d) not found.',[ImplementationID]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.FlagsSet(ImplementationID: TUIMIdentifier; ImplementationFlags: TUIMImplementationFlags): TUIMImplementationFlags;
var
  Index:  Integer;
begin
If Find(ImplementationID,Index) then
  begin
    Result := fImplementations[Index].ImplementationFlags;
    fImplementations[Index].ImplementationFlags := ImplementationFlags;
  end
else raise EUIMInvalidIdentifier.CreateFmt('TUIMImplementedObject.FlagsSet: Implementation with selected ID (%d) not found.',[ImplementationID]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.FlagAdd(ImplementationID: TUIMIdentifier; ImplementationFlag: TUIMImplementationFlag): Boolean;
var
  Index:  Integer;
begin
If Find(ImplementationID,Index) then
  begin
    Result := ImplementationFlag in fImplementations[Index].ImplementationFlags;
    Include(fImplementations[Index].ImplementationFlags,ImplementationFlag);
  end
else raise EUIMInvalidIdentifier.CreateFmt('TUIMImplementedObject.FlagAdd: Implementation with selected ID (%d) not found.',[ImplementationID]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.FlagRemove(ImplementationID: TUIMIdentifier; ImplementationFlag: TUIMImplementationFlag): Boolean;
var
  Index:  Integer;
begin
If Find(ImplementationID,Index) then
  begin
    Result := ImplementationFlag in fImplementations[Index].ImplementationFlags;
    Exclude(fImplementations[Index].ImplementationFlags,ImplementationFlag);
  end
else raise EUIMInvalidIdentifier.CreateFmt('TUIMImplementedObject.FlagRemove: Implementation with selected ID (%d) not found.',[ImplementationID]);
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.Selected(out SelectedImplementationID: TUIMIdentifier): Boolean;
begin
If not CheckRouting then
  fSelectedIndex := -1;
If CheckIndex(fSelectedIndex) then
  begin
    SelectedImplementationID := fImplementations[fSelectedIndex].ImplementationID;
    Result := True;
  end
else Result := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TUIMImplementedObject.Selected: TUIMIdentifier;
begin
If not Selected(Result) then
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.IsSelected(ImplementationID: TUIMIdentifier): Boolean;
begin
If not CheckRouting then
  fSelectedIndex := -1;
If CheckIndex(fSelectedIndex) then
  Result := ImplementationID = fImplementations[fSelectedIndex].ImplementationID
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.SelectIndex(Index: Integer): TUIMIdentifier;
begin
If CheckIndex(Index) then
  begin
    fSelectedIndex := Index;
    case fImplementedObjectType of
      otFunction: Pointer(fImplementedObjectVarAddr^) := fImplementations[fSelectedIndex].FunctionImplementor;
      otMethod:   TMethod(fImplementedObjectVarAddr^) := fImplementations[fSelectedIndex].MethodImplementor;
      otObject:   TObject(fImplementedObjectVarAddr^) := fImplementations[fSelectedIndex].ObjectImplementor;
      otClass:    TClass(fImplementedObjectVarAddr^) := fImplementations[fSelectedIndex].ClassImplementor;
    else
      raise EUIMInvalidValue.CreateFmt('TUIMImplementedObject.SelectIndex: Invalid implemented object type (%d).',[Ord(fImplementedObjectType)])
    end;
    Result := fImplementations[Index].ImplementationID;
  end
else raise EUIMIndexOutOfBounds.CreateFmt('TUIMImplementedObject.SelectIndex: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.Select(ImplementationID: TUIMIdentifier);
var
  Index:  Integer;
begin
If Find(ImplementationID,Index) then
  SelectIndex(Index)
else
  raise EUIMInvalidIdentifier.CreateFmt('TUIMImplementedObject.Select: Implementation with selected ID (%d) not found.',[ImplementationID]);
end;

//------------------------------------------------------------------------------

procedure TUIMImplementedObject.Deselect;
begin
fSelectedIndex := -1;
case fImplementedObjectType of
  otFunction: Pointer(fImplementedObjectVarAddr^) := nil;
  otMethod:   begin
                TMethod(fImplementedObjectVarAddr^).Code := nil;
                TMethod(fImplementedObjectVarAddr^).Data := nil;
              end;
  otObject:   TObject(fImplementedObjectVarAddr^) := TObject(nil);
  otClass:    TClass(fImplementedObjectVarAddr^) := TClass(nil);
else
  raise EUIMInvalidValue.CreateFmt('TUIMImplementedObject.Deselect: Invalid implemented object type (%d).',[Ord(fImplementedObjectType)])
end;
end;

//------------------------------------------------------------------------------

Function TUIMImplementedObject.CheckRouting: Boolean;
begin
If CheckIndex(fSelectedIndex) then
  case fImplementedObjectType of
    otFunction: Result := Pointer(fImplementedObjectVarAddr^) = fImplementations[fSelectedIndex].FunctionImplementor;
    otMethod:   Result := (TMethod(fImplementedObjectVarAddr^).Code = fImplementations[fSelectedIndex].MethodImplementor.Code) and
                          (TMethod(fImplementedObjectVarAddr^).Data = fImplementations[fSelectedIndex].MethodImplementor.Data);
    otObject:   Result := TObject(fImplementedObjectVarAddr^) = fImplementations[fSelectedIndex].ObjectImplementor;
    otClass:    Result := TClass(fImplementedObjectVarAddr^) = fImplementations[fSelectedIndex].ClassImplementor;
  else
    raise EUIMInvalidValue.CreateFmt('TUIMImplementedObject.CheckRouting: Invalid implemented object type (%d).',[Ord(fImplementedObjectType)])
  end
else Result := True;
end;


{===============================================================================
--------------------------------------------------------------------------------
                             TImplementationManager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TImplementationManager - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TImplementationManager - protected methods
-------------------------------------------------------------------------------}

Function TImplementationManager.GetImplementedObject(Index: Integer): TUIMImplementedObject;
begin
If CheckIndex(Index) then
  Result := fImplementedObjects[Index]
else
  raise EUIMIndexOutOfBounds.CreateFmt('TImplementationManager.GetImplementedObject: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.GetCapacity: Integer;
begin
Result := Length(fImplementedObjects);
end;

//------------------------------------------------------------------------------

procedure TImplementationManager.SetCapacity(Value: Integer);
var
  i:  Integer;
begin
If Value >= 0 then
  begin
    If Value < fImplementedObjectCount then
      begin
        For i := Value to HighIndex do
          FreeAndNil(fImplementedObjects[i]);
        fImplementedObjectCount := Value;
      end;
    SetLength(fImplementedObjects,Value);
  end
else raise EUIMInvalidValue.CreateFmt('TImplementationManager.SetCapacity: Invalid capacity value (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.GetCount: Integer;
begin
Result := fImplementedObjectCount;
end;

//------------------------------------------------------------------------------

class Function TImplementationManager.GrowDelta: Integer;
begin
Result := 16;
end;

//------------------------------------------------------------------------------

procedure TImplementationManager.Initialize;
begin
SetLength(fImplementedObjects,0);
fImplementedObjectCount := 0;
end;

//------------------------------------------------------------------------------

procedure TImplementationManager.Finalize;
begin
Clear;
end;

//------------------------------------------------------------------------------

Function TImplementationManager.Add(ImplementedObjectID: TUIMIdentifier; ObjectType: TUIMObjectType; VarAddr: Pointer): Integer;
begin
If not Find(ImplementedObjectID,Result) then
  begin
    Grow;
    Result := fImplementedObjectCount;
    case ObjectType of
      otFunction: fImplementedObjects[Result] := TUIMImplementedObject.Create(ImplementedObjectID,Pointer(VarAddr^));
      otMethod:   fImplementedObjects[Result] := TUIMImplementedObject.Create(ImplementedObjectID,TMethod(VarAddr^));
      otObject:   fImplementedObjects[Result] := TUIMImplementedObject.Create(ImplementedObjectID,TObject(VarAddr^));
      otClass:    fImplementedObjects[Result] := TUIMImplementedObject.Create(ImplementedObjectID,TClass(VarAddr^));
    else
      raise EUIMInvalidValue.CreateFmt('TImplementationManager.Add: Invalid implemented object type (%d).',[Ord(ObjectType)])
    end;
    Inc(fImplementedObjectCount);
  end
else raise EUIMDuplicateItem.CreateFmt('TImplementationManager.Add: Implemented object with selected id (%d) already exists.',[ImplementedObjectID]);
end;

{-------------------------------------------------------------------------------
    TImplementationManager - public methods
-------------------------------------------------------------------------------}

constructor TImplementationManager.Create;
begin
inherited;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TImplementationManager.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

Function TImplementationManager.LowIndex: Integer;
begin
Result := Low(fImplementedObjects);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.HighIndex: Integer;
begin
Result := Pred(fImplementedObjectCount);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.IndexOf(ImplementedObjectID: TUIMIdentifier): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If fImplementedObjects[i].ImplementedObjectID = ImplementedObjectID then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TImplementationManager.Find(ImplementedObjectID: TUIMIdentifier; out Index: Integer): Boolean;
begin
Index := IndexOf(ImplementedObjectID);
Result := CheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.FindObj(ImplementedObjectID: TUIMIdentifier): TUIMImplementedObject;
var
  Index:  Integer;
begin
If Find(ImplementedObjectID,Index) then
  Result := fImplementedObjects[Index]
else
  raise EUIMInvalidIdentifier.CreateFmt('TImplementationManager.FindObj: Implementated object with selected ID (%d) not found.',[ImplementedObjectID]);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.Add(ImplementedObjectID: TUIMIdentifier; var FunctionVariable: Pointer): Integer;
begin
Result := Add(ImplementedObjectID,otFunction,@FunctionVariable);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TImplementationManager.Add(ImplementedObjectID: TUIMIdentifier; var MethodVariable: TMethod): Integer;
begin
Result := Add(ImplementedObjectID,otMethod,@MethodVariable);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TImplementationManager.Add(ImplementedObjectID: TUIMIdentifier; var ObjectVariable: TObject): Integer;
begin
Result := Add(ImplementedObjectID,otObject,@ObjectVariable);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TImplementationManager.Add(ImplementedObjectID: TUIMIdentifier; var ClassVariable: TClass): Integer;
begin
Result := Add(ImplementedObjectID,otClass,@ClassVariable);
end;

//------------------------------------------------------------------------------

Function TImplementationManager.AddObj(ImplementedObjectID: TUIMIdentifier; var FunctionVariable: Pointer): TUIMImplementedObject;
var
  Index:  Integer;
begin
Index := Add(ImplementedObjectID,FunctionVariable);
Result := fImplementedObjects[Index];
end;
 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TImplementationManager.AddObj(ImplementedObjectID: TUIMIdentifier; var MethodVariable: TMethod): TUIMImplementedObject;
var
  Index:  Integer;
begin
Index := Add(ImplementedObjectID,MethodVariable);
Result := ImplementedObjects[Index];
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TImplementationManager.AddObj(ImplementedObjectID: TUIMIdentifier; var ObjectVariable: TObject): TUIMImplementedObject;
var
  Index:  Integer;
begin
Index := Add(ImplementedObjectID,ObjectVariable);
Result := ImplementedObjects[Index];
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TImplementationManager.AddObj(ImplementedObjectID: TUIMIdentifier; var ClassVariable: TClass): TUIMImplementedObject;
var
  Index:  Integer;
begin
Index := Add(ImplementedObjectID,ClassVariable);
Result := ImplementedObjects[Index];
end;

//------------------------------------------------------------------------------

Function TImplementationManager.Remove(ImplementedObjectID: TUIMIdentifier): Integer;
begin
If Find(ImplementedObjectID,Result) then
  Delete(Result)
else
  Result := -1;
end;

//------------------------------------------------------------------------------

procedure TImplementationManager.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    FreeAndNil(fImplementedObjects[Index]);
    For i := Index to Pred(HighIndex) do
      fImplementedObjects[i] := fImplementedObjects[i + 1];
    Dec(fImplementedObjectCount);
  end
else raise EUIMIndexOutOfBounds.CreateFmt('TImplementationManager.Delete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TImplementationManager.Clear;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  FreeAndNil(fImplementedObjects[i]);
SetLength(fImplementedObjects,0);
fImplementedObjectCount := 0;
end;

end.
