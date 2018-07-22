unit MD5.Version;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Windows;

type
  /// <summary>
  ///   This structure describes a file version
  /// </summary>
  TVersion = record
    Version: String;
    CompanyName: String;
    ProgramName: String;
    Comments: String;
  end;

/// <summary>
///   Retrieve a version from the executable file
/// </summary>
procedure GetVersion(var Version: TVersion);

implementation

procedure GetVersion(var Version: TVersion);
var
  Dummy: Cardinal;
  Buffer: Pointer;
  Size: Cardinal;
  //
  PInfo: Pointer;
  PFix: PVsFixedFileInfo;
  PTransl: PWordArray;
  //
  S: String;
begin
  Version.Version := '';
  Version.CompanyName := '';
  Version.ProgramName := '';
  Version.Comments := '';
  // Узнаем номер версии
  Size := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if Size > 0 then
  begin
    GetMem(Buffer, Size);
    if GetFileVersionInfo(PChar(ParamStr(0)), 0, Size, Buffer) then
    begin
      // Запрос версии
      if VerQueryValue(Buffer, '\', Pointer(PFix), Size) then
      begin
        S := IfThen((PFix^.dwFileFlags AND VS_FF_PRERELEASE) <> 0, 'b', '');
        Version.Version := Format('%d.%d.%d/%d%s',
                             [HiWord(PFix^.dwFileVersionMS),
                              LoWord(PFix^.dwFileVersionMS),
                              HiWord(PFix^.dwFileVersionLS),
                              LoWord(PFix^.dwFileVersionLS), S]);
      end;
      if VerQueryValue(Buffer, '\VarFileInfo\Translation', Pointer(PTransl), Size) then
      begin
        S := '\StringFileInfo\' + IntToHex(PTransl^[0], 4) + IntToHex(PTransl^[1], 4);
        if VerQueryValue(Buffer, PChar(S + '\ProductName'), PInfo, Size) then
          Version.ProgramName := PChar(PInfo);
        if VerQueryValue(Buffer, PChar(S + '\CompanyName'), PInfo, Size) then
          Version.CompanyName := PChar(PInfo);
        if VerQueryValue(Buffer, PChar(S + '\Comments'), PInfo, Size) then
          Version.Comments := PChar(PInfo);
      end;
    end;
    FreeMem(Buffer);
  end;
end;

end.
