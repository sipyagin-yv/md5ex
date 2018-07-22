unit MD5.Hash;

interface

uses
  System.SysUtils,
  shared.Utils;

type
  PMD5Digest = ^TMD5Digest;
  TMD5Digest = record
    case byte of
      0: (A, B, C, D: Cardinal);
      1: (V: array[0..15] of Byte);
      2: (W: array[0..3] of Cardinal);
  end;
  //
  TMD5Hash = class
  private
    FDigest: TMD5Digest;
    FLength: UInt64;
    FIndex: Integer;
    FBuffer: packed array[0..63] of Byte;
    FInternalBufferUsed: UInt64;
    procedure UpdateBuffer(Buffer: PByte);
  public
    constructor Create;
    procedure Update(Buffer: PByte; BufferLength: Cardinal);
    function Done: String;
    //
    class function GetFitBlockSize(Size: Cardinal): Cardinal; inline;
    property InternalBufferUsed: UInt64 read FInternalBufferUsed;
  end;

//const
//  Padding: array[0..15] of Cardinal = // 64 ����� ( sizeof(Cardinal) * 16 = 64 )
//  ($80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

procedure MD5UpdateFastSwapp_FASM(P: Pointer; State: PMD5Digest); register; external;
{$IFDEF CPUX86}
  {$L md5_swapp_fasm.obj}
{$ENDIF}
{$IFDEF CPUX64}
  {$L md5_swapp_fasm_x64.obj}
{$ENDIF}

implementation

constructor TMD5Hash.Create;
begin
  inherited;
  with FDigest do
  begin
    A := $67452301;
    B := $EFCDAB89;
    C := $98BADCFE;
    D := $10325476;
  end;
  FLength := 0; // ����� �����
  FIndex := 0; // �� ������� �������� �����
  FInternalBufferUsed := 0;
end;

procedure TMD5Hash.UpdateBuffer(Buffer: PByte);
begin
  MD5UpdateFastSwapp_FASM(Buffer, @FDigest);
  FIndex := 0;
end;

procedure TMD5Hash.Update(Buffer: PByte; BufferLength: Cardinal);
// ����������� ����� ��������� ������� �� 64 �����
var
  T: Cardinal;
begin
  // ��������� ����� ���������
  Inc(FLength, BufferLength);
  // ���� �� ������?
  while BufferLength > 0 do
  begin
    if (FIndex = 0) AND (BufferLength >= 64) then
    begin
      // ����� ���� ����, � � ��� ���������� ������ ��� ���������
      UpdateBuffer(Buffer);
      Dec(BufferLength, 64);
      Inc(Buffer, 64);
    end else
    begin
      Inc(FInternalBufferUsed);
      // ��������� �����
      T := 64-FIndex;
      if T > BufferLength then T := BufferLength;
      Move(Buffer^, FBuffer[FIndex], T);
      // ������������� ����������
      Dec(BufferLength, T);
      Inc(FIndex, T);
      Inc(Buffer, T);
      // ��������� ������, ���� ����� ��������
      if FIndex=64 then UpdateBuffer(@FBuffer);
    end;
  end;
end;

function TMD5Hash.Done: String;
var
  L: UInt64;
  i: Integer;
begin
  // ����� ���� 1
  FBuffer[FIndex] := $80;
  Inc(FIndex);
  if FIndex = 64 then UpdateBuffer(@FBuffer);
  // ���������� ������ ������, ���� �� ��������� � ����� 8 ���� (��� L)
  while FIndex <> 64-8 do
  begin
    FBuffer[FIndex] := 0;
    Inc(FIndex);
    if FIndex = 64 then UpdateBuffer(@FBuffer);
  end;
  // ����� ������� ����� � �����
  L := FLength SHL 3;
  Update( @L, 8 );
  //
  Result := '';
  for i := Low(FDigest.V) to High(FDigest.V) do
  begin
    Result := Result + ByteToHex(FDigest.V[i]);
  end;
end;

class function TMD5Hash.GetFitBlockSize(Size: Cardinal): Cardinal;
begin
  // ��������� ������ �����, ����� �� ������� ������ �� 64
  // �.�. ����� ������� 6 ��� ���� ����� 0.
  Result := (Size + 64) AND (NOT $3F);
end;

end.

