unit Compiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RAM;

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

end.

