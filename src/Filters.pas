unit Filters;

interface

uses
  Windows, Classes, SysUtils, Graphics,
  PlugIf, Dibas_Classes, Sugaku, SushoUtils;

type
{ ColorFilters }
  TGrayScaleType = (gstWeighted, gstAverage, gstMax);
  TGrayScaleFilter = class(TColorFilter)
  private
      FGrayScaleType: TGrayScaleType;
  protected
      procedure FilterRGB(var Color: TRGBTriple); override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property GrayScaleType: TGrayScaleType read FGrayScaleType write FGrayScaleType;
  end;

  TSolarizationFilter = class(TColorFilter)
  private
      FSplitValue: Integer;
  protected
      procedure FilterRGB(var Color: TRGBTriple); override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property SplitValue: Integer read FSplitValue write FSplitValue;{ 閾値 }
  end;

  TChannel = (chR, chG, chB, chY, chCb, chCr);
  TCopyChannel = class(TColorFilter)
  private
      FChannel1, FChannel2: TChannel;
      FFlag1, FFlag2: Boolean;
  protected
      procedure FilterRGB(var Color: TRGBTriple); override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Channel1: TChannel read FChannel1 write FChannel1;
      property Channel2: TChannel read FChannel2 write FChannel2;
      property Flag1: Boolean read FFlag1 write FFlag1;
      property Flag2: Boolean read FFlag2 write FFlag2;
  end;

  TPosterization = class(TColorFilter)
  private
      //処理後の階調数
      FRColors: Integer;
      FGColors: Integer;
      FBColors: Integer;
      {ルックアップテーブル}
      RTable, GTable, BTable: array[0..255] of Byte;
  protected
      procedure Initialize; override;
      procedure FilterRGB(var Color: TRGBTriple); override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
      class function DoPoster(c: Byte; Count: SmallInt): Byte;
  published
      property RColors: Integer read FRColors write FRColors;
      property GColors: Integer read FGColors write FGColors;
      property BColors: Integer read FBColors write FBColors;
  end;

  TDualTone = class(TColorFilter)
  private
      {ルックアップテーブル}
      Table: array[0..255] of TRGBTriple;
  protected
      procedure Initialize; override;
      procedure FilterRGB(var Color: TRGBTriple); override;
  end;

  TRGBShift = class(TColorFilter)
  protected
      procedure FilterRGB(var Color: TRGBTriple); override;
  public
      RShift, GShift, BShift: Integer;
      procedure GetInfo(var Info: TFilterInfo); override;
  end;

  TMonoTone = class(TColorFilter)
  private
      U_YUV, V_YUV: Double;{色差}
  protected
      procedure Initialize; override;
      procedure FilterRGB(var Color: TRGBTriple); override;
  end;

{ Noise }

  TDiffusionFilter = class(TFilter)
  private
      FFrequency: Integer; {拡散頻度}
      FRadius: Integer;    {最大拡散距離}
      FFlatRate: Boolean;  {拡散方法(True: 均一; False: 集中)}
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Frequency: Integer read FFrequency write FFrequency; {拡散頻度}
      property Radius: Integer read FRadius write FRadius;          {最大拡散距離}
      property FlatRate: Boolean read FFlatRate write FFlatRate;    {拡散方法(True: 均一; False: 集中)}
  end;

{ Transform }
  TTunnel = class(TRectTransform)
  private
      tunnelR, XTemp, Temp: Double;
      FSquare: Boolean;
  protected
      procedure Transform(var x, y: Double); override;
      procedure Initialize; override;
  published
      property Square: Boolean read FSquare write FSquare;
  end;

  TSpinFilter = class(TPolorTransform)
  private
      FLoopPixels: Integer;      // 一回転に必要なピクセル数
      FDirection: Byte;          // 回転方向(時計回り=0, 半時計周り=1)
  protected
      procedure Transform(var Angle, Distance: Double); override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property LoopPixels: Integer read FLoopPixels write FLoopPixels;
      property Direction: Byte read FDirection write FDirection;
  end;

  TRectToPolor = class(TCustomTransform)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  end;

  TAffineTransform = class(TRectTransform)
  protected
      procedure Transform(var X, Y: Double); override;
  public
      {アフィン変換のパラメータ}
      a, b, c, d, e, f: Double;
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  end;

  TLozenge = class(TCustomTransform)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  end;

  TSphere = class(TCustomTransform)
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  end;

  TGlassFilter = class(TFilter)
  private
      FVertical: Boolean;
      FSize: Cardinal;
  protected
      function DoApply(const Arg: TFilterArg): Integer; override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Vertical: Boolean read FVertical write FVertical;
      property Size: Cardinal read FSize write FSize;
  end;


