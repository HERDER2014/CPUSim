unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, uTypen;

type TCPU = class

   private Reg : TRegRecord;

   public constructor Create(var r : TRam);

   {
   Vor.: -
   Eff.: -
   Erg.: Liefert den Wert von Register 'index'.
   }
   public function ReadRegister(index : RegisterIndex) : Word;

   {
   Vor.: Simulation nicht am Ende.
   Eff.: Befehl im RAM an Stelle IP wurde ausgeführt.
   Erg.: Liefert genau dann TRUE, wenn die Simulation zu Ende ist.
   }
   function Step() : Boolean;
end;

implementation

constructor TCPU.Create(var r : TRAM);
begin

end;

function TCPU.ReadRegister(index : RegisterIndex) : Word;
begin

end;

function TCPU.Step() : Boolean;
begin

end;

end.

