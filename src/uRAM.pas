unit uRAM;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils;

type TRAM = class
  constructor Create(size : Cardinal);

  { Vor.: addr < size
    Effekt: -
    Ergebnis: Liefert das Byte an Adresse addr.
  }
  function ReadByte(addr : Cardinal) : Byte;

  { Vor.: addr < size
    Effekt: -
    Ergebnis: Setzt das Byte an Adresse addr auf b.
  }
  procedure WriteByte(addr : Cardinal; b : Byte);

  { Vor.: addr < size-1
    Effekt: -
    Ergebnis: Liefert das Wort ab Adresse addr.
  }
  function ReadWord(addr : Cardinal) : Word;

  { Vor.: addr < size-1
    Effekt: -
    Ergebnis: Setzt das Wort ab Adresse addr auf w.
  }
  procedure WriteWord(addr : Cardinal; w : Word);

  { Vor.: RAM ist kreiert
    Effekt: -
    Ergebnis: Gibt Größe des RAM aus.
  }
  function GetSize : Cardinal;
end;

implementation
var ram : ARRAY OF Word;
var size_RAM : Cardinal;

   constructor TRAM.Create(size : Cardinal);
   begin
     SetLength(ram, size);
     size_RAM := size;
   end;

   function TRAM.ReadByte(addr : Cardinal) : Byte;
   begin
     if addr < size_RAM then result := ram[addr];
   end;

   procedure TRAM.WriteByte(addr : Cardinal; b : Byte);
   begin
     if addr < size_RAM then ram[addr] := b;
   end;

   function TRAM.ReadWord(addr : Cardinal) : Word;
   begin
     if addr < (size_RAM - 1) then result := ram[addr];
   end;

   procedure TRAM.WriteWord(addr : Cardinal; w : Word);
   begin
     if addr < (size_RAM - 1) then ram[addr] := w;
   end;

   function TRAM.GetSize : Cardinal;
   begin
     result := size_RAM;
   end;

end.
