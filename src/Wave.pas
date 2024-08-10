unit Wave;

interface

uses PlugIf, Dibas_Classes, Filters;

type
  TWaveFunc = function(X: Extended): Extended;

  TWaveTransform = class(TRectTransform)
  private
      FAngle: Integer;
      FAmplitude: Integer;
      FWaveLength: Integer;
      FVertical: Boolean;
      FWaveType: Integer;
      FWaveFunc: TWaveFunc;
      dAngle: Double;          {�p�x�i���W�A���j}
      dBeginningPhase: Double; {�����ʑ��i���W�A���j}
      dSin, dCos: Double;
      dSin2, dCos2: Double;
  protected
      procedure Transform(var x, y: Double); override;
      procedure Initialize; override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Angle: Integer read FAngle write FAngle;                {�p�x}
      property Amplitude: Integer read FAmplitude write FAmplitude;    {�U��}
      property WaveLength: Integer read FWaveLength write FWaveLength; {�g��}
      property Vertical: Boolean read FVertical write FVertical;       {�c�g���H}
      property WaveType: Integer read FWaveType write FWaveType;
  end;


  TSplashFilter = class(TPolorTransform)
  private
      FAmplitude: Integer;
      FWaveLength: Integer;
      FVertical: Boolean;
      FWaveType: Integer;
      FWaveFunc: TWaveFunc;
  protected
      procedure Transform(var Angle, Distance: Double); override;
      procedure Initialize; override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property Amplitude: Integer read FAmplitude write FAmplitude;
      property WaveLength: Integer read FWaveLength write FWaveLength;
      property Vertical: Boolean read FVertical write FVertical;
      property WaveType: Integer read FWaveType write FWaveType;
  end;


  TBlowOutFilter = class(TPolorTransform)
  private
      FWaveCount: Integer;
      FPhase: Double;
      FStrength: Double;
      FWaveType: Integer;
      FWaveFunc: TWaveFunc;
  protected
      procedure Transform(var Angle, Distance: Double); override;
      procedure Initialize; override;
  public
      constructor Create; override;
      procedure GetInfo(var Info: TFilterInfo); override;
  published
      property WaveCount: Integer read FWaveCount write FWaveCount;
      property Phase: Double read FPhase write FPhase;
      property Strength: Double read FStrength write FStrength;
      property WaveType: Integer read FWaveType write FWaveType;
  end;


  function SinWave(X: Extended): Extended;
  function TriangleWave(X: Extended): Extended;
  function RectWave(X: Extended): Extended;

implementation

function SinWave(X: Extended): Extended;
begin
    Result := Sin(X);
end;

function TriangleWave(X: Extended): Extended;{ �O�p�g }
begin
    while X < 0 do X := X + (2 * Pi);
    while X > (2 * Pi) do X := X - (2 * Pi);
    if X < (Pi / 2) then
        Result := X / (Pi / 2)
    else if X < (Pi * 3 / 2) then
        Result := 1 + (X - (Pi / 2)) / (-Pi / 2)
    else
        Result := -1 + (X - (Pi * 3 / 2)) / (Pi / 2);
end;

function RectWave(X: Extended): Extended;{ �Z�`�g }
begin
    while X < 0 do X := X + (2 * Pi);
    while X > (2 * Pi) do X := X - (2 * Pi);
    if X < Pi then
        Result := 1
    else
        Result := -1;
end;

{ TWaveFilter }

constructor TWaveTransform.Create;
begin
    inherited;
    FAmplitude  := 10; {�U��}
    FWaveLength := 40; {�g��}
end;

procedure TWaveTransform.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TWaveTransform.Initialize;
begin
    inherited;
    dAngle := Angle * Pi / 180;
    dSin := Sin(-dAngle);
    dCos := Cos(-dAngle);
    if FVertical then begin
        dSin2 := Sin(dAngle);
        dCos2 := Cos(dAngle);
    end else begin
        dSin2 := Sin(dAngle + Pi / 2);
        dCos2 := Cos(dAngle + Pi / 2);
    end;
    dBeginningPhase := 0;
    case WaveType of
      0: FWaveFunc := SinWave;
      1: FWaveFunc := TriangleWave;
      2: FWaveFunc := RectWave;
    end;
end;

procedure TWaveTransform.Transform(var X, Y: Double);
var d, x1, y1: Double;
begin
   {�ړ�����ׂ����������߂�B}
    d := FWaveFunc(((X * dCos - Y * dSin) / WaveLength) * 2 * Pi + dBeginningPhase) * Amplitude;
    x1 := X;
    y1 := Y;
    X := x1 - d * dCos2;
    Y := y1 - d * dSin2;
end;

{ TSplashFilter }

constructor TSplashFilter.Create;
begin
    inherited;
    FAmplitude  := 10;  { �U�� }
    FWaveLength := 20;  { �g�� }
end;

procedure TSplashFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TSplashFilter.Initialize;
begin
    inherited;
    case WaveType of
      0: FWaveFunc := SinWave;
      1: FWaveFunc := TriangleWave;
      2: FWaveFunc := RectWave;
    end;
end;

procedure TSplashFilter.Transform(var Angle, Distance: Double);
begin
    if Vertical then
        Distance := Distance - FWaveFunc((Distance / FWaveLength) * Pi * 2) * FAmplitude
    else if Distance > 1 then
        Angle := Angle - FAmplitude * FWaveFunc((Distance / FWaveLength) * Pi * 2) / Distance;
end;

{ TBrowOutFilter }

constructor TBlowOutFilter.Create;
begin
    inherited;
    FWaveCount := 15;
    FStrength := 0.2;
end;

procedure TBlowOutFilter.GetInfo(var Info: TFilterInfo);
begin
    inherited;
    Include(Info.Flags, ffUseParam);
end;

procedure TBlowOutFilter.Initialize;
begin
    inherited;
    case WaveType of
      0: FWaveFunc := SinWave;
      1: FWaveFunc := TriangleWave;
      2: FWaveFunc := RectWave;
    end;
end;

procedure TBlowOutFilter.Transform(var Angle, Distance: Double);
begin
    Distance := Distance * (1 - FStrength * FWaveFunc((Angle + FPhase) * FWaveCount));
    if Distance < 0 then
        Distance := 0;
end;


end.
