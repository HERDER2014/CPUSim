unit uCPU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM, uTypen, uOPCodes;

type

  { TCPU }

  TCPU = class

    type TProc =
    procedure of object;


  private

    Reg: TRegRecord;
    cs: TRTLCriticalSection;
    Ram: TRAM;
    KeyInputs: TStringList;

    OPCodeProcedures: array[0..integer(OPCode.Count) - 1] of TProc;
    Terminated: boolean;
    wMessage: string;

    procedure push(w: word); overload;
    function pop(): word;
    procedure setFlag(f: TFlags; b: boolean);
    function getFlag(f: TFlags): boolean;

    procedure WR(index: byte; w: longint; flags: boolean); overload;
    procedure WR(index: byte; w: smallint); overload;
    procedure WR(force: boolean; index: byte; w: longint; flags: boolean); overload;
    procedure WR(force: boolean; index: byte; w: smallint); overload;
    function RR(index: byte): smallint;

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

   {
   Vor.: -
   Eff.: i wird an Input queue angefuegt
   Erg.: -
   }
  public
    procedure SendKeyInput(i: char);

   {
   Vor.: -
   Eff.: -
   Erg.: gibt aktuelle Waiting Message aus
   }
  public
    function waitingMessage(): string;

   {
   Vor.: -
   Eff.: Keyboard Buffer wird geleert
   Erg.: -
   }
  public
    procedure clearKeyboardBuffer();

   {
   Vor.: -
   Eff.: moegliche Wartevorgaenge werden abgebrochen
   Erg.: -
   }
  public
    procedure Terminate();

  public
    function getRam():TRAM;

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
    procedure Run_MOV_ADDR_X_X();
    procedure Run_MOV_ADDR_R_X();
    procedure Run_MOV_R_R();
    procedure Run_MOV_R_ADDR_RX();
    procedure Run_MOV_ADDR_RX_R();
    procedure Run_MOV_ADDR_RX_X();
    procedure Run_MOVB_R_X();
    procedure Run_MOVB_R_ADDR_R();
    procedure Run_MOVB_R_ADDR_X();
    procedure Run_MOVB_ADDR_R_R();
    procedure Run_MOVB_ADDR_X_R();
    procedure Run_MOVB_ADDR_X_X();
    procedure Run_MOVB_ADDR_R_X();
    procedure Run_MOVB_R_R();
    procedure Run_MOVB_R_ADDR_RX();
    procedure Run_MOVB_ADDR_RX_R();
    procedure Run_MOVB_ADDR_RX_X();
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
    procedure Run_JK_R();
    procedure Run_JK_X();
    procedure Run_JNS_R();
    procedure Run_JNS_X();
    procedure Run_JNZ_R();
    procedure Run_JNZ_X();
    procedure Run_JNO_R();
    procedure Run_JNO_X();
    procedure Run_JNK_R();
    procedure Run_JNK_X();
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
    procedure Run_AND_R_ADDR_X();
    procedure Run_AND_R_ADDR_R();
    procedure Run_OR_R_X();
    procedure Run_OR_R_R();
    procedure Run_OR_R_ADDR_X();
    procedure Run_OR_R_ADDR_R();
    procedure Run_XOR_R_X();
    procedure Run_XOR_R_R();
    procedure Run_XOR_R_ADDR_X();
    procedure Run_XOR_R_ADDR_R();
    procedure Run_OUT_R();
    procedure Run_OUT_X();
    procedure Run_IN_R();
    procedure Run_CKB();

  end;

implementation


