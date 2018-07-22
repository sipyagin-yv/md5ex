unit MD5.Console;

INTERFACE

uses
  System.SysUtils,
  MD5.Utils,
  Windows;

type
  TConsole = class
  private
    CharsCounter: Integer;
    DefaultAttr: Integer;
    OutputHandle: Integer;
    FWidth, FHeight: Integer;
    procedure Write0(const Attr: Integer; P: PChar; Len: Integer); overload; // MAIN!
  public
    // cursor moves/info
    function GetCursorX: Integer;
    function GetCursorY: Integer;
    procedure GetCursorXY(out x, y: Integer);
    procedure SetCursorXY(x, y: Integer);
    // write text
    procedure Write(const S: String); overload;
    procedure Write(const Attr: Integer; const S: String); overload;
    procedure WriteLn; overload;
    // write numbers
    procedure WriteFormatNumber(const Attr: Integer; N: UInt64); overload;
    procedure WriteFormatNumber(N: UInt64); overload;
    procedure WriteFormatNumberSize(const Attr: Integer; N: UInt64);
    // write paths
    procedure WriteFileName(const Attr: Integer; const S: String; ReduceToScreenEdge: Boolean = FALSE);
    // write repeated text
    procedure WriteRepeat(const S: String; Count: Integer); overload;
    procedure WriteRepeat(const Attr: Integer; const S: String; Count: Integer); overload;
    // useful functions
//    procedure WriteValueLn(const Attr: Integer; const S1, S2, S3: String);
    procedure WritePointLn;
    // update engine :)
    procedure UpdateBegin(var Counter: Integer);
    procedure UpdateEnd(var Counter: Integer);
    procedure UpdateClear(var Counter: Integer);
    // init/done
    constructor Create;
    destructor Destroy; override;
    //
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

IMPLEMENTATION

uses
  MD5.FileUtils;

constructor TConsole.Create;
var
  Info: TConsoleScreenBufferInfo;
begin
  inherited;
  OutputHandle := GetStdHandle( STD_OUTPUT_HANDLE );
  GetConsoleScreenBufferInfo(OutputHandle, Info);
  DefaultAttr := Info.wAttributes;
  CharsCounter := -1;
  FWidth := Info.dwSize.X;
  FHeight := Info.dwSize.Y;
end;

destructor TConsole.Destroy;
begin
  OutputHandle := 0;
  inherited;
end;

function TConsole.GetCursorX: Integer;
var
  Dummy: Integer;
begin
  GetCursorXY(Result, Dummy);
end;

function TConsole.GetCursorY: Integer;
var
  Dummy: Integer;
begin
  GetCursorXY(Dummy, Result);
end;

procedure TConsole.SetCursorXY(x, y: Integer);
var
  Info: TConsoleScreenBufferInfo;
  Coord: TCoord;
begin
  if (x = -1) OR (y = -1) then
  begin
    GetConsoleScreenBufferInfo(OutputHandle, Info);
  end;
  //
  if x = -1 then Coord.X := Info.dwCursorPosition.X else Coord.X := x;
  if y = -1 then Coord.Y := Info.dwCursorPosition.Y else Coord.Y := y;
  //
  SetConsoleCursorPosition(OutputHandle, Coord);
end;

procedure TConsole.GetCursorXY(out x, y: Integer);
var
  Info: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(OutputHandle, Info);
  x := Info.dwCursorPosition.X;
  y := Info.dwCursorPosition.Y;
end;

procedure TConsole.Write0(const Attr: Integer; P: PChar; Len: Integer);
var
  t: Cardinal;
begin
  if OutputHandle = 0 then Exit;
  //
  // Установка атрибутов цвета
  if Attr = -1 then SetConsoleTextAttribute(OutputHandle, DefaultAttr)
               else SetConsoleTextAttribute(OutputHandle, Attr);
  // Вывод текста
  WriteConsoleW(OutputHandle, P, Len, t, NIL);
  // Если нужно, подсчет количества выведенных символов
  if CharsCounter >= 0 then Inc(CharsCounter, t);
end;

//==============================================================================
procedure TConsole.WriteRepeat(const S: String; Count: Integer);
begin
  WriteRepeat(-1, S, Count);
end;

procedure TConsole.WriteRepeat(const Attr: Integer; const S: String; Count: Integer);
begin
  if Count > 0 then
  begin
    case S.Length of
      0: Exit;
      1: Write0(Attr, PChar(StringOfChar(S[1], Count)), Count);
      else
        while Count > 0 do
        begin
          Dec(Count);
          Write0(Attr, PChar(S), S.Length);
        end;
    end;
  end;
