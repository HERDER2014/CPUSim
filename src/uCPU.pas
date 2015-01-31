unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, uTypen, uOPCodes;



type
  TCPU = class

  type TProc = procedure of object;


  private

    Reg: TRegRecord;
    cs: TRTLCriticalSection;
    Ram: TRAM;

    OPCodeProcedures: Array[0..Integer(OPCode.COUNT)-1] of TProc;


    procedure push(w: word); overload;
    function pop(): word;
    procedure setFlag(f: TFlags; b: boolean);
    function getFlag(f: TFlags): boolean;

    procedure WR(index: byte; w: word; flags: boolean); overload;
    procedure WR(index: byte; w: word); overload;
    procedure WR(force: boolean; index: byte; w: integer; flags: boolean); overload;
    procedure WR(force: boolean; index: byte; w: word); overload;
    function RR(index: byte): word;

  public
    constructor Create(var r: TRam);

   {
   Vor.: index ist Registerindex
   Eff.: -
   Erg.: Liefert den Wert von Register 'index'.
   }
  public
    function ReadRegister(index: RegisterIndex): word;

   {
     DEBUG ONLY

   Vor.: index ist Registerindex
   Eff.: w steht im Register 'index' sofern erlaubt. Ist force, so steht w immer in Register 'index'
   Erg.: -
   Exceptions: Invalid Register / Not Allowed
   }
  public
    procedure WriteRegister(index: RegisterIndex; w: word);

   {
   Vor.: Simulation nicht am Ende.
   Eff.: Befehl im RAM an Stelle IP wurde ausgeführt.
   Erg.: Lifert den OPCode des zuletzt aufgerufenen Befehlt.
   Exeptions.: Runtimeerrors
   }
  public
    function Step(): OPCode;

  private
   {
   OP-Code befehle
   }
    procedure Run_END();
    procedure Run_MOV_R_X();
    procedure Run_MOV_R_ADDR_R();
    procedure Run_MOV_R_ADDR_X();
    procedure Run_MOV_ADDR_R_R();
    procedure Run_MOV_ADDR_X_R();
    procedure Run_MOV_R_R();
    procedure Run_MOV_R_ADDR_RX();
    procedure Run_MOV_ADDR_RX_R();
    procedure Run_INC_R();
    procedure Run_DEC_R();
    procedure Run_ADD_R_X();
    procedure Run_ADD_R_ADDR_R();
    procedure Run_ADD_R_ADDR_X();
    procedure Run_ADD_R_R();
    procedure Run_SUB_R_X();
    procedure Run_SUB_R_ADDR_X();
    procedure Run_SUB_R_ADDR_R();
    procedure Run_SUB_R_R();
    procedure Run_MUL_R_X();
    procedure Run_MUL_R_ADDR_X();
    procedure Run_MUL_R_ADDR_R();
    procedure Run_MUL_R_R();
    procedure Run_DIV_R_X();
    procedure Run_DIV_R_ADDR_X();
    procedure Run_DIV_R_ADDR_R();
    procedure Run_DIV_R_R();
    procedure Run_MOD_R_X();
    procedure Run_MOD_R_ADDR_X();
    procedure Run_MOD_R_ADDR_R();
    procedure Run_MOD_R_R();
    procedure Run_CMP_R_X();
    procedure Run_CMP_R_R();
    procedure Run_JMP_R();
    procedure Run_JMP_ADDR();
    procedure Run_JS_R();
    procedure Run_JS_X();
    procedure Run_JZ_R();
    procedure Run_JZ_X();
    procedure Run_JO_R();
    procedure Run_JO_X();
    procedure Run_JNS_R();
    procedure Run_JNS_X();
    procedure Run_JNZ_R();
    procedure Run_JNZ_X();
    procedure Run_JNO_R();
    procedure Run_JNO_X();
    procedure Run_CALL_X();
    procedure Run_CALL_R();
    procedure Run_RET();
    procedure Run_PUSH_R();
    procedure Run_PUSH_X();
    procedure Run_POP();
    procedure Run_POP_R();
    procedure Run_NOT_R();
    procedure Run_AND_R_X();
    procedure Run_AND_R_R();
    procedure Run_OR_R_X();
    procedure Run_OR_R_R();
    procedure Run_XOR_R_X();
    procedure Run_XOR_R_R();
  end;