{Combines}
  TOrCombine = class(TPixelCombine)
  protected
      function CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple; override;
  end;

  TAndCombine = class(TPixelCombine)
  protected
      function CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple; override;
  end;

  TCMYAddCombine = class(TPixelCombine)
  protected
      function CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple; override;
  end;

  TCMYMultipleCombine = class(TPixelCombine)
  protected
      function CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple; override;
  end;

{ Quantize }

  TRandomDither = class(TQuantize)
  protected
      function DoApply(const Arg: TQuantizeArg): Integer; override;
  public
      procedure GetInfo(var Info: TFilterInfo); override;
  end;

implementation

{ GrayScale }

procedure TGrayScaleFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TGrayScaleFilter.FilterRGB(var Color: TRGBTriple);
var g: byte;
    function Max(Value1, Value2: Byte): Integer;
    begin
        if Value1>Value2 then
            Result := Value1
        else
            Result := Value2;
    end;
begin
    case FGrayScaleType of
      gstWeighted: g := (Color.B * 28 + Color.G * 151 + Color.R * 77) shr 8;
      gstAverage: g := (Color.B + Color.G + Color.R) div 3;
      gstMax: g := Max(Max(Color.B, Color.G), Color.R);
      else g := 0;
    end;
    Color.R := g;
    Color.G := g;
    Color.B := g;
end;

{ Solarization }

procedure TSolarizationFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TSolarizationFilter.FilterRGB(var Color: TRGBTriple);
begin
    if FSplitValue < Color.R then
        Color.R := not Color.R;
    if FSplitValue < Color.G then
        Color.G := not Color.G;
    if FSplitValue < Color.B then
        Color.B := not Color.B;
end;

{ CopyChannel }

procedure TCopyChannel.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TCopyChannel.FilterRGB(var Color: TRGBTriple);
var c1, c2: Byte;
    function GetChannelValue(const RGBTriple: TRGBTriple; Channel: TChannel): Byte;
    begin
        case Channel of
          chR:  Result := RGBTriple.R;
          chG:  Result := RGBTriple.G;
          chB:  Result := RGBTriple.B;
          chY:  Result := ByteRange(Round(0.299   * RGBTriple.R + 0.587  * RGBTriple.G + 0.144  * RGBTriple.B));
          chCb: Result := ByteRange(Round(-0.1687 * RGBTriple.R - 0.3313 * RGBTriple.G + 0.5    * RGBTriple.B) + 128);
          chCr: Result := ByteRange(Round(0.5     * RGBTriple.R - 0.4187 * RGBTriple.G - 0.0813 * RGBTriple.B) + 128);
          else Result := 0;
        end;
    end;
    procedure SetChannelValue(var RGBTriple: TRGBTriple; Value: Byte; Channel: TChannel);
    var Y, Cb, Cr: Double;
    begin
        case Channel of
          chR: RGBTriple.R := Value;
          chG: RGBTriple.G := Value;
          chB: RGBTriple.B := Value;
          chY, chCb, chCr:
            begin
               Y  := 0.299   * RGBTriple.R + 0.587  * RGBTriple.G + 0.144  * RGBTriple.B;
               Cb := -0.1687 * RGBTriple.R - 0.3313 * RGBTriple.G + 0.5    * RGBTriple.B + 128;
               Cr := 0.5     * RGBTriple.R - 0.4187 * RGBTriple.G - 0.0813 * RGBTriple.B + 128;
               case Channel of
                 chY  : Y  := Value;
                 chCb : Cb := Value;
                 chCr : Cr := Value;
               end;
               RGBTriple.R := ByteRange(Round(Y                        + 1.402   * (Cr - 128)));
               RGBTriple.G := ByteRange(Round(Y - 0.34414 * (Cb - 128) - 0.71414 * (Cr - 128)));
               RGBTriple.B := ByteRange(Round(Y + 1.772   * (Cb - 128)                       ));
            end;
        end;
    end;
