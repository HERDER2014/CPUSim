unit uCPUThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uCPU;
  type CPUThread = class
    private
      //nichts
    public

      {
      Vor.: sim ist kreiert
      Eff.: thread ist kreiert
      Erg.: -
      }
      constructor create(sim : CPU);

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


end.

