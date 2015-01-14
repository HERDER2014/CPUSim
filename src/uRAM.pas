unit uRAM;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, LazLogger, Dialogs;

type
  TRAM = class
  var
    logfile : File of Byte;
    log : TFileStream;

    constructor Create(size: cardinal);

    destructor Destroy; override;

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
  log := TFileStream.Create('ram.bin', fmCreate);
  log.Seek(0, TSeekOrigin.soBeginning);
  //AssignFile(logfile, 'ram.bin');
  //Rewrite(logfile);
end;

destructor TRAM.Destroy();
begin
  //CloseFile(logfile);
  log.Free;
  //log.Destroy;
end;

function TRAM.ReadByte(addr: cardinal): byte;
begin

end;

procedure TRAM.WriteByte(addr: cardinal; b: byte);
begin
  //ShowMessage('Writing byte ' + IntToStr(b) + ' at ' + IntToStr(addr));
  //DebugLn('Writing byte at ' + IntToStr(addr) + ': "' + IntToStr(b) + '"');
  //Seek(logfile, addr);
  //Write(logfile, b);
  log.Seek(addr, soBeginning);
  log.WriteByte(b);
end;

function TRAM.ReadWord(addr: cardinal): word;
begin

end;

procedure TRAM.WriteWord(addr: cardinal; w: word);
begin
  //ShowMessage('Writing word ' + IntToStr(w) + ' at ' + IntToStr(addr));
  //DebugLn('Writing word at ' + IntToStr(addr) + ': "' + IntToStr(w) + '"');
  //Seek(logfile, addr);
  //Write(logfile, w and 65280);
  //Write(logfile, w and 240);
  log.Seek(addr, soBeginning);
  log.WriteWord(w);
end;

end.
