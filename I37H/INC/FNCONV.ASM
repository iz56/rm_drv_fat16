;fnconv.asm
 
 
;si=file name
;si=file name for fat
 
ConvFileName:
       pushad
       call     if_zeroString
       jc       .err
       mov      [.tmpSi],si
       popad
       mov      si,[.tmpSi]
       ret  ; - - exit[1]
 
.err:
       popad
       clc
       ret  ; - - exit[2]
 
.tmpSi dw 0
 
 
if_zeroString:
 
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
       stc
       ret
 
.ptrBuf dw .buf
.buf rb 11
 
 
;EOF
