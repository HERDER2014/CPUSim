;Dezimale Zahlenausgabe (maximal 32767, wegen Registergröße)
;Niklas 2/11/2015
;die auszugebende Zahl ist gepusht:
push 7B
call mehrstelligeAusgabe
pop ;damit stack sauber ist
end
;-----------------------------------------------------
;Programmstart
mehrstelligeAusgabe:
push BP
mov BP, SP
  mov ax, [BP + 4]
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
