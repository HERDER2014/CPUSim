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
{$WARNING Jedi wird nicht funktionieren; bitte in den Jedi-Einstellungen bei
  PreProcessor das Symbol "JEDI" eintragen. }
type
  TLabelMap = specialize TFPGMap<string, Word>;

type
  TCommandLineList = specialize TFPGList<TCodeLineNr>;

type
  TLabelResolveList = specialize TFPGList<TLabelUse>;

type
  TCodePositionMap = specialize TFPGMap<Word, Cardinal>;

type
  TCodeLineAddrMap = specialize TFPGMap<Cardinal, Word>;

type
  TByteList = specialize TFPGList<Byte>;

{$ENDIF}

type
  TCompilerException = class(Exception);

type
  TNumberInputMode = (Decimal, Hexadecimal);

type

  { TCompiler }

  TCompiler = class
  private
  var
    Ram: TRAM;
    CodePosMap: TCodePositionMap;
    CodeLineAddrMap: TCodeLineAddrMap;
    warnings: TStringList;

  public
  var
    NumberInputMode: TNumberInputMode;

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
     Vor: -
     Erg.: Liefert die Warnungen vom letzten Assemblen.
    }
    function GetWarnings(): TStringList;

   {
   Vor.: Compile wurde ausgeführt.
   Eff.: -
   Erg.: Liefert die Zeile in der Eingabe, die an Adresse addr kompiliert wurde. Wenn diese ungültig ist, wird 0 zurückgegeben.
   }
    function GetCodePosition(addr: word): cardinal;

    function GetCodeAddrOfLine(line: Cardinal) : Word;

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
      var offset: word; line: cardinal; var rBytesWritten: word;
      var rErrorString: string): boolean;

    function TryParseIntBase(s: string; out i: integer;
      base: TNumberInputMode): boolean;
    function GetAllOperandsAsBytes(opString: string): TByteList;
    //function ParseAddress(addressString: string; base : TNumberInputMode): TAddress;  -> in Funktion Write...toRAM


  var
    m_labelResolveList: TLabelResolveList;

  public
    // Die Größe des letzten Images.
    LastSize: cardinal;
  end;

implementation

constructor TCompiler.Create(var r: TRAM);
begin
  Ram := r;
  NumberInputMode := TNumberInputMode.Decimal;
  CodePosMap := TCodePositionMap.Create;
  CodeLineAddrMap := TCodeLineAddrMap.Create;
  warnings := TStringList.Create;
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
    Result := Trim(Copy(line, i + 1, Length(line) - i));
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

function IsValidLabelName(s: string): boolean;
var
  i: integer;
begin
  for i := 1 to length(s) do
  begin
    if (not IsValidLabelChar(s[i])) or ((i = 1) and (s[i] >= '0') and (s[i] <= '9')) then
      exit(False);
  end;
  exit(True);
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
        Result := UpperCase(r);
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
        // mehr als 2 Operanden. Sollte nicht vorkommen. (siehe MultipleOp...)
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

function ParseMultipleOperands(opString: string): TStringList;
var
  pos: integer;
  len: integer;
  s: string;
  c: char;
  inString: boolean;
begin
  Result := TStringList.Create;
  pos := 1; // VORSICHT
  len := Length(opString);

  inString := False;
  s := EmptyStr;

  while pos <= len do
  begin
    c := opString[pos];

    case c of
      '"':
      begin
        inString := not inString;
        s += c;
      end;
      ',':
      begin
        if not inString then
        begin
          s := Trim(s);
          if s <> EmptyStr then
          begin
            Result.Add(s);
            s := EmptyStr;
          end;
        end
        else
        begin
          s += c;
        end;
      end
      else
      begin
        s += c;
      end;
    end;

    Inc(pos);
  end;

  if not inString then
  begin
    s := Trim(s);
    if s <> EmptyStr then
    begin
      Result.Add(s);
    end;
  end
  else
  begin
    exit(nil);
  end;
end;

{

 Erg.: Wenn nicht erfolgreich: gibt NIL zurück.
}
function TCompiler.GetAllOperandsAsBytes(opString: string): TByteList;
var
  opList: TStringList;
  i, j, x: integer;
  s, ss: string;
