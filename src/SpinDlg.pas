unit SpinDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin,

  DbsDlgs, Filters;

type
  TSpinDialog = class(TDibasDialog)
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    DirectionGroup: TRadioGroup;
    procedure SpinEdit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DirectionGroupClick(Sender: TObject);
  private
    { Private êÈåæ }
  end;

implementation

{$R *.DFM}

procedure TSpinDialog.FormShow(Sender: TObject);
begin
    SpinEdit1.Value := TSpinFilter(Target).LoopPixels;
    DirectionGroup.ItemIndex := TSpinFilter(Target).Direction;
end;

procedure TSpinDialog.SpinEdit1Change(Sender: TObject);
begin
    TSpinFilter(Target).LoopPixels := SpinEdit1.Value;
    Modified;
end;

procedure TSpinDialog.DirectionGroupClick(Sender: TObject);
begin
    TSpinFilter(Target).Direction := DirectionGroup.ItemIndex;
    Modified;
end;

end.
