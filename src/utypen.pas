unit UTypen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

   type RegisterIndex = (AX, BX, CX, DX, BP, SP);

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

