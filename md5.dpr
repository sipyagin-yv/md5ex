{TODO 5 -cvery important: при запуске на сетевом диске вылетает с исключением:
cannot create file.}

{ DONE -cvery important :ВНИМАНИЕ! при рекурсивной проверке контрольных сумм,
у каждого *.md5 файла должен быть свой базовый путь }

{ DONE : Впоследствии, указание рабочего каталога сделать через
  ключ -b (-basedir), например -b d:\work_path ИЛИ
  -b "d:\work path" }

// ЗАДАЧИ
// ======
//
// * рассмотреть задачу хранения вычисленных контрольных сумм в глобальном каталоге, куда будут складываться
//   все вычисленные/проверенные контрольные суммы. Он будет представлять обычный MD5 файл, но пути к файлу
//   будут глобальные, с указанием диска. Например,
//   000000000000000000000 *d:\video0\~иностранные фильмы\С\Стражи Галактики (2014)\стражи галактики [2014].avi
//   и так далее.
//
// * STOP/RESUME:
//   > сделать возможность продолжения вычисления контрольной суммы после прерывания работы
//     например, через ключе -resume
//   > по пункту с ключем -resume. Где-то нужно хранить результаты вычислений КС. Во временном файле?
//     или сразу записывать в файл КС?
//   > прерывание сделать по Ctrl+C. При этом состояние программы должно сохраниться.
//
// * и снова задача - избавиться от мерцания. При обработке очень
//   больших файлов мерцание есть, т.к. показания изменяются очень
//   медленно, а прорисовка каждую секунды. Для избавления от этого:
//   ввести проверку на изменение показаний. Т.е. сохраняем отображенное
//   значение в TProgressMessage, и если в следующий раз что-то изменилось
//   в данных - отображаем это на экране (в основном, это касается процентов)
//
// * избавиться от указания атрибутов при работе с TConsole.
//   например, вместо Console.WriteNumber(ATTR_NUMBER, ...) писать просто,
//   Console.WriteNumber(...). Атрибут сам используется нужный. А для его
//   указания использовать методо Console.SetAttrNumber(ATTR_NUMBER).
//   Ну или Console.SetAttr(ATTR_NUMBER, attrNumberValue).
//
// * добавить новые методы SHA1,SHA2 и проч.
//
// * Хранить в *.md5 файлах атрибуты файла.
//   В случае, если файл не найден, искать его по атрибутам.
//   Таким образом, файл будет проверен, даже если он будет перемещен.
// == как вариант, после проверки файлов, если имеются новые и отсутствующие файлы, то вычисляем
//    контрольные суммы новых файлов, а затем ищем по контрольной сумме файлы среди отсутствующих.
//    Дополнительно проверяем имя файла. Если имена совпадают, то это наш перемещенный файл. Если
//    имя не совпадает, то возможны варианты... Но, конечно, надежнее будет хранить атрибуты файла
//    в *.md5. Атрибуты хранить под видом комментариев, например:
//    000000000000000000000000000000000000000 *folderA/file data1.txt
//    000000000000000000000000000000000000000 *folderB/file data2.txt
//    #EXT_INFO
//    #"folderA/file data1.txt", size=100234, attr=0x20, created=0x1234567812345678, last_write=0x1234567812345678, last_change=0x1234567812345678
//    #"folderB/file data2.txt", size=124, attr=0x20, created=0x1234567812345678, last_write=0x1234567812345678, last_change=0x1234567812345678
//    #END_EXT_INFO
//
// * компактный log файл,например:
//   checking "checksums001.md5" -- OK
//   checking "checksums002.md5" -- OK
//   checking "checksums003.md5" -- FAIL
//   (wrong 2 files, not found 2 files, not opened 2 files, new 2 files):
//     wrong checksums:
//        file1.txt
//        file2.txt
//     not found:
//        file3.txt
//        file4.txt
//     found, but nop opened:
//        file5.txt
//        file6.txt
//     new files:
//        file7.txt
//        file8.txt
//
// * Обновление файла с контрольными суммами. Например, в таком варианте:
//   checksums.md5 --> основной файл
//   checksums(10-12-2015).md5 --> добавление новых файлов
//   checksums(15-12-2015).md5 --> добавление новых файлов и т.д.
//   Т.е. это вариант с добавлением новых файлов, но старые файлы с контрольными
//   суммами при этом не меняются.
//
// * При выходе из программы убрать одну лишнюю строчку
//
// * Мелкие косметические изменения
//
// СДЕЛАНО
// =======
// * Как вариант, хранить контрольные суммы в альтернативных файловых потоках,
//   например, file:checksums.
// == вряд ли это хороший вариант. Если программа копирования не сумеет скопировать альтернативный файловый
//    поток, мы потеряем информацию о контрольных суммах. Возможно, лучше оставить так как есть сейчас, т.к.
//    контрольные суммы хранятся в файлах *.md5. 
//
// * реализовать команду SCAN - поиск папок, в которых отсутствуют контрольные файлы с контрольными суммами
//   а также файлов, которые отсутствуют в файлах КС (ВНИМАНИЕ! Есть папка c:\data. В этой папке есть файл КС.
//   И есть файл c:\data\sub1\text.txt. Файл присутствует в файле КС. Команда SCAN не должна реагировать на этот
//   самый файл).
// == Сделан объект TChecksumCatalog, который умеет читать все файлы *.md5, удалять полные дубликаты файлов
//    а также вычислять новые и отсутствующие файлы. Новые и отсутствующие файлы можно узнать с помощью
//    методов NewFiles, NotFoundFiles. По списку новых файлов, например, можно вычислить КС новых файлов и 
//    записать в *.md5 файл.
//
// * Сообщение об ошибках выводить так:
//   File open error "d:\data2\file.dat" [Access Denied]
//   File open error "d:\data2" [File not found]
//
// * нужен объект, умеющий читать *.md5 файла.
//    у него будет:
//       список файлов - FileList
//       контрольные суммы - CheckLists[method]
//       базовый путь - BasePath
//
// * Мелкие косметические изменения ("Verifying is done, with errors" поставить ":")
//   OK
//
// * В конце выводить время в виде дд:чч:мм:сс
//   OK
//
// * функция для "редукции" имени файла, чтобы все вмещалось на 1 строчку консоли
//   OK
//
// * Поиск "новых" файлов, т.е. файлов, появившихся после создания md5 файла
//   {
//     a)читаем список файлов, кроме файла с контрольными суммами,
//     b)читаем список файлов из файла с контрольными суммами.
//     Сравниваем списки a) и b): ищем те файлы из списка a), которых нет в списке b)
//   }
//   OK
//
// * при проверке контрольных сумм сообщать о "лишних" файлах,
//   появившихся после создания файла с контрольными суммами
//   OK
//

