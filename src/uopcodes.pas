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
    // MOV R, X
    MOV_R_X = 1,
    // MOV R, [R]
    MOV_R_ADDR_R = 2,
    // MOV R, [X]
    MOV_R_ADDR_X = 3,
    // MOV [R], R
    MOV_ADDR_R_R = 4,
    // MOV [X], R
    MOV_ADDR_X_R = 5,
    // MOV R, R
    MOV_R_R = 6,
    // MOV R, [R+X]
    MOV_R_ADDR_RX = 7,
    // MOV [R+X], R
    MOV_ADDR_RX_R = 8,

    // ADD R, X
    ADD_R_X = 9,
    // ADD R, [R]
    ADD_R_ADDR_R = 10,
    // ADD R, [X]
    ADD_R_ADDR_X = 11,
    // ADD R, R
    ADD_R_R = 12,

    // SUB R, X
    SUB_R_X = 13,
    // SUB R, [X]
    SUB_R_ADDR_X = 14,
    // SUB R, [R]
    SUB_R_ADDR_R = 15,
    // SUB R, R
    SUB_R_R = 16,

    // MUL R, X
    MUL_R_X = 17,
    // MUL R, [X]
    MUL_R_ADDR_X = 18,
    // MUL R, [R]
    MUL_R_ADDR_R = 19,
    // MUL R, R
    MUL_R_R = 20,

    // DIV R, X
    DIV_R_X = 21,
    // DIV R, [X]
    DIV_R_ADDR_X = 22,
    // DIV R, [R]
    DIV_R_ADDR_R = 23,
    // DIV R, R
    DIV_R_R = 24,

    // MOD R, X
    MOD_R_X = 25,
    // MOD R, [X]
    MOD_R_ADDR_X = 26,
    // MOD R, [R]
    MOD_R_ADDR_R = 27,
    // MOD R, R
    MOD_R_R = 28,

    // CMP R, X
    CMP_R_X = 29,

    // JMP X
    JMP_ADDR = 31,
    // PUSH R
    PUSH_R = 46,
    // PUSH X
    PUSH_X = 47,
    // POP
    POP = 48,
    // POP R
    POP_R = 49,
    // NOT R
    NOT_R = 50
    );

implementation

end.

