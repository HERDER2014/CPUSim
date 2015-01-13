unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCPU;
  type TCPUThread = class(TThread)
    private
      sim : TCPU;
//      Handle : THandle;
      cs:TRTLCriticalSection;
      v:Int64;
    public

      {
      Vor.: sim ist kreiert
      Eff.: thread ist kreiert
      Erg.: -
      }
      constructor create(sim2 : TCPU);

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
      procedure setVel(v2 :int64);

      destructor destroy();
  end;
implementation

procedure TCPUThread.step();
begin

end;
//
//procedure TCPUThread.start(v2 :int64);
//begin
//
//end;
//
//procedure TCPUThread.stop();
//begin
//
//end;
//
destructor TCPUThread.destroy();
begin

end;

constructor TCPUThread.create(sim2: TCPU);
begin
  inherited Create(true);
  self.sim := sim2;
  InitCriticalSection(cs);
end;

procedure TCPUThread.setVel(v2 :int64);
begin
  {$IFDEF windows}
    EnterCriticalSection(cs.LockCount);
  {$ELSE}
    EnterCriticalSection(cs.__m_count);
  {$ENDIF}
  try
    self.v := v;
  finally
    {$IFDEF windows}
      LeaveCriticalSection(cs.LockCount);
    {$ELSE}
      LeaveCriticalSection(cs.__m_count);
    {$ENDIF}
  end;
end;

procedure TCPUThread.Execute;
begin
  while (not Terminated) and (not sim.Step()) do begin
   {$IFDEF windows}
     EnterCriticalSection(cs.LockCount);
   {$ELSE}
     EnterCriticalSection(cs.__m_count);
   {$ENDIF}
   try
     start := GetTickCount;
     repeat
       stop := GetTickCount;
     until (stop - start) >= v;
   finally
     {$IFDEF windows}
       LeaveCriticalSection(cs.LockCount);
     {$ELSE}
       LeaveCriticalSection(cs.__m_count);
     {$ENDIF}
   end;
  end;
end;

destructor TCPUThread.destroy();
begin
  inherited destroy();
  DoneCriticalsection(cs);
end;

end.