(*
  Описание команд и модификаторов командной строки.

  Основные команды, которые умеет выполнять md5 (command),
  в командах можно опускать ведущий "-":
     -[c]reate - вычислить контрольные суммы
     -[v]erify - проверить контрольные суммы
     -[u]pdate - обновить контрольные суммы
     -[s]plit [level] - разделить файл контрольных сумм по папкам.
                        [level] - на сколько глубоко просматривать каталоги.
                        По умолчанию - 1.
     -[j]oin [level] - сцепить файлы контрольных сумм из папок.
                       [level] - на сколько глубоко просматривать каталоги.
                       По умолчанию - 1.
     -[s]can - найти папки, в которых нет файлов с контрольными суммами.
     -[r]esume - продолжить предыдущую незавершенную операцию.
     -[h]elp, -? - помощь по командам и опциям (эта страница)

  Модификаторы команд (options):
     -[r]ecursive - рекурсивная операция (в текущем каталоге и подкаталогах)
     -[n]orecursive - нерекурсивная операция (только в текущем каталоге)
     -[b]ase каталог - указание базового каталога
                       (по-умолчанию - текущий каталог)
     -[w]ork каталог - указание рабочего каталога
                       (по-умолчанию - текущий каталог)
     -[l]og каталог - указание каталога для log фалов
                      (по-умолчанию - каталог, откуда запущена программа)
     -debug - режим отладки. Из файлов всегда читаются нули.

  Методы вычисляние контрольных сумм (methods), могут указываться
  несколько доступных методов, например -md5 -sha1:
     -md2, -md4, -md5,
     -sha1, -sha224, -sha256, -sha384, -sha512,
     -crc32, -adler32, -tiger192,
     -RipeMD128, -RipeMD160,
     -RipeMD256, -RipeMD320 - указание метода контрольной суммы.

  Существуют базовый и рабочий каталог. По умолчанию они равны текущему каталогу.
     * Базовый каталог, с которого прогамма начинает проверку/вычисление
       контрольных сумм.
     * Рабочий каталог - каталог, где находятся файлы с контрольными суммами.
  Это нужно для того, чтобы проверять файлы из каталога, который находится
  в месте, отличном от места с файлами контрольных сумм. Например, на CD-ROM.

  Формат файла с контрольными суммами. Предлагается оставить базовым формат MD5:
     контрольная сумма, пробел, "*", имя файла с путём.
  А все остальные форматы, в том числе атрибуты файла, записывать
  в комментарий к файлу. Например:
     8eff61de *readme.txt # ext:size=1_309_835,attr=AH,
                                create=10/05/2015_16:24,
                                change=10/05/2016_16:32,
                                open=10/05/2016 10:24,sha1=93080923809286,crc32=0285095,
                                ripemd128=329015823905205723095
  Атрибуты файла могут пригодиться, если файл был перемещен, и будет
  произведен поиск по имеющимся атрибутам, с последующим вычислением
  контрольной суммы.

  Или же сохранять в комментарии после файла:
  73972398573 *readme.txt
  #A8 /** @size=1_282_2328, @attr=AH,
  #99 @create=10/05/2015_16:24, @change=10/05/2015_19:20, @open=10/05/2015_12:00
  #83 @sha1=320781532985732095713295739257932753971590327519075932
  #90 @ripemd128=302917538972214712908742189741274 **/

  Логика запуска:
  1) Запуск без параметров командной строки
     если в "рабочий каталог" есть файлы *.md5
        проверить контрольные суммы файлов из каталогов "базовый путь",
        указанных в файлах *.md5
     иначе
        вычислить контрольные суммы файлов из каталогов "базовый путь",
        РЕКУРСИВНО
        и записать контрольные суммы в файл checksums.md5
     конец если

  2) Запуск с параметрами -verify
     если не указано -recursive, запуск подобен п.1
     если указано -recursive, то ищем все файлы *.md5 и проверяем все файлы
     из них.

  3) Запуск с параметрами -calculate
     если указано или не указано -recursive, вычисляем контрольные суммы
     всех файлов РЕКУРСИВНО.
     если указано -norecursive, вычисляем контрольные суммы всех файлов
     только в текущем каталоге.

  4) Запуск с параметрами -update [файл для обновления контрольной суммы]
       do (
              Если файла MD5 нет {
                 переходим в предыдущий каталог,
                 если каталогов больше нет, прерываемся с "error"
              }
              Если файл есть в файле MD5 {
                 вычисляем контрольную сумму,
                 обновляем файл MD5
                 выходим с "ok".
              } иначе {
                 переходим в предыдущий каталог,
                 если каталогов больше нет, прерываемся с "error"
              }
          )

*)

{ TODO -cvery important :
В СЛУЧАЕ, ЕСЛИ имеются ненайденные файлы,
в конце сообщать сводку типа:

5 файлов всего в md5
4 файла не найдено
1 файл проверен без ошибок }

