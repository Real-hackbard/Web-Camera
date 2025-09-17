unit VFrames;
interface
USES Windows, Messages, Controls, Forms, SysUtils, Graphics, Classes,
     AppEvnts, MMSystem, DirectShow9, JPEG,
     VSample;
CONST
  CBufferCnt = 3;
TYPE
  TNewVideoFrameEvent = procedure(Sender : TObject; Width, Height: integer; DataPtr: pointer) of object;
  TVideoProperty = (VP_Brightness,
                    VP_Contrast,
                    VP_Hue,
                    VP_Saturation,
                    VP_Sharpness,
                    VP_Gamma,
                    VP_ColorEnable,
                    VP_WhiteBalance,
                    VP_BacklightCompensation,
                    VP_Gain);
  TVideoImage = class
                  private
                    VideoSample   : TVideoSample;
                    OnNewFrameBusy: boolean;
                    fVideoRunning : boolean;
                    fBusy         : boolean;
                    fSkipCnt      : integer;
                    fFrameCnt     : integer;
                    f30FrameTick  : cardinal;
                    fFPS          : double;  
                    fWidth,
                    fHeight       : integer;
                    fFourCC       : cardinal;
                    fBitmap       : TBitmap;
                    fDisplayCanvas: TCanvas;
                    fImagePtr     : ARRAY[0..CBufferCnt] OF pointer; 
                    fImagePtrSize : ARRAY[0..CBufferCnt] OF integer;
                    fImagePtrIndex: integer;
                    fMessageHWND  : HWND;
                    fMsgNewFrame  : uint;
                    fOnNewFrame   : TNewVideoFrameEvent;
                    AppEvent      : TApplicationEvents;
                    IdleEventTick : cardinal;
                    ValueY_298,
                    ValueU_100,
                    ValueU_516,
                    ValueV_409,
                    ValueV_208    : ARRAY[byte] OF integer;
                    ValueClip     : ARRAY[-1023..1023] OF byte;
                    fYUY2TablesPrepared : boolean;
                    JPG           : TJPEGImage;
                    MemStream     : TMemoryStream;
                    fImageUnpacked: boolean;
                    procedure     PaintFrame;
                    procedure     UnpackFrame(Size: integer; pData: pointer);
                    procedure     WndProc(var Msg: TMessage);
                    function      VideoSampleIsPaused: boolean;
                    procedure     AppEventsIdle(Sender: TObject; var Done: Boolean);
                    procedure     CallBack(pb : pbytearray; var Size: integer);
                    function      TranslateProperty(const VP: TVideoProperty; VAR VPAP: TVideoProcAmpProperty): HResult;
                    PROCEDURE     PrepareTables;
                    procedure     YUY2_to_RGB(pData: pointer);
                    procedure     I420_to_RGB(pData: pointer);
                  public
                    constructor   Create;
                    destructor    Destroy; override;
                    procedure     Free;
                    property      IsPaused: boolean read VideoSampleIsPaused;
                    property      VideoRunning : boolean read fVideoRunning;
                    property      VideoWidth: integer read fWidth;
                    property      VideoHeight: integer read fHeight;
                    property      OnNewVideoFrame : TNewVideoFrameEvent read fOnNewFrame write fOnNewFrame;
                    property      FramesPerSecond: double read fFPS;
                    property      FramesSkipped: integer read fSkipCnt;
                    procedure     GetListOfDevices(DeviceList: TStringList);
                    procedure     VideoStop;
                    procedure     VideoPause;
                    procedure     VideoResume;
                    function      VideoStart(DeviceName: string): integer;
                    procedure     GetBitmap(BMP: TBitmap);
                    procedure     SetDisplayCanvas(Canvas: TCanvas);
                    procedure     ShowProperty;
                    procedure     ShowProperty_Stream;
                    FUNCTION      ShowVfWCaptureDlg: HResult;
                    procedure     GetBrightnessSettings(VAR Actual: integer);
                    procedure     SetBrightnessSettings(const Actual: integer);
                    PROCEDURE     GetListOfSupportedVideoSizes(VidSize: TStringList);
                    PROCEDURE     SetResolutionByIndex(Index: integer);
                    FUNCTION      GetVideoPropertySettings(    VP                : TVideoProperty;
                                                           VAR MinVal, MaxVal,
                                                               StepSize, Default,
                                                               Actual            : integer;
                                                           VAR AutoMode: boolean): HResult;
                    FUNCTION      SetVideoPropertySettings(VP: TVideoProperty; Actual: integer; AutoMode: boolean): HResult;
                end;
