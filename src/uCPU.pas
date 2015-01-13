unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, UTypen, uOPCodes;

type TCPU = class

   private

   Reg : TRegRecord;
   cs:TRTLCriticalSection;
   var Ram : TRAM;


   procedure push(w : word); overload;
   function pop():word;
   procedure setFlag(f:TFlags; b:Boolean);
   function getFlag(f:TFlags):Boolean;

   procedure WR(index : Byte; w:Word; flags:Boolean); overload;
   procedure WR(index : Byte; w:Word); overload;
   procedure WR(force:Boolean; index : Byte; w:Integer; flags:Boolean); overload;
   procedure WR(force:Boolean; index : Byte; w:Word); overload;
   function RR(index : Byte) : Word;

   public constructor Create(var r : TRam);

   {
   Vor.: index ist Registerindex
   Eff.: -
   Erg.: Liefert den Wert von Register 'index'.
   }
   public function ReadRegister(index : Byte) : Word;

   {
     DEBUG ONLY

   Vor.: index ist Registerindex
   Eff.: w steht im Register 'index' sofern erlaubt. Ist force, so steht w immer in Register 'index'
   Erg.: -
   Exceptions: Invalid Register / Not Allowed
   }
   public procedure WriteRegister(index : Byte; w:Word);

   {
   Vor.: Simulation nicht am Ende.
   Eff.: Befehl im RAM an Stelle IP wurde ausgeführt.
   Erg.: Liefert genau dann TRUE, wenn die Simulation zu Ende ist.
   Exeptions.: Runtimeerrors
   }
   public function Step() : Boolean;



end;

implementation
constructor TCPU.Create(var r : TRam);
begin
   Ram := r;

   Reg.IP:=0;
   Reg.SP:=2045;
   Reg.BP:=2045;
   Reg.FLAGS:=0;
   Reg.AX:=0;
   Reg.BX:=0;
   Reg.CX:=0;
   Reg.DX:=0;
   //   Reg := TRegRecord.Create();
end;

function TCPU.RR(index : byte) : Word;
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


procedure TCPU.WR(index : byte; w: Word);
begin
   WR(false,index,w);
end;

procedure TCPU.WR(index : byte; w: Word; flags: Boolean);
begin
   WR(false,index,w, flags);
end;

procedure TCPU.WR(force: Boolean; index : Byte; w: Integer; flags:Boolean);
begin
  WR(force,index,Word(w));
  if flags then begin
    setFlag(TFlags.O, w>65535);
    setFlag(TFlags.S, w<0);
    setFlag(TFlags.Z, Word(w)=0);
  end;
end;

procedure TCPU.WR(force: Boolean; index : byte; w: Word);
begin
   case index of
      Integer(AX): Reg.AX := w;
      Integer(AL): Reg.AX := (w and 255) or (Reg.AX and (255 shl 8));
      Integer(AH): Reg.AX := ((w and 255) shl 8) or (Reg.AX and 255);

      Integer(BX): Reg.BX := w;
      Integer(BL): Reg.BX := (w and 255) or (Reg.BX and (255 shl 8));
      Integer(BH): Reg.BX := ((w and 255) shl 8) or (Reg.BX and 255);

      Integer(CX): Reg.CX := w;
      Integer(CL): Reg.CX := (w and 255) or (Reg.CX and (255 shl 8));
      Integer(CH): Reg.CX := ((w and 255) shl 8) or (Reg.CX and 255);

      Integer(DX): Reg.DX := w;
      Integer(DL): Reg.DX := (w and 255) or (Reg.DX and (255 shl 8));
      Integer(DH): Reg.DX := ((w and 255) shl 8) or (Reg.DX and 255);

      Integer(BP): Reg.BP := w;
      else begin
        if force then begin
          case index of
            Integer(IP): Reg.IP := w;
            Integer(SP): Reg.SP := w;
            Integer(FLAGS): Reg.FLAGS := w;
            else raise Exception.CreateFmt('Register with index %x is invalid.',[index]);
          end;
        end else
          raise Exception.CreateFmt('Not allowed to write register with index %x.',[index]);
      end;
   end;
end;



procedure TCPU.push(w : word);
begin
  Ram.WriteWord(Reg.SP-1,w);
  Reg.SP-=2;
end;

function TCPU.pop():word;
begin
  result:=Ram.ReadWord(Reg.SP+1);
  Reg.SP+=2;
end;

procedure TCPU.setFlag(f:TFlags; b:Boolean);
begin
  if b then
    Reg.FLAGS := Reg.FLAGS or word(f)
  else
    Reg.FLAGS := Reg.FLAGS and (not word(f));
end;

function TCPU.getFlag(f:TFlags):Boolean;
begin
  result:=Boolean(Reg.FLAGS and word(f));
end;

//============================================================
// PUBLIC

