;macro.asm
 
       macro    keyWx {
; xor eax,eax
; int 16h
       }
 
macro read42 { call ReadSectors }
 
macro align value { rb (value-1) - ($ + value-1) mod value }
 
       macro    printDXstrDos {
;must be es=ds
; call DosInt21h
       mov      ax,0
       mov      si,dx
       int      87h
;call PrintString09h
       }
 
       macro    DbgDsplALmm {
       local    .outmacro, .msg, .lz1, .lz0
       cmp      al,'$'
       jnz      .lz0
       mov      al,'S'
.lz0:
       cmp      al,32
       jae      .lz1
       mov      al,'.'
.lz1:
       mov      byte [.msg],al
       mov      ah,9
       mov      dx,.msg
       printDXstrDos ;int 21h
       jmp      .outmacro
.msg db 0
db '$'
.outmacro:
       }
 
       macro    DbgDspl_si {
       local    .outmacroe, .msge, .lz11
.lz11:
       mov      al,byte [si]
       inc      si
       cmp      al,0
       jz       .outmacroe
       cmp      al,'S'
       jz       .outmacroe
       cmp      al,13
       jz       .outmacroe
       cmp      al,10
       jz       .outmacroe
       push     si
       mov      [.msge],al
       mov      ah,9
       mov      dx,.msge
       printDXstrDos ;int 21h
       pop      si
       jmp      .lz11
.msge db 0
db '$'
.outmacroe:
       }
 
       macro    DbgDspl str {
       local    .outmacroEE, .msgEE
       pusha
       mov      ah,9
       mov      dx,.msgEE
       printDXstrDos ;int 21h
       jmp      .outmacroEE
.msgEE db str
db '$'
.outmacroEE:
       popa
       }
 
       macro    DbgDsplLine {
       local    .outmacro, .msg
       mov      ah,9
       mov      dx,.msg
       printDXstrDos ;int 21h
       jmp      .outmacro
.msg db 13,10
db '$'
.outmacro:
       }
 
       macro    DbgDsplEAXh {
       local    .outmacro, .saveEAX
       pusha
       mov      [.saveEAX],eax
       call     CreateStringEAxHex
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    DbgDsplEAXh_prefix0x {
       local    .outmacro, .saveEAX, okRR, okRR2
       pusha
       mov      [.saveEAX],eax
       shr      eax,28
       test     eax,eax
       jz       .okRR
       DbgDspl  '0x0'
       jmp      .okRR2
.okRR:
       DbgDspl  '0x'
.okRR2:
       mov      eax,[.saveEAX]
       call     CreateStringEAxHex
; call Bin2AsciiDec
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    DbgDsplALh {
       local    .outmacro, .saveEAX
       pusha
       mov      [.saveEAX],eax
       call     CreateStringAlHex
; call Bin2AsciiDec
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    DbgDsplEAXdFIXsize {
       local    .outmacro, .saveEAX
       pusha
       mov      [.saveEAX],eax
       call     Bin2AsciiDecFIX
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    DbgDsplEAXd {
       local    .outmacro, .saveEAX
       pusha
       mov      [.saveEAX],eax
       call     Bin2AsciiDec
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    DbgDsplAXd {
       local    .outmacro, .saveEAX
       pusha
       mov      [.saveEAX],eax
       shl      eax,16
       shr      eax,16
;call CreateStringEAxHex
       call     Bin2AsciiDec
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    DbgDsplAXh {
       local    .outmacro, .saveEAX
       pusha
       mov      [.saveEAX],eax
       call     CreateStringAxHex ;hex.asm
       mov      dx,si
       mov      ah,9
       printDXstrDos ;int 21h
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
       }
 
       macro    PrintAX {
       pusha
       DbgDspl  ' AX='
       popa
       DbgDsplAXh
       }
 
       macro    PrintSegs { ;arg=ss,cs,ds,gs..
       DbgDsplLine
       DbgDsplLine
DbgDspl '> * * * Runtime dump of segRegs : '
       DbgDsplLine
DbgDspl ' ss: '
       push     ss
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
       DbgDsplLine
DbgDspl ' cs: '
       push     cs
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
       DbgDsplLine
DbgDspl ' es: '
       push     es
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
       DbgDsplLine
DbgDspl ' ds: '
       push     ds
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
       DbgDsplLine
       }
 
macro CheckControlData {
pushad
mov eax,dword [ControlData]
   DbgDsplEAXh
xor ax,ax
int 16h
popad
 
}
 
;EOF