FUNCTION GetVideoPropertyName(VP: TVideoProperty): string;
CONST
  FourCC_YUY2 = $32595559;
  FourCC_YUYV = $56595559;
  FourCC_YUNV = $564E5559;
  FourCC_MJPG = $47504A4D;
  FourCC_I420 = $30323449;
  FourCC_YV12 = $32315659;
  FourCC_IYUV = $56555949;
implementation
FUNCTION GetVideoPropertyName(VP: TVideoProperty): string;
BEGIN
  CASE VP OF
    VP_Brightness           : Result := 'Brightness';
    VP_Contrast             : Result := 'Contrast';
    VP_Hue                  : Result := 'Hue';
    VP_Saturation           : Result := 'Saturation';
    VP_Sharpness            : Result := 'Sharpness';
    VP_Gamma                : Result := 'Gamma';
    VP_ColorEnable          : Result := 'ColorEnable';
    VP_WhiteBalance         : Result := 'WhiteBalance';
    VP_BacklightCompensation: Result := 'Backlight';
    VP_Gain                 : Result := 'Gain';
  END; 
END;
procedure TVideoImage.CallBack(pb : pbytearray; var Size: integer);
var
  i  : integer;
  T1 : cardinal;
begin
  Inc(fFrameCnt);
  T1 := TimeGetTime;
  IF fFrameCnt mod 30 = 0 then
    begin
      if f30FrameTick > 0 then
        fFPS := 30000 / (T1-f30FrameTick);
      f30FrameTick := T1;
    end;
  IF Abs(T1-IdleEventTick) > 1000 then
    begin
      Inc(fSkipCnt);
      exit;
    end;
  i := (fImagePtrIndex+1) mod CBufferCnt;
  IF fImagePtrSize[i] <> Size then
    begin
      IF fImagePtrSize[i] > 0 then
        FreeMem(fImagePtr[i], fImagePtrSize[i]);
      fImagePtrSize[i] := Size;
      GetMem(fImagePtr[i], fImagePtrSize[i]);
    end;
  move(pb^, fImagePtr[i]^, Size);
  fImagePtrIndex := i;
  fImageUnpacked := false;
  PostMessage(fMessageHWND, fMsgNewFrame, Size, integer(fImagePtr[i]));
  sleep(0);
end;
procedure TVideoImage.WndProc(var Msg: TMessage);
begin
  with Msg do
    if Msg = fMsgNewFrame then
      try
        IF not fBusy then
          begin
            fBusy := true;
            fImageUnpacked := false;
            PaintFrame; 
            IF assigned(fOnNewFrame) then
              fOnNewFrame(self, fWidth, fHeight, fImagePtr[fImagePtrIndex]);
            fBusy := false;
          end
          else Inc(fSkipCnt);
      except
        Application.HandleException(Self);
        fBusy := false;
      end
    else Result := DefWindowProc(fMessageHWND, Msg, wParam, lParam);
end;
constructor TVideoImage.Create;
VAR
  i : integer;
begin
  inherited Create;
  fVideoRunning   := false;
  OnNewFrameBusy  := false;
  fBitmap         := TBitmap.Create;
  fDisplayCanvas  := nil;
  fWidth          := 0;
  fHeight         := 0;
  fFourCC         := 0;
  FOR i := 0 TO CBufferCnt-1 DO
    BEGIN
      fImagePtr[i]     := nil; 
      fImagePtrSize[i] := 0;
    END;
  fMsgNewFrame    := wm_user+662;
  fOnNewFrame     := nil;
  fBusy           := false;
  fMessageHWND    := AllocateHWND(WndProc);
  AppEvent        := TApplicationEvents.Create(Application.MainForm);
  AppEvent.OnIdle := AppEventsIdle;
  JPG             := TJPEGImage.Create;
  MemStream       := TMemoryStream.Create;
end;
procedure TVideoImage.AppEventsIdle(Sender: TObject; var Done: Boolean);
begin
  IdleEventTick := TimeGetTime;
  Done := true;
end;
destructor  TVideoImage.Destroy;
VAR
  i : integer;
begin
  FOR i := CBufferCnt-1 DOWNTO 0 DO
    IF fImagePtrSize[i] <> 0 then
      begin
        FreeMem(fImagePtr[i], fImagePtrSize[i]);
        fImagePtr[i] := nil;
        fImagePtrSize[i] := 0;
      end;
  DeallocateHWnd(fMessageHWND);
  inherited Destroy;
