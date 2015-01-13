unit uCompiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, fgl, SysUtils, strutils, Dialogs, uRAM, uAdvancedRecords,
  uTypen, uOPCodes;

{ Ist nur da, um den JEDI-Codeformatierer am Leben zu halten. Der wird alles
    zwischen "$IFNDEF JCF" und "$ENDIF" ignorieren. So die Theorie.
  Das ist notwendig, weil er keine Generics kennt und daher bei den spitzen
    Klammern ansonsten aufhört zu parsen.
  Irgendwie funktioniert das aber auch nicht richtig, weil er dann teilweise
    alles ignoriert. /ff
}
{$IFNDEF JEDI}
{$WARNING Jedi wird nicht funktionieren; bitte in den Einstellungen bei
  PreProcessor das Symbol "JEDI" eintragen. }
type
  TLabelMap = specialize TFPGMap<string, Word>;

type
  TCommandLineList = specialize TFPGList<TCodeLineNr>;

type
  TLabelResolveList = specialize TFPGList<TLabelUse>;

{$ENDIF}

type
  TCompilerException = class(Exception);

type
  {_____________________
   COMPILER-Klasse
   Nicht komplett funktionsfähig. Compile() wird u.U. Meldungen anzeigen.
  }
  TCompiler = class
  private
  var
    Ram: TRAM;

  public
    constructor Create(var r: TRAM);

   {
   Vor.: -
   Eff.: Das kompilierte Programm steht im RAM.
   Erg.: -
   Ausnahmen: Fehlermeldungen (TCompilerException).
   }
    procedure Compile(input: string);


   {
   Vor.: Compile wurde ausgeführt.
   Eff.: -
   Erg.: Liefert die Position in der Eingabe, die an Adresse addr kompiliert wurde.
   }
    function GetCodePosition(addr: cardinal): cardinal;

  {
   Schreibt die Instruktion mit ihren Operanden in den RAM.
   Gibt TRUE zurück, wenn die Eingaben in instruction und operands gültig sind.

   Beispiel: Eingabezeile          "ADD   AL, BL"

   instruction: Instruktion; bspw. "ADD"
   operands: Operanden; bspw.            "AL, BL"
   offset: gibt die Startposition zum Schreiben in den RAM an.
   var rBytesWritten: Wenn TRUE zurückgegeben wurde, enthält nach Ausführung die Anzahl an Bytes, die in den RAM geschrieben wurden.
  }
  private
    function WriteInstrucitonLineToRAM(instruction, operandsString: string;
      var offset: word; line: cardinal; var labelResolveList: TLabelResolveList;
      var rBytesWritten: word; var rErrorString: string): boolean;

    public
      // Die Größe des letzten Images.
      LastSize : Cardinal;
  end;

implementation

constructor TCompiler.Create(var r: TRAM);
begin
  Ram := r;
end;

{
 Liefert nur die Anweisung aus einer Codezeile in GROSSBUCHSTABEN.
 Eine Labelzeile wird vollständig zurückgegeben.

 Bsp.: "add al, 4" => "ADD", "pop" => "POP", "label:" => "label:"
}
function ExtractInstructionString(line: string): string;
var
  i: cardinal;
begin
  i := Pos(' ', line);
  if i = 0 then
    i := Length(line)
  else
    Dec(i); // 1-basiert
  Result := UpperCase(Copy(line, 1, i));
end;


{
 Liefert nur die Operanden aus einer Codezeile in GROSSBUCHSTABEN.

 Bsp.: "add al, 4" => "AL, 4"
}
function ExtractOperandsString(line: string): string;
var
  i: cardinal;
begin
  i := Pos(' ', line);
  if i = 0 then
    Result := EmptyStr
  else
  begin
    Result := Trim(UpperCase(Copy(line, i + 1, Length(line) - i)));
  end;
end;

