unit PlugIf;

interface

uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinTypes,
{$ENDIF}
  SysUtils, Messages;

{$IFNDEF WIN32}
  type
    UINT  = Integer;
    DWORD = LongInt;
    WPARAM = Longint;
    LPARAM = Longint;
    PRGBQuad = ^TRGBQuad;
    TRGBQuad = packed record
      rgbBlue: Byte;
      rgbGreen: Byte;
      rgbRed: Byte;
      rgbReserved: Byte;
    end;
{$ENDIF}


{ Transrated from Plugif.h }

const
  IFPLUG_VERSION = 1;       { �C���^�[�t�F�[�X�̃o�[�W�����ԍ� }

  { result code }
  FTR_OK     =  0;          { ����I�� }
  FTR_FAIL   = -1;          { �G���[�I�� }
  FTR_CANCEL =  1;          { ���[�U�ɂ���Ē��f }


type
{ �v���Z�X�\�������f��荇�킹�p�֐��B

 �t�B���^�[�@�\���s���ɒ���I�ɌĂяo���̂��]�܂����B��O���A�����ꍇ��
 �����𒆒f���邱�ƁB

 IN:  pos     �������̈ʒu�������l
      total   �ő�ʒu�������l
 OUT:         ���[�U�����f�{�^�����������Ȃ��O�A
              �����ĂȂ���΂O��Ԃ��B

 �g�p��

    for y := 0 to height-1 do begin
        if Arg.Abortfunc(y, height) <> FTR_OK then begin
            �㏈��
            Result := FTR_CANCEL;
            Exit;
        end;
        ... �t�B���^�[����
    end;
}

{$IFDEF WIN32}
  TAbortfunc = function(pos, total: Word): Word; stdcall;
{$ELSE}
  TAbortfunc = function(pos, total: Word): Word;
{$ENDIF}


{ �摜�f�[�^�A�}�X�N�f�[�^�ւ̂Q�����z��B

  �摜�f�[�^�̏ꍇ�@�F �� := data[y][x * 3 + 0]
                       �� := data[y][x * 3 + 1]
                       �� := data[y][x * 3 + 2] �ŃA�N�Z�X����B

  �}�X�N�f�[�^�̏ꍇ�F �}�X�N�l := data[y][x]
                       �}�X�N�l���O�̃f�[�^�Ɋւ��Ă͏������Ȃ��Ă悢�B
                       (�������Ă��e���͂Ȃ��j}
type
  PScanLines  = ^TScanLines;
  TScanLines = array[0..10000] of PByteArray;


{ plugin flag }
const
  PLGF_LOCKDLL = $0001;     { DLL�𖢎g�p���ɃA�����[�h���Ȃ� }

type
  PPlugInfo = ^TPlugInfo;
  TPlugInfo = packed record
    version    : Word;   { OUT: IFPLUG_VERSION }
    nEntries   : Word;   { OUT: number of plug-in entries in this DLL }
    aboutID    : Word;   { OUT: resource string-ID of description
                                about plugin }
    flag       : Word;   { OUT: plugin flag }
  end;

{Filter Plugin Interface}
const
  FT_PAINT     =  1;        { �t�B���^�[�F�h��ׂ��n }
  FT_COLOR     =  2;        { �t�B���^�[�F�K���ύX�n }
  FT_SHARP     =  3;        { �t�B���^�[�F��s���n }
  FT_SMOOTH    =  4;        { �t�B���^�[�F�������n }
  FT_NOISE     =  5;        { �t�B���^�[�F�m�C�Y�n }
  FT_RESERVED1 =  6;        { �t�B���^�[�F�\�� }
  FT_RESERVED2 =  7;        { �t�B���^�[�F�\�� }
  FT_RESERVED3 =  8;        { �t�B���^�[�F�\�� }
  FT_VISUAL    =  9;        { �t�B���^�[�F���o���ʌn }
  FT_EDGE      = 10;        { �t�B���^�[�F�֊s���o�n }
  FT_SPECIAL   = 11;        { �t�B���^�[�F����ȗp�r�n }
  FT_OTHER     = 12;        { �t�B���^�[�F���̑� }

{ �T�C�Y�ύX ([�ҏW]-[�T�C�Y�ύX]) }
  FT_RESIZE    = 13;        { �T�C�Y�ύX }

{ �摜�̍��� (�����c�[���A�����y��) }
  FT_COMBINE   = 14;        { ���� }

{ ���F       ([�ҏW]-[���F]) }
  FT_QUANT256  = 15;        { ���F�F�Q�T�U�F�ȉ� }
  FT_QUANT16   = 16;        { ���F�F�P�U�F�ȉ� }
  FT_QUANT2    = 17;        { ���F�F�Q�F�ȉ� }
  FT_QUANTDSP  = 18;        { ���F�F�\�� }

{ filter flag }
const
  FF_MENUONLY  = $0001;   { ���j���[�ł����g����t�B���^�[ }
  FF_PENONLY   = $0002;   { [�y���@�\]�ł����g����t�B���^�[ }
  FF_ONESHOT   = $0004;   { �d�ˏ������� }
  FF_NOPARAM   = $0008;   { �p�����[�^�[�ݒ�Ȃ� }
  FF_USEMASK   = $0010;   { mask�f�[�^���g�p }

type
  PFilterInfo = ^TFilterInfo;
  TFilterInfo = packed record
    FilterType : Word;     { OUT: filter type }
    Flag       : Word;     { OUT: filter flag }
    NameID     : Word;     { OUT: resource string-ID of filter name }
    BitmapID   : Word;     { OUT: resource bitmap-ID of filter (optional) }
  end;

  PFilterArg = ^TFilterArg;
  TFilterArg = packed record
    Abortfunc : TAbortfunc;  { IN:  query abort function }
    inData    : PScanLines;  { IN:  source data (B,G,R ordered 24bits data) }
    outData   : PScanLines;  { OUT: result data (B,G,R ordered 24bits data) }
    mask      : PScanLines;  { IN:  mask data (8 bits data) }
    xInData   : Word;        { IN:  left pixel of inData }
    yInData   : Word;        { IN:  top pixel of inData }
    cxData    : Word;        { IN:  result data width }
    cyData    : Word;        { IN:  result data height }
    fgColor   : LongInt;     { IN:  current foreground color }
    bgColor   : LongInt;     { IN:  current background color }
    cxInData  : Word;        { IN:  width of inData }
    cyInData  : Word;        { IN:  height of inData }
  end;

  PResizeArg = ^TResizeArg;
  TResizeArg = packed record
    Abortfunc : TAbortfunc;  { IN:  query abort function }
    inData    : PScanLines;  { IN:  source data (B,G,R ordered 24bits data) }
    cxIn      : Word;        { IN:  source data width }
    cyIn      : Word;        { IN:  source data height }
    outData   : PScanLines;  { OUT: result data (B,G,R ordered 24bits data) }
    cxOut     : Word;        { IN:  destination data width }
    cyOut     : Word;        { IN:  destination data height }
  end;
  
  PCombineArg = ^TCombineArg;
  TCombineArg = packed record
    Abortfunc : TAbortfunc;  { IN:  query abort function }
    inData1   : PScanLines;  { IN:  source data (B,G,R ordered 24bits data) }
    xInData1  : Word;        { IN:  left pixel of inData }
    yInData1  : Word;        { IN:  top pixel of inData }
    inData2   : PScanLines;  { IN:  source data (B,G,R ordered 24bits data) }
    xInData2  : Word;        { IN:  left pixel of inData }
    yInData2  : Word;        { IN:  top pixel of inData }
    outData   : PScanLines;  { OUT: result data (B,G,R ordered 24bits data) }
    cxData    : Word;        { IN:  data width }
    cyData    : Word;        { IN:  data height }
  end;

  PQuantizeArg = ^TQuantizeArg;
  TQuantizeArg = packed record
    Abortfunc : TAbortfunc;  { IN:  query abort function }
    inData    : PScanLines;  { IN:  source data (B,G,R ordered 24bits data) }
    outData   : PScanLines;  { OUT: result data (8 bits color index data) }
    outRGB    : PRGBQUAD;    { OUT: color palette }
    cxData    : Word;        { IN:  data width }
    cyData    : Word;        { IN:  data height }
    mask      : PScanLines;  { IN:  mask data (8 bits data) }
  end;

  TDialogInfo = packed record
    dlgName   : PChar;      { OUT: dialog template name }
    paramSize : DWORD;      { OUT: size of parameter contents }
    dlgProc   : TFNDlgProc; { OUT: dialog procedure address (optional) }
    lParam    : LPARAM;     { OUT: dialog argument (optional) }
    helpFile  : PChar;      { OUT: help file name (optional) }
    contextID : DWORD;      { OUT: help context-ID (optional) }
  end;



{ Transrated from Sample01.txt }

const
  DBSM_FILTER_PREVIEW  = WM_USER + 100;
{ SetParam()�Ăяo������Filter()���Ăяo���Ă��炤�B
  SetParam()��FTR_OK��Ԃ��ƃv���r���[���̃f�[�^�����̂܂�
  �������ʂƂ��Ďg�p���ASetParam()���Filter()�̌Ăяo����
  �X�L�b�v�����B
  �v���r���[�Ŏg�p�B}

  DBSM_GET_PALETTE = WM_USER + 101;
{ �摜�\���p�̃p���b�g��Ԃ��B256�F���łȂ���΁A�O��Ԃ��B
  (���̃p���b�g�͍폜���Ă͂����Ȃ��B)
  16�F���F�ō쐬�����F�̈ꗗ��\�����邽�߂Ɏg�p }

  DBSM_GET_NEARESTCOLOR  = WM_USER + 102;
{ �摜�\���p�̃p���b�g�̒�����A�����œn�����F�Ɉ�ԋ߂�
  �F��T���ĕԂ��B256�F���łȂ���Έ��������̂܂ܕԂ�B
  16�F���F�ō쐬�����F�̈ꗗ��\�����邽�߂Ɏg�p�B}


  DBSM_GET_TOOLFONT = WM_USER + 103;
{ [�ݒ�]-[���̑��̃E�B���h�E�t�H���g]�Ŏw�肳�ꂽ�t�H���g��
  �Ԃ��B(���̃t�H���g�͍폜���Ă͂����Ȃ��B)
  �_�C�A���O�̃t�H���g�𑼂̃E�B���h�E�ƍ��킹�邽�߂Ɏg�p�B}

implementation

end.
