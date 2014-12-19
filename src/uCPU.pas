unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, UTypen;

type CPU = class

   private Reg : TRegRecord;
           var Ram : TRAM;

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

constructor CPU.Create(var r : TRam);
begin
   Ram := r;
   Reg := TRegRecord.Create();
end;

function CPU.ReadRegister(index : RegisterIndex) : Word;
begin
   case index of
      AX: result:=Reg.AX;
      AL: result:=Reg.AX and 255;
      AH: result:=Reg.AX shr 8;

      BX: result:=Reg.BX;
      BL: result:=Reg.BX and 255;
      BH: result:=Reg.BX shr 8;

      CX: result:=Reg.CX;
      CL: result:=Reg.CX and 255;
      CH: result:=Reg.CX shr 8;

      DX: result:=Reg.DX;
      DL: result:=Reg.DX and 255;
      DH: result:=Reg.DX shr 8;

      BP: result:=Reg.BP;
      IP: result:=Reg.IP;
      SP: result:=Reg.SP;
      FLAGS: result:=Reg.FLAGS;
   end;
end;

end.

