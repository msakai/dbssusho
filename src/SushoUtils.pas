
{*******************************************************}
{                                                       }
{       Susho Component Library                         }
{                                                       }
{       Copyright (C) 1998,99 Susho(M.Sakai)            }
{                                                       }
{*******************************************************}

unit SushoUtils;

interface

uses Windows, Classes, SysUtils;

type
{ TBufferStream class }
  TBufferStream = class(TCustomMemoryStream)
  public
    constructor Create(Buffer: Pointer; Size: LongInt);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;


{ TDummyStream class }
  TDummyStream = class(TStream)
  private
    FSize, FPosition: LongInt;
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;


  TMacBinHeader = packed record
      Version       : Byte;
      FileNameLen   : Byte;
      FileName      : array[0..62] of Char;
      FileType      : array[0..3] of Char;
      Creater       : array[0..3] of Char;
      FinderFlag    : Byte;
      Reserved1     : Byte;
      WinPosX       : array[0..1] of Byte;
      WinPosY       : array[0..1] of Byte;
      FolderID      : array[0..1] of Byte;
      ProtectedFlag : Byte;
      Reserved2     : Byte;
      DataLen       : array[0..3] of Byte;
      ResLen        : array[0..3] of Byte;
      CretationTime : array[0..3] of Byte;
      UpdateTime    : array[0..3] of Byte;
      { MacBinally 2 }
      GetInfoMsgLen     : array[0..1] of Byte;
      FinderFlag2       : Byte;
      Reserved3         : array[0..13] of Byte;
      UnpackedFileLen   : array[0..3]  of Byte;
      SecondHeaderLen   : array[0..1]  of Byte;
      UpLoaderMacBinVer : Byte;
      LoaderMacBinVer   : Byte;
      CRC               : array[0..1] of Byte;
      Reserved4         : array[0..1] of Byte;
  end;

  // array[0..1] of Byte の中身は big endian の ワードです
  // array[0..3] of Byte の中身は big endian の ダブルワードです
  // Reserved は 0 で埋めて下さい。

{ 計算 }
function Bit(x: Byte): LongInt;

{ メモリ関連 }
function AddOffset(p: Pointer; Offset: LongInt): Pointer;

{ 文字列操作 }
procedure ShuffleStrings(Strings: TStrings);
function DirToPath(const Dir: string): string;
function PathToDir(const Path: string): string;
function Cut(var S: string; Index, Count: Integer): string;
procedure Split(const SubStr: string; S: string; Dest: TStrings);
procedure AnsiSplit(const SubStr: string; S: string; Dest: TStrings);

{ 飽和演算関数 }
function IntRange(X, Min, Max: Integer): Integer;
function ByteRange(X: Integer): Byte;
function WordRange(X: Integer): Word;

{ 型変換 }
function IntToComp(X: Integer): Comp;
//function CompToHex(Value: Comp; Digits: Integer): string;
function CompToStr(Value: Comp): string;

{ ファイル関連 }
// FAT32のお陰でLongIntの範囲を超える可能性があるため
// 64bit整数を使わなければならない。
// ただしDelphi3ではint64が使えないのでCompを使用
procedure DiskSpace(Path: string; var Size, FreeSize: Comp);
function DiskSize(Path: string): Comp;
function DiskFree(Path: string): Comp;
function GetLongFileName(FileName: TFileName): TFileName;
function GetShortFileName(FileName: TFileName): TFileName;

{ gdi関連 }

function CopyFont(Src: HFONT): HFONT;


implementation

{ TBufferStream class }

constructor TBufferStream.Create(Buffer: Pointer; Size: LongInt);
begin
    inherited Create;
    SetPointer(Buffer, Size);
end;

function TBufferStream.Write(const Buffer; Count: Longint): Longint;
begin
    if Position + Count > Size then
        Result := Size - Position
    else
        Result := Count;
    System.Move(Buffer, AddOffset(Memory, Position)^, Result);
    Position := Position + Count;
end;

{ TDummyStream class }

procedure TDummyStream.SetSize(NewSize: Longint);
begin
    FSize := NewSize;
end;

function TDummyStream.Read(var Buffer; Count: Longint): Longint;
begin
    FillChar(Buffer, Count, 0);
    Position := Position + Count;
    Result   := Count;
end;

function TDummyStream.Write(const Buffer; Count: Longint): Longint;
begin
    Position := Position + Count;
    Result   := Count;
end;

function TDummyStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
    case Origin of
      soFromBeginning : FPosition := Offset;
      soFromCurrent   : FPosition := FPosition + Offset;
      soFromEnd       : FPosition := FSize + Offset;
    end;
    if FPosition < 0 then
        FPosition := 0
    else if FPosition + 1 > FSize then
        Size := FPosition + 1;
    Result := FPosition;
end;

{ 計算 }

function Bit(x: Byte): LongInt;
begin
    Result := 1 shl x;
end;

{ メモリ関連 }

function AddOffset(p: Pointer; Offset: LongInt): Pointer;
begin
    Result := Pointer(LongInt(p) + Offset);
end;

{ 文字列操作 }

procedure ShuffleStrings(Strings: TStrings);
var i, j: Integer;
begin
    j := Strings.Count;
    if j > 1 then begin
        Randomize;
        Strings.BeginUpDate;
        try
            for i := 0 to j - 2 do
                Strings.Exchange(Random(j - i), j - i - 1);
        finally
            Strings.EndUpdate;
        end;
    end;
