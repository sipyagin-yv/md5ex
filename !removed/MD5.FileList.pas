unit MD5.FileList;
// ��� ������ ����� FileList
//  1.������� � ���� ������ ������ ������ �� ���������� ���������
//    (� ����� ��� �������� �����: ������, ��������, ����� ��������, ������� � ��������� ������)
//  2.����� ���������� ���� � ���� ����������� ���� (�������� � ������������ �������)
//  3.����� ������ ���� �� ����� ����������� ���� (�������� � ������������ �������)
//  4.����� ���������� ���� � ������� �������� (��� ��������� "�����" � "�������������" ������)
//  5.����� ���������� ���� � ������� �������� (�� �����, ����������� ������, ���������, �����
//    �������� ����� ��������������/����������� ������)
//  6.

interface

//uses
//  System.SysUtils,
//  System.Classes,
//  Windows;
//
//const
//  ALL_FILES_MASK        =  '*';            // NOT *.* !!!
//  EXTENDED_PATH_PREFIX  =  '\\?\';
//  SKIP_FOLDER_NAME_1    =  '.';
//  SKIP_FOLDER_NAME_2    =  '..';
//  // for MatchMask
//  MASK_CHAR_ZERO_OF_MANY =  '*';
//  MASK_CHAR_ANY          =  '?';
//  MASK_END_OF_STRING     =  #0;
//
//type
//  TFileListInfo = class
//    Size: UInt64;
//    Attributes: Cardinal;
//    CreationTime: TFileTime;
//    LastAccessTime: TFileTime;
//    LastWriteTime: TFileTime;
//    //
//    FolderIndex: Integer;
//  end;
//
//  TFileList = class
//  private
//    FFolders: TStringList;
//    FFiles: TStringList;
//    //
//    function AddRecord: Integer;
//    procedure ScanFolders(const BasePath: String);
//  public
//    constructor Create;
//    destructor Destroy; override;
//    /// <summary>
//    ///   Scan files, starts from BasePath.
//    /// </summary>
//    procedure ScanFiles(const BasePath: String; Recursive: Boolean);
//    /// <summary>
//    ///   Add file information into list. Check file exist, and get it size,
//    ///   attributes and time.
//    /// </summary>
//    /// <param name="FileName">
//    ///   File name to add to list.
//    /// </param>
//    /// <returns>
//    ///   Return index, if file has been added, otherwise -1 (file or path not exist)
//    /// </returns>
//    function AddFile(const FileName: String): Integer;
//    /// <summary>
//    ///   Add folder information.
//    /// </summary>
//    /// <returns>
//    ///   Return folder index.
//    /// </returns>
//    function AddFolder(const FileFolder: String): Integer;
//  end;
//
//implementation
//
//{ TFileList }
//
//function TFileList.AddFile(const FileName: String): Integer;
//var
//  WS: TWin32FindDataW;
//  H: THandle;
//  Index: Integer;
//begin
//  H := FindFirstFileW(PChar( EXTENDED_PATH_PREFIX + FileName ), WS);
//  if H <> INVALID_HANDLE_VALUE then
//  begin
//    Index := AddRecord;
//    FFiles[Index].Size := MakeUInt64(WS.nFileSizeLow, WS.nFileSizeHigh);
//    FFiles[Index].Attributes := WS.dwFileAttributes;
//    FFiles[Index].CreationTime := WS.ftCreationTime;
//    FFiles[Index].LastAccessTime := WS.ftLastAccessTime;
//    FFiles[Index].LastWriteTime := WS.ftLastWriteTime;
//    FFiles[Index].FolderIndex := AddFolder(ExtractFilePath(FileName));
//    FFiles[Index].FileName := ExtractFileName(FileName);
//    FindClose(H);
//    Result := Index;
//  end else
//  begin
//    Result := -1;
//  end;
//end;
//
//function TFileList.AddFolder(const FileFolder: String): Integer;
//var
//  Index: Integer;
//begin
//  if FFolders.Find(FileFolder, Index) then Exit(Index);
//  Result := FFolders.Add(FileFolder);
//end;
//
//function TFileList.AddRecord: Integer;
//begin
//  if FFilesIndex >= Length(FFiles) then
//  begin
//    SetLength(FFiles, Length(FFiles) + 100);
//  end;
//  Result := FFilesIndex;
//  Inc(FFilesIndex);
//end;
//
//constructor TFileList.Create;
//begin
//  FFolders := TStringList.Create;
//  FFolders.Sorted := TRUE;
//  FFolders.Duplicates := dupIgnore;
//  FFolders.OwnsObjects := TRUE;
//  //
//  FFiles := TStringList.Create;
//  FFiles.Sorted := TRUE;
//  FFiles.Duplicates := dupAccept;
//  FFiles.OwnsObjects := TRUE;
//end;
//
//destructor TFileList.Destroy;
//begin
//  FFolders.Free;
//  FFiles.Free;
//end;
//
//procedure TFileList.ScanFiles(const BasePath: String; Recursive: Boolean);
//begin
//
//end;

IMPLEMENTATION

end.
