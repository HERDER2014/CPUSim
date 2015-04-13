;Ausgabe von db
;Niklas 02/27/2015
;die Adresse des Beginns der Ausgabe ist gepusht
jmp begin
var1:;Variablen speichern
db "Apfel", 0
var2:
db " Banane", 0
begin:
push var1;Adresse der ersten Variable pushen
call db_Ausgabe;Ausgabe aufrufen
pop
push var2
call db_Ausgabe
pop
end

db_Ausgabe:
  push BP
  mov BP, SP

  mov ax, [BP + 5];Adresse bekommen
  dbAusgabe:
  movb bl, [ax];Byte an Adresse in bl schreiben
  cmp bl, 0;Wenn die Ausgabe beendet ist (das Byte 0 hat im Ascii-Code kein Zeichen,
  jz dbaEnde;weil es immer das Ende der Variable kennzeichnet
  out bl;das Zeichen ausgeben
  inc ax;nächste Adresse ausgeben
  jmp dbAusgabe
  dbAEnde:

  mov SP, BP
  pop BP
ret
