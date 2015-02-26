;hook.asm
 
 
;ax = mun of interrupt
;cs:bx = ptr to new handler
 
hook:
       push     es
       push     ax
       mov      word [new_vector],bx
 
       mov      ax,cs
       mov      word [new_vector+2],ax
 
       xor      eax,eax
       mov      es,ax
 
       mov      dword eax,[new_vector]
       pop      bx
       shl      bx,2;x4
mov dword [es:bx],eax
 
       pop      es
       ret
 
new_vector:
dw new_handler
dw 0
 
 
;EOF
