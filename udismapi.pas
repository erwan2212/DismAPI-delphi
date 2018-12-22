unit udismapi;

interface

uses windows,sysutils,registry ;

const
DISM_ONLINE_IMAGE = 'DISM_{53BFAE52-B167-4E2F-A258-0A37B57FF845}';
//mount
DISM_MOUNT_READWRITE        =$00000000;
DISM_MOUNT_READONLY         =$00000001;
DISM_MOUNT_OPTIMIZE         =$00000002;
DISM_MOUNT_CHECK_INTEGRITY  =$00000004;
//Unmount flags
DISM_COMMIT_IMAGE  =$00000000;
DISM_DISCARD_IMAGE =$00000001;

//Commit flags
DISM_COMMIT_GENERATE_INTEGRITY =$00010000;
DISM_COMMIT_APPEND             =$00020000;

// Commit flags may also be used with unmount.  AND this with unmount flags and you will
// get the commit-specific flags.
DISM_COMMIT_MASK               =$ffff0000;

type DismLogLevel = ( DismLogErrors = 0,  DismLogErrorsWarnings,    DismLogErrorsWarningsInfo);
type DismImageIdentifier = (  DismImageIndex = 0, DismImageName);
type DismMountMode = (  DismReadWrite = 0, DismReadOnly );
type DismImageType = (  DismImageTypeUnsupported = -1, DismImageTypeWim = 0, DismImageTypeVhd = 1 );
type DismImageBootable = (  DismImageBootableYes = 0,    DismImageBootableNo,    DismImageBootableUnknown );
type DismMountStatus = (  DismMountStatusOk = 0,    DismMountStatusNeedsRemount,    DismMountStatusInvalid );
type DismImageHealthState = (  DismImageHealthy = 0,    DismImageRepairable,    DismImageNonRepairable );
type DismPackageIdentifier = (  DismPackageNone = 0,    DismPackageName,    DismPackagePath );
type DismPackageFeatureState  = (  DismStateNotPresent = 0,    DismStateUninstallPending,    DismStateStaged,    DismStateResolved,
                                   DismStateRemoved = DismStateResolved,    DismStateInstalled,    DismStateInstallPending,
                                   DismStateSuperseded,    DismStatePartiallyInstalled );
type DismReleaseType  = (  DismReleaseTypeCriticalUpdate = 0,    DismReleaseTypeDriver,    DismReleaseTypeFeaturePack,    DismReleaseTypeHotfix,
                            DismReleaseTypeSecurityUpdate,    DismReleaseTypeSoftwareUpdate,    DismReleaseTypeUpdate,    DismReleaseTypeUpdateRollup,
                          DismReleaseTypeLanguagePack,    DismReleaseTypeFoundation,    DismReleaseTypeServicePack,    DismReleaseTypeProduct,
                          DismReleaseTypeLocalPack,    DismReleaseTypeOther );
type DismRestartType  = (  DismRestartNo = 0,    DismRestartPossible,    DismRestartRequired );
type DismDriverSignature  = (  DismDriverSignatureUnknown = 0,    DismDriverSignatureUnsigned = 1,    DismDriverSignatureSigned = 2);
type DismFullyOfflineInstallableType  = (   DismFullyOfflineInstallable = 0,    DismFullyOfflineNotInstallable,    DismFullyOfflineInstallableUndetermined);

 POSVERSIONINFOEXW = ^OSVERSIONINFOEXW;
  {$EXTERNALSYM POSVERSIONINFOEXW}
  _OSVERSIONINFOEXW = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array [0..127] of WCHAR;     // Maintenance string for PSS usage
    wServicePackMajor: WORD;
    wServicePackMinor: WORD;
    wSuiteMask: WORD;
    wProductType: BYTE;
    wReserved: BYTE;
  end;
  {$EXTERNALSYM _OSVERSIONINFOEXW}
  OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
  {$EXTERNALSYM OSVERSIONINFOEXW}
  LPOSVERSIONINFOEXW = ^OSVERSIONINFOEXW;
  {$EXTERNALSYM LPOSVERSIONINFOEXW}
  RTL_OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
  {$EXTERNALSYM RTL_OSVERSIONINFOEXW}
  PRTL_OSVERSIONINFOEXW = ^RTL_OSVERSIONINFOEXW;
  {$EXTERNALSYM PRTL_OSVERSIONINFOEXW}
  TOSVersionInfoExW = _OSVERSIONINFOEXW;


