unit GradDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DbsDlgs, StdCtrls, Buttons, ExtCtrls, Paint;

type
  TGradationDialog = class(TDibasDialog)
    RadioGroup1: TRadioGroup;
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  GradationDialog: TGradationDialog;

implementation

{$R *.DFM}

procedure TGradationDialog.FormShow(Sender: TObject);
begin
    inherited;
    RadioGroup1.ItemIndex := Ord(TGradationPaint(Target).GradationType);
end;

procedure TGradationDialog.RadioGroup1Click(Sender: TObject);
var NewType: TGradationType;
begin
    inherited;
    NewType := TGradationType(RadioGroup1.ItemIndex);
    if TGradationPaint(Target).GradationType <> NewType then begin
        TGradationPaint(Target).GradationType := NewType;
        Modified;
    end;
end;

end.
