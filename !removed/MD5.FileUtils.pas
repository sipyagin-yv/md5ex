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

  // ������ �����, ��������� � ������
  // (��� ����, ����� ������� ������ � TStringList)
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
    FStatus: DWORD;             // ��� ��������� ������ (0, ���� ��� ������)
    FHandle: THANDLE;           // ����� �����
    FSize: UInt64;              // ������ �����
    FBuffer: Pointer;           // ����� ��� ������
    FBufferSize: Cardinal;      // ������ ������ ��� ������
    // ���. � �������� ������
    FLastReaded: Cardinal;      // ��������� � ��������� ������
    FTotalReaded: UInt64;       // ��������� � ������ ������
  public
    constructor Create(const FileName: String; BufferSize: Cardinal);
    destructor Destroy; override;
    function StatusMessage: String;
    /// <summary>
    ///   ������ ��������� ������ �� �����.
    /// </summary>
    /// <returns>
    ///   ���������� TRUE, ���� ���� ���������� ��� ���������.
    ///   ����� ���������� FALSE (��������� ����� �����).
    ///   �����, � Status ������������ ������ ��������. 0 �������� - ��� ������,
    ///   ����� ������ �������� - ��� ������.
    /// </returns>
    /// <remarks>
    ///   ����� ������ ����������� ��������� Status.
    /// </remarks>
    function ReadNextBlock: Boolean;
    /// <summary>
    ///   ���������� ������ ��������� ��������. 0 �������� - ��� ������.
    ///   ����� ������ ����� - ��� ������.
    /// </summary>
    property Status: Cardinal read FStatus;
    /// <summary>
    ///   ���������� ������ ����� � ������.
    /// </summary>
    property Size: UInt64 read FSize;
    /// <summary>
    ///   ���������� ���������� ����, ����������� � ��������� ������.
    /// </summary>
    property LastReaded: Cardinal read FLastReaded;
    /// <summary>
    ///   ���������� ���������� ����, ����������� � ������ �����.
    /// </summary>
    property TotalReaded: UInt64 read FTotalReaded;
    /// <summary>
    ///   ���������� ����� ������, ���� �������� ����� �� �����.
    /// </summary>
    property Buffer: Pointer read FBuffer;
  end;

/// <summary>
///   ��������� ����� ����
/// </summary>
function ReduceFileName(const FileName: String; MaxLength: Integer): String;

/// <summary>
///   ������� ��� ���� ��� ���� BasePath.
/// </summary>
function GetVolumeName(const BasePath: String): String;

/// <summary>
///   ������� ���������� ������ ����� (�� ����� �����)
/// </summary>
/// <param name="FileName">
///   ��� �����, ��� �������� ����� ������ ������.
///   � ������� � ����� ����� ������������ Extended Prefix, '\\?\'.
/// </param>
/// <param name="FileSize">
///   ������ �� ����������, ����������� ������ �����.
/// </param>
/// <returns>
///   TRUE, ���� ������ ����� ��������� � ���������� FileSize. FALSE, ���� ��������� ������ (� FileSize ��� ���� ������������ 0).
/// </returns>
function GetFileSize(const FileName: String; out FileSize: UInt64): Boolean; overload;

/// <summary>
///   ������� ���������� ������ ����� (�� ����������� �����)
/// </summary>
/// <param name="H">
///   ���������� �����, ��� �������� ����� ������ ������.
/// </param>
/// <param name="FileSize">
///   ������ �� ����������, ����������� ������ �����.
/// </param>
/// <returns>
///   TRUE, ���� ������ ����� ��������� � ���������� FileSize. FALSE, ���� ��������� ������ (� FileSize ��� ���� ������������ 0).
/// </returns>
function GetFileSize(H: THandle; out FileSize: UInt64): Boolean; overload;


/// <summary>
///   ������� ���� ����� �, ���� ����������, ��������� ���������� � ���.
/// </summary>
///
///  <param name="StartPath">� ����� �������� ���������� �����</param>
///
///  <param name="Mask">����� ������. ������ ��� ���� ������ �����: "*".
///  �������� ����� �������������� �������� CompareMask (�� ��������!).
///  � �������� �������� FindFirstFileW ���������, ��� ��� �������
///  �� ��������� ����� "*.md5" � "*.md5file", ������� �������� ��������
///  ���� �������.</param>
///
///  <param name="Recursive">TRUE, ���� ��������� ����������� �����.
///  FALSE - ���� ����� ������ ������ � �������� StartPath.</param>
///
///  <param name="AddInfo">TRUE, ���� ���������� �������� ���������� � �����
///  (������, ��������, ����� ��������; �����������; �������).</param>
///
///  <param name="RemoveStartPath">TRUE, ���� �� ����� ���������� �����
///  ���������� ������� ��������� �������.</param>
///
///  <param name="StatProc">���������, ������� ����� ���������� ��������������
///  ����������. ��� ������������ - �������� �������� ������
///  <see cref="TScreenMessage"/>. �� ���������, �������� ��������� ����� nil.
///  </param>
///
///  <param name="StatUpdateInterval">�����, ����� ������� ����� ��������
///  ������� StatProc. �� ���������, �������� ��������� ����� 1500.</param>
///
///  <remarks>������������� ��������� �������� ����������, StatUpdateInterval,
///  � �������� 1000-1500 �����������.</remarks>
///
///  <returns>
///  ������� ���������� ������ ��� ������, � �������
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
///   ����������� ��������� �� ������ �� ������ ������.
/// </summary>
function FormatMessage(const MessageId: Integer): String;