begin
    if FFlag2 then begin {チャンネル交換}
        c1 := GetChannelValue(Color, FChannel1);
        c2 := GetChannelValue(Color, FChannel2);
        if FFlag1 then begin{反転して複写}
            c1 := 255 - c1;
            c2 := 255 - c2;
        end;
        SetChannelValue(Color, c2, FChannel1);
        SetChannelValue(Color, c1, FChannel2);
    end else begin {チャンネル複写}
        c1 := GetChannelValue(Color, FChannel1);
        if FFlag1 then {反転して複写}
            c1 := 255 - c1;
        SetChannelValue(Color, c1, FChannel2);
    end;
end;

{ Posterization }

constructor TPosterization.Create;
begin
    inherited;
    RColors := 256;
    GColors := 256;
    BColors := 256;
end;

procedure TPosterization.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

{実際に階調数を減らしている関数}
class function TPosterization.DoPoster(c: Byte; Count: SmallInt): Byte;
begin
    case Count of
      0, 1: Result := 128;
      256: Result := c;
      else Result := ByteRange( ((c * Count) and (not $FF)) div (Count - 1) );
    end;
end;

procedure TPosterization.Initialize;
var i: Integer;
begin
    inherited;
    for i:= 0 to 255 do begin
        RTable[i] := DoPoster(i, RColors);
        GTable[i] := DoPoster(i, GColors);
        BTable[i] := DoPoster(i, BColors);
    end;
end;

procedure TPosterization.FilterRGB(var Color: TRGBTriple);
begin
    Color.R := RTable[Color.R];
    Color.G := GTable[Color.G];
    Color.B := BTable[Color.B];
end;

{ DualTone }

procedure TDualTone.Initialize;
var i: Integer;
begin
    inherited;
    //ルックアップテーブルの作成
    Table[0]   := ColorToRGBTriple(Argument.BGColor);
    Table[255] := ColorToRGBTriple(Argument.FGColor);
    for i:=1 to 254 do begin
        with Table[i] do begin
            B := ((Table[255].B * i) + (Table[0].B * (255 - i))) div 255;
            G := ((Table[255].G * i) + (Table[0].G * (255 - i))) div 255;
            R := ((Table[255].R * i) + (Table[0].R * (255 - i))) div 255;
        end;
    end;
end;

procedure TDualTone.FilterRGB(var Color: TRGBTriple);
var i: Integer;
begin
    i := (Color.R + Color.G +Color.B) div 3;
    Color := Table[i];
end;

{ RGBShift }

procedure TRGBShift.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TRGBShift.FilterRGB(var Color: TRGBTriple);
begin
    Color.R := ByteRange(Color.R + RShift);
    Color.G := ByteRange(Color.G + GShift);
    Color.B := ByteRange(Color.B + BShift);
end;

{ MonoTone }

procedure TMonoTone.Initialize;
var t: TRGBTriple;
begin
    inherited;
    t := ColorToRGBTriple(Argument.fgColor);
    U_YUV := -0.1686 * t.R - 0.3311 * t.G + 0.4997 * t.B;
    V_YUV := 0.4998  * t.R - 0.4185 * t.G - 0.0813 * t.B;
end;

procedure TMonoTone.FilterRGB(var Color: TRGBTriple);
var y: Double; { 輝度 }
begin
    y := 0.2990 * Color.R + 0.5870 * Color.G + 0.1140 * Color.B;
    Color.R := ByteRange( Round(y                  + 1.4026 * V_YUV) );
    Color.G := ByteRange( Round(y - 0.3444 * U_YUV - 0.7144 * V_YUV) );
    Color.B := ByteRange( Round(y + 1.7730 * U_YUV                  ) );