type
pcwstr=pwidechar;
uint=cardinal;
puint=^uint;
uint64=int64;
PPointer= ^Pointer;

type _DismString=record
     Value:PCWSTR;
end;
_PDismString= ^_DismString;

type DismLanguage= _DismString;
type PDismLanguage= ^DismLanguage;

type _DismMountedImageInfo=record
     MountPath:PCWSTR;
     ImageFilePath:PCWSTR;
     ImageIndex:UINT;
     MountMode:DismMountMode;
     MountStatus:DismMountStatus;
end;
_PDismMountedImageInfo= ^_DismMountedImageInfo;
_DismMountedImagesInfo=array of  _DismMountedImageInfo;

{$align 4}
type _DismImageInfo=record
     ImageType:DismImageType;
     ImageIndex:UINT;
     ImageName:PCWSTR;
     ImageDescription:PCWSTR;
     ImageSize:UINT64;
     Architecture:UINT;
     ProductName:PCWSTR;
     EditionId:PCWSTR;
     InstallationType:PCWSTR;
     Hal:PCWSTR;
     ProductType:PCWSTR;
     ProductSuite:PCWSTR;
     MajorVersion:UINT;
     MinorVersion:UINT;
     Build:UINT;
     SpBuild:UINT;
     SpLevel:UINT;
     Bootable:DismImageBootable;
     SystemRoot:PCWSTR;
     Language:PDismLanguage;
     LanguageCount:UINT;
     DefaultLanguageIndex:UINT;
     CustomizedInfo:pointer;
end ;
{$align off}
_PDismImageInfo= ^_DismImageInfo;
_DismImagesInfo=array of  _DismImageInfo;


//{$align 4}
type _DismPackage = record   //NOT PACKED !!! 32->26 on x64,24->22 on x86
        PackageName:PCWSTR;  //8 x64  //4 x86
        PackageState:DismPackageFeatureState; //1
        ReleaseType:DismReleaseType;          //1
        InstallTime:SYSTEMTIME; //16
        {$IFDEF win32}padding:dword;{$endif}
end;
//{$align off}
_PDismPackage= ^_DismPackage;
_DismPackages=array of  _DismPackage;

{$align 4}
type _DismDriverPackage = record
                  PublishedName:PCWSTR;
                  OriginalFileName:PCWSTR;
                  InBox:BOOL;
                  CatalogFile:PCWSTR;
                  ClassName:PCWSTR;
                  ClassGuid:PCWSTR;
                  ClassDescription:PCWSTR;
                  BootCritical:BOOL;
                  DriverSignature:DismDriverSignature;
                  ProviderName:PCWSTR;
                  Date:SYSTEMTIME;
                  MajorVersion:UINT;
                  MinorVersion:UINT;
                  Build:UINT;
                  Revision:UINT;
end;
{$align off}
_PDismDriverPackage= ^_DismDriverPackage;
_DismDriverPackages=array of  _DismDriverPackage;

type _DismFeature=record

     FeatureName:PCWSTR;
     State:DismPackageFeatureState;
end;
_PDismFeature= ^_DismFeature;
_DismFeatures=array of  _DismFeature;

function winver: string;
function GetOsVersion_(var pk_OsVer: RTL_OSVERSIONINFOEXW): Boolean;

function GetFileVersion_(const FileName: ansistring;
     var Major, Minor, Release, Build: word): boolean;

