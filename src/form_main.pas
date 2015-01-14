unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, uCPU, uRAM, uTypen, uCPUThread;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RefreshTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure OnCPUTerminate(Sender: TObject);
  private
    simulator : TCPU;
    ram : TRAM;
    cpuThread : TCPUThread;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  ram := TRAM.Create(0);         // \ sollte auch bei Start (Button1Click) sein
  simulator := TCPU.Create(ram); // / Hier nicht notwendig, da kein Compiler
end;

procedure TForm1.RefreshTimerTimer(Sender: TObject);
begin
  Label1.Caption := format('AX : %x',[simulator.ReadRegister(AX)]);
  Label2.Caption := format('BX : %x',[simulator.ReadRegister(BX)]);
  Label3.Caption := format('CX : %x',[simulator.ReadRegister(CX)]);
  Label4.Caption := format('DX : %x',[simulator.ReadRegister(DX)]);

  Label5.Caption := format('IP : %x',[simulator.ReadRegister(IP)]);
  Label6.Caption := format('SP : %x',[simulator.ReadRegister(SP)]);
  Label7.Caption := format('BP : %x',[simulator.ReadRegister(BP)]);
  Label8.Caption := format('FLAGS : %x',[simulator.ReadRegister(FLAGS)]);


end;

procedure TForm1.OnCPUTerminate(Sender: TObject);
begin
  if (cpuThread.getException() = '') then
     Label9.Caption:='Program ended Successfully'
  else
     Label9.Caption:= cpuThread.getException();
  cpuThread.free;
end;

procedure TForm1.Button1Click(Sender: TObject); //Start (also sets vel)
begin
  Label9.Caption:='';
  simulator.free;
  simulator := TCPU.Create(ram);
  cpuThread := TCPUThread.Create(simulator);
  Button5Click(nil);
  cpuThread.OnTerminate := @OnCPUTerminate;
  cpuThread.Start;
end;

procedure TForm1.Button2Click(Sender: TObject); //Resume
begin
    cpuThread.Resume;
end;

procedure TForm1.Button3Click(Sender: TObject); //Suspent / Pause
begin
    cpuThread.Suspend;
end;

procedure TForm1.Button4Click(Sender: TObject); //Terminate / Stop
begin
    cpuThread.Terminate;
end;

procedure TForm1.Button5Click(Sender: TObject); //SetVel
begin
     cpuThread.setVel(StrToInt64(Edit1.Text));
end;

end.

