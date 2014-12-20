{
 Diese Unit existiert nur, um den Records einen Equal-Operator zu
   geben, sodass sie in Collections verwendet werden können. Danke, Lazarus. Danke.
}
unit uAdvancedRecords;

// Hier der Grund: Compileranweisung "$mode delphi" für Operatoren.
{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils;

type
  {
   Enthält eine Zeile und ihre Nummer.
  }
  TCodeLineNr = record
    line: string;
    nr: cardinal;
    class operator Equal(l1, l2: TCodeLineNr): boolean;
  end;

type
  {
   Enthält Informationen über die Benutzung eines Labels im Code.
   Wird benutzt, um nach dem Parsen die richtigen Positionen für Labels
     zu übernehmen.
  }
  TLabelUse = record
    {
     Name des Labels.
    }
    labelName: string;
    {
     Adresse der Verwendung des Labels (Adressen sind 2 Byte groß)
    }
    addrRAM: word;
    class operator Equal(l1, l2: TLabelUse): boolean;
  end;

function CrTCodeLineNr(line: string; nr: cardinal): TCodeLineNr;

implementation

function CrTCodeLineNr(line: string; nr: cardinal): TCodeLineNr;
var
  r: TCodeLineNr;
begin
  r.line := line;
  r.nr := nr;
  Result := r;
end;

class operator TCodeLineNr.Equal(l1, l2: TCodeLineNr): boolean;
begin
  Result := l1.line = l2.line;
end;

class operator TLabelUse.Equal(l1, l2: TLabelUse): boolean;
begin
  // an einer Stelle im RAM wird auch nur auf ein einziges Label verwiesen.
  Result := l1.addrRAM = l2.addrRAM;
end;

end.

