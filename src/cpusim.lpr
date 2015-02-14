program cpusim;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, form_main, uRAM, uCompiler, uTypen,
  form_options, asmHighlighter, EpikTimer;

{$R *.res}

begin
  Application.Title:='CPU Simulator Herder 14';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TmainFrm, mainFrm);
  Application.CreateForm(TOptionsFrm, OptionsFrm);
  Application.Run;
end.

