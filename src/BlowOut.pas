unit BlowOut;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin,

  DbsDlgs, Wave;

type
  TBlowOutDlg = class(TDibasDialog)
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    StrengthBar: TScrollBar;
    Label2: TLabel;
    StrengthEdit: TSpinEdit;
    Label3: TLabel;
    PhaseEdit: TSpinEdit;
    RadioGroup1: TRadioGroup;
    procedure FormShow(Sender: TObject);
    procedure StrengthBarChange(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure StrengthEditChange(Sender: TObject);
    procedure PhaseEditChange(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private êÈåæ }
    FChanging: Boolean;
  public
    { Public êÈåæ }
  end;



implementation

{$R *.DFM}


procedure TBlowOutDlg.FormShow(Sender: TObject);
begin
    RadioGroup1.ItemIndex := TBlowOutFilter(Target).WaveType;
    SpinEdit1.Value := TBlowOutFilter(Target).WaveCount;
    StrengthEdit.Value := Round(TBlowOutFilter(Target).Strength * 100);
    PhaseEdit.Value := Round(TBlowOutFilter(Target).Phase * 180 / Pi) mod 360;
end;

procedure TBlowOutDlg.StrengthBarChange(Sender: TObject);
begin
    inherited;
    if not FChanging then begin
        FChanging := True;
        TBlowOutFilter(Target).Strength := StrengthBar.Position / 100;
        StrengthEdit.Value := StrengthBar.Position;
        Modified;
        FChanging := False;
    end;
end;

procedure TBlowOutDlg.StrengthEditChange(Sender: TObject);
begin
    inherited;
    if not FChanging then begin
        FChanging := True;
        TBlowOutFilter(Target).Strength := StrengthEdit.Value / 100;
        StrengthBar.Position := StrengthEdit.Value;
        Modified;
        FChanging := False;
    end;
end;

procedure TBlowOutDlg.SpinEdit1Change(Sender: TObject);
begin
    inherited;
    TBlowOutFilter(Target).WaveCount := SpinEdit1.Value;
    Modified;
end;

procedure TBlowOutDlg.PhaseEditChange(Sender: TObject);
begin
    inherited;
    TBlowOutFilter(Target).Phase := PhaseEdit.Value * Pi / 180;
    Modified;
end;

procedure TBlowOutDlg.RadioGroup1Click(Sender: TObject);
begin
    inherited;
    TBlowOutFilter(Target).WaveType := RadioGroup1.ItemIndex;
    Modified;
end;

end.
