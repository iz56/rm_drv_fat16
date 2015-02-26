;hook.asm
 
 
;в регистре ax номер прерывания
;в регистрах cs:bx адрес нового обработчика
 
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
dw new_handler;-100h
dw 0
 
 
;EOF