function init_lib:boolean;
function dism_mount(image,folder:string;flags:dword=DISM_MOUNT_READWRITE):integer;
function dism_unmount(folder:string;flags:dword=DISM_COMMIT_IMAGE):integer;
function dism_opensession(folder:string):integer;
function dism_closesession:integer;
function dism_addpackage(package:string):integer;
function dism_adddriver(driver:string):integer;
function dism_addcapability(capability:string):integer;
function dism_GetPackages(var packages:_DismPackages ):integer;
function dism_GetDrivers(var drivers:_DismDriverPackages ):integer;
function Dism_GetFeatures(var features:_DismFeatures ):integer;
function Dism_GetLastErrorMessage:string;
function Dism_GetImageInfo(imagefilepath:string;var imagesinfo:_DismImagesInfo):integer;
function Dism_MountedImageInfo(var ImagesInfo:_DismMountedImagesInfo   ):integer;

var
dismapi_filename:string;
//
  DismInitialize:function(LogLevel:integer;LogFilePath:PCWSTR;ScratchDirectory:PCWSTR):integer;stdcall;
  DismOpenSession:function(ImagePath:PCWSTR;WindowsDirectory:PCWSTR;SystemDrive:PCWSTR;var DismSession:integer):integer;stdcall;
  DismCloseSession:function(DismSession:integer):integer;stdcall;
  DismMountImage:function(ImageFilePath:PCWSTR;
                 MountPath:PCWSTR;
                 ImageIndex:integer;
                 ImageName:PCWSTR;
                 ImageIdentifier:integer;
                 Flags:dword;
                 CancelEvent,Progress,UserData:pointer):integer;stdcall;
  DismUnmountImage:function(
                   MountPath:PCWSTR;
                    Flags:dword;
  CancelEvent,Progress,UserData:pointer):integer;stdcall;
  DismCleanupMountPoints:function():integer;stdcall;
  DismAddPackage:function(
          Session:integer;
          PackagePath:PCWSTR;
          IgnoreCheck:boolean;
          PreventPending:boolean;
          CancelEvent,Progress,UserData:pointer):integer;stdcall;
  DismAddDriver:function(
  Session:integer;
  DriverPath:PCWSTR;
  ForceUnsigned:boolean):integer;stdcall;
  DismAddCapability:function(
    Session:integer;
    Name:PCWSTR;
    LimitAccess:boolean;
    SourcePaths:PCWSTR;
    SourcePathCount:integer;
    CancelEvent,Progress,UserData:pointer):integer;stdcall;
  DismGetPackages:function(
     Session:integer;
     DismPackage:ppointer;
     Count:puint):integer;stdcall;
  DismDelete:function(DismStructure:pointer):integer;stdcall;
DismGetDrivers:function(
  Session:integer;
   AllDrivers:boolean;
  DriverPackage:ppointer;
     Count:pdword):integer;stdcall;
 DismGetFeatures:function(
              Session:integer;
              Identifier:PCWSTR;
    PackageIdentifier:DismPackageIdentifier;
  Feature:ppointer;
  Count:pdword):integer;stdcall;
DismGetLastErrorMessage:function(ErrorMessage:ppointer):integer;stdcall;
DismShutdown:function():integer;stdcall;
DismGetImageInfo:function(ImageFilePath:PCWSTR;ImageInfo:ppointer;Count:pdword):integer;stdcall;
DismGetMountedImageInfo:function(MountedImageInfo:ppointer;Count:pdword):integer;stdcall;





implementation

var session:integer;


function init_lib:boolean;
var
{$IFDEF win32}lib:cardinal;{$endif}
{$IFDEF win64}lib:int64;{$endif}
p:pchar;
begin
result:=false;
try
lib:=0;
//C:\Windows\SysWOW64\
    lib:=loadlibrary('DismAPI.dll');
if lib<=0 then
  begin
  raise exception.Create  ('could not loadlibrary:'+inttostr(getlasterror));
  exit;
  end;
//
getmem(p,512);
if GetModuleFileName(lib ,p,512)>0 then
  begin
  dismapi_filename:=strpas(p);
  end;
