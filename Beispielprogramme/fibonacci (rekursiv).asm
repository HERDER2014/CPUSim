;fibonacci
jmp begin
var1:
db "F(", 0
var2:
db ")=", 0
begin:
;F( ausgeben
in bx;fibonacci von
;'ax' ausgeben
;)= ausgeben
sub bx,30
push bx
call fibonacci
pop
push ax
call mehrstelligeAusgabe
pop
end




;Voraussetzung: dx ist 0
;Parameter von was ist gepusht
;Ergebnis steht in ax
fibonacci:
push BP
mov BP, SP

  mov bx, [BP + 5]
  cmp bx, 3
  js ende1

  dec bx
  push bx
  call fibonacci
  pop bx
  dec bx
  push bx
  call fibonacci
  pop
  jmp ende2

  ende1:
  add ax, 1
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
  aufteilen:
  cmp ax, 0A
  js asg1  ;wenn ax kleiner als 10 ist, ax pushen und die Zahl ausgeben
  mov bx, ax   ;sonst ax mod 10 zum errechnen der einser stelle
  mod bx, 0A
  push bx      ;diese pushen
  sub ax, bx
  div ax, 0A   ;diese "eintfernen" und neu aufteilen
  jmp aufteilen

  ;gepushte Zahl ausgeben
  asg1:
  push ax      ;ax pushen, um alles auszugeben
  asg:
  cmp SP, BP   ;wenn der stack leer ist, nichts mehr ausgeben
  jz ende
  pop ax       ;in ax poppen
  add ax, 30
  out ax
  jmp asg

  ende:
mov SP, BP
pop BP
ret
