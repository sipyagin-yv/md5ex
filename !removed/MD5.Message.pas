unit MD5.Message;

interface

uses
  MD5.Globals,
  MD5.Utils;

type
  { TScreenMessage }
  TScreenMessageShowMode = (smNORMAL, smFORCE, smDONE);
  TScreenMessageParameters = array[0..10] of Cardinal; // Параметры статистики
  /// <summary>
  ///   Ссылка на процедуру, которая умеет
  ///  показывать статистическую информацию
  /// </summary>
  TScreenMessageProc = reference to procedure(var P: TScreenMessageParameters);
  TScreenMessage = class
  private
    LineSize: Integer;
    Interval: Cardinal; // update interval in ms
    Proc: TScreenMessageProc;
    Timer: TTimer;
    FParams: TScreenMessageParameters;
  public
    constructor Create(Proc: TScreenMessageProc; Interval: Cardinal); overload;
    destructor Destroy; override;
    procedure Show(Mode: TScreenMessageShowMode); overload;
    procedure Show(Mode: TScreenMessageShowMode; P: array of Cardinal); overload;
    procedure Clear;
    function Passed: Cardinal;
    //
    procedure SetParams(Index: Integer; Value: Cardinal);
    function GetParams(Index: Integer): Cardinal;
    property Params[Index: Integer]: Cardinal read GetParams write SetParams; default;
  end;

implementation

{=== TScreenMessages ===}
constructor TScreenMessage.Create(Proc: TScreenMessageProc; Interval: Cardinal);
var
  i: Integer;
begin
  inherited Create;
  // Init vars
  Self.Interval := Interval;
  Self.Proc := Proc;
  Self.Timer := TTimer.Create;
  LineSize := 0;
  for i := Low(FParams) to High(FParams) do FParams[i] := 0;
end;

destructor TScreenMessage.Destroy;
begin
  Timer.Free;
  inherited;
end;

function TScreenMessage.GetParams(Index: Integer): Cardinal;
begin
  if (Index >= Low(FParams)) AND (Index <= High(FParams)) then Result := FParams[Index]
                                                          else Result := 0;
end;

function TScreenMessage.Passed: Cardinal;
begin
  Result := Timer.Passed;
end;

procedure TScreenMessage.Clear;
begin
  Console.UpdateClear(LineSize);
end;

procedure TScreenMessage.SetParams(Index: Integer; Value: Cardinal);
begin
  if (Index >= Low(FParams)) AND (Index <= High(FParams)) then FParams[Index] := Value;
end;

procedure TScreenMessage.Show(Mode: TScreenMessageShowMode; P: array of Cardinal);
var
  i: Integer;
begin
  for i := Low(P) to High(P) do Params[i] := P[i];
  Show(Mode);
end;

procedure TScreenMessage.Show(Mode: TScreenMessageShowMode);
begin
  case Mode of
    smDONE: Clear;
    smFORCE:
    begin
      Console.UpdateBegin(LineSize);
      if Assigned(Proc) then Proc(FParams);
      Console.UpdateEnd(LineSize);
    end;
    smNORMAL:
    if Timer.CheckInterval(Interval) then
    begin
      Console.UpdateBegin(LineSize);
      if Assigned(Proc) then Proc(FParams);
      Console.UpdateEnd(LineSize);
    end;
    else Clear;
  end;
end;

end.
