unit Paint;

interface

uses Windows, SushoUtils, PlugIf, Dibas_Classes, Filters, NkDib;

type
  TPaintFilter = class(TFilter)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  end;
  

  TCustomBitmapPaint = class(TPaintFilter)
  private
      FDib: TNkDib;
  protected
      procedure SetDib(Obj: TNkDib); virtual;
  public
      constructor Create; override;
      destructor Destroy; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Dib: TNkDib read FDib write SetDib;
  end;


  TBMPPaint = class(TCustomBitmapPaint)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  end;


  TPatternPaint = class(TCustomBitmapPaint)
  protected
       function DoApply(const Arg: TFilterArg): Integer; override;
  end;


  TGradationType = (gtHorizontal, gtVertical);
  TGradationPaint = class(TPaintFilter)
  private
      FGradationType: TGradationType;
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
      function PaintHorizontal(const Arg: TFilterArg): Integer;
      function PaintVertical(const Arg: TFilterArg): Integer;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property GradationType: TGradationType read FGradationType write FGradationType;
  end;


  TAveragePaint = class(TPaintFilter)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  end;


  TMarkerPaint = class(TPaintFilter)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  end;


implementation


procedure TPaintFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_PAINT;
end;

function TPaintFilter.DoApply(const Arg: TFilterArg): Integer;
var x, y: Integer;
    lpOut :PRGBTriple;
    ColorTriple: TRGBTriple;
begin
    ColorTriple := ColorToRGBTriple(Arg.fgColor);
    for y := 0 to Arg.cyData - 1 do begin
        lpOut := PRGBTriple(Arg.Outdata[y]);
        for x := 0 to Arg.cxData - 1 do begin
            lpOut^ := ColorTriple;
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}

constructor TCustomBitmapPaint.Create;
begin
    inherited;
    FDib := TNkDib.Create;
end;

destructor TCustomBitmapPaint.Destroy;
begin
    Dib.Free;
end;

procedure TCustomBitmapPaint.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TCustomBitmapPaint.SetDib(Obj: TNkDib);
begin
    FDib.Assign(Obj);
end;

{------------------------------------------------------------------------------}

function TBMPPaint.DoApply(const Arg: TFilterArg): Integer;
var x, y, w, h: Integer;
    lpOut: PRGBTriple;
    lpData: PRGBTripleArray;
begin
    w := Dib.Width;
    h := Dib.Height;
    Dib.ConvertToTrueColor;
    for y := 0 to Arg.cyData - 1 do begin
        lpOut := PRGBTriple(Arg.Outdata[y]);
        lpData := Dib.ScanLine[(y + Arg.yInData) mod h];
        for x := 0 to Arg.cxData - 1 do begin
            lpOut^ := lpData[(x + Arg.xInData) mod w];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}

function TPatternPaint.DoApply(const Arg: TFilterArg): Integer;
var x, y, w, h: Integer;
    lpOut, lpIn: PRGBTriple;
    lpData: PRGBTripleArray;
    FGTriple: TRGBTriple;
    t: TRGBTriple;
begin
    w := Dib.Width;
    h := Dib.Height;
    Dib.ConvertToTrueColor;
    FGTriple := ColorToRGBTriple(Arg.fgColor);
    for y := 0 to Arg.cyData - 1 do begin
        lpIn   := PRGBTriple(Arg.Indata[y + Arg.yInData]);
        Inc(lpIn, Arg.xInData);
        lpOut := PRGBTriple(Arg.Outdata[y]);
        lpData := Dib.ScanLine[(y + Arg.yInData) mod h];
        for x := 0 to Arg.cxData - 1 do begin
            t := lpData[(x + Arg.xInData) mod w];
            lpOut.R := (FGTriple.R * t.R + lpIn.R * (255 - t.R)) div 255;
            lpOut.G := (FGTriple.G * t.G + lpIn.G * (255 - t.G)) div 255;
            lpOut.B := (FGTriple.B * t.B + lpIn.B * (255 - t.B)) div 255;
            Inc(lpIn);
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}

procedure TGradationPaint.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

function TGradationPaint.DoApply(const Arg: TFilterArg): Integer;
begin
    case GradationType of
      gtHorizontal: Result := PaintHorizontal(Arg);
      gtVertical:   Result := PaintVertical(Arg);
      else Result := FTR_FAIL;
    end;
end;