constructor TCPU.Create(var r: TRam);
begin
  Ram := r;
  InitCriticalSection(cs);
  Reg.IP := 0;
  Reg.SP := r.GetVRAMStart - 1;
  Reg.BP := r.GetVRAMStart - 1;
  Reg.VP := r.GetVRAMStart;
  Reg.FLAGS := 0;
  Reg.AX := 0;
  Reg.BX := 0;
  Reg.CX := 0;
  Reg.DX := 0;
  Terminated := False;

  KeyInputs := TStringList.Create;
  //   Reg := TRegRecord.Create();

  // initialize OPCodeProcedures
  OPCodeProcedures[integer(_END)] := @Run_END;
  OPCodeProcedures[integer(MOV_R_X)] := @Run_MOV_R_X;
  OPCodeProcedures[integer(MOV_R_ADDR_X)] := @Run_MOV_R_ADDR_X;
  OPCodeProcedures[integer(MOV_R_ADDR_R)] := @Run_MOV_R_ADDR_R;
  OPCodeProcedures[integer(MOV_ADDR_R_R)] := @Run_MOV_ADDR_R_R;
  OPCodeProcedures[integer(MOV_ADDR_X_R)] := @Run_MOV_ADDR_X_R;
  OPCodeProcedures[integer(MOV_ADDR_R_X)] := @Run_MOV_ADDR_R_X;
  OPCodeProcedures[integer(MOV_ADDR_X_X)] := @Run_MOV_ADDR_X_X;
  OPCodeProcedures[integer(MOV_R_R)] := @Run_MOV_R_R;
  OPCodeProcedures[integer(MOV_R_ADDR_RX)] := @Run_MOV_R_ADDR_RX;
  OPCodeProcedures[integer(MOV_ADDR_RX_R)] := @Run_MOV_ADDR_RX_R;
  OPCodeProcedures[integer(MOV_ADDR_RX_X)] := @Run_MOV_ADDR_RX_X;
  OPCodeProcedures[integer(MOVB_R_X)] := @Run_MOVB_R_X;
  OPCodeProcedures[integer(MOVB_R_ADDR_X)] := @Run_MOVB_R_ADDR_X;
  OPCodeProcedures[integer(MOVB_R_ADDR_R)] := @Run_MOVB_R_ADDR_R;
  OPCodeProcedures[integer(MOVB_ADDR_R_R)] := @Run_MOVB_ADDR_R_R;
  OPCodeProcedures[integer(MOVB_ADDR_X_R)] := @Run_MOVB_ADDR_X_R;
  OPCodeProcedures[integer(MOVB_ADDR_R_X)] := @Run_MOVB_ADDR_R_X;
  OPCodeProcedures[integer(MOVB_ADDR_X_X)] := @Run_MOVB_ADDR_X_X;
  OPCodeProcedures[integer(MOVB_R_R)] := @Run_MOVB_R_R;
  OPCodeProcedures[integer(MOVB_R_ADDR_RX)] := @Run_MOVB_R_ADDR_RX;
  OPCodeProcedures[integer(MOVB_ADDR_RX_R)] := @Run_MOVB_ADDR_RX_R;
  OPCodeProcedures[integer(MOVB_ADDR_RX_X)] := @Run_MOVB_ADDR_RX_X;
  OPCodeProcedures[integer(ADD_R_X)] := @Run_ADD_R_X;
  OPCodeProcedures[integer(ADD_R_ADDR_R)] := @Run_ADD_R_ADDR_R;
  OPCodeProcedures[integer(ADd_R_ADDR_X)] := @Run_ADD_R_ADDR_X;
  OPCodeProcedures[integer(ADD_R_R)] := @Run_ADD_R_R;
  OPCodeProcedures[integer(SUB_R_X)] := @Run_SUB_R_X;
  OPCodeProcedures[integer(SUB_R_ADDR_X)] := @Run_SUB_R_ADDR_X;
  OPCodeProcedures[integer(SUB_R_ADDR_R)] := @Run_SUB_R_ADDR_R;
  OPCodeProcedures[integer(SUB_R_R)] := @Run_SUB_R_R;
  OPCodeProcedures[integer(MUL_R_X)] := @Run_MUL_R_X;
  OPCodeProcedures[integer(MUL_R_ADDR_X)] := @Run_MUL_R_ADDR_X;
  OPCodeProcedures[integer(MUL_R_ADDR_R)] := @Run_MUL_R_ADDR_R;
  OPCodeProcedures[integer(MUL_R_R)] := @Run_MUL_R_R;
  OPCodeProcedures[integer(DIV_R_X)] := @Run_DIV_R_X;
  OPCodeProcedures[integer(DIV_R_ADDR_X)] := @Run_DIV_R_ADDR_X;
  OPCodeProcedures[integer(DIV_R_ADDR_R)] := @Run_DIV_R_ADDR_R;
  OPCodeProcedures[integer(DIV_R_R)] := @Run_DIV_R_R;
  OPCodeProcedures[integer(MOD_R_X)] := @Run_MOD_R_X;
  OPCodeProcedures[integer(MOD_R_ADDR_X)] := @Run_MOD_R_ADDR_X;
  OPCodeProcedures[integer(MOD_R_ADDR_R)] := @Run_MOD_R_ADDR_R;
  OPCodeProcedures[integer(MOD_R_R)] := @Run_MOD_R_R;
  OPCodeProcedures[integer(CMP_R_X)] := @Run_CMP_R_X;
  OPCodeProcedures[integer(JMP_R)] := @Run_JMP_R;
  OPCodeProcedures[integer(JMP_ADDR)] := @Run_JMP_ADDR;
  OPCodeProcedures[integer(JS_R)] := @Run_JS_R;
  OPCodeProcedures[integer(JS_X)] := @Run_JS_X;
  OPCodeProcedures[integer(JZ_R)] := @Run_JZ_R;
  OPCodeProcedures[integer(JZ_X)] := @Run_JZ_X;
  OPCodeProcedures[integer(JO_R)] := @Run_JO_R;
  OPCodeProcedures[integer(JO_X)] := @Run_JO_X;
  OPCodeProcedures[integer(JK_R)] := @Run_JK_R;
  OPCodeProcedures[integer(JK_X)] := @Run_JK_X;
  OPCodeProcedures[integer(JNS_R)] := @Run_JNS_R;
  OPCodeProcedures[integer(JNS_X)] := @Run_JNS_X;
  OPCodeProcedures[integer(JNZ_R)] := @Run_JNZ_R;
  OPCodeProcedures[integer(JNZ_X)] := @Run_JNZ_X;
  OPCodeProcedures[integer(JNK_R)] := @Run_JNK_R;
  OPCodeProcedures[integer(JNK_X)] := @Run_JNK_X;
  OPCodeProcedures[integer(CALL_X)] := @Run_CALL_X;
  OPCodeProcedures[integer(CALL_R)] := @Run_CALL_R;
  OPCodeProcedures[integer(CMP_R_R)] := @Run_CMP_R_R;
  OPCodeProcedures[integer(RET)] := @Run_RET;
  OPCodeProcedures[integer(PUSH_R)] := @Run_PUSH_R;
  OPCodeProcedures[integer(PUSH_X)] := @Run_PUSH_X;
  OPCodeProcedures[integer(OPCode.POP)] := @Run_POP;
  OPCodeProcedures[integer(POP_R)] := @Run_POP_R;
  OPCodeProcedures[integer(NOT_R)] := @Run_NOT_R;
  OPCodeProcedures[integer(AND_R_X)] := @Run_AND_R_X;
  OPCodeProcedures[integer(AND_R_R)] := @Run_And_R_R;
  OPCodeProcedures[integer(OR_R_X)] := @Run_OR_R_X;
  OPCodeProcedures[integer(OR_R_R)] := @Run_OR_R_R;
  OPCodeProcedures[integer(XOR_R_X)] := @Run_XOR_R_X;
  OPCodeProcedures[integer(XOR_R_R)] := @Run_XOR_R_R;
  OPCodeProcedures[integer(JNO_R)] := @Run_JNO_R;
  OPCodeProcedures[integer(JNO_X)] := @Run_JNO_X;
  OPCodeProcedures[integer(AND_R_ADDR_X)] := @Run_AND_R_ADDR_X;
  OPCodeProcedures[integer(AND_R_ADDR_R)] := @Run_AND_R_ADDR_R;
  OPCodeProcedures[integer(OR_R_ADDR_X)] := @Run_OR_R_ADDR_X;
  OPCodeProcedures[integer(OR_R_ADDR_R)] := @Run_OR_R_ADDR_R;
  OPCodeProcedures[integer(XOR_R_ADDR_X)] := @Run_XOR_R_ADDR_X;
  OPCodeProcedures[integer(XOR_R_ADDR_R)] := @Run_XOR_R_ADDR_R;
  OPCodeProcedures[integer(IN_R)] := @Run_IN_R;
  OPCodeProcedures[integer(CKB)] := @Run_CKB;
  OPCodeProcedures[integer(INC_R)] := @Run_INC_R;
  OPCodeProcedures[integer(DEC_R)] := @Run_DEC_R;
  OPCodeProcedures[integer(OUT_R)] := @Run_OUT_R;
  OPCodeProcedures[integer(OUT_X)] := @Run_OUT_X;

