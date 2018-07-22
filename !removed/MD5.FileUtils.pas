unit MD5.FileUtils;
// String default is UnicodeString

INTERFACE

{$DEFINE FINDFILES_DEBUG}

uses
  MD5.Utils,
  MD5.Message,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Windows;

const
  ALL_FILES_MASK        =  '*';            // NOT *.* !!!
  EXTENDED_PATH_PREFIX  =  '\\?\';
  SKIP_FOLDER_NAME_1    =  '.';
  SKIP_FOLDER_NAME_2    =  '..';
  // for MatchMask
  MASK_CHAR_ZERO_OF_MANY =  '*';
  MASK_CHAR_ANY          =  '?';
  MASK_END_OF_STRING     =  #0;

var
  UpperCaseTable: array[Char] of Char;

type
  TExtendedPathBuffer = array[0..32768] of Char;

  // Размер файла, обернутый в объект
  // (для того, чтобы хранить размер в TStringList)
  TFileSizeInfo = class
  private
    FSize: UInt64;
  public
    constructor Create(Size: UInt64);
    // properties to read the file information
    property Size: UInt64 read FSize;
  end;

  TFindFileInfo = class // size is 4*4 + 8 = 24 bytes
  private
    FSize: UInt64;
    FAttributes: Cardinal;
    FCreationTime: _FILETIME;
    FLastAccessTime: _FILETIME;
    FLastWriteTime: _FILETIME;
  public
    constructor Create(var WS: WIN32_FIND_DATA);
    // properties to read the file information
    property Size: UInt64 read FSize;
    property Attributes: Cardinal read FAttributes;
    property CreationTime: _FILETIME read FCreationTime;
    property LastAccessTime: _FILETIME read FLastAccessTime;
    property LastWriteTime: _FILETIME read FLastWriteTime;
  end;

const
  SFR_CLOSED        = $ffffffff; // -1
  SFR_READINCORRECT = $fffffffe; // -2
  SFR_NOMEM         = $fffffffd; // -3
  SFR_ENDOFFILE     = $fffffffc; // -4

type
  TSequentialFileReader = class
  private
    FStatus: DWORD;             // Код последней ошибки (0, если нет ошибок)
    FHandle: THANDLE;           // Хэндл файла
    FSize: UInt64;              // Размер файла
    FBuffer: Pointer;           // Буфер для чтения
    FBufferSize: Cardinal;      // Размер буфера для чтения
    // Инф. о процессе чтения
    FLastReaded: Cardinal;      // Прочитано в последнем чтении
    FTotalReaded: UInt64;       // Прочитано с начала чтения
  public
    constructor Create(const FileName: String; BufferSize: Cardinal);
    destructor Destroy; override;
    function StatusMessage: String;
    /// <summary>
    ///   Читаем очередную порцию из файла.
    /// </summary>
    /// <returns>
    ///   Возвращает TRUE, если есть информация для обработки.
    ///   Иначе возвращает FALSE (достигнут конец файла).
    ///   Также, в Status возвращается статус операции. 0 означает - нет ошибки,
    ///   любое другое значение - код ошибки.
    /// </returns>
    /// <remarks>
    ///   После чтения обязательно проверить Status.
    /// </remarks>
    function ReadNextBlock: Boolean;
    /// <summary>
    ///   Возвращает статут последней операции. 0 означает - нет ошибок.
    ///   Любое другое число - код ошибки.
    /// </summary>
    property Status: Cardinal read FStatus;
    /// <summary>
    ///   Возвращает размер файла в байтах.
    /// </summary>
    property Size: UInt64 read FSize;
    /// <summary>
    ///   Возвращает количество байт, прочитанных в последнем чтении.
    /// </summary>
    property LastReaded: Cardinal read FLastReaded;
    /// <summary>
    ///   Возвращает количество байт, прочитанных с начала файла.
    /// </summary>
    property TotalReaded: UInt64 read FTotalReaded;
    /// <summary>
    ///   Возвращает адрес буфера, куда читаются байты из файла.
    /// </summary>
    property Buffer: Pointer read FBuffer;
  end;

/// <summary>
///   Уменьшить длину пути
/// </summary>
function ReduceFileName(const FileName: String; MaxLength: Integer): String;

/// <summary>
///   Вернуть имя тома для пути BasePath.
/// </summary>
function GetVolumeName(const BasePath: String): String;