freemem(p);
//
DismInitialize:=getProcAddress(lib,'DismInitialize');
DismOpenSession:=getProcAddress(lib,'DismOpenSession');
DismCloseSession:=getProcAddress(lib,'DismCloseSession');
DismMountImage:=getProcAddress(lib,'DismMountImage');
DismUnmountImage:=getProcAddress(lib,'DismUnmountImage');
DismCleanupMountPoints:=getProcAddress(lib,'DismCleanupMountPoints');
DismShutdown:=getProcAddress(lib,'DismShutdown');
DismAddPackage:=getProcAddress(lib,'DismAddPackage');
DismAddDriver:=getProcAddress(lib,'DismAddDriver');
DismAddCapability:=getProcAddress(lib,'DismAddCapability');
DismGetPackages:=getProcAddress(lib,'DismGetPackages');
DismDelete:=getProcAddress(lib,'DismDelete');
DismGetDrivers :=getProcAddress(lib,'DismGetDrivers');
DismGetFeatures:=getProcAddress(lib,'DismGetFeatures');
DismGetLastErrorMessage:=getProcAddress(lib,'DismGetLastErrorMessage');
DismGetImageInfo:=getProcAddress(lib,'DismGetImageInfo');
DismGetMountedImageInfo:=getProcAddress(lib,'DismGetMountedImageInfo');
result:=true;
except
on e:exception do raise exception.Create ('loadlibrary error:'+e.message);
end;
end;

function GetOsVersion_(var pk_OsVer: RTL_OSVERSIONINFOEXW): Boolean;
type
  // type LONG (WINAPI* tRtlGetVersion)(RTL_OSVERSIONINFOEXW*);
  tRtlGetVersion = function (var PRTL_OSVERSIONINFOEXW: RTL_OSVERSIONINFOEXW): integer; stdcall;
var
  StructSize: integer;
  h_NtDll : HMODULE;
  RtlGetVersion: tRtlGetVersion;
begin
  StructSize := SizeOf(RTL_OSVERSIONINFOEXW);
  //ZeroMemory(pk_OsVer, StructSize);
  fillchar(pk_OsVer,0,StructSize);
  pk_OsVer.dwOSVersionInfoSize := StructSize;
 
  h_NtDll := GetModuleHandleW('ntdll.dll');
  RtlGetVersion := GetProcAddress(h_NtDll, 'RtlGetVersion');
  if not Assigned(RtlGetVersion) then 
    Result := False // This will never happen (all processes load ntdll.dll)
  else
    Result := ( RtlGetVersion(pk_OsVer) = 0 );  
end;




//
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

//%windir%\Sysnative

function SystemDir: string;
var 
  dir: array [0..MAX_PATH] of Char; 
begin 
  GetSystemDirectory(dir, MAX_PATH); 
  Result := StrPas(dir); 
end;

function winver: string;
var
  ver: TOSVersionInfo;
  reg:TRegistry ;
  CurrentMajorVersionNumber,CurrentMinorVersionNumber:integer;
  Major, Minor, Release, Build:word;
begin
  ver.dwOSVersionInfoSize := SizeOf(ver);
  if GetVersionEx(ver) then
    with ver do result := IntToStr(dwMajorVersion) + '.' + IntToStr(dwMinorVersion) + '.' + IntToStr(dwBuildNumber); // + ' (' + szCSDVersion + ')';
//
try
if GetFileVersion_(SystemDir+'\kernel32.dll',Major, Minor, Release, Build) then
  begin
  if (major>=ver.dwMajorVersion) then
    begin
    ver.dwMajorVersion :=major;
    if minor>=ver.dwMinorVersion then
      begin
      ver.dwMinorVersion :=minor;
      if Release >=ver.dwBuildNumber then ver.dwBuildNumber:=release;
      end; //if minor>=ver.dwMinorVersion the
    end; //if (major>=ver.dwMajorVersion) then
    with ver do result := IntToStr(dwMajorVersion) + '.' + IntToStr(dwMinorVersion) + '.' + IntToStr(dwBuildNumber);
  end; //if GetFileVersion_
except
end;  

//It looks like you are passing KEY_WOW64_64KEY ($0100), so you should be looking at the 64-bit registry branch.
//If you want to look at the 32-bit registry branch, you should pass KEY_WOW64_32KEY ($0200).