end;
procedure TVideoImage.Free;
begin
  fDisplayCanvas := nil;
  fBitmap.Free;
  AppEvent.OnIdle := nil;
  AppEvent.Free;
  AppEvent := nil;
  inherited Free;
end;
function TVideoImage.TranslateProperty(const VP: TVideoProperty; VAR VPAP: TVideoProcAmpProperty): HResult;
begin
  Result := S_OK;
  CASE VP OF
    VP_Brightness             : VPAP := VideoProcAmp_Brightness;
    VP_Contrast               : VPAP := VideoProcAmp_Contrast;
    VP_Hue                    : VPAP := VideoProcAmp_Hue;
    VP_Saturation             : VPAP := VideoProcAmp_Saturation;
    VP_Sharpness              : VPAP := VideoProcAmp_Sharpness;
    VP_Gamma                  : VPAP := VideoProcAmp_Gamma;
    VP_ColorEnable            : VPAP := VideoProcAmp_ColorEnable;
    VP_WhiteBalance           : VPAP := VideoProcAmp_WhiteBalance;
    VP_BacklightCompensation  : VPAP := VideoProcAmp_BacklightCompensation;
    VP_Gain                   : VPAP := VideoProcAmp_Gain;
    else Result := S_False;
  END; 
end;
FUNCTION TVideoImage.GetVideoPropertySettings(VP: TVideoProperty; VAR MinVal, MaxVal, StepSize, Default, Actual: integer; VAR AutoMode: boolean): HResult;
VAR
  VPAP       : TVideoProcAmpProperty;
  pCapsFlags : TVideoProcAmpFlags;
BEGIN
  Result   := S_FALSE;
  MinVal   := -1;
  MaxVal   := -1;
  StepSize := 0;
  Default  := 0;
  Actual   := 0;
  AutoMode := true;
  IF not(assigned(VideoSample)) or Failed(TranslateProperty(VP, VPAP)) then
    exit;
  Result := TranslateProperty(VP, VPAP);
  IF Failed(Result) then
    exit;
  Result := VideoSample.GetVideoPropAmpEx(VPAP, MinVal, MaxVal, StepSize, Default, pCapsFlags, Actual);
  IF Failed(Result) then
    begin
      MinVal   := -1;
      MaxVal   := -1;
      StepSize := 0;
      Default  := 0;
      Actual   := 0;
      AutoMode := true;
    end
    else begin
      AutoMode := pCapsFlags <> VideoProcAmp_Flags_Manual;
    end;
END;
FUNCTION TVideoImage.SetVideoPropertySettings(VP: TVideoProperty; Actual: integer; AutoMode: boolean): HResult;
VAR
  VPAP       : TVideoProcAmpProperty;
  pCapsFlags : TVideoProcAmpFlags;
BEGIN
  Result := TranslateProperty(VP, VPAP);
  IF not(assigned(VideoSample)) or Failed(Result) then
    exit;
  IF AutoMode
    then pCapsFlags := VideoProcAmp_Flags_Auto
    else pCapsFlags := VideoProcAmp_Flags_Manual;
  Result := VideoSample.SetVideoPropAmpEx(VPAP, pCapsFlags, Actual);
END;
procedure TVideoImage.GetListOfDevices(DeviceList: TStringList);
begin
  GetCaptureDeviceList(DeviceList);
end;
procedure TVideoImage.VideoPause;
begin
  if not assigned(VideoSample) then
    exit;
  VideoSample.PauseVideo;
end;
procedure TVideoImage.VideoResume;
begin
  if not assigned(VideoSample) then
    exit;
  VideoSample.ResumeVideo;
end;
procedure TVideoImage.VideoStop;
begin
  fFPS := 0;
  if not assigned(VideoSample) then
    exit;
  try
    VideoSample.Free;
    VideoSample := nil;
  except
  end;
  fVideoRunning := false;
end;
function TVideoImage.VideoStart(DeviceName: string): integer;
VAR
  hr     : HResult;
  st     : string;
  W, H   : integer;
  FourCC : cardinal;