/// <summary>
///   Функция возвращает размер файла (по имени файла)
/// </summary>
/// <param name="FileName">
///   Имя файла, для которого нужно узнать размер.
///   В функции к имени файла прибавляется Extended Prefix, '\\?\'.
/// </param>
/// <param name="FileSize">
///   Ссылка на переменную, принимающую размер файла.
/// </param>
/// <returns>
///   TRUE, если размер файла возвращен в переменную FileSize. FALSE, если произошла ошибка (в FileSize при этом возвращается 0).
/// </returns>
function GetFileSize(const FileName: String; out FileSize: UInt64): Boolean; overload;

/// <summary>
///   Функция возвращает размер файла (по дескриптору файла)
/// </summary>
/// <param name="H">
///   Дескриптор файла, для которого нужно узнать размер.
/// </param>
/// <param name="FileSize">
///   Ссылка на переменную, принимающую размер файла.
/// </param>
/// <returns>
///   TRUE, если размер файла возвращен в переменную FileSize. FALSE, если произошла ошибка (в FileSize при этом возвращается 0).
/// </returns>
function GetFileSize(H: THandle; out FileSize: UInt64): Boolean; overload;


/// <summary>
///   Функция ищет файлы и, если необходимо, добавляет информацию о них.
/// </summary>
///
///  <param name="StartPath">С этого каталога начинается поиск</param>
///
///  <param name="Mask">Маска поиска. Маская для всех файлов такая: "*".
///  Проверка маски осуществляется функцией CompareMask (не системой!).
///  В процессе изучения FindFirstFileW оказалось, что эта функция
///  не различает маски "*.md5" и "*.md5file", поэтому пришлось написать
///  свою функцию.</param>
///
///  <param name="Recursive">TRUE, если необходим рекурсивный поиск.
///  FALSE - если нужно искать только в каталоге StartPath.</param>
///
///  <param name="AddInfo">TRUE, если необходимо добавить информацию о файле
///  (размер, атрибуты, время создания; модификации; доступа).</param>
///
///  <param name="RemoveStartPath">TRUE, если из имени найденного файла
///  необходимо удалить стартовый каталог.</param>
///
///  <param name="StatProc">Процедура, которая будет показывать статистическую
///  информацию. Для подробностей - смотрите описание класса
///  <see cref="TScreenMessage"/>. По умолчанию, значение параметра равно nil.
///  </param>
///
///  <param name="StatUpdateInterval">Время, через которое нужно вызывать
///  функцию StatProc. По умолчанию, значение параметра равно 1500.</param>
///
///  <remarks>Рекомендуется указывать интервал обновления, StatUpdateInterval,
///  в пределах 1000-1500 миллисекунд.</remarks>
///
///  <returns>
///  Функция возвращает список имён файлов, в объекте
///  <see cref="TStringList"/>.
///  </returns>
function FindFiles(const StartPath: String;
                   const Mask: String;
                   Recursive: Boolean;
                   AddInfo: Boolean = FALSE;
                   RemoveStartPath: Boolean = FALSE;
                   StatProc: TScreenMessageProc = nil;
                   StatUpdateInterval: Cardinal = 1500): TStringList;

/// <summary>
///   Форматирует сообщение об ошибке по номеру ошибки.
/// </summary>
function FormatMessage(const MessageId: Integer): String;

// Функции для преобразования пути и имени файла
function GetLocalFileName(const WorkPath: String; const FileName: String): String;
function GetFullFileName(const WorkPath: String; const FileName: String): String;
function GetExtendedFileName(const FileName: String): String;

// Функции для работы с масками
function CompareMask(Name, Mask: PChar): Boolean; overload;
function CompareMask(Name, Mask: String): Boolean; overload;
function CompareChar(const C1, C2: Char): Boolean;

procedure PathBeautifuler(var S: String);

/// <summary>
///   Reduce file name to fit to MaxLength chars.
/// </summary>
//function ReduceFileName(const FileName: String; MaxLength: Integer): String;

IMPLEMENTATION

procedure PathBeautifuler(var S: String);
begin
  if (S.Length >= 2) then
  begin
    if (S[2] = ':') AND (S[1] >= 'a') AND (S[1] <= 'z') then
    begin
      S[1] := UpCase(S[1]);
    end;
  end;
end;

function FormatMessage(const MessageId: Integer): String;
var
  R: DWORD;
  Buffer: array[0..1000] of Char;
