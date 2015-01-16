unit uTypen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  RegisterIndex = (AX, BX, CX, DX,
    AL, BL, CL, DL,
    AH, BH, CH, DH,
    BP, SP, IP, FLAGS,

    {
     Wird vom Compiler dazu genutzt, ungültige Register-
     Eingaben zu identifizieren.
    }
    INVALID);

type
  TRegRecord = record
    AX: word;
    BX: word;
    CX: word;
    DX: word;

    BP: word;
    SP: word;
    IP: word;

    FLAGS: word;
  end;

  type TFlags = (O=2048,S=128,Z=64);

implementation

end.