end;

procedure TConsole.Write(const S: String);
begin
  Write0(-1, PChar(S), S.Length);
end;

procedure TConsole.Write(const Attr: Integer; const S: String);
begin
  Write0(Attr, PChar(S), S.Length);
end;

procedure TConsole.WriteFileName(const Attr: Integer; const S: String; ReduceToScreenEdge: Boolean = FALSE);
var
  ReduceChars: Integer;
begin
  Write(Attr, '"');
  if ReduceToScreenEdge then
  begin
    ReduceChars := Width - GetCursorX - 5;
    Write(Attr, ReduceFileName(S, ReduceChars));
  end else
  begin
    Write(Attr, S);
  end;
  Write(Attr, '"');
end;

procedure TConsole.WriteFormatNumber(N: UInt64);
begin
  WriteFormatNumber(-1, N);
end;

procedure TConsole.WriteFormatNumber(const Attr: Integer; N: UInt64);
var
  S: String;
begin
  S := FormatNumberHelper(N);
  Write0(Attr, PChar(S), S.Length);
end;

procedure TConsole.WriteFormatNumberSize(const Attr: Integer; N: UInt64);
//var
//  Value, KBytes, MBytes, GBytes, PBytes: Double;
//  Suffix: String;
const
  MB_DIVISOR = 1024*1024;
  GB_DIVISOR = 1024*1024*1024;
//var
//  FS: TFormatSettings;
begin
  if (N DIV MB_DIVISOR) >= 1 then
  begin
    Write(' (');
    WriteFormatNumber(Attr, N DIV MB_DIVISOR);
    Write(' MBytes');
    if (N DIV GB_DIVISOR) >= 1 then // if >= 1.xxx Gb
    begin
      Write('; ');
//      FS := TFormatSettings.Create;
//      FS.DecimalSeparator := '.';
//      Write(Attr, Format('%.2f', [N/GB_DIVISOR], FS));
      Write(Attr, Format('%.2f', [N/GB_DIVISOR]));
      Write(' GBytes');
    end;
    Write(')');
  end;
  //
(*
  KBytes := N / 1024;
  MBytes := KBytes / 1024;
  GBytes := MBytes / 1024;
  PBytes := GBytes / 1024;
  //
  if PBytes < 1 then
  begin
    Suffix := 'GBytes';
    Value := GBytes;
  end else if GBytes < 1 then
  begin
    Suffix := 'MBytes';
    Value := MBytes;
  end else if MBytes < 1 then
  begin
    Suffix := 'KBytes';
    Value := KBytes;
  end else Exit; // bytes and pbytes is show as bytes
  //
  Write(' (');
  Write(Attr, Format('%.2f', [Value]));
  Write(' ');
  Write(Suffix);
  Write(')');
*)
end;

procedure TConsole.WriteLn;
const
  CRLF = #13#10;
begin
  Write0(-1, PChar(CRLF), CRLF.Length);
end;

procedure TConsole.WritePointLn;
begin
//  Write('.');
  WriteLn;
end;

//procedure TConsole.WriteValueLn(const Attr: Integer; const S1, S2, S3: String);
//begin
//  Write0(-1, PChar(S1), S1.Length);
//  Write0(Attr, PChar(S2), S2.Length);
//  Write0(-1, PChar(S3), S3.Length);
//  WriteLn;
//end;

procedure TConsole.UpdateBegin(var Counter: Integer);
begin
  WriteRepeat(#8, Counter);
  CharsCounter := 0;
end;

procedure TConsole.UpdateEnd(var Counter: Integer);
var
  Diff: Integer;
begin
  Diff := Counter - CharsCounter;
  Counter := CharsCounter;
  CharsCounter := -1;
  // Действуем в том случае, если вывели
  // меньше символов, чем в предыдущий раз
  if Diff > 0 then
  begin
    // clear trail symbols
    WriteRepeat(' ', Diff);
    WriteRepeat(#8, Diff);
  end;
end;

procedure TConsole.UpdateClear(var Counter: Integer);
begin
  WriteRepeat(#8, Counter); // back to begin
  WriteRepeat(' ', Counter); // clear
  WriteRepeat(#8, Counter); // again back to begin
  Counter := 0;
//  UpdateBegin(Counter);
//  UpdateEnd(Counter);
end;

end.

