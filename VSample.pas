unit VSample;

interface

USES Windows, Messages, SysUtils, Classes, ActiveX, Forms,
     {$ifdef DXErr} DXErr9, {$endif}
     DirectShow9;
CONST
  WM_GRAPHNOTIFY = WM_APP+1;
  WM_NewFrame    = WM_User+2;   
CONST  
  {$EXTERNALSYM IID_IUnknown}
  IID_IUnknown: TGUID = (
    D1:$00000000;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
TYPE
  TPLAYSTATE      = (PS_Stopped,
                     PS_Paused,
                     PS_Running);
TYPE
  TVideoSampleCallBack= procedure(pb : pbytearray; var Size: integer) of object;
  TSampleGrabberCBInt = interface(ISampleGrabberCB)
                          function  SampleCB(SampleTime: Double; pSample: IMediaSample): HResult; stdcall;
                          function  BufferCB(SampleTime: Double; pBuffer: PByte; BufferLen: longint): HResult; stdcall;
                        end;
  TSampleGrabberCBImpl= class
                          CallBack    : TVideoSampleCallBack;
                          function  SampleCB(SampleTime: Double; pSample: IMediaSample): HResult; stdcall;
                          function  BufferCB(SampleTime: Double; pBuffer: PByte; BufferLen: longint): HResult; stdcall;
                        end;
  TSampleGrabberCB =    class(TInterfacedObject, TSampleGrabberCBInt)
                          FSampleGrabberCB: TSampleGrabberCBImpl;
                          CallBack    : TVideoSampleCallBack;
                          property SampleGrabberCB: TSampleGrabberCBImpl read FSampleGrabberCB implements TSampleGrabberCBInt;
                        end;
  TFormatInfo   = RECORD
                    Width,
                    Height : integer;
                    SSize  : cardinal;
                    OIndex : integer;
                    pmt    : PAMMediaType;
                    FourCC : ARRAY[0..3] OF char;
                  END;
  TVideoSample  = class(TObject)
                    private
                      ghApp             : HWND;
                      pIVideoWindow     : IVideoWindow;
                      pIMediaControl    : IMediaControl;
                      pIMediaEventEx    : IMediaEventEx;
                      pIGraphBuilder    : IGraphBuilder;
                      pICapGraphBuild2  : ICaptureGraphBuilder2;
                      g_psCurrent       : TPLAYSTATE;
                      pIAMStreamConfig  : IAMStreamConfig;
                      piBFSampleGrabber : IBaseFilter;
                      pIAMVideoProcAmp  : IAMVideoProcAmp;
                      pIBFNullRenderer  : IBaseFilter;
                      pIKsPropertySet   : IKsPropertySet;
                      pISampleGrabber   : ISampleGrabber;
                      pIBFVideoSource   : IBaseFilter;
                      {$ifdef REGISTER_FILTERGRAPH}
                        g_dwGraphRegister :DWORD;
                      {$endif}
                      SGrabberCB  : TSampleGrabberCB;
                      _SGrabberCB : TSampleGrabberCBInt;
                      fVisible    : boolean;
                      CallBack    : TVideoSampleCallBack;
                      FormatArr   : ARRAY OF TFormatInfo;
                      FUNCTION    GetInterfaces(ForceRGB: boolean; WhichMethodToCallback: integer): HRESULT;
                      FUNCTION    SetupVideoWindow(): HRESULT;
                      FUNCTION    ConnectToCaptureDevice(DeviceName: string; VAR DeviceSelected: string; VAR ppIBFVideoSource: IBaseFilter): HRESULT;
                      FUNCTION    RestartVideoEx(Visible: boolean):HRESULT;
                      FUNCTION    ShowPropertyDialogEx(const IBF: IUnknown; FilterName:  PWideChar): HResult;
                      FUNCTION    LoadListOfResolution: HResult;
                      procedure   DeleteBelow(const IBF: IBaseFilter);
                      procedure   CloseInterfaces;
                    public
                      {$ifdef DXErr}
                        DXErrString: string;  
                      {$endif}
                      constructor Create(VideoCanvasHandle: THandle; ForceRGB: boolean; WhichMethodToCallback: integer; VAR HR: HResult);
                      destructor  Destroy; override;
                      property    PlayState: TPLAYSTATE read g_psCurrent;
                      procedure   ResizeVideoWindow();
                      FUNCTION    RestartVideo:HRESULT;
                      FUNCTION    StartVideo(CaptureDeviceName: string; Visible: boolean; VAR DeviceSelected: string):HRESULT;
                      FUNCTION    PauseVideo: HResult;  
                      FUNCTION    ResumeVideo: HResult; 
                      FUNCTION    StopVideo: HResult;
                      function    GetImageBuffer(VAR pb : pbytearray; var Size: integer): HResult;
                      FUNCTION    SetPreviewState(nShow: boolean): HRESULT;
                      FUNCTION    ShowPropertyDialog: HResult;
                      FUNCTION    ShowPropertyDialog_CaptureStream: HResult;
                      FUNCTION    GetVideoPropAmpEx(    Prop           : TVideoProcAmpProperty;
                                                    VAR pMin, pMax,
                                                        pSteppingDelta,
                                                        pDefault       : longint;
                                                    VAR pCapsFlags     : TVideoProcAmpFlags;
                                                    VAR pActual        : longint): HResult;
                      FUNCTION    SetVideoPropAmpEx(    Prop           : TVideoProcAmpProperty;
                                                        pCapsFlags     : TVideoProcAmpFlags;
                                                        pActual        : longint): HResult;
                      PROCEDURE   GetVideoPropAmpPercent(Prop: TVideoProcAmpProperty; VAR AcPerCent: integer);
                      PROCEDURE   SetVideoPropAmpPercent(Prop: TVideoProcAmpProperty; AcPerCent: integer);
                      PROCEDURE   GetVideoSize(VAR Width, height: integer);
                      FUNCTION    ShowVfWCaptureDlg: HResult;
                      FUNCTION    GetStreamInfo(VAR Width, Height: integer; VAR FourCC: dword): HResult;
                      FUNCTION    GetExProp(    guidPropSet   : TGuiD;
                                                dwPropID      : TAMPropertyPin;
                                                pInstanceData : pointer;
                                                cbInstanceData: DWORD;
                                            out pPropData;
                                                cbPropData    : DWORD;
                                            out pcbReturned   : DWORD): HResult;
                      FUNCTION    SetExProp(   guidPropSet : TGuiD;
                                                  dwPropID : TAMPropertyPin;
                                            pInstanceData  : pointer;
                                            cbInstanceData : DWORD;
                                                 pPropData : pointer;
                                                cbPropData : DWORD): HResult;
                      FUNCTION    GetCaptureIAMStreamConfig(VAR pSC: IAMStreamConfig): HResult;
                      PROCEDURE   DeleteCaptureGraph;
                      PROCEDURE   SetCallBack(CB: TVideoSampleCallBack);
                      FUNCTION    GetPlayState: TPlayState;  
                      PROCEDURE   GetListOfVideoSizes(VidSize: TStringList);
                      FUNCTION    SetVideoSizeByListIndex(ListIndex: integer): HResult;
                      {$ifdef REGISTER_FILTERGRAPH}
                        FUNCTION AddGraphToRot(pUnkGraph: IUnknown; VAR pdwRegister: DWORD):HRESULT;
                        procedure RemoveGraphFromRot(pdwRegister: dword);
                      {$endif}
                  END;
FUNCTION TGUIDEqual(const TG1, TG2 : TGUID): boolean;
FUNCTION GetCaptureDeviceList(VAR SL: TStringList): HResult;
implementation
FUNCTION TGUIDEqual(const TG1, TG2 : TGUID): boolean;
BEGIN
  Result := CompareMem(@TG1, @TG2, SizeOf(TGUID));
END; 
FUNCTION GetCaptureDeviceList(VAR SL: TStringList): HResult;
VAR
  pDevEnum     : ICreateDevEnum;
  pClassEnum   : IEnumMoniker;
  st           : string;
          FUNCTION GetNextDeviceName(VAR Name: string): boolean;
          VAR
            pMoniker     : IMoniker;
            pPropertyBag : IPropertyBag;
            v            : OLEvariant;
            cFetched     : ulong;
          BEGIN
            Result := false;
            Name   := '';
            pMoniker := nil;
            IF (S_OK = (pClassEnum.Next (1, pMoniker, @cFetched))) THEN
              BEGIN
                pPropertyBag := nil;
                if S_OK = pMoniker.BindToStorage(nil, nil, IPropertyBag, pPropertyBag) then
                  begin
                    if S_OK = pPropertyBag.Read('FriendlyName', v, nil) then
                      begin
                        Name := v;
                        Result := true;
                      end;
                  end;
              END;
          END; 
begin
  Result := S_FALSE;
  if not(assigned(SL)) then
    SL := TStringlist.Create;
  try
    SL.Clear;
  except
    exit;
  end;
  Result := CoCreateInstance (CLSID_SystemDeviceEnum,
                              nil,
                              CLSCTX_INPROC_SERVER,
                              IID_ICreateDevEnum,
                              pDevEnum);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    begin
      exit;
    end;
  pClassEnum := nil;
  Result := pDevEnum.CreateClassEnumerator (CLSID_VideoInputDeviceCategory, pClassEnum, 0);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    begin
      exit;
    end;
  if (pClassEnum = nil) then
    begin
       exit;
    end;
  WHILE GetNextDeviceName(st) DO
    SL.Add(st);
end; 
function TSampleGrabberCBImpl.SampleCB(SampleTime: Double; pSample: IMediaSample): HResult; stdcall;
var
  BufferLen: integer;
  ppBuffer : pbyte;
begin
  BufferLen := pSample.GetSize;
  if BufferLen > 0 then
    begin
      pSample.GetPointer(ppBuffer); 
      if @CallBack = nil
        then SendMessage(Application.Mainform.handle, WM_NewFrame, BufferLen, integer(ppBuffer))
        else Callback(pbytearray(ppBuffer), BufferLen);
    end;
  Result := 0;
end;
function TSampleGrabberCBImpl.BufferCB(SampleTime: Double; pBuffer: PByte; BufferLen: longint): HResult; stdcall;
begin
  if BufferLen > 0 then
    begin
      if @CallBack = nil
        then SendMessage(Application.Mainform.handle, WM_NewFrame, BufferLen, integer(pBuffer))
        else Callback(pbytearray(pBuffer), BufferLen);
    end;
  Result := 0;
end;
constructor TVideoSample.Create(VideoCanvasHandle: THandle; ForceRGB: boolean; WhichMethodToCallback: integer; VAR HR: HResult);
begin
  ghApp             := 0;
  pIVideoWindow     := nil;
  pIMediaControl    := nil;
  pIMediaEventEx    := nil;
  pIGraphBuilder    := nil;
  pICapGraphBuild2  := nil;
  g_pSCurrent       := PS_Stopped;
  pIAMStreamConfig  := nil;
  piBFSampleGrabber := nil;
  pIAMVideoProcAmp  := nil;
  pIKsPropertySet   := nil;
  {$ifdef REGISTER_FILTERGRAPH}
  g_dwGraphRegister:=0;
  {$endif}
  pISampleGrabber   := nil;
  pIBFVideoSource   := nil;
  SGrabberCB        := nil;
  _SGrabberCB       := nil;
  pIBFNullRenderer  := nil;
  CallBack          := nil;
  inherited create;
  ghApp             := VideoCanvasHandle;
  HR                := GetInterfaces(ForceRGB, WhichMethodToCallback);
end;
FUNCTION TVideoSample.GetInterfaces(ForceRGB: boolean; WhichMethodToCallback: integer): HRESULT;
VAR
  MT: _AMMediaType;
BEGIN
  Result := CoCreateInstance(CLSID_FilterGraph,
                             nil,
                             CLSCTX_INPROC,
                             IID_IGraphBuilder,
                             pIGraphBuilder);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
   exit;
  Result := CoCreateInstance(CLSID_SampleGrabber,
                             nil,
                             CLSCTX_INPROC_SERVER,
                             IBaseFilter,
                             piBFSampleGrabber);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  Result := CoCreateInstance(CLSID_NullRenderer, nil, CLSCTX_INPROC_SERVER,
                             IID_IBaseFilter, pIBFNullRenderer);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  Result := piBFSampleGrabber.QueryInterface(IID_ISampleGrabber, pISampleGrabber);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  pISampleGrabber.SetBufferSamples(false);  
  IF ForceRGB then
    begin
      FillChar(MT, sizeOf(MT), #0);
      MT.majortype := MediaType_Video;
      MT.subtype := MediaSubType_RGB24;
      Result := pISampleGrabber.SetMediaType(MT);
      {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
      if (FAILED(Result)) then
        exit;
    end;
  if not assigned(SGrabberCB) then
    begin
      SGrabberCB := TSampleGrabberCB.Create;
      TSampleGrabberCB(SGrabberCB).FSampleGrabberCB := TSampleGrabberCBImpl.Create;
      _SGrabberCB := TSampleGrabberCB(SGrabberCB);
    end;
  pISampleGrabber.SetCallback(ISampleGrabberCB(_SGrabberCB), WhichMethodToCallback);
  Result := CoCreateInstance(CLSID_CaptureGraphBuilder2,
                             nil,
                             CLSCTX_INPROC,
                             IID_ICaptureGraphBuilder2,
                             pICapGraphBuild2);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  Result := pIGraphBuilder.QueryInterface(IID_IMediaControl, pIMediaControl);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  Result := pIGraphBuilder.QueryInterface(IID_IVideoWindow, pIVideoWindow);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  Result := pIGraphBuilder.QueryInterface(IID_IMediaEvent, pIMediaEventEx);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    exit;
  Result := pIMediaEventEx.SetNotifyWindow(OAHWND(ghApp), WM_GRAPHNOTIFY, 0);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
end;
FUNCTION TVideoSample.ConnectToCaptureDevice(DeviceName: string; VAR DeviceSelected: string; VAR ppIBFVideoSource: IBaseFilter): HRESULT;
VAR
  pDevEnum   : ICreateDevEnum;
  pClassEnum : IEnumMoniker;
  Index      : integer;
  Found      : boolean;
          FUNCTION CheckNextDeviceName(Name: string; VAR Found: boolean): HResult;
          VAR
            pMoniker     : IMoniker;
            pPropertyBag : IPropertyBag;
            v            : OLEvariant;
            cFetched     : ulong;
            MonName      : string;
          BEGIN
            Found  := false;
            pMoniker := nil;
            Result := pClassEnum.Next(1, pMoniker, @cFetched);
            IF (S_OK = Result) THEN
              BEGIN
                Inc(Index);
                pPropertyBag := nil;
                Result := pMoniker.BindToStorage(nil, nil, IPropertyBag, pPropertyBag);
                if S_OK = Result then
                  begin
                    Result := pPropertyBag.Read('FriendlyName', v, nil);   
                    if S_OK = Result then
                      begin
                        MonName := v;
                        if (Uppercase(Trim(MonName)) = UpperCase(Trim(Name))) or
                          ((Length(Name)=2) and (Name[1]='#') and (ord(Name[2])-48=Index)) then
                          begin
                            DeviceSelected := Trim(MonName);
                            Result := pMoniker.BindToObject(nil, nil, IID_IBaseFilter, ppIBFVideoSource);
                            Found := Result = S_OK;
                          end;
                      end;
                  end;
              END;
          END; 
BEGIN
  DeviceSelected := '';
  Index := 0;
  DeviceName := Trim(DeviceName);
  IF DeviceName = '' then
    DeviceName := '#1'; 
  if @ppIBFVideoSource = nil then
    begin
      result := E_POINTER;
      exit;
    end;
  Result := CoCreateInstance(CLSID_SystemDeviceEnum,
                             nil,
                             CLSCTX_INPROC,
                             IID_ICreateDevEnum,
                             pDevEnum);
  if (FAILED(Result)) then
    begin
      exit;
    end;
  pClassEnum := nil;
  Result := pDevEnum.CreateClassEnumerator (CLSID_VideoInputDeviceCategory, pClassEnum, 0);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    begin
      exit;
    end;
  if (pClassEnum = nil) then
    begin
      result := E_FAIL;
      exit;
    end;
  Found := false;
  REPEAT
    try
      Result := CheckNextDeviceName(DeviceName, Found)
    except
      IF Result = 0 then
        result := E_FAIL;
    end;
  UNTIL Found or (Result <> S_OK);
end; 
procedure TVideoSample.ResizeVideoWindow();
var
  rc : TRect;
begin
  if (pIVideoWindow) <> nil then
    begin
      GetClientRect(ghApp, rc);
      pIVideoWindow.SetWindowPosition(0, 0, rc.right, rc.bottom);
    end;
end; 
FUNCTION TVideoSample.SetupVideoWindow(): HRESULT;
BEGIN
  Result := pIVideoWindow.put_Owner(OAHWND(ghApp));
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    begin
      exit;
    end;
  Result := pIVideoWindow.put_WindowStyle(WS_CHILD or WS_CLIPCHILDREN);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    begin
      exit;
    end;
  ResizeVideoWindow();
  Result := pIVideoWindow.put_Visible(TRUE);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if (FAILED(Result)) then
    begin
      exit;
    end;
end; 
FUNCTION TVideoSample.RestartVideoEx(Visible: boolean):HRESULT;
VAR
  pCut, pTyp : pGuiD;
BEGIN
  if (pIAMVideoProcAmp = nil) then
    if not(S_OK = pIBFVideoSource.QueryInterface(IID_IAMVideoProcAmp, pIAMVideoProcAmp)) then
      pIAMVideoProcAmp := nil;
   if (pIKsPropertySet = nil) then
    if not(S_OK = pIBFVideoSource.QueryInterface(IID_IKsPropertySet, pIKsPropertySet)) then
      pIKsPropertySet := nil;
    Result := pIGraphBuilder.AddFilter(pIBFVideoSource, Widestring('Video Capture'));
    if (FAILED(Result)) then
      begin
        exit;
      end;
    Result := pIGraphBuilder.AddFilter(piBFSampleGrabber, Widestring('Sample Grabber'));
    if (FAILED(Result)) then
      EXIT;
    if not(Visible) then
      begin
        Result := pIGraphBuilder.AddFilter(pIBFNullRenderer, WideString('Null Renderer'));
        if (FAILED(Result)) then
          EXIT;
      end;
    New(pCut);
    New(pTyp);
    pCut^ := PIN_CATEGORY_CAPTURE;
    pTyp^ := MEDIATYPE_Video;
    try
      if Visible
        then Result := pICapGraphBuild2.RenderStream (pCut, pTyp,
                                    pIBFVideoSource, piBFSampleGrabber, nil)
        else Result := pICapGraphBuild2.RenderStream (pCut, pTyp,
                                    pIBFVideoSource, piBFSampleGrabber, pIBFNullRenderer);
    except
      Result := -1;
    end;
    if (FAILED(Result)) then
      begin
        exit;
      end;
    if Visible then
      begin
        Result := SetupVideoWindow();
        if (FAILED(Result)) then
          begin
            exit;
          end;
      end;
{$ifdef REGISTER_FILTERGRAPH}
    try
      hr := AddGraphToRot(IUnknown(pIGraphBuilder), g_dwGraphRegister);
    except
    end;
    if (FAILED(Result)) then
      begin
        g_dwGraphRegister := 0;
      end;
{$endif}
      begin
        Result := pIMediaControl.Run();
        if (FAILED(Result)) then
          begin
          end;
      end;
    g_psCurrent := PS_Running;
end; 
FUNCTION TVideoSample.RestartVideo: HRESULT;
BEGIN
  Result := RestartVideoEx(FVisible);
END; 
FUNCTION TVideoSample.StartVideo(CaptureDeviceName: string; Visible: boolean; VAR DeviceSelected: string):HRESULT;
BEGIN
  pIBFVideoSource := nil;
  FVisible   := Visible;
  Result := pICapGraphBuild2.SetFiltergraph(pIGraphBuilder);
  if (FAILED(Result)) then
    begin
      exit;
    end;
  Result := ConnectToCaptureDevice(CaptureDeviceName, DeviceSelected, pIBFVideoSource);
  if (FAILED(Result)) then
    begin
      exit;
    end;
  LoadListOfResolution;    
  Result := RestartVideo;
end;
FUNCTION TVideoSample.PauseVideo: HResult;
BEGIN
  IF g_psCurrent = PS_Paused
    then begin
      Result := S_OK;
      EXIT;
    end;
  IF g_psCurrent = PS_Running then
    begin
      Result := pIMediaControl.Pause;
      if Succeeded(Result) then
        g_psCurrent := PS_Paused;
    end
    else Result := S_FALSE;
END;
FUNCTION TVideoSample.ResumeVideo: HResult;
BEGIN
  IF g_psCurrent = PS_Running then
    begin
      Result := S_OK;
      EXIT;
    end;
  IF g_psCurrent = PS_Paused then
    begin
      Result := pIMediaControl.Run;
      if Succeeded(Result) then
        g_psCurrent := PS_Running;
    end
    else Result := S_FALSE;
END;
FUNCTION TVideoSample.StopVideo: HResult;
BEGIN
  Result := pIMediaControl.StopWhenReady();
  g_psCurrent := PS_Stopped;
  SetLength(FormatArr, 0);
END;
PROCEDURE TVideoSample.DeleteBelow(const IBF: IBaseFilter);
VAR
  hr         : HResult;
  pins       : IEnumPins;
  pIPinFrom,
  pIPinTo    : IPin;
  fetched    : ulong;
  pInfo      : _PinInfo;
BEGIN
  pIPinFrom := nil;
  pIPinTo   := nil;
  hr := IBF.EnumPins(pins);
  WHILE (hr = NoError) DO
    BEGIN
      hr := pins.Next(1, pIPinFrom, @fetched);
      if (hr = S_OK) and (pIPinFrom <> nil) then
        BEGIN
          hr := pIPinFrom.ConnectedTo(pIPinTo);
          if (hr = S_OK) and (pIPinTo <> nil) then
            BEGIN
              hr := pIPinTo.QueryPinInfo(pInfo);
              if (hr = NoError) then
                BEGIN
                  if pinfo.dir = PINDIR_INPUT then
                    BEGIN
                      DeleteBelow(pInfo.pFilter);
                      pIGraphBuilder.Disconnect(pIPinTo);
                      pIGraphBuilder.Disconnect(pIPinFrom);
                      pIGraphBuilder.RemoveFilter(pInfo.pFilter);
                    ENd;
                END;
            END;
        END;
    END;
END; 
PROCEDURE TVideoSample.DeleteCaptureGraph;
BEGIN
  pIBFVideoSource.Stop;
  DeleteBelow(pIBFVideoSource);
END;
procedure TVideoSample.CloseInterfaces;
begin
  if (pISampleGrabber <> nil) then
    pISampleGrabber.SetCallback(nil, 1);
  if (pIMediaControl <> nil) then
    pIMediaControl.StopWhenReady();
  g_psCurrent := PS_Stopped;
  if (pIMediaEventEx <> nil) then
    pIMediaEventEx.SetNotifyWindow(OAHWND(nil), WM_GRAPHNOTIFY, 0);
  if (pIVideoWindow<>nil) then
    begin
      pIVideoWindow.put_Visible(FALSE);
      pIVideoWindow.put_Owner(OAHWND(nil));
    end;
  {$ifdef REGISTER_FILTERGRAPH}
    if (g_dwGraphRegister<>nil) then
      RemoveGraphFromRot(g_dwGraphRegister);
  {$endif}
end;
function TVideoSample.GetImageBuffer(VAR pb : pbytearray; var Size: integer): HResult;
VAR
  NewSize : integer;
begin
  Result := pISampleGrabber.GetCurrentBuffer(NewSize, nil);
  if (Result <> S_OK) then
    EXIT;
  if (pb <> nil) then
    begin
      if Size <> NewSize then
        begin
          try
            FreeMem(pb, Size);
          except
          end;
          pb := nil;
          Size := 0;
        end;
    end;
  Size := NewSize;
  IF Result = S_OK THEN
    BEGIN
      if pb = nil then
        GetMem(pb, NewSize);
      Result := pISampleGrabber.GetCurrentBuffer(NewSize, pb);
    END;
end;
FUNCTION TVideoSample.SetPreviewState(nShow: boolean): HRESULT;
BEGIN
  Result := S_OK;
  if (pIMediaControl = nil) then
    exit;
  if (nShow) then
    begin
      if (g_psCurrent <> PS_Running) then
        begin
          Result := pIMediaControl.Run();
          g_psCurrent := PS_Running;
        end;
    end
    else begin
        Result := pIMediaControl.Stop;
        g_psCurrent := PS_Stopped;
    end;
end;
FUNCTION TVideoSample.ShowPropertyDialogEx(const IBF: IUnknown; FilterName: PWideChar): HResult;
VAR
  pProp      : ISpecifyPropertyPages;
  c          : tagCAUUID;
begin
 pProp  := nil;
 Result := IBF.QueryInterface(ISpecifyPropertyPages, pProp);
 if Result = S_OK then
   begin
     Result := pProp.GetPages(c);
     if (Result = S_OK) and (c.cElems > 0) then
       begin
         Result := OleCreatePropertyFrame(ghApp, 0, 0, FilterName, 1, @IBF, c.cElems, c.pElems, 0, 0, nil);
         CoTaskMemFree(c.pElems);
       end;
   end;
end;
FUNCTION TVideoSample.ShowPropertyDialog: HResult;
VAR
  FilterInfo : FILTER_INFO;
begin
  Result := pIBFVideoSource.QueryFilterInfo(FilterInfo);
  if not(Failed(Result)) then
    Result := ShowPropertyDialogEx(pIBFVideoSource, FilterInfo.achName);
end;
FUNCTION TVideoSample.GetCaptureIAMStreamConfig(VAR pSC: IAMStreamConfig): HResult;
BEGIN
  pSC := nil;
  Result := pICapGraphBuild2.FindInterface(@PIN_CATEGORY_capture,
                                           @MEDIATYPE_Video,
                                           pIBFVideoSource,
                                           IID_IAMStreamConfig, pSC);
END;
FUNCTION TVideoSample.ShowPropertyDialog_CaptureStream: HResult;
VAR
  pSC       : IAMStreamConfig;
BEGIN
  pIMediaControl.Stop;
  Result := GetCaptureIAMStreamConfig(pSC);
  if Result = S_OK then
    Result := ShowPropertyDialogEx(pSC, '');
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  pIMediaControl.Run;
END;
FUNCTION TVideoSample.LoadListOfResolution: HResult;
VAR
  pSC                   : IAMStreamConfig;
  VideoStreamConfigCaps : TVideoStreamConfigCaps;
  p                     : ^TVideoStreamConfigCaps;
  ppmt                  : PAMMediaType;
  i, j,
  piCount,
  piSize                : integer;
  Swap                  : boolean;
  FM                    : TFormatInfo;
BEGIN
  SetLength(FormatArr, 0);
  Result := GetCaptureIAMStreamConfig(pSC);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  IF Result = S_OK then
    Result := pSC.GetNumberOfCapabilities(piCount, piSize);
  j := 0;
  if Result = S_OK then
    begin
      FOR i := 0 TO piCount-1 DO
        begin
          p := @VideoStreamConfigCaps;
          Result := pSC.GetStreamCaps(i, ppmt, p^);
          IF Succeeded(Result) then
            begin
              Inc(j);
              SetLength(FormatArr, j);
              FormatArr[j-1].OIndex := i;
              FormatArr[j-1].Width  := p^.InputSize.cx;
              FormatArr[j-1].Height := p^.InputSize.cy;
              FormatArr[j-1].pmt    := ppmt;
              FormatArr[j-1].SSize  := ppmt^.lSampleSize;
              IF TGuIDEqual(MEDIASUBTYPE_RGB24, ppmt^.Subtype)
                then FormatArr[j-1].FourCC := 'RGB '
                else move(ppmt^.Subtype.D1, FormatArr[j-1].FourCC, 4);
            end;
        end;
    end;
  IF j > 1 then
    begin
      REPEAT
        Swap := false;
        FOR i := 0 TO j-2 DO
          IF (FormatArr[i].Width > FormatArr[i+1].Width) or
             (((FormatArr[i].Width = FormatArr[i+1].Width)) and ((FormatArr[i].Height > FormatArr[i+1].Height)))
          then
            begin
              Swap := true;
              FM := FormatArr[i];
              FormatArr[i] := FormatArr[i+1];
              FormatArr[i+1] := FM;
            end;
      UNTIL not(Swap);
    end;
END;
FUNCTION TVideoSample.SetVideoSizeByListIndex(ListIndex: integer): HResult;
VAR
  pSC                   : IAMStreamConfig;
  VideoStreamConfigCaps : TVideoStreamConfigCaps;
  p                     : ^TVideoStreamConfigCaps;
  ppmt                  : PAMMediaType;
  piCount,
  piSize                : integer;
BEGIN
  IF (ListIndex < 0) or (ListIndex >= Length(FormatArr)) then
    begin
      Result := S_FALSE;
      exit;
    end;
  ListIndex := FormatArr[ListIndex].OIndex;
  pIMediaControl.Stop;
  Result := GetCaptureIAMStreamConfig(pSC);
  IF Succeeded(Result) then
    begin
      piCount := 0;
      piSize  := 0;
      pSC.GetNumberOfCapabilities(piCount, piSize);
      p := @VideoStreamConfigCaps;
      Result := pSC.GetStreamCaps(ListIndex, ppmt, p^);
      IF Succeeded(Result) then
        Result := pSC.SetFormat(ppmt^);
    end;
  pIMediaControl.Run;
END;
FUNCTION TVideoSample.GetStreamInfo(VAR Width, Height: integer; VAR FourCC: dword): HResult;
VAR
  pSC   : IAMStreamConfig;
  ppmt  : PAMMediaType;
  pmt   : _AMMediaType;
  VI    : VideoInfo;
  VIH   : VideoInfoHeader;
BEGIN
  Width := 0;
  Height := 0;
  pIMediaControl.Stop;
  pIBFVideoSource.Stop;  
  Result := GetCaptureIAMStreamConfig(pSC);
  {$ifdef DXErr} DXErrString := DXGetErrorDescription9A(Result); {$endif}
  if Result = S_OK then
    begin
      Result := pSC.GetFormat(ppmt);
      pmt := ppmt^;
      if  TGUIDEqual(ppmt.formattype, FORMAT_VideoInfo) then
        begin
          FillChar(VI, SizeOf(VI), #0);
          VIH := VideoInfoHeader(ppmt^.pbFormat^);
          move(VIH, VI, SizeOf(VIH));
          Width := VI.bmiHeader.biWidth;
          Height := Abs(VI.bmiHeader.biHeight);
          FourCC := VI.bmiHeader.biCompression;
        end;
    end;
  pIBFVideoSource.Run(0);
  pIMediaControl.Run;
END;
FUNCTION TVideoSample.GetVideoPropAmpEx(    Prop                     : TVideoProcAmpProperty;
                                        VAR pMin, pMax,
                                            pSteppingDelta, pDefault : longint;
                                        VAR pCapsFlags               : TVideoProcAmpFlags;
                                        VAR pActual                  : longint): HResult;
BEGIN
  Result := S_False;
  if pIAMVideoProcAmp = nil then
    exit;
  Result := pIAMVideoProcAmp.GetRange(Prop, pMin, pMax, pSteppingDelta, pDefault, pCapsFlags);
  pActual := pDefault;
  IF Result = S_OK then
    Result := pIAMVideoProcAmp.Get(Prop, pActual, pCapsFlags)
END;
FUNCTION TVideoSample.SetVideoPropAmpEx(    Prop           : TVideoProcAmpProperty;
                                            pCapsFlags     : TVideoProcAmpFlags;
                                            pActual        : longint): HResult;
BEGIN
  Result := S_False;
  if pIAMVideoProcAmp = nil then
    exit;
  Result := pIAMVideoProcAmp.Set_(Prop, pActual, pCapsFlags)
END;
PROCEDURE TVideoSample.GetVideoPropAmpPercent(Prop: TVideoProcAmpProperty; VAR AcPerCent: integer);
VAR
  pMin, pMax,
  pSteppingDelta,
  pDefault       : longint;
  pCapsFlags     : TVideoProcAmpFlags;
  pActual        : longint;
BEGIN
  IF GetVideoPropAmpEx(Prop, pMin, pMax, pSteppingDelta, pDefault, pCapsFlags, pActual) = S_OK
    THEN BEGIN
      AcPerCent := round(100 * (pActual-pMin)/(pMax-pMin));
    END
    ELSE AcPerCent := -1;
END;
PROCEDURE TVideoSample.SetVideoPropAmpPercent(Prop: TVideoProcAmpProperty; AcPerCent: integer);
VAR
  pMin, pMax,
  pSteppingDelta,
  pDefault        : longint;
  pCapsFlags      : TVideoProcAmpFlags;
  pActual         : longint;
  d               : double;
BEGIN
  IF GetVideoPropAmpEx(Prop, pMin, pMax, pSteppingDelta, pDefault, pCapsFlags, pActual) = S_OK
    THEN BEGIN
      IF (AcPercent < 0) or (AcPercent > 100) then
        begin
          pActual := pDefault;
        end
        else begin
          d := (pMax-pMin)/100*AcPercent;
          pActual := round(d);
          pActual := (pActual div pSteppingDelta) * pSteppingDelta;
          pActual := pActual + pMin;
        end;
      pIAMVideoProcAmp.Set_(Prop, pActual, pCapsFlags);
    END
END;
PROCEDURE TVideoSample.GetVideoSize(VAR Width, height: integer);
VAR
  pBV : IBasicVideo;
BEGIN
  Width := 0;
  Height := 0;
  pBV := nil;
  if pIGraphBuilder.QueryInterface(IID_IBasicVideo, pBV)=S_OK then
    pBV.GetVideoSize(Width, height);
END; 
FUNCTION TVideoSample.ShowVfWCaptureDlg: HResult;
VAR
  pVfw : IAMVfwCaptureDialogs;
BEGIN
  pVfw := nil;
  pIMediaControl.Stop;
  Result := pICapGraphBuild2.FindInterface(@PIN_CATEGORY_CAPTURE,
                                     @MEDIATYPE_Video,
                                     pIBFVideoSource,
                                     IID_IAMVfwCaptureDialogs, pVfW);
  if not(Succeeded(Result)) then 
    Result := pICapGraphBuild2.queryinterface(IID_IAMVfwCaptureDialogs, pVfw);
  if not(Succeeded(Result)) then 
    Result := pIGraphBuilder.queryinterface(IID_IAMVfwCaptureDialogs, pVfw);
  if (SUCCEEDED(Result)) THEN
    BEGIN
      if (S_OK = pVfw.HasDialog(VfwCaptureDialog_Source)) then
        Result := pVfw.ShowDialog(VfwCaptureDialog_Source, ghApp);
    END;
  pIMediaControl.Run;
END;
FUNCTION TVideoSample.GetExProp(   guidPropSet : TGuiD;
                                      dwPropID : TAMPropertyPin;
                                pInstanceData  : pointer;
                                cbInstanceData : DWORD;
                                 out pPropData;
                                    cbPropData : DWORD;
                                out pcbReturned: DWORD): HResult;
BEGIN
  Result := pIKsPropertySet.Get(guidPropSet, dwPropID, pInstanceData, cbInstanceData, pPropData, cbPropData, pcbReturned);
END;
FUNCTION TVideoSample.SetExProp(   guidPropSet : TGuiD;
                                      dwPropID : TAMPropertyPin;
                                pInstanceData  : pointer;
                                cbInstanceData : DWORD;
                                     pPropData : pointer;
                                    cbPropData : DWORD): HResult;
BEGIN
  Result := pIKsPropertySet.Set_(guidPropSet, dwPropID, pInstanceData, cbInstanceData, pPropData, cbPropData);
END;
PROCEDURE TVideoSample.SetCallBack(CB: TVideoSampleCallBack);
BEGIN
  CallBack := CB;
  SGrabberCB.FSampleGrabberCB.CallBack := CB;
END;
FUNCTION TVideoSample.GetPlayState: TPlayState;
BEGIN
  Result := g_psCurrent;
END;
PROCEDURE TVideoSample.GetListOfVideoSizes(VidSize: TStringList);
VAR
  i : integer;
BEGIN
  try
    IF not(assigned(VidSize)) then
      VidSize := TStringList.Create;
    VidSize.Clear;
  except
    exit;
  end;
  IF g_psCurrent < PS_Paused then
    exit;
  FOR i := 0 TO Length(FormatArr)-1 DO
    VidSize.Add(IntToStr(FormatArr[i].Width)+'*'+IntToStr(FormatArr[i].Height) + '  (' + FormatArr[i].FourCC+')');
END;
{$ifdef REGISTER_FILTERGRAPH}
FUNCTION TVideoSample.AddGraphToRot(pUnkGraph: IUnknown; VAR pdwRegister: DWORD):HRESULT;
VAR
  pMoniker   : IMoniker;
  pRot       : IRunningObjectTable;
  sz         : string;
  wsz        : ARRAY[0..128] OF wchar;
  hr         : HResult;
  dwRegister : integer absolute pdwregister;
  i : integer;
BEGIN
    if (FAILED(GetRunningObjectTable(0, pROT))) then
      begin
        result := E_FAIL;
        exit;
      end;
    sz := 'FilterGraph ' + lowercase(IntToHex(integer((pUnkGraph)), 8))+' pid '+
                           lowercase(IntToHex(GetCurrentProcessID,8))+#0;
    fillchar(wsz, sizeof(wsz), #0);
    for i := 1 to length(sz) DO
      wsz[i-1] := widechar(sz[i]);
    hr := CreateItemMoniker('!', wsz, pMoniker);
    if (SUCCEEDED(hr)) then
      begin
        hr := pROT.Register(ROTFLAGS_REGISTRATIONKEEPSALIVE, pUnkGraph,
                            pMoniker, dwRegister);
      end;
    result := hr;
end;
procedure TVideoSample.RemoveGraphFromRot(pdwRegister: dword);
VAR
  pROT :  IRunningObjectTable;
begin
  if (SUCCEEDED(GetRunningObjectTable(0, pROT))) then
    begin
      pROT.Revoke(pdwRegister);
    end;
end;
{$endif}
destructor TVideoSample.Destroy;
begin
  try
    SetPreviewState(false);
    pIMediaControl.Stop;
    pIBFVideoSource.Stop;
    DeleteCaptureGraph;
    closeInterfaces;
  finally
    try
      inherited destroy;
    except
    end;
  end;
end;
end.

