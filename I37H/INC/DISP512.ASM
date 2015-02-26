;displ512.asm
 
 
;input:
;si = ptr to data (512bytes)
;eax = num of sector (LBA)
DisplayToUser:
       pusha
       shr      eax,16
       push     ax
       DbgDsplLine
       DbgDspl  '> sector # '
       pop      ax
       shl      eax,16
       popa
 
       .SIZE_OF_DATA = 512 ; size of sector - must be 512
       pusha
       mov      [.startBuf],si
       DbgDsplEAXd
       popa
       pusha
       mov      cx,word .SIZE_OF_DATA/2
 
       jmp      .newLineSkipFirst16byte
 
.newLine:
       call     PrintASCII_16byte
.newLineSkipFirst16byte:
 
       pusha
       DbgDsplLine
       popa
       pusha
 
       xor      eax,eax
       mov      ax,si
       mov      dx,[.startBuf]
       sub      ax,dx
       add      eax,[.TotalCounter]
 
       DbgDsplEAXh
       DbgDspl  ' '
 
       xor      eax,eax
       mov      ax,si
       mov      dx,[.startBuf]
       sub      ax,dx
       add      eax,[.TotalCounter]
 
       DbgDsplEAXdFIXsize
       DbgDspl  ' '
 
       popa
 
       mov      dx,9
.l1:
       dec      dx
       jz       .newLine
 
       mov      ah,byte [si]
       inc      si
       mov      al,byte [si]
 
       pusha
       DbgDsplAXh
       DbgDspl  ' '
       popa
 
       inc      si
       dec      cx
       jnz      .l1
 
       call     PrintASCII_16byte
 
       DbgDsplLine
;DbgDspl 'sector # '
 
       popa
       add      [.TotalCounter],dword .SIZE_OF_DATA
 
       call     EscPressedCheck ;set stc if abort
       ret
 
.startBuf dw 0 ;save here first ptr to data
.TotalCounter dd 0
 
PrintASCII_16byte:
       pusha
       push     si
       DbgDspl  ' '
       pop      si
       push     si
       pop      di
       sub      si,word 16
.nextAL:
       mov      al,byte [si]
       inc      si
       cmp      si,di
       ja       .exit
       pusha
       DbgDsplALmm
       popa
 
       jmp      .nextAL
 
.exit:
       popa
       ret
 
 
;EOF
