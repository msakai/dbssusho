{
    Susho's Filters Plug-in for Dibas version 0.30
    Copyright (C) 1999  Masahiro Sakai <ZVM01052@nifty.ne.jp>
}

{
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}


library Susho;

uses
  DbsDlgs in 'DbsDlgs.pas' {DibasDialog},
  PosterDlg in 'PosterDlg.pas' {PosterDialog},
  Channels in 'Channels.pas' {CopyChannelDlg},
  SolarDlg in 'SolarDlg.pas' {SolarizationDlg},
  GrayScale in 'GrayScale.pas' {GrayScaleDlg},
  WaveDlg in 'WaveDlg.pas' {WaveDialog},
  Diffusion in 'Diffusion.pas' {DiffusionDlg},
  Affine in 'Affine.pas' {AffineDlg},
  SpinDlg in 'SpinDlg.pas' {SpinDialog},
  BMPPaint in 'BMPPaint.pas' {BMPPaintDlg},
  Relief in 'Relief.pas' {ReliefDlg},
  BlowOut in 'BlowOut.pas' {BlowOutDlg},
  GlassDlg in 'GlassDlg.pas' {GlassDialog},
  RGBShift in 'RGBShift.pas' {RGBShiftDialog},
  GradDlg in 'GradDlg.pas' {GradationDialog},
  DbsMain in 'DbsMain.pas',
  DibasRes in 'DibasRes.pas',
  Filters in 'Filters.pas',
  Artistic in 'Artistic.pas',
  Paint in 'Paint.pas',
  Wave in 'Wave.pas';

{$R *.RES}

exports
  PlugInfo   name 'PlugInfo',
  SetParam   name 'SetParam',
  FilterInfo name 'FilterInfo',
  Filter     name 'Filter',
  Resize     name 'Resize',
  Combine    name 'Combine',
  Quantize   name 'Quantize';
{$IFDEF WIN32}
  {$E f32}
{$ENDIF}


begin
end.
