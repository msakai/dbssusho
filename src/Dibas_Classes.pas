unit Dibas_Classes;

interface

uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinTypes, WinProcs,
{$ENDIF}
  Classes, SysUtils, Graphics, SushoUtils, PlugIf;

type
  TRGBTriple = packed record
      B, G, R: Byte;
  end;
  PRGBTriple = ^TRGBTriple;
  {最近になって気が付いたが、TRGBTripleは Windows Unit に定義されていた。
   でも、rgbtRed等と長たらしい名前を書くのがめんどくさいので
   しばらくはこのままだと思う。}

  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..10000000] of TRGBTriple;

  PRGBQUADArray = ^TRGBQUADArray;
  TRGBQUADArray = array[0..255] of TRGBQUAD;

  TFilterFlag = (ffUseMenu, ffUsePen, ffOneShot, ffUseParam, ffUseMask);
  TFilterFlags = set of TFilterFlag;

  TFilterInfo = record
      FilterType : Integer;
      Flags      : TFilterFlags;
  end;


type
  TPlugInObject = class(TObject)
  private
      FTag: LongInt;
  protected
      //初期化処理、終了処理。
      procedure Initialize; dynamic;
      procedure Finalize; dynamic;
  public
      constructor Create; virtual;
      procedure GetInfo(var Info: TFilterInfo); virtual;
      property Tag: LongInt read FTag write FTag;
  end;

  TFilter = class(TPlugInObject)
  private
      FArgument: PFilterArg;
      FWrapAround: Boolean;
      FCenter: TPoint;
  protected
      { 内部メソッド }
      function GetPixels(x, y: Integer): TRGBTriple;
      function GetInterpolatedPixels(x, y: Double): TRGBTriple;
      function DoApply(const Arg: TFilterArg): Integer; dynamic;
      property WrapAround: Boolean read FWrapAround write FWrapAround;
      {座標の色を取得する際、範囲外の座標値ならば巻き戻す。主に変形系のフィルタで使用}
      property Center: TPoint read FCenter write FCenter;
      {処理の基準となる座標、主に変形系のフィルタで使用}
      property Argument: PFilterArg read FArgument;
      property Pixels[x, y: Integer]: TRGBTriple read GetPixels;
      property InterPolatedPixels[x, y: Double]: TRGBTriple read GetInterpolatedPixels;
  public
      function Apply(const Arg: TFilterArg): Integer; dynamic;
  end;

  TResize = class(TPlugInObject)
  protected
      function DoApply(const Arg: TResizeArg): Integer; dynamic;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
      function Apply(const Arg: TResizeArg): Integer; dynamic;
  end;

  TCombine = class(TPlugInObject)
  protected
      function DoApply(const Arg: TCombineArg): Integer; dynamic;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
      function Apply(const Arg: TCombineArg): Integer; dynamic;
  end;

  TQuantize = class(TPlugInObject)
  protected
      function DoApply(const Arg: TQuantizeArg): Integer; dynamic;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
      function Apply(const Arg: TQuantizeArg): Integer; dynamic;
  end;

  TColorFilter = class(TFilter)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
      procedure FilterRGB(var Color: TRGBTriple); virtual; abstract;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  end;

  TCustomTransform = class(TFilter)
  private
      FInterpolation: Boolean;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
      property Interpolation: Boolean read FInterPolation write FInterPolation
        default True;
  end;

  TRectTransform = class(TCustomTransform)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
      procedure Transform(var X, Y: Double); virtual; abstract;
      {渡された変換後の座標から変換前の座標を計算する。}
      {画像の範囲外の座標になってもかまわない}
  end;

  TPolorTransform = class(TCustomTransform)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
      procedure Initialize; override;
      procedure Transform(var Angle, Distance: Double); virtual; abstract;
      {渡された変換後の座標から変換前の座標を計算する。}
      {画像の範囲外の座標になってもかまわない}
  end;
{
  TRelativePolorTransform = class(TPolorTransform)
  protected
      procedure Initialize; override;
      procedure Transform(var Angle, Distance: Double); override;
  end;
}
  TPixelCombine = class(TCombine)
  protected
      function DoApply(const Arg: TCombineArg): Integer; override;
      function CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple; virtual; abstract;
  end;

