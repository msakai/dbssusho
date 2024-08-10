unit BMPPaint;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ClipBrd, Dialogs,
  NkDib,

  Paint, DbsDlgs;

type
  TBMPPaintDlg = class(TDibasDialog)
    OpenDialog: TOpenDialog;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure FromFileClick(Sender: TObject);
    procedure FromClipBoardClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private �錾 }
    procedure UpdatePaintBox;
  public
    { Public �錾 }
  end;


implementation

{$R *.DFM}

procedure TBMPPaintDlg.FormShow(Sender: TObject);
begin
    inherited;
    UpdatePaintBox;
end;

procedure TBMPPaintDlg.FromFileClick(Sender: TObject);
begin
    if OpenDialog.Execute then begin
        TCustomBitmapPaint(Target).Dib.LoadFromFile(OpenDialog.FileName);
        UpdatePaintBox;
        Modified;
    end;
end;

procedure TBMPPaintDlg.FromClipBoardClick(Sender: TObject);
begin
    if Clipboard.HasFormat(CF_DIB) then begin
        TCustomBitmapPaint(Target).Dib.Assign(ClipBoard);
        UpdatePaintBox;
        Modified;
    end else
        ShowMessage('�N���b�v�{�[�h�Ƀr�b�g�}�b�v������܂���');
end;

procedure TBMPPaintDlg.ClearClick(Sender: TObject);
begin
    TCustomBitmapPaint(Target).Dib.Assign(nil);
    UpdatePaintBox;
    Modified;
end;

procedure TBMPPaintDlg.PaintBox1Paint(Sender: TObject);
begin
    PaintBox1.Canvas.Draw(0, 0, TCustomBitmapPaint(Target).Dib);
end;

procedure TBMPPaintDlg.UpdatePaintBox;
begin
    PaintBox1.Width := TCustomBitmapPaint(Target).Dib.Width;
    PaintBox1.Height := TCustomBitmapPaint(Target).Dib.Height;
    PaintBox1.Invalidate;
end;


end.
