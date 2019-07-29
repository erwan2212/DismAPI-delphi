unit umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,udismapi{,dismlib_tlb,comobj};

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    txtimage: TEdit;
    txtfolder: TEdit;
    mount: TButton;
    Button3: TButton;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    txtfolder2: TEdit;
    Label3: TLabel;
    txtpackage: TEdit;
    Label4: TLabel;
    txtdriver: TEdit;
    Button7: TButton;
    Button6: TButton;
    Button4: TButton;
    Button5: TButton;
    GroupBox3: TGroupBox;
    Memo1: TMemo;
    txtcapability: TEdit;
    Label6: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    chkdiscard: TCheckBox;
    Button12: TButton;
    Button13: TButton;
    OpenDialog1: TOpenDialog;
    Button14: TButton;
    Button15: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure mountClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
  private
    { Private declarations }
    procedure initialize;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;



implementation

{$R *.dfm}
{$R uac.res}

var
session_:integer;


//https://docs.microsoft.com/fr-fr/windows-hardware/manufacture/desktop/dism/dismopensession-function
procedure TForm1.FormCreate(Sender: TObject);
var
major,minor,release,build:word;
ret:boolean;
begin
memo1.Lines.Add('Host:'+winver); 
SetThreadLocale(1033); //->setthreaduilangage
session_:=0;
try
ret:=init_lib;
if ret=true
  then memo1.Lines.Add ('loadlibrary OK')
  else memo1.Lines.Add ('loadlibrary failed');
except
on e:exception do memo1.Lines.Add(e.Message ); 
end;
if (ret=true) and (dismapi_filename <>'') then
  begin
  memo1.Lines.Add('dll:'+dismapi_filename);
if GetFileVersion_(dismapi_filename,Major, Minor, Release, Build)=true
  then memo1.Lines.Add('version='+inttostr(major)+'.'+inttostr(Minor)+'.'+inttostr(Release)+'.'+inttostr(Build))
  else memo1.Lines.Add('could not retrieve dismapi.dll version');
  end;
  //
if ret=true then initialize ;
end;