try
reg := TRegistry.Create(KEY_READ or $0100);
reg.RootKey :=HKEY_LOCAL_MACHINE ;
if reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion',false)=true then
  begin
  //CurrentMajorVersionNumber windows 10
  //CurrentMinorVersionNumber windows 10
  CurrentMajorVersionNumber:=0;CurrentMinorVersionNumber:=0;
  if reg.ValueExists('CurrentMajorVersionNumber') then CurrentMajorVersionNumber:=reg.ReadInteger('CurrentMajorVersionNumber');
  if reg.ValueExists('CurrentMinorVersionNumber') then CurrentMinorVersionNumber:=reg.ReadInteger('CurrentMinorVersionNumber');
  if CurrentMajorVersionNumber=10 then
    with ver do result := IntToStr(CurrentMajorVersionNumber) + '.' + IntToStr(CurrentMinorVersionNumber) + '.' + IntToStr(dwBuildNumber);
  reg.CloseKey ;
  end;
reg.Free ;
except
end;  

end;

//*****************************************************************

function DismProgressCallback(Current,Total:integer;UserData:pointer):dword;
begin
if current=0 then;
if total=0 then ;
end;

function Dism_GetLastErrorMessage:string;
var
hr:integer;
p:_PDismString;
ws:widestring;
begin
hr := DismGetLastErrorMessage(@p);
if hr=s_ok then
  begin
  ws:=p^.Value;
  result:=ws;
  DismDelete (p);
  end;
end;

function Dism_GetImageInfo(imagefilepath:string;var imagesinfo:_DismImagesInfo):integer;
var
count:dword;
p:pointer;
b:byte;
begin
if not FileExists(imagefilepath  ) then raise exception.Create('file does not exist');
count:=0;
{$IFDEF win32}
result:=DismGetImageInfo (pwidechar(widestring(imagefilepath)),@p,@count);
{$endif}
{$IFDEF win64}
result:=DismGetImageInfo (pwidechar((imagefilepath)),@p,@count);
{$endif}

if count>0 then
  begin
  SetLength (imagesinfo,count);
  //messagebox(0, pchar(inttostr(count)),'tinydism',0);
  copymemory(@imagesinfo[0] ,p,count*sizeof(_DismImageInfo ));
  end;//if count>0 ...

end;

//HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WIMMount\Mounted Images
//https://stackoverflow.com/questions/13382668/detecting-if-a-directory-is-a-junction-in-delphi
function Dism_MountedImageInfo(var ImagesInfo:_DismMountedImagesInfo  ):integer;
var
p,NewPointer:pointer;
pp:ppointer;
count:dword;
b:byte;
begin
count:=0;

result:=DismGetMountedImageInfo (@p,@count);
if count>0 then
  begin
  SetLength (ImagesInfo,count);
  copymemory(@ImagesInfo[0] ,p,count*sizeof(_DismMountedImageInfo ));
  end;//if count>0 ...

end;

function Dism_GetFeatures(var features:_DismFeatures ):integer;
var
p,NewPointer:pointer;
pp:ppointer;
count:dword;
b:byte;
begin
count:=0;

result:=DismGetFeatures (session,nil,DismPackageName,@p,@count);
if count>0 then
  begin
  SetLength (features,count);
  copymemory(@features[0] ,p,count*sizeof(_DismFeature ));
  end;//if count>0 ...

end;

function dism_GetDrivers(var drivers:_DismDriverPackages ):integer;
var
p,NewPointer:pointer;
pp:ppointer;
count:dword;
b:byte;
begin
count:=0;

result:=DismGetDrivers (session,true,@p,@count);
if count>0 then
  begin
  SetLength (drivers,count);
  //messagebox(0, pchar(inttostr(count)),'tinydism',0);
  copymemory(@drivers[0] ,p,count*sizeof(_DismDriverPackage ));
 {
 NewPointer:=p;
 copymemory(@drivers[0] ,NewPointer,sizeof(_DismDriverPackage ));
  for b:=1 to count-1 do
    begin
    NewPointer := Pointer(NativeUInt(p) + (sizeof(_DismDriverPackage )*b));
    //messagebox(0, _PDismPackage(NewPointer)^.PackageName,'tinydism',0);
    copymemory(@drivers[b] ,NewPointer,sizeof(_DismDriverPackage ));
    end;
 }
  end;//if count>0 ...