{ DONE -cvery important :Убрать из перерисовки статистической строки
очистку пробелами... Т.е. рисовать по нарисованному, без
предварительного стирания
UPD: В общем то, так и было...}
{ TODO : скорее всего, вывод #8 приводит к такому морганию }
{ TODO :
Всё-таки мерцание есть, если выводить текст поверх текста. Очень заметное.
Видимо нужно делать что-то типа умного вывода. Или просто не обращать внимание. }

program MD5; //программа будет считать не только MD5, как назвать???
// Вычисление контрольных сумм MD5
// в будущем SHA1, и другие...
// Работа с программой:
// 1.  Запуск без параметров приводит к поиску файла *.md5
//     в текущей папке и проверке файлов
// 2.  Если *.md5 не найден, происходит генерация контрольных
//     сумм по всем файлам и папкам, начиная с текущей папки

{$APPTYPE CONSOLE}
{$R *.res}

uses
  // system units
  Windows,
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.StrUtils,
  System.Character,
  System.DateUtils,
  System.Math,
  System.Contnrs,
  System.RegularExpressions,
  System.Generics.Collections,
  // shared units
  shared.Console,
  shared.FileUtils,
  shared.Globals,
  shared.Logs,
  shared.ProgressMessage,
  shared.Utils,
  shared.Version,
  shared.FileWalker,
  shared.FileList,
  shared.Debug,
  // local units
  MD5.Hash in 'MD5.Hash.pas',
  MD5.Parameters in 'MD5.Parameters.pas';

{ TODO: Ввести отображение процентов в заголовке окна (как при копировании в FAR) }
const
{$IFDEF SPECIAL_FAST_MODE}
  {$MESSAGE 'SPECIAL MODE: default extension is "md5debug"'}
  DEFAULT_EXT = 'md5debug';
{$ELSE}
//  {$MESSAGE 'SPECIAL MODE: off'}
  DEFAULT_EXT = 'md5';
{$ENDIF}
  DEFAULT_FILENAME = 'checksums.' + DEFAULT_EXT;
  DEFAULT_CHECKSUM_PATTERN = '^.*\.' + DEFAULT_EXT + '$';
  //
  UPDATE_SEARCH_INTERVAL = 1000; // в миллисекундах!
  UPDATE_CALC_INTERVAL = 1000; // в миллисекундах!
  VERIFY_CALC_INTERVAL = 1000; // в миллисекундах!
  BUFFER_SIZE = 50 * 1024 * 1024; // В байтах

type
  TTotalInfo = record
    TotalSize: UInt64;       // Общий объем
    TotalReaded: UInt64;     // Сколько прочитано от общего объема
    SaveTotalReader: UInt64; // для случаев, если ошибка при открытии/чтении
    TotalFiles: Integer;     // Общее количество файлов
  end;

{ DONE 1 :При открытии занятого другим процессом файла происходит следующее:
md5.exe: Exception EFOpenError in module md5.exe at 000AB063.
Cannot open file "\\?\C:\Utils\MD5\md5.exe". Процесс не может получить доступ
к файлу, так как этот файл занят другим процессом.

-- Готово. Необходимо TStream открывать с параметрами
fmOpenRead OR fmShareDenyWrite
}

/// <summary>
///   Показать статистику о прошедшем времени и скорости обработки
/// </summary>
/// <param name="TotalSize">
///   Общий размер файлов
/// </param>
/// <param name="Passed">
///   Сколько прошло времени, в миллисекундах
/// </param>
procedure ShowTimeStatistics(TotalSize: UInt64; Passed: Cardinal);
// 0xffffffff ms = 4'294'967'295 ms, 4'294'967 s, 71582 min, 1193 hrs, 48 days.
const
  SEC_DIVISOR = 1000;
  MEGABYTE = 1024*1024;
var
  DHMS: TDayHourMinSec;
begin
{ DONE : Расширить статистику о времени, показывать дни, часы, минуты, секунды }
  Console.Write('Passed time ');
  Console.Write(ATTR_NUMBER, Format('%.1f', [Passed/SEC_DIVISOR]));
  Console.Write(' sec');
  // Вывести время в формате [dd:hh:mm:ss]
  DHMS.AssignFromMs(Passed);
  //
  if (DHMS.Day>0) OR (DHMS.Hour>0) OR (DHMS.Min>0) then
  begin
    Console.Write(' [');
    if (DHMS.Day>0) then
    begin
      Console.Write(ATTR_NUMBER, IntToStr(DHMS.Day));
      Console.Write('d ');
    end;
    if (DHMS.Hour>0) OR (DHMS.Day>0) then
    begin
      Console.Write(ATTR_NUMBER, Format('%.2d', [DHMS.Hour]));
      Console.Write('h ');
    end;
    if (DHMS.Min>0) OR (DHMS.Hour>0) OR (DHMS.Day>0) then
    begin
      Console.Write(ATTR_NUMBER, Format('%.2d', [DHMS.Min]));
      Console.Write('m ');
    end;
    Console.Write(ATTR_NUMBER, Format('%.2d', [DHMS.Second]));
    Console.Write('s');
    Console.Write(']');
  end;
  //
  Console.WritePointLn;
  // avoid divizion by zero
  if Passed > 0 then
  begin
    Console.Write('Average speed ');
    Console.WriteFormatNumber(ATTR_NUMBER,
                              Trunc(TotalSize / (Passed/SEC_DIVISOR)) DIV MEGABYTE );
    Console.Write(' Mb/sec');
    Console.WritePointLn;
  end;
end;

/// <summary>
///   Показать статистику о общем количестве файлов и общем размере
/// </summary>
/// <param name="TotalSize">
///   Общий размер файлов
/// </param>
/// <param name="TotalFiles">
///   Общее количество файлов
/// </param>
procedure ShowTotalStatistics(TotalSize: UInt64; TotalFiles: Integer);
begin
  Console.Write('Total files ');
  Console.WriteFormatNumber(ATTR_NUMBER, TotalFiles);
  Console.WritePointLn;
  //
  Console.Write('Total size ');
  Console.WriteFormatNumber(ATTR_NUMBER, TotalSize);
  Console.Write(' bytes');
  Console.WriteFormatNumberSize(ATTR_NUMBER, TotalSize);
  Console.WritePointLn;
end;

procedure ShowParametersDirectories;
begin
  // Console.Write('Working directory is the same as the base directory');
  if Parameters.SameFolders then
  begin
    Console.Write('Files and checksums directory ');
    Console.WriteFileName(ATTR_FILE, Parameters.FilesPath, TRUE);
  end else
  begin
    Console.Write('Files directory ');
    Console.WriteFileName(ATTR_FILE, Parameters.FilesPath);
    Console.WriteLn;
    Console.Write('Checksums directory ');
    Console.WriteFileName(ATTR_FILE, Parameters.ChecksumPath);
  end;
  Console.WritePointLn;
end;

procedure ShowFileErrorInfo(const FileName: String;
                            const ErrorMessage: String;
                            const ErrorDescription: String = '');
var
  TempStr: String;
begin
  // На экран выдаем локальное имя файла
  TempStr := ShowTrailingSpaces(GetLocalFileName(Parameters.FilesPath, FileName));
  Console.Write('File ');
  Console.WriteFileName(ATTR_FILE, TempStr);
  Console.Write(' is ');
  Console.Write(ATTR_ERROR, ErrorMessage);
  if ErrorDescription <> '' then
  begin
    Console.Write(' [');
    Console.Write(ErrorDescription);
    Console.Write(']');
  end;
  Console.WritePointLn;
end;

procedure ShowFileList(const L: TStringList;
                       Attr: Integer;
                       const ListDescr: String;
                       MaxOutput: Integer);
var
  i, FirstOutput, EndOutput: Integer;
begin
  if L.Count = 0 then Exit;
  //
  Console.Write('List of ');
  Console.WriteFormatNumber(ATTR_NUMBER, L.Count);
  Console.Write(' ');
  Console.Write(Attr, ListDescr);
  Console.Write(' files');
  if L.Count > MaxOutput then
  begin
    FirstOutput := MaxOutput;
    EndOutput := L.Count-MaxOutput;
    //
    Console.Write(' (first ');
    Console.WriteFormatNumber(ATTR_NUMBER, FirstOutput);
    Console.Write(')');
  end else
  begin
    FirstOutput := L.Count;
    EndOutput := 0;
  end;
  Console.Write(':');
  Console.WriteLn;
  //
  for i := 0 to FirstOutput-1 do
  begin
    //Console.WriteFormatNumber(i+1);
    //Console.Write('. ');
    Console.Write('* ');
    Console.WriteFileName(ATTR_FILE, L[i]);
    Console.WriteLn;
  end;
  if EndOutput > 0 then
  begin
    Console.Write('... and ');
    Console.WriteFormatNumber(ATTR_NUMBER, EndOutput);
    Console.Write(' files not shown (see full list in log file)');
    Console.WritePointLn;
  end;
end;

type
  TGenErrorCode = (gecFileOK, gecFileNotOpen, gecFileReadError, gecFileChecksumError);

function ShowFileStatusInformation(ErrorCode: TGenErrorCode;
  const FileName: String; SR: TSequentialFileReader): Boolean;
var
  StatusMessage: String;
begin
  StatusMessage := '';
  if Assigned(SR) then StatusMessage := SR.StatusMessage;
  // В log файле сохраняем полный путь к файлу,
  // на экран выдаем локальный путь
  case ErrorCode of

    gecFileOK:
    begin
      // На экран информация об успешности проверки не выдается
      Log.AddText('OK, file ' + FileName);
    end;

    gecFileNotOpen:
    begin
      ShowFileErrorInfo(FileName, 'not opened', StatusMessage);
      Log.AddText('error opening file [' + StatusMessage + '] (' + FileName + ')');
    end;

    gecFileReadError:
    begin
      ShowFileErrorInfo(FileName, 'error while reading', StatusMessage);
      Log.AddText('error while reading [' + StatusMessage + '] (' + FileName + ')');
    end;

    gecFileChecksumError:
    begin
      ShowFileErrorInfo(FileName, 'wrong checksum');
      Log.AddText('FAIL, wrong checksum calculated (' + FileName + ')');
    end;

  end;
  result := TRUE;
end;

//============================================================================//
//                                                                            //
//                      ВЫЧИСЛЕНИЕ КОНТРОЛЬНЫХ СУММ                           //
//                                                                            //
//============================================================================//
/// <summary>
///   Вычисление контрольной суммы у файлов.
/// </summary>
/// <param name="FilesPath">
///   путь, по которому находятся файлы, у которых вычисляются контрольные суммы
/// </param>
/// <param name="ChecksumPath">
///   путь, по которому нужно сохранить файл с вычисленными контрольными суммами
/// </param>
procedure DoCreateMD5;
var
  // Списки
  FileList, Checksums: TStringList;
  // Для статистики
  TI: TTotalInfo;
  S: TProgressMessage;
  // Для цикла
  FileName: String;
  MD5: TMD5Hash;
  i: Integer;
  SR: TSequentialFilereader;
  //
  ErrorFlag: Boolean;
  ErrorFlagMessage: String;
  MD5Value: String;
  t: TFileCharacteristics;
begin
  Log.AddText('MODE: Create checksums');
  Log.AddPart;
  //
  Console.WriteLn;
  ShowParametersDirectories;
  //
  Console.Write(ATTR_WORKMODE, 'Calculating checksums');
  Console.WritePointLn;
  // ищем все файлы, добавлять инф о файле
  FileList := FindFilesEx(Parameters.FilesPath,               // Начальный путь поиска
                          ALL_FILES_PATTERN,                  // Шаблон имен файлов
                          [ffoptRecursive, ffoptAddFileChar], // Options
                          procedure(var Info: TProgressMessageParameters)
                          begin
                            Console.Write('Search files, found ');
                            Console.WriteFormatNumber(ATTR_NUMBER_STAT, Info[0]);
                            Console.Write(' files, ');
                            Console.WriteFormatNumber(ATTR_NUMBER_STAT, Info[1]);
                            Console.Write(' folders');
                          end,                                // Процедура статистики
                          UPDATE_SEARCH_INTERVAL);            // Интервал обновления статистики, мс
  FileList.Sort;
  // Подготовка рабочих переменных
  TI.TotalSize := 0;
  TI.TotalReaded := 0;
  // Вычисление общего размера
  for i := 0 to FileList.Count-1 do
  begin
    t := TFileCharacteristics(FileList.Objects[i]);
    if Assigned(t) then Inc(TI.TotalSize, t.Attr.Size);
  end;
  // Формируем заголовок выходного файла
  Checksums := TStringList.Create;
  Checksums.Add('# Checksums generated by program of YSoft lab [version ' + Version.Version + ']');
  Checksums.Add('# Created at "' + CurrentDateTime + '"');
  Checksums.Add('# Total files ' + FormatNumber(FileList.Count));
  Checksums.Add('# Total size ' + FormatNumber(TI.TotalSize) + ' bytes');
  Checksums.Add('# Files path "' + Parameters.FilesPath + '"');
  Checksums.Add('# Checksums path "' + Parameters.ChecksumPath + '"');
  Checksums.Add('# Volume name "' + GetVolumeName(Parameters.FilesPath) + '"');
  Checksums.Add('');

  // Информация
  ShowTotalStatistics(TI.TotalSize, FileList.Count);
  //
  S := TProgressMessage.Create(
         procedure(var Info: TProgressMessageParameters)
         begin
           Console.Write('Calculating MD5 of file ');
           Console.WriteFormatNumber(ATTR_NUMBER_STAT, Info[0]);
           Console.Write(' of ');
           Console.WriteFormatNumber(ATTR_NUMBER_STAT, Info[1]);
           Console.Write(' [');
           Console.Write(ATTR_PERCENT_STAT, IntToStr(Info[2]).PadLeft(3));
           Console.Write(ATTR_PERCENT_STAT, '%');
           Console.Write(']');
         end,
         UPDATE_CALC_INTERVAL);
  // Вычисляем контрольные суммы
  SR := TSequentialFileReader.Create(TMD5Hash.GetFitBlockSize(BUFFER_SIZE));
  for i := 0 to FileList.Count-1 do
  begin
    ErrorFlag := FALSE;
    FileName := FileList[i];
{ DONE :Что будет, если файла не окажется на месте??? Например, удалится после сканирования списка файлов???
= Сделано. Если файл отсутствует, к прочитанным байтам прибавляем его размер и всё. А также пишем сообщение об ошибке.}
    TI.SaveTotalReader := TI.TotalReaded; // на случай ошибки
{ DONE : Сделать, чтобы объект TSequentialFileReader выделял память под буфер только один раз!!! }
    if NOT SR.OpenFile(FileName) then
    begin
      S.Clear;
      ShowFileStatusInformation(gecFileNotOpen, FileName, SR);
      ErrorFlag := TRUE;
    end else
    begin
      // ЦИКЛ ВЫЧИСЛЕНИЯ КОНТРОЛЬНОЙ СУММЫ
      MD5 := TMD5Hash.Create;
      while SR.ReadNextBlock do
      begin
        if SR.Status <> 0 then
        begin
          S.Clear;
          ShowFileStatusInformation(gecFileReadError, FileName, SR);
          ErrorFlag := TRUE;
          Break;
        end;
        //
        MD5.Update(SR.Buffer, SR.LastReaded);
        Inc(TI.TotalReaded, SR.LastReaded);
        //
        if S.NeedShow then S.Show(smFORCE, [i+1, FileList.Count, Percent(TI.TotalReaded, TI.TotalSize)]);
      end;
      MD5Value := MD5.Done;
      MD5.Free;
      // ЦИКЛ ВЫЧИСЛЕНИЯ КОНТРОЛЬНОЙ СУММЫ
    end;
    if ErrorFlag then
    begin
      // Корректируем общее количество обработанных файлов
      TI.TotalReaded := TI.SaveTotalReader;
      Inc(TI.TotalReaded, TFileCharacteristics(FileList.Objects[i]).Attr.Size);
//      Log.AddText(ErrorFlagMessage);
    end;
    SR.CloseFile;
    { DONE : Продумать конверсию имени, если оно заканчивается на пробел.
             Может быть, закавычить строку?
             Например *readme.rus.txt_ (где _ - пробел), получаем *"readme.rus.txt "
             == ТАК И СДЕЛАНО}
    if NOT ErrorFlag then
    begin
      FileName := GetLocalFileName(Parameters.FilesPath, FileName).Replace('\', '/');
      if FileName.EndsWith(' ') then FileName := FileName.QuotedString;
      Checksums.Add(MD5Value + ' *' + FileName); // "*" означает двоичный файл
    end else
    begin
      Checksums.Add('# ' + ErrorFlagMessage);
    end;
  end;
  SR.Free;
  S.Clear;
  //=======================//
  // Сохраняем результаты  //
  //=======================//
  Checksums.SaveToFile(GetExtendedFileName(Parameters.ChecksumPath + DEFAULT_FILENAME), TEncoding.Unicode);
  Checksums.Free;
  //
  ShowTimeStatistics(TI.TotalSize, S.Passed);
  //
  Console.Write('Calculating checksums ');
  Console.Write(ATTR_OK, 'done');
  Console.WritePointLn;
  //====================//
  // Уничтожаем объекты //
  //====================//
//  FreeMem(Buffer);
  FileList.Free;
  S.Free;
end;

procedure FileListToLog(FileList: TFileList; const Header: String);
var
  i: Integer;
begin
  if FileList.Count > 0 then
  begin
    Log.AddText(Header);
    for i := 0 to FileList.Count-1 do
    begin
      Log.AddText(IntToStr(i+1) + '. "' + FileList[i] + '"');
    end;
    Log.AddDiv;
  end;
end;

//const
//  CHK_FILE_EXT = '.md5';
//
//function isChecksumExtension(const S: String): Boolean;
//begin
//  result := AnsiSameText(
//              S.Substring(S.Length-CHK_FILE_EXT.Length, CHK_FILE_EXT.Length),
//              CHK_FILE_EXT);
//end;

{ TODO :
Расширить статистику, типа
Обрабатывается файл 10 из 100,
Осталось: 10 113 125 байт из 27 000 000
Средняя скорость: 100 мб/сек
Оставшееся время: примерно 10ч 20м

или, например, как в новых версиях freearc
               файл            байт            время
Обработано       1           56 000            10:25
Всего          100      100 324 235   примерно 11:24
Скорость       100 мб/сек

а в усеченной версии статистики, выводить, например, так:

Verifying MD5 of file 2 of 38 [  2%] (passed time 05:35, estimated time 10:53, speed 120Mb/sec)

}
{ DONE :
Неплохо бы перед проверкой прочитать все файлы из данного каталога,
сравнить с файлом контрольных сумм и вывести что-то типа:
НОВЫХ ФАЙЛОВ 10 (список смотри в log файле "Y:\DATA1\LOGS\log 22-11-2015 @ 21-40-32.txt")
}

procedure ShowSourceChecksumFiles(Catalog: TChecksumCatalog);
var
  TempStr: String;
  i: Integer;
begin
  // Показать имя файла контрольных сумм, если он один;
  // или количество, если файлов контрольных сумм несколько.
  if Catalog.ChecksumsCount > 1 then
  begin
    Console.Write(' from ');
    Console.WriteFormatNumber(ATTR_NUMBER, Catalog.ChecksumsCount);
    Console.Write(' checksum files');
    Console.WritePointLn;
    //
    { DONE : Вывести в Log файлы *.md5, по которым будем проверять контрольные суммы }
    Log.AddText('CHECKSUM FILES:');
    for i := 0 to Catalog.ChecksumsCount-1 do
    begin
      Log.AddText(IntToStr(i+1) + '. ' + Catalog.Checksums[i].ChecksumFullFileName);
    end;
  end else if Catalog.ChecksumsCount = 1 then
  begin
    TempStr := GetLocalFileName(Parameters.ChecksumPath, Catalog.Checksums[0].ChecksumFullFileName);
    Console.Write(' from file ');
    Console.WriteFileName(ATTR_FILE, TempStr);
    Console.WritePointLn;
    //
    Log.AddText('CHECKSUM FILE: ' + TempStr);
  end else
  begin
    Console.WriteLn;
  end;
  Log.AddPart;
end;

type
  TVerifyInfo = record
    INFO_NotFound: Integer;
    INFO_New: Integer;
    ERR_FilesNotFound: Integer;
    ERR_WrongChecksum: Integer;
    procedure Clear;
  end;

{ TVerifyInfo }

procedure TVerifyInfo.Clear;
begin
  INFO_NotFound := 0;
  INFO_New := 0;
  ERR_FilesNotFound := 0;
  ERR_WrongChecksum := 0;
end;

procedure ShowVerifyReport(const VI: TVerifyInfo);
begin
  (* LOG [raw data] *)
  Log.AddPart;
  Log.AddText('VERIFYCATION REPORT:');
  Log.AddText('  wrong checksums = ' + IntToStr(VI.ERR_WrongChecksum));
  Log.AddText('  files not found = ' + IntToStr(VI.ERR_FilesNotFound));
  Log.AddText('  new files = ' + IntToStr(VI.INFO_New));
  (* /LOG *)
  // Отчёт о возможных ошибках
  if (VI.ERR_WrongChecksum = 0) AND (VI.ERR_FilesNotFound = 0) then
  begin
    Console.Write('Verifying is done, ');
    Console.Write(ATTR_OK, 'without errors');
    Console.WritePointLn;
  end else
  begin
    Console.Write('Verifying is done, ');
    Console.Write(ATTR_ERROR, 'with errors:');
    Console.WritePointLn;
    //
    if VI.ERR_FilesNotFound <> 0 then
    begin
      Console.Write('* ');
      Console.Write(ATTR_ERROR, FormatNumber(VI.ERR_FilesNotFound));
      Console.Write(' not found files');
      Console.WritePointLn;
    end;
    //
    if VI.ERR_WrongChecksum <> 0 then
    begin
      Console.Write('* ');
      Console.Write(ATTR_ERROR, FormatNumber(VI.ERR_WrongChecksum));
      Console.Write(' checksums errors');
      Console.WritePointLn;
    end;
  end;
end;

//====================================================================================================//
//                                                                                                    //
//                      ПРОВЕРКА КОНТРОЛЬНЫХ СУММ                                                     //
//                                                                                                    //
//====================================================================================================//
/// <summary>Проверить контрольную сумму</summary>
procedure DoVerifyMD5;
var
  VI: TVerifyInfo;
  MD5: TMD5Hash;
  S: TProgressMessage;
  TI: TTotalInfo;
  ErrorFlag: Boolean;
  // Переменные цикла
  i, CurrentFile: Integer;
  SR: TSequentialFileReader;
  MD5Value: String;
  // Каталог
  Catalog: TChecksumCatalog;
  t: TChecksumCatalogItem;
  FileName: String;
begin
  VI.Clear;
  // Подготовка списка файлов для проверки
  Catalog := TChecksumCatalog.Create(Parameters.ChecksumPath, Parameters.FilesPath);
  // Открыть каталог
  S := TProgressMessage.Create(
         procedure(var Info: TProgressMessageParameters)
         begin
           Console.Write('Open catalog [');
           Console.Write(ATTR_PERCENT_STAT, FormatPercent(Info[0], Info[1]));
           Console.Write(']');
         end, 1500);
  Catalog.OpenCatalog(Parameters.Recursive, S, DEFAULT_CHECKSUM_PATTERN);
  S.Free;

  // Показать, что сейчас будем делать
  Console.Write(ATTR_HIGHLIGHT, 'Verifying checksums');
  Log.AddText('MODE: Verify checksums');
  ShowSourceChecksumFiles(Catalog);
  if Catalog.ChecksumsCount = 0 then
  begin
    Console.WriteLn('Nothing to verify (may be option "recursive" need specify?)');
    Catalog.Free; // досрочное закрытие каталога
    Exit;
  end;

  // Получить общий размер файлов и количество
  TI.TotalSize := Catalog.TotalSize;
  TI.TotalFiles := Catalog.FilesCount;

  // REPORT FOR NOT FOUND FILES
  VI.INFO_NotFound := Catalog.NotFoundFiles.Count;
  if VI.INFO_NotFound > 0 then Console.WriteLn;
  ShowFileList(Catalog.NotFoundFiles, ATTR_ERROR, 'not found', 5);
  if VI.INFO_NotFound > 0 then Console.WriteLn;
  // ADD FileList into LOG
  FileListToLog(Catalog.NotFoundFiles, 'LIST OF '+IntToStr(VI.INFO_NotFound)+' NOT FOUND FILES:');

  // REPORT FOR NEW FILES
  VI.INFO_New := Catalog.NewFiles.Count;
  if (VI.INFO_New > 0) AND (VI.INFO_NotFound=0) then Console.WriteLn;
  ShowFileList(Catalog.NewFiles, ATTR_OK, 'new', 5);
  if VI.INFO_New > 0 then Console.WriteLn;
  // ADD FileList into LOG
  FileListToLog(Catalog.NewFiles, 'LIST OF '+IntToStr(VI.INFO_New)+' NEW FILES:');
  //
  ShowTotalStatistics(TI.TotalSize, TI.TotalFiles);
  //
  // ПРОВЕРЯЕМ КОНТРОЛЬНЫЕ СУММЫ
  // ===========================
  Log.AddText('LIST OF VERIFIED FILES:');
  // Второй проход - вычисляем контрольные суммы
  S := TProgressMessage.Create(
         procedure(var Info: TProgressMessageParameters)
         begin
           Console.Write('Verifying MD5 of file ');
           Console.WriteFormatNumber(ATTR_NUMBER_STAT, Info[0]);
           Console.Write(' of ');
           Console.WriteFormatNumber(ATTR_NUMBER_STAT, Info[1]);
           Console.Write(' [');
           Console.Write(ATTR_PERCENT_STAT, IntToStr(Info[2]).PadLeft(3));
           Console.Write(ATTR_PERCENT_STAT, '%');
           Console.Write(']');
         end,
         VERIFY_CALC_INTERVAL);
  //
  { TODO : Оформить в виде процедуры, т.к. код в verify и create одинаковый на 99% }
  TI.TotalReaded := 0;
  CurrentFile := 0;
  SR := TSequentialFileReader.Create(TMD5Hash.GetFitBlockSize(BUFFER_SIZE));
  for i := 0 to Catalog.FilesCount-1 do
  begin
    t := Catalog.Files[i];
    FileName := t.FullFileName;
    //
    Inc(CurrentFile);
    ErrorFlag := FALSE;
    TI.SaveTotalReader := TI.TotalReaded;
    //
    { TODO :А если устроить проверку через MapViewOfFile ? Будет ли это быстрее/проще? }
    SR.OpenFile(FileName);
    if SR.Status <> 0 then
    begin
      S.Clear;
      ShowFileStatusInformation(gecFileNotOpen, FileName, SR);
      ErrorFlag := TRUE;
    end else
    begin
      // ЦИКЛ ВЫЧИСЛЕНИЯ КОНТРОЛЬНОЙ СУММЫ
      MD5 := TMD5Hash.Create;
      while SR.ReadNextBlock do
      begin
        if SR.Status <> 0 then
        begin
          S.Clear;
          ShowFileStatusInformation(gecFileReadError, FileName, SR);
          ErrorFlag := TRUE;
          Break;
        end;
        //
        MD5.Update(SR.Buffer, SR.LastReaded);
        Inc(TI.TotalReaded, SR.LastReaded);
        //                                  Info[0]      Info[1]        Info[3]
        if S.NeedShow then S.Show(smFORCE, [CurrentFile, TI.TotalFiles, Percent(TI.TotalReaded, TI.TotalSize)]);
      end;
      MD5Value := MD5.Done;
      MD5.Free;
    end;
    //
    if ErrorFlag then
    begin
      // "Пропускаем" ошибочный файл
      TI.TotalReaded := TI.SaveTotalReader;
      Inc(TI.TotalReaded, t.Attr.Size);
    end else
    begin
      // Всё в порядке с чтением файла, проверяем контрольные суммы
      if NOT AnsiSameText(t.MD5, MD5Value) then
      begin
        S.Clear;
        ShowFileStatusInformation(gecFileChecksumError, FileName, nil);
        Inc(VI.ERR_WrongChecksum);
      end else
      begin
        Log.AddText('OK, ' + FileName);
      end;
    end;
    SR.CloseFile;
  end;
  SR.Free;
  S.Clear;
  // отчёты
  ShowTimeStatistics(TI.TotalSize, S.Passed);
  ShowVerifyReport(VI);
  // Завершаем работу
  S.Free;
  Catalog.Free;
end;

//======================================================================================================================
//======================================================================================================================
//======================================================================================================================

function CheckDirectoryExists(const Dir: String; const Msg1: String): Boolean;
begin
  if TDirectory.Exists(Dir) then exit(TRUE);
  //
  // Output
  Console.Write(Msg1 + ' directory ');
  Console.WriteFileName(ATTR_FILE, Dir);
  Console.Write(' is ');
  Console.Write(ATTR_ERROR, 'not exists');
  Console.WritePointLn;
  // Log
  Log.AddText('FAIL: ' + Msg1 + ' directory is not exists');
  result := FALSE;
end;

procedure InitializeLog;
begin
  Log := TLog.Create(Parameters.LogPath,  // BasePath
                     '',                  // FileNameSuffix
                     TRUE);               // PrintDateTime
  Log.AddPart;
  Log.AddText('PROGRAM: ' + Version.ProgramName);
  Log.AddText('VERSION: ' + Version.Version);
  Log.AddText('RUN AT: "' + Version.ProgramExecutable + '"');
  if Parameters.SameFolders then
  begin
    Log.AddText('FILES AND CHECKSUMS DIRECTORY: "' + Parameters.FilesPath + '"');
  end else
  begin
    Log.AddText('FILES DIRECTORY: "' + Parameters.FilesPath + '"');
    Log.AddText('CHECKSUMS DIRECTORY: "' + Parameters.ChecksumPath + '"');
  end;
  Parameters.LogParameters;
end;

function DoWork: Boolean;
var
  Files: TStringList;
  r1, r2: Boolean;
begin
  InitializeLog;
  //
  Console.WriteLn;
  ShowParametersDirectories;
  //
  r1 := CheckDirectoryExists(Parameters.FilesPath, 'Files');
  r2 := CheckDirectoryExists(Parameters.ChecksumPath, 'Checksums');
  result := r1 AND r2;
  if NOT result then
  begin
    Log.Free;
    Exit;
  end;

{ DONE :Сделать тут рекурсивный поиск MD5 файлов
(чтобы проверять сразу все контрольные суммы
во всех подкаталогах). А переключатель этого
в командной строке должен быть. Типа -recursive (-r) }

  { Выбираем режим работы автоматически (пока так):
    1) если в каталоге нет файлов *.md5, режим "создание"
    2) если в каталоге есть файлы *.md5, режим "проверка" }

  // Смотрим, не нужно ли определить команду???
  if Parameters.Command = CMD_EMPTY then
  begin
    Files := FindFilesEx(Parameters.ChecksumPath,   // StartPath
                         DEFAULT_CHECKSUM_PATTERN,  // Pattern
                         [ffoptRemoveStartPath],    // Options
                         nil,                       // StatProc
                         0);                        // StatUpdateInterval
    if Files.Count = 0 then Parameters.Command := CMD_CREATE
                       else Parameters.Command := CMD_VERIFY;
    Files.Free;
  end;
  //
{ DONE : Ещё неплохо бы: при проверке сканировать список файлов,
и сравнить его со списков файлов в md5 файле. А потом вывести
информацию о файлах, которые есть в каталогах, но их нет
в файле с контрольными суммами.}
{ DONE : неактуально! При рекурсивном поиска *.md5 базовый путь извлекается из пути к *.md5 файлу }

  case Parameters.Command of

    CMD_CREATE: DoCreateMD5; // создание

    CMD_VERIFY: DoVerifyMD5; // проверка

    CMD_HELP: Parameters.PrintHelp(FALSE);

    CMD_LONGHELP: Parameters.PrintHelp(TRUE);
  end;
  //
  Log.Free;
  Result := TRUE;