end;

function TCPU.RR(index: byte): smallint;
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
    integer(VP): Result := Reg.VP;

    integer(FLAGS): Result := Reg.FLAGS;
    else
      raise Exception.CreateFmt('Register with index %x is invalid.', [index]);
  end;
end;


procedure TCPU.WR(index: byte; w: smallint);
begin
  WR(False, index, w);
end;

procedure TCPU.WR(index: byte; w: longint; flags: boolean);
begin
  WR(False, index, w, flags);
end;

procedure TCPU.WR(force: boolean; index: byte; w: longint; flags: boolean);
begin
  WR(force, index, smallint(w));
  if flags then
  begin
    setFlag(TFlags.O, ((((index = byte(AL)) or (index = byte(BL)) or
      (index = byte(CL)) or (index = byte(DL)) or (index = byte(AH)) or
      (index = byte(BH)) or (index = byte(CH)) or (index = byte(DH))) and (w > 255)) or
      (w > 65535)));
    setFlag(TFlags.S, w < 0);
    setFlag(TFlags.Z, smallint(w) = 0);
  end;
end;

procedure TCPU.WR(force: boolean; index: byte; w: smallint);
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
    integer(VP): Reg.VP := w;
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

procedure TCPU.Run_MOV_ADDR_X_R();
begin
  Ram.WriteWord(Ram.ReadWord(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 3)));
  Reg.IP += 4;