begin
  // format message for information
  FillChar(Buffer, sizeof(Buffer), 0);
  R := FormatMessageW(
          FORMAT_MESSAGE_FROM_SYSTEM OR
          FORMAT_MESSAGE_MAX_WIDTH_MASK,              // dwFlags
          nil,                                        // lpSource
          MessageId,                                  // dwMessageId
          0,                                          // dwLanguageId
          Buffer,                                     // lpBuffer
          Length(Buffer),                             // nSize
          nil);                                       // Arguments
  if R = 0 then Result := 'N/A' // result is N/A, if FormatMessageW fails.
           else Result := Buffer;
  // Форматирование
  Result := Result.Trim;
  if Result.EndsWith('.') then Result := Result.Substring(0, Result.Length-1);
  Result := Format('#%x, %s', [MessageId, Result]);
end;

// Сравнение по маске
// Специальные символы маски:
//    ? заменяет собой один символ
//    * заменяет собой 0 или более символов
// Планируется:
//    [a-b] любой символ из диапазона a-b, например [a-f] - символы a,b,c,d,e,f
//    [~a-b] любой символ кроме символа из диапазона a-b, например [~a] - любой символ, кроме a
//    [abcd] любой символ из списка, например [!@#] - символы !, @, #
//    [~abcd] любой символ, кроме символов из списка, например [~!] - любой символ, кроме !
//    () - группировка, | - или, & - и, например ([a-b]|[x-z])
//    
// Особенности:
//    CompareMask('',''));              = true
//    CompareMask('', '*'));            = true
//    CompareMask('some', ''));         = false
//    CompareMask('filename', '*'));    = true
//    CompareMask('abc', 'def'));       = false
function CompareMask(Name, Mask: PChar): Boolean;
// передача параметров через указатели более удобна.
// в противном случае, требуется создание локальных переменных - индексов,
// а параметры Name, Mask будут неизменяемые. И потребуется ещё одна
// вложенность процедуры - сравнивателя, которая будет работать
// непосредственно с индексами.
begin
  repeat
    // Проверка на конец сравнения
    if (Name^ = MASK_END_OF_STRING) AND
       (Mask^ = MASK_END_OF_STRING) then Exit(TRUE);
    // Анализируем символ маски
         if Mask^ = MASK_CHAR_ANY then
    else if Mask^ = MASK_CHAR_ZERO_OF_MANY then
    begin
      // Пропускаем 0 или более символов в Name, и сравниваем с маской
      Inc(Mask);
      // Оптимизация (если после '*' идёт символ #0 - дальше можно не сравнивать)
      if Mask^ = MASK_END_OF_STRING then Exit(TRUE);
      // Указатель маски остается на месте, а мы
      // пропускаем в Name 0 или более символов
      repeat
        if CompareMask(Name, Mask) then Exit(TRUE);
        Inc(Name);
        if (Name^ = MASK_END_OF_STRING) then Exit(FALSE);
      until FALSE;
      // Отсюда возврата нет!
    end else
    begin
      // Сравниваем символы маски и строки
      if NOT CompareChar(Name^, Mask^) then Exit(FALSE);
    end;
    // Переходим к следующим символам маски и строки
    Inc(Name);
    Inc(Mask);
  until FALSE;
end;

function CompareMask(Name, Mask: String): Boolean;
begin
  Exit(CompareMask(PChar(Name), PChar(Mask)));
end;

function FindFiles(const StartPath: String;
                   const Mask: String;
                   Recursive: Boolean;
                   AddInfo: Boolean = FALSE;
                   RemoveStartPath: Boolean = FALSE;
                   StatProc: TScreenMessageProc = nil;
                   StatUpdateInterval: Cardinal = 1500): TStringList;
var
  CurrentPath: String;
  FileInfo: TFindFileInfo;
  //
  S: TScreenMessage;

procedure FindHelper;
var
  FF: THandle;
  WS: WIN32_FIND_DATA;
