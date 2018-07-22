unit MD5.Parameters;

INTERFACE

uses
  System.SysUtils,
  System.Classes,
  //
  shared.FileUtils,
  shared.Console,
  shared.Globals;

type
  // Класс опции
  TClazz = (CLS_NONE,          // Команда не указана
            CLS_COMMAND,       // Класс ключевого слова: команда
            CLS_OPTION,        // Класс ключевого слова: опция
            CLS_CRC);          // Класс ключевого слова: код конрольной суммы
//=== COMMAND ===
  TCommand = (CMD_EMPTY,       // команда не указана
              CMD_CREATE,      // создать КС
              CMD_VERIFY,      // проверить КС
              CMD_CHECK,       // протестировать каталог (на случаи перемещения файла)
              CMD_UPDATE,      // обновить КС (вычислить КС у новых файлов)
              CMD_SPLIT,       // разделить файлы с КС (уровень)
              CMD_JOIN,        // сцепить файлы с КС (уровень)
              CMD_HELP,        // краткая помощь
              CMD_LONGHELP,    // расширенная помощь
              CMD_RESUME       // Продолжить сессию
              );
//=== OPTIONS ===
  TOption = (OPT_RECURSIVE,    // с рекурсией
             OPT_NORECURSION,  // без рекурсии
             OPT_FILESPATH,    // каталог контрольных сумм
             OPT_CHECKSUMPATH, // каталог файлов для проверки
             OPT_LOGPATH,      // каталог для log файлов
             OPT_CHECKFILE);   // имя файла, куда сохранятся вычисленные контрольные суммы
//=== CRC ===
  TCrc = (M_CRC32, M_ADLER32,
          M_TIGER192,
          M_MD2, M_MD4, M_MD5,
          M_SHA1, M_SHA224, M_SHA256, M_SHA384, M_SHA512,
          M_RIPEMD128, M_RIPEMD160, M_RIPEMD256, M_RIPEMD320);
  TCrcSet = set of TCrc;
  //
  TParamType = (ptNone, ptInt, ptPath, ptFile);
  // Элемент опции/команды/код контрольной суммы
  TOptionsItem = record
    Name: String;
    Value: Integer;
    Clazz: TClazz;
    ParamType: TParamType;
    Params: String;
    Descr: String;
    LongDescr: String;
  end;