end;

procedure Title;
begin
  Console.Write(ATTR_HIGHLIGHT, Version.ProgramName);
  Console.Write(' * by ' + Version.CompanyName + {' ' + Version.Comments +} ' * ');
  Console.Write('(v' + Version.Version + ')');
  Console.WriteLn;
  Console.Write(StringOfChar('‾', Version.ProgramName.Length));
{$IFDEF SPECIAL_FAST_MODE}
  Console.WriteLn;
  Console.Write(ATTR_ERROR, 'SPECIAL FAST MODE ACTIVATED');
{$ENDIF}
end;

//function FindInArrayByName(const Name: String; Clazz: TClazz; NotFoundValue: Integer): Integer;
//var
//  i, Count, Index: Integer;
//  NameTemp: String;
//begin
//  // Если в начале есть "-", опускаем его.
//  if Name.StartsWith('-') then NameTemp := Name.Substring(1)
//                          else NameTemp := Name;
//  Count := 0;
//  Index := -1;
//  // Поиск Cmd в массиве CommandArray
//  for i:=Low(Options) to High(Options) do
//  begin
//    if (Clazz=CLS_ANY) OR (Clazz=Options[i].Clazz) then
//    begin
//      if CompareText(NameTemp, Options[i].Name.Substring(0, NameTemp.Length))=0 then
//      begin
//        Inc(Count);
//        if Count = 1 then Index := i;
//      end;
//    end;
//  end;
//  if Count <> 1 then Exit(NotFoundValue);
//  Result := Options[Index].Value;
//end;

