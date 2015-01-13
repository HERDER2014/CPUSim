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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    RefreshTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
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
  ram := TRAM.Create(0);
  simulator := TCPU.Create(ram);
  cpuThread := TCPUThread.Create(simulator);
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

procedure TForm1.Button1Click(Sender: TObject);
begin

  cpuThread.Start;

end;

end.

