unit uRAM;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, Dialogs;

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
   var value : String ;
   begin
     InputQuery('RAM TEST', 'Gelesen wird Byte an Adresse ' + IntToStr(addr), value);
     result := StrToInt(value);
   end;
   procedure TRAM.WriteByte(addr : Cardinal; b : Byte);
   begin
     ShowMessage('Geschrieben wird an Adresse ' + IntToStr(addr) + ' das Byte ' + IntToStr(b));
   end;
   function TRAM.ReadWord(addr : Cardinal) : Word;
   var value : String ;
   begin
     InputQuery('RAM TEST', 'Gelesen wird Word an Adresse ' + IntToStr(addr), value);
     result := StrToInt(value);
   end;
   procedure TRAM.WriteWord(addr : Cardinal; w : Word);
   begin
     ShowMessage('Geschrieben wird an Adresse ' + IntToStr(addr) + ' das Word ' + IntToStr(w));
   end;

end.

