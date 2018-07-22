unit MD5.Globals;
// ���������� ����������.

interface

uses
  MD5.Logs,
  MD5.Console,
  MD5.Version;

const
  ATTR_STATNUMBER  =  $000B; // ����� � ����������
  ATTR_STATPERCENT =  $000D; // ������� � ����������

  ATTR_HIGHLIGHT   =  $000F; // ������ ���������
  ATTR_NUMBER      =  $000F; // �����
  ATTR_FILE        =  $0006; // ����/����
  ATTR_ERROR       =  $000C; // ������
  ATTR_OK          =  $000A; // ���_������
  ATTR_WORKMODE    =  $000F; // ����� ������ ���������

type
  TOptions = record
    _WorkPath: String;   // ������� �������, ��� �������� MD5 �����
    _BasePath: String;   // ������� �������, � �������
    LogPath: String;    // ������� � ���-�������
    SpecialMode: Boolean;
    Recursive: Boolean; // ����������� ����� *.md5 ������
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

