unit WaveDlg;

interface

uses SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons, ExtCtrls,
  checklst, Spin,

  Filters, Dibas_Classes, Wave, DbsDlgs;

type
  TWaveDialog = class(TDibasDialog)
    AngleLabel1: TLabel;
    AmplitudeLabel1: TLabel;
    AngleEdit: TSpinEdit;
    AmplitudeEdit: TSpinEdit;
    LengthLabel1: TLabel;
    LengthEdit: TSpinEdit;
    AngleBox: TPaintBox;
    RadioGroup1: TRadioGroup;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure EditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AngleBoxPaint(Sender: TObject);
    procedure AngleBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AngleBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AngleBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RadioGroup1Click(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
  private
    { Private 宣言 }
    FOnChanging: Boolean;
    FDown: Boolean;
  end;


implementation

{$R *.DFM}

procedure TWaveDialog.FormShow(Sender: TObject);
begin
    inherited;
    FOnChanging := True;
    if Target is TWaveTransform then begin
        with TWaveTransform(Target) do begin
            AngleEdit.Value := Angle;
            AmplitudeEdit.Value := Amplitude;
            LengthEdit.Value := WaveLength;
            CheckListBox1.Checked[0] := Vertical;
            RadioGroup1.ItemIndex := WaveType;
        end;
    end else if Target is TSplashFilter then begin
        with TSplashFilter(Target) do begin
            AmplitudeEdit.Value := Amplitude;
            LengthEdit.Value := WaveLength;
            CheckListBox1.Checked[0] := Vertical;
            RadioGroup1.ItemIndex := WaveType;
        end;
    end;
    CheckListBox1.Checked[1] := TCustomTransform(Target).Interpolation;
    FOnChanging := False;
end;

procedure TWaveDialog.EditChange(Sender: TObject);
begin
    if not FOnChanging then begin
        FOnChanging := True;
        if Target is TWaveTransform then begin
            with TWaveTransform(Target) do begin
               Angle := AngleEdit.Value;
               Amplitude := AmplitudeEdit.Value;
               WaveLength := LengthEdit.Value;
            end;
        end else if Target is TSplashFilter then begin
            with TSplashFilter(Target) do begin
               Amplitude := AmplitudeEdit.Value;
               WaveLength := LengthEdit.Value;
            end;
        end;
        AngleBox.Invalidate;
        Modified;
        FOnChanging := False;
    end;
end;

procedure TWaveDialog.RadioGroup1Click(Sender: TObject);
begin
  inherited;
    if Target is TWaveTransform then
        TWaveTransform(Target).WaveType := RadioGroup1.ItemIndex
    else if Target is TSplashFilter then
        TSplashFilter(Target).WaveType := RadioGroup1.ItemIndex;
    Modified;
end;

procedure TWaveDialog.AngleBoxPaint(Sender: TObject);
var dAngle: Double;
begin
    dAngle := AngleEdit.Value * Pi / 180;
    with TPaintBox(Sender).Canvas do begin
         Pen.Width := 1;
         Pen.Style := psSolid;
         Pen.Color := clBlack;
         Brush.Style := bsSolid;
         Brush.Color := clWhite;
         Ellipse(0, 0, 64, 64);
         Pen.Color := clRed;
         MoveTo(32, 32);
         LineTo(Round(32 + Cos(dAngle) * 32), Round(32 + Sin(dAngle) * 32));
    end;
end;

procedure TWaveDialog.AngleBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbLeft then
        FDown := True;
end;

procedure TWaveDialog.AngleBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbLeft then
        FDown := False;
end;

procedure TWaveDialog.AngleBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var D: Double;
begin
    if FDown then begin
        X := X - 32;
        Y := Y - 32;
        {中心からの角度（ラジアン）を計算}
        if X = 0 then
            D := Pi / 2
        else
            D := ArcTan(Y / X);
        if ((X <= 0) and (Y <= 0)) or ((X < 0) and (Y > 0)) then
            D := D + Pi;
        AngleEdit.Value := (Round(D * 180 / Pi) + 360) mod 360;
    end;
end;


procedure TWaveDialog.CheckListBox1Click(Sender: TObject);
begin
    inherited;
    if Target is TWaveTransform then
        TWaveTransform(Target).Vertical := CheckListBox1.Checked[0]
    else if Target is TSplashFilter then
        TSplashFilter(Target).Vertical := CheckListBox1.Checked[0];
    TCustomTransform(Target).Interpolation := CheckListBox1.Checked[1];
    Modified;
end;

end.
