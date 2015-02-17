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
    // END
    _END = 0,
    // MOV R, X
    MOV_R_X,
    // MOV R, [R]
    MOV_R_ADDR_R,
    // MOV R, [X]
    MOV_R_ADDR_X,
    // MOV [R], R
    MOV_ADDR_R_R,
    // MOV [R], X
    MOV_ADDR_R_X,
    // MOV [X], R
    MOV_ADDR_X_R,
    // MOV [X], X
    MOV_ADDR_X_X,
    // MOV R, R
    MOV_R_R,
    // MOV R, [R+X]
    MOV_R_ADDR_RX,
    // MOV [R+X], R
    MOV_ADDR_RX_R,
    // MOV [R+X], X
    MOV_ADDR_RX_X,

    // MOVW = MOV

    // MOVB R, X
    MOVB_R_X,
    // MOVB R, [R]
    MOVB_R_ADDR_R,
    // MOVB R, [X]
    MOVB_R_ADDR_X,
    // MOVB [R], R
    MOVB_ADDR_R_R,
    // MOVB [R], X
    MOVB_ADDR_R_X,
    // MOVB [X], R
    MOVB_ADDR_X_R,
    // MOVB [X], X
    MOVB_ADDR_X_X,
    // MOVB R, R
    MOVB_R_R,
    // MOVB R, [R+X]
    MOVB_R_ADDR_RX,
    // MOVB [R+X], R
    MOVB_ADDR_RX_R,
    // MOVB [R+X], X
    MOVB_ADDR_RX_X,

    // ADD R, X
    ADD_R_X,
    // ADD R, [R]
    ADD_R_ADDR_R,
    // ADD R, [X]
    ADD_R_ADDR_X,
    // ADD R, R
    ADD_R_R,

    // SUB R, X
    SUB_R_X,
    // SUB R, [X]
    SUB_R_ADDR_X,
    // SUB R, [R]
    SUB_R_ADDR_R,
    // SUB R, R
    SUB_R_R,

    // MUL R, X
    MUL_R_X,
    // MUL R, [X]
    MUL_R_ADDR_X,
    // MUL R, [R]
    MUL_R_ADDR_R,
    // MUL R, R
    MUL_R_R,

    // DIV R, X
    DIV_R_X,
    // DIV R, [X]
    DIV_R_ADDR_X,
    // DIV R, [R]
    DIV_R_ADDR_R,
    // DIV R, R
    DIV_R_R,

    // MOD R, X
    MOD_R_X,
    // MOD R, [X]
    MOD_R_ADDR_X,
    // MOD R, [R]
    MOD_R_ADDR_R,
    // MOD R, R
    MOD_R_R,

    // CMP R, X
    CMP_R_X,

    // JMP R
    JMP_R,
    // JMP X
    JMP_ADDR,

    // JS R
    JS_R,
    // JS X
    JS_X,
    // JZ R
    JZ_R,
    // JZ X
    JZ_X,
    // JO R
    JO_R,
    // JO X
    JO_X,
    // JNS R
    JNS_R,
    // JNS X
    JNS_X,
    // JNZ R
    JNZ_R,
    // JNZ X
    JNZ_X,

    // CALL X
    CALL_X,
    // CALL R
    CALL_R,

    // CMP R, R
    CMP_R_R,

    // RET
    RET,

    // PUSH R
    PUSH_R,
    // PUSH X
    PUSH_X,
    // POP
    POP,
    // POP R
    POP_R,
    // NOT R
    NOT_R,

    // AND R, X
    AND_R_X,
    // AND R, R
    AND_R_R,
    // OR R, X
    OR_R_X,
    // OR R, R
    OR_R_R,
    // XOR R, X
    XOR_R_X,
    // XOR R, R
    XOR_R_R,
    // JNO R
    JNO_R,
    // JNO X
    JNO_X,
    // AND R, [X]
    AND_R_ADDR_X,
    // AND R, [R]
    AND_R_ADDR_R,
    // OR R, [X]
    OR_R_ADDR_X,
    // OR R, [R]
    OR_R_ADDR_R,
    // XOR R, [X]
    XOR_R_ADDR_X,
    // XOR R, [R]
    XOR_R_ADDR_R,

    // IN R
    IN_R,

    // OUT X
    OUT_X,
    // OUT R
    OUT_R,

    // INC R
    INC_R,
    // DEC R
    DEC_R,

    // CKB
    CKB,

    // DB
    DB,

    //Leave this at the end:
    Count

    );

implementation

end.