{ Utility functions }
function DummyAbortFunc(pos, total: Word): Word; stdcall;
function RGBTriple(R, G, B: Integer): TRGBTriple;
function RGBQuad(R, G, B: Integer): TRGBQUAD;
function ColorToRGBTriple(Color: TColor): TRGBTriple;
function ColorToRGBQuad(Color: TColor): TRGBQuad;
function BlendRGBTriple(Src1, Src2: TRGBTriple; Mix: Byte): TRGBTriple;

implementation

{ TPlugInObject }

constructor TPlugInObject.Create;
begin inherited Create; end;

procedure TPlugInObject.GetInfo(var Info: TFilterInfo);
begin
    Info.Flags := [ffUsePen, ffUseMenu];
end;

procedure TPlugInObject.Initialize;
begin end;

procedure TPlugInObject.Finalize;
begin end;

{ TFilter }

function TFilter.Apply(const Arg: TFilterArg): Integer;
begin
    FArgument := @Arg;
    Initialize;
    try
        Result := DoApply(Arg);
    finally
        Finalize;
        FArgument := nil;
    end;
end;

{フィルタのデフォルトの動作。}
function TFilter.DoApply(const Arg: TFilterArg): Integer;
var y: Integer;
begin
    for y:=0 to Arg.cyData - 1 do begin
        if Arg.AbortFunc(y, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        Move(PRGBTripleArray(Arg.Indata[y + Arg.yInData])[Arg.xInData],
             Arg.Outdata[y]^,
             SizeOf(TRGBTriple) * Arg.cxData);
    end;
    Result := FTR_OK;
end;


function TFilter.GetPixels(x, y: Integer): TRGBTriple;
begin
    if WrapAround then begin
        X := X mod Argument.cxInData;
        Y := Y mod Argument.cyInData;
        if X < 0 then Inc(X, Argument.cxInData);
        if Y < 0 then Inc(Y, Argument.cyInData);
        Result:= PRGBTripleArray(Argument.inData[y])[x]
    end else begin

        if (x >= 0) and (x < Argument.cxInData)
          and (y >= 0) and (y < Argument.cyInData) then
            Result := PRGBTripleArray(Argument.inData[y])[x]
        else
            Result := ColorToRGBTriple(Argument.bgColor);
{
        if X < 0 then
            X := 0
        else if X >= Argument.cxInData then
            X := Argument.cxInData - 1;
        if Y < 0 then
            Y := 0
        else if Y >= Argument.cyInData then
            Y := Argument.cyInData - 1;
        Result := PRGBTripleArray(Argument.inData[y])[x]
}
    end;
end;


function TFilter.GetInterpolatedPixels(x, y: Double): TRGBTriple;
var px, py: Integer;
    t1, t2, t3, t4: TRGBTriple;
    function BlendRGBTriple(Src1, Src2: TRGBTriple; Mix: Double): TRGBTriple;
    var d: Double;
    begin
        d := 1 - Mix;
        Result.R := ByteRange(Round(Src1.R * d + Src2.R * Mix));
        Result.G := ByteRange(Round(Src1.G * d + Src2.G * Mix));
        Result.B := ByteRange(Round(Src1.B * d + Src2.B * Mix));
    end;
begin
    if x >= 0 then
        px := Trunc(x)
    else
        px := Trunc(x - 1);

    if y >= 0 then
        py := Trunc(y)
    else
        py := Trunc(y - 1);
    {関連する４点の色を求める}
    t1 := Pixels[px, py];
    t2 := Pixels[px, py + 1];
    t3 := Pixels[px + 1, py];
    t4 := Pixels[px + 1, py + 1];
    Result := BlendRGBTriple(
      BlendRGBTriple(t1, t3, x - px),
      BlendRGBTriple(t2, t4, x - px),
      y - py);
end;

{ TResize }

procedure TResize.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_RESIZE;
end;

function TResize.Apply(const Arg: TResizeArg): Integer;
begin
    Initialize;
    try
       Result := DoApply(Arg);
    finally
        Finalize;
    end;
end;

{サイズ変更ツールのデフォルト処理。（近傍近似）}
function TResize.DoApply(const Arg: TResizeArg): Integer;
var x, y: Integer;         {変換後の画像の座標}
    DstX, DstY: Integer;   {変換前の画像の座標}
    IncX, IncY: Integer;   {X方向, Y方向の増分}
    lpIn: PRGBTripleArray;
    lpOut: PRGBTriple;
begin
{注 DstX, DstY, IncX, IncY は固定小数点を使用。
     整数部: 16bit
     小数部: 16bit  です。}
    IncX := (Arg.cxIn shl 16) div Arg.cxOut;
    IncY := (Arg.cyIn shl 16) div Arg.cyOut;
    DstY := 0;
    for y:=0 to Arg.cyOut-1 do begin
        if Arg.AbortFunc(y, Arg.cyOut) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpIn  := PRGBTripleArray(Arg.Indata[DstY shr 16]);
        lpOut := PRGBTriple(Arg.Outdata[y]);
        DstX := 0;
        for x:=0 to Arg.cxOut-1 do begin
            lpOut^ := lpIn[DstX shr 16];
            Inc(lpOut);
            Inc(DstX, IncX);
        end;
        Inc(DstY, IncY);
    end;
    Result := FTR_OK;
end;

{ TCombine }

procedure TCombine.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_COMBINE;
end;

function TCombine.Apply(const Arg: TCombineArg): Integer;
begin
    Initialize;
    try
        Result := DoApply(Arg);
    finally
        Finalize;
    end;
end;

{合成ツールのデフォルトの動作}
function TCombine.DoApply(const Arg: TCombineArg): Integer;
var y: Integer;
begin
    for y := 0 to Arg.cyData - 1 do begin
        if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        Move(PRGBTripleArray(Arg.Indata1[Arg.yInData1 + y])[Arg.xInData1],
             Arg.Outdata[y]^,
             SizeOf(TRGBTriple) * Arg.cxData);
    end;
    Result := FTR_OK;
end;

{ TQuantize }

procedure TQuantize.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_QUANT256;
end;

function TQuantize.Apply(const Arg: TQuantizeArg): Integer;
begin
    Initialize;
    try
        Result := DoApply(Arg);
    finally
        Finalize;
    end;
end;

function TQuantize.DoApply(const Arg: TQuantizeArg): Integer;
begin Result := FTR_FAIL; end;

{ TColorFilter }

procedure TColorFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_COLOR;
    Include(Info.Flags, ffOneShot);
end;

function TColorFilter.DoApply(const Arg: TFilterArg): Integer;
var x, y: Integer;
    lpIn, lpOut :PRGBTriple;
begin
    for y := 0 to Arg.cyData - 1 do begin
        if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpIn  := PRGBTriple(Arg.Indata[y + Arg.yInData]);
        Inc(lpIn, Arg.xInData);
        lpOut := PRGBTriple(Arg.Outdata[y]);
        for x := 0 to Arg.cxData - 1 do begin
            lpOut^ := lpIn^;
            FilterRGB(lpOut^);
            Inc(lpIn);
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ TCustomTransform }

