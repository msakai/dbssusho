unit Channels;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls,

  DbsDlgs, Filters;

type
  TCopyChannelDlg = class(TDibasDialog)
    AGroup: TRadioGroup;
    BGroup: TRadioGroup;
    CheckBox1: TCheckBox;
    RadioGroup1: TRadioGroup;
    procedure ChannelGroupClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;


implementation

{$R *.DFM}


procedure TCopyChannelDlg.FormShow(Sender: TObject);
begin
    inherited;
    BGroup.Items.Assign(AGroup.Items);
    with TCopyChannel(Target) do begin
        AGroup.ItemIndex  := Integer(Channel1);
        BGroup.ItemIndex  := Integer(Channel2);
        CheckBox1.Checked := Flag1;
        if Flag2 then
            RadioGroup1.ItemIndex := 1
        else
            RadioGroup1.ItemIndex := 0;
    end;
end;

procedure TCopyChannelDlg.ChannelGroupClick(Sender: TObject);
begin
    with TCopyChannel(Target) do begin
        Channel1 := TChannel(AGroup.ItemIndex);
        Channel2 := TChannel(BGroup.ItemIndex);
    end;
    Modified;
end;

procedure TCopyChannelDlg.CheckBox1Click(Sender: TObject);
begin
    TCopyChannel(Target).Flag1 := CheckBox1.Checked;
    Modified;
end;

procedure TCopyChannelDlg.RadioGroup1Click(Sender: TObject);
begin
    with TCopyChannel(Target) do begin
        Flag2 := (RadioGroup1.ItemIndex=1);
    end;
    Modified;
end;

end.
