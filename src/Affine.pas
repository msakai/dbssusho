unit Affine;

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Buttons, ExtCtrls, Dialogs, Grids,
  DbsDlgs, Filters;

type
  TAffineDlg = class(TDibasDialog)
    Label1: TLabel;
    ParamGrid: TStringGrid;
    procedure ParamGridExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;


implementation

{$R *.DFM}


procedure TAffineDlg.FormShow(Sender: TObject);
begin
    inherited;
{位置あわせ}
    Label1.Left := ParamGrid.Left + ParamGrid.Width + 10;
{パラメータの代入}
    with ParamGrid, TAffineTransform(Target) do begin
        Cells[0, 1] := 'a';
        Cells[0, 2] := 'b';
        Cells[0, 3] := 'c';
        Cells[0, 4] := 'd';
        Cells[0, 5] := 'e';
        Cells[0, 6] := 'f';
        Cells[1, 0] := 'Value';
        Cells[1, 1] := FloatToStrF(a, ffGeneral, 5, 2);
        Cells[1, 2] := FloatToStrF(b, ffGeneral, 5, 2);
        Cells[1, 3] := FloatToStrF(c, ffGeneral, 5, 2);
        Cells[1, 4] := FloatToStrF(d, ffGeneral, 5, 2);
        Cells[1, 5] := FloatToStrF(e, ffGeneral, 5, 2);
        Cells[1, 6] := FloatToStrF(f, ffGeneral, 5, 2);
    end;
end;


procedure TAffineDlg.ParamGridExit(Sender: TObject);
begin
    try
        with ParamGrid, TAffineTransform(Target) do begin
            a := StrToFloat(Cells[1, 1]);
            b := StrToFloat(Cells[1, 2]);
            c := StrToFloat(Cells[1, 3]);
            d := StrToFloat(Cells[1, 4]);
            e := StrToFloat(Cells[1, 5]);
            f := StrToFloat(Cells[1, 6]);
        end;
    except
      on E: EConvertError do begin
          ShowMessage(E.Message);
          ParamGrid.SetFocus;
      end;
    end;
    Modified;
end;

end.
