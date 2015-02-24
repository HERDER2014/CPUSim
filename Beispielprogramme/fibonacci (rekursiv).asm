in ax
sub ax, 30
push ax
mov bx, 00
push bx
mov bx, 01
push bx
call apfel

apfel:
  push BP
  mov BP, SP

  mov cx, [BP+5]
  add cx, 30
  out cx
  sub cx, 30

  mov ax, [BP+7]
  sub ax, 01
  jz ende
  push ax
  
  mov bx, [BP+9]
 
  push cx
  add bx, cx
  push bx
  call apfel

  ende:
  mov SP, BP
  pop BP
  ret

end
