;Mehrstellige Eingabe
;Niklas 02/24/2015
;Bestätigen durch 20, also Space
;Ergebnis steht in ax
call mehrstelligeEingabe
end
;--------------------------------------------
;Programm Anfang
mehrstelligeEingabe:
;initialisiert Register mit 0, damit keine Fehler auftreten
mov ax, 00
mov bx, 00
mov cx, 00
mov dx, 00
push BP
mov BP, SP
  msEinput:
  in ax ;Eingabe
  cmp ax, 20 ;wenn 'Space' (20) eingegeben wurde, ist die eingabe beendet
  jz msEcalc
  sub ax, 30 ;sonst als Zahl interpretieren, also $30 abziehen
  push ax    ;und pushen
  jmp msEinput

  msEcalc:
  mov ax, 00 ;ax initialisieren
  msELoop:
  cmp SP, BP ;wenn der Stack leer ist, wurde jede Eingabe bearbeitet
  jz msEend
  pop bx     ;nächste Stelle poppen

  ;dx ist der Zähler der Stellen, also 0 heißt, es ist die einser stelle, 1, zehnerstelle usw.
  ;damit die Stelle stimmt muss folgendes gerechnet werden: bx*10^dx, bx ist die ziffer und dx der zähler
  push dx ;dx speichern
  mov cx, 01 ;in cx steht der zu bx zu multiplizierende Faktor
  msEsum:       ;die Summe versinnbildlicht 10^dx
  cmp dx, 00
  jz msEsumEnd
  mul cx, 0A
  dec dx
  jmp msEsum
  msEsumEnd:
  pop dx ;dx wiederherstellen

  mul bx, cx ;in bx steht dann der entsprechende Wert der Ziffer
  add ax, bx ;zu ax hinzufügen

  inc dx ;zähler um eins erhöhen und neu anfangen
  jmp msELoop
  msEend:
mov SP, BP
pop BP
ret
