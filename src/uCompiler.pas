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
   Ausnahmen: Fehlermeldungen.
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
      offset: word; line: cardinal; var labelResolveList: TLabelResolveList;
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

// ======================= TCompiler functions =================================

function TCompiler.WriteInstrucitonLineToRAM(instruction, operandsString: string;
  offset: word; line: cardinal; var labelResolveList: TLabelResolveList;
  var rBytesWritten: word; var rErrorString: string): boolean;
var
  operands: TOperands;
  r1: RegisterIndex;
  r2: RegisterIndex;
  n1, n2: integer;

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

  case instruction of
    'ADD':
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
        end;
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
    'SUB':
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
        end;
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
    'JMP':
    begin
      if operands.Count = 1 then
      begin
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
    'MOV':
    begin
      if operands.Count = 2 then
      begin
        if (r1 <> RegisterIndex.INVALID) and (r2 <> RegisterIndex.INVALID) then
        begin
          //MOV R, R
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
          // Hier andere Kombinationen von Operanden
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
    'PUSH':
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
    'POP':
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
    'NOT':
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
