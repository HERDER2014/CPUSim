unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
	 Classes, SysUtils, uCPU, uOPCodes, uTypen, EpikTimer;

type

   { TCPUThread }

  TCPUThread = class(TThread)
	 private
			 cpu: TCPU;
			 cs: TRTLCriticalSection;
			 p: extended;
			 stopAtSP: word;
			 FException: string;
   	   countBefehle: int64;
       elapsedTime: Extended;
	 public

			{
      Vor.: sim ist kreiert
      Eff.: thread ist kreiert
      Erg.: -
      }
			 constructor Create(sim: TCPU);

			{
      Vor.: -
      Eff.: Die Frequenz der Ausführung wird auf v (in Hz) gesetzt. Ist v = 0,
            so wird so schenlle simuliert, wie möglich. Ist v = -1 so wird beim
            Aufruf von resume nur ein Schritt ausgefuehrt. Ist v = -2 und der
            naechste auszufuehrende Befehl CALL ist, so werden beim Aufruf von
            resume genau soviele schritte ausgefuehrt, dass die aufgerufenen
            Funktion (CALL) wieder zuruckgekehrt ist (RET). Ist v = -2 und der
            naechste auszufuehrende Befehl ist nicht CALL, so wird nur ein Schritt ausgeführt.
      Erg.: -
      }
			 procedure setVel(v: extended);

			{
      Vor.: Der Thread wurde beendet (Terminated = True)
      Eff.: -
      Erg.: Gibt die Fehlermeldung des Fehlers zurueck, welcher fuer die beendung
            des Thread gesorgt hat. Wurde der Thread durch den Aufruf von Terminate
            oder durch das Erreichen des OP-Codes END (ID 0) beendet, so wird ''
            zurueckgegeben
      }
			 function getException(): string;
      {
      Vor.: -
      Eff.: -
      Erg.: Gibt die Anzahl der bisher ausgeführten Befehle zurück
      }
       function getBefehlCount(): Int64;
      {
      Vor.: Der Thread wurde beendet (Terminated = True)
      Eff.: -
      Erg.: Gibt die Zeit der Ausführung in Sekunden zurück.
      }
       function getElapsedTime(): Extended;

			{
        DO NOT CALL THIS OR YOU WILL EXECUTE IT IN THE SAME THREAD
         -> use the resume and terminate procedures provided by TThread
      }
			 procedure Execute(); override;

			 destructor Destroy(); override;
	 end;

implementation


constructor TCPUThread.Create(sim: TCPU);
begin
	 cpu := sim;
	 FreeOnTerminate := True;
	 InitCriticalSection(cs);
	 inherited Create(True);
end;

procedure TCPUThread.setVel(v: extended);
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
	 t: extended;
	 op_code: OPCode;
	 StackPointer: word;
	 ET: TEpikTimer;
begin
	 stopAtSP := High(word); // at start do not stop at any specific Stack-Pointer
	 FException := '';
	 ET := TEpikTimer.Create(nil);
	 countBefehle := 0;
	 ET.Start;
	 while (not Terminated) do
	 begin
			 StackPointer := cpu.ReadRegister(SP);

			 // stop at specific Stack-Pointer
			 if (StackPointer = stopAtSP) then
			 begin
					 stopAtSP := High(word);
					 suspend;
					 continue;
			 end;
			 try
					 op_code := cpu.Step();
			 except
					 on Ex: Exception do
					 begin
							 // break on Exception
							 FException := Ex.Message;
							 break;
					 end;
			 end;

			 // break on END
			 if (op_code = _END) then
			 begin
					 break;
			 end;

			 // get sleep duration in t inside CriticalSection
			 EnterCriticalSection(cs);
			 try
					 t := p;
			 finally
					 LeaveCriticalSection(cs);
			 end;

       Inc(countBefehle);
			 // suspend or sleep depending on t and other parameters
			 if ((op_code = CALL_X) or (op_code = CALL_R)) and (stopAtSP = High(word)) and
					 (t = -2) then
					 stopAtSP := StackPointer
			 else if ((t < 0) and (stopAtSP = High(word))) then
			 begin
					 stopAtSP := High(word);
					 suspend;
					 continue;
			 end
			 else if (t > 0) then
			 begin
					 while (ET.Elapsed < countBefehle / t) do
					 begin
					 end;
			 end;
	 end;
   elapsedTime:= ET.Elapsed;
	 ET.Destroy;
end;

function TCPUThread.getException(): string;
begin
	 Result := FException;
end;

function TCPUThread.getBefehlCount(): Int64;
begin
  result:= countBefehle;
end;

function TCPUThread.getElapsedTime(): Extended;
begin
  result:= elapsedTime;
end;

destructor TCPUThread.Destroy();
begin
	 inherited Destroy();
	 DoneCriticalsection(cs);
end;

end.
