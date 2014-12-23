{
 Übergangsunit, um einige Befehle zu identifizieren.
}
unit uOPCodes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  OPCode = (
    // ADD R, R
    ADD_R_R,
    // ADD R, X
    ADD_R_X,
    // SUB R, R
    SUB_R_R,
    // SUB R, X
    SUB_R_X,
    // JMP X
    JMP_ADDR,
    // MOV R, R
    MOV_R_R,
    // MOV R, X
    MOV_R_X,
    // PUSH R
    PUSH_R,
    // PUSH X
    PUSH_X,
    // POP R
    POP_R,
    // POP
    POP,
    // NOT R
    NOT_R
    );

implementation

end.

