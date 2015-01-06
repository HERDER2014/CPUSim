unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, UTypen;

type CPU = class

   private

   Reg : TRegRecord;
   var Ram : TRAM;

   {
   Vor.: -
   Eff.: b steht in Ram an Adresse SP ; SP -=1
   Erg.: -
   }
   procedure push(b : byte); overload;

   {
   Vor.: -
   Eff.: w steht in Ram an Adresse SP und SP-1 ; SP -=2
   Erg.: -
   }
   procedure push(w : word); overload;

   {
   Vor.: -
   Eff.: SP +=1;
   Erg.: wert an adresse SP
   }
   function pop_b():byte;

   {
   Vor.: -
   Eff.: SP +=2;
   Erg.: wert an adresse SP und SP+1
   }
   function pop_w():word;


   public constructor Create(var r : TRam);

   {
   Vor.: -
   Eff.: -
   Erg.: Liefert den Wert von Register 'index'.
   }
   public function ReadRegister(index : RegisterIndex) : Word;

   {
   Vor.: -
   Eff.: w steht im Register 'index'
   Erg.: -
   }
   public procedure WriteRegister(index : RegisterIndex; w:Word);

   {
   Vor.: Simulation nicht am Ende.
   Eff.: Befehl im RAM an Stelle IP wurde ausgeführt.
   Erg.: Liefert genau dann TRUE, wenn die Simulation zu Ende ist.
   }
   public function Step() : Boolean;



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

procedure CPU.WriteRegister(index : RegisterIndex; w: Word);
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

procedure CPU.push(b : byte);
begin
  Ram.WriteByte(Reg.SP,b);
  Reg.SP-=1;
end;

procedure CPU.push(w : word);
begin
  Ram.WriteWord(Reg.SP-1,w);
  Reg.SP-=2;
end;

function CPU.pop_b():byte;
begin
  result:=Ram.ReadByte(Reg.SP+1);
  Reg.SP+=1;
end;

function CPU.pop_w():word;
begin
  result:=Ram.ReadWord(Reg.SP+1);
  Reg.SP+=2;
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
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)));
        Reg.IP += 4;
      end; // MOV R,[x]
      4: begin
        Ram.WriteWord(ReadRegister(Ram.ReadByte(Reg.IP+1)),ReadRegister(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end; // MOV [R],R
      5: begin
        Ram.WriteWord(Ram.ReadWord(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+3)));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //add R,[R]
      11: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //sub R,[x]
      15: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))) + ReadRegister(Ram.ReadByte(Reg.IP+1)));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) * ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 4;
      end; //mul R,[x]
      19: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))) * ReadRegister(Ram.ReadByte(Reg.IP+1)));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Ram.ReadWord(Reg.IP+2)));
        Reg.IP += 4;
      end; //div R,[x]
      23: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Ram.ReadWord(Reg.IP+2)));
        Reg.IP += 4;
      end; //div R,[x]
      27: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))));
        Reg.IP += 3;
      end; //div R,[R]
      28: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod ReadRegister(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end; //div R,R


      // 29 cmp R,x

      30: begin
        WriteRegister(RegisterIndex.IP ,Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+1))));
      end; //jmp [R]
      31: begin
        WriteRegister(RegisterIndex.IP ,Ram.ReadWord(Ram.ReadWord(Reg.IP+1)));
      end; //jmp [X]
     // 34 js [R]
     // 35 js [X]
     // 37 jz [X]
     // 38 jz [R]
     // 40 je [X]
     // 41 je [R]
      42: begin
        push(ReadRegister(RegisterIndex.IP+3));
        WriteRegister(RegisterIndex.IP,Ram.ReadWord(Reg.IP+1));
      end; //call [X]
      43: begin
        push(ReadRegister(RegisterIndex.IP+2));
        WriteRegister(RegisterIndex.IP,ReadRegister(Ram.ReadByte(Reg.IP+1)));
      end; //call [R]
      45: begin
        WriteRegister(RegisterIndex.IP,pop_b());
      end; //pop R
      46: begin
        push(ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP+=1;
      end;// push R
      47: begin
        push(Ram.ReadWord(Reg.IP+1));
        Reg.IP+=2;
      end;// push x
      48: begin
        pop_w();
        Reg.IP+=1;
      end; //pop			(in kein Register)
      49: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),pop_w());
        Reg.IP+=2;
      end; //pop R
      50: begin
        WriteRegister(ReadByte(Reg.IP+1),not ReadRegister(ReadByte(Reg.IP+1)));
        Reg.IP += 2;
      end; //not R		(binär)
      51: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) and Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; //and R,x
      52: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) and ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //and R,R

      53: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) or Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; //or R,x
      54: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) or ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //or R,R

      55: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) xor Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; //xor R,x
      56: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) xor ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 3;
      end; //xor R,R

   end;
end;

end.

