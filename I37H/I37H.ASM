;i37h.asm
 
       include  'inc\macro.asm'
 
       FILE_OK  = 0
       FILE_NOT_FAUND = 1
       DISK_IO_ERROR = 2
       INIT_ERROR = 3
       BIOS_FUN_42_ERROR = 4
       API_TARGET_OFFSET_ALIGN_ERROR = 5
       FILE_NAME_IS_BAD = 6
 
       org      2560 ;size of i87h.bin
       use16
 
;init driver - set new handler for 37h interrupt
       mov      ax,37h
       mov      word bx,new_handler
       call     hook ;\int\hook.asm
 
       DbgDspl  '> set new int = 37h '
       xor      eax,eax
       int      16h
       jmp      Wexit
 
 
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
       include  'inc\drv.asm'
 
       align    8 ;if next cod must be aligned 16
db '12345678'
Wexit: ;goto next cod in kernel
 
 
;EOF
