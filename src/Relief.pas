unit Relief;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin,

  Artistic, DbsDlgs;

type
  TReliefDlg = class(TDibasDialog)
    StrengthBar: TScrollBar;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    StrengthEdit: TSpinEdit;
    procedure StrengthBarChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure StrengthEditChange(Sender: TObject);
  private
    { Private êÈåæ }
    FChanging: Boolean;
  public
    { Public êÈåæ }
  end;

implementation

{$R *.DFM}

procedure TReliefDlg.FormShow(Sender: TObject);
begin
    StrengthBar.Position := TReliefFilter(Target).Strength;
    CheckBox1.Checked := TReliefFilter(Target).Emboss;
end;

procedure TReliefDlg.StrengthBarChange(Sender: TObject);
begin
    if not FChanging then begin
         FChanging := True;
         TReliefFilter(Target).Strength := StrengthBar.Position;
         StrengthEdit.Value := TReliefFilter(Target).Strength;
         Modified;
         FChanging := False;
    end;

end;

procedure TReliefDlg.StrengthEditChange(Sender: TObject);
begin
    if not FChanging then begin
         FChanging := True;
         TReliefFilter(Target).Strength := StrengthEdit.Value;
         StrengthBar.Position := TReliefFilter(Target).Strength;
         Modified;
         FChanging := False;
    end;
end;

procedure TReliefDlg.CheckBox1Click(Sender: TObject);
begin
    TReliefFilter(Target).Emboss := CheckBox1.Checked;
    Modified;
end;

end.
