unit MD5.FileList;

INTERFACE

uses
  System.Classes,
  shared.ProgressMessage,
  shared.FileUtils;

(*
1 ������ ��� ����� *.md5
2 ������ ������� �� ������� ����� *.md5
3 ���������� ������ ���� ������
4 ��������� ������ �� ����
5 ���� ���������. ���� ����������� ����� ��������� (���� � ��� �� ����), �� ���������� ����� ���������
  ���� ����������� ����� �� ���������, �����������

  ��������,
  19870429817424  *readme.rus.txt
  11902890128904  *readme.rus.txt

  ���� ���� � ��� ��, � ����������� ����� ������. ��� ������ � ���� ������?

  ��������:
  1. �������� �������� � ����������
  2. ��������� ����������� ����� ��������������� �����, � �������� � ������������ �������. ���� ���� �� ���
     �� ���� ���������, ����������������.  � ����� - �������� ����������� �����.

6 ������ ��� ����� �� �����
7 ���������� ������ ������ �� ����� � ������ ������ �� �3. ���������� ������������� ����� � ����� �����
  (����� ����� ����� ��� ���������� ����������� ���� ������ ���� ������)
*)
type
  TFileListObject = class
    FileName: String;           // ���� � ��� �����
    Char: TFileCharacteristics; // �������������� ����� (������, ��������)
    Sums: String;               // ����������� �����
  end;
  //
  TFileList = class
  private
    MD5FileList: TStringList; // ������ ������ � ������������ �������
    //
  public
    constructor Create;
    destructor Destroy; override;
    //
  end;

IMPLEMENTATION

{ TFileList }

constructor TFileList.Create;
begin
  inherited;
  SetLength(FList, 0);
end;

destructor TFileList.Destroy;
begin
  SetLength(FList, 0);
  inherited;
end;

end.