constructor TCustomTransform.Create;
begin
    inherited;
    FInterpolation := True;
end;

procedure TCustomTransform.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_SPECIAL;
    Exclude(Info.Flags, ffUsePen);
end;

{ TRectTransform }

function TRectTransform.DoApply(const Arg: TFilterArg): Integer;
var i, j: Integer;
    x, y: Integer;
    dx, dy: Double;
    dCenterX, dCenterY: Double;
    lpOut: PRGBTriple;
begin
    dCenterX := Center.X;
    dCenterY := Center.Y;
    {フィルターの実処理}
    for j:=0 to Arg.cyData-1 do begin
        if Arg.AbortFunc(j, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[j]);
        y := Arg.yInData + j;
        for i:=0 to Arg.cxData-1 do begin
            x := Arg.xInData + i;
            dx := x - dCenterX;
            dy := y - dCenterY;
            Transform(dx, dy);
            if FInterpolation then
                lpOut^ := InterpolatedPixels[dx + dCenterX, dy + dCenterY]
            else
                lpOut^ := Pixels[Round(dx + dCenterX), Round(dy + dCenterY)];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ TPolorTransform }

procedure TPolorTransform.Initialize;
begin
    inherited;
    Center := Point(Argument.cxInData div 2, Argument.cyInData div 2);