end;

{ DiffusionFilter }

constructor TDiffusionFilter.Create;
begin
    inherited;
    Frequency := 100; {拡散頻度}
    Radius := 5;      {最大拡散距離}
end;

procedure TDiffusionFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_NOISE;
    Include(Info.Flags, ffUseParam);
end;

function TDiffusionFilter.DoApply(const Arg: TFilterArg): Integer;
var x, y, DstX, DstY: Integer;
    Angle: Double;
    Length: Double;
    lpOut: PRGBTriple;
begin
    Randomize;
    for y:=0 to Arg.cyData - 1 do begin
        if Arg.AbortFunc(y, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[y]);
        for x:=0 to Arg.cxData-1 do begin
            DstX := Arg.xInData + x;
            DstY := Arg.yInData + y;
            if Frequency > Random(100) then begin
                if FlatRate then
                    Length := Random * Radius
                else
                    Length := Sqr(Random) * Radius;

                Angle := Random(360) * Pi / 180;
                DstX := DstX - Round(Cos(Angle) * Length);
                DstY := DstY - Round(Sin(Angle) * Length);

                if DstX < 0 then
                    DstX := 0
                else if DstX > Arg.cxInData - 1 then
                    DstX := Arg.cxInData - 1;

                if DstY < 0 then
                    DstY := 0
                else if DstY > Arg.cyInData - 1 then
                    DstY := Arg.cyInData - 1;
            end;
            lpOut^ := PRGBTripleArray(Arg.InData[DstY])[DstX];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ Tunel }

{ そのうちパラメータとして与えられる様にする
	dFov
		Field Of View ＝視角 (M_PI/6)ぐらいの値がトンネルとして見た目が良いです。

	dMag
		テクスチャーの奥行きを引き延ばす率
		（仮想的にビットマップが iTextWidth × (MAG*iTextHeight) になる。）
		64ぐらいがトンネルとしての見た目が良いです
}
procedure TTunnel.Initialize;
begin
    WrapAround := True;
    Center := Point(Argument.cxInData div 2, Argument.cyInData div 2);

    tunnelR := Sqrt(Sqr(Argument.cxData) + Sqr(Argument.cyData));
    XTemp := Argument.cxInData / (2 * Pi) ;
    Temp := Argument.cyInData / (2.0 * Tan({dFov}(Pi / 6) / 2)) / {dMag}64;
    if Temp < 0 then
        Temp := -Temp;
end;

procedure TTunnel.Transform(var x, y: Double);
var r: Double;
    function Max(V1, V2: Double): Double;
    begin
        if V1 > V2 then Result := V1
        else Result := V2;
    end;
begin
    if FSquare then
        r := max(Abs(x), Abs(y))   {四角形のトンネルになる}
    else
        r := Sqrt(Sqr(x) + Sqr(y));  {円形のトンネルになる}

    if r > 0 then begin
        x := XTemp * ArcTan2(y, x);
        y := Temp * ( tunnelR - r ) / r;
    end else begin
        x := 0;
        y := 0;
    end;
end;

{ Spin }

constructor TSpinFilter.Create;
begin
    inherited;
    LoopPixels := 50;
end;

procedure TSpinFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TSpinFilter.Transform(var Angle, Distance: Double);
begin
    {距離によって違う角度で回転}
    if FDirection = 0 then
        Angle := Angle - (Distance / FLoopPixels)  {時計回り}
    else
        Angle := Angle + (Distance / FLoopPixels); {半時計回り}
end;

{ RectToPolor }

function TRectToPolor.DoApply(const Arg: TFilterArg): Integer;
var i, j: Integer;
    x, y: Integer;
    lpOut: PRGBTriple;
    dCenterX, dCenterY: Double;
    dDstX, dDstY: Double;
    D: Double;
    dPerpendicularX, dPerpendicularY: Double;{直交座標(テクスチャー)上でのＸＹ座標}
