;sector.asm
 
       include  'inc\macro.asm'
 
       org      0h ;first into memory
       use16
 
       push     cs
       pop      ax
       mov      ds,ax
       mov      es,ax
 
 
       mov      ax,87h ;номер прерывания
       mov      word bx,new_handler ;адрес обработчика
       call     hook ;\int\hook.asm
 
 
       DbgDspl  '> set new int = 87h '
xor eax,eax
int 16h
jmp exit
 
       include  'inc\dec.asm'
       include  'inc\hex.asm'
       include  'inc\print.asm'
       include  'inc\s_80x25.asm'
       include  'inc\memman.asm'
 
include 'inc\int\hook.asm'
include 'inc\int\intman.asm'
include 'inc\int\video.asm'
 
 align 512
rb 511
db 'x'
exit:
 
 
;EOF
