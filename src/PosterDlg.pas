unit PosterDlg;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  Spin, ExtCtrls,

  Filters, DbsDlgs;

type
  TPosterDialog = class(TDibasDialog)
    PaintBox1: TPaintBox;
    Label4: TLabel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    REdit: TSpinEdit;
    GEdit: TSpinEdit;
    BEdit: TSpinEdit;
    CheckBox1: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure ValueChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    FChanging: Boolean; //パラメータの更新中か
  end;


implementation

{$R *.DFM}


procedure TPosterDialog.FormShow(Sender: TObject);
begin
    FChanging := True;
    with TPosterization(Target) do begin
        REdit.Value := RColors;
        GEdit.Value := GColors;
        BEdit.Value := BColors;
    end;
    FChanging := False;
end;

procedure TPosterDialog.ValueChange(Sender: TObject);
var i: Integer;
begin
    if not FChanging then begin
        i :=  TSpinEdit(Sender).Value;
        with TPosterization(Target) do begin
            if CheckBox1.Checked then begin
                RColors := i;
                GColors := i;
                BColors := i;
            end else begin
                if Sender = REdit then
                    RColors := i
                else if Sender = GEdit then
                    GColors := i
                else if Sender = BEdit then
                    BColors := i;
            end;
            FChanging := True;
            REdit.Value := RColors;
            GEdit.Value := GColors;
            BEdit.Value := BColors;
            FChanging := False;
        end;
        Modified;
    end;
    PaintBox1.Invalidate;
end;

procedure TPosterDialog.PaintBox1Paint(Sender: TObject);
var i, j: Integer;
begin
    with PaintBox1.Canvas do begin

        Brush.Color := clSilver;
        Brush.Style := bsSolid;
        FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
        Pen.Color := clBlack;
        Pen.Style := psSolid;
        Pen.Width := 1;
        Polyline([Point(0, 0),
          Point(0, PaintBox1.Height - 1),
          Point(PaintBox1.Width - 1, PaintBox1.Height - 1),
          Point(PaintBox1.Width - 1, -1)]);
        Pen.Style := psDot;
        Brush.Style := bsClear;
        for i := 1 to 3 do begin
            j := PaintBox1.Width * i div 4;
            MoveTo(j, 0);
            LineTo(j, PaintBox1.Height - 1);
            j := PaintBox1.Height * i div 4;
            MoveTo(0, j);
            LineTo(PaintBox1.Width - 1, j);
        end;

        Pen.Style := psSolid;

        Pen.Color := clRed;
        MoveTo(1, PaintBox1.Height - 2 - TPosterization.DoPoster(0, TPosterization(Target).RColors));
        for i := 0 to 255 do begin
            LineTo(i + 1, PaintBox1.Height - 2 - TPosterization.DoPoster(i, TPosterization(Target).RColors));
        end;

        Pen.Color := clGreen;
        MoveTo(1, PaintBox1.Height - 2 - TPosterization.DoPoster(0, TPosterization(Target).GColors));
        for i := 0 to 255 do begin
            LineTo(i + 1, PaintBox1.Height - 2 - TPosterization.DoPoster(i, TPosterization(Target).GColors));
        end;

        Pen.Color := clBlue;
        MoveTo(1, PaintBox1.Height - 2 - TPosterization.DoPoster(0, TPosterization(Target).BColors));
        for i := 0 to 255 do begin
            LineTo(i + 1, PaintBox1.Height - 2 - TPosterization.DoPoster(i, TPosterization(Target).BColors));
        end;

    end;
end;

{------------------------------------------------------------------------------}







end.
