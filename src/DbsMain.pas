unit DbsMain;

interface

uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinTypes, WinProcs,
{$ENDIF}
  SysUtils, SushoUtils, PlugIf,

{各フィルタのユニット}
  Filters, Artistic, Paint, Wave,
{パラメーター設定用ダイアログ}
  DbsDlgs, SolarDlg, PosterDlg, Channels, GrayScale, SpinDlg, BlowOut, Relief,
  BMPPaint, Diffusion, GlassDlg, WaveDlg, Affine, RGBShift, GradDlg;


{$IFDEF WIN32}
  procedure PlugInfo(var Info: TPlugInfo); stdcall;
  procedure FilterInfo(No: Word; var Info: TFilterInfo); stdcall;
  function  SetParam(No: Word; ParentWindow: hwnd; Pen: WordBool): Integer; stdcall;
  function  Filter(No: Word; var Arg: TFilterArg)     : Integer; stdcall;
  function  Resize(No: Word; var Arg: TResizeArg)     : Integer; stdcall;
  function  Combine(No: Word; var Arg: TCombineArg)   : Integer; stdcall;
  function  Quantize(No: Word; var Arg: TQuantizeArg) : Integer; stdcall;
{$ELSE}
  procedure PlugInfo(var Info: TPlugInfo); export;
  procedure FilterInfo(No: Word; var Info: TFilterInfo); export;
  function  SetParam(No: Word; ParentWindow: hwnd; Pen: WordBool): Integer; export;
  function  Filter(No: Word; var Arg: TFilterArg)     : Integer; export;
  function  Resize(No: Word; var Arg: TResizeArg)     : Integer; export;
  function  Combine(No: Word; var Arg: TCombineArg)   : Integer; export;
  function  Quantize(No: Word; var Arg: TQuantizeArg) : Integer; export;
{$ENDIF}


implementation

uses Dibas_Classes, DibasRes;

const FilterCount = 30;

var FilterArray: array[1..FilterCount] of TPlugInObject;
    DialogArray: array[1..FilterCount] of TDibasDialogClass;


function GetPlugInObject(ID: Integer): TPlugInObject;
begin
    if (ID >= 1) and (ID <= FilterCount) then
        Result := FilterArray[ID]
    else
        Result := nil;
end;

procedure ExitProc;
var i: Integer;
begin
    for i := 1 to FilterCount do
        FilterArray[i].Free;
end;

{ Export関数 }

procedure PlugInfo;
begin
    with Info do begin
	version  := IFPLUG_VERSION;
	nEntries := FilterCount;        {プラグインに含まれる機能の数}
	aboutID  := PLUGIN_DESCRIPTION; {プラグインの説明のリソースＩＤ}
    end;
end;

procedure FilterInfo;
var Obj: TPlugInObject;
    Info2: TFilterInfo;
begin
    Obj := GetPlugInObject(No);
    if Assigned(Obj) then begin
        Obj.GetInfo(Info2);
        with Info do begin
            NameID := No; {フィルター機能名のリソースID }
            
            FilterType := Info2.FilterType;

            Flag := 0;
            if ffOneShot in Info2.Flags then
                Flag := Flag or FF_ONESHOT;
            if ffUseMask in Info2.Flags then
                Flag := Flag or FF_USEMASK;
            if not (ffUseParam in Info2.Flags) then
                Flag := Flag or FF_NOPARAM;
            if (ffUsePen in Info2.Flags) and (not (ffUseMenu in Info2.Flags)) then
                Flag := Flag or FF_PENONLY;
            if (not (ffUsePen in Info2.Flags)) and (ffUseMenu in Info2.Flags) then
                Flag := Flag or FF_MENUONLY;
            { Bitmapリソース }
            case No of
              ID_GRAYSCALE, ID_POSTERIZE, ID_SOLARIZATION, ID_COPYCHANNEL,
              ID_DEFFUSION, ID_MARKERPAINT, ID_BMPPAINT, ID_GRADATIONPAINT,
              ID_RGBSHIFT, ID_MONOTONE, ID_DUALTONE: bitmapID := No;
            end;
        end;
    end;
end;


function SetParam;
var DialogClass: TDibasDialogClass;
    Dlg: TDibasDialog;
    hFont1: HFONT;
begin
    DialogClass := DialogArray[No];
    if Assigned(DialogClass) then begin
        Dlg := DialogClass.CreateParented(ParentWindow);
        try
            hFont1 := SendMessage(ParentWindow, DBSM_GET_TOOLFONT, 0, 0);
            if Pen and (hFont1=0) then
                hFont1 := SendMessage(GetParent(ParentWindow), DBSM_GET_TOOLFONT, 0, 0);
            Dlg.Font.Handle := CopyFont(hFont1);
            Dlg.Target      := GetPlugInObject(No);
            Dlg.Caption     := LoadStr(No);
            Dlg.CanPreview  := not Pen;
            case Dlg.ShowModal of
              idOK: Result := FTR_OK;
              idCancel: Result := FTR_CANCEL;
              else Result := FTR_FAIL;
            end;
        finally
            Dlg.Free;
        end;
    end else
        Result := FTR_FAIL;
