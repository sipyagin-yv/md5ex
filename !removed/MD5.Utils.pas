unit MD5.Utils;

interface

uses
  System.SysUtils,
  System.DateUtils,
  Windows;

const
  DATE_FORMAT = 'dd"/"mm"/"yyyy';
  TIME_FORMAT = 'hh":"nn":"ss';
  DATE_TIME_FORMAT = DATE_FORMAT + ' ' + TIME_FORMAT;

/// <summary>������������� ���� � ��������� �������������</summary>
function ByteToHex(B: Byte): String;

/// <summary>������ ������� FormatNumberHelper</summary>
/// <remarks><see cref="FormatNumberHelper"/></remarks>
function FormatNumber(N: UInt64): String;

/// <summary>Convert number into string, with split by group of 3 chars</summary>
/// <param name="N">N, number to convert to string</param>
/// <returns>true, if convert is succesfull. false otherwise</returns>
function FormatNumberHelper(N: UInt64): String;

/// <summary>���������, ����� �� ������</summary>
/// <param name="S">����������� ������</param>
/// <returns>true, ���� ������ �������� ������ ������� � ������� ���������,
/// false � ���� ������</returns>
function StringIsEmpty(const S: String): Boolean;

/// <summary>
///   ��������� ������� ����� N1 �� N2. ������� ����� ��������
///   �� ������� N1*100/N2. ��� ����, ����� �������� ������������,
///   ����� N1 � N2 ������� �� 2 (SHR 1), ���� ��� ��� �� ������
///   ������ System.MaxInt ($7fffffff).
/// </summary>
/// <remarks>
///   ���� N1 > N2, ������� ������ 100.
/// </remarks>
function Percent(N1, N2: UInt64): Integer;

/// <summary>
///   ������������� ������� ��������� N1 �� N2 (������������ ������� Percent)
///   � ��������� �������������. ����� ����������� ��������� �� 3-� ��������.
/// </summary>
function FormatPercent(N1, N2: UInt64): String;

/// <summary>
///   ������� ������� ���� � ��������� �������.
///   ������ �������� ���������� DATE_FORMAT.
/// </summary>
function CurrentDate: String;

/// <summary>
///   ������� ������� ����� � ��������� �������.
///   ������ �������� ���������� TIME_FORMAT.
/// </summary>
function CurrentTime: String;

/// <summary>
///   ������� ������� ���� � ����� � ��������� �������.
///   ������ �������� ���������� DATE_TIME_FORMAT.
/// </summary>
function CurrentDateTime: String;

/// <summary>
///   ������� �������� ����������� ������� �� ������ '�', ����������, ��� � ����� ����� ����� ������������ �������
/// </summary>
/// <param name="S">
///   ������ � ������ �����
/// </param>
/// <returns>
///   ���������� ������, � ������� ����������� ������� �������� �� ������ '�'
/// </returns>
function ShowTrailingSpaces(const S: String): String;

type
  /// <summary>
  ///   ��������� ������������� ��� �������� ����, �����, �����, ������, ��.
  /// </summary>
  TDayHourMinSec = record
    Day,
    Hour,
    Min,
    Second,
    Ms: Cardinal;
    procedure AssignFromMs(Ms: Cardinal);
  end;
  /// <summary>�����, ���������� ���������, ������ �� X ����������� � ������� ��������� ��������</summary>
  TTimer = class
  private
    StartTime: Cardinal;
    CheckTime: Cardinal;
  public
    constructor Create;
    /// <summary>���������, ������ �� ��������� ���������� �����������</summary>
    /// <param name="Delta">���������� �����������</param>
    ///  <returns>���������� TRUE, ���� � ������� ��������� �������� ������ Delta �����������. FALSE - � ������ ������</returns>
    function CheckInterval(Delta: Cardinal): Boolean;
    /// <summary>���������� ���������� �����������, ��������� � ������� �������� �������</summary>
    function Passed: Cardinal;
  end;
  //
  /// <summary>
  ///   Hold the value into class (for reference by pointer).
  /// </summary>
  TBoxing<T> = class
  private
    FValue: T;
  public
    constructor Create(Value: T);
  end;

  /// <summary>
  ///   ������������ UInt64 �� ���� ���������, Lo � Hi.
  /// </summary>
  function MakeUInt64(Lo, Hi: Cardinal): UInt64; inline;

IMPLEMENTATION

function MakeUInt64(Lo, Hi: Cardinal): UInt64;
begin
  Int64Rec(Result).Lo := Lo;
  Int64Rec(Result).Hi := Hi;