implementation

constructor TCPU.Create(var r: TRam);
begin
  Ram := r;
  InitCriticalSection(cs);
  Reg.IP := 0;
  Reg.SP := r.GetSize - 1;
  Reg.BP := r.GetSize - 1;
  Reg.FLAGS := 0;
  Reg.AX := 0;
  Reg.BX := 0;
  Reg.CX := 0;
  Reg.DX := 0;
  //   Reg := TRegRecord.Create();

  // initialize OPCodeProcedures
  OPCodeProcedures[Integer(_END)] := @Run_END;
  OPCodeProcedures[Integer(MOV_R_X)] := @Run_MOV_R_X;
  OPCodeProcedures[Integer(MOV_R_ADDR_X)] := @Run_MOV_R_ADDR_X;
  OPCodeProcedures[Integer(MOV_R_ADDR_R)] := @Run_MOV_R_ADDR_R;
  OPCodeProcedures[Integer(MOV_ADDR_R_R)] := @Run_MOV_ADDR_R_R;
  OPCodeProcedures[Integer(MOV_ADDR_X_R)] := @Run_MOV_ADDR_X_R;
  OPCodeProcedures[Integer(MOV_R_R)] := @Run_MOV_R_R;
  OPCodeProcedures[Integer(MOV_R_ADDR_RX)] := @Run_MOV_R_ADDR_RX;
  OPCodeProcedures[Integer(MOV_ADDR_RX_R)] := @Run_MOV_ADDR_RX_R;
  OPCodeProcedures[Integer(ADD_R_X)] := @Run_ADD_R_X;
  OPCodeProcedures[Integer(ADD_R_ADDR_R)] := @Run_ADD_R_ADDR_R;
  OPCodeProcedures[Integer(ADd_R_ADDR_X)] := @Run_ADD_R_ADDR_X;
  OPCodeProcedures[Integer(ADD_R_R)] := @Run_ADD_R_R;
  OPCodeProcedures[Integer(SUB_R_X)] := @Run_SUB_R_X;
  OPCodeProcedures[Integer(SUB_R_ADDR_X)] := @Run_SUB_R_ADDR_X;
  OPCodeProcedures[Integer(SUB_R_ADDR_R)] := @Run_SUB_R_ADDR_R;
  OPCodeProcedures[Integer(SUB_R_R)] := @Run_SUB_R_R;
  OPCodeProcedures[Integer(MUL_R_X)] := @Run_MUL_R_X;
  OPCodeProcedures[Integer(MUL_R_ADDR_X)] := @Run_MUL_R_ADDR_X;
  OPCodeProcedures[Integer(MUL_R_ADDR_R)] := @Run_MUL_R_ADDR_R;
  OPCodeProcedures[Integer(MUL_R_R)] := @Run_MUL_R_R;
  OPCodeProcedures[Integer(DIV_R_X)] := @Run_DIV_R_X;
  OPCodeProcedures[Integer(DIV_R_ADDR_X)] := @Run_DIV_R_ADDR_X;
  OPCodeProcedures[Integer(DIV_R_ADDR_R)] := @Run_DIV_R_ADDR_R;
  OPCodeProcedures[Integer(DIV_R_R)] := @Run_DIV_R_R;
  OPCodeProcedures[Integer(MOD_R_X)] := @Run_MOD_R_X;
  OPCodeProcedures[Integer(MOD_R_ADDR_X)] := @Run_MOD_R_ADDR_X;
  OPCodeProcedures[Integer(MOD_R_ADDR_R)] := @Run_MOD_R_ADDR_R;
  OPCodeProcedures[Integer(MOD_R_R)] := @Run_MOD_R_R;
  OPCodeProcedures[Integer(CMP_R_X)] := @Run_CMP_R_X;
  OPCodeProcedures[Integer(JMP_R)] := @Run_JMP_R;
  OPCodeProcedures[Integer(JMP_ADDR)] := @Run_JMP_ADDR;
  OPCodeProcedures[Integer(JS_R)] := @Run_JS_R;
  OPCodeProcedures[Integer(JS_X)] := @Run_JS_X;
  OPCodeProcedures[Integer(JZ_R)] := @Run_JZ_R;
  OPCodeProcedures[Integer(JZ_X)] := @Run_JZ_X;
  OPCodeProcedures[Integer(JO_R)] := @Run_JO_R;
  OPCodeProcedures[Integer(JO_X)] := @Run_JO_X;
  OPCodeProcedures[Integer(JNS_R)] := @Run_JNS_R;
  OPCodeProcedures[Integer(JNS_X)] := @Run_JNS_X;
  OPCodeProcedures[Integer(JNZ_R)] := @Run_JNZ_R;
  OPCodeProcedures[Integer(JNZ_X)] := @Run_JNZ_X;
  OPCodeProcedures[Integer(CALL_X)] := @Run_CALL_X;
  OPCodeProcedures[Integer(CALL_R)] := @Run_CALL_R;
  OPCodeProcedures[Integer(CMP_R_R)] := @Run_CMP_R_R;
  OPCodeProcedures[Integer(RET)] := @Run_RET;
  OPCodeProcedures[Integer(PUSH_R)] := @Run_PUSH_R;
  OPCodeProcedures[Integer(PUSH_X)] := @Run_PUSH_X;
  OPCodeProcedures[Integer(OPCode.POP)] := @Run_POP;
  OPCodeProcedures[Integer(POP_R)] := @Run_POP_R;
  OPCodeProcedures[Integer(NOT_R)] := @Run_NOT_R;
  OPCodeProcedures[Integer(AND_R_X)] := @Run_AND_R_X;
  OPCodeProcedures[Integer(AND_R_R)] := @Run_And_R_R;
  OPCodeProcedures[Integer(OR_R_X)] := @Run_OR_R_X;
  OPCodeProcedures[Integer(OR_R_R)] := @Run_OR_R_R;
  OPCodeProcedures[Integer(XOR_R_X)] := @Run_XOR_R_X;
  OPCodeProcedures[Integer(XOR_R_R)] := @Run_XOR_R_R;
  OPCodeProcedures[Integer(JNO_R)] := @Run_JNO_R;
  OPCodeProcedures[Integer(JNO_X)] := @Run_JNO_X;
 // OPCodeProcedures[Integer(AND_R_ADDR_X)] := @Run_AND_R_ADDR_X;
 // OPCodeProcedures[Integer(AND_R_ADDR_R)] := @Run_AND_R_ADDR_R;
 // OPCodeProcedures[Integer(OR_R_ADDR_X)] := @Run_OR_R_ADDR_X;
 // OPCodeProcedures[Integer(OR_R_ADDR_R)] := @Run_OR_R_ADDR_R;
 // OPCodeProcedures[Integer(XOR_R_ADDR_X)] := @Run_XOR_R_ADDR_X;
 // OPCodeProcedures[Integer(XOR_R_ADDR_R)] := @Run_XOR_R_ADDR_R;
 // OPCodeProcedures[Integer(IN_R)] := @Run_IN_R;
  OPCodeProcedures[Integer(INC_R)] := @Run_INC_R;
  OPCodeProcedures[Integer(DEC_R)] := @Run_DEC_R;
 // OPCodeProcedures[Integer(MOD_ADDR_R_X)] := @Run_MOV_ADDR_R_X;

