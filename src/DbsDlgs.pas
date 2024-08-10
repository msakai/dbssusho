unit DbsDlgs;

interface

uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinTypes, WinProcs,
{$ENDIF}
  SysUtils, Classes, Forms, Controls, StdCtrls, Buttons, ExtCtrls, Spin,
  PlugIf, Dibas_Classes;

type
  TDibasDialogClass = class of TDibasDialog;
  
  TDibasDialog = class(TForm)
    Panel1: TPanel;
    PreviewBtn: TBitBtn;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    procedure PreviewBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FPreviewed: Boolean;   {"Preview"����x�ł��Ă΂ꂽ��}
    FModified: Boolean;    {�Ō��"Preview"���Ă΂ꂽ��Ƀp�����[�^�ύX���Ȃ��ꂽ���B}
    FCanPreview: Boolean;
    FAutoPreview: Boolean;
    FTarget: TPlugInObject;
  protected
    procedure DoShow; override;
    procedure SetTarget(Value: TPluginObject); virtual;
    procedure SetCanPreview(Value: Boolean); virtual;
  public
    procedure Preview; dynamic;
    procedure Modified; dynamic;
    {�p�����[�^�ɕύX���������Ƃ����̃��\�b�h���Ă΂Ȃ��Ă͂Ȃ�܂���}
    property Target: TPlugInObject read FTarget write SetTarget;
    property CanPreview: Boolean read FCanPreview write SetCanPreview;
    {�v���r���[���\���H}
  end;

resourcestring
    SCancel  = '�L�����Z��';
    SPreview = '�v���r���[';
    
implementation

{$R *.DFM}

procedure TDibasDialog.DoShow;
begin
    inherited;
    PreviewBtn.Visible := CanPreview;
end;

procedure TDibasDialog.Preview;
begin
    if CanPreview and FModified then begin
        FPreviewed := True;
        FModified := False;
        SendMessage(GetParentHandle, DBSM_FILTER_PREVIEW, 0, 0);
    end;
end;

procedure TDibasDialog.Modified;
begin
    if FPreviewed then
       FModified := True;
    if FAutoPreview then
       Preview;
end;

procedure TDibasDialog.SetTarget(Value: TPluginObject);
begin
    if Value <> FTarget then begin
        FTarget := Value;
        FModified := True;
        FPreviewed := False;
    end;
end;

procedure TDibasDialog.SetCanPreview(Value: Boolean);
begin
    FCanPreview := Value;
end;

{------------------------------------------------------------------------------}

procedure TDibasDialog.FormCreate(Sender: TObject);
begin
    CancelBtn.Caption  := SCancel;
    PreviewBtn.Caption := SPreview;
end;

procedure TDibasDialog.OKBtnClick(Sender: TObject);
begin
    if CanPreview and FPreviewed and FModified then
        Preview;
end;

procedure TDibasDialog.PreviewBtnClick(Sender: TObject);
begin
    Preview;
end;

end.