begin
    {原点}
    dCenterX := Arg.cxInData / 2;
    dCenterY := Arg.cyInData / 2;
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

           {極座標の中心座標からの相対座標を計算}
            dDstX := x - dCenterX;
            dDstY := y - dCenterY;

            {中心からの角度（ラジアン）を計算}
            if dDstX = 0 then
                D := Pi / 2
            else
                D := ArcTan(dDstY / dDstX);
            if ((dDstX <= 0) and (dDstY <= 0)) or ((dDstX < 0) and (dDstY > 0)) then
                D := D + Pi;

            {中心からの角度を直交座標のＸ座標にする}
            dPerpendicularX := (((Pi + Pi / 2) - D) / (Pi * 2)) * (Arg.cxInData - 1);
            {中心からの距離を直交座標のＹ座標にする}
            dPerpendicularY := Sqrt(Sqr(dDstX) + Sqr(dDstY));
            lpOut^ := InterPolatedPixels[dPerpendicularX, dPerpendicularY];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ AffineTransform }

constructor TAffineTransform.Create;
begin
    inherited;
    a := 1;
    e := 1;
end;

procedure TAffineTransform.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TAffineTransform.Transform(var X, Y: Double);
var x1, y1: Double;
begin
    x1 := x;
    y1 := y;
    X := (a * x1) + (b * y1) + c;
    Y := (d * x1) + (e * y1) + f;
end;

{ Lozenge }

function TLozenge.DoApply(const Arg: TFilterArg): Integer;
var i, j: Integer;
    x, y: Integer;
    lpOut: PRGBTriple;
    dCenterX, dCenterY: Double;
    dX, dY: Double;
    x1, y1: Double;
begin
    {中心の座標}
    dCenterX := Arg.cxInData / 2;
    dCenterY := Arg.cyInData / 2;
    {フィルターの実処理}
    for j:=0 to Arg.cyData-1 do begin
        if Arg.AbortFunc(j, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[j]);
        y := Arg.yInData + j;
        dY := y - dCenterY;
        y1 := 1 - ( Abs(dY) / (dCenterY + 1) );
        for i:=0 to Arg.cxData - 1 do begin
            x := Arg.xInData + i;
            dX := x - dCenterX;
            x1 := 1 - ( Abs(dX) / (dCenterX + 1) );
            lpOut^ := InterPolatedPixels[(dX / y1) + dCenterX,
              (dY / x1) + dCenterY];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;

{ TShere }

function TSphere.DoApply(const Arg: TFilterArg): Integer;
var i, j: Integer;
    x, y: Integer;
    lpOut: PRGBTriple;
    dCenterX, dCenterY: Double;
    dX, dY: Double;
    Angle, Len: Double;
begin
    {中心の座標}
    dCenterX := Arg.cxInData / 2;
    dCenterY := Arg.cyInData / 2;
    {フィルターの実処理}
    for j:=0 to Arg.cyData-1 do begin
        if Arg.AbortFunc(j, Arg.cyData) <> FTR_OK then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpOut := PRGBTriple(Arg.Outdata[j]);
        y := Arg.yInData + j;
        dY := (y - dCenterY) / dCenterY;
        for i:=0 to Arg.cxData - 1 do begin
            x := Arg.xInData + i;
            dX := (x - dCenterX) / dCenterX;
            Len   := Sqrt(Sqr(dX) + Sqr(dY));
            if Len < 1 then begin
                Len := 1 - Sqrt(1 - Len); { 適当な式だけど... }
                Angle := ArcTan2(dY, dX);
                lpOut^ := InterPolatedPixels[
                  (Cos(Angle) * Len) * dCenterX + dCenterX,
                  (Sin(Angle) * Len) * dCenterY + dCenterY];
            end else
                lpOut^ := Pixels[x, y];
            Inc(lpOut);
        end;
    end;
    Result := FTR_OK;
end;


{ GlassFilter }

constructor TGlassFilter.Create;
begin
    inherited;
    FSize := 8;
