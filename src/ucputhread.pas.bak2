unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCPU;
  type TCPUThread = class(TThread)
    private
      sim : TCPU;
      Handle : THandle;
      cs:TRTLCriticalSection;
      v:Int64;
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
      procedure step();

      {
      Vor.: start wurde nicht oder stop wurde nach start aufgerufen
      Eff.: CPU.step wird ausgefuehrt mit v ms pause zwischen jeder Ausfuehrung
      Erg.: -
      }
      procedure setVel(v :int64);

      destructor destroy();
  end;
implementation


constructor TCPUThread.create(sim: TCPU);
begin
  inherited Create(true);
  self.sim = sim;
  InitCriticalSection(cs);
end;

procedure TCPUThread.setVel(v :int64);
begin
    EnterCriticalSection(cs);
  try
    self.v := v;
  finally
    LeaveCriticalSection(cs);
  end;
end;

procedure TCPUThread.Execute;
begin
  while (not Terminated) and (not sim.Step()) do begin
     EnterCriticalSection(cs);
   try
     start := GetTickCount;
     repeat
       stop := GetTickCount;
     until (stop - start) >= v;
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