end;

function TCPU.RR(index: byte): word;
begin
  case index of
    integer(AX): Result := Reg.AX;
    integer(AL): Result := Reg.AX and 255;
    integer(AH): Result := Reg.AX shr 8;

    integer(BX): Result := Reg.BX;
    integer(BL): Result := Reg.BX and 255;
    integer(BH): Result := Reg.BX shr 8;

    integer(CX): Result := Reg.CX;
    integer(CL): Result := Reg.CX and 255;
    integer(CH): Result := Reg.CX shr 8;

    integer(DX): Result := Reg.DX;
    integer(DL): Result := Reg.DX and 255;
    integer(DH): Result := Reg.DX shr 8;

    integer(BP): Result := Reg.BP;
    integer(IP): Result := Reg.IP;
    integer(SP): Result := Reg.SP;
    integer(FLAGS): Result := Reg.FLAGS;
    else
      raise Exception.CreateFmt('Register with index %x is invalid.', [index]);
  end;
end;


procedure TCPU.WR(index: byte; w: word);
begin
  WR(False, index, w);
end;

procedure TCPU.WR(index: byte; w: word; flags: boolean);
begin
  WR(False, index, w, flags);
end;

procedure TCPU.WR(force: boolean; index: byte; w: integer; flags: boolean);
begin
  WR(force, index, word(w));
  if flags then
  begin
    setFlag(TFlags.O, w > 65535);
    setFlag(TFlags.S, w < 0);
    setFlag(TFlags.Z, word(w) = 0);
  end;