end;

procedure TGlassFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_VISUAL;
    Include(Info.Flags, ffUseParam);
end;

function TGlassFilter.DoApply(const Arg: TFilterArg): Integer;
var x, y, i, j: Integer;
    GlassSize: Integer;
    lpIn, lpOut: PRGBTriple;
begin
    GlassSize := FSize;
    if Vertical then begin
        j := (Arg.cxData div GlassSize) * GlassSize;
        for y := 0 to Arg.cyData - 1 do begin
            if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
                Result := FTR_CANCEL;
                Exit;
            end;
            lpIn :=  PRGBTriple(Arg.Indata[y + Arg.yInData]);
            Inc(lpIn, Arg.xInData);
            lpOut := PRGBTriple(Arg.outData[y]);
            for x := 0 to Arg.cxData - 1 do begin
                if x < j then
                    i := (GlassSize - 1) - (x mod GlassSize) + (x div GlassSize) * GlassSize
                else
                    i := x;
                lpOut^ := PRGBTripleArray(lpIn)[i];
                Inc(lpOut);
            end;
        end;
    end else begin
        j := (Arg.cyData div GlassSize) * GlassSize;
        for y := 0 to Arg.cyData - 1 do begin
            if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
                Result := FTR_CANCEL;
                Exit;
            end;
            if y < j then
                i := (GlassSize - 1) - (y mod GlassSize) + (y div GlassSize) * GlassSize
            else
                i := y;
            lpIn :=  PRGBTriple(Arg.Indata[i + Arg.yInData]);
            Inc(lpIn, Arg.xInData);
            lpOut := PRGBTriple(Arg.outData[y]);
            Move(lpIn^, lpOut^, SizeOf(TRGBTriple) * Arg.cxData);
        end;
    end;
    Result := FTR_OK;
end;

{ Combines }

function TORCombine.CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple;
begin
    Result.B := Src1.B or Src2.B;
    Result.G := Src1.G or Src2.G;
    Result.R := Src1.R or Src2.R;
end;

function TAndCombine.CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple;
begin
    Result.B := Src1.B and Src2.B;
    Result.G := Src1.G and Src2.G;
    Result.R := Src1.R and Src2.R;
end;

function TCMYAddCombine.CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple;
begin
    Result.B := ByteRange(Src1.B + Src2.B - 255);
    Result.G := ByteRange(Src1.G + Src2.G - 255);
    Result.R := ByteRange(Src1.R + Src2.R - 255);
end;

function TCMYMultipleCombine.CombinePixel(Src1, Src2: TRGBTriple): TRGBTriple;
begin
    Result.B := not ((not Src1.B) * (not Src2.B) div 255);
    Result.G := not ((not Src1.G) * (not Src2.G) div 255);
    Result.R := not ((not Src1.R) * (not Src2.R) div 255);
end;

{ Quantize }

procedure TRandomDither.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Info.FilterType := FT_QUANT2;
end;

function TRandomDither.DoApply(const Arg: TQuantizeArg): Integer;
var x, y: Integer;
    lpIn: PRGBTriple;
    lpOut: PByte;
begin
    PRGBQUADArray(Arg.outRGB)[0] := RGBQuad(0, 0, 0);
    PRGBQUADArray(Arg.outRGB)[1] := RGBQuad(255, 255, 255);
    Randomize;
    for y:=0 to Arg.cyData-1 do begin
        if (Arg.AbortFunc(y, Arg.cyData) <> FTR_OK) then begin
            Result := FTR_CANCEL;
            Exit;
        end;
        lpIn  := PRGBTriple(Arg.Indata[y]);
        lpOut := PByte(Arg.Outdata[y]);
        for x:=0 to Arg.cxData-1 do begin
            if Random(256) < (lpIn.B + lpIn.G + lpIn.R) div 3 then
                lpOut^ := 1
            else
                lpOut^ := 0;
            Inc(lpOut);
            Inc(lpIn);
        end;
    end;
    Result := FTR_OK;
end;



end.