// ������� ��� �������������� ���� � ����� �����
function GetLocalFileName(const WorkPath: String; const FileName: String): String;
function GetFullFileName(const WorkPath: String; const FileName: String): String;
function GetExtendedFileName(const FileName: String): String;

// ������� ��� ������ � �������
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
  // ��������������
  Result := Result.Trim;
  if Result.EndsWith('.') then Result := Result.Substring(0, Result.Length-1);
  Result := Format('#%x, %s', [MessageId, Result]);
end;

// ��������� �� �����
// ����������� ������� �����:
//    ? �������� ����� ���� ������
//    * �������� ����� 0 ��� ����� ��������
// �����������:
//    [a-b] ����� ������ �� ��������� a-b, �������� [a-f] - ������� a,b,c,d,e,f
//    [~a-b] ����� ������ ����� ������� �� ��������� a-b, �������� [~a] - ����� ������, ����� a
//    [abcd] ����� ������ �� ������, �������� [!@#] - ������� !, @, #
//    [~abcd] ����� ������, ����� �������� �� ������, �������� [~!] - ����� ������, ����� !
//    () - �����������, | - ���, & - �, �������� ([a-b]|[x-z])
//    
// �����������:
//    CompareMask('',''));              = true
//    CompareMask('', '*'));            = true
//    CompareMask('some', ''));         = false
//    CompareMask('filename', '*'));    = true
//    CompareMask('abc', 'def'));       = false
function CompareMask(Name, Mask: PChar): Boolean;
// �������� ���������� ����� ��������� ����� ������.
// � ��������� ������, ��������� �������� ��������� ���������� - ��������,
// � ��������� Name, Mask ����� ������������. � ����������� ��� ����
// ����������� ��������� - ������������, ������� ����� ��������
// ��������������� � ���������.
begin
  repeat
    // �������� �� ����� ���������
    if (Name^ = MASK_END_OF_STRING) AND
       (Mask^ = MASK_END_OF_STRING) then Exit(TRUE);
    // ����������� ������ �����
         if Mask^ = MASK_CHAR_ANY then
    else if Mask^ = MASK_CHAR_ZERO_OF_MANY then
    begin
      // ���������� 0 ��� ����� �������� � Name, � ���������� � ������
      Inc(Mask);
      // ����������� (���� ����� '*' ��� ������ #0 - ������ ����� �� ����������)
      if Mask^ = MASK_END_OF_STRING then Exit(TRUE);
      // ��������� ����� �������� �� �����, � ��
      // ���������� � Name 0 ��� ����� ��������
      repeat
        if CompareMask(Name, Mask) then Exit(TRUE);
        Inc(Name);
        if (Name^ = MASK_END_OF_STRING) then Exit(FALSE);
      until FALSE;
      // ������ �������� ���!
    end else
    begin
      // ���������� ������� ����� � ������
      if NOT CompareChar(Name^, Mask^) then Exit(FALSE);
    end;
    // ��������� � ��������� �������� ����� � ������
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
���������� part1 � part2, �.�. ��������� ������ ( ���� + '*' ) ����������.
� � ������� ������ ����� ���������� 2 ����: ������ ������ - �����, ������ ������ - ��������
===����������}
  FF := FindFirstFileW( PChar(EXTENDED_PATH_PREFIX + CurrentPath + ALL_FILES_MASK), WS);
  if FF <> INVALID_HANDLE_VALUE then
  begin
    repeat
      // ������������ ����
      if (WS.dwFileAttributes AND FILE_ATTRIBUTE_DIRECTORY) = 0 then
      begin
        // ���������� � ������ (���������� ���� ��������� ���������, �.�.
        // ��������� ��� ����� *.md5 ������� ����� checksum.md5, checksum.md5abc)
        if Mask.Length > 0 then
        begin
          if NOT CompareMask(WS.cFileName, Mask) then Continue;
        end;
        // ����� ����
        S[0] := S[0] + 1;