begin
  Result := TByteList.Create;
  opList := ParseMultipleOperands(opString);

  if opList = nil then
  begin
    exit(nil);
  end;

  for i := 0 to opList.Count - 1 do
  begin
    s := opList[i];
    if TryParseIntBase(s, x, numberInputMode) then
    begin
      // Zahl in Operand i
      if x > 255 then
      begin
        // über Byte-Größe
        exit(nil);
      end
      else
      begin
        Result.Add(byte(x));
      end;
    end
    else
    begin
      if (LeftStr(s, 1) = '"') and (RightStr(s, 1) = '"') and (Length(s) >= 2) then
      begin
        // "String"
        ss := Copy(s, 2, Length(s) - 2);
        if ss = EmptyStr then
          Continue;
        for j := 1 to Length(ss) do
        begin
          Result.Add(byte(ss[j]));
        end;
      end
      else
      begin
        exit(nil);
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
  case UpperCase(registerString) of
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
    'VP': Result := RegisterIndex.VP;
    'FLAGS': Result := RegisterIndex.FLAGS;
    else
      Result := RegisterIndex.INVALID;
  end;
end;


{// TODO: überprüfen, ob Zahl > SmallInt
function TCompiler.ParseAddress(addressString: string; base : TNumberInputMode): TAddress;
var
  inbrackets: string;
  pluspos: cardinal;
  minuspos: cardinal;
  left, right: string;
  longX: longint;
begin
  if (LeftStr(addressString, 1) = '[') and (RightStr(addressString, 1) = ']') then
  begin
    inbrackets := Copy(addressString, 2, Length(addressString) - 2);
    inbrackets := Trim(inbrackets);
    pluspos := Pos('+', inbrackets);
    Result.rFound := True;    // sowohl X als auch R sind vorhanden, sonst
    Result.xFound := True;    // wird das weiter unten geändert!
    if pluspos = 0 then
    begin
      minuspos := Pos('-', inbrackets);
      if minuspos = 0 then
      begin
        // kein + oder - => nur [R] oder [X] möglich.
        if TryParseIntBase(inbrackets, LongX, base) then
        begin
          Result.valid := True;
          Result.x := smallint(LongX);
          Result.R := RegisterIndex.INVALID;
          Result.rFound := False;
        end
        else
        begin
          Result.xFound := False;
          Result.R := ParseRegisterIndex(inbrackets);
          if Result.R <> RegisterIndex.INVALID then
          begin
            Result.valid := True;
          end
          else
          begin
            // Eingabe ungültig
            Result.valid := False;
          end;
        end;
      end
      else
      begin
        // MINUS
        left := Trim(Copy(inbrackets, 1, minuspos - 1));
        right := Trim(Copy(inbrackets, minuspos + 1, Length(inbrackets) - minuspos));
        if TryParseIntBase(right, LongX, base) then
        begin
          // rechtes ist Zahl => linkes muss Register sein
          Result.x := smallint(LongX);
          Result.R := ParseRegisterIndex(left);
          if Result.R <> RegisterIndex.INVALID then
          begin
            Result.valid := True;
            Result.x := -Result.x;
          end
          else
          begin
            // kein Register
            Result.valid := False;
          end;
        end
        else
        begin
          // keine Zahl
          Result.valid := False;
        end;
      end;
    end
    else
    begin
      // PLUS
      left := Trim(Copy(inbrackets, 1, pluspos - 1));
      right := Trim(Copy(inbrackets, pluspos + 1, Length(inbrackets) - pluspos));
      if TryParseIntBase(right, LongX, base) then
      begin
        // rechtes ist Zahl => linkes muss Register sein
        Result.x := smallint(LongX);
        Result.R := ParseRegisterIndex(left);
        if Result.R <> RegisterIndex.INVALID then
        begin
          Result.valid := True;
        end
        else
        begin
          // kein Register
          Result.valid := False;
        end;
      end
      else
      begin
        // keine Zahl
        Result.valid := False;
      end;
    end;
  end
  else
  begin
    // keine [ ]
    Result.valid := False;
    Result.rFound := False;
    Result.xFound := False;
  end;
end;}

