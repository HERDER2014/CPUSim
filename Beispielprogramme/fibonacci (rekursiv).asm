;Fibonacci
;Niklas Schelten 02/24/2015
;berechnet F(X), wobei F die Fibonacci-Folge ist x elemnt n < 24 (nur 16bit register)
jmp begin
var1:
db "Fibonacci(", 0
var2:
db ")=", 0
begin:
;gibt F(X)=Y aus, wobei X die Eingabe und Y das Ergebnis von Fibonacci ist
push var1;Ausgabe von 'Fibonacci('
call db_Ausgabe
pop
call mehrstelligeEingabe;get X
push ax;Funktionsparameter (X) (vor db_Ausgabe pushen, weil dort ax verändert wird)
push var2;Ausgabe von ')='
call db_Ausgabe
pop
call fibonacci;Y berechnen
pop
push ax;Funktionsparameter (Y)
call mehrstelligeAusgabe;Y ausgeben
pop
end


;Parameter: F(X)
;Ergebnis steht in ax
fibonacci:
;init Register
mov ax, 00
mov bx, 00
mov cx, 00
mov dx, 00
fib:
push BP
mov BP, SP

  mov bx, [BP + 5];Parameter bekommen
  cmp bx, 3;F(2)=F(1)=1 ist definiert
  js ende1;also keine Berechnung, wenn X 1 oder 2 ist

  ;sonst gilt: F(X)=F(X-1)+F(X-2)
  dec bx;F(X-1)
  push bx
  call fib
  pop bx
  dec bx;F(X-2)
  push bx
  call fib
  pop
  jmp ende2

  ende1:
  add ax, 1;dem Ergebnis 1 hinzufügen
  ende2:
mov SP, BP
pop BP
ret

;Parameter: auszugebende Zahl gepusht
mehrstelligeAusgabe:
push BP
mov BP, SP
  mov ax, [BP + 5]
  ;zahl aufteilen
  msAaufteilen:
  cmp ax, 0A
  js msAausgabe1  ;wenn ax kleiner als 10 ist, ax pushen und die Zahl ausgeben
  mov bx, ax   ;sonst ax mod 10 zum errechnen der einser stelle
  mod bx, 0A
  push bx      ;diese pushen
  sub ax, bx
  div ax, 0A   ;diese "eintfernen" und neu aufteilen
  jmp msAaufteilen

  ;gepushte Zahl ausgeben
  msAausgabe1:
  push ax      ;ax pushen, um alles auszugeben
  msAausgabe:
  cmp SP, BP   ;wenn der stack leer ist, nichts mehr ausgeben
  jz msAende
  pop ax       ;in ax poppen
  add ax, 30
  out ax
  jmp msAausgabe

  msAende:
mov SP, BP
pop BP
ret

;Ergebnis steht in ax
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
  cmp ax, 30 ;Eingabe nur akzeptieren, wenn 0 oder größer
  js msEinput
  cmp ax, 3A ;Eingabe nur akzeptieren, wenn 9 oder kleiner
  jns msEinput
  out ax ;Ausgabe der Eingabe
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

;Parameter sind gepusht (Adresse der Auszugebenden Variable
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