procedure Prepare;
begin
  //
  GetVersion(Version);
end;


// Параметры DEBUG запуска:
// Базовый каталог: Y:\Data1\Операционные системы\ОПЕРАЦИОННЫЕ СИСТЕМЫ (lesk)\
//     (здесь файлы, md5 которых нужно вычислить)
// Рабочий каталог: Y:\Projects\!RAD Studio\md5\WORK_FOLDER
//     (здесь хранится файл с контрольными суммами)

{$REGION 'tests'}
//procedure T1;
//var
//  S: TProgressMessage;
//  i: Integer;
//begin
//  S := TProgressMessage.Create(
//     procedure(var Info: TProgressMessageParameters)
//     begin
//       Console.Write(Info[0]);
//       Console.Write(' = ');
//       Console.Write(Info[1]);
//     end, 1500);
//  S.Params[0] := 'check progress message';
//  for i := 1 to 1000000 do
//  begin
//    S.Params[1] := 1;
//    S.Show(TProgressMessageShowMode.smFORCE);
//
//    S.Params[1] := 1000000;
//    S.Show(TProgressMessageShowMode.smFORCE);
//  end;
//  S.Free;
//end;


//procedure T2;
//var
//  r: TRegEx;
//begin
//  r := TRegEx.Create('^.*\.md5$', [TRegExOption.roIgnoreCase, TRegExOption.roCompiled]);
//  writeln(  r.IsMatch('checksums.md5')  );
//
//
//  r := TRegEx.Create('.*', [TRegExOption.roIgnoreCase, TRegExOption.roCompiled, TRegExOption.roSingleLine]);
//  writeln(  r.IsMatch('flkmf') );
//
//end;

