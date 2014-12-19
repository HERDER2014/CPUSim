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

end;

implementation
   constructor TRAM.Create(size : Cardinal);
   begin

   end;
   function TRAM.ReadByte(addr : Cardinal) : Byte;
   begin

   end;
   procedure TRAM.WriteByte(addr : Cardinal; b : Byte);
   begin

   end;
   function TRAM.ReadWord(addr : Cardinal) : Word;
   begin

   end;
   procedure TRAM.WriteWord(addr : Cardinal; w : Word);
   begin

   end;

end.