// Gibt true zurück, wenn Register nur 1B groß.
function RegisterSmall(r: RegisterIndex): boolean;
begin
  if (r = RegisterIndex.AL) or (r = RegisterIndex.AH) or
    (r = RegisterIndex.BL) or (r = RegisterIndex.BH) or
    (r = RegisterIndex.CL) or (r = RegisterIndex.CH) or
    (r = RegisterIndex.DL) or (r = RegisterIndex.DH) then
  begin
    exit(True);
  end;
  exit(False);
end;

// ======================= TCompiler functions =================================

function TCompiler.WriteInstrucitonLineToRAM(instruction, operandsString: string;
  var offset: word; line: cardinal; var rBytesWritten: word;
  var rErrorString: string): boolean;
var
  operands: TOperands;
  r1, r2: RegisterIndex;
  n1, n2: integer;
  a1, a2: TAddress;
  dbBytes: TByteList;

  i: integer; // Zählervariable, nur zum Testen

  procedure ReportOPCountError(expected: cardinal);
  begin
    rErrorString := UpperCase(instruction) + ': Wrong number of operands.'#13 +
      'Expected: ' + IntToStr(expected) + #13'Found: ' + IntToStr(operands.Count);
  end;

  procedure ReportInvalidOperands();
  begin
    rErrorString := UpperCase(instruction) + ': Invalid operands.';
  end;

  procedure ReportWarning(s: string);
  begin
    warnings.Add('Line ' + IntToStr(line) + ': ' + s);
  end;

  function TryParseIntOrLabel(s: string; out i: integer; addr: word): boolean;
  begin
    Result := TryParseIntBase(s, i, NumberInputMode);
    if (not Result) and IsValidLabelName(UpperCase(s)) then
    begin
      m_labelResolveList.Add(CrTLabelUse(UpperCase(s), addr, line));
      Result := True;
    end;
  end;

  {
   Funktioniert wie TryParseIntOrLabel, schreibt aber -i.
  }
  function TryParseIntOrLabelNeg(s: string; out i: integer; addr: word): boolean;
  begin
    Result := TryParseIntBase(s, i, NumberInputMode);
    if (not Result) and IsValidLabelName(UpperCase(s)) then
    begin
      m_labelResolveList.Add(CrTLabelUseN(UpperCase(s), addr, line, True));
      Result := True;
    end;
  end;

  function TryParseIntOnly(s: string; out i: integer): boolean;
  begin
    Result := TryParseIntBase(s, i, NumberInputMode);
  end;

  // TODO: überprüfen, ob Zahl > SmallInt
  function ParseAddress(addressString: string): TAddress;
  var
    inbrackets: string;
    pluspos: cardinal;
    minuspos: cardinal;
    left, right: string;
    longX: longint;
  begin
    if (LeftStr(addressString, 1) = '[') and (RightStr(addressString, 1) = ']') then
    begin
      inbrackets := Copy(addressString, 2, Length(addressString) - 2);
      inbrackets := Trim(inbrackets);
      pluspos := Pos('+', inbrackets);
      Result.rFound := True;    // sowohl X als auch R sind vorhanden, sonst
      Result.xFound := True;    // wird das weiter unten geändert!
      if pluspos = 0 then
      begin
        minuspos := Pos('-', inbrackets);
        if minuspos = 0 then
        begin
          // kein + oder - => nur [R] oder [X] möglich.
          Result.R := ParseRegisterIndex(inbrackets);
          if Result.R <> RegisterIndex.INVALID then
          begin
            Result.xFound := False;
            Result.valid := True;
          end
          else
          if TryParseIntOrLabel(inbrackets, LongX, offset + 1) then
          begin
            Result.valid := True;
            Result.x := smallint(LongX);
            Result.rFound := False;
          end
          else
          begin
            Result.valid := False;
          end;
        end
        else
        begin
          // MINUS
          left := Trim(Copy(inbrackets, 1, minuspos - 1));
          right := Trim(Copy(inbrackets, minuspos + 1, Length(inbrackets) - minuspos));

          Result.R := ParseRegisterIndex(left);
          if Result.R <> RegisterIndex.INVALID then
          begin
            if TryParseIntOrLabelNeg(right, LongX, offset + 3) then
            begin
              Result.valid := True;
              Result.x := smallint(LongX);
              Result.x := -Result.x;
            end
            else
            begin
              // keine Zahl
              Result.valid := False;
            end;
          end
          else
          begin
            // kein Register
            Result.valid := False;
          end;
        end;
      end
      else
      begin
        // PLUS
        left := Trim(Copy(inbrackets, 1, pluspos - 1));
        right := Trim(Copy(inbrackets, pluspos + 1, Length(inbrackets) - pluspos));

        Result.R := ParseRegisterIndex(left);
        if Result.R <> RegisterIndex.INVALID then
        begin
          if TryParseIntOrLabel(right, LongX, offset + 3) then
          begin
            Result.valid := True;
            Result.x := smallint(LongX);
          end
          else
          begin
            // keine Zahl
            Result.valid := False;
          end;
        end
        else
        begin
          // kein Register
          Result.valid := False;
        end;
      end;
    end
    else
    begin
      // keine [ ]
      Result.valid := False;
      Result.rFound := False;
      Result.xFound := False;
    end;
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
        rBytesWritten := 1;
        exit(True);
      end
      else
      begin
        ReportOPCountError(0);
        exit(False);
      end;
    end;

    'MOV', 'MOVW': // 11(*2)
    begin
      if (r1 <> RegisterIndex.INVALID) or (r2 <> RegisterIndex.INVALID) then
      begin
        if RegisterSmall(r1) or RegisterSmall(r2) then
        begin
          ReportWarning('Register may be too small for this operation.');
        end;
      end;
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
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // MOV R, X
          Ram.WriteByte(offset, Ord(OPCode.MOV_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) then
        begin
          // MOV R, [A]
          if (a2.rFound and a2.xFound) then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOV_R_ADDR_RX));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            Ram.WriteWord(offset + 3, a2.x);
            rBytesWritten := 5;
          end
          else
          if a2.xFound then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOV_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOV_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
          end;
          exit(True);
        end
        else
        if (a1.valid) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MOV [A], R
          if (a1.rFound) and (not a1.xFound) then
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_R_R));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteByte(offset + 2, Ord(r2));
            rBytesWritten := 3;
          end
          else
          if (a1.xFound) and (not a1.rFound) then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_X_R));
            Ram.WriteWord(offset + 1, Ord(a1.x));
            Ram.WriteByte(offset + 3, Ord(r2));
            rBytesWritten := 4;
          end
          else
          if (a1.rFound) and (a1.xFound) then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_RX_R));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteWord(offset + 2, Ord(a1.x));
            Ram.WriteByte(offset + 4, Ord(r2));
            rBytesWritten := 5;
          end;
          exit(True);
        end
        else
        if (a1.valid) and TryParseIntOrLabel(operands.op2, n2, offset + 4) then
        begin
          // MOV [A], X
          if a1.rFound and a1.xFound then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_RX_X));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteWord(offset + 2, Ord(a1.x));
            Ram.WriteWord(offset + 4, n2);
            rBytesWritten := 6;
            exit(True);
          end
          else
          if a1.rFound and (not a1.xFound) then
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_R_X));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteWord(offset + 2, n2);
            rBytesWritten := 4;
            exit(True);
          end
          else
          if a1.xFound and (not a1.rFound) then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOV_ADDR_X_X));
            Ram.WriteWord(offset + 1, Ord(a1.X));
            Ram.WriteWord(offset + 3, n2);
            rBytesWritten := 5;
            exit(True);
          end;
        end
        else
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

    'MOVB': // 8
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MOVB R, R
          Ram.WriteByte(offset, Ord(OPCode.MOVB_R_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOnly(operands.op2, n2) then
        begin
          // MOVB R, X
          Ram.WriteByte(offset, Ord(OPCode.MOVB_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, byte(n2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) then
        begin
          // MOVB R, [A]
          if (a2.rFound and a2.xFound) then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOVB_R_ADDR_RX));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            Ram.WriteWord(offset + 3, a2.x);
            rBytesWritten := 5;
          end
          else
          if a2.xFound then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOVB_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOVB_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
          end;
          exit(True);
        end
        else
        if (a1.valid) and (r2 <> RegisterIndex.INVALID) then
        begin
          // MOVB [A], R
          if (a1.rFound) and (not a1.xFound) then
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOVB_ADDR_R_R));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteByte(offset + 2, Ord(r2));
            rBytesWritten := 3;
          end
          else
          if (a1.xFound) and (not a1.rFound) then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOVB_ADDR_X_R));
            Ram.WriteWord(offset + 1, Ord(a1.x));
            Ram.WriteByte(offset + 3, Ord(r2));
            rBytesWritten := 4;
          end
          else
          if (a1.rFound) and (a1.xFound) then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOVB_ADDR_RX_R));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteWord(offset + 2, Ord(a1.x));
            Ram.WriteByte(offset + 4, Ord(r2));
            rBytesWritten := 5;
          end;
          exit(True);
        end
        else
        if (a1.valid) and TryParseIntOnly(operands.op2, n2) then
        begin
          // MOVB [A], X
          if a1.rFound and a1.xFound then
          begin
            // A = R+X
            Ram.WriteByte(offset, Ord(OPCode.MOVB_ADDR_RX_X));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteWord(offset + 2, Ord(a1.x));
            Ram.WriteByte(offset + 4, byte(n2));
            rBytesWritten := 5;
            exit(True);
          end
          else
          if a1.rFound and (not a1.xFound) then
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOVB_ADDR_R_X));
            Ram.WriteByte(offset + 1, Ord(a1.R));
            Ram.WriteByte(offset + 2, byte(n2));
            rBytesWritten := 3;
            exit(True);
          end
          else
          if a1.xFound and (not a1.rFound) then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOVB_ADDR_X_X));
            Ram.WriteWord(offset + 1, Ord(a1.X));
            Ram.WriteByte(offset + 3, byte(n2));
            rBytesWritten := 4;
            exit(True);
          end;
        end
        else
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
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // ADD R, X
          Ram.WriteByte(offset, Ord(OPCode.ADD_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and
          (a2.xFound xor a2.rFound) then
        begin
          // ADD R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.ADD_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.ADD_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(True);
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
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // SUB R, X
          Ram.WriteByte(offset, Ord(OPCode.SUB_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and
          (a2.xFound xor a2.rFound) then
        begin
          // SUB R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.SUB_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.SUB_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(True);
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
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // MUL R, X
          Ram.WriteByte(offset, Ord(OPCode.MUL_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and
          (a2.xFound xor a2.rFound) then
        begin
          // MUL R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MUL_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MUL_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(True);
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
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // DIV R, X
          Ram.WriteByte(offset, Ord(OPCode.DIV_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and
          (a2.xFound xor a2.rFound) then
        begin
          // DIV R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.DIV_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.DIV_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(True);
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
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // MOD R, X
          Ram.WriteByte(offset, Ord(OPCode.MOD_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and (a2.valid) and
          (a2.xFound xor a2.rFound) then
        begin
          // MOD R, [A]
          if a2.R = RegisterIndex.INVALID then
          begin
            // A = X
            Ram.WriteByte(offset, Ord(OPCode.MOD_R_ADDR_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, word(a2.x));
            rBytesWritten := 4;
            exit(True);
          end
          else
          begin
            // A = R
            Ram.WriteByte(offset, Ord(OPCode.MOD_R_ADDR_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(a2.R));
            rBytesWritten := 3;
            exit(True);
          end;
          exit(True);
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
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteByte(offset + 2, Ord(r2));
          rBytesWritten := 3;
          exit(True);
        end
        else
        if (r1 <> RegisterIndex.INVALID) and TryParseIntOrLabel(operands.op2,
          n2, offset + 2) then
        begin
          // CMP R, X
          Ram.WriteByte(offset, Ord(OPCode.CMP_R_X));
          Ram.WriteByte(offset + 1, Ord(r1));
          Ram.WriteWord(offset + 2, n2);
          rBytesWritten := 4;
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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

    'JZ', 'JE': // 2
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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

    'JNZ', 'JNE': // 2
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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

    'JK': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JK R
          Ram.WriteByte(offset, Ord(OPCode.JK_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
        begin
          // JK X
          Ram.WriteByte(offset, Ord(OPCode.JK_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JK LABEL
          Ram.WriteByte(offset, Ord(OPCode.JK_X));
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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

    'JNK': // 2
    begin
      if operands.Count = 1 then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // JNK R
          Ram.WriteByte(offset, Ord(OPCode.JNK_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
        begin
          // JNK X
          Ram.WriteByte(offset, Ord(OPCode.JNK_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
        begin
          // JNK LABEL
          Ram.WriteByte(offset, Ord(OPCode.JNK_X));
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
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
          m_labelResolveList.Add(CrTLabelUse(UpperCase(operands.op1), offset + 1, line));
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
        rBytesWritten := 1;
        exit(True);
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
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryParseIntOrLabel(operands.op1, n1, offset + 1) then
        begin
          // PUSH X
          Ram.WriteByte(offset, Ord(OPCode.PUSH_X));
          Ram.WriteWord(offset + 1, n1);
          rBytesWritten := 3;
          exit(True);
        end
        else
          // restliche Kombinationen
        begin
          // keine passenden Operanden
          ReportInvalidOperands();
          exit(False);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;

    'POP': // 2
    begin
      if operands.Count = 0 then
      begin
        // POP
        Ram.WriteByte(offset, Ord(OPCode.POP));
        rBytesWritten := 1;
        exit(True);
      end
      else
      begin
        if (operands.Count = 1) then
        begin
          if (r1 <> RegisterIndex.INVALID) then
          begin
            // POP R
            Ram.WriteByte(offset, Ord(POP_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            rBytesWritten := 2;
            exit(True);
          end
          else
          begin
            // keine passenden Operatoren
            ReportInvalidOperands();
            exit(False);
          end;
        end
        else
        begin
          ReportOPCountError(1);
          exit(False);
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
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
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
      end;
    end;

    'AND': // 4
    begin
      if (operands.Count = 2) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          if TryParseIntOrLabel(operands.op2, n2, offset + 2) then
          begin
            // AND R, X
            Ram.WriteByte(offset, Ord(OPCode.AND_R_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, n2);
            rBytesWritten := 4;
            exit(True);
          end
          else
          if (r2 <> RegisterIndex.INVALID) then
          begin
            // AND R, R
            Ram.WriteByte(offset, Ord(OPCode.AND_R_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(r2));
            rBytesWritten := 3;
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
              Ram.WriteByte(offset + 1, Ord(r1));
              Ram.WriteWord(offset + 2, a2.x);
              rBytesWritten := 4;
              exit(True);
            end
            else
            if a2.rFound and (not a2.xFound) then
            begin
              // A = R
              Ram.WriteByte(offset, Ord(OPCode.AND_R_ADDR_R));
              Ram.WriteByte(offset + 1, Ord(r1));
              Ram.WriteByte(offset + 2, Ord(a2.R));
              rBytesWritten := 3;
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
          if TryParseIntOrLabel(operands.op2, n2, offset + 2) then
          begin
            // OR R, X
            Ram.WriteByte(offset, Ord(OPCode.OR_R_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, n2);
            rBytesWritten := 4;
            exit(True);
          end
          else
          if (r2 <> RegisterIndex.INVALID) then
          begin
            // OR R, R
            Ram.WriteByte(offset, Ord(OPCode.OR_R_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(r2));
            rBytesWritten := 3;
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
              Ram.WriteByte(offset + 1, Ord(r1));
              Ram.WriteWord(offset + 2, a2.x);
              rBytesWritten := 4;
              exit(True);
            end
            else
            if a2.rFound and (not a2.xFound) then
            begin
              // A = R
              Ram.WriteByte(offset, Ord(OPCode.OR_R_ADDR_R));
              Ram.WriteByte(offset + 1, Ord(r1));
              Ram.WriteByte(offset + 2, Ord(a2.R));
              rBytesWritten := 3;
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
          if TryParseIntOrLabel(operands.op2, n2, offset + 2) then
          begin
            // XOR R, X
            Ram.WriteByte(offset, Ord(OPCode.XOR_R_X));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteWord(offset + 2, n2);
            rBytesWritten := 4;
            exit(True);
          end
          else
          if (r2 <> RegisterIndex.INVALID) then
          begin
            // XOR R, R
            Ram.WriteByte(offset, Ord(OPCode.XOR_R_R));
            Ram.WriteByte(offset + 1, Ord(r1));
            Ram.WriteByte(offset + 2, Ord(r2));
            rBytesWritten := 3;
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
              Ram.WriteByte(offset + 1, Ord(r1));
              Ram.WriteWord(offset + 2, a2.x);
              rBytesWritten := 4;
              exit(True);
            end
            else
            if a2.rFound and (not a2.xFound) then
            begin
              // A = R
              Ram.WriteByte(offset, Ord(OPCode.XOR_R_ADDR_R));
              Ram.WriteByte(offset + 1, Ord(r1));
              Ram.WriteByte(offset + 2, Ord(a2.R));
              rBytesWritten := 3;
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

    'IN':  // 1
    begin
      if (operands.Count = 1) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          Ram.WriteByte(offset, Ord(OPCode.IN_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
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
      end;
    end;

    'OUT': // 2
    begin
      if (operands.Count = 1) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          // OUT R
          Ram.WriteByte(offset, Ord(OPCode.OUT_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
          exit(True);
        end
        else
        if TryParseIntOnly(operands.op1, n1) then
        begin
          // OUT X (X : 1 byte)
          Ram.WriteByte(offset, Ord(OPCode.OUT_X));
          Ram.WriteByte(offset + 1, n1);
          rBytesWritten := 2;
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
      end;
    end;

    'INC': // 1
    begin
      if (operands.Count = 1) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          Ram.WriteByte(offset, Ord(OPCode.INC_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
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
      end;
    end;

    'DEC': // 1
    begin
      if (operands.Count = 1) then
      begin
        if (r1 <> RegisterIndex.INVALID) then
        begin
          Ram.WriteByte(offset, Ord(OPCode.DEC_R));
          Ram.WriteByte(offset + 1, Ord(r1));
          rBytesWritten := 2;
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
      end;
    end;

    'CKB': // 1
    begin
      if (operands.Count = 0) then
      begin
        Ram.WriteByte(offset, Ord(OPCode.CKB));
        rBytesWritten := 1;
        exit(True);
      end
      else
      begin
        ReportOPCountError(0);
        exit(False);
      end;
    end;

    'DB': // 1
    begin
      if (operands.Count >= 1) then
      begin
        dbBytes := GetAllOperandsAsBytes(operandsString);
        if dbBytes = nil then
        begin
          // Fehler
          ReportInvalidOperands();
          exit(False);
        end
        else
        begin
          rBytesWritten := 0;
          for i := 0 to dbBytes.Count - 1 do
          begin
            Ram.WriteByte(offset + i, dbBytes[i]);
            Inc(rBytesWritten);
          end;
          exit(True);
        end;
      end
      else
      begin
        ReportOPCountError(1);
        exit(False);
      end;
    end;


    'ORG': // Pseudo instruction
    begin
      if (operands.Count = 1) then
      begin
        if TryParseIntOnly(operands.op1, n1) then
        begin
          offset := n1;
          rBytesWritten := 0;
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
      end;
    end;

    else
    begin
      // Unbekannte Instruktion
      rBytesWritten := 0;
      rErrorString := 'Unknown instruction "' + instruction + '".';
      exit(False);
    end;
  end;
  Result := False;
end;

function TCompiler.TryParseIntBase(s: string; out i: integer;
  base: TNumberInputMode): boolean;
var
  o: integer;
begin
  if base = TNumberInputMode.Hexadecimal then
  begin
    Result := TryStrToInt('$' + s, o);
  end
  else
    Result := TryStrToInt(s, o);

  i := o;
end;

function IndexOfLabelName(var labelMap: TLabelMap; labelName: string): integer;
var
  i: integer;
begin
  for i := 0 to (labelMap.Count - 1) do
  begin
    if labelMap.Keys[i] = labelName then
    begin
      exit(i);
    end;
  end;
  exit(-1);
end;

procedure TCompiler.Compile(input: string);
var
  cpos, len, zlen, zNr, commentpos: cardinal;
  zeile: string;
  inst: string;
  tLabelName: string;
  commandLines: TCommandLineList;
  i: cardinal;

  labelTable: TLabelMap;
  opString: string;
  errString: string;
  bytepos: word;
  rwritten: word;

  procedure ReportError(Text: string; line: cardinal);
  begin
    raise TCompilerException.Create('Error at line ' + IntToStr(line) +
      ':'#13#13 + Text);
  end;

  {
   Sucht aus der labelResolveList alle Benutzungen heraus und setzt die
     entsprechenden Adressen in den Speicher.
  }
  procedure ResolveLabelAddresses();
  var
    item: TLabelUse;
    index: integer;
  begin
    i := 0;
    while i < cardinal(m_labelResolveList.Count) do
    begin
      item := m_labelResolveList[i];
      index := IndexOfLabelName(labelTable, item.labelName);
      if index = -1 then
      begin
        // Label nicht gefunden
        ReportError('Label "' + item.labelName + '" not found.', item.line);
      end
      else
      begin
        // Label gefunden. Schreibe Sprungadresse in RAM.
        if item.isNegative then
        begin
          Ram.WriteWord(item.addrRAM, -labelTable.Data[index]);
        end
        else
          Ram.WriteWord(item.addrRAM, labelTable.Data[index]);
      end;
      Inc(i);
    end;
  end;

begin
  warnings.Clear;
  commandLines := TCommandLineList.Create;
  labelTable := TLabelMap.Create;
  m_labelResolveList := TLabelResolveList.Create;

  CodePosMap.Clear;
  CodeLineAddrMap.Clear;

  cpos := 0;
  zNr := 1;    // Zeilennummer
  len := Length(input);
  while cpos < len do
  begin
    // VORSICHT! Kein Mensch weiß warum, aber Delphi indiziert Strings ab 1, nicht 0!
    zlen := PosEx(#10, input, 1 + cpos);
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
      commandLines.Add(CrTCodeLineNr(zeile, zNr));

    cpos += zlen + 1; // wegen \n
    Inc(zNr);
  end;

  bytepos := 0;
  rwritten := 0;
  i := 0;


  while i < cardinal(commandLines.Count) do
  begin
    errString := EmptyStr;
    inst := ExtractInstructionString(commandLines[i].line);
    opString := ExtractOperandsString(commandLines[i].line);
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
          ReportError('Empty label name not allowed.', commandLines[i].nr);
        end
        else
        begin
          if labelTable.IndexOf(tLabelName) = -1 then
          begin
            // Label noch nicht vorhanden, alles gut
            labelTable.Add(tLabelName, bytepos);
          end
          else
          begin
            // Label-Duplikat
            ReportError('Duplicate label "' + tLabelName + '".', commandLines[i].nr);
          end;
        end;
      end
      else
      begin
        // Nach Label-Deklaration steht noch was, das soll nicht sein.
        ReportError('Text after label declaration.', commandLines[i].nr);
      end;
      rwritten := 0;
    end
    else
    begin
      CodePosMap.Add(bytepos, commandLines[i].nr);
      CodeLineAddrMap.Add(commandLines[i].nr, bytepos);
      // kein Label, Befehl in RAM schreiben.
      if not WriteInstrucitonLineToRAM(inst, opString, bytepos,
        commandLines[i].nr, rwritten, errString) then
      begin
        ReportError(errString, commandLines[i].nr);
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

function TCompiler.GetWarnings: TStringList;
begin
  Result := warnings;
end;

function TCompiler.GetCodePosition(addr: word): cardinal;
var
  i: integer;
begin
  if CodePosMap.Find(addr, i) then
  begin
    exit(CodePosMap.Data[i]);
  end
  else
  begin
    Result := 0;
  end;
end;

function TCompiler.GetCodeAddrOfLine(line: Cardinal): Word;
var
  i: integer;
begin
  if CodeLineAddrMap.Find(line, i) then
  begin
    exit(CodeLineAddrMap.Data[i]);
  end
  else
  begin
    Result := 0;
  end;
end;

end.
