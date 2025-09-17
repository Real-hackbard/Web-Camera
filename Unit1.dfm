object Form1: TForm1
  Left = 1665
  Top = 256
  Caption = 'WebCam Capture'
  ClientHeight = 545
  ClientWidth = 764
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 377
    Top = 0
    Width = 7
    Height = 545
    OnMoved = Splitter1Moved
    ExplicitHeight = 433
  end
  object Panel_Left: TPanel
    Left = 0
    Top = 0
    Width = 377
    Height = 545
    Align = alLeft
    TabOrder = 0
    inline Frame_Video1: TFrame1
      Left = 1
      Top = 1
      Width = 375
      Height = 543
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 375
      ExplicitHeight = 543
      inherited Panel_Top: TPanel
        Width = 375
        ExplicitWidth = 375
        DesignSize = (
          375
          104)
        inherited Label_Cameras: TLabel
          Width = 52
          Height = 13
          ExplicitWidth = 52
          ExplicitHeight = 13
        end
        inherited Label1: TLabel
          Width = 63
          Height = 13
          ExplicitWidth = 63
          ExplicitHeight = 13
        end
        inherited Label3: TLabel
          Width = 51
          Height = 13
          ExplicitWidth = 51
          ExplicitHeight = 13
        end
        inherited Label4: TLabel
          Width = 44
          Height = 13
          ExplicitWidth = 44
          ExplicitHeight = 13
        end
        inherited ComboBox_Cams: TComboBox
          Height = 21
          TabStop = False
          ExplicitHeight = 21
        end
        inherited ComboBox_DisplayMode: TComboBox
          Height = 21
          TabStop = False
          ExplicitHeight = 21
        end
        inherited ComboBox1: TComboBox
          Height = 21
          TabStop = False
          ExplicitHeight = 21
        end
      end
      inherited Panel_Bottom: TPanel
        Width = 375
        Height = 439
        ExplicitWidth = 375
        ExplicitHeight = 438
        DesignSize = (
          375
          439)
        inherited Label_VideoSize: TLabel
          Width = 50
          Height = 13
          ExplicitWidth = 50
          ExplicitHeight = 13
        end
        inherited Label_fps: TLabel
          Width = 90
          Height = 13
          ExplicitWidth = 90
          ExplicitHeight = 13
        end
        inherited Label2: TLabel
          Width = 49
          Height = 13
          ExplicitWidth = 49
          ExplicitHeight = 13
        end
        inherited PaintBox_Video: TPaintBox
          Width = 367
          Height = 483
          ExplicitWidth = 367
          ExplicitHeight = 391
        end
      end
    end
  end
  object Panel_Right: TPanel
    Left = 384
    Top = 0
    Width = 380
    Height = 545
    Align = alClient
    TabOrder = 1
    inline Frame_Video2: TFrame1
      Left = 1
      Top = 1
      Width = 378
      Height = 543
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 378
      ExplicitHeight = 543
      inherited Panel_Top: TPanel
        Width = 378
        ExplicitWidth = 374
        DesignSize = (
          378
          104)
        inherited Label_Cameras: TLabel
          Width = 52
          Height = 13
          ExplicitWidth = 52
          ExplicitHeight = 13
        end
        inherited Label1: TLabel
          Width = 63
          Height = 13
          ExplicitWidth = 63
          ExplicitHeight = 13
        end
        inherited Label3: TLabel
          Width = 51
          Height = 13
          ExplicitWidth = 51
          ExplicitHeight = 13
        end
        inherited Label4: TLabel
          Width = 44
          Height = 13
          ExplicitWidth = 44
          ExplicitHeight = 13
        end
        inherited Bevel1: TBevel
          ExplicitWidth = 253
        end
        inherited ComboBox_Cams: TComboBox
          Height = 21
          TabStop = False
          ExplicitHeight = 21
        end
        inherited ComboBox_DisplayMode: TComboBox
          Height = 21
          TabStop = False
          ExplicitHeight = 21
        end
        inherited ComboBox1: TComboBox
          Height = 21
          TabStop = False
          ExplicitHeight = 21
        end
      end
      inherited Panel_Bottom: TPanel
        Width = 378
        Height = 439
        ExplicitWidth = 374
        ExplicitHeight = 438
        DesignSize = (
          378
          439)
        inherited Label_VideoSize: TLabel
          Width = 50
          Height = 13
          ExplicitWidth = 50
          ExplicitHeight = 13
        end
        inherited Label_fps: TLabel
          Width = 90
          Height = 13
          ExplicitWidth = 90
          ExplicitHeight = 13
        end
        inherited Label2: TLabel
          Width = 49
          Height = 13
          ExplicitWidth = 49
          ExplicitHeight = 13
        end
        inherited PaintBox_Video: TPaintBox
          Width = 374
          Height = 483
          ExplicitWidth = 374
          ExplicitHeight = 391
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 368
    Top = 8
    object File1: TMenuItem
      Caption = '&File'
      object Quit1: TMenuItem
        Caption = '&Quit'
        OnClick = Quit1Click
      end
    end
  end
end