function TGradationPaint.PaintHorizontal(const Arg: TFilterArg): Integer;
var x, y: Integer;
    GradLen: Integer;
    lpOut: PRGBTriple;
    IncR, IncG, IncB: Double;
    R, G, B: Double;
    R1, G1, B1: Double;
begin
    GradLen := Arg.cxData;

    R1 := GetRValue(Arg.BGColor);
    G1 := GetGValue(Arg.BGColor);
    B1 := GetBValue(Arg.BGColor);
    IncR := (GetRValue(Arg.FGColor) - R1) / GradLen;
    IncG := (GetGValue(Arg.FGColor) - G1) / GradLen;
    IncB := (GetBValue(Arg.FGColor) - B1) / GradLen;
    for y := 0 to Arg.cyData - 1 do begin
        if Arg.AbortFunc(y, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[y]);
        R := R1;
        G := G1;
        B := B1;
        for x := 0 to Arg.cxData - 1 do begin
            lpOut.R := Round(R);
            lpOut.G := Round(G);
            lpOut.B := Round(B);
            R := R + IncR;
            G := G + IncG;
            B := B + IncB;
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

function TGradationPaint.PaintVertical(const Arg: TFilterArg): Integer;
var x, y: Integer;
    GradLen: Integer;
    lpOut: PRGBTriple;
    IncR, IncG, IncB: Double;
    R, G, B: Double;
    t: TRGBTriple;
begin
    GradLen := Arg.cyData;

    R := GetRValue(Arg.BGColor);
    G := GetGValue(Arg.BGColor);
    B := GetBValue(Arg.BGColor);
    IncR := (GetRValue(Arg.FGColor) - R) / GradLen;
    IncG := (GetGValue(Arg.FGColor) - G) / GradLen;
    IncB := (GetBValue(Arg.FGColor) - B) / GradLen;
    for y := 0 to Arg.cyData - 1 do begin
        if Arg.AbortFunc(y, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[y]);
        R := R + IncR;
        G := G + IncG;
        B := B + IncB;
        t.R := Round(R);
        t.G := Round(G);
        t.B := Round(B);
        for x := 0 to Arg.cxData - 1 do begin
            lpOut^ := t;
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}

procedure TAveragePaint.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseMask);
end;

function TAveragePaint.DoApply(const Arg: TFilterArg): Integer;
var x, y: Integer;
    lpIn: PRGBTriple;
    lpMask: PByte;
    D, R, G, B: Double;
    Arg2: TFilterArg;
begin
    D := 0;
    R := 0;
    G := 0;
    B := 0;
    for y := 0 to Arg.cyData - 1 do begin
        if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpIn   := PRGBTriple(Arg.Indata[y + Arg.yInData]);
        Inc(lpIn, Arg.xInData);
        lpMask := PByte(Arg.mask[y]);
        for x := 0 to Arg.cxData - 1 do begin
            R := R + lpIn.R * lpMask^;
            G := G + lpIn.G * lpMask^;
            B := B + lpIn.B * lpMask^;
            D := D + lpMask^;
            Inc(lpIn);
            Inc(lpMask);
        end;
    end;

    Arg2 := Arg;
    Arg2.Abortfunc := DummyAbortFunc;
    Arg2.fgColor := RGB(
      ByteRange(Round(R / D)),
      ByteRange(Round(G / D)),
      ByteRange(Round(B / D))
    );

    Result := inherited DoApply(Arg2);
end;

{------------------------------------------------------------------------------}

function TMarkerPaint.DoApply(const Arg: TFilterArg): Integer;
var x, y: Integer;
    lpIn, lpOut :PRGBTriple;
    c: TRGBTriple;
begin
    c := ColorToRGBTriple(Arg.fgColor);
    for y := 0 to Arg.cyData - 1 do begin
        if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpIn  := PRGBTriple(Arg.Indata[y + Arg.yInData]);
        Inc(lpIn, Arg.xInData);
        lpOut := PRGBTriple(Arg.Outdata[y]);
        for x := 0 to Arg.cxData - 1 do begin
            lpOut.B := ByteRange(lpIn.B + c.B - 255);
            lpOut.G := ByteRange(lpIn.G + c.G - 255);
            lpOut.R := ByteRange(lpIn.R + c.R - 255);
            Inc(lpIn);
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{------------------------------------------------------------------------------}


end.