const
  Clazzs: array[TClazz] of String = (
    '',                // CLS_NONE
    'Commands',        // CLS_COMMAND
    'Options',         // CLS_OPTION
    'Checksum IDs');   // CLS_CRC

  Options: array[1..30] of TOptionsItem =
  ( (Name:'create';      Value:Integer(CMD_CREATE);      Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'create checksum'),  // 1
    (Name:'verify';      Value:Integer(CMD_VERIFY);      Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'verify checksum'),  // 2
    (Name:'update';      Value:Integer(CMD_UPDATE);      Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'create checksum for new files'), // 3
    (Name:'split';       Value:Integer(CMD_SPLIT);       Clazz:CLS_COMMAND; ParamType:ptInt;  Params:'[level]'; Descr:'split checksums files'; LongDescr:'split checksums files to checksum files into upper catalogs (default depth level=1)'), // 4
    (Name:'join';        Value:Integer(CMD_JOIN);        Clazz:CLS_COMMAND; ParamType:ptInt;  Params:'[level]'; Descr:'join checksums files'; LongDescr:'join checksums files to checksum file in the current catalog (default depth level=1)'), // 5
    (Name:'check';       Value:Integer(CMD_CHECK);       Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'check checksum files for file movements'), // 6
    (Name:'help';        Value:Integer(CMD_HELP);        Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'short help'; LongDescr:'short help (only commands and options)'),
    (Name:'longhelp';    Value:Integer(CMD_LONGHELP);    Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'long help'; LongDescr:'long help (commands, options and checksum id''s and examples)'),
    (Name:'resume';      Value:Integer(CMD_RESUME);      Clazz:CLS_COMMAND; ParamType:ptNone;                   Descr:'resume from resume file'; LongDescr:'resume from resume file (if exist, in checksum folder and named as "resume.state")'),
    //
    (Name:'recursive';   Value:Integer(OPT_RECURSIVE);   Clazz:CLS_OPTION;  ParamType:ptNone;                   Descr:'command verify will be recursive checksum check'),  // 7
    (Name:'norecursive'; Value:Integer(OPT_NORECURSION); Clazz:CLS_OPTION;  ParamType:ptNone;                   Descr:'command create will be no recursive checksum create'),  // 8
    (Name:'files';       Value:Integer(OPT_FILESPATH);   Clazz:CLS_OPTION;  ParamType:ptPath; Params:'folder';  Descr:'folder with files'),  // 9
    (Name:'checksum';    Value:Integer(OPT_CHECKSUMPATH);Clazz:CLS_OPTION;  ParamType:ptPath; Params:'folder';  Descr:'folder with checksum files'),  // 10
    (Name:'log';         Value:Integer(OPT_LOGPATH);     Clazz:CLS_OPTION;  ParamType:ptPath; Params:'folder';  Descr:'folder for log files (default: folder with executable file)'),  // 11
    (Name:'checkfile';   Value:Integer(OPT_CHECKFILE);   Clazz:CLS_OPTION;  ParamType:ptFile; Params:'[name]';  Descr:'specify checksums file name'; LongDescr:'specify file name to write calculated checksums (default file name is "checksums.md5"). This value is used by command "create". If use special file name value %FOLDER, then checksum file will be named as the name of the current directory'),
    //
    (Name:'crc32';       Value:Integer(M_CRC32);         Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'crc32, fastest method, 32 bits'),     // 12
    (Name:'adler32';     Value:Integer(M_ADLER32);       Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'adler32, like crc32, 32 bits'),     // 13
    (Name:'tiger192';    Value:Integer(M_TIGER192);      Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'tiger192, very slow method, 192 bits'),     // 14
    (Name:'md2';         Value:Integer(M_MD2);           Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'md2 method, 128 bits'),     // 15
    (Name:'md4';         Value:Integer(M_MD4);           Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'md4 method, 128 bits'),     // 16
    (Name:'md5';         Value:Integer(M_MD5);           Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'md5 method, 128 bits -- default method'),     // 17
    (Name:'sha1';        Value:Integer(M_SHA1);          Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'sha1 method, 160 bits'),     // 18
    (Name:'sha224';      Value:Integer(M_SHA224);        Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'sha224 method, 224 bits'),     // 19
    (Name:'sha256';      Value:Integer(M_SHA256);        Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'sha256 method, 256 bits'),     // 20
    (Name:'sha384';      Value:Integer(M_SHA384);        Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'sha384 method, 384 bits'),     // 21
    (Name:'sha512';      Value:Integer(M_SHA512);        Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'sha512 method, 512 bits'),     // 22
    (Name:'ripemd128';   Value:Integer(M_RIPEMD128);     Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'ripemd128, 128 bits'),     // 23
    (Name:'ripemd160';   Value:Integer(M_RIPEMD160);     Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'ripemd160, 160 bits'),     // 24
    (Name:'ripemd256';   Value:Integer(M_RIPEMD256);     Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'ripemd256, 256 bits'),     // 25
    (Name:'ripemd320';   Value:Integer(M_RIPEMD320);     Clazz:CLS_CRC;     ParamType:ptNone;                   Descr:'ripemd320, 320 bits')      // 26
  );

type
  TParameters = record
    // Команды, опции, методы
    Params: array of String;
    Command: TCommand;
    CrcSet: TCrcSet;
    // Параметры команд, опций и методов
    ChecksumPath: String;  // рабочий каталог, где хранятся MD5 файлы (опция -work)
    FilesPath: String;     // базовый каталог, с файлами (опция -base)
    FolderLevel: Integer;  // уровень папок (опции -split, -join)
    Recursive: Boolean;    // рекурсивно, модификатор для команды verify
    NoRecursive: Boolean;  // нерекурсивно, модификатор для команды create
    CheckFile: String;     // имя файла контрольных сумм
    // Разное
    DebugMode: Boolean;    // =true, из файла всегда читаются нули (для отладки)
    LogPath: String;       // каталог с лог-файлами
    ErrorMessage: String;  // сообщение об ошибке разбора командных параметров
    function SameFolders: Boolean;
    procedure Parse;
    procedure PrintHelp(longVersion: Boolean);
    procedure LogParameters;
  end;

