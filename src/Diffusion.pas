unit Diffusion;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin,

  Filters, DbsDlgs;

type
  TDiffusionDlg = class(TDibasDialog)
    RadiusEdit: TSpinEdit;
    Label1: TLabel;
    ConcentrateButton: TRadioButton;
    FlatRateButton: TRadioButton;
    FrequencyEdit: TSpinEdit;
    Label2: TLabel;
    procedure RadiusEditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FlatRateButtonClick(Sender: TObject);
    procedure FrequencyEditChange(Sender: TObject);
  end;

implementation

{$R *.DFM}


procedure TDiffusionDlg.FormShow(Sender: TObject);
begin
    with TDiffusionFilter(Target) do begin
        FrequencyEdit.Value := Frequency;
        RadiusEdit.Value := Radius;
        FlatRateButton.Checked := FlatRate;
    end;
    RadiusEdit.Left := Label1.BoundsRect.Right + 10;
    FrequencyEdit.Left := RadiusEdit.Left;
end;

procedure TDiffusionDlg.RadiusEditChange(Sender: TObject);
begin
    TDiffusionFilter(Target).Radius := Radiusedit.Value;
    Modified;
end;

procedure TDiffusionDlg.FlatRateButtonClick(Sender: TObject);
begin
    TDiffusionFilter(Target).FlatRate := FlatRateButton.Checked;
    Modified;
end;

procedure TDiffusionDlg.FrequencyEditChange(Sender: TObject);
begin
    TDiffusionFilter(Target).Frequency := FrequencyEdit.Value;
    Modified;
end;

end.