end;

procedure TCPU.WR(force: boolean; index: byte; w: word);
begin
  case index of
    integer(AX): Reg.AX := w;
    integer(AL): Reg.AX := (w and 255) or (Reg.AX and (255 shl 8));
    integer(AH): Reg.AX := ((w and 255) shl 8) or (Reg.AX and 255);

    integer(BX): Reg.BX := w;
    integer(BL): Reg.BX := (w and 255) or (Reg.BX and (255 shl 8));
    integer(BH): Reg.BX := ((w and 255) shl 8) or (Reg.BX and 255);

    integer(CX): Reg.CX := w;
    integer(CL): Reg.CX := (w and 255) or (Reg.CX and (255 shl 8));
    integer(CH): Reg.CX := ((w and 255) shl 8) or (Reg.CX and 255);

    integer(DX): Reg.DX := w;
    integer(DL): Reg.DX := (w and 255) or (Reg.DX and (255 shl 8));
    integer(DH): Reg.DX := ((w and 255) shl 8) or (Reg.DX and 255);

    integer(BP): Reg.BP := w;
    integer(SP): Reg.SP := w;
    else
    begin
      if force then
      begin
        case index of
          integer(IP): Reg.IP := w;
          integer(FLAGS): Reg.FLAGS := w;
          else
            raise Exception.CreateFmt('Register with index %x is invalid.', [index]);
        end;
      end
      else
      if (index = integer(IP)) or (index = integer(FLAGS)) then
        raise Exception.CreateFmt(
          'Not allowed to write into register with index %x.', [index])
      else
        raise Exception.CreateFmt('Register with index %x is invalid.', [index]);
    end;
  end;
end;



procedure TCPU.push(w: word);
begin
  Ram.WriteWord(Reg.SP - 1, w);
  Reg.SP -= 2;
end;

function TCPU.pop(): word;
begin
  Result := Ram.ReadWord(Reg.SP + 1);
  Reg.SP += 2;
end;

procedure TCPU.setFlag(f: TFlags; b: boolean);
begin
  if b then
    Reg.FLAGS := Reg.FLAGS or word(f)
  else
    Reg.FLAGS := Reg.FLAGS and (not word(f));
end;

function TCPU.getFlag(f: TFlags): boolean;
begin
  Result := boolean(Reg.FLAGS and word(f));
end;

//============================================================
// PUBLIC

function TCPU.ReadRegister(index: RegisterIndex): word;
begin
  EnterCriticalSection(cs);
  try
    Result := RR(byte(index));
  finally
    LeaveCriticalSection(cs);
  end;
end;

procedure TCPU.WriteRegister(index: RegisterIndex; w: word);
begin
  EnterCriticalSection(cs);
  try
    WR(True, byte(index), w);
  finally
    LeaveCriticalSection(cs);
  end;
end;

procedure TCPU.Run_END();
begin

end;

procedure TCPU.Run_MOV_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Reg.IP + 2));
  Reg.IP += 4;
end; // MOV R,X

procedure TCPU.Run_MOV_R_ADDR_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))));
  Reg.IP += 3;
end; // MOV R,[R]

procedure TCPU.Run_MOV_R_ADDR_X();
begin
  WR(
    Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)));
  Reg.IP += 4;
end; // MOV R,[x]

procedure TCPU.Run_MOV_ADDR_R_R();
begin
  Ram.WriteWord(RR(Ram.ReadByte(Reg.IP + 1)), RR(Ram.ReadByte(Reg.IP + 2)));
  Reg.IP += 3;
end; // MOV [R],R
      {MOV_ADDR_R_X: begin
        Ram.WriteWord(RR(Ram.ReadByte(Reg.IP+1)),Ram.ReadWord(Reg.IP+2));
        Reg.IP += 3;
      end; // MOV [R],X  }
procedure TCPU.Run_MOV_ADDR_X_R();
begin
  Ram.WriteWord(Ram.ReadWord(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 3)));
  Reg.IP += 4;
end; // mov [x],R