function TCPU.ReadRegister(index : Byte) : Word;
begin
    EnterCriticalSection(cs);
  try
    result:=RR(index);
  finally
      LeaveCriticalSection(cs);
  end;
end;

procedure TCPU.WriteRegister(index : Byte; w : Word);
begin
    EnterCriticalSection(cs);
  try
    WR(true,index, w);
  finally
    LeaveCriticalSection(cs);
  end;
end;


function TCPU.Step() : Boolean;
begin
    EnterCriticalSection(cs);
  try
    case OPCode(Ram.ReadByte(Reg.IP)) of
      _END: result:=True;
      MOV_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2));
        Reg.IP += 4;
      end; // MOV R,x
      MOV_R_ADDR_R: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))));
        Reg.IP += 3;
      end; // MOV R,[R]
      MOV_R_ADDR_X: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)));
        Reg.IP += 4;
      end; // MOV R,[x]
      MOV_ADDR_R_R: begin
        Ram.WriteWord(RR(Ram.ReadByte(Reg.IP+1)),RR(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end; // MOV [R],R
      MOV_ADDR_X_R: begin
        Ram.WriteWord(Ram.ReadWord(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+3)));
        Reg.IP += 4;
      end; // mov [x],R
      MOV_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+2)));
        Reg.IP += 3;
      end;//mov R,R
      MOV_R_ADDR_RX: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))+Ram.ReadWord(Reg.IP+3)));
        Reg.IP += 5;
      end; //mov R,[R+x]	()
      MOV_ADDR_RX_R: begin
        Ram.WriteWord(RR(Ram.ReadByte(Reg.IP+1))+Ram.ReadWord(Reg.IP+2),RR(Ram.ReadByte(Reg.IP+4)));
        Reg.IP += 5;
      end; //mov [R+x],R


      ADD_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //add R,x
      ADD_R_ADDR_R: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //add R,[R]
      ADD_R_ADDR_X: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //add R,[x]
      ADD_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+2)) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //add R,R
      SUB_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Reg.IP+2) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //sub R,x
      SUB_R_ADDR_X: begin
        WR(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //sub R,[x]
      SUB_R_ADDR_R: begin
        WR(Ram.ReadByte(Reg.IP+1),-Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //sub R,[R]
      SUB_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),-RR(Ram.ReadByte(Reg.IP+2)) + RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //sub R,R
      MUL_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Reg.IP+2) * RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //mul R,x
      MUL_R_ADDR_X: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) * RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 4;
      end; //mul R,[x]
      MUL_R_ADDR_R: begin
        WR(Ram.ReadByte(Reg.IP+1),Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))) * RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //mul R,[R]
      MUL_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+2)) * RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //mul R,R
      DIV_R_X: begin
        if (Ram.ReadWord(Reg.IP+2) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Reg.IP+2),true);
          Reg.IP += 4;
        end else
           Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //div R,x
      DIV_R_ADDR_X: begin
        if (Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(Ram.ReadWord(Reg.IP+2)),true);
          Reg.IP += 4;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //div R,[x]
      DIV_R_ADDR_R: begin
        if (Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) div Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))),true);
          Reg.IP += 3;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //div R,[R]
      DIV_R_R: begin
        if (RR(Ram.ReadByte(Reg.IP+2))<>0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) div RR(Ram.ReadByte(Reg.IP+2)),true);
          Reg.IP += 3;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //div R,R
      MOD_R_X: begin
        if (Ram.ReadWord(Reg.IP+2) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Reg.IP+2),true);
          Reg.IP += 4;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //mod R,x
      MOD_R_ADDR_X: begin
        if (Ram.ReadWord(Ram.ReadWord(Reg.IP+2)) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(Ram.ReadWord(Reg.IP+2)),true);
          Reg.IP += 4;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //mod R,[x]
      MOD_R_ADDR_R: begin
        if (Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) mod Ram.ReadWord(RR(Ram.ReadByte(Reg.IP+2))),true);
          Reg.IP += 3;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //mod R,[R]
      MOD_R_R: begin
        if (RR(Ram.ReadByte(Reg.IP+2)) <> 0) then begin
          WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) mod RR(Ram.ReadByte(Reg.IP+2)),true);
          Reg.IP += 3;
        end else
          Raise Exception.CreateFmt('Division by zero is not allowed.',[]);
      end; //mod R,R
      CMP_R_X: begin
        setFlag(TFlags.O, false);
        setFlag(TFlags.S, RR(Ram.ReadByte(Reg.IP+1))<Ram.ReadWord(Reg.IP+2));
        setFlag(TFlags.Z, RR(Ram.ReadByte(Reg.IP+1))=Ram.ReadWord(Reg.IP+2));
        Reg.IP+=4;
      end; //cmp R,x
      CMP_R_R: begin
        setFlag(TFlags.O, false);
        setFlag(TFlags.S, RR(Ram.ReadByte(Reg.IP+1))<RR(Ram.ReadByte(Reg.IP+2)));
        setFlag(TFlags.Z, RR(Ram.ReadByte(Reg.IP+1))=RR(Ram.ReadByte(Reg.IP+2)));
        Reg.IP+=3;
      end; //cmp R, R
      JMP_R: begin
        Reg.IP:=RR(Ram.ReadByte(Reg.IP+1));
      end; //jmp R
      JMP_ADDR: begin
        Reg.IP:=Ram.ReadWord(Reg.IP+1);
      end; //jmp X


      JS_R: begin
        if (getFlag(S)) then
          Reg.IP:=RR(Ram.ReadByte(Reg.IP+1))
        else
          Reg.IP+=2;
      end; //js R
      JS_X: begin
        if (getFlag(S)) then
          Reg.IP:=Ram.ReadWord(Reg.IP+1)
        else
          Reg.IP+=3;
      end; // js X
      JZ_R: begin
        if (getFlag(Z)) then
          Reg.IP:=RR(Ram.ReadByte(Reg.IP+1))
        else
          Reg.IP+=2;
      end; //jz R
      JZ_X: begin
        if (getFlag(Z)) then
          Reg.IP:=Ram.ReadWord(Reg.IP+1)
        else
          Reg.IP+=3;
      end; // jz X
      JO_R: begin
        if (getFlag(O)) then
          Reg.IP:=RR(Ram.ReadByte(Reg.IP+1))
        else
          Reg.IP+=2;
      end; //jo R
      JO_X: begin
        if (getFlag(O)) then
          Reg.IP:=Ram.ReadWord(Reg.IP+1)
        else
          Reg.IP+=3;
      end; // jo X


      JNS_R: begin
        if (not getFlag(S)) then
          Reg.IP:=RR(Ram.ReadByte(Reg.IP+1))
        else
          Reg.IP+=2;
      end; //jns R
      JNS_X: begin
        if (not getFlag(S)) then
          Reg.IP:=Ram.ReadWord(Reg.IP+1)
        else
          Reg.IP+=3;
      end; // jns X
      JNZ_R: begin
        if (not getFlag(Z)) then
          Reg.IP:=RR(Ram.ReadByte(Reg.IP+1))
        else
          Reg.IP+=2;
      end; //jnz R
      JNZ_X: begin
        if (not getFlag(Z)) then
          Reg.IP:=Ram.ReadWord(Reg.IP+1)
        else
          Reg.IP+=3;
      end; // jnz X
      JNO_R: begin
        if (not getFlag(O)) then
          Reg.IP:=RR(Ram.ReadByte(Reg.IP+1))
        else
          Reg.IP+=2;
      end; //jno R
      JNO_X: begin
        if (not getFlag(O)) then
          Reg.IP:=Ram.ReadWord(Reg.IP+1)
        else
          Reg.IP+=3;
      end; // jno X



      CALL_X: begin
        push(Reg.IP+3);
        Reg.IP:=Ram.ReadWord(Reg.IP+1);
      end; //call [X]
      CALL_R: begin
        push(Reg.IP+2);
        Reg.IP:=RR(Ram.ReadByte(Reg.IP+1));
      end; //call [R]
      RET: begin
        Reg.IP:=pop();
      end; //ret


      PUSH_R: begin
        push(RR(Ram.ReadByte(Reg.IP+1)));
        Reg.IP+=1;
      end;// push R
      PUSH_X: begin
        push(Ram.ReadWord(Reg.IP+1));
        Reg.IP+=2;
      end;// push x
      OPCode.POP: begin
        pop();
        Reg.IP+=1;
      end; //pop			(in kein Register)
      POP_R: begin
        WR(Ram.ReadByte(Reg.IP+1),pop());
        Reg.IP+=2;
      end; //pop R


      NOT_R: begin
        WR(Ram.ReadByte(Reg.IP+1),not RR(Ram.ReadByte(Reg.IP+1)));
        Reg.IP += 2;
      end; //not R		(binär)
      AND_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) and Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //and R,x
      AND_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+2)) and RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //and R,R
      OR_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) or Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //or R,x
      OR_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+2)) or RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //or R,R
      XOR_R_X: begin
        WR(Ram.ReadByte(Reg.IP+1), RR(Ram.ReadByte(Reg.IP+1)) xor Ram.ReadWord(Reg.IP+2),true);
        Reg.IP += 4;
      end; //xor R,x
      XOR_R_R: begin
        WR(Ram.ReadByte(Reg.IP+1),RR(Ram.ReadByte(Reg.IP+2)) xor RR(Ram.ReadByte(Reg.IP+1)),true);
        Reg.IP += 3;
      end; //xor R,R

     end;
  finally
    LeaveCriticalSection(cs);
  end;
end;

end.