end;


function Filter;
var Obj: TPlugInObject;
begin
    Obj := GetPlugInObject(No);
    if Obj is TFilter then
        Result := TFilter(Obj).Apply(Arg)
    else
        Result := FTR_FAIL;
end;


function Resize;
var Obj: TPlugInObject;
begin
    Obj := GetPlugInObject(No);
    if Obj is TResize then
        Result := TResize(Obj).Apply(Arg)
    else
        Result := FTR_FAIL;
end;


function Combine;
var Obj: TPlugInObject;
begin
    Obj := GetPlugInObject(No);
    if Obj is TCombine then
        Result := TCombine(Obj).Apply(Arg)
    else
        Result := FTR_FAIL;
end;


function Quantize;
var Obj: TPlugInObject;
begin
    Obj := GetPlugInObject(No);
    if Obj is TQuantize then
        Result := TQuantize(Obj).Apply(Arg)
    else
        Result := FTR_FAIL;
end;

{------------------------------------------------------------------------------}

initialization
//フィルタのリストに登録
  FilterArray[ID_MARKERPAINT]    := TMarkerPaint.Create;
  FilterArray[ID_BMPPAINT]       := TBMPPaint.Create;
  FilterArray[ID_AVERAGEPAINT]   := TAveragePaint.Create;
  FilterArray[ID_PATTERNPAINT]   := TPatternPaint.Create;
  FilterArray[ID_GRADATIONPAINT] := TGradationPaint.Create;

  FilterArray[ID_GRAYSCALE]    := TGrayScaleFilter.Create;
  FilterArray[ID_POSTERIZE]    := TPosterization.Create;
  FilterArray[ID_SOLARIZATION] := TSolarizationFilter.Create;
  FilterArray[ID_COPYCHANNEL]  := TCopyChannel.Create;
  FilterArray[ID_DUALTONE]     := TDualTone.Create;
  FilterArray[ID_MONOTONE]     := TMonoTone.Create;
  FilterArray[ID_RGBSHIFT]     := TRGBShift.Create;

  FilterArray[ID_DEFFUSION]    := TDiffusionFilter.Create;
  FilterArray[ID_WAVE]         := TWaveTransform.Create;
  FilterArray[ID_SPIN]         := TSpinFilter.Create;
  FilterArray[ID_BLOWOUT]      := TBlowOutFilter.Create;
  FilterArray[ID_SPLASH]       := TSplashFilter.Create;

  FilterArray[ID_RECTTOPOLOR]  := TRectToPolor.Create;
  FilterArray[ID_RELIEF]       := TReliefFilter.Create;
  FilterArray[ID_DOTPAINT]     := TDotPaint.Create;
  FilterArray[ID_GLASSFILTER]  := TGlassFilter.Create;
  FilterArray[ID_TUNNEL]       := TTunnel.Create;
  FilterArray[ID_LOZENGE]      := TLozenge.Create;
  FilterArray[ID_AFFINE]       := TAffineTransform.Create;
  FilterArray[ID_SPHERE]       := TSphere.Create;

  FilterArray[ID_CMYADD]       := TCMYAddCombine.Create;
  FilterArray[ID_CMYMULTIPLE]  := TCMYMultipleCombine.Create;
  FilterArray[ID_AND]          := TAndCombine.Create;
  FilterArray[ID_OR]           := TOrCombine.Create;

  FilterArray[ID_RANDOMDITHER] := TRandomDither.Create;


//ダイアログの登録
  DialogArray[ID_BMPPAINT]       := TBMPPaintDlg;
  DialogArray[ID_PATTERNPAINT]   := TBMPPaintDlg;
  DialogArray[ID_GRADATIONPAINT] := TGradationDialog;

  DialogArray[ID_GRAYSCALE]    := TGrayScaleDlg;
  DialogArray[ID_POSTERIZE]    := TPosterDialog;
  DialogArray[ID_SOLARIZATION] := TSolarizationDlg;
  DialogArray[ID_COPYCHANNEL]  := TCopyChannelDlg;
  DialogArray[ID_RGBSHIFT]     := TRGBShiftDialog;

  DialogArray[ID_DEFFUSION]    := TDiffusionDlg;
  DialogArray[ID_WAVE]         := TWaveDialog;
  DialogArray[ID_SPLASH]       := TWaveDialog;
  DialogArray[ID_SPIN]         := TSpinDialog;
  DialogArray[ID_BLOWOUT]      := TBlowOutDlg;

  DialogArray[ID_RELIEF]       := TReliefDlg;
  DialogArray[ID_GLASSFILTER]  := TGlassDialog;

  DialogArray[ID_AFFINE]       := TAffineDlg;
finalization
    ExitProc;
end.
