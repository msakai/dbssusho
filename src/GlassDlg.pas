unit GlassDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DbsDlgs, StdCtrls, Buttons, ExtCtrls,

  Filters, Spin, Mswheel;

type
  TGlassDialog = class(TDibasDialog)
    CheckBox1: TCheckBox;
    Label1: TLabel;
    SizeEdit: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure SizeEditChange(Sender: TObject);
  end;

implementation

{$R *.DFM}

procedure TGlassDialog.FormShow(Sender: TObject);
begin
    inherited;
    CheckBox1.Checked := TGlassFilter(Target).Vertical;
    SizeEdit.Value := TGlassFilter(Target).Size;
end;

procedure TGlassDialog.CheckBox1Click(Sender: TObject);
begin
    inherited;
    TGlassFilter(Target).Vertical := CheckBox1.Checked;
    Modified;
end;

procedure TGlassDialog.SizeEditChange(Sender: TObject);
begin
    inherited;
    TGlassFilter(Target).Size := SizeEdit.Value;
    Modified;
end;

end.