var
  Parameters: TParameters;

IMPLEMENTATION


function GetCommandNameByCommand(cmd: TCommand): String;
var
  i: Integer;
begin
  result := '';
  for i := low(Options) to high(Options) do
  begin
    if (Options[i].Clazz = CLS_COMMAND) AND (TCommand(Options[i].Value) = cmd) then
    begin
      Exit( Options[i].Name );
    end;
  end;

end;

{ TParameters }

function TParameters.SameFolders: Boolean;
begin
  result := CompareStringIgnoreCaseExact(Parameters.ChecksumPath, Parameters.FilesPath);
end;

{==============================================================================}

procedure TParameters.LogParameters;
var
  id: Integer;
  i: Integer;
begin
  Log.AddText('COMMAND LINE:');
  id := 1;
  for i := low(Params) to high(Params) do
  begin
    Log.AddText(IntToStr(id) + '. ' + Params[i]);
    inc(id);
  end;
end;

procedure TParameters.Parse;
var
  i: Integer;
  j: Integer;
  optIndex: Integer;
  //
  TempStr: String;
  TempInt: Integer;
  //
  optSpec: array[TOption] of Boolean;
  setCommand: TCommand;
  setOption: TOption;
  setCrc: TCrc;
begin
  // Разбор командной строки
  // command
  Command := CMD_EMPTY;
  // options
  for setOption := low(optSpec) to high(optSpec) do optSpec[setOption] := FALSE;
  FilesPath := '';          // files
  ChecksumPath := '';       // checksum
  FolderLevel := 1;         // split [level], -join [level]
  DebugMode := FALSE;       // debug
  LogPath := '';            // log
  Recursive := FALSE;       // recursive
  NoRecursive := FALSE;     // norecursive
  CheckFile := '';          // checksum file name
  // checksums type
  CrcSet := [M_MD5];        // типы КС crc32, adler32, ....
  // others
  ErrorMessage := '';       // Обнаруженная ошибка при разборе командной строки
  //
  setLength(Params, ParamCount());
  for i := low(Params) to high(Params) do
  begin
    Params[i] := ParamStr(i+1);
  end;
  //
  i := low(Params);
  while i <= high(Params) do
  begin
    TempStr := Params[i];
    // Поиск команды в массиве команд
    optIndex := -1;
    for j := low(Options) to high(Options) do
    begin
      if CompareStringIgnoreCaseExact(Options[j].Name, TempStr) then
      begin
        optIndex := j;
        break;
      end;
    end;
    //
    if optIndex = -1 then
    begin
      ErrorMessage := 'Unknown command, options or checksum ID: ' + TempStr;
      Exit;
    end;
    // Разбираемся с параметром команды
    case Options[optIndex].ParamType of
      ptInt:
      begin
        // Если следующего параметра нет или он не цифра, принять значение по-умолчанию: 1
        inc(i);
        if i <= high(Params) then
        begin
          TempStr := Params[i];
          if NOT TryStrToInt(TempStr, TempInt) then
          begin
            TempInt := 1; // Следующий параметр не цифра, значение по-умолчанию
            Dec(i);
          end;
        end else
        begin
          TempInt := 1; // Значение по-умолчанию
        end;
        //
        FolderLevel := TempInt;
      end;
      ptPath, ptFile:
      begin
        inc(i);
        if i <= high(Params) then
        begin
          TempStr := Params[i].DeQuotedString;
          { DONE : Нужно сделать тут полный путь }
          TempStr := ExpandFileName(TempStr);
        end else
        begin
          ErrorMessage := 'Parameters must be specified after command "' + Options[optIndex].Name + '"';
          Exit;
        end;
      end;
    end;
    //
    // А теперь работаем с опцией/командой/ИД контрольной суммы
    case Options[optIndex].Clazz of

      CLS_COMMAND:
      begin
        setCommand := TCommand(Options[optIndex].Value);
        if Command <> CMD_EMPTY then
        begin
          ErrorMessage := 'Command already specified to "' +
                          GetCommandNameByCommand(Command) +
                          '", try redeclared to "' +
                          GetCommandNameByCommand(setCommand) +
                          '"';
          Exit;
        end;
        Command := setCommand;
      end;

      CLS_OPTION:
      begin
        setOption := TOption(Options[optIndex].Value);
        if optSpec[setOption] then
        begin
          ErrorMessage := 'Option "' + Options[optIndex].Name + '" already specified';
          Exit;
        end else optSpec[setOption] := TRUE;
        //
        case setOption of
          OPT_RECURSIVE: Recursive := TRUE;
          OPT_NORECURSION: NoRecursive := TRUE;
          OPT_FILESPATH: FilesPath := TempStr;
          OPT_CHECKSUMPATH: ChecksumPath := TempStr;
          OPT_LOGPATH: LogPath := TempStr;
          OPT_CHECKFILE: CheckFile := TempStr;
        end;
      end;

      CLS_CRC:
      begin
        setCrc := TCrc(Options[optIndex].Value);
        CrcSet := CrcSet + [setCrc];
      end;

    end;

    inc(i);
  end;

  // Если какие-то параметры не заданы, задаём их значения по-умолчанию
  // Разбираемся с путями
  // Каталогом с контрольными суммами считается папка, откуда запущена программа
  // (если этот каталог не указан в параметрах)
  if ChecksumPath = '' then ChecksumPath := GetCurrentDir;
  if FilesPath = '' then FilesPath := ChecksumPath;
  // Log path (global LOG) - каталог с логами
  if LogPath = '' then LogPath := ExtractFileDir(ParamStr(0));

  // "Причёсываем" Для красоты
  Parameters.ChecksumPath := PathBeautifuler(Parameters.ChecksumPath);
  Parameters.FilesPath := PathBeautifuler(Parameters.FilesPath);
  Parameters.LogPath := PathBeautifuler(Parameters.LogPath);

