unit CPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RAM, UTypen;

type CPU = class

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
   Eff.: Führt einen Befehl im RAM an Stelle IP aus.
   Erg.: Liefert genau dann TRUE, wenn die Simulation zu Ende ist.
   }
   function Step() : Boolean;
end;

implementation



end.