end; // mov [x],R

procedure TCPU.Run_MOV_ADDR_X_X;
begin
  Ram.WriteWord(Ram.ReadWord(Reg.IP + 1), Ram.ReadWord(Reg.IP + 3));
  Reg.IP += 5;
end;

procedure TCPU.Run_MOV_ADDR_R_X;
begin
  Ram.WriteWord(RR(Ram.ReadByte(Reg.IP + 1)), Ram.ReadWord(Reg.IP + 2));
  Reg.IP += 4;
end;

procedure TCPU.Run_MOV_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 2)));
  Reg.IP += 3;
end;//mov R,R

procedure TCPU.Run_MOV_R_ADDR_RX();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2)) +
    smallint(Ram.ReadWord(Reg.IP + 3))));
  Reg.IP += 5;
end; //mov R,[R+x]

procedure TCPU.Run_MOV_ADDR_RX_R();
begin
  Ram.WriteWord(RR(Ram.ReadByte(Reg.IP + 1)) + smallint(Ram.ReadWord(Reg.IP + 2)),
    RR(Ram.ReadByte(Reg.IP + 4)));
  Reg.IP += 5;
end; //mov [R+x],R

procedure TCPU.Run_MOV_ADDR_RX_X;
begin
  Ram.WriteWord(RR(Ram.ReadByte(Reg.IP + 1)) + smallint(Ram.ReadWord(Reg.IP + 2)),
    Ram.ReadWord(Reg.IP + 4));
  Reg.IP += 6;
end;

procedure TCPU.Run_MOVB_R_X();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadByte(Reg.IP + 2));
  Reg.IP += 3;
end; // MOVB R,X

procedure TCPU.Run_MOVB_R_ADDR_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadByte(RR(Ram.ReadByte(Reg.IP + 2))));
  Reg.IP += 3;
end; // MOVB R,[R]

procedure TCPU.Run_MOVB_R_ADDR_X();
begin
  WR(
    Ram.ReadByte(Reg.IP + 1), Ram.ReadByte(Ram.ReadWord(Reg.IP + 2)));
  Reg.IP += 4;
end; // MOVB R,[x]

procedure TCPU.Run_MOVB_ADDR_R_R();
begin
  Ram.WriteByte(RR(Ram.ReadByte(Reg.IP + 1)), RR(Ram.ReadByte(Reg.IP + 2)));
  Reg.IP += 3;
end; // MOVB [R],R

procedure TCPU.Run_MOVB_ADDR_X_R();
begin
  Ram.WriteByte(Ram.ReadWord(Reg.IP + 1), RR(Ram.ReadByte(Reg.IP + 3)));
  Reg.IP += 4;
end; // movb [x],R

procedure TCPU.Run_MOVB_ADDR_X_X;
begin
  Ram.WriteByte(Ram.ReadWord(Reg.IP + 1), Ram.ReadByte(Reg.IP + 3));
  Reg.IP += 4;
end; // movb [x],x

procedure TCPU.Run_MOVB_ADDR_R_X;
begin
  Ram.WriteByte(RR(Ram.ReadByte(Reg.IP + 1)), Ram.ReadByte(Reg.IP + 2));
  Reg.IP += 3;
end; //movb [R],x

procedure TCPU.Run_MOVB_R_R();
begin
  WR(Ram.ReadByte(Reg.IP + 1), byte(RR(Ram.ReadByte(Reg.IP + 2))));
  Reg.IP += 3;
end;//movb R,R

procedure TCPU.Run_MOVB_R_ADDR_RX();
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadByte(RR(Ram.ReadByte(Reg.IP + 2)) +
    smallint(Ram.ReadWord(Reg.IP + 3))));
  Reg.IP += 5;
end; //movb R,[R+x]

