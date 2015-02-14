unit uRAM;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils;

type
  TRAMChangeCallback = procedure(addr: word) of object;

type

  { TRAM }

  TRAM = class
    constructor Create(size: word; vStart: word);

  var
    ChangeCallback: TRAMChangeCallback;

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

  { Vor.: RAM ist kreiert
    Effekt: -
    Ergebnis: Gibt Größe des RAM aus.
  }
    function GetSize: cardinal;

  { Vor.: RAM ist kreiert
    Effekt: -
    Ergebnis: Gibt die erste Adresse des V-RAMs aus.
  }
    function GetVRAMStart: cardinal;


  end;

type
  TCompilerException = class(Exception);

implementation

var
  ram: array of byte;
  size_RAM: word;
  cs: Trtlcriticalsection;
  vRamStart: word;

constructor TRAM.Create(size: word; vStart: word);
var
  i: word;
begin
  ChangeCallback := nil;
  SetLength(ram, size);
  for i := 0 to size - 1 do
    ram[i] := 0;
  size_RAM := size;
  initcriticalsection(cs);
  vRamStart:=vStart;
end;

function TRAM.ReadByte(addr: cardinal): byte;
begin
  if addr < size_RAM then
    Result := ram[addr]
  else
    raise TCompilerException.Create('Error: invalid RAM address');
end;

procedure TRAM.WriteByte(addr: cardinal; b: byte);
begin
  entercriticalsection(cs);
  try
    if addr < size_RAM then
      ram[addr] := b
    else
      raise TCompilerException.Create('Error: invalid RAM address');
  finally
    if ChangeCallback <> nil then
      ChangeCallback(addr);
    leavecriticalsection(cs);
  end;
end;

function TRAM.ReadWord(addr: cardinal): word;
begin
  if addr < (size_RAM - 1) then
    Result := ((ram[addr] * 256) + ram[addr + 1])
  else
    raise TCompilerException.Create('Error: invalid RAM address');
end;

procedure TRAM.WriteWord(addr: cardinal; w: word);
var
  x, sum: cardinal;
begin
  entercriticalsection(cs);
  try
    x := 0;
    if addr < (size_RAM - 1) then
    begin
      sum := (w mod 256);
      x := ((w - sum) div 256);
      ram[addr] := x;
      ram[addr + 1] := sum;
      if ChangeCallback <> nil then
      begin
        ChangeCallback(addr);
        ChangeCallback(addr+1);
      end;
    end
    else
      raise TCompilerException.Create('Error: invalid RAM address');
  finally
    leavecriticalsection(cs);
  end;
end;

function TRAM.GetSize: cardinal;
begin
  Result := size_RAM;
end;

function TRAM.GetVRAMStart: cardinal;
begin
  Result := vRamStart;
end;

end.