procedure TCPU.Run_MOV_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)));
  Reg.IP += 3;
end;//mov R,R

procedure TCPU.Run_MOV_R_ADDR_RX();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(
    RR(Ram.ReadByte(Reg.IP + 2)) + Ram.ReadWord(Reg.IP + 3)));
  Reg.IP += 5;
end; //mov R,[R+x]

procedure TCPU.Run_MOV_ADDR_RX_R();
begin
  Ram.WriteWord(RR(Ram.ReadByte(Reg.IP + 1)) + Ram.ReadWord(Reg.IP + 2), RR(
    Ram.ReadByte(Reg.IP + 4)));
  Reg.IP += 5;
end; //mov [R+x],R

procedure TCPU.Run_INC_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) + 1, True);
  Reg.IP += 2;
end;//inc R

procedure TCPU.Run_DEC_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) - 1, True);
  Reg.IP += 2;
end;//dec R

procedure TCPU.Run_ADD_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Reg.IP + 2) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end; //add R,x

procedure TCPU.Run_ADD_R_ADDR_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //add R,[R]

procedure TCPU.Run_ADD_R_ADDR_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end; //add R,[x]

procedure TCPU.Run_ADD_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //add R,R


procedure TCPU.Run_SUB_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), -Ram.ReadWord(Reg.IP + 2) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end; //sub R,x

procedure TCPU.Run_SUB_R_ADDR_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), -Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end; //sub R,[x]

procedure TCPU.Run_SUB_R_ADDR_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), -Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //sub R,[R]

procedure TCPU.Run_SUB_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), -RR(Ram.ReadByte(Reg.IP + 2)) +
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //sub R,R


procedure TCPU.Run_MUL_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Reg.IP + 2) *
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end; //mul R,x

procedure TCPU.Run_MUL_R_ADDR_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) *
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end; //mul R,[x]

procedure TCPU.Run_MUL_R_ADDR_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) *
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //mul R,[R]

procedure TCPU.Run_MUL_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)) *
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //mul R,R


procedure TCPU.Run_DIV_R_X();
begin
  if (Ram.ReadWord(Reg.IP + 2) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) div
      Ram.ReadWord(Reg.IP + 2), True);
    Reg.IP += 4;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //div R,x

procedure TCPU.Run_DIV_R_ADDR_X();
begin
  if (Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) div
      Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)), True);
    Reg.IP += 4;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //div R,[x]

procedure TCPU.Run_DIV_R_ADDR_R();
begin
  if (Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) div
      Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))), True);
    Reg.IP += 3;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //div R,[R]

procedure TCPU.Run_DIV_R_R();
begin
  if (RR(Ram.ReadByte(Reg.IP + 2)) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) div
      RR(Ram.ReadByte(Reg.IP + 2)), True);
    Reg.IP += 3;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //div R,R


procedure TCPU.Run_MOD_R_X();
begin
  if (Ram.ReadWord(Reg.IP + 2) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) mod
      Ram.ReadWord(Reg.IP + 2), True);
    Reg.IP += 4;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //mod R,x

procedure TCPU.Run_MOD_R_ADDR_X();
begin
  if (Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) mod
      Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)), True);
    Reg.IP += 4;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //mod R,[x]

procedure TCPU.Run_MOD_R_ADDR_R();
begin
  if (Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) mod
      Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))), True);
    Reg.IP += 3;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //mod R,[R]

procedure TCPU.Run_MOD_R_R();
begin
  if (RR(Ram.ReadByte(Reg.IP + 2)) <> 0) then
  begin
    WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) mod
      RR(Ram.ReadByte(Reg.IP + 2)), True);
    Reg.IP += 3;
  end
  else
    raise Exception.CreateFmt('Division by zero is not allowed.', []);
end; //mod R,R


procedure TCPU.Run_CMP_R_X();
begin
  setFlag(TFlags.O, False);
  setFlag(TFlags.S, RR(Ram.ReadByte(Reg.IP + 1)) < Ram.ReadWord(Reg.IP + 2));
  setFlag(TFlags.Z, RR(Ram.ReadByte(Reg.IP + 1)) = Ram.ReadWord(Reg.IP + 2));
  Reg.IP += 4;
end; //cmp R,x

