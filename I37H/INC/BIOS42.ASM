;biosdisk.asm
 
 
;LBA HDD read in real mode CPU x86, fasm
 
;read sectors BIOS
 
;in:
;es:di - buffer
;eax - LBA sector
;cx - sector count
 
ReadSectors:
       pushad
       mov      [ExitCod],byte BIOS_FUN_42_ERROR
 
       mov      [.packet_Buffer_Segment],es
       mov      [.packet_Buffer_Offset],di
       mov      [.packet_LBA],eax
       mov      [.packet_Sector_Count],cx
       mov      dl,[.DriveNumber80_81]
       mov      si,.packet
       mov      ah,42h
       int      13h
       cmp      ah,0
       jnz      FatalError
 
       popad
       ret
 
.DriveNumber80_81 db 0
 
.packet db 10h,0
.packet_Sector_Count dw 0
.packet_Buffer_Offset dw 0
.packet_Buffer_Segment dw 0
.packet_LBA dd 0,0
 
 
;EOF
