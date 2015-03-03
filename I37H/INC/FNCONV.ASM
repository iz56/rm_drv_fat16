;fnconv.asm
 
 
GetFileName_si: ;return user file name
       pushad
       push     es
       mov      word ax,[saveall16_seg_regs.ds_reg]
       mov      es,ax
 
       mov      esi,dword [saveall32regs.esireg]
       mov      di,.TestFile
       mov      cx,13
;es:si = incoming filename string
.copyName:
       mov      al,[es:si]
       call     checkAlforTrueFileName
       call     UpCaseAll
       mov      [di],al
       inc      si
       inc      di
       dec      cx
       jnz      .copyName
 
       mov      si,.TestFile
       call     ConvFileName ;return new si
       mov      di,.FileName11b
       call     .CopySaveFileName
 
       pop      es
       popad
       mov      si, .FileName11b
       ret
 
.CopySaveFileName:
       .FILE_NAME_LEGHT = 11 ;for fat must be 11
       mov      cl,byte .FILE_NAME_LEGHT
.l1:
       mov      al,[si]
       test     al,al
       jz       .err1
 
       cmp      al,'.'
       jz       .err2
 
       inc      si
       mov      [di],al
       inc      di
       dec      cl
       jnz      .l1
       ret
 
.err1:
       DbgDspl  'fnconv.asm'
       DbgDspl  'ERR1'
       mov      [ExitCod],byte FILE_NAME_IS_BAD
       jmp      FatalError
 
.err2:
       DbgDspl  'fnconv.asm'
       DbgDspl  'ERR2'
       mov      [ExitCod],byte FILE_NAME_IS_BAD
       jmp      FatalError
 
 
.TestFile rb 15
.FileName11b rb 13
 
 
;si=file name
;si=file name for fat
 
ConvFileName:
 
       mov      cl,11
       mov      di,[.ptrBuf]
.l1:
       mov      al,[si]
       inc      si
 
       cmp      al,32
       jz       .itSpace
 
       test     al,al
       jz       .itZero
 
       cmp      al,'.'
       jz       .itDot
 
       mov      [di],al
       inc      di
       dec      cl
       jnz      .l1
       jmp      .ok
 
.itSpace:
       stc
       ret
 
 
.itZero:
       call     .Fill32
 
.ok:
       mov      si,[.ptrBuf]
       clc
       ret
 
.itDot:
       cmp      cl,3
       jz       .l1
       jb       .err
 
       sub      cl,3
       call     .Fill32
       add      cl,3
       jmp      .l1
 
.Fill32:
       mov      al,32
.l2:
       mov      [di],al
       inc      di
       dec      cl
       jnz      .l2
       ret
 
.err:
       DbgDspl  'fnconv.asm'
       DbgDspl  'ERR3'
       mov      [ExitCod],byte FILE_NAME_IS_BAD
       jmp      FatalError
 
.ptrBuf dw .buf
.buf rb 11
 
 
;update al
UpCaseAll:
       pushad
 
       mov      bx,.lowCase
       mov      cx,26
.l1:
       cmp      al,byte [bx]
       jz       .ok
       inc      bx
       dec      cx
       jnz      .l1
       popad
       ret
 
.ok:
       add      bx,26
       mov      al,byte [bx]
       mov      [.saveAl],al
       popad
       mov      al,[.saveAl]
       ret
.saveAl db 0
 
.lowCase:
db 'qwertyuiopasdfghjklzxcvbnm'
;.upCase:
db 'QWERTYUIOPASDFGHJKLZXCVBNM'
 
 
;check al
checkAlforTrueFileName:
       pushad
 
       mov      bx,.tableOfBadChars
       mov      cx,.SISE_OF_TABLE
 
.l1:
       cmp      al,byte [bx]
       jz       .err
       inc      bx
       dec      cx
       jnz      .l1
       popad
       ret
 
.err:
       DbgDspl  'fnconv.asm'
       DbgDspl  'ERR4'
       mov      [ExitCod],byte FILE_NAME_IS_BAD
       jmp      FatalError
 
.tableOfBadChars:
db '/\!@#$%^&*()-+=|<>?~`'
       .SISE_OF_TABLE = $ - .tableOfBadChars
 
;EOF
