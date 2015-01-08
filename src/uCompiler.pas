unit uCompiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRAM;

type TCompiler = class
  public constructor Create(var r : TRAM);


   {
   Vor.: -
   Eff.: Das kompilierte Programm steht im RAM.
   Erg.: -
   Ausnahmen: Fehlermeldungen.
   }
  procedure Compile(input : String);


   {
   Vor.: Compile wurde ausgeführt.
   Eff.: -
   Erg.: Liefert die Position in der Eingabe, die an Adresse addr kompiliert wurde.
   }
  function GetCodePosition(addr : Cardinal) : Cardinal;
end;

implementation
  constructor TCompiler.Create(var r : TRAM);
  begin

  end;

  procedure TCompiler.Compile(input : String);
  begin

  end;

  function TCompiler.GetCodePosition(addr : Cardinal) : Cardinal;
  begin

  end;

end.