{
 Gibt an, ob das Zeichen c zu einem Labelbezeichner gehören darf.
 Gültig sind: A-Z, Ä, Ö, Ü, ß, 0-9, _
}
function IsValidLabelChar(c: char): boolean;
begin
  Result := ((c >= 'A') and (c <= 'Z')) or ((c >= '0') and (c <= '9')) or
    (c = '_') or (c = 'Ä') or (c = 'Ö') or (c = 'Ü') or (c = 'ß');
end;

{
 Liefert den Namen einer Labelzeile wie z.B. "START:" => "START".
 Liefert EMPTYSTR, wenn kein gültiges Label gefunden wurde.
}
function GetLabelName(LabelText: string): string;
var
  r: string;
  i: cardinal;
  len: cardinal;
  c: char;
begin
  r := '';
  // String-Indizierung ab 1...
  i := 1;
  len := Length(LabelText);
  Result := EmptyStr;
  // s.o.
  while i <= len do
  begin
    c := LabelText[i];
    if IsValidLabelChar(c) then
      AppendStr(r, c)
    else
    begin
      if c = ':' then
      begin
        Result := r;
      end;
      break;
    end;
    Inc(i);
  end;
end;

{
 Liefert die Operanden und deren Anzahl aus einem Operandenstring,
   wie z.B. "AL, BL" -> "AL", "BL", 2
}
function ParseOperands(opString: string): TOperands;
var
  kommaPos: cardinal;
begin
  opString := Trim(opString);
  Result.op1 := EmptyStr;
  Result.op2 := EmptyStr;

  if opString = EmptyStr then
  begin
    // keine Operanden
    Result.Count := 0;
  end
  else
  begin
    // min. 1 Operator
    kommaPos := Pos(',', opString);
    if kommaPos = 0 then
    begin
      // kein Komma enthalten -> 1 Operand = opString
      Result.Count := 1;
      Result.op1 := opString;
    end
    else
    begin
      // Komma enthalten -> min. 2 Operanden
      if PosEx(',', opString, kommaPos + 1) <> 0 then
      begin
        // mehr als 2 Operanden. Sollte nicht vorkommen.
        Result.Count := 3;
      end
      else
      begin
        // 2 Operatoren.
        Result.Count := 2;
        Result.op1 := Trim(Copy(opString, 1, kommaPos - 1));
        Result.op2 := Trim(Copy(opString, kommaPos + 1, Length(opString) - kommaPos));
      end;
    end;
  end;
end;

{
 Liefert die Größe eines Registers in Bytes.
 Liefert 0, wenn das Register ungültig ist.
}
function RegisterSize(r: RegisterIndex): cardinal;
begin
  case r of
    RegisterIndex.AL,
    RegisterIndex.AH,
    RegisterIndex.BL,
    RegisterIndex.BH,
    RegisterIndex.CL,
    RegisterIndex.CH,
    RegisterIndex.DL,
    RegisterIndex.DH:
    begin
      Result := 1;
    end;
    RegisterIndex.AX,
    RegisterIndex.BX,
    RegisterIndex.CX,
    RegisterIndex.DX,
    RegisterIndex.BP,
    RegisterIndex.SP,
    RegisterIndex.IP,
    RegisterIndex.FLAGS:
    begin
      Result := 2;
    end
    else
    begin
      Result := 0;
    end;
  end;
end;

{
 Liefert den RegisterIndex eines Registerstrings.
 Wenn das Register nicht gültig ist, wird RegisterIndex.INVALID zurückgegeben.
}
function ParseRegisterIndex(registerString: string): RegisterIndex;
begin
  case registerString of
    'AX': Result := RegisterIndex.AX;
    'BX': Result := RegisterIndex.BX;
    'CX': Result := RegisterIndex.CX;
    'DX': Result := RegisterIndex.DX;
    'AL': Result := RegisterIndex.AL;
    'BL': Result := RegisterIndex.BL;
    'CL': Result := RegisterIndex.CL;
    'DL': Result := RegisterIndex.DL;
    'AH': Result := RegisterIndex.AH;
    'BH': Result := RegisterIndex.BH;
    'CH': Result := RegisterIndex.CH;
    'DH': Result := RegisterIndex.DH;
    'BP': Result := RegisterIndex.BP;
    'SP': Result := RegisterIndex.SP;
    'IP': Result := RegisterIndex.IP;
    'FLAGS': Result := RegisterIndex.FLAGS;
    else
      Result := RegisterIndex.INVALID;
  end;
