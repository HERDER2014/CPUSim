unit uTypen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  RegisterIndex = (AX, BX, CX, DX,
    AL, BL, CL, DL,
    AH, BH, CH, DH,
    BP, SP, IP, VP,
    FLAGS,

    {
     Wird vom Compiler dazu genutzt, ungültige Register-
     Eingaben zu identifizieren.
    }
    INVALID);

type
  TRegRecord = record
    AX: Smallint;
    BX: Smallint;
    CX: Smallint;
    DX: Smallint;

    BP: word;
    SP: word;
    IP: word;
    VP: word;

    FLAGS: word;
  end;

  type TFlags = (O=2048,S=128,Z=64);


  type TBoolPointer = ^Boolean;
implementation

end.