end;

function DirToPath(const Dir: string): string;
begin
   Result := Dir;
   if not IsPathDelimiter(Result, Length(Result)) then
      Result := Result + '\';
end;

function PathToDir(const Path: string): string;
begin
   Result := ExtractFileDir(DirToPath(Path));
end;

function Cut(var S: string; Index, Count: Integer): string;
begin
    Result := Copy(S, Index, Count);
    Delete(S, Index, Count);
end;

procedure Split(const SubStr: string; S: string; Dest: TStrings);
var nPos: Integer;
begin
    if not Assigned(Dest) then Exit;

    Dest.BeginUpdate;
    try
        while True do begin
            nPos := Pos(SubStr, S);
            if nPos > 0 then begin
                Dest.Add( Copy(S, 1, nPos - 1) );
                Delete(S, 1, (nPos - 1) + Length(SubStr));
            end else begin
                Dest.Add(S);
                Break;
            end;
        end;
    finally
        Dest.EndUpDate;
    end;
end;

procedure AnsiSplit(const SubStr: string; S: string; Dest: TStrings);
var nPos: Integer;
begin
    if not Assigned(Dest) then Exit;

    Dest.BeginUpdate;
    try
        while True do begin
            nPos := AnsiPos(SubStr, S);
            if nPos > 0 then begin
                Dest.Add( Copy(S, 1, nPos - 1) );
                Delete(S, 1, (nPos - 1) + Length(SubStr));
            end else begin
                Dest.Add(S);
                Break;
            end;
        end;
    finally
        Dest.EndUpDate;
    end;
end;

{ 飽和演算関数 }

function IntRange(X, Min, Max: Integer): Integer;
begin
    if X < Min then
        Result := Min
    else if X > Max then
        Result := Max
    else
        Result := X;
end;

function ByteRange(X: Integer): Byte;
begin
    if X < Low(Byte) then
        Result := Low(Byte)
    else if X > High(Byte) then
        Result := High(Byte)
    else
        Result := Byte(X);
end;

function WordRange(X: Integer): Word;
begin
    if X < Low(Word) then
        Result := Low(Word)
    else if X > High(Word) then
        Result := High(Word)
    else
        Result := Word(X);
end;

{ 型変換 }

function IntToComp(X: Integer): Comp;
begin
    Result := X;
end;

//function CompToHex(Value: Comp; Digits: Integer): string;
//begin
//end;

function CompToStr(Value: Comp): string;
begin
    Result := FormatFloat('0', Value);
end;

{ ファイル関係 }

procedure DiskSpace(Path: string; var Size, FreeSize: Comp);
var SectorsPerCluster: Integer;
    BytesPerSector: Integer;
    NumberOfFreeClusters: Integer;
    TotalNumberOfClusters: Integer;
begin
    GetDiskFreeSpace(PChar(Path), SectorsPerCluster, BytesPerSector,
      NumberOfFreeClusters, TotalNumberOfClusters);
    Size     := IntToComp(TotalNumberOfClusters) * BytesPerSector * SectorsPerCluster;
    FreeSize := IntToComp(NumberOfFreeClusters)  * BytesPerSector * SectorsPerCluster;
end;

function DiskSize(Path: string): Comp;
var Dummy: Comp;
begin
    DiskSpace(Path, Result, Dummy);
end;

function DiskFree(Path: string): Comp;
var Dummy: Comp;
begin
    DiskSpace(Path, Dummy, Result);
end;

function GetLongFileName(FileName: TFileName): TFileName;
var SearchRec: TSearchRec;
    Found: Integer;
begin
    Result := '';
    if not FileExists(FileName) then Exit;

    FileName := PathToDir(FileName);

    Found := FindFirst(FileName, faAnyFile, SearchRec);
    if Found = 0 then
        Result := SearchRec.FindData.cFileName;
    FindClose(SearchRec);

    while Found = 0 do begin
        FileName := ExtractFileDir(FileName);
        if FileName <> '' then begin
            Found := FindFirst(FileName, faAnyFile, SearchRec);
            if Found=0 then
                Result := Concat(SearchRec.FindData.cFileName, string('\'), Result);
            FindClose(SearchRec);
        end;
    end;

    Result := Concat(ExtractFileDrive(FileName), '\', Result);
end;

function GetShortFileName(FileName: TFileName): TFileName;
var SearchRec: TSearchRec;
    Found: Integer;
begin
    Result := '';
    if not FileExists(FileName) then Exit;

    FileName := PathToDir(FileName);

    Found := FindFirst(FileName, faAnyFile, SearchRec);
    if Found = 0 then
        Result := SearchRec.FindData.cAlternateFileName;
    FindClose(SearchRec);

    while Found = 0 do begin
        FileName := ExtractFileDir(FileName);
        if FileName <> '' then begin
            Found := FindFirst(FileName, faAnyFile, SearchRec);
            if Found=0 then
                Result := Concat(SearchRec.FindData.cAlternateFileName, '\', Result);
            FindClose(SearchRec);
        end;
    end;

    Result := Concat(ExtractFileDrive(FileName), '\', Result);
end;


{ gdi関連 }

function CopyFont(Src: HFONT): HFONT;
var LogFont: TLogFont;
begin
    GetObject(Src, SizeOf(LogFont), @LogFont);
    Result := CreateFontIndirect(LogFont);
end;

end.
