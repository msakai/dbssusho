unit Artistic;

interface

uses Windows, SushoUtils, PlugIf, Dibas_Classes, Filters, Paint, NkDib;

type
  TDotPaint = class(TFilter)
  private
      FAveragePaint: TAveragePaint;
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  public
      constructor Create; override;
      destructor Destroy; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  end;


  TReliefFilter = class(TFilter)
  private
      FStrength: Integer;
      FEmboss: Boolean;
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Strength: Integer read FStrength write FStrength;
      property Emboss: Boolean read FEmboss write FEmboss;
  end;


implementation


constructor TDotPaint.Create;
begin
    inherited;
    FAveragePaint := TAveragePaint.Create;
end;

destructor TDotPaint.Destroy;
begin
    FAveragePaint.Free;
    inherited;
end;

procedure TDotPaint.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_VISUAL;
    Exclude(Info.Flags, ffUsePen);
end;

function TDotPaint.DoApply(const Arg: TFilterArg): Integer;
const
    DotSize = 7;
var Arg2: TFilterArg;
    MaskDib, BuffDib: TNkDib;
    MaskScanLines: PScanLines;
    BuffScanlines: PScanLines;
    i, x, y: Integer;
    x1, y1: Integer;
    lpIn, lpOut: PRGBTriple;
    lpMask: PByte;
    total: Word;
    MaskCenterX, MaskCenterY: Double;
    MaskRadius: Double;
    d: Double;
begin
    Arg2 := Arg;
    Arg2.Abortfunc := DummyAbortFunc;
    inherited DoApply(Arg2);

    MaskDib := TNkDib.Create;
    BuffDib := TNkDib.Create;
    try
        BuffDib.Height := DotSize;
        BuffDib.Width  := DotSize;
        BuffDib.BitCount := 24;
        MaskDib.Height := DotSize;
        MaskDib.Width := DotSize;
        MaskDib.BitCount := 8;
        MaskDib.PaletteSize := 256;
        for i := 0 to 255 do begin
            MaskDib.Colors[i] := RGB(i, i, i);
        end;

        MaskCenterX := MaskDib.Width / 2;
        MaskCenterY := MaskDib.Height / 2;
        MaskRadius := DotSize / 2;
        for y := 0 to MaskDib.Height - 1 do begin
            lpMask := MaskDib.ScanLine[y];
            for x := 0 to MaskDib.Width - 1 do begin
                d := Sqrt(Sqr(x - MaskCenterX) + Sqr(y - MaskCenterY));
                if d > MaskRadius + 1 then
                    lpMask^ := 0
                else if d > MaskRadius then
                    lpMask^ := Round(255 * (1 - (d - MaskRadius)))
                else
                    lpMask^ := 255;
                Inc(lpMask);
            end;
        end;

        GetMem(MaskScanLines, SizeOf(Pointer) * MaskDib.Height);
        GetMem(BuffScanLines, SizeOf(Pointer) * BuffDib.Height);
        try
            for y := 0 to MaskDib.Height - 1 do begin
                MaskScanLines[y] := MaskDib.ScanLine[y];
                BuffScanLines[y] := BuffDib.ScanLine[y];
            end;
            Arg2 := Arg;
            Arg2.Abortfunc := DummyAbortFunc;
            Arg2.mask := MaskScanLines;
            Arg2.outData := BuffScanLines;
            Arg2.cxData := BuffDib.Width;
            Arg2.cyData := BuffDib.Height;

            Randomize;
            Total := Round(10 * Arg.cxData * Arg.cyData / Sqr(DotSize));
            for i := 0 to Total do begin
                if Arg.Abortfunc(i, Total) <> FTR_OK then begin
                    Result := FTR_CANCEL;
                    Exit;
                end;
                x1 := Random(Arg.cxData + 1 - DotSize);
                y1 := Random(Arg.cyData + 1 - DotSize);
                Arg2.xIndata := Arg.xInData + x1;
                Arg2.yIndata := Arg.yInData + y1;
                FAveragePaint.Apply(Arg2);
                for y := 0 to BuffDib.Height - 1 do begin
                    lpIn := BuffDib.ScanLine[y];
                    lpMask := MaskDib.ScanLine[y];
                    lpOut := PRGBTriple(Arg.outData[y + y1]);
                    Inc(lpOut, x1);
                    for x := 0 to BuffDib.Width - 1 do begin
                        lpOut.R := (lpIn.R * lpMask^ + lpOut.R * (255 - lpMask^)) div 255;
                        lpOut.G := (lpIn.G * lpMask^ + lpOut.G * (255 - lpMask^)) div 255;
                        lpOut.B := (lpIn.B * lpMask^ + lpOut.B * (255 - lpMask^)) div 255;
                        Inc(lpIn);
                        Inc(lpOut);
                        Inc(lpMask);
                    end;
                end;
            end;
        finally
            FreeMem(MaskScanLines);
            FreeMem(BuffScanlines);
        end;
    finally
        MaskDib.Free;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}