end;

function dism_GetPackages(var packages:_DismPackages ):integer;
var
p,NewPointer:pointer;
pp:ppointer;
count:uint;
b:byte;
begin
count:=0;

result:=DismGetPackages (session,@p,@count);
if count>0 then
  begin
  SetLength (packages,count);
  copymemory(@packages[0] ,p,count*sizeof(_dismpackage ));

 //messagebox(0, _PDismPackage(p)^.PackageName,'tinydism',0);
 {
 NewPointer:=p;
 copymemory(@packages[0] ,NewPointer,sizeof(_dismpackage ));
  for b:=1 to count-1 do
    begin
    NewPointer := Pointer(NativeUInt(p) + (sizeof(_dismpackage )*b));
    //messagebox(0, _PDismPackage(NewPointer)^.PackageName,'tinydism',0);
    copymemory(@packages[b] ,NewPointer,sizeof(_dismpackage ));
    end;
  }
  //DismDelete(p);
  end;//if count>0 ...

end;

//“Language.Basic~~~en-US~0.0.1.0”
function dism_addcapability(capability:string):integer;
begin
{$IFDEF win32}
result := DismAddCapability(Session, pwidechar(widestring(capability)), TRUE, nil, 0, nil, nil, nil);
{$endif}
{$IFDEF win64}
result := DismAddCapability(Session, pwidechar((capability)), TRUE, nil, 0, nil, nil, nil);
{$endif}
end;

function dism_adddriver(driver:string):integer;
begin
if not FileExists(driver) then raise exception.Create('file does not exist');
{$IFDEF win32}
result := DismAddDriver (session,pwidechar(widestring(driver)),true);
{$endif}
{$IFDEF win64}
result := DismAddDriver (session,pwidechar((driver)),true);
{$endif}
end;

function dism_addpackage(package:string):integer;
begin
if not FileExists(package ) then raise exception.Create('file does not exist');
{$IFDEF win32}
result := DismAddPackage (session,pwidechar(widestring(package)),TRUE, FALSE, nil, nil, nil);
{$endif}
{$IFDEF win64}
result := DismAddPackage (session,pwidechar((package)),TRUE, FALSE, nil, nil, nil);
{$endif}
end;

function dism_closesession:integer;
begin
result := DismCloseSession (session);
end;

function dism_opensession(folder:string):integer;
begin
if not directoryexists(folder) then raise exception.Create('folder does not exist'); 
{$IFDEF win32}
result := DismOpenSession(pwidechar(widestring(folder )),nil,nil,session);
{$endif}
{$IFDEF win64}
result := DismOpenSession(pwidechar((folder )),nil,nil,session);
{$endif}
end;

function dism_unmount(folder:string;flags:dword=DISM_COMMIT_IMAGE):integer;
begin
{$IFDEF win32}
result:=DismUnmountImage(pwidechar(widestring(folder)),flags,nil,nil,nil);
{$endif}
{$IFDEF win64}
result:=DismUnmountImage(pwidechar((folder)),flags,nil,nil,nil);
{$endif}
end;

function dism_mount(image,folder:string;flags:dword=DISM_MOUNT_READWRITE):integer;
begin
//ImageFilePath,MountPath, ImageIndex,ImageName,ImageIdentifier,Flags,
//To mount an image from a VHD file, you must specify an ImageIndex of
if not FileExists(image) then raise exception.Create('file does not exist');
{$IFDEF win32}
result := DismMountImage(pwidechar(widestring(image)),pwidechar(widestring(folder)),1,nil,0,flags,nil,nil,nil);
{$endif}
{$IFDEF win64}
result := DismMountImage(pwidechar((image)),pwidechar((folder)),1,nil,0,flags,nil,nil,nil);
{$endif}
end;

end.
