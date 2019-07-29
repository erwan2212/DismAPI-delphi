program tinydism;

uses
  Forms,
  umain in 'umain.pas' {Form1},
  udismapi in 'udismapi.pas',
  DismLib_TLB in '..\..\..\..\..\..\..\Program Files (x86)\Borland\Delphi7\Imports\DismLib_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