begin
  fSkipCnt       := 0;
  fFrameCnt      := 0;
  f30FrameTick   := 0;
  fFPS           := 0;
  fImageUnpacked := false;
  Result := 0;
  if assigned(VideoSample) then
    VideoStop;
  VideoSample := TVideoSample.Create(Application.MainForm.Handle, false, 0, HR); 
  try
    hr := VideoSample.StartVideo(DeviceName, false, st) 
  except
    hr := -1;
  end;
  if Failed(hr)
    then begin
      VideoStop;
     Result := 1;
    end
    else begin
      hr := VideoSample.GetStreamInfo(W, H, FourCC);
      IF Failed(HR)
        then begin
          VideoStop;
          Result := 1;
        end
        else BEGIN
          fWidth := W;
          fHeight := H;
          fFourCC := FourCC;
          FBitmap.PixelFormat := pf24bit;
          FBitmap.Width := W;
          FBitmap.Height := H;
          VideoSample.SetCallBack(CallBack);  
        END;
    end;
end;
function TVideoImage.VideoSampleIsPaused: boolean;
begin
  if assigned(VideoSample)
    then Result := VideoSample.PlayState = PS_PAUSED
    else Result := false;
end;
PROCEDURE TVideoImage.PrepareTables;
VAR
  i : integer;
BEGIN
  IF fYUY2TablesPrepared then
    exit;
  FOR i := 0 TO 255 DO
    BEGIN
      ValueY_298[i] := round(i *  298.082);
      ValueU_100[i] := round(i * -100.291);
      ValueU_516[i] := round(i *  516.412  - 276.836*256);
      ValueV_409[i] := round(i *  408.583  - 222.921*256);
      ValueV_208[i] := round(i * -208.120  + 135.576*256);
    END;
  FillChar(ValueClip, SizeOf(ValueClip), #0);
  FOR i := 0 TO 255 DO
    ValueClip[i] := i;
  FOR i := 256 TO 1023 DO
    ValueClip[i] := 255;
  fYUY2TablesPrepared := true;
END;
procedure TVideoImage.I420_to_RGB(pData: pointer);
VAR
  L, X, Y    : integer;
  ps         : pbyte;
  pY, pU, pV : pbyte;
begin
  pY := pData;
  PrepareTables;
  FOR Y := 0 TO fBitmap.Height-1 DO
    BEGIN
      ps := fBitmap.ScanLine[Y];
      pU := pData;
      Inc(pU, fBitmap.Width*(fBitmap.height+ Y div 4));
      pV := PU;
      Inc(pV, fBitmap.Width*fBitmap.height div 4);
      FOR X := 0 TO (fBitmap.Width div 2)-1 DO
        begin
          L := ValueY_298[pY^];
          ps^ := ValueClip[(L + ValueU_516[pU^]                  ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pU^] + ValueV_208[pV^]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                   + ValueV_409[pV^]) div 256];
          Inc(ps);
          Inc(pY);
          L := ValueY_298[pY^];
          ps^ := ValueClip[(L + ValueU_516[pU^]                     ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pU^] + ValueV_208[pV^]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                   + ValueV_409[pV^]) div 256];
          Inc(ps);
          Inc(pY);
          Inc(pU);
          Inc(pV);
        end;
    END;
end;
procedure TVideoImage.YUY2_to_RGB(pData: pointer);
type
  TFour  = ARRAY[0..3] OF byte;
VAR
  L, X, Y : integer;
  ps      : pbyte;
  pf      : ^TFour;
begin
  pf := pData;
  PrepareTables;
  FOR Y := 0 TO fBitmap.Height-1 DO
    BEGIN
      ps := fBitmap.ScanLine[Y];
      FOR X := 0 TO (fBitmap.Width div 2)-1 DO
        begin
          L := ValueY_298[pf^[0]];
          ps^ := ValueClip[(L + ValueU_516[pf^[1]]                     ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pf^[1]] + ValueV_208[pf^[3]]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                      + ValueV_409[pf^[3]]) div 256];
          Inc(ps);
          L := ValueY_298[pf^[2]];
          ps^ := ValueClip[(L + ValueU_516[pf^[1]]                     ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pf^[1]] + ValueV_208[pf^[3]]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                      + ValueV_409[pf^[3]]) div 256];
          Inc(ps);
          Inc(pf);
        end;
    END;
end;
procedure TVideoImage.PaintFrame;
BEGIN
  if assigned(fDisplayCanvas) then
    begin
      IF not fImageUnpacked then
        UnpackFrame(fImagePtrSize[fImagePtrIndex], fImagePtr[fImagePtrIndex]);
      IF fDisplayCanvas.LockCount < 1 then
        begin
          fDisplayCanvas.lock;
          try
            fDisplayCanvas.Draw(0, 0, fBitmap);
          finally
            fDisplayCanvas.unlock;
          end;
        end;
    end;
