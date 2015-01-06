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
   Eff.: w steht in Ram an Adresse SP und SP-1 ; SP -=2
   Erg.: -
   }
   procedure push(w : word); overload;

   {
   Vor.: -
   Eff.: SP +=2;
   Erg.: wert an adresse SP und SP+1
   }
   function pop():word;

   {
   Vor.: -
   Eff.: Flag f ist b;
   Erg.: -
   }
   procedure setFlag(f:TFlags; b:Boolean);

   {
   Vor.: -
   Eff.: -
   Erg.: Flag f;
   }
   function getFlag(f:TFlags):Boolean;


   {
   Vor.: -
   Eff.: die ersten 16 bit von w stehen im Register 'index'
         die Flags 'O','S' und 'Z' werden entsprechend gesehtz sofern f.
   Erg.: -
   }
   procedure WriteRegister(index : Byte; w:Integer; f:Boolean); overload;

   public constructor Create(var r : TRam);

   {
   Vor.: -
   Eff.: -
   Erg.: Liefert den Wert von Register 'index'.
   }
   public function ReadRegister(index : Byte) : Word;

   {
   Vor.: -
   Eff.: w steht im Register 'index'
   Erg.: -
   }
   public procedure WriteRegister(index : Byte; w:Word); overload;

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

   Reg.IP:=0;
   Reg.SP:=255;
   Reg.BP:=2045;
   Reg.FLAGS:=0;
   Reg.AX:=0;
   Reg.BX:=0;
   Reg.CX:=0;
   Reg.DX:=0;
   //   Reg := TRegRecord.Create();
end;

function CPU.ReadRegister(index : byte) : Word;
begin
   case index of
      Integer(AX): result:=Reg.AX;
      Integer(AL): result:=Reg.AX and 255;
      Integer(AH): result:=Reg.AX shr 8;

      Integer(BX): result:=Reg.BX;
      Integer(BL): result:=Reg.BX and 255;
      Integer(BH): result:=Reg.BX shr 8;

      Integer(CX): result:=Reg.CX;
      Integer(CL): result:=Reg.CX and 255;
      Integer(CH): result:=Reg.CX shr 8;

      Integer(DX): result:=Reg.DX;
      Integer(DL): result:=Reg.DX and 255;
      Integer(DH): result:=Reg.DX shr 8;

      Integer(BP): result:=Reg.BP;
      Integer(IP): result:=Reg.IP;
      Integer(SP): result:=Reg.SP;
      Integer(FLAGS): result:=Reg.FLAGS;
      else raise Exception.CreateFmt('Register with index %b is invalid.',[index]);
   end;
end;

procedure CPU.WriteRegister(index : byte; w: Word);
begin
   case index of
      Integer(AX): Reg.AX := w;
      Integer(AL): Reg.AX := (w and 255) or (Reg.AX and (255 shl 8));
      Integer(AH): Reg.AX := (w and (255 shl 8)) or (Reg.AX and 255);

      Integer(BX): Reg.BX := w;
      Integer(BL): Reg.BX := (w and 255) or (Reg.BX and (255 shl 8));
      Integer(BH): Reg.BX := (w and (255 shl 8)) or (Reg.BX and 255);

      Integer(CX): Reg.CX := w;
      Integer(CL): Reg.CX := (w and 255) or (Reg.CX and (255 shl 8));
      Integer(CH): Reg.CX := (w and (255 shl 8)) or (Reg.CX and 255);

      Integer(DX): Reg.DX := w;
      Integer(DL): Reg.DX := (w and 255) or (Reg.DX and (255 shl 8));
      Integer(DH): Reg.DX := (w and (255 shl 8)) or (Reg.DX and 255);

      Integer(BP): Reg.BP := w;
      Integer(IP): Reg.IP := w;
      Integer(SP): Reg.SP := w;
      Integer(FLAGS): Reg.FLAGS := w;
      else raise Exception.CreateFmt('Register with index %b is invalid.',[index]);
   end;
end;

procedure CPU.WriteRegister(index : Byte; w: Integer; f:Boolean);
begin
  WriteRegister(index,Word(w));
  if f then begin
    setFlag(TFlags.O, w>65535);
    setFlag(TFlags.S, w<0);
    setFlag(TFlags.Z, w=0);
  end;