procedure TCPU.Run_CMP_R_R();
begin
  setFlag(TFlags.O, False);
  setFlag(TFlags.S, RR(Ram.ReadByte(Reg.IP + 1)) < RR(Ram.ReadByte(Reg.IP + 2)));
  setFlag(TFlags.Z, RR(Ram.ReadByte(Reg.IP + 1)) = RR(Ram.ReadByte(Reg.IP + 2)));
  Reg.IP += 3;
end; //cmp R, R

procedure TCPU.Run_JMP_R();
begin
  Reg.IP := RR(Ram.ReadByte(Reg.IP + 1));
end; //jmp R

procedure TCPU.Run_JMP_ADDR();
begin
  Reg.IP := Ram.ReadWord(Reg.IP + 1);
end; //jmp X


procedure TCPU.Run_JS_R();
begin
  if (getFlag(S)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end; //js R

procedure TCPU.Run_JS_X();
begin
  if (getFlag(S)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end; // js X

procedure TCPU.Run_JZ_R();
begin
  if (getFlag(Z)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end; //jz R

procedure TCPU.Run_JZ_X();
begin
  if (getFlag(Z)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end; // jz X

procedure TCPU.Run_JO_R();
begin
  if (getFlag(O)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end; //jo R

procedure TCPU.Run_JO_X();
begin
  if (getFlag(O)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end; // jo X


procedure TCPU.Run_JNS_R();
begin
  if (not getFlag(S)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end; //jns R

procedure TCPU.Run_JNS_X();
begin
  if (not getFlag(S)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end; // jns X

procedure TCPU.Run_JNZ_R();
begin
  if (not getFlag(Z)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end; //jnz R

procedure TCPU.Run_JNZ_X();
begin
  if (not getFlag(Z)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end; // jnz X

procedure TCPU.Run_JNO_R();
begin
  if (not getFlag(O)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end; //jno R

procedure TCPU.Run_JNO_X();
begin
  if (not getFlag(O)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end; // jno X



procedure TCPU.Run_CALL_X();
begin
  push(Reg.IP + 3);
  Reg.IP := Ram.ReadWord(Reg.IP + 1);
end; //call [X]

procedure TCPU.Run_CALL_R();
begin
  push(Reg.IP + 2);
  Reg.IP := RR(Ram.ReadByte(Reg.IP + 1));
end; //call [R]

procedure TCPU.Run_RET();
begin
  Reg.IP := pop();
end; //ret


procedure TCPU.Run_PUSH_R();
begin
  push(RR(Ram.ReadByte(Reg.IP + 1)));
  Reg.IP += 2;
end;// push R

procedure TCPU.Run_PUSH_X();
begin
  push(Ram.ReadWord(Reg.IP + 1));
  Reg.IP += 3;
end;// push x

procedure TCPU.Run_POP();
begin
  pop();
  Reg.IP += 1;
end; //pop(in kein Register)

procedure TCPU.Run_POP_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), pop());
  Reg.IP += 2;
end; //pop R


procedure TCPU.Run_NOT_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), not RR(Ram.ReadByte(Reg.IP + 1)));
  Reg.IP += 2;
end; //not R

procedure TCPU.Run_AND_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) and
    Ram.ReadWord(Reg.IP + 2), True);
  Reg.IP += 4;
end; //and R,x

procedure TCPU.Run_AND_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)) and
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //and R,R

procedure TCPU.Run_OR_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) or
    Ram.ReadWord(Reg.IP + 2), True);
  Reg.IP += 4;
end; //or R,x

procedure TCPU.Run_OR_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)) or
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //or R,R

procedure TCPU.Run_XOR_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 1)) xor
    Ram.ReadWord(Reg.IP + 2), True);
  Reg.IP += 4;
end; //xor R,x

procedure TCPU.Run_XOR_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)) xor
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end; //xor R,R

function TCPU.Step(): OPCode;
var OPCodeNum : Byte;
begin
  OPCodeNum := Ram.ReadByte(Reg.IP);
  EnterCriticalSection(cs);
  try
    if OPCodeNum<Integer(OPCode.COUNT) then begin
      result:=OPCode(OPCodeNum);
      OPCodeProcedures[OPCodeNum]();
    end else begin
      Raise Exception.CreateFmt('OP-Code with Index %x is invalid',[OPCodeNum]);
    end;
  finally
    LeaveCriticalSection(cs);
  end;

end;

end.