begin
{ DONE -cvery important :
Объединить part1 и part2, т.к. сигнатуры поиска ( путь + '*' ) одинаковые.
А в текущий момент поиск происходит 2 раза: первый проход - файлы, второй проход - каталоги
===ИСПРАВЛЕНО}
  FF := FindFirstFileW( PChar(EXTENDED_PATH_PREFIX + CurrentPath + ALL_FILES_MASK), WS);
  if FF <> INVALID_HANDLE_VALUE then
  begin
    repeat
      // Обрабатываем ФАЙЛ
      if (WS.dwFileAttributes AND FILE_ATTRIBUTE_DIRECTORY) = 0 then
      begin
        // Сравниваем с маской (используем нашу процедуру сравнения, т.к.
        // системная для маски *.md5 находит файлы checksum.md5, checksum.md5abc)
        if Mask.Length > 0 then
        begin
          if NOT CompareMask(WS.cFileName, Mask) then Continue;
        end;
        // Нашли файл
        S[0] := S[0] + 1;
//        Inc(StatInfo.FilesFound);
        // Добавляем информацию о файле
        if AddInfo then
        begin
          FileInfo := TFindFileInfo.Create(WS);
        end else
        begin
          FileInfo := nil;
        end;
        if RemoveStartPath then
        begin
          Result.AddObject(GetLocalFileName(StartPath, CurrentPath + WS.cFileName), FileInfo);
        end else
        begin
          Result.AddObject(CurrentPath + WS.cFileName, FileInfo);
        end;

      end else if (WS.dwFileAttributes AND FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
      begin
        // Only if recursive!!!
        if Recursive then
        begin
          // Папки с именами '.' и '..' не нужны!
          if (StrComp(WS.cFileName, SKIP_FOLDER_NAME_1) = 0) OR
             (StrComp(WS.cFileName, SKIP_FOLDER_NAME_2) = 0) then Continue;
          // Нашли папку
          S[1] := S[1] + 1;
//          Inc(StatInfo.FoldersFound);
          // Сформировать новый текущий путь
          CurrentPath := CurrentPath + WS.cFileName + PathDelim;
          // recursive scan
          FindHelper;
          // Восстановить старый
          SetLength(CurrentPath, CurrentPath.Length -
                                 Integer(StrLen(WS.cFileName)) -
                                 Length(PathDelim));
        end;
      end;
      S.Show(smNORMAL);
    until NOT FindNextFile( FF, WS );
    FindClose(FF);
  end;
end;

begin
  // Инициализация переменных
  //StatTick := 0;
  //T := TTimer.Create;
  S := TScreenMessage.Create(StatProc, StatUpdateInterval);
  Result := TStringList.Create;
  Result.OwnsObjects := TRUE;
//  FillChar(StatInfo, sizeof(StatInfo), 0);
  // Готовим стартовый путь
  CurrentPath := IncludeTrailingPathDelimiter(StartPath);
  // Поехали!
  S.Show(smNORMAL);
//  StatHelper(FALSE);
  FindHelper;
  S.Show(smDONE);
//  StatHelper(TRUE);
  // Заключительная обработка
  //Result.Sort;
//  T.Free;
  S.Free;
end;

function GetFullFileName(const WorkPath: String; const FileName: String): String;
// Функция возвращает полный путь файла FileName
// (спереди добавляется WorkPath, если он не равен пустой строке,
// в ином случае, текущая рабочая папка)
begin
  Result := IncludeTrailingPathDelimiter( WorkPath ) + FileName;
end;

// Функция "откусывает" от полного пути к файлу текущий путь
// В системе существует аналог моей функции, но более навороченный:
// s:=ExtractRelativePath('Y:\Projects\','Y:\Projects\Boulder MY\files.inc');
function GetLocalFileName(const WorkPath: String; const FileName: String): String;
var
  i: Integer;
begin
  i := 1;
  while (i<=WorkPath.Length) AND
        (i<=FileName.Length) AND
        CompareChar(WorkPath[i], FileName[i]) do Inc(i);
  //
  Exit( FileName.Substring(i-1) ); // index zero-based
end;

function CompareChar(const C1, C2: Char): Boolean; inline;
begin
  Exit(UpperCaseTable[C1] = UpperCaseTable[C2]);
end;

procedure MakeUpperCaseTable;
var
  Ch: Char;
begin
  // Генерация таблицы преобразования в верхний регистр
  for Ch := Low(Char) to High(Char) do UpperCaseTable[Ch] := Ch;
  CharUpperBuffW(UpperCaseTable, Length(UpperCaseTable));
end;

function GetFileSize(const FileName: String; out FileSize: UInt64): Boolean;
var
  FS: WIN32_FILE_ATTRIBUTE_DATA;
begin
  Result := GetFileAttributesEx(PChar( EXTENDED_PATH_PREFIX + FileName ), GetFileExInfoStandard, @FS);
  if Result then
  begin
    FileSize := MakeUInt64(FS.nFileSizeLow, FS.nFileSizeHigh);
  end else
  begin
    FileSize := MakeUInt64(0, 0);
  end;
end;

function GetFileSize(H: THandle; out FileSize: UInt64): Boolean;
var
  FileSizeLow, FileSizeHigh: Cardinal;
begin
  FileSizeLow := Windows.GetFileSize(H, @FileSizeHigh);
  if (FileSizeLow = $ffffffff) AND (GetLastError <> 0) then
  begin
    FileSize := MakeUInt64(0, 0);
    Result := FALSE;
  end else
  begin
    FileSize := MakeUInt64(FileSizeLow, FileSizeHigh);
    Result := TRUE;
  end;
end;

function GetVolumeName(const BasePath: String): String;
var
  // Интересно, что если записать размерность 1..MAX_PATH,
  // то команда Result := Buffer1 перестанет рассматривать
  // буфер Buffer1 как ASCII-Z строку.
  Buffer1, Buffer2: array[0..MAX_PATH] of Char;
  Dummy1, Dummy2: DWORD;
  R: Boolean;
begin
  R := GetVolumeInformation(
         PChar(IncludeTrailingPathDelimiter(ExtractFileDrive(BasePath))),
         @Buffer1, Length(Buffer1),
         NIL,
         Dummy1,
         Dummy2,
         @Buffer2, Length(Buffer2));
  //
  if R then Result := Buffer1
       else Result := 'N/A';
end;

function GetExtendedFileName(const FileName: String): String;
begin
  if FileName.StartsWith(EXTENDED_PATH_PREFIX) then
  begin
    Result := FileName;
  end else
  begin
    Result := EXTENDED_PATH_PREFIX + FileName;
  end;
end;

{ TFindFilesFileInfo }

constructor TFindFileInfo.Create(var WS: WIN32_FIND_DATA);
begin
  // Размер файла
  FSize := MakeUInt64(WS.nFileSizeLow, WS.nFileSizeHigh);

(*
  // !!! НЕВЕРНО КОМПИЛИРУЕТСЯ !!!
  FSize := $ffffffffffffffff;         // работает правильно
  TFileSize(FSize).Lo := 1;           // FSize не изменяется!
  TFileSize(FSize).Hi := 1;           // FSize не изменяется!
*)

  // Атрибуты
  FAttributes := WS.dwFileAttributes;
  FCreationTime := WS.ftCreationTime;
  FLastAccessTime := WS.ftLastAccessTime;
  FLastWriteTime := WS.ftLastWriteTime;
end;

{ TSequentialFileReader }

constructor TSequentialFileReader.Create(const FileName: String; BufferSize: Cardinal);
begin
  inherited Create;
  //
  FBuffer := nil;
  FLastReaded := 0;
  FTotalReaded := 0;
  FStatus := 0;
  FBufferSize := 0;
  //
  FHandle := CreateFile(
                PChar( GetExtendedFileName(FileName) ), // lpFileName
                GENERIC_READ,                           // dwDesiredAccess
                FILE_SHARE_READ,                        // dwShareMode
                nil,                                    // lpSecurityAttributes
                OPEN_EXISTING,                          // dwCreationDisposition
                FILE_ATTRIBUTE_NORMAL,                  // dwFlagsAndAttribute
                0);                                     // hTemplateFile
  // Файл не открылся - ошибка
  if FHandle = INVALID_HANDLE_VALUE then
  begin
    // store error code
    FStatus := GetLastError;
    FHandle := INVALID_HANDLE_VALUE;
  end else
  begin
    // Файл открылся, задаем константы для работы
    if NOT GetFileSize(FHandle, FSize) then
    begin
      // Получить размер файла не удалось - ошибка
      FStatus := GetLastError;
      CloseHandle(FHandle);
      FHandle := INVALID_HANDLE_VALUE;
    end else
    begin
      // all ok, file opened, and we get's it size
      FBufferSize := BufferSize;
      FStatus := 0;
      // Пытаемся выделить буфер для файла
      FBuffer := GetMemory(FBufferSize);
      if FBuffer = nil then FStatus := SFR_NOMEM;
    end;
  end;
end;

destructor TSequentialFileReader.Destroy;
begin
  if FBuffer <> nil then
  begin
    FreeMemory(FBuffer);
    FBuffer := nil;
  end;
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
  end;
  FStatus := SFR_CLOSED;
  inherited;
end;

function TSequentialFileReader.ReadNextBlock: Boolean;
var
  R, Readed: DWORD;
begin
  // Проверка на достижение конца файла
  if FSize - FTotalReaded = 0 then Exit(FALSE);
  // Вычисляем размер очередной порции для чтения
  if FSize - FTotalReaded > FBufferSize then R := FBufferSize
                                        else R := FSize - FTotalReaded;
  //
{$IFDEF SPECIAL_FAST_MODE}
  {$MESSAGE 'SPECIAL MODE: on (read from zero-file)'}
  Readed := R;
  Result := TRUE;
  FillChar(FBuffer^, R, 0);
{$ELSE}
  {$MESSAGE 'SPECIAL MODE: off'}
  // Читаем файл
  Result := Windows.ReadFile(FHandle,     // hFile
                             FBuffer^,    // lpBuffer
                             R,           // nNumberOfBytesToRead
                             Readed,      // lpNumberOfBytesRead
                             nil);        // lpOverlapped
{$ENDIF}
  // Установка ошибки, если ошибка при чтении
  if NOT Result then
  begin
    FStatus := GetLastError;
    Exit(TRUE);
  end;
  // Установка ошибки, если прочитано не столько, сколько просили
  if Readed <> R then
  begin
    FStatus := SFR_READINCORRECT;
    Exit(TRUE);
  end;
  // Иначе, нет ошибки
  FLastReaded := R;
  Inc(FTotalReaded, R);
  Result := TRUE;
end;

function TSequentialFileReader.StatusMessage: String;
begin
  case FStatus of
    SFR_CLOSED:        Exit('attempt to use destroyed object');  // 'the object is already destroyed';
    SFR_READINCORRECT: Exit('the number of bytes read does not equal the number requested'); // read bytes != request bytes
    SFR_NOMEM:         Exit('not enough memory for allocate the read buffer');
    0:                 Exit('');
    else               Exit(FormatMessage(FStatus));
  end;
end;

//==============================================================================

{ TFileSize }

constructor TFileSizeInfo.Create(Size: UInt64);
begin
  FSize := Size;
end;

function ReduceFileName(const FileName: String; MaxLength: Integer): String;
// Возможны следующие пути:
// "\\сервер\share\путь\файл" - сокращения начинать с "путь\файл"
// "C:\путь\имя" - сокращения начинать с "путь\файл"
// если путь начинается с "\\?\", эту часть ("\\?\") можно убрать
var
  IndexStart, IndexEnd, IndexRemove: Integer;
const
  SUBST_CHARS = '...';

function BeginsWithDrive(const S: String): Boolean;
begin
  Result := (S.Length>=3) AND
            (CharInSet(S[1], ['A'..'Z', 'a'..'z'])) AND
            (S[2]=':') AND
            (S[3]='\');
end;

begin
  Result := FileName;
  if MaxLength < 0 then Exit;
  // Убрать ненужные части
  if FileName.StartsWith('\\?\') then
  begin
    Result := Result.Substring(4);
  end;
  //
  if Result.Length > MaxLength then
  begin
    if MaxLength <= SUBST_CHARS.Length then
    begin
      Result := SUBST_CHARS.Substring(0, MaxLength);
    end else
    begin
      IndexStart := 1;
      IndexEnd := Result.Length;
      // Проверка: FileName это путь с буквой диска
      // (буква диска) ":" "\"
      if BeginsWithDrive(Result) then
      begin
        IndexStart := 4;
      end;
      //
      IndexRemove := IndexStart + (Result.Length - MaxLength + SUBST_CHARS.Length);
      if IndexRemove >= IndexEnd then
      begin
        // Пробуем сместить IndexStart на начало
        IndexStart := 1;
        IndexRemove := IndexStart + (Result.Length - MaxLength + SUBST_CHARS.Length);
      end;
      // Remove chars IndexStart..IndexRemove
      Result := Result.Substring(0, IndexStart-1) + SUBST_CHARS +
                Result.Substring(IndexRemove-1, IndexEnd-IndexRemove+1);
    end;
  end;
end;

initialization
  MakeUpperCaseTable;
finalization

end.

