unit GrayScale;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls,

  DbsDlgs, Filters;

type
  TGrayScaleDlg = class(TDibasDialog)
    FilterGroup: TRadioGroup;
    procedure FilterGroupClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

implementation

{$R *.DFM}


procedure TGrayScaleDlg.FormShow(Sender: TObject);
begin
    FilterGroup.ItemIndex := Integer(TGrayScaleFilter(Target).GrayScaleType);
end;

procedure TGrayScaleDlg.FilterGroupClick(Sender: TObject);
begin
    if TGrayScaleFilter(Target).GrayScaleType <> TGrayScaleType(FilterGroup.ItemIndex) then begin
        TGrayScaleFilter(Target).GrayScaleType := TGrayScaleType(FilterGroup.ItemIndex);
        Modified;
    end;
end;

end.