procedure TCPU.Run_MOVB_ADDR_RX_R();
begin
  Ram.WriteByte(RR(Ram.ReadByte(Reg.IP + 1)) + smallint(Ram.ReadWord(Reg.IP + 2)),
    RR(Ram.ReadByte(Reg.IP + 4)));
  Reg.IP += 5;
end; //movb [R+x],R

procedure TCPU.Run_MOVB_ADDR_RX_X;
begin
  Ram.WriteByte(RR(Ram.ReadByte(Reg.IP + 1)) + smallint(Ram.ReadWord(Reg.IP + 2)),
    Ram.ReadByte(Reg.IP + 4));
  Reg.IP += 5;
end;

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

procedure TCPU.Run_JK_R;
begin
  if (getFlag(K)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end;

procedure TCPU.Run_JK_X;
begin
  if (getFlag(K)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end;


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

procedure TCPU.Run_JNK_R;
begin
  if (not getFlag(K)) then
    Reg.IP := RR(Ram.ReadByte(Reg.IP + 1))
  else
    Reg.IP += 2;
end;

procedure TCPU.Run_JNK_X;
begin
  if (not getFlag(K)) then
    Reg.IP := Ram.ReadWord(Reg.IP + 1)
  else
    Reg.IP += 3;
end;



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

procedure TCPU.Run_AND_R_ADDR_X;
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) and
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end;

procedure TCPU.Run_AND_R_ADDR_R;
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) and
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end;

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

procedure TCPU.Run_OR_R_ADDR_X;
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) or
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end;

procedure TCPU.Run_OR_R_ADDR_R;
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) or
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end;

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

procedure TCPU.Run_XOR_R_ADDR_X;
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(Ram.ReadWord(Reg.IP + 2)) xor
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 4;
end;

procedure TCPU.Run_XOR_R_ADDR_R;
begin
  WR(Ram.ReadByte(Reg.IP + 1), Ram.ReadWord(RR(Ram.ReadByte(Reg.IP + 2))) xor
    RR(Ram.ReadByte(Reg.IP + 1)), True);
  Reg.IP += 3;
end;

procedure TCPU.Run_OUT_R;
begin
  Ram.WriteByte(Reg.VP, RR(Ram.ReadByte(Reg.IP + 1)));
  Reg.VP += 1;
  Reg.IP += 2;
end;

procedure TCPU.Run_OUT_X;
begin
  Ram.WriteByte(Reg.VP, Ram.ReadByte(Reg.IP + 1));
  Reg.VP += 1;
  Reg.IP += 2;
end;

procedure TCPU.Run_IN_R;
var
  b: boolean;
begin
  b := (KeyInputs.Count = 0);
  LeaveCriticalSection(cs);
  while (b) do
  begin
    if (Terminated) then
    begin
      EnterCriticalSection(cs);
      exit;
    end;
    EnterCriticalSection(cs);

    wMessage := 'Waiting for Keyboard Input';
    try
      b := (KeyInputs.Count = 0);
    finally
      LeaveCriticalSection(cs);
    end;
  end;
  EnterCriticalSection(cs);

  wMessage := '';
  WR(Ram.ReadByte(Reg.IP + 1), byte(KeyInputs[0][1]));
  Reg.IP += 2;
  KeyInputs.Delete(0);
  setFlag(K,KeyInputs.Count > 0);
end;

procedure TCPU.Run_CKB;
begin
  KeyInputs.Clear;
  Reg.IP += 1;
end;

function TCPU.Step(): OPCode;
var
  OPCodeNum: byte;
begin
  OPCodeNum := Ram.ReadByte(Reg.IP);
  EnterCriticalSection(cs);
  try
    if OPCodeNum < integer(OPCode.Count) then
    begin
      Result := OPCode(OPCodeNum);
      OPCodeProcedures[OPCodeNum]();
    end
    else
    begin
      raise Exception.CreateFmt('OP-Code with Index %x is invalid', [OPCodeNum]);
    end;
  finally
    LeaveCriticalSection(cs);
  end;

end;

procedure TCPU.SendKeyInput(i: char);
begin
  EnterCriticalSection(cs);
  try
    KeyInputs.Append(i);
    setFlag(K,true);
  finally
    LeaveCriticalSection(cs);
  end;
end;

procedure TCPU.Terminate;
begin
  Terminated := True;
end;

function TCPU.getRam: TRAM;
begin
  result:=Ram;
end;

function TCPU.waitingMessage: string;
begin
  Result := wMessage;
end;

procedure TCPU.clearKeyboardBuffer;
begin
  Run_CKB;
  setFlag(K, false);
end;

end.
