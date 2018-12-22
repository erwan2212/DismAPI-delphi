program tinydism_cmd;

{$APPTYPE CONSOLE}

uses
  SysUtils,udismapi,windows;


var
session,hr:integer;
cmdline:string;
b:byte;
flags:dword;
packages:_DismPackages;
drivers:_DismDriverPackages ;
imagesinfo:_DismImagesInfo ;
MountedImagesInfo:_DismMountedImagesInfo ;

function GetFileVersion_(const FileName: ansistring;
     var Major, Minor, Release, Build: word): boolean;
  // Returns True on success and False on failure.
  var
    size, len: longword;
    handle: dword;
    buffer: pansichar;
    pinfo: ^VS_FIXEDFILEINFO;
  begin
    Result := False;
    size := GetFileVersionInfoSizea(pansichar(FileName), handle);
    if size > 0 then begin
      GetMem(buffer, size);
      if GetFileVersionInfoa(pansichar(FileName), 0, size, buffer)
      then
        if VerQueryValuea(buffer, '\', pointer(pinfo), len) then begin
          Major   := HiWord(pinfo.dwFileVersionMS);
          Minor   := LoWord(pinfo.dwFileVersionMS);
          Release := HiWord(pinfo.dwFileVersionLS);
          Build   := LoWord(pinfo.dwFileVersionLS);
          Result  := True;
        end;
      FreeMem(buffer);
    end;
  end;

function closeapp(classname:string):boolean;
Const
WM_SYSCOMMAND = $112;
WM_CLOSE =$10;
//WM_NCDestroy
var
nHwnd:thandle;
begin
repeat
nHwnd :=0;
nHwnd := FindWindow (pchar(classname),nil);
if nHwnd >0 then
  begin
  SendMessage(nHwnd, WM_SYSCOMMAND,WM_CLOSE, 0);
  PostMessage(nHwnd, WM_CLOSE, 0, 0);
  end;
until nHwnd =0;
end;

procedure initialize;
var
hr:integer;
begin
try
{$IFDEF win32}
hr:=DismInitialize(1,pwidechar(widestring(GetCurrentDir+'\dism.log')), nil);
{$endif}
{$IFDEF win64}
hr:=DismInitialize(1,pwidechar(GetCurrentDir+'\dism.log'), nil);
{$endif}
if hr<>S_OK
  then writeln('DismInitialize Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else writeln('DismInitialize OK');
except
on e:exception do writeln(e.Message )
end;
end;

procedure start;
var
major,minor,release,build:word;
ret:boolean;
begin
writeln('host:'+winver);
SetThreadLocale(1033);
session:=0;
try
ret:=init_lib;
if ret=true
  then writeln ('loadlibrary OK')
  else writeln ('loadlibrary failed');
except
on e:exception do writeln(e.Message );
end;
if (ret=true) and (dismapi_filename <>'') then
  begin
  writeln('path:'+dismapi_filename);
  if GetFileVersion_(dismapi_filename,Major, Minor, Release, Build)=true
  then writeln('version:'+inttostr(major)+'.'+inttostr(Minor)+'.'+inttostr(Release)+'.'+inttostr(Build))
  else writeln('could not retrieve dismapi.dll version');
  end;
  //
if ret=true then initialize ;
end;

begin
  { TODO -oUser -cConsole Main : Insert code here }
  start;
  //
  if paramcount=0 then
    begin
    writeln('tinydism 0.2 by erwan2212@gmail.com');
    writeln('tinydism /get-imageinfo c:\temp\boot.wim');
    writeln('tinydism /mount-image c:\temp\boot.wim c:\mount [/ro] [/force] ');
    writeln('tinydism /unmount-image c:\mount [/discard] [/force]');
    writeln('tinydism /add-package c:\mount c:\temp\package.cab');
    writeln('tinydism /add-driver c:\mount c:\temp\driver.inf');
    writeln('tinydism /add-capability c:\mount Language.Basic~~~en-US~0.0.1.0');
    writeln('tinydism /get-drivers');
    writeln('tinydism /get-packages');
    writeln('tinydism /get-mountedimageinfo');
    exit;
    end;
  if ParamCount>0 then for b:=1 to ParamCount  do cmdline:=cmdline+' '+ParamStr(b);
  cmdline:=lowercase(cmdline);
  if pos('/mount-image',(cmdline))>0 then
    begin
    hr:=Dism_GetImageInfo(paramstr(2),imagesinfo );
    try
    if hr=S_OK then writeln('image:'+((inttostr(imagesinfo[0].Majorversion)+'.'+inttostr(imagesinfo[0].MinorVersion)+'.'+inttostr(imagesinfo[0].Build ))));
    except
    end;
    if pos('/force',cmdline)>0 then
      begin
      hr:=dism_unmount(paramstr(3),DISM_DISCARD_IMAGE);
      if hr<>S_OK
        then writeln('DismMountImage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
        else writeln('DismMountImage OK');
      end;
    if pos('/ro',cmdline)>0 then flags:=DISM_MOUNT_READONLY else flags:=DISM_MOUNT_READWRITE;
    hr:=dism_mount(paramstr(2),paramstr(3),flags);
    if hr<>S_OK
    then writeln('DismMountImage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
    else writeln('DismMountImage OK');
    end;
  if pos('/unmount-image',(cmdline))>0 then
    begin
    if pos('/discard',cmdline)>0 then flags:=DISM_DISCARD_IMAGE else flags:=DISM_COMMIT_IMAGE;
    if pos('/force',cmdline)>0 then
      begin
      closeapp('CabinetWClass');
      closeapp('ExploreWClass');
      end;
    hr:=dism_unmount(paramstr(2),flags);
    if hr<>S_OK
    then writeln('DismUnMountImage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
    else writeln('DismUnMountImage OK');
    end;
  if pos('/add-package',(cmdline))>0 then
    begin
    hr:=dism_opensession(paramstr(2));
    if (hr=S_OK)  then
      begin
      hr:=dism_addpackage(paramstr(3));
      if (hr<>S_OK) and (hr<>1)
      then writeln('DismAddPackage Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
      else writeln('DismAddPackage OK');
      dism_closesession ;
      end
      else writeln('DismOpenSession failed');
    end;
  if pos('/add-driver',(cmdline))>0 then
    begin
    hr:=dism_opensession(paramstr(2));
    if hr=S_OK then
      begin
      hr:=dism_adddriver(paramstr(3));
      if hr<>S_OK
      then writeln('DismAddDriver Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
      else writeln('DismAddDriver OK');
      dism_closesession ;
      end
      else writeln('DismOpenSession failed');
    end;
  if pos('/add-capability',(cmdline))>0 then
    begin
    hr:=dism_opensession(paramstr(2));
    if hr=S_OK then
      begin
      hr:=dism_addcapability(paramstr(3));
      if hr<>S_OK
      then writeln('DismAddCapability Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
      else writeln('DismAddCapability OK');
      dism_closesession ;
      end
      else writeln('DismOpenSession failed');
    end;
if pos('/get-packages',(cmdline))>0 then
    begin
    hr:=dism_opensession(paramstr(2));
    if hr=S_OK then
      begin
      hr:=dism_GetPackages (packages);
      if hr<>S_OK
      then writeln('dism_GetPackages Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
      else writeln('dism_GetPackages OK');
      if hr=s_ok then for b:= low(packages) to high(packages) do writeln(widestring(packages[b].PackageName)); ;
      dism_closesession ;
      end
      else writeln('DismOpenSession failed');
    end;
if pos('/get-drivers',(cmdline))>0 then
    begin
    hr:=dism_opensession(paramstr(2));
    if hr=S_OK then
      begin
      hr:=dism_GetDrivers  (drivers);
      if hr<>S_OK
      then writeln('dism_GetDrivers Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
      else writeln('dism_GetDrivers OK');
      if hr=s_ok then for b:= low(drivers) to high(drivers) do writeln(widestring(drivers[b].PublishedName)); ;
      dism_closesession ;
      end
      else writeln('DismOpenSession failed');
    end;//if pos
if pos('get-imageinfo',cmdline)>0 then
  begin
  hr:=Dism_GetImageInfo(paramstr(2) ,imagesinfo);
  if hr<>S_OK
  then writeln('DismGetImageInfo Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
  else writeln('DismGetImageInfo OK');
  if hr=s_ok then for b:= low(imagesinfo) to high(imagesinfo) do
  begin
  writeln('Index:'+inttostr(imagesinfo[b].ImageIndex));
  writeln('ImageName:'+pwidechar((imagesinfo[b].ImageName)));
  //writeln('EditionId:'+pwidechar((imagesinfo[b].EditionId)));
  writeln('Version:'+((inttostr(imagesinfo[b].Majorversion)+'.'+inttostr(imagesinfo[b].MinorVersion)+'.'+inttostr(imagesinfo[b].Build ))));
  end;
  end;//if pos
if pos('dismcleanupmountpoints',cmdline)>0 then
  begin
  hr:=DismCleanupMountPoints();
  end;//if pos
if pos('/get-mountedimageinfo',(cmdline))>0 then
    begin
      hr:=Dism_MountedImageInfo  (MountedImagesInfo);
      if hr<>S_OK
      then writeln('Dism_MountedImageInfo Failed: ' + inttostr(hr)+' '+Dism_GetLastErrorMessage)
      else writeln('Dism_MountedImageInfo OK');
      if length(MountedImagesInfo )=0 then exit;
      if hr=s_ok then for b:= low(MountedImagesInfo) to high(MountedImagesInfo) do
        begin
        writeln('MountPath: '+widestring(MountedImagesInfo[b].MountPath)); ;
        writeln('ImageFilePath: '+widestring(MountedImagesInfo[b].ImageFilePath ));
        writeln('ImageIndex: '+inttostr(MountedImagesInfo[b].ImageIndex  ));
        if MountedImagesInfo[b].MountMode=DismReadWrite
          then writeln('MountMode: RW')
          else writeln('MountMode: RO');
        case MountedImagesInfo[b].MountStatus of
        DismMountStatusOk:writeln('MountStatus: OK');
        DismMountStatusNeedsRemount:writeln('MountStatus: NeedsRemount');
        DismMountStatusInvalid:writeln('MountStatus: Invalid');
        end;//case
      end;//for b:=...
      end;//if pos
end.
