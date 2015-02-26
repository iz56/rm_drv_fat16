;i37h.asm
 
       include  'inc\macro.asm'
 
;0=ok - not error
       FILE_NOT_FAUND = 1
       FILE_OK  = 2
       DISK_IO_ERROR = 3
       INIT_ERROR = 4
       BIOS_FUN_42_ERROR = 5
API_TARGET_OFFSET_ALIGN_ERROR = 6
 
       org      2560
       use16
 
;init driver All here
 
       mov      ax,37h
       mov      word bx,new_handler
       call     hook ;\int\hook.asm
 
       DbgDspl  '> set new int = 37h '
       xor      eax,eax
       int      16h
       jmp      Wexit
 
 
;mov di,boot ; set di=memory for BPB (+3 bytes at start)
;mov cx,SIZE_BPB
GetMBR_GetVBR_GetBPBfromIt:
       pusha
 
       include  'initBPB.asm' ;return ax=memory BPB+3bytesStart
 
       mov      [.saveTmpBPBptr],ax
       popa
       mov      si,[.saveTmpBPBptr]
       mov      cx,0x036
.l1:
       mov      al,[si]
       mov      [di],al
       inc      si
       inc      di
       dec      cx
       jnz      .l1
 
       clc
       ret
.saveTmpBPBptr dw 0
.err:
       stc
       ret
 
       include  'inc\int\hook.asm'
       include  'inc\int\intman.asm'
       include  'inc\int\table.asm'
 
       include  'inc\fat16.asm' ;main file for fat16 subprogs
       include  'inc\fatval.asm' ;data file for fat16 subprogs
 
       include  'inc\data.asm'
       include  'inc\bios42.asm'
       include  'inc\disp512.asm'
 
       include  'inc\esc.asm'
       include  'inc\dec.asm'
       include  'inc\hex.asm'
 
       include  'inc\fnconv.asm'
ReadFileMain:
       mov      [ExitCod],byte INIT_ERROR
 
;here set memory for work
       push     ax
       push     cs
       pop      ax
       add      ax,0x1000
       call     SetFreeMemorySeg
       pop      ax
 
       include  'drv.asm'
 
       align    8 ;if next cod must be aligned 16
db '12345678'
Wexit: ;goto next cod in kernel
 
 
;EOF