end;

function TTimer.CheckInterval(Delta: Cardinal): Boolean;
var
  Temp: Cardinal;
begin
  Temp := GetTickCount;
  if (Temp - CheckTime) >= Delta then
  begin
    CheckTime := Temp;
    Exit(TRUE);
  end;
  Exit(FALSE);
end;

constructor TTimer.Create;
begin
  inherited;
  StartTime := GetTickCount;
  CheckTime := StartTime;
end;

function TTimer.Passed: Cardinal;
begin
  Exit(GetTickCount - StartTime);
end;

function ByteToHex(B: Byte): String;
const
  Hexdigits: array[0..15] of Char =
  ('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
begin
  Result := Hexdigits[B SHR 4] + Hexdigits[B AND $F];
end;

function FormatNumber(N: UInt64): String;
begin
  Result := FormatNumberHelper(N);
end;

// ������� TRUE, ���� � ������ S ������ �������, ��� ������ ������
function StringIsEmpty(const S: String): Boolean;
var
  Ch: Char;
begin
  for Ch in S do
  begin
    if NOT ((Ch = ' ') OR (Ch = #9)) then Exit(FALSE);
  end;
  Result := TRUE;
end;

function Percent(N1, N2: UInt64): Integer;
begin
  if N1 > N2 then Exit(100);
  // �������� ����� � ����������� ���� Integer (32 bits)
  while (N1 > $7fffffff) OR (N2 > $7fffffff) do
  begin
    N1 := N1 SHR 1;
    N2 := N2 SHR 1;
  end;
  Result := Windows.MulDiv(N1, 100, N2)
end;

function FormatPercent(N1, N2: UInt64): String;
begin
  Result := IntToStr(Percent(N1, N2)).PadLeft(3) + '%';
end;

{ DONE :
������� ������, TTimer, ������� ���������� ����� ������ ��������.
����� � ����� ����� ���� ��������� ����� ������ ���������.
�����, �� ������ �������� �� ������: � ������� ��������� ��������
������ X �����������? }

function CurrentDate: String;
var
  D: TDateTime;
begin
  D := Today;
  DateTimeToString(Result, DATE_FORMAT, D);
end;

function CurrentTime: String;
var
  T: TDateTime;
begin
  T := Time;
  DateTimeToString(Result, TIME_FORMAT, T);
end;

function CurrentDateTime: String;
begin
  DateTimeToString(Result, DATE_TIME_FORMAT, Now);
end;

function ShowTrailingSpaces(const S: String): String;
var
  Index: Integer;
begin
  Result := S;
  for Index := High(Result) downto Low(Result) do
  begin
    if Result[Index]=' ' then
    begin
      Result[Index] := '�';
    end else Break;
  end;
end;

function FormatNumberHelper(N: UInt64): String;
var
  Index, Group: Integer;
  Buffer: array[0..79] of Char;
begin
  Index := High(Buffer)+1;
  Dec(Index);
  Buffer[Index] := #0;
  Group := 3;
  repeat
    Dec(Index);
    Buffer[Index] := Char((N MOD 10) + Ord('0'));
    N := N DIV 10;
    if N = 0 then Break;
    Dec(Group);
    if Group = 0 then
    begin
      Dec(Index);
      Buffer[Index] := '`';
      Group := 3;
    end;
  until FALSE;
  Result := PChar(@Buffer[Index]);
end;

{ TDayHourMinSec }

procedure TDayHourMinSec.AssignFromMs(Ms: Cardinal);
const
  SEC_DIVISOR = 1000;
  MIN_DIVISOR = SEC_DIVISOR*60;
  HRS_DIVISOR = MIN_DIVISOR*60;
  DAY_DIVISOR = HRS_DIVISOR*24;
var
  T: Cardinal;
begin
  Self.Day := Ms DIV DAY_DIVISOR;
  T := Ms MOD DAY_DIVISOR;
  //
  Self.Hour := T DIV HRS_DIVISOR;
  T := T MOD HRS_DIVISOR;
  //
  Self.Min := T DIV MIN_DIVISOR;
  T := T MOD MIN_DIVISOR;
  //
  Self.Second := T DIV SEC_DIVISOR;
  T := T MOD SEC_DIVISOR;
  //
  Self.Ms := T;
end;

{ TBoxing<T> }

constructor TBoxing<T>.Create(Value: T);
begin
  FValue := Value;
end;

end.