end;


// TODO: überprüfen, ob Zahl > SmallInt
function ParseAddress(addressString : string) : TAddress;
var inbrackets : string;
  pluspos : Cardinal;
  minuspos : Cardinal;
  left, right : String;
  longX : LongInt;
begin
  if (LeftStr(addressString, 1) = '[') and (RightStr(addressString, 1) = ']') then
  begin
    inbrackets:=Copy(addressString, 2, Length(addressString) - 2);
    inbrackets := Trim(inbrackets);
    pluspos := Pos('+', inbrackets);
    Result.rFound:=true;    // sowohl X als auch R sind vorhanden, sonst
    Result.xFound:=true;    // wird das weiter unten geändert!
    if pluspos = 0 then
    begin
      minuspos := Pos('-', inbrackets);
      if minuspos = 0 then
      begin
        // kein + oder - => nur [R] oder [X] möglich.
        if TryStrToInt(inbrackets, LongX) then
        begin
          Result.valid:=true;
          Result.x:=SmallInt(LongX);
          Result.R:=RegisterIndex.INVALID;
          Result.rFound:=false;
        end
        else
        begin
          Result.xFound:=false;
          Result.R := ParseRegisterIndex(inbrackets);
          if Result.R <> RegisterIndex.INVALID then
          begin
            Result.valid:=true;
          end
          else
          begin
            // Eingabe ungültig
            Result.valid:=false;
          end;
        end;
      end
      else
      begin
        // MINUS
        left := Trim(Copy(inbrackets, 1, minuspos-1));
        right := Trim(Copy(inbrackets, minuspos+1, Length(inbrackets) - minuspos));
          if TryStrToInt(right, LongX) then
          begin
            // rechtes ist Zahl => linkes muss Register sein
            Result.x:=SmallInt(LongX);
            Result.R:=ParseRegisterIndex(left);
            if Result.R <> RegisterIndex.INVALID then
            begin
              Result.valid:=true;
              Result.x:=-Result.x;
            end
            else
            begin
              // kein Register
              Result.valid:=false;
            end;
          end
          else
          begin
            // keine Zahl
            Result.valid:=false;
          end;
      end;
    end
    else
    begin
      // PLUS
      left := Trim(Copy(inbrackets, 1, pluspos-1));
        right := Trim(Copy(inbrackets, pluspos+1, Length(inbrackets) - pluspos));
          if TryStrToInt(right, LongX) then
          begin
            // rechtes ist Zahl => linkes muss Register sein
            Result.x:=SmallInt(LongX);
            Result.R:=ParseRegisterIndex(left);
            if Result.R <> RegisterIndex.INVALID then
            begin
              Result.valid:=true;
            end
            else
            begin
              // kein Register
              Result.valid:=false;
            end;
          end
          else
          begin
            // keine Zahl
            Result.valid:=false;
          end;
    end;
  end
  else
  begin
    // keine [ ]
    Result.valid:=false;
    Result.rFound:=false;
    Result.xFound:=false;
  end;
end;

// ======================= TCompiler functions =================================

function TCompiler.WriteInstrucitonLineToRAM(instruction, operandsString: string;
  var offset: word; line: cardinal; var labelResolveList: TLabelResolveList;
  var rBytesWritten: word; var rErrorString: string): boolean;
var
  operands: TOperands;
  r1, r2: RegisterIndex;
  n1, n2: integer;
  a1, a2: TAddress;

  procedure ReportOPCountError(expected: cardinal);
  begin
    rErrorString := UpperCase(instruction) + ': Wrong number of operands.'#13 +
      'Expected: ' + IntToStr(expected) + #13'Found: ' + IntToStr(operands.Count);
  end;

  procedure ReportInvalidOperands();
  begin
    rErrorString := UpperCase(instruction) + ': Invalid operands.';
  end;

