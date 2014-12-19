unit uCompiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils,strings, Dialogs, uRAM;


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
  offset, cpos, len, zlen: cardinal;
  zeile : String;
  zeilenende : TSysCharSet;
  befehleL : TStrings;
begin
  offset := 0;
  cpos := 0;
  zeilenende := [#13, #10];
  len := strlen(PChar(input));
  while cpos < len do
  begin
    zlen := PosEx('#13#10', input, cpos);
    zeile := Copy(); //ExtractSubstr(input, LongInt(cpos), zeilenende);
    zeile := str
  end;
end;

function TCompiler.GetCodePosition(addr: cardinal): cardinal;
begin

end;

end.
