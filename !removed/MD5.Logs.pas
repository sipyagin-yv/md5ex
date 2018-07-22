unit MD5.Logs;

interface

uses
  MD5.Utils,
  System.Classes,
  System.SysUtils,
  System.StrUtils;

const
  LOG_FILENAME_STAMP  = 'dd-mm-yyyy@hh-nn-ss,z';
  LOG_FILENAME_PREFIX = 'log_';
  LOG_FILENAME_EXT    = '.txt';

type
  TLog = class
  private
    FStream: TStreamWriter;
    FPrintDateTime: Boolean;
  public
    constructor Create(const BasePath: String; const FileNameSuffix: String; PrintDateTime: Boolean);
    destructor Destroy; override;
    // Вывод лога
    procedure AddText(const S: String);
    procedure AddLine; overload;
    // Разграничение
    procedure AddDiv; // одинарная граница
    procedure AddPart; // двойная граница
  end;

IMPLEMENTATION

{ TLogs }

procedure TLog.AddText(const S: String);
begin
  FStream.WriteLine(S);
end;

procedure TLog.AddLine;
begin
  FStream.WriteLine;
end;


procedure TLog.AddDiv;
begin
  FStream.WriteLine(StringOfChar('.', 120));
end;

procedure TLog.AddPart;
begin
  FStream.WriteLine(StringOfChar('=', 120+9));
end;

constructor TLog.Create(const BasePath: String; const FileNameSuffix: String; PrintDateTime: Boolean);
var
  LogFileName: String;
begin
  FPrintDateTime := PrintDateTime;
 { DONE 5 -cvery important :Если два раза запустить MD5, то тут произойдет ошибка при открытии файла log.txt.
Предусмотреть log файл, в имени которого будет дата и время создания. }
  LogFileName := LOG_FILENAME_PREFIX +
                 FormatDateTime(LOG_FILENAME_STAMP, Now) +
                 IfThen(FileNameSuffix='', '', '-') +
                 FileNameSuffix +
                 LOG_FILENAME_EXT;
  inherited Create;
  FStream := TStreamWriter.Create(BasePath + LogFileName, TRUE, TEncoding.Unicode, 4096);
  if FPrintDateTime then FStream.WriteLine('Log file created at ' + CurrentDateTime);
end;

destructor TLog.Destroy;
begin
  if FPrintDateTime then
  begin
    AddDiv;
    FStream.WriteLine('Log file closed at ' + CurrentDateTime);
  end;
  AddPart;
  FStream.Free;
  inherited;
end;

end.

