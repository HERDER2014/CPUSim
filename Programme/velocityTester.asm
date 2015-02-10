; This Program can be used to
; determine the maximum velocity
; of the simulation. The total
; count of executed OP-Codes is
; 33555203. ((2*16^4+3)*16^2+3)
;actual executed: 33423617

MOV AX,FFFF
MOV BX,FF
start:
SUB AX,01
JNZ start
MOV AX,FFFF
SUB BX,01
JNZ start
END