END;
procedure TVideoImage.UnpackFrame(Size: integer; pData: pointer);
var
  Unknown : boolean;
  FourCCSt: string[4];
begin
  IF pData = nil
    then exit;
  Unknown := false;
  try
    Case fFourCC OF
      0           :  BEGIN
                       IF (Size = fWidth*fHeight*3)
                         then move(pData^, FBitmap.scanline[fHeight-1]^, Size)
                         else Unknown := true;
                     END;
      FourCC_YUY2,
      FourCC_YUYV,
      FourCC_YUNV :  BEGIN
                       IF (Size = fWidth*fHeight*2)
                         then YUY2_to_RGB(pData)
                         else Unknown := true;
                     END;
      FourCC_MJPG :  BEGIN
                       try
                         MemStream.Clear;
                         MemStream.SetSize(Size);
                         MemStream.Position := 0;
                         MemStream.WriteBuffer(pData^, Size);
                         MemStream.Position := 0;
                         JPG.LoadFromStream(MemStream);
                         FBitmap.Canvas.Draw(0, 0, JPG);
                       except
                         Unknown := true;
                       end;
                     END;
      FourCC_I420,
      FourCC_YV12,
      FourCC_IYUV : BEGIN
                      IF (Size = (fWidth*fHeight*3) div 2)
                        then I420_to_RGB(pData)
                        else Unknown := true;
                    END;
      else          BEGIN
                      Unknown := true;
                    END;
    end; 
    IF Unknown then
      begin
        IF fFourCC = 0
          then FourCCSt := 'RGB'
          else begin
            FourCCSt := '    ';
            move(fFourCC, FourCCSt[1], 4);
          end;
        FBitmap.Canvas.TextOut(0,  0, 'Unknown compression');
        FBitmap.Canvas.TextOut(0, FBitmap.Canvas.TextHeight('X'), 'DataSize: '+INtToStr(Size)+'  FourCC: '+FourCCSt);
      end;
    fImageUnpacked := true;
  except
  end;
end;
procedure TVideoImage.GetBitmap(BMP: TBitmap);
begin
  IF not fImageUnpacked then
    UnpackFrame(fImagePtrSize[fImagePtrIndex], fImagePtr[fImagePtrIndex]);
  BMP.Assign(fBitmap);
end;
procedure TVideoImage.SetDisplayCanvas(Canvas: TCanvas);
begin
  fDisplayCanvas := Canvas;
end;
procedure TVideoImage.ShowProperty;
begin
  VideoSample.ShowPropertyDialog;
end;
procedure TVideoImage.ShowProperty_Stream;
var
  hr     : HResult;
  W, H   : integer;
  FourCC : cardinal;
begin
  VideoSample.ShowPropertyDialog_CaptureStream;
  hr := VideoSample.GetStreamInfo(W, H, FourCC);
  IF Failed(HR)
    then begin
      VideoStop;
    end
    else BEGIN
      fWidth := W;
      fHeight := H;
      fFourCC := FourCC;
      FBitmap.PixelFormat := pf24bit;
      FBitmap.Width := W;
      FBitmap.Height := H;
      VideoSample.SetCallBack(CallBack);
    END;
end;
FUNCTION  TVideoImage.ShowVfWCaptureDlg: HResult;
begin
  Result := VideoSample.ShowVfWCaptureDlg;
end;
procedure TVideoImage.GetBrightnessSettings(VAR Actual: integer);
begin
end;
procedure TVideoImage.SetBrightnessSettings(const Actual: integer);
begin
end;
PROCEDURE TVideoImage.GetListOfSupportedVideoSizes(VidSize: TStringList);
BEGIN
  VideoSample.GetListOfVideoSizes(VidSize);
END;
PROCEDURE TVideoImage.SetResolutionByIndex(Index: integer);
VAR
  hr     : HResult;
  W, H   : integer;
  FourCC : cardinal;
BEGIN
  VideoSample.SetVideoSizeByListIndex(Index);
  hr := VideoSample.GetStreamInfo(W, H, FourCC);
  IF Succeeded(HR)
    then begin
      fWidth := W;
      fHeight := H;
      fFourCC := FourCC;
      FBitmap.PixelFormat := pf24bit;
      FBitmap.Width := W;
      FBitmap.Height := H;
    END;
END;
end.

