unit uCompiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils, strings, Dialogs, uRAM;

type
  TCompiler = class
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

end;

procedure TCompiler.Compile(input: string);
var
  offset, cpos, len, zlen, commentpos: cardinal;
  zeile: string;
  zeilenende: TSysCharSet;
  befehleL: TStringList;
  i : Cardinal;
begin
  offset := 0;
  cpos := 0;
  befehleL := TStringList.Create;
  len := strlen(PChar(input));
  while cpos < len do
  begin
    // VORSICHT! Kein Mensch weiß warum, aber Delphi indiziert Strings ab 1, nicht 0!
    zlen := PosEx(#13#10, input, 1 + cpos) - cpos - 1;
    zeile := Copy(input, cpos + 1, zlen);
    commentpos := Pos(';', zeile);
    if commentpos > 0 then
      zeile := Copy(zeile, 1, commentpos-1);
    zeile := Trim(zeile);
    befehleL.Add(zeile);
    cpos += zlen + 2; // wegen \r\n
  end;
  while i < befehleL.Count do
  begin
    ShowMessage(befehleL[i]);
    inc (i);
  end;
end;

function TCompiler.GetCodePosition(addr: cardinal): cardinal;
begin

end;

end.
