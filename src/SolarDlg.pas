unit SolarDlg;

interface

uses  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  Spin, ExtCtrls,

  DbsDlgs, Filters;

type
  TSolarizationDlg = class(TDibasDialog)
    Label1: TLabel;
    ScrollBar1: TScrollBar;
    SpinEdit1: TSpinEdit;
    procedure ScrollBar1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private êÈåæ }
    FOnChanging: Boolean;{çXêVíÜ}
  end;

implementation

{$R *.DFM}

procedure TSolarizationDlg.FormShow(Sender: TObject);
begin
    { à íuÇ†ÇÌÇπ }
    ScrollBar1.Left := Label1.BoundsRect.Right + 10;
    SpinEdit1.Left := ScrollBar1.BoundsRect.Right + 10;

    FOnChanging := True;
    with TSolarizationFilter(Target) do begin
        ScrollBar1.Position := SplitValue;
        SpinEdit1.Value := SplitValue;
    end;
    FOnChanging := False;
end;

procedure TSolarizationDlg.ScrollBar1Change(Sender: TObject);
begin
    if not FOnChanging then begin
        FOnChanging := True;
        with TSolarizationFilter(Target) do begin
            SplitValue := TScrollBar(Sender).Position;
            SpinEdit1.Value := SplitValue;
        end;
        FOnChanging := False;
        Modified;
    end;
end;

procedure TSolarizationDlg.Edit1Change(Sender: TObject);
begin
    if not FOnChanging then begin
        FOnChanging := True;
        with TSolarizationFilter(Target) do begin
            SplitValue := SpinEdit1.Value;
            ScrollBar1.Position := SplitValue;
        end;
        FOnChanging := False;
        Modified;
    end;
end;

end.
