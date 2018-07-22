unit MD5.FileList;

INTERFACE

uses
  System.Classes,
  shared.ProgressMessage,
  shared.FileUtils;

(*
1 читаем все файлы *.md5
2 читаем строчки из каждого файла *.md5
3 генерируем список всех файлов
4 сортируем список по пути
5 ищем дубликаты. Если контрольные суммы совпадают (один и тот же файл), то пропускаем такие дубликаты
  если контрольные суммы не совпадают, информируем

  например,
  19870429817424  *readme.rus.txt
  11902890128904  *readme.rus.txt

  файл один и тот же, а контрольные суммы разные. Что делать в этом случае?

  варианты:
  1. показать различия и пропустить
  2. вычислить контрольную сумму подозрительного файла, и сравнить с контрольными суммами. Если одна из них
     всё таки совпадает, проинформировать.  А иначе - неверная контрольная сумма.

6 читаем все файлы из папки
7 сравниваем список файлов из папки и список файлов из п3. Показываем отсутствующие файлы и новые файлы
  (новые файлы нужны для вычисления контрольных сумм только этих файлов)
*)
type
  TFileListObject = class
    FileName: String;           // Путь и имя файла
    Char: TFileCharacteristics; // Характеристики файла (размер, атрибуты)
    Sums: String;               // Контрольная сумма
  end;
  //
  TFileList = class
  private
    MD5FileList: TStringList; // список файлов с контрольными суммами
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
