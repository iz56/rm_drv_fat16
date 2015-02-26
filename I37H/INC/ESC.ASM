;esc.asm
 
 
EscPressedCheck:
;+check key pressed (Esc)
       pusha
 
       mov      ah,1 ;check to see if a char is ready
       int      16h
       jz       .ReadLoop ;nope, continue
 
       mov      ah,0
       int      16h ;get the character & put in AX
       cmp      ah,1 ;=! Esc ...
       jnz      .ReadLoop ;nope, continue
 
       popa
       stc
       ret
 
.ReadLoop:
       popa
       clc
       ret
;-
 
 
;EOF
