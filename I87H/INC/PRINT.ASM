;print.asm
 
 
PrintString09h:
 
pusha
push dx
xor esi,esi
pop si
 
xor eax,eax
       int      87h
 
;call print
 
popa
 
ret
 
 
 
 
 
 
 
 
;EOF
