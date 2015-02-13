;Dezimale Zahlenausgabe
;Niklas 2/11/2015
;in ax steht die auszugebende Zahl
;[dx] ist mit [VP] zu ersetzen, bzw 'out' benutzen
mov ax, 7B
mov dx, F0
;Programmstart

;zahl aufteilen
aufteilen:
cmp ax, 0A
js ausgabe1  ;wenn ax kleiner als 10 ist, ax pushen und die Zahl ausgeben
mov bx, ax   ;sonst ax mod 10 zum errechnen der einser stelle
mod bx, 0A
push bx      ;diese pushen
sub ax, bx
div ax, 0A   ;diese "eintfernen" und neu aufteilen
jmp aufteilen

;gepushte Zahl ausgeben
ausgabe1:
push ax      ;ax pushen, um alles auszugeben
ausgabe:
cmp SP, BP   ;wenn der stack leer ist, nichts mehr ausgeben
jz ende
pop ax       ;in ax poppen
mov [dx], ax ;und dann ausgeben
inc dx       ;weitere Ausgabe-->beides mit out ersetzen
jmp ausgabe

ende:
end
