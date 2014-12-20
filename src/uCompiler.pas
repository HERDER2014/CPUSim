unit uCompiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, fgl, SysUtils, strutils, strings, Dialogs, uRAM, uAdvancedRecords;

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
  {_____________________
   COMPILER-Klasse
   Nicht komplett funktionsfähig. Compile() wird u.U. Meldungen anzeigen.
  }
  TCompiler = class
  private
    var Ram : TRAM;

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
  end;

implementation

constructor TCompiler.Create(var r: TRAM);
begin
  Ram := r;
end;

{
 Liefert nur die Anweisung aus einer Codezeile in GROSSBUCHSTABEN.
 Eine Labelzeile wird vollständig zurückgegeben.

 Bsp.: "add al, 4" => "ADD", "pop" => "POP"
}
function ExtractInstructionString(line: string): string;
var
  i: cardinal;
begin
  i := Pos(' ', line);
  if i = 0 then
    i := Length(line)
  else
    Dec(i);
  Result := UpperCase(Copy(line, 1, i));
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

 Schreibt die Instruktion mit ihren Operanden in den RAM.
 Gibt TRUE zurück, wenn die Eingaben in instruction und operands gültig sind.

 Beispiel: Eingabezeile          "ADD   AL, BL"

 instruction: Instruktion; bspw. "ADD"
 operands: Operanden; bspw.            "AL, BL"
 offset: gibt die Startposition zum Schreiben in den RAM an.
 var rBytesWritten: Wenn TRUE zurückgegeben wurde, enthält nach Ausführung die Anzahl an Bytes, die in den RAM geschrieben wurden.

}
function WriteInstrucitonLineToRAM(instruction, operands: string;
  offset: word; var labelResolveList: TLabelResolveList;
  var rBytesWritten: word): boolean;
begin
  Result := True;
  rBytesWritten := 0;
  case instruction of
    'ADD':
    begin
      rBytesWritten := 3;
      exit;
    end;
    'JMP':
    begin
      rBytesWritten := 3;
      exit;
    end;
    'MOV':
    begin
      rBytesWritten := 3;
      exit;
    end;
    else
    begin
      rBytesWritten := 0;
      exit(False);
    end;
  end;
  Result := False;
end;

procedure TCompiler.Compile(input: string);
var
  offset, cpos, len, zlen, zNr, commentpos: cardinal;
  zeile: string;
  inst: string;
  temps: string;
  zeilenende: TSysCharSet;
  befehleDict: TCommandLineList;
  i: cardinal;

  labelDict: TLabelMap;
  labelResolveList: TLabelResolveList;
  bytepos: word;
  rwritten: word;
begin
  offset := 0;
  cpos := 0;
  zNr := 1;
  befehleDict := TCommandLineList.Create;
  len := strlen(PChar(input));
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
    commentpos := Pos(';', zeile);
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
  rwritten:=0;
  i := 0;

  while i < befehleDict.Count do
  begin
    //ShowMessage('---'#13'Zeile '+IntToStr(befehleDict[i].nr)+' ...');
    inst := ExtractInstructionString(befehleDict[i].line);
    if RightStr(inst, 1) = ':' then
    begin
      // Letztes Zeichen ist ':' => Zeile ist ein Label.
      // Es ist also keine weitere Verarbeitung nötig, die Adresse des Labels
      //   muss lediglich gesichert werden.
      labelDict.Add(GetLabelName(inst), bytepos);
      ShowMessage('LABEL: "' + GetLabelName(inst) + '" in Zeile ' +
        IntToStr(befehleDict[i].nr));
    end
    else
    begin
      if not WriteInstrucitonLineToRAM(inst, 'bl, al', bytepos,
        labelResolveList, rwritten) then
      begin
        ShowMessage('ERROR at line ' + IntToStr(befehleDict[i].nr));
        exit;
      end;
    end;

    bytepos += rwritten;
    Inc(i);
  end;

  {
   Routinen zum Überprüfen und Ausgeben der Resultate.
  }
  i := 0;
  while i < labelDict.Count do
  begin
    temps := labelDict.Keys[i];
    ShowMessage('"' + temps + '" at address ' + IntToStr(labelDict.KeyData[temps]) + '.');
    Inc(i);
  end;
end;

function TCompiler.GetCodePosition(addr: cardinal): cardinal;
begin
  Raise EInvalidOperation.Create('GetCodePosition ist noch nicht implementiert.');
  Result:=0;
end;

end.
