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

type
  TCompilerException = class(Exception);

implementation
var ram : ARRAY OF Byte;
var size_RAM : Cardinal;
var cs : Trtlcriticalsection;

   constructor TRAM.Create(size : Cardinal);
   var
     i: Integer;
   begin
     SetLength(ram, size);
     for i:= 0 to size-1 do
         ram[i]:= 0;
     size_RAM := size;
     initcriticalsection(cs);
   end;

   function TRAM.ReadByte(addr : Cardinal) : Byte;
   begin
     if addr < size_RAM then result := ram[addr]
     else raise TCompilerException.Create('Error: invalid RAM address');
   end;

   procedure TRAM.WriteByte(addr : Cardinal; b : Byte);
   begin
     entercriticalsection(cs);
     try
       if addr < size_RAM then ram[addr] := b
       else raise TCompilerException.Create('Error: invalid RAM address');
     finally
       leavecriticalsection(cs);
     end;
   end;

   function TRAM.ReadWord(addr : Cardinal) : Word;
   begin
     if addr < (size_RAM - 1) then result := ((ram[addr]*256)+ram[addr+1])
     else raise TCompilerException.Create('Error: invalid RAM address');
   end;

   procedure TRAM.WriteWord(addr : Cardinal; w : Word);
   var x, sum : Cardinal;
   begin
     entercriticalsection(cs);
     try
       x := 0;
       if addr < (size_RAM - 1) then
       begin
         sum := (w mod 256);
         x := ((w-sum) div 256);
         ram[addr] := x;
         ram[addr+1] := sum;
       end
       else raise TCompilerException.Create('Error: invalid RAM address');
     finally
       leavecriticalsection(cs);
     end;
   end;

   function TRAM.GetSize : Cardinal;
   begin
     result := size_RAM;
   end;

end.
