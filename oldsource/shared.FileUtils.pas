///// <summary>
/////   Функция ищет файлы и, если необходимо, добавляет информацию о них.
///// </summary>
/////
/////  <param name="StartPath">С этого каталога начинается поиск.</param>
/////
/////  <param name="Pattern">Шаблон поиска. Для большей информации
/////  смотрите "регулярные выражения".</param>
/////
/////  <param name="Recursive">=TRUE, поиск по всем подкаталогам.
/////  =FALSE, искать только в каталоге StartPath.</param>
/////
/////  <param name="AddInfo">=TRUE, добавить информацию о файле
/////  (размер, атрибуты, время: создания, модификации, доступа). Для подробностей
/////  см. <see cref="shared.FileUtils.TFindFileInfo"/></param>
/////
/////  <param name="RemoveStartPath">=TRUE, из имени найденного файла
/////  удаляется стартовый каталог.</param>
/////
/////  <param name="StatProc">Необязательный. По умолчанию = nil. Процедура для
/////  отобажения прогресса операции. Для подробностей - смотрите описание
/////  класса <see cref="shared.ProgressMessage.TProgressMessage"/>.
/////  </param>
/////
/////  <param name="StatUpdateInterval">Необязательный. Значение по умолчанию = 1500.
/////  Время, через которое нужно вызывать функцию StatProc.</param>
/////
/////  <returns>
/////  Функция возвращает список имён файлов, в объекте <see cref="System.SysUtils.TStringList"/>.
/////  </returns>
/////
/////  <remarks>Рекомендуется задавать StatUpdateInterval = 1000-1500.</remarks>
//function FindFiles(const StartPath: String;
//                   const Pattern: String;
//                   Options: TFindFilesOptions;
//                   StatProc: TProgressMessageProc = nil;
//                   StatUpdateInterval: Cardinal = 1500): TFileList;


//function FindFiles(const StartPath: String;
//                   const Pattern: String;
//                   Options: TFindFilesOptions;
//                   StatProc: TProgressMessageProc = nil;
//                   StatUpdateInterval: Cardinal = 1500): TFileList;
//var
//  CurrentPath: String;
//  FileInfo: TFileCharacteristics;
//  //
//  S: TProgressMessage;
//  RegEx: TRegEx;
//
//procedure FindHelper;
//var
//  FF: THandle;
//  WS: WIN32_FIND_DATA;
//  SaveLength: Integer;
//  //
//  FullFileName: String;
//begin
//{ DONE -cvery important :
//Объединить part1 и part2, т.к. сигнатуры поиска ( путь + '*' ) одинаковые.
//А в текущий момент поиск происходит 2 раза: первый проход - файлы, второй проход - каталоги
//===ИСПРАВЛЕНО}
//
//  // Проверка: а вдруг в пути уже присутствует расширенный префикс ?
//  if TPath.IsExtendedPrefixed(CurrentPath) then
//    FF := FindFirstFileW( PChar(CurrentPath + ALL_FILES_MSDOSMASK), WS)
//  else
//    FF := FindFirstFileW( PChar(EXTENDED_PATH_PREFIX + CurrentPath + ALL_FILES_MSDOSMASK), WS);
//  if FF <> INVALID_HANDLE_VALUE then
//  begin
//    repeat
//      // Обрабатываем ФАЙЛ
//      if (WS.dwFileAttributes AND FILE_ATTRIBUTE_DIRECTORY) = 0 then
//      begin
//        // Сравниваем с маской (используем нашу процедуру сравнения, т.к.
//        // системная для маски *.md5 находит файлы checksum.md5, checksum.md5abc)
//        // 30/10/2016 YS UPDATE: Теперь используем шаблоны RegEx
//        if NOT RegEx.IsMatch(WS.cFileName) then Continue;
//        // Нашли файл
//        S[0] := S[0] + 1;
//        // Добавляем информацию о файле
//        if ffoptAddInfo in Options then
//        begin
//          FileInfo := TFileCharacteristics.Create;
//          FileInfo.Attr.Assign(WS);
//        end else FileInfo := nil;
//        // Вычисляем путь к файлу
//        FullFileName := CurrentPath + WS.cFileName;
//        if ffoptRemoveStartPath in Options then FullFileName := GetLocalFileName(StartPath, FullFileName);
//        //
//        Result.AddObject(FullFileName, FileInfo);
//        //
//      end else if (WS.dwFileAttributes AND FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
//      begin
//        // Only if recursive!!!
//        if ffoptRecursive in Options then
//        begin
//          // Папки с именами '.' и '..' не нужны!
//          if IsRootOrPrevCatalog(WS) then Continue;
//
//          // Нашли папку
//          S[1] := S[1] + 1;
//
//          // Сформировать новый текущий путь
//          SaveLength := CurrentPath.Length;
//          CurrentPath := CurrentPath + WS.cFileName + PathDelim;
//
//          // recursive scan
//          FindHelper;
//
//          // Восстановить старый путь
//          SetLength(CurrentPath, SaveLength);
//        end;
//      end;
//      S.Show(smNORMAL);
//    until NOT FindNextFile( FF, WS );
//    FindClose(FF);
//  end;
//end;
//
//begin
//  // Инициализация переменных
//  S := TProgressMessage.Create(StatProc, StatUpdateInterval);
//  Result := TFileList.Create;
//  Result.OwnsObjects := TRUE;
//  //
//  RegEx := TRegEx.Create(Pattern, [roIgnoreCase, roCompiled, roSingleLine]);
//  // Готовим стартовый путь
//  CurrentPath := IncludeTrailingPathDelimiter(StartPath);
//  // Поехали!
//  S.Show(smNORMAL);
//  FindHelper;
//  S.Show(smDONE);
//  // Заключительная обработка
//  //Result.Sort;
//  S.Free;
//end;

