unit RGBShift;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DbsDlgs, StdCtrls, Buttons, ExtCtrls,

  Filters;

type
  TRGBShiftDialog = class(TDibasDialog)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RBar: TScrollBar;
    GBar: TScrollBar;
    BBar: TScrollBar;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RLabel: TLabel;
    GLabel: TLabel;
    BLabel: TLabel;
    Shape1: TShape;
    procedure FormShow(Sender: TObject);
    procedure ShiftBarChange(Sender: TObject);
  private
    { Private êÈåæ }
    FOnChanging: Boolean;
  public
    { Public êÈåæ }
    procedure UpDateLabel;
  end;

implementation

{$R *.DFM}

procedure TRGBShiftDialog.UpDateLabel;
begin
    with Target as TRGBShift do begin
        RLabel.Caption := IntToStr(RShift);
        GLabel.Caption := IntToStr(GShift);
        BLabel.Caption := IntToStr(BShift);
        Shape1.Brush.Color := RGB(RShift div 2 + 128, GShift div 2 + 128, BShift div 2 + 128);
    end;
end;

procedure TRGBShiftDialog.FormShow(Sender: TObject);
begin
    inherited;
    with Target as TRGBShift do begin
        FOnChanging := True;
        RBar.Position := RShift;
        GBar.Position := GShift;
        BBar.Position := BShift;
        UpDateLabel;
        FOnChanging := False;
    end;
end;

procedure TRGBShiftDialog.ShiftBarChange(Sender: TObject);
begin
    inherited;
    if not FOnChanging then begin
        with Target as TRGBShift do begin
            RShift := RBar.Position;
            GShift := GBar.Position;
            BShift := BBar.Position;
            UpDateLabel;
        end;
        Modified;
    end;
end;



end.