//procedure t3;
//var
//  fl: tfilelist;
//  flc: tstringlist;
//  prev: string;
//  cur: string;
//  i: integer;
//  len: integer;
//  count: integer;
//  j: integer;
//begin
//  fl := FindFiles2('d:\video0', '.*', [TFindFiles2Option.ffoptRecursive]);
//  fl.Sort;
//  writeln( 'FindFiles2: found ', fl.Count, ' files');
//  fl.SaveToFile('d:\video0.catalog.FindFiles2.txt', TEncoding.UTF8);
//
//  flc := tfilelist.Create;
//  prev := '';
//  for i := 0 to fl.Count-1 do
//  begin
//    cur := fl[i];
//    len := length(prev);
//    if length(cur) < len then len := length(cur);
//    //
//    count := 0;
//    for j := 1 to len do
//    begin
//      if prev[j] = cur[j] then inc(count) else break;
//    end;
//    //
//    flc.Add(inttostr(count) + '~' + cur.Substring(count));
//    prev := cur;
//  end;
//  flc.SaveToFile('d:\video0.catalog.compressed.txt');
//  flc.Free;
//
//  fl.Free;
//
//  //==========================
//
//  fl := FindFiles('d:\video0', '.*', TRUE);
//  fl.Sort;
//  writeln( 'FindFiles: found ', fl.Count, ' files');
//  fl.SaveToFile('d:\video0.catalog.FindFiles.txt', TEncoding.UTF8);
//  fl.Free;
//
//end;

