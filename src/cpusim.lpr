program cpusim;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, form_main, uRAM, uCompiler, uTypen, uAdvancedRecords, uOPCodes;

{$R *.res}

begin
  Application.Title:='CPU Simulator Herder14';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