end;

function TPolorTransform.DoApply(const Arg: TFilterArg): Integer;
var i, j: Integer;
    x, y: Integer;
    dx, dy: Double;
    dCenterX, dCenterY: Double;
    dAngle, dDistance: Double;
    lpOut: PRGBTriple;
begin
    dCenterX := Center.X;
    dCenterY := Center.Y;
    //フィルターの実処理
    for j:=0 to Arg.cyData-1 do begin
        if Arg.AbortFunc(j, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[j]);
        y := Arg.yInData + j;
        for i:=0 to Arg.cxData-1 do begin
            x := Arg.xInData + i;

            dx := x - dCenterX;
            dy := y - dCenterY;

            //中心からの角度（ラジアン）を計算
            if dx = 0 then
                dAngle := Pi / 2
            else
                dAngle := ArcTan(dy / dx);
            if ((dx <= 0) and (dy <= 0)) or ((dx < 0) and (dy > 0)) then
                dAngle := dAngle + Pi;

            //中心からの距離 //hypot(dDstX, dDstY);
            dDistance := Sqrt(Sqr(dx) + Sqr(dy));

            Transform(dAngle, dDistance);

            if Interpolation then
                lpOut^ := InterpolatedPixels[dCenterX + dDistance * Cos(dAngle),
                  dCenterY + dDistance * Sin(dAngle)]
            else
                lpOut^ := Pixels[Round(dCenterX + dDistance * Cos(dAngle)),
                  Round(dCenterY + dDistance * Sin(dAngle))];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ TPixelCombine }

function TPixelCombine.DoApply(const Arg: TCombineArg): Integer;
var lpIn1, lpIn2, lpOut: PRGBTriple;
    x, y: Integer;
begin
    for y:=0 to Arg.cyData-1 do begin
        if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[y]);
        lpIn1 := PRGBTriple(Arg.Indata1[Arg.yInData1 + y]);
        lpIn2 := PRGBTriple(Arg.Indata2[Arg.yInData2 + y]);
        Inc(lpIn1, Arg.xInData1);
        Inc(lpIn2, Arg.xInData2);
        for x:=0 to Arg.cxData - 1 do begin
            lpOut^ := CombinePixel(lpIn1^, lpIn2^);
            Inc(lpIn1);
            Inc(lpIn2);
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ Utility functions }

function DummyAbortFunc(pos, total: Word): Word;
begin
    Result := FTR_OK;
end;

function RGBTriple(R, G, B: Integer): TRGBTriple;
begin
    Result.B := ByteRange(B);
    Result.G := ByteRange(G);
    Result.R := ByteRange(R);
end;

function RGBQuad(R, G, B: Integer): TRGBQUAD;
begin
    Result.rgbBlue     := ByteRange(B);
    Result.rgbGreen    := ByteRange(G);
    Result.rgbRed      := ByteRange(R);
    Result.rgbReserved := 0;
end;


function ColorToRGBTriple(Color: TColor): TRGBTriple;
begin
    Color := ColorToRGB(Color);
    Result := RGBTriple(GetRValue(Color), GetGValue(Color), GetBValue(Color));
end;

function ColorToRGBQuad(Color: TColor): TRGBQuad;
begin
    Color := ColorToRGB(Color);
    Result := RGBQuad(GetRValue(Color), GetGValue(Color), GetBValue(Color));
end;

function BlendRGBTriple(Src1, Src2: TRGBTriple; Mix: Byte): TRGBTriple;
begin
    Result.R := (Src1.R * (255 - Mix) + Src2.R * Mix) div 255;
    Result.G := (Src1.R * (255 - Mix) + Src2.G * Mix) div 255;
    Result.B := (Src1.R * (255 - Mix) + Src2.B * Mix) div 255;
end;


end.