//procedure T4;
//var
//  a, b, c: Variant;
//begin
//  a := '3';
//  b := 1000000;
//
//  c := a*b;
//
//
//end;
{$ENDREGION}

//procedure t1;
//var
//  FL: TFileList;
//  S: String;
//  id: Integer;
//begin
//  FL := FindFilesEx('Y:\_FILE_LIST_\TEMP_CATALOG1', '', [ffoptRecursive, ffoptAddFileChar, ffoptSort]);
//  id := 1;
//  for S in FL do
//  begin
//    writeln(id, ') ', S);
//    inc(id);
//  end;
//  FL.Free;
//
//  halt;
//end;

//procedure t1;
//var
//  Cat: TChecksumCatalog;
//  i: Integer;
//  id: integer;
//  t: TChecksumCatalogItem;
//begin
//  Cat := TChecksumCatalog.Create('Y:\_FILE_LIST_\_OPEN_CATALOG_TEST_(SEPARATE)_\checksumfile',
//                                 'Y:\_FILE_LIST_\_OPEN_CATALOG_TEST_(SEPARATE)_\datafile');
//  Cat.OpenCatalog(TRUE, nil);
//
//  writeln('regular files:');
//  id:=1;
//  for i := 0 to Cat.FilesCount-1 do
//  begin
//    t := Cat.Files[i];
//    if NOT (cciNotFound in t.Status) then
//    begin
//      writeln(id,') ',t.FullFileName);
//      inc(id);
//    end;
//  end;
//
//  writeln('new files:');
//  id:=1;
//  for i := 0 to Cat.NewFiles.Count-1 do
//  begin
//    writeln(id,') ', Cat.NewFiles[i]);
//  end;
//
//  writeln('not found files:');
//  id:=1;
//  for i := 0 to Cat.NotFoundFiles.Count-1 do
//  begin
//    write(id,') ', Cat.NotFoundFiles[i]);
//    t := TChecksumCatalogItem(Cat.NotFoundFiles.Objects[i]);
//    writeln(', [', FormatMessage(t.LastError), ']');
//  end;
//
//  Cat.Free;
//end;

//========== procedure MD5.Main() ==========
begin
//  t1;
//  ReportMemoryLeaksOnShutdown := TRUE;
//  halt;


//  writeln(  Format('===%-*s===', [20, '1']) );

  // Разобрать командную строку
  Parameters.Parse;

  // Подготовить переменные
  Prepare;

  // Основная программа начинается тут
  Title;
  if Parameters.ErrorMessage <> '' then
  begin
    Parameters.PrintHelp(FALSE);
  end else
  begin
    DoWork;
  end;

  // check memory leak
  ReportMemoryLeaksOnShutdown := TRUE;
end.

