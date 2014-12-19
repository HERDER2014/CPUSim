unit uTypen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

   type RegisterIndex = (AX, BX, CX, DX,
                         AL, BL, CL, DL,
                         AH, BH, CH, DH,
                         BP, SP, IP, FLAGS);

   type TRegRecord = Record
      AX : Word;
      BX : Word;
      CX : Word;
      DX : Word;

      BP : Word;
      SP : Word;
      IP : Word;

      FLAGS : Word;
   end;

implementation

end.