begin
  Result := True;
  rBytesWritten := 0;
  operands := ParseOperands(operandsString);
  r1 := ParseRegisterIndex(operands.op1);
  r2 := ParseRegisterIndex(operands.op2);
  a1 := ParseAddress(operands.op1);
  a2 := ParseAddress(operands.op2);

  case instruction of
    'END': // 1
    begin
      if (operands.Count = 0) then
      begin
        Ram.WriteByte(offset, Ord(OPCode._END));
        rBytesWritten:=1;
      end
      else
      begin
        ReportOPCountError(0);
      end;
    end;

    'MOV': // 8
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MOV R, R
          Ram.WriteByte(offset, Ord(OPCode.MOV_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // MOV R, X
          Ram.WriteByte(offset, Ord(OPCode.MOV_R_X));
          Ram.WriteByte(offset+1, Ord(r1));
          Ram.WriteWord(offset+2, n2);
          rBytesWritten := 4;
          exit(TRUE);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) then
        begin
          // MOV R, [A]
          if (a2.rFound and a2.xFound) then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOV_R_ADDR_RX));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            Ram.WriteWord(offset+3, a2.x);
            rBytesWritten := 5;
          end
          else
          if a2.xFound then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOV_R_ADDR_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, Word(a2.x));
            rBytesWritten := 4;
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOV_R_ADDR_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            rBytesWritten := 3;
          end;
          exit(TRUE);
        end
        else
        if (a1.valid) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MOV [A], R
          if (a1.rFound) and (not a1.xFound) then
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_R_R));
            Ram.WriteByte(offset+1, Ord(a1.R));
            Ram.WriteByte(offset+2, Ord(r2));
            rBytesWritten := 3;
          end
          else
          if (a1.xFound) and (not a1.rFound) then
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_X_R));
            Ram.WriteWord(offset+1, Ord(a1.x));
            Ram.WriteByte(offset+3, Ord(r2));
            rBytesWritten := 4;
          end
          else
          if (a1.rFound) and (a1.xFound) then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_RX_R));
            Ram.WriteByte(offset+1, Ord(a1.R));
            Ram.WriteWord(offset+2, Ord(a1.x));
            Ram.WriteByte(offset+4, Ord(r2));
            rBytesWritten := 5;
          end;
          exit(True);
        end;
          // Keine anderen Kombinationen von Operanden
        begin
          // Keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'ADD': // 4
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // ADD R, R
          Ram.WriteByte(offset, Ord(OPCode.ADD_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // ADD R, X
          Ram.WriteByte(offset, Ord(OPCode.ADD_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and (a2.xFound xor a2.rFound) then
        begin
          // ADD R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.ADD_R_ADDR_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, Word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.ADD_R_ADDR_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(TRUE);
        end
        else
        // Hier andere Kombinationen angeben.
        begin
          // Keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        // NICHT 2 Operatoren
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'SUB': // 4
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // SUB R, R
          Ram.WriteByte(offset, Ord(OPCode.SUB_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // SUB R, X
          Ram.WriteByte(offset, Ord(OPCode.SUB_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and (a2.xFound xor a2.rFound) then
        begin
          // SUB R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.SUB_R_ADDR_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, Word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.SUB_R_ADDR_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(TRUE);
        end
        else
        // Hier andere Kombinationen angeben.
        begin
          // Keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        // NICHT 2 Operatoren
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'MUL': // 4
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MUL R, R
          Ram.WriteByte(offset, Ord(OPCode.MUL_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // MUL R, X
          Ram.WriteByte(offset, Ord(OPCode.MUL_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and (a2.xFound xor a2.rFound) then
        begin
          // MUL R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MUL_R_ADDR_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, Word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MUL_R_ADDR_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(TRUE);
        end
        else
        // Hier andere Kombinationen angeben.
        begin
          // Keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        // NICHT 2 Operatoren
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'DIV': // 4
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // DIV R, R
          Ram.WriteByte(offset, Ord(OPCode.DIV_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // DIV R, X
          Ram.WriteByte(offset, Ord(OPCode.DIV_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and (a2.xFound xor a2.rFound) then
        begin
          // DIV R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.DIV_R_ADDR_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, Word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.DIV_R_ADDR_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(TRUE);
        end
        else
        // Hier andere Kombinationen angeben.
        begin
          // Keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        // NICHT 2 Operatoren
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'MOD': // 4
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MOD R, R
          Ram.WriteByte(offset, Ord(OPCode.MOD_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // MOD R, X
          Ram.WriteByte(offset, Ord(OPCode.MOD_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and (a2.xFound xor a2.rFound) then
        begin
          // MOD R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOD_R_ADDR_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, Word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOD_R_ADDR_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(TRUE);
        end
        else
        // Hier andere Kombinationen angeben.
        begin
          // Keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        // NICHT 2 Operatoren
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'CMP': // 2
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // CMP R, R
          Ram.WriteByte(offset, Ord(OPCode.CMP_R_R));
          Ram.WriteByte(offset+1, Ord(r1));
          Ram.WriteByte(offset+2, Ord(r2));
          rBytesWritten:=3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryStrToInt(operands.op2, n2) then
        begin
          // CMP R, X
          Ram.WriteByte(offset, Ord(OPCode.CMP_R_X));
          Ram.WriteByte(offset+1, Ord(r1));
          Ram.WriteWord(offset+2, n2);
          rBytesWritten:=4;
          exit(True);
        end
        else
        begin
          // Keine passenden Operanden.
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
      // Falsche Anzahl an Operanden.
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'JMP': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JMP R
          Ram.WriteByte(offset, Ord(OPCode.JMP_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JMP X
          Ram.WriteByte(offset, Ord(OPCode.JMP_ADDR));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JMP LABEL
          Ram.WriteByte(offset, Ord(OPCode.JMP_ADDR));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'JS': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JS R
          Ram.WriteByte(offset, Ord(OPCode.JS_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JS X
          Ram.WriteByte(offset, Ord(OPCode.JS_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JS LABEL
          Ram.WriteByte(offset, Ord(OPCode.JS_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'JZ': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JZ R
          Ram.WriteByte(offset, Ord(OPCode.JZ_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JZ X
          Ram.WriteByte(offset, Ord(OPCode.JZ_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JZ LABEL
          Ram.WriteByte(offset, Ord(OPCode.JZ_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'JO': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JO R
          Ram.WriteByte(offset, Ord(OPCode.JO_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JO X
          Ram.WriteByte(offset, Ord(OPCode.JO_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JO LABEL
          Ram.WriteByte(offset, Ord(OPCode.JO_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'JNS': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JNS R
          Ram.WriteByte(offset, Ord(OPCode.JNS_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JNS X
          Ram.WriteByte(offset, Ord(OPCode.JNS_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JNS LABEL
          Ram.WriteByte(offset, Ord(OPCode.JNS_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'JNZ': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JNZ R
          Ram.WriteByte(offset, Ord(OPCode.JNZ_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JNZ X
          Ram.WriteByte(offset, Ord(OPCode.JNZ_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JNZ LABEL
          Ram.WriteByte(offset, Ord(OPCode.JNZ_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'JNO': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JNO R
          Ram.WriteByte(offset, Ord(OPCode.JNO_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // JNO X
          Ram.WriteByte(offset, Ord(OPCode.JNO_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JNO LABEL
          Ram.WriteByte(offset, Ord(OPCode.JNO_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'CALL': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // CALL R
          Ram.WriteByte(offset, Ord(OPCode.CALL_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // CALL X
          Ram.WriteByte(offset, Ord(OPCode.CALL_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // CALL LABEL
          Ram.WriteByte(offset, Ord(OPCode.CALL_X));
          labelResolveList.Add(CrTLabelUse(operands.op1, offset + 1, line));
          rBytesWritten := 3;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'RET': // 1
    begin
      if (operands.Count = 0) then
      begin
        Ram.WriteByte(offset, Ord(OPCode.RET));
        rBytesWritten:=1;
        exit(True)
      end
      else
      begin
        ReportOPCountError(0);
        exit(False);
      end;
    end;

    'PUSH': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // PUSH R
          Ram.WriteByte(offset, Ord(OPCode.PUSH_R));
          Ram.WriteByte(offset+1, Ord(r1));
          rBytesWritten:=2;
          exit(TRUE);
        end
        else
        if TryStrToInt(operands.op1, n1) then
        begin
          // PUSH X
          Ram.WriteByte(offset, Ord(OPCode.PUSH_X));
          Ram.WriteWord(offset+1, n1);
          rBytesWritten := 3;
          exit(TRUE);
        end
        else
        // restliche Kombinationen
        begin
          // keine passenden Operanden
          ReportInvalidOperands();
          exit(FALSE);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(FALSE);
      end;
    end;

    'POP': // 2
    begin
      if operands.Count = 0 then
      begin
        // POP
        Ram.WriteByte(offset, Ord(OPCode.POP));
        rBytesWritten := 1;
        exit(TRUE);
      end
      else
      begin
        if (operands.Count = 1) then
        begin
          if (r1 <> RegisterIndex.INVALID) then
          begin
            // POP R
            Ram.WriteByte(offset, Ord(POP_R));
            Ram.WriteByte(offset+1, Ord(r1));
            rBytesWritten := 2;
            exit(TRUE);
          end
          else
          begin
            // keine passenden Operatoren
            ReportInvalidOperands();
            exit(FALSE);
          end;
        end
        else
        begin
          ReportOPCountError(1);
          exit(FALSE);
        end;
      end;
    end;

    'NOT': // 1
    begin
      if operands.Count = 1 then
      begin
        if r1 <> RegisterIndex.INVALID then
        begin
          // NOT R
          Ram.WriteByte(offset, Ord(OPCode.NOT_R));
          Ram.WriteByte(offset+1, Ord(r1));
          rBytesWritten:=2;
          exit(TRUE);
        end
        else
        begin
          ReportInvalidOperands();
          exit(FALSE);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(FALSE);
      end;
    end;

    'AND': // 4
    begin
      if (operands.Count = 2) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          if TryStrToInt(operands.op2, n2) then
          begin
            // AND R, X
            Ram.WriteByte(offset, Ord(OPCode.AND_R_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, n2);
            rBytesWritten:=4;
            exit(True);
          end
          else
          if (r2 <> RegisterIndex.INVALID) then
          begin
            // AND R, R
            Ram.WriteByte(offset, Ord(OPCode.AND_R_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(r2));
            rBytesWritten:=3;
            exit(True);
          end
          else
          if a2.valid then
          begin
            // AND R, [A]
            if a2.xFound and (not a2.rFound) then
            begin
              // A = X
              Ram.WriteByte(offset, Ord(OPCode.AND_R_ADDR_X));
              Ram.WriteByte(offset+1, Ord(r1));
              Ram.WriteWord(offset+2, a2.x);
              rBytesWritten:=4;
              exit(True);
            end
            else
            if a2.rFound and (not a2.xFound) then
            begin
              // A = R
              Ram.WriteByte(offset, Ord(OPCode.AND_R_ADDR_R));
              Ram.WriteByte(offset+1, Ord(r1));
              Ram.WriteByte(offset+2, Ord(a2.R));
              rBytesWritten:=3;
              exit(True);
            end;
          end;
        end;

        // Keine passenden Operanden.
        ReportInvalidOperands();
        exit(False);
      end
      else
      begin
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'OR': // 4
    begin
      if (operands.Count = 2) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          if TryStrToInt(operands.op2, n2) then
          begin
            // OR R, X
            Ram.WriteByte(offset, Ord(OPCode.OR_R_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, n2);
            rBytesWritten:=4;
            exit(True);
          end
          else
          if (r2 <> RegisterIndex.INVALID) then
          begin
            // OR R, R
            Ram.WriteByte(offset, Ord(OPCode.OR_R_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(r2));
            rBytesWritten:=3;
            exit(True);
          end
          else
          if a2.valid then
          begin
            // OR R, [A]
            if a2.xFound and (not a2.rFound) then
            begin
              // A = X
              Ram.WriteByte(offset, Ord(OPCode.OR_R_ADDR_X));
              Ram.WriteByte(offset+1, Ord(r1));
              Ram.WriteWord(offset+2, a2.x);
              rBytesWritten:=4;
              exit(True);
            end
            else
            if a2.rFound and (not a2.xFound) then
            begin
              // A = R
              Ram.WriteByte(offset, Ord(OPCode.OR_R_ADDR_R));
              Ram.WriteByte(offset+1, Ord(r1));
              Ram.WriteByte(offset+2, Ord(a2.R));
              rBytesWritten:=3;
              exit(True);
            end;
          end;
        end;

        // Keine passenden Operanden.
        ReportInvalidOperands();
        exit(False);
      end
      else
      begin
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'XOR': // 4
    begin
      if (operands.Count = 2) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          if TryStrToInt(operands.op2, n2) then
          begin
            // XOR R, X
            Ram.WriteByte(offset, Ord(OPCode.XOR_R_X));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteWord(offset+2, n2);
            rBytesWritten:=4;
            exit(True);
          end
          else
          if (r2 <> RegisterIndex.INVALID) then
          begin
            // XOR R, R
            Ram.WriteByte(offset, Ord(OPCode.XOR_R_R));
            Ram.WriteByte(offset+1, Ord(r1));
            Ram.WriteByte(offset+2, Ord(r2));
            rBytesWritten:=3;
            exit(True);
          end
          else
          if a2.valid then
          begin
            // XOR R, [A]
            if a2.xFound and (not a2.rFound) then
            begin
              // A = X
              Ram.WriteByte(offset, Ord(OPCode.XOR_R_ADDR_X));
              Ram.WriteByte(offset+1, Ord(r1));
              Ram.WriteWord(offset+2, a2.x);
              rBytesWritten:=4;
              exit(True);
            end
            else
            if a2.rFound and (not a2.xFound) then
            begin
              // A = R
              Ram.WriteByte(offset, Ord(OPCode.XOR_R_ADDR_R));
              Ram.WriteByte(offset+1, Ord(r1));
              Ram.WriteByte(offset+2, Ord(a2.R));
              rBytesWritten:=3;
              exit(True);
            end;
          end;
        end;

        // Keine passenden Operanden.
        ReportInvalidOperands();
        exit(False);
      end
      else
      begin
        ReportOPCountError(2);
        exit(False);
      end;
    end;

    'ORG':
    begin
      if (operands.Count = 1) then
      begin
        if TryStrToInt(operands.op1, n1) then
        begin
          offset := n1;
          rBytesWritten:=0;
          exit(True);
        end
        else
        begin
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end
    end;

    otherwise
    begin
      // Unbekannte Instruktion
      rBytesWritten := 0;
      rErrorString := 'Invalid instruction "' + instruction +
        '".'#13#13'Maybe not yet implemented...';
      exit(False);
    end;
  end;
  Result := False;
end;

procedure TCompiler.Compile(input: string);
var
  cpos, len, zlen, zNr, commentpos: cardinal;
  zeile: string;
  inst: string;
  temps: string;
  tLabelName: string;
  befehleDict: TCommandLineList;
  i: cardinal;

  labelDict: TLabelMap;
  labelResolveList: TLabelResolveList;
  opString: string;
  errString: string;
  bytepos: word;
  rwritten: word;

  procedure ReportError(Text: string);
  begin
    raise TCompilerException.Create('Error at line ' + IntToStr(
      befehleDict[i].nr) + ':'#13#13 + Text);
  end;

  procedure ResolveLabelAddresses();
  var
    item: TLabelUse;
    index: integer;
  begin
    i := 0;
    while i < cardinal(labelResolveList.Count) do
    begin
      item := labelResolveList[i];
      if not labelDict.Find(item.labelName, index) then
      begin
        // Label nicht gefunden
        ReportError('Label "' + item.labelName + '" not found.');
      end
      else
      begin
        // Label gefunden. Schreibe Sprungadresse in RAM.
        Ram.WriteWord(item.addrRAM, labelDict.Data[index]);
      end;
      Inc(i);
    end;
  end;

begin
  cpos := 0;
  zNr := 1;    // Zeilennummer
  befehleDict := TCommandLineList.Create;
  len := Length(input);
  while cpos < len do
  begin
    // VORSICHT! Kein Mensch weiß warum, aber Delphi indiziert Strings ab 1, nicht 0!
    zlen := PosEx(#13#10, input, 1 + cpos);
    if zlen = 0 then
      // kein Zeilenumbruch gefunden
      zlen := len - cpos
    else
      // Zeilenumbruch gefunden, korrigieren.
      zlen := zlen - cpos - 1;
    zeile := Copy(input, cpos + 1, zlen);
    commentpos := Pos(';', zeile);    // Entfernt Kommentare
    if commentpos > 0 then
      zeile := Copy(zeile, 1, commentpos - 1);
    zeile := Trim(zeile); // Entfernt alle vorhergehenden und nachfolgenden Leerzeichen.
    if zeile <> EmptyStr then
      // Zeile ist nicht leer
      befehleDict.Add(CrTCodeLineNr(UpperCase(zeile), zNr));

    cpos += zlen + 2; // wegen \r\n
    Inc(zNr);
  end;

  labelDict := TLabelMap.Create;
  labelResolveList := TLabelResolveList.Create;
  bytepos := 0;
  rwritten := 0;
  i := 0;
  errString := '';

  //
  while i < cardinal(befehleDict.Count) do
  begin
    inst := ExtractInstructionString(befehleDict[i].line);
    opString := ExtractOperandsString(befehleDict[i].line);
    if RightStr(inst, 1) = ':' then
    begin
      // Letztes Zeichen ist ':' => Zeile ist ein Label.
      // Es ist also keine weitere Verarbeitung nötig, die Adresse des Labels
      //   muss lediglich gesichert werden.
      if opString = EmptyStr then
      begin
        // kein Text nach Labeldeklaration
        tLabelName := GetLabelName(inst);
        if tLabelName = EmptyStr then
        begin
          // kein Labelname, nur ':'
          ReportError('Empty label name not allowed.');
        end
        else
        begin
          if labelDict.IndexOf(tLabelName) = -1 then
          begin
            // Label noch nicht vorhanden, alles gut
            labelDict.Add(tLabelName, bytepos);
          end
          else
          begin
            // Label-Duplikat
            ReportError('Duplicate label "' + tLabelName + '".');
          end;
        end;
      end
      else
      begin
        // Nach Label-Deklaration steht noch was, das soll nicht sein.
        ReportError('Text after label declaration.');
      end;
      rwritten := 0;
    end
    else
    begin
      // kein Label, Befehl in RAM schreiben.
      if not WriteInstrucitonLineToRAM(inst, opString, bytepos,
        befehleDict[i].nr, labelResolveList, rwritten, errString) then
      begin
        ReportError(errString);
        exit;
      end;
    end;

    bytepos += rwritten;
    Inc(i);
  end;

  {
   Routinen zum Überprüfen und Ausgeben der Resultate.
  }
  //nichts.

  {
   Schreiben der Labeladressen
  }
  ResolveLabelAddresses();
  LastSize := bytepos;
end;

function TCompiler.GetCodePosition(addr: cardinal): cardinal;
begin
  raise EInvalidOperation.Create('GetCodePosition ist noch nicht implementiert.');
  Result := 0;
end;

end.