procedure TForm1.initialize;
var
hr:integer;
begin
try
{$IFDEF win32}
hr:=DismInitialize(1,pwidechar(widestring(ExtractFilePath(Application.ExeName )+'dism.log')), nil);
{$endif}
{$IFDEF win64}
hr:=DismInitialize(1,pwidechar((ExtractFilePath(Application.ExeName )+'dism.log')), nil);
{$endif}
if hr<>S_OK
  then memo1.Lines.Add('DismInitialize Failed: ' + inttostr(hr))
  else memo1.Lines.Add('DismInitialize OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
hr:integer;
{
obj:TDismManager;
image:IDismImage;
imageinfo:IDismImageInfo;
}
begin
//CreateComObject
{
obj:=TDismManager.Create(self);
image:=CreateComObject(CLASS_DismManager) as IDismImage;
image.SetProviderStorePath(widestring(txtimage.Text ));
//image:=imageinfo.Mount(widestring(txtfolder.Text ),0);
obj.CreateImageSession(image);
obj.Free ;
exit;
}
try
hr:=DismCleanupMountPoints;
if hr<>S_OK
  then memo1.Lines.Add('DismCleanupMountPoints Failed: ' + inttostr(hr))
  else memo1.Lines.Add('DismCleanupMountPoints OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
hr:integer;
begin
try
memo1.Lines.Add('mount:'+txtfolder.Text );
if chkdiscard.Checked =true
  then hr:=dism_unmount(txtfolder.Text,DISM_DISCARD_IMAGE)
  else hr:=dism_unmount(txtfolder.Text);
if hr<>S_OK
  then memo1.Lines.Add('DismUnmountImage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismUnmountImage OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.mountClick(Sender: TObject);
var
hr:integer;
osver:RTL_OSVERSIONINFOEXW;
begin
//showmessage(inttostr(sizeof(PCWSTR)));
//exit;
try
memo1.Lines.Add('image:'+txtimage.Text );
memo1.Lines.Add('mount:'+txtfolder.Text );
hr:=dism_mount(txtimage.text,txtfolder.text);
if hr<>S_OK
  then memo1.Lines.Add('DismMountImage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismMountImage OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
hr:integer;
begin
try
memo1.Lines.Add('mount:'+txtfolder2.Text );
hr:=dism_opensession(txtfolder2.Text );
if hr<>S_OK
  then memo1.Lines.Add('DismOpenSession Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismOpenSession OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
hr:integer;
begin
try
hr := dism_closesession;
if hr<>S_OK
  then memo1.Lines.Add('DismCloseSession Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismCloseSession OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
hr:integer;
packages:_DismPackages;
b:byte;
begin
try
memo1.Lines.Add('package:'+txtpackage.Text );

hr:=dism_addpackage(txtpackage.text);

if (hr<>S_OK) and (hr<>1)
  then memo1.Lines.Add('DismAddPackage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismAddPackage OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;

end;

procedure TForm1.Button7Click(Sender: TObject);
var
hr:integer;
begin
try
memo1.Lines.Add('driver:'+txtdriver.Text );
hr:=dism_adddriver(txtdriver.Text);
if hr<>S_OK
  then memo1.Lines.Add('DismAddDriver Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismAddDriver OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;

end;

procedure TForm1.Button9Click(Sender: TObject);
var
hr:integer;
packages:_DismPackages;
b:byte;
begin
try
hr:=dism_GetPackages(packages );
if hr<>S_OK
  then memo1.Lines.Add('dismGetPackages Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('dismGetPackages OK');
if hr=s_ok then for b:= low(packages) to high(packages) do memo1.Lines.Add(((packages[b].PackageName)));
except
on e:exception do memo1.Lines.Add(e.Message );
end;

end;

procedure TForm1.Button10Click(Sender: TObject);
var
hr:integer;
drivers:_DismDriverPackages;
w:word;
begin
try
hr:=dism_GetDrivers(drivers );
if hr<>S_OK
  then memo1.Lines.Add('dismGetDrivers Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('dismGetDrivers OK');
if hr=s_ok then for w:= low(drivers) to high(drivers) do memo1.Lines.Add(((drivers[w].PublishedName)));

except
on e:exception do memo1.Lines.Add(e.Message )
end;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
hr:integer;
begin
if winver[1]='6' then exit;
try
memo1.Lines.Add('driver:'+txtdriver.Text );
hr:=dism_addcapability(txtcapability.Text);
if hr<>S_OK
  then memo1.Lines.Add('dism_addcapability Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('dism_addcapability OK');
except
on e:exception do memo1.Lines.Add(e.Message )
end;

end;

procedure TForm1.Button11Click(Sender: TObject);
var
hr:integer;
features:_DismFeatures;
b:byte;
begin
try
hr:=Dism_GetFeatures(features);
if hr<>S_OK
  then memo1.Lines.Add('DismGetFeatures Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismGetFeatures OK');
if hr=s_ok then for b:= low(features) to high(features) do memo1.Lines.Add(((features[b].FeatureName)));

except
on e:exception do memo1.Lines.Add(e.Message )
end;

end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
DismShutdown;
end;

procedure TForm1.Button12Click(Sender: TObject);
var
hr:integer;
imagesinfo:_DismImagesInfo;
b:byte;
begin
try
hr:=Dism_GetImageInfo(txtimage.Text ,imagesinfo);

if hr<>S_OK
  then memo1.Lines.Add('DismGetImageInfo Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else memo1.Lines.Add('DismGetImageInfo OK');
if hr=s_ok then for b:= low(imagesinfo) to high(imagesinfo) do
  begin
  memo1.Lines.Add('ImageName:'+((imagesinfo[b].ImageName)));
  memo1.Lines.Add('EditionId:'+((imagesinfo[b].EditionId)));
  memo1.Lines.Add('Version:'+((inttostr(imagesinfo[b].Majorversion)+'.'+inttostr(imagesinfo[b].MinorVersion)+'.'+inttostr(imagesinfo[b].Build ))));
  end;
except
on e:exception do memo1.Lines.Add(e.Message )
end;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
if OpenDialog1.Execute=true then txtimage.Text :=OpenDialog1.FileName ; 
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
if OpenDialog1.Execute=true then txtpackage.Text :=OpenDialog1.FileName ;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
if OpenDialog1.Execute=true then txtdriver.Text :=OpenDialog1.FileName ;
end;

end.