procedure TReliefFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_VISUAL;
    Include(Info.Flags, ffUseParam);
    Exclude(Info.Flags, ffUsePen);
end;

function TReliefFilter.DoApply(const Arg: TFilterArg): Integer;
const Sqrt2 = 1.41421356;
var i, j: Integer;
    x, y: Integer;
    lpOut: PRGBTriple;
    Temp: TRGBTriple;
    BgTriple: TRGBTriple;
    R, G, B: Double;
    dStrength: Double;
    function GetPixel(x, y: Integer): TRGBTriple;
    begin
        if x < 0 then
            x := 0
        else if x >= Arg.cxIndata then
            x := Arg.cxIndata - 1;
        if y < 0 then
            y := 0
        else if y >= Arg.cyIndata then
            y := Arg.cyIndata - 1;
        Result := PRGBTripleArray(Arg.inData[y])[x];
    end;
begin
    dStrength := (Strength / 100) * (2 + 2 * Sqrt(2));
    BgTriple := ColorToRGBTriple(Arg.bgColor);

    for j:=0 to Arg.cyData-1 do begin
        if Arg.AbortFunc(j, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[j]);
        y := Arg.yInData + j;
        for i:=0 to Arg.cxData - 1 do begin
            x := Arg.xInData + i;

            R := 0;
            G := 0;
            B := 0;

            Temp := GetPixel(x - 1, y - 1);
            R := R - Temp.R;
            G := G - Temp.G;
            B := B - Temp.B;
            Temp := GetPixel(x + 1, y + 1);
            R := R + Temp.R;
            G := G + Temp.G;
            B := B + Temp.B;

            Temp := GetPixel(x + 1, y - 1);
            R := R - Temp.R;
            G := G - Temp.G;
            B := B - Temp.B;
            Temp := GetPixel(x - 1, y + 1);
            R := R + Temp.R;
            G := G + Temp.G;
            B := B + Temp.B;

            R := R / Sqrt2;
            G := G / Sqrt2;
            B := B / Sqrt2;

            Temp := GetPixel(x - 1, y);
            R := R - Temp.R;
            G := G - Temp.G;
            B := B - Temp.B;
            Temp := GetPixel(x + 1, y);
            R := R + Temp.R;
            G := G + Temp.G;
            B := B + Temp.B;

            Temp := GetPixel(x, y - 1);
            R := R - Temp.R;
            G := G - Temp.G;
            B := B - Temp.B;
            Temp := GetPixel(x, y + 1);
            R := R + Temp.R;
            G := G + Temp.G;
            B := B + Temp.B;

            R := (R / 2) * dStrength;
            G := (G / 2) * dStrength;
            B := (B / 2) * dStrength;

            if Emboss then begin
                R := (R + G + B) / 3;
                G := R;
                B := R;
                R := R + BGTriple.R;
                G := G + BGTriple.G;
                B := B + BGTriple.B;
            end else begin
                Temp := GetPixel(x, y);
                R := R + Temp.R;
                G := G + Temp.G;
                B := B + Temp.B;
            end;

            lpOut.R := ByteRange(Round(R));
            lpOut.G := ByteRange(Round(G));
            lpOut.B := ByteRange(Round(B));

            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}

end.