end;

procedure TParameters.PrintHelp(longVersion: Boolean);
var
  Clazz: TClazz;
  i: Integer;
  Descr: String;
const
  L1 = 2;     // отступ до команды, опции, ИД контрольной суммы
  L2 = 20;    // ширина поля для названия + описание параметров
  LDiff = 10; // сколько отступить от правого края
begin
  if ErrorMessage <> '' then
  begin
    Console.WriteLn;
    Console.WriteLn('! Error processing command line:');
    Console.WriteLn('  ' + ErrorMessage);
    Console.WriteLn;
  end;
  //
  for Clazz := low(TClazz) to high(TClazz) do
  begin
    if Clazz = CLS_NONE then continue;
    if (Clazz = CLS_CRC) AND (NOT longVersion) then continue;
    //
    Console.WriteLn( Clazzs[Clazz] + ':' );
    for i := low(Options) to high(Options) do
    begin
      if Options[i].Clazz = Clazz then
      begin
        Console.Write(StringOfChar(' ', L1));
        Console.Write(Format('%-*s', [L2, Options[i].Name + ' ' + Options[i].Params]));
        // Извлечь описание команды
        Descr := Options[i].Descr;
        if longVersion AND (Options[i].LongDescr <> '') then
        begin
          Descr := Options[i].LongDescr;
        end;
        Console.PrintParagraph(Options[i].Descr, Console.Width - L1 - L2 - LDiff);
      end;
    end;
    Console.WriteLn;
  end;

  if longVersion then
  begin
    Console.PrintParagraph('! ',
      'if command "create" or "verify" is not specified, ' +
      'then use this algorithm:', 0);

    Console.PrintParagraph('* ',
      'if in current catalog exists any MD5 file, the command ' +
      'assumed "verify" and use no recursive checksum files '+
      'search (to override this, use ' +
      'option "recursive")', 0);

    Console.PrintParagraph('* ',
      'otherwise, command assumed "create" and use recursive ' +
      'file search (to override this, use option ' +
      '"norecursive")', 0);

    Console.WriteLn('Examples:');
    Console.WriteLn('  md5ex  create ');
    Console.WriteLn('  md5ex  create  checkfile  "new_check.md5"');

  end else
  begin

    Console.PrintParagraph('! ',
      'This is short version of help. ' +
      'Use command "longhelp" to show extended help topics', 0);
  end;

end;

end.

//
