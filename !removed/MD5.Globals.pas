unit MD5.Globals;
// Глобальные переменные.

interface

uses
  MD5.Logs,
  MD5.Console,
  MD5.Version;

const
  ATTR_STATNUMBER  =  $000B; // Число в статистике
  ATTR_STATPERCENT =  $000D; // Процент в статистике

  ATTR_HIGHLIGHT   =  $000F; // Просто выделение
  ATTR_NUMBER      =  $000F; // Число
  ATTR_FILE        =  $0006; // Файл/путь
  ATTR_ERROR       =  $000C; // ОШИБКА
  ATTR_OK          =  $000A; // НЕТ_ОШИБКИ
  ATTR_WORKMODE    =  $000F; // Режим работы программы

type
  TOptions = record
    _WorkPath: String;   // рабочий каталог, где хранятся MD5 файлы
    _BasePath: String;   // базовый каталог, с файлами
    LogPath: String;    // каталог с лог-файлами
    SpecialMode: Boolean;
    Recursive: Boolean; // Рекурсивный поиск *.md5 файлов
  end;

var
  Log: TLog;
  Console: TConsole;
  Version: TVersion;
  Options: TOptions;

implementation

initialization
  Console := TConsole.Create;
finalization
  Console.Free;
end.

