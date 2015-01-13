unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCPU;
  type TCPUThread = class
    private
      //nichts
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
      procedure start(v :int64);

      {
      Vor.: start wurde aufgerufen, stop wurde nicht nach start aufgerufen
      Eff.: CPU.step wird nichtmehr ausgefuehrt
      Erg.: -
      }
      procedure stop();
      destructor destroy();
  end;
implementation

constructor TCPUThread.create(sim : TCPU);
begin

end;

procedure TCPUThread.step();
begin

end;

procedure TCPUThread.start(v :int64);
begin

end;

procedure TCPUThread.stop();
begin

end;

destructor TCPUThread.destroy();
begin

end;

end.

