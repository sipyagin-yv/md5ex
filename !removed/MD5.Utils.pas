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

/// <summary>Преобразовать байт в строковое представление</summary>
function ByteToHex(B: Byte): String;

/// <summary>Аналог функции FormatNumberHelper</summary>
/// <remarks><see cref="FormatNumberHelper"/></remarks>
function FormatNumber(N: UInt64): String;

/// <summary>Convert number into string, with split by group of 3 chars</summary>
/// <param name="N">N, number to convert to string</param>
/// <returns>true, if convert is succesfull. false otherwise</returns>
function FormatNumberHelper(N: UInt64): String;

/// <summary>Проверить, пуста ли строка</summary>
/// <param name="S">Проверяемая строка</param>
/// <returns>true, если строка содержит только пробелы и символы табуляции,
/// false в ином случае</returns>
function StringIsEmpty(const S: String): Boolean;

/// <summary>
///   Вычисляем процент числа N1 от N2. Процент будет вычислен
///   по формуле N1*100/N2. При этом, чтобы избежать переполнения,
///   числа N1 и N2 делятся на 2 (SHR 1), пока оба они не станут
///   меньше System.MaxInt ($7fffffff).
/// </summary>
/// <remarks>
///   Если N1 > N2, функция вернет 100.
/// </remarks>
function Percent(N1, N2: UInt64): Integer;

/// <summary>
///   Преобразовать процент параметра N1 от N2 (используется функция Percent)
///   в строковое представление. Слева дополняется пробелами до 3-х символов.
/// </summary>
function FormatPercent(N1, N2: UInt64): String;

/// <summary>
///   Вернуть текущую дату в строковом формате.
///   Формат задается константой DATE_FORMAT.
/// </summary>
function CurrentDate: String;

/// <summary>
///   Вернуть текущее время в строковом формате.
///   Формат задается константой TIME_FORMAT.
/// </summary>
function CurrentTime: String;

/// <summary>
///   Вернуть текущую дату и время в строковом формате.
///   Формат задается константой DATE_TIME_FORMAT.
/// </summary>
function CurrentDateTime: String;

/// <summary>
///   Функция заменяет завершающие пробелы на символ '•', означающий, что в конце имени файла присутствуют пробелы
/// </summary>
/// <param name="S">
///   Строка с именем файла
/// </param>
/// <returns>
///   Возвращает строку, у которой завершающие пробелы заменены на символ '•'
/// </returns>
function ShowTrailingSpaces(const S: String): String;

type
  /// <summary>
  ///   Структура предназначена для хранения дней, часов, минут, секунд, мс.
  /// </summary>
  TDayHourMinSec = record
    Day,
    Hour,
    Min,
    Second,
    Ms: Cardinal;
    procedure AssignFromMs(Ms: Cardinal);
  end;
  /// <summary>Класс, помогающий проверить, прошло ли X миллисекунд с момента последней проверки</summary>
  TTimer = class
  private
    StartTime: Cardinal;
    CheckTime: Cardinal;
  public
    constructor Create;
    /// <summary>Проверить, прошло ли указанное количество миллисекунд</summary>
    /// <param name="Delta">Количество миллисекунд</param>
    ///  <returns>Возвращает TRUE, если с момента последней проверки прошло Delta миллисекунд. FALSE - в другом случае</returns>
    function CheckInterval(Delta: Cardinal): Boolean;
    /// <summary>Возвращает количество миллисекунд, прошедших с момента создания объекта</summary>
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
  ///   Сформировать UInt64 из двух половинок, Lo и Hi.
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

// Вернуть TRUE, если в строке S только пробелы, или строка пустая
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
  // Приводим числа к разрядности типа Integer (32 bits)
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
Создать объект, TTimer, который запоминает время своего создания.
Чтобы в конце можно было вычислить время работы программы.
Также, он должен отвечать на вопрос: с момента последней проверки
прошло X миллисекунд? }

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
      Result[Index] := '•';
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

