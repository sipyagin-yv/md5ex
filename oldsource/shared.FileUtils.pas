///// <summary>
/////   ������� ���� ����� �, ���� ����������, ��������� ���������� � ���.
///// </summary>
/////
/////  <param name="StartPath">� ����� �������� ���������� �����.</param>
/////
/////  <param name="Pattern">������ ������. ��� ������� ����������
/////  �������� "���������� ���������".</param>
/////
/////  <param name="Recursive">=TRUE, ����� �� ���� ������������.
/////  =FALSE, ������ ������ � �������� StartPath.</param>
/////
/////  <param name="AddInfo">=TRUE, �������� ���������� � �����
/////  (������, ��������, �����: ��������, �����������, �������). ��� ������������
/////  ��. <see cref="shared.FileUtils.TFindFileInfo"/></param>
/////
/////  <param name="RemoveStartPath">=TRUE, �� ����� ���������� �����
/////  ��������� ��������� �������.</param>
/////
/////  <param name="StatProc">��������������. �� ��������� = nil. ��������� ���
/////  ���������� ��������� ��������. ��� ������������ - �������� ��������
/////  ������ <see cref="shared.ProgressMessage.TProgressMessage"/>.
/////  </param>
/////
/////  <param name="StatUpdateInterval">��������������. �������� �� ��������� = 1500.
/////  �����, ����� ������� ����� �������� ������� StatProc.</param>
/////
/////  <returns>
/////  ������� ���������� ������ ��� ������, � ������� <see cref="System.SysUtils.TStringList"/>.
/////  </returns>
/////
/////  <remarks>������������� �������� StatUpdateInterval = 1000-1500.</remarks>
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
//���������� part1 � part2, �.�. ��������� ������ ( ���� + '*' ) ����������.
//� � ������� ������ ����� ���������� 2 ����: ������ ������ - �����, ������ ������ - ��������
//===����������}
//
//  // ��������: � ����� � ���� ��� ������������ ����������� ������� ?
//  if TPath.IsExtendedPrefixed(CurrentPath) then
//    FF := FindFirstFileW( PChar(CurrentPath + ALL_FILES_MSDOSMASK), WS)
//  else
//    FF := FindFirstFileW( PChar(EXTENDED_PATH_PREFIX + CurrentPath + ALL_FILES_MSDOSMASK), WS);
//  if FF <> INVALID_HANDLE_VALUE then
//  begin
//    repeat
//      // ������������ ����
//      if (WS.dwFileAttributes AND FILE_ATTRIBUTE_DIRECTORY) = 0 then
//      begin
//        // ���������� � ������ (���������� ���� ��������� ���������, �.�.
//        // ��������� ��� ����� *.md5 ������� ����� checksum.md5, checksum.md5abc)
//        // 30/10/2016 YS UPDATE: ������ ���������� ������� RegEx
//        if NOT RegEx.IsMatch(WS.cFileName) then Continue;
//        // ����� ����
//        S[0] := S[0] + 1;
//        // ��������� ���������� � �����
//        if ffoptAddInfo in Options then
//        begin
//          FileInfo := TFileCharacteristics.Create;
//          FileInfo.Attr.Assign(WS);
//        end else FileInfo := nil;
//        // ��������� ���� � �����
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
//          // ����� � ������� '.' � '..' �� �����!
//          if IsRootOrPrevCatalog(WS) then Continue;
//
//          // ����� �����
//          S[1] := S[1] + 1;
//
//          // ������������ ����� ������� ����
//          SaveLength := CurrentPath.Length;
//          CurrentPath := CurrentPath + WS.cFileName + PathDelim;
//
//          // recursive scan
//          FindHelper;
//
//          // ������������ ������ ����
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
//  // ������������� ����������
//  S := TProgressMessage.Create(StatProc, StatUpdateInterval);
//  Result := TFileList.Create;
//  Result.OwnsObjects := TRUE;
//  //
//  RegEx := TRegEx.Create(Pattern, [roIgnoreCase, roCompiled, roSingleLine]);
//  // ������� ��������� ����
//  CurrentPath := IncludeTrailingPathDelimiter(StartPath);
//  // �������!
//  S.Show(smNORMAL);
//  FindHelper;
//  S.Show(smDONE);
//  // �������������� ���������
//  //Result.Sort;
//  S.Free;
//end;

