unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCPU, uOPCodes, uTypen;
  type TCPUThread = class(TThread)
    private
      cpu : TCPU;
      cs:TRTLCriticalSection;
      p:Int64;
      stopAtSP: Word;
      FException: String;
    public

      {
      Vor.: sim ist kreiert
      Eff.: thread ist kreiert
      Erg.: -
      }
      constructor create(sim : TCPU);

      {
      Vor.: -
      Eff.: Die Pause zwischen jeder ausfuehrung wird auf v (in ms) gesetzt. Ist
            v = -1 so wird beim aufruf von resume nur ein schritt ausgefuehrt.
            Ist v = -2 und der naechste auszufuehrende Befehl CALL ist, so
            werden beim aufruf von resume genau soviele schritte ausgefuehrt,
            dass die aufgerufenen funktion (CALL) wieder zuruckgekehrt ist (RET).
            Ist v = -2 und der naechste auszufuehrende Befehl ist nicht CALL, so
            wird nur ein schritt ausgefuehrt
      Erg.: -
      }
      procedure setVel(v :int64);

      {
      Vor.: Der Thread wurde beendet (Terminated = True)
      Eff.: -
      Erg.: Gibt die Fehlermeldung des Fehlers zurueck, welcher fuer die beendung
            des Thread gesorgt hat. Wurde der Thread durch den Aufruf von Terminate
            oder durch das Erreichen des OP-Codes END (ID 0) beendet, so wird ''
            zurueckgegeben
      }
      function getException():String;

      {
        DO NOT CALL THIS OR YOU WILL EXECUTE IT IN THE SAME THREAD
         -> use the resume and terminate procedures provided by TThread
      }
      procedure execute(); override;

      destructor destroy(); override;
  end;
implementation


constructor TCPUThread.create(sim: TCPU);
begin
  cpu := sim;
  InitCriticalSection(cs);
  inherited Create(true);
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
  t : Int64;
  op_code : OPCode;
  StackPointer: Word;

begin
  stopAtSP := High(Word);
  FException := '';
  while (not Terminated) do begin
   StackPointer := cpu.ReadRegister(SP);
   if (StackPointer = stopAtSP) then begin
     stopAtSP := High(Word);
     suspend;
     continue;
   end;
   try
     op_code := cpu.Step();
   except
     on Ex:Exception do begin
       FException := Ex.Message;
       break;
     end;
   end;
   if (op_code = _END) then begin
     break;
   end;
   EnterCriticalSection(cs);
   try
     t := p;
   finally
     LeaveCriticalSection(cs);
   end;

   if ((op_code = CALL_X) or (op_code = CALL_R)) and (stopAtSP = High(Word)) and (t=-2) then
      stopAtSP := StackPointer
   else if ((t<0) and (stopAtSP = High(Word))) then begin
     stopAtSP := High(Word);
     suspend;
     continue;
   end;

   Sleep(t);
  end;
end;

function TCPUThread.getException():String;
begin
  result:=FException;
end;

destructor TCPUThread.destroy();
begin
  inherited destroy();
  DoneCriticalsection(cs);
end;

end.