//        Inc(StatInfo.FilesFound);
        // ��������� ���������� � �����
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
          // ����� � ������� '.' � '..' �� �����!
          if (StrComp(WS.cFileName, SKIP_FOLDER_NAME_1) = 0) OR
             (StrComp(WS.cFileName, SKIP_FOLDER_NAME_2) = 0) then Continue;
          // ����� �����
          S[1] := S[1] + 1;
//          Inc(StatInfo.FoldersFound);
          // ������������ ����� ������� ����
          CurrentPath := CurrentPath + WS.cFileName + PathDelim;
          // recursive scan
          FindHelper;
          // ������������ ������
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
  // ������������� ����������
  //StatTick := 0;
  //T := TTimer.Create;
  S := TScreenMessage.Create(StatProc, StatUpdateInterval);
  Result := TStringList.Create;
  Result.OwnsObjects := TRUE;
//  FillChar(StatInfo, sizeof(StatInfo), 0);
  // ������� ��������� ����
  CurrentPath := IncludeTrailingPathDelimiter(StartPath);
  // �������!
  S.Show(smNORMAL);
//  StatHelper(FALSE);
  FindHelper;
  S.Show(smDONE);
//  StatHelper(TRUE);
  // �������������� ���������
  //Result.Sort;
//  T.Free;
  S.Free;
end;

function GetFullFileName(const WorkPath: String; const FileName: String): String;
// ������� ���������� ������ ���� ����� FileName
// (������� ����������� WorkPath, ���� �� �� ����� ������ ������,
// � ���� ������, ������� ������� �����)
begin
  Result := IncludeTrailingPathDelimiter( WorkPath ) + FileName;
end;

// ������� "����������" �� ������� ���� � ����� ������� ����
// � ������� ���������� ������ ���� �������, �� ����� ������������:
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
  // ��������� ������� �������������� � ������� �������
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
  // ���������, ��� ���� �������� ����������� 1..MAX_PATH,
  // �� ������� Result := Buffer1 ���������� �������������
  // ����� Buffer1 ��� ASCII-Z ������.
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
  // ������ �����
  FSize := MakeUInt64(WS.nFileSizeLow, WS.nFileSizeHigh);

(*
  // !!! ������� ������������� !!!
  FSize := $ffffffffffffffff;         // �������� ���������
  TFileSize(FSize).Lo := 1;           // FSize �� ����������!
  TFileSize(FSize).Hi := 1;           // FSize �� ����������!
*)

  // ��������
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
  // ���� �� �������� - ������
  if FHandle = INVALID_HANDLE_VALUE then
  begin
    // store error code
    FStatus := GetLastError;
    FHandle := INVALID_HANDLE_VALUE;
  end else
  begin
    // ���� ��������, ������ ��������� ��� ������
    if NOT GetFileSize(FHandle, FSize) then
    begin
      // �������� ������ ����� �� ������� - ������
      FStatus := GetLastError;
      CloseHandle(FHandle);
      FHandle := INVALID_HANDLE_VALUE;
    end else
    begin
      // all ok, file opened, and we get's it size
      FBufferSize := BufferSize;
      FStatus := 0;
      // �������� �������� ����� ��� �����
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
  // �������� �� ���������� ����� �����
  if FSize - FTotalReaded = 0 then Exit(FALSE);
  // ��������� ������ ��������� ������ ��� ������
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
  // ������ ����
  Result := Windows.ReadFile(FHandle,     // hFile
                             FBuffer^,    // lpBuffer
                             R,           // nNumberOfBytesToRead
                             Readed,      // lpNumberOfBytesRead
                             nil);        // lpOverlapped
{$ENDIF}
  // ��������� ������, ���� ������ ��� ������
  if NOT Result then
  begin
    FStatus := GetLastError;
    Exit(TRUE);
  end;
  // ��������� ������, ���� ��������� �� �������, ������� �������
  if Readed <> R then
  begin
    FStatus := SFR_READINCORRECT;
    Exit(TRUE);
  end;
  // �����, ��� ������
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
// �������� ��������� ����:
// "\\������\share\����\����" - ���������� �������� � "����\����"
// "C:\����\���" - ���������� �������� � "����\����"
// ���� ���� ���������� � "\\?\", ��� ����� ("\\?\") ����� ������
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
  // ������ �������� �����
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
      // ��������: FileName ��� ���� � ������ �����
      // (����� �����) ":" "\"
      if BeginsWithDrive(Result) then
      begin
        IndexStart := 4;
      end;
      //
      IndexRemove := IndexStart + (Result.Length - MaxLength + SUBST_CHARS.Length);
      if IndexRemove >= IndexEnd then
      begin
        // ������� �������� IndexStart �� ������
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

