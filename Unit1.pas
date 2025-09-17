unit Unit1;

interface

uses
  Windows, Classes, Controls, Forms, ExtCtrls, Frame_Video, Menus,
  StdCtrls, XPMan;

type
  TForm1 = class(TForm)
    Panel_Left: TPanel;
    Frame_Video1: TFrame1;
    Splitter1: TSplitter;
    Panel_Right: TPanel;
    Frame_Video2: TFrame1;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Quit1: TMenuItem;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    SplitterRatio : double;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  Frame_Video1.Stop;
  Frame_Video2.Stop;
  Screen.Cursor := crdefault;
end;
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Frame_Video1.Close;
  Frame_Video2.Close;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
  Frame_Video1.InitFrame;
  Frame_Video2.InitFrame;
  Frame_Video2.Label_Cameras.Caption := 'Camera #2';
end;
procedure TForm1.Quit1Click(Sender: TObject);
begin
  close;
end;
procedure TForm1.Splitter1Moved(Sender: TObject);
begin
  SplitterRatio := (Panel_Left.Width+Splitter1.Width div 2) / Width;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  SplitterRatio := 0.5;
end;
procedure TForm1.FormResize(Sender: TObject);
begin
  Panel_Left.Width := round(SplitterRatio * (Width-Splitter1.Width div 2));
end;
end.

