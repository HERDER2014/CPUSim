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
    // JMP X
    JMP_ADDR,
    // MOV R, R
    MOV_R_R);

implementation

end.

