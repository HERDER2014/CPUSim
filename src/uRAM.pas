unit uRAM;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, LazLogger;

type
  TRAM = class
    constructor Create(size: cardinal);

  { Vor.: addr < size
    Effekt: -
    Ergebnis: Liefert das Byte an Adresse addr.
  }

    function ReadByte(addr: cardinal): byte;

  { Vor.: addr < size
    Effekt: -
    Ergebnis: Setzt das Byte an Adresse addr auf b.
  }
    procedure WriteByte(addr: cardinal; b: byte);

  { Vor.: addr < size-1
    Effekt: -
    Ergebnis: Liefert das Wort ab Adresse addr.
  }
    function ReadWord(addr: cardinal): word;

  { Vor.: addr < size-1
    Effekt: -
    Ergebnis: Setzt das Wort ab Adresse addr auf w.
  }
    procedure WriteWord(addr: cardinal; w: word);

  end;

implementation

constructor TRAM.Create(size: cardinal);
begin

end;

function TRAM.ReadByte(addr: cardinal): byte;
begin

end;

procedure TRAM.WriteByte(addr: cardinal; b: byte);
begin
  //DebugLn('Writing byte at ' + IntToStr(addr) + ': "' + IntToStr(b) + '"');
end;

function TRAM.ReadWord(addr: cardinal): word;
begin

end;

procedure TRAM.WriteWord(addr: cardinal; w: word);
begin
  //DebugLn('Writing word at ' + IntToStr(addr) + ': "' + IntToStr(w) + '"');
end;

end.
