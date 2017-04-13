;#RAM: 1024
;#VRAM: 2000
;#CLOCK: 2
;#CLOCK_UNIT: kHz


; VRAM Size: 2000
; Taktung: 1 KHz

jmp start

spawnpoints:
db 1,0F, 5,80, 7,41, 5,b8, 2,16, 3,e0, 4,67, 5,7d, 6,b1, 2,8d,5,bf,6,83
db 2,a5,2,2d,2,d7,5,22,2,7c,0,66,0,35,6,13, 0, 0

snakepos:  ;pos, dir, len
db 0, 0

snakedir:
db 0, 1

snakelen:
db 5

queuepos:
db 0

randompos:
db 0, 0

gameovermessage:
db "GAME OVER", 0
db "Points: ", 0

start:

MOV AX,VP
ADD AX,7D0

initloop0:
  DEC AX
  MOVB [AX],20
  CMP AX,VP
JNZ initloop0

MOV AX, 4F
initloop1:
  MOV BX,AX
  ADD BX,VP
  MOVB [BX],23
  ADD BX, 780
  MOVB [BX],23
  DEC AX
JNS initloop1

MOV AX,780
initloop2:
  MOV BX,AX
  ADD BX,VP
  MOVB [BX],23
  ADD BX, 4F
  MOVB [BX],23
  SUB AX, 50
JNZ initloop2


MOV AX, VP   ; \ Start
ADD AX, 3E8  ; / Position
MOV [snakepos], AX

MOV AX, randompos
MOV AX, [AX]
MOV BX, spawnpoints
ADD AX,BX
MOV AX, [AX]
ADD AX, VP
MOVB [AX], 4F

loop:

  ;---- collision detection
  MOV AX, snakepos
  MOV AX, [AX]
  MOVB BL,[AX]
  CMP BL, 4F
  JNZ noCoin

  ;---- coin
  coin:
  MOV BX, randompos
  MOV AX, [BX]
  ADD AX, 02
  MOV [BX],AX
  MOV BX, spawnpoints
  ADD AX,BX
  MOV AX, [AX]
  CMP AX, 00
  JZ newcoin
  ADD AX, VP
  MOVB [AX], 4F

  MOV BX, snakelen
  MOVB AL, [BX]
  INC AL
  MOVB [BX],AL

  JMP afterCoin

  newcoin:
  MOV BX, randompos
  MOV [BX], 0
  JMP coin

  ;---- wall
  noCoin:

  CMP BL, 20
  JNZ ende

  afterCoin:
  ; Snake queue


  ;---- snake saving
  MOV AX,queuepos
  MOVB AX, [AX]
  MOV BX, snakepos
  MOV BX, [BX]
  ADD AX, snakearraypos
  MOV [AX], BX

  ;---- snake removal
  MOV AX, queuepos
  MOVB AL, [AX]
  MOV BX, snakelen
  MOVB BL, [BX]
  SUB AL, BL
  SUB AL, BL
  ADD AX, snakearraypos
  MOV CX, [AX]
  MOVB [CX], 20

  ;---- snake saving queue update
  MOV BX, queuepos
  MOVB AL,[BX]
  ADD AL, 02
  MOVB [BX], AL

  ;---- Display
  MOV AX, snakepos
  MOV AX, [AX]
  MOVB [AX],2B

  ;---- Movement
  MOV BX, snakedir
  MOV BX, [BX]
  ADD AX, BX    ; Movement
  MOV CX, snakepos
  MOV [CX], AX


  ;---- slow down loop
  MOV AX,F0
  wloop:
    DEC AX
  JNZ wloop

  ;---- keyboard input
  jnk KeyEnd

  in AX

  cmp AX,57
  jz up

  cmp AX,77
  jz up

  cmp AX,41
  jz left

  cmp AX,61
  jz left

  cmp AX,53
  jz down

  cmp AX,73
  jz down

  cmp AX,44
  jz right

  cmp AX,64
  jz right

  KeyEnd:

jmp loop
;================

left:
mov CX, snakedir
mov [CX], FFFF
jmp KeyEnd

right:
mov CX, snakedir
mov [CX], 1
jmp KeyEnd

up:
mov CX, snakedir
mov [CX], FFB0
jmp KeyEnd

down:
mov CX, snakedir
mov [CX], 50
jmp KeyEnd

ende:

ADD VP, AA
MOV CX, VP
MOV AX,gameovermessage
endloop1:
MOVB BX,[AX]
INC AX
CMP BX,0
JZ endloop2start
OUT BX
jmp endloop1

endloop2start:
MOV VP, CX
ADD VP, 50

endloop2:
MOVB BX,[AX]
INC AX
CMP BX,0
JZ punktzahlausgabe
OUT BX
jmp endloop2

punktzahlausgabe:

MOV AX,snakelen
MOVB AX,[AX]
SUB AX,4
PUSH AX
CALL mehrstelligeAusgabe
POP

end


mehrstelligeAusgabe:
push BP
mov BP, SP
  mov ax, [BP + 4]
  ;zahl aufteilen
  msAaufteilen:
  cmp ax, 0A
  js msAausgabe1  ;wenn ax kleiner als 10 ist, ax pushen und die Zahl ausgeben
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

snakearraypos:
;keep 256 bytes free
