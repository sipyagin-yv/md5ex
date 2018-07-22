type
  TExtractInfo = record
     Status: (eisERROR, eisOK, eisSKIP);
     MD5: String;
     LocalFileName: String;
     SourceLine: String;
  end;


///// <summary>
/////   Извлечь информацию о файле, из файла с контрольными суммами
///// </summary>
//procedure ExtractHashInfo(const SourceLine: String; out EInfo: TExtractInfo);
//var
//  Index: Integer;
//  Ch: Char;
//  S: String;
//begin
//  S := SourceLine.Trim;
//  //
//  EInfo.SourceLine := S;
//  EInfo.Status := eisERROR;
//  EInfo.MD5 := '';
//  EInfo.LocalFileName := '';
//  // Формат ДОЛЖЕН БЫТЬ такой:
//  // A) - пустая строка - пропускаем
//  // B) - строка, начинающаяся с "#" - комментарий - пропускаем
//  // C) - контрольная сумма + имя файла:
//  //      0) SPACES
//  //      1) 16 символов 0..9, a..f, A..F
//  //      2) SPACES
//  //      3) * (двоичный файл) - если есть, просто пропускаем
//  //      4) имя файла (возможно, в кавычках, если в конце имени файла пробелы)
//
//  // Пустая строка ?
//  if StringIsEmpty(S) then
//  begin
//    EInfo.Status := eisSKIP;
//    Exit;
//  end;
//
//  // Строка-комментарий ?
//  if S.StartsWith('#') then
//  begin
//    EInfo.Status := eisSKIP;
//    Exit;
//  end;
//
//  // ВНИМАНИЕ!!
//  // Если дошли до этого места, то Exit(FALSE) означает
//  // ошибку в формате имени файла!!!
//{ DONE :Обработать exit(FALSE) как ошибку форматирования
//в файле с контрольными суммами = сделан возврат статуса разбора строки в .Status }
//
//{ DONE : А если в строке будут пробелы, а затем контрольная сумма?
//=в формате md5 строгий формат, никаких пробелов.
//}
//  // Разделяем на контрольную сумму и имя файла
//  Index := S.IndexOf(' ');
//  if Index < 0 then
//  begin
//    EInfo.Status := eisERROR;
//    Exit;
//  end;
//  // Готовим имя файла
//  EInfo.LocalFileName := S.Substring(Index).TrimLeft;
//
//  // Определяем ТИП файла
//  // "*" - двоичный файл
//  // " " - текстовый файл
//  if EInfo.LocalFileName.StartsWith('*') then
//  begin
//    EInfo.LocalFileName := EInfo.LocalFileName.Substring(1);
//  end;
//  // Получаем путь к файлу (относительно BASE - локальный)
//  EInfo.LocalFileName := EInfo.LocalFileName.DequotedString.Replace('/', '\');
//  // Определяем, что за контрольная сумма используется
//  // Она отделяется от имени файла так:
//  // ?sha1*fielname.ext
//
//  // Готовим контрольную сумму
//  EInfo.MD5 := S.Substring(0, Index);
//  if Length(EInfo.MD5) <> 32 then
//  begin
//    EInfo.Status := eisERROR;
//    Exit;
//  end;
//  //
//  for Ch in EInfo.MD5 do
//  begin
//    if NOT CharInSet(Ch, ['0'..'9', 'A'..'F', 'a'..'f']) then
//    begin
//      EInfo.Status := eisERROR;
//      Exit;
//    end;
//  end;
//  //
//  EInfo.Status := eisOK;
//end;