end;


procedure CPU.push(w : word);
begin
  Ram.WriteWord(Reg.SP-1,w);
  Reg.SP-=2;
end;

function CPU.pop():word;
begin
  result:=Ram.ReadWord(Reg.SP+1);
  Reg.SP+=2;
end;

procedure CPU.setFlag(f:TFlags; b:Boolean);
begin
  if b then
    Reg.FLAGS := Reg.FLAGS or word(f)
  else
    Reg.FLAGS := Reg.FLAGS and (not word(f));
end;

function CPU.getFlag(f:TFlags):Boolean;
begin
  result:=Boolean(Reg.FLAGS and word(f));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))));
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
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //add R,x
      10: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //add R,[R]
      11: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //add R,[x]
      12: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //add R,R


      13: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Reg.IP+2) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //sub R,x
      14: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //sub R,[x]
      15: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //sub R,[R]
      16: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),-ReadRegister(Ram.ReadByte(Reg.IP+2)) + ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //sub R,R


      17: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2) * ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //mul R,x
      18: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) * ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //mul R,[x]
      19: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))) * ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //mul R,[R]
      20: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) * ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //mul R,R


      21: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //div R,x
      22: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Ram.ReadWord(Reg.IP+2)),true);
        Reg.IP += 4;
      end; //div R,[x]
      23: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))),true);
        Reg.IP += 3;
      end; //div R,[R]
      24: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) div ReadRegister(Ram.ReadByte(Reg.IP+2)),true);
        Reg.IP += 3;
      end; //div R,R


      25: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //div R,x
      26: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Ram.ReadWord(Reg.IP+2)),true);
        Reg.IP += 4;
      end; //div R,[x]
      27: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+2))),true);
        Reg.IP += 3;
      end; //div R,[R]
      28: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) mod ReadRegister(Ram.ReadByte(Reg.IP+2)),true);
        Reg.IP += 3;
      end; //div R,R

      29: begin
        setFlag(TFlags.O, false);
        setFlag(TFlags.S, ReadRegister(Ram.ReadByte(Reg.IP+1))<Ram.ReadWord(Reg.IP+2));
        setFlag(TFlags.Z, ReadRegister(Ram.ReadByte(Reg.IP+1))=Ram.ReadWord(Reg.IP+2));
        Reg.IP+=4;
      end; //cmp R,x

      30: begin
        Reg.IP:=Ram.ReadWord(ReadRegister(Ram.ReadByte(Reg.IP+1)));
      end; //jmp R
      31: begin
        Reg.IP:=Ram.ReadWord(Ram.ReadWord(Reg.IP+1));
      end; //jmp X
      34: begin

      end;//js R
     // 35 js X
     // 37 jz X
     // 38 jz R
      end;

      42: begin
        push(Reg.IP+3);
        Reg.IP:=Ram.ReadWord(Reg.IP+1);
      end; //call [X]
      43: begin
        push(Reg.IP+2);
        Reg.IP:=ReadRegister(Ram.ReadByte(Reg.IP+1));
      end; //call [R]
      44: begin
        setFlag(TFlags.O, false);
        setFlag(TFlags.S, ReadRegister(Ram.ReadByte(Reg.IP+1))<ReadRegister(Ram.ReadByte(Reg.IP+2)));
        setFlag(TFlags.Z, ReadRegister(Ram.ReadByte(Reg.IP+1))=ReadRegister(Ram.ReadByte(Reg.IP+2)));
        Reg.IP+=3;
      end; //cmp R, R
      45: begin
        Reg.IP:=pop();
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
        pop();
        Reg.IP+=1;
      end; //pop			(in kein Register)
      49: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),pop());
        Reg.IP+=2;
      end; //pop R
      50: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),not ReadRegister(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 2;
      end; //not R		(binär)
      51: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) and Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //and R,x
      52: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) and ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //and R,R

      53: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) or Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //or R,x
      54: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) or ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //or R,R

      55: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1), ReadRegister(Ram.ReadByte(Reg.IP+1)) xor Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //xor R,x
      56: begin
        WriteRegister(Ram.ReadByte(Reg.IP+1),ReadRegister(Ram.ReadByte(Reg.IP+2)) xor ReadRegister(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //xor R,R

   end;
end;

end.

