unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCPU;
  type TCPUThread = class(TThread)
    private
      cpu : TCPU;
      cs:TRTLCriticalSection;
      p:Int64;
    public

      {
      Vor.: sim ist kreiert
      Eff.: thread ist kreiert
      Erg.: -
      }
      constructor create(sim : TCPU);

      {
      Vor.: start wurde nicht oder stop wurde nach start aufgerufen
      Eff.: CPU.step wurde ausgefuehrt
      Erg.: -
      }
     // procedure step();

      {
      Vor.: start wurde nicht oder stop wurde nach start aufgerufen
      Eff.: CPU.step wird ausgefuehrt mit v ms pause zwischen jeder Ausfuehrung
      Erg.: -
      }
      procedure setVel(v :int64);

      procedure execute(); override;

      destructor destroy();
  end;
implementation


constructor TCPUThread.create(sim: TCPU);
begin
  inherited Create(true);
  cpu := sim;
  InitCriticalSection(cs);
end;

procedure TCPUThread.setVel(v :int64);
begin
  EnterCriticalSection(cs);
  try
    p := v;
  finally
    LeaveCriticalSection(cs);
  end;
end;

procedure TCPUThread.Execute;
var
  a,e : TDateTime;
begin
  while (not Terminated) and (not cpu.Step()) do begin
     EnterCriticalSection(cs);
   try
     a := Time();
     repeat
       e := Time();
     until (e - a) >= p;
   finally
     LeaveCriticalSection(cs);
   end;
  end;
end;

destructor TCPUThread.destroy();
begin
  inherited destroy();
  DoneCriticalsection(cs);
end;

end.

