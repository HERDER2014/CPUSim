unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, UTypen;

type CPU = class

   private Reg : TRegRecord;
           var Ram : TRAM;
           function WriteRegister(index : RegisterIndex, w:Word);

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

function CPU.WriteRegister(index : RegisterIndex, w: Word);
begin
   case index of
      AX: Reg.AX := w;
      AL: Reg.AX := (w and 255) or (Reg.AX and (255 shl 8));
      AH: Reg.AX := (w and (255 shl 8)) or (Reg.AX and 255);

      BX: Reg.BX := w;
      BL: Reg.BX := (w and 255) or (Reg.BX and (255 shl 8));
      BH: Reg.BX := (w and (255 shl 8)) or (Reg.BX and 255);

      CX: Reg.CX := w;
      CL: Reg.CX := (w and 255) or (Reg.CX and (255 shl 8));
      CH: Reg.CX := (w and (255 shl 8)) or (Reg.CX and 255);

      DX: Reg.DX := w;
      DL: Reg.DX := (w and 255) or (Reg.DX and (255 shl 8));
      DH: Reg.DX := (w and (255 shl 8)) or (Reg.DX and 255);

      BP: Reg.BP := w;
      IP: Reg.IP := w;
      SP: Reg.SP := w;
      FLAGS: Reg.FLAGS := w;
   end;
end;


function CPU.Step() : Boolean;
begin
   case Ram.ReadByte(Reg.IP) of
      0: result:=True;
      1: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; // MOV R,x
      2: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(IP+2))));
        Reg.IP += 3;
      end; // MOV R,[R]
      3: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(IP+2)));
        Reg.IP += 4;
      end; // MOV R,[x]
      4: begin
        Ram.WriteWord(ReadRegister(Ram.ReadByte(IP+1)),ReadRegister(Ram.ReadByte(IP+2)));
        Reg.IP += 3;
      end; // MOV [R],R
      5: begin
        Ram.WriteWord(Ram.ReadWord(IP+1),ReadRegister(Ram.ReadByte(IP+3)));
        Reg.IP += 4;
      end; // mov [x],R
      6: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end;//mov R,R
     // 7 mov R,[R+x]	()
     // 8 mov [R+x],R


      9: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //add R,x
      10: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(IP+2))) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //add R,[R]
      11: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //add R,[x]
      12: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //add R,R


      13: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Reg.IP+2) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //sub R,x
      14: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Ram.ReadWord(IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //sub R,[x]
      15: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(ReadRegister(Ram.ReadByte(IP+2))) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //sub R,[R]
      16: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-ReadRegister(Ram.ReadByte(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //sub R,R


      17: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2) * ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //mul R,x
      18: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(IP+2)) * ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //mul R,[x]
      19: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(IP+2))) * ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //mul R,[R]
      20: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) * ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //mul R,R


      21: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; //div R,x
      22: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Ram.ReadWord(IP+2)));
        Reg.IP += 4;
      end; //div R,[x]
      23: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(ReadRegister(Ram.ReadByte(IP+2))));
        Reg.IP += 3;
      end; //div R,[R]
      24: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div ReadRegister(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end; //div R,R


      25: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; //div R,x
      26: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Ram.ReadWord(IP+2)));
        Reg.IP += 4;
      end; //div R,[x]
      27: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(ReadRegister(Ram.ReadByte(IP+2))));
        Reg.IP += 3;
      end; //div R,[R]
      28: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod ReadRegister(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end; //div R,R


      // 29 cmp R,x

      30 jmp [R]
      31 jmp [X]
      34 js [R]
      35 js [X]
      37 jz [X]
      38 jz [R]
      40 je [X]
      41 je [R]
      42 call [X]
      43 call [R]
      45 ret
      46 push R
      47 push x
      48 pop			(in kein Register)
      49 pop R
      50 not R		(binär)
      51 and R,x
      52 and R,R
      53 or R,x
      54 or R,R
      55 xor R,x
      56 xor R,R
}
   end;
end;

end.

