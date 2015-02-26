;mbr.asm
 
 
       ISOS_PARTITION_START_SECTOR_LBA = 0x26
       ISOS_PARTITION_SIZE_SECTORS = 0x0eb516
 
       use16
       org      0x07e00
start = $
       NEW_OFF= 00h;x7c00


       xor      ax,ax
       mov      es,ax
       mov      ds,ax
 
       cld
       mov      si,7c00h ;now we here
       mov      di,7e00h  ;will here
       mov      cx,200h
       rep      movsb
 
;jmp 0000:7e00h+StartReplacedCod
;StartReplacedCod = $-start

jmp 0000:StartReplacedCod
StartReplacedCod:


       PARTITION_TABLE_1_SECTOR_OFFSET = 454+0x7c00 ;from start of MBR sector
 
       mov      bx,PARTITION_TABLE_1_SECTOR_OFFSET 
mov eax,dword [es:bx] ;LBA for first partition
       push     dx
       call     .Read!_1_!Sector 
 
       mov      si, msgOk 
       call     Print2
 
       pop      dx
       push     word 0
       pop      ds
 
jmp 0000:7c00h
 
;in:
;eax - LBA sector
 
.Read!_1_!Sector:
       mov      [.packet_LBA ],eax
       mov      si,.packet 
       mov      ah,42h
       int      13h
       cmp      ah,0
       jne      .Hdd_Err 
       ret
 
.Hdd_Err:
       mov      si, msgEr 
       call     Print2 
       xor      ax,ax
       int      0x16
       int      0x19
 
 
.packet db 10h,0
.packet_Sector_Count dw 1 ;fix value
.packet_Buffer_Offset dw 0x07c00
.packet_Buffer_Segment dw 0
.packet_LBA dd 0,0
 
 
Print2:
       mov      ah, 0Eh
       mov      bx, 7
 
       lodsb
       int      10h ; 1st char
       lodsb
       int      10h ; 2nd char
       ret
 
msgOk db 'OK'
msgEr db 'ER'
 
 
rb start+0x01be-$
Partitions:
 
       BOOT_ID  = 0x0e ;BIGDOS FAT16 & BIOS int13 LBA support
       BOOT_INDICATOR = 0x080
 
;size of this partition may be 33Mb-4G
db BOOT_INDICATOR
db 0xff,0xff,0xff ;must be FFFFFF for LBA
db BOOT_ID
db 0xff,0xff,0xff ;must be FFFFFF for LBA
dd ISOS_PARTITION_START_SECTOR_LBA
dd ISOS_PARTITION_SIZE_SECTORS
 
 
; set the BOOT-signature at byte 510. ;
rb start+512-2-$
db 0x55, 0xAA
 
 
;EOF
