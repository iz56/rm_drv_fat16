;setdrv.asm
 
 
;test program for IS-OS /SetDrv/
 
 
macro align value { rb (value-1) - ($ + value-1) mod value }
 
       org      100h
       use16
 
       push     cs
       pop      ds
 
 
       mov      dx,word Kernel
       call     SetDrv
 
       push     cs
       pop      es
       push     es
       pop      ds
       mov      si,testName
       mov      di,Top
       xor      eax,eax
       int      37h
 
;push cs
;pop ds
 
xor ax,ax
int 16h
 
push cs
pop es
mov si,Top
xor ax,ax
int 87h
 
xor ax,ax
int 16h
 
;mov ah,9
;int 21h
 
mov ax,4
int 87h
 
       mov      ah,4ch
       int      21h
 
 
;dx=drv binary offset (aligned 16 - must be start from paragraf)
;dx=/here translaite it to rus text/
SetDrv:
;save ret addr
       pop      ax
       push     cs ;/for far ret/ seg
       push     ax ; offset
       shr      dx,4
 
       push     cs
       pop      ax
       add      ax,dx
 
 
       mov      es,ax
       mov      [jmpaddr.seg],ax
 
       jmp      far dword [jmpaddr]
 
jmpaddr:
.off dw 0
.seg dw 0
 
       align    16
Kernel:
       file     'fsdrv.bin'
       retf
 
;testName:  db 'EMD.COM'
testName:  db 'SETDRV.ASm'
 
align 16
       Top      = $
 
db 'qwerty$',0
;EOF
