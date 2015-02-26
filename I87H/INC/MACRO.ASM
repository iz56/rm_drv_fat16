;macro.asm
 
 
macro align value { rb (value-1) - ($ + value-1) mod value }
 
macro      printDXstrRealMode {
 
call   PrintString09h
 
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
       printDXstrRealMode
       jmp      .outmacro
.msg db 0
db '$'
.outmacro:
       }
 
 
 
 
 
 
 
       macro    DbgDspl str {
 
       local    .outmacro, .msg
       mov      ah,9
       mov      dx,.msg
       printDXstrRealMode
       jmp      .outmacro
.msg db str
db '$'
.outmacro:
       }
 
       macro    DbgDsplLine {
 
       local    .outmacro, .msg
       mov      ah,9
       mov      dx,.msg
       printDXstrRealMode
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
; call Bin2AsciiDec
       mov      dx,si
       mov      ah,9
       printDXstrRealMode
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
       printDXstrRealMode
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
 
;call CreateStringEAxHex
       call     Bin2AsciiDec
       mov      dx,si
       mov      ah,9
       printDXstrRealMode
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
       printDXstrRealMode
       jmp      .outmacro
.saveEAX dd 0
.outmacro:
       popa
       mov      eax,[.saveEAX]
 
       }
 
 
       macro    PrprintDXstrRealModeAHhex {
       pusha
       DbgDspl  ' AX='
       popa
       DbgDsplAXh
       }
 
 
;EOF
 
