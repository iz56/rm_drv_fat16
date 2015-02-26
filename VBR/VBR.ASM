;vbr.asm
 SEG_STACK=7000h
KERNEL_SEGMENT = 50h 
       ISOS_PARTITION_START_SECTOR_LBA = 0x26
       ISOS_PARTITION_SIZE_SECTORS = 0x0eb516
 
 
       use16
       org      0x7C00
 
boot:
       jmp      start
       nop
bsOemName db 'XXXXXXXX' ; 0x03
 
BPB:
.BytsPerSec dw 512 ;0x0b / 11
.SecPerClus db 0x10 ;0x0d / 13
.RsvdSecCnt dw 0x21; 0x0e / 14 ; or =32 for fat32
.NumFats db 2; 0x010 / 16 ; or 1 for usb-stick
.RootEntCnt dw 512 ;0x11 /17 ;for fat32 = 0
.TotSec16 dw 0 ;0x13 / 19 ;=0 for fat32 and big FAT16
.Media db 0x0f8 ;0x15 / 21
.FATSz16 dw 0x0ef ;0x16 / 22 ;=0 for fat32
.SecPerTrk dw 0x3f; 0x18 /24
.NumHeads dw 0xff; 0x1a /26
.HiddSec dd ISOS_PARTITION_START_SECTOR_LBA ;0x1c /28
 
;.TotSec32 dd ;x10000 ;must be > 0x10000 and .TotSec16=0
.TotSec32 dd ISOS_PARTITION_SIZE_SECTORS
 
;_f1216:
.DrvNum db 0 ; only OS used --!
.Reserved1 db 0 ;use NT
.BootSig db 0x29 ;must be 0x29 for FAT16
.VolID dd 0 ;Rundom
.VolLab rb 11 ;Not used here
.FilSysType rb 8 ;Not used here
 
; starting point of bootsector code
start:
       cli
 
       xor      ax, ax ; initialize all the necessary
       mov      ds, ax ; registers.
       mov ax,SEG_STACK
       mov      ss, ax
       mov      sp, 0xFF ; Stack..
 
       mov      [BPB.DrvNum], dl
 
       sti
 
;fat - load it
       call     GetMemoryForFAT16__ES ;ret es=buf for fat 128Kb, di=0
       call     CalcFatsz_AX_CX ;ax=FAT size in paragrafs, cx= in sectors
       call     CalcAddrOfFat ; eax = LBA
       call     ReadSectors
 
;root directory - load it
       call     GetMemoryForRoot__ES ;es,di sets to buf for root
       call     CalcSzRootSectors ;cx=sectors to read
       call     CalcStartOfRootDir ;ret eax=sector
       call     ReadSectors
 
;find file
       call     GetMemoryForRoot__ES ;es,di sets to buf for root
       mov      dx, 512 ; dx = number of root entries
; ds/si -> program name
       mov      si, FileName11b
 
; Looks for a file with particular name
; Input: DS:SI = name (11 chars)
; ES:DI = root directory array
; DX = root entries
; Output: SI = cluster number
 
FindName:
       mov      cx, 11
.Cycle:
cmp byte [es:di], ch
       je       FatalError ; end of root directory
       pusha
       repe     cmpsb
       popa
       je       .Found
       add      di, 32
       dec      dx
       jnz      .Cycle ; next root entry
       jmp      FatalError
.Found:
mov si, [es:di+1Ah] ; si = cluster no.
 
       call     GetFirstDataAreaSector
 
   ;    MAX_SIZE_OF_FILE_IN_CLUSTERS=0x0ffff
    ;   mov      cx,MAX_SIZE_OF_FILE_IN_CLUSTERS
ReadNextCluster:
   ;    push     cx
       call     ReadClusterFat16
 
  ;     pop      cx
 ;      dec      cx
 ;      jz       FatalError
       cmp si,word 0
       jz       FatalError
 
; Type checking \
;if End of Clusterchain then done
       cmp      si,word 0x0ffff
       jz       .Done
       cmp      si,word 0x0fff8
       jnz      ReadNextCluster
; Type checking /
 
.Done:
 
 
jmp KERNEL_SEGMENT:0x0000 ; jump to loaded file (64kb in mem)
 
 
; Reads a FAT16 cluster
;> SI = cluster no
;< SI = next cluster
 
ReadClusterFat16:
       push     si
;ax=clus
       mov      ax,si
 
       call     GetFirstSectorOfCluster
 
       push     ax
       mov      ax,word [.iFileInMemorySeg]
       test     ax,ax
       jnz      .noInit
       call     GetMemoryForFileReading_ES_DI
       jmp      .okEs_Di
 
.noInit:
       mov      es,ax
 ;      mov      di,word [.iFileInMemoryOff]
.okEs_Di:
       pop      ax
 
       movzx    cx,byte [BPB.SecPerClus]
 
       call     ReadSectors
 
       push     es
       pop      ax
       mov      word [.iFileInMemorySeg],ax
 ;      mov      word [.iFileInMemoryOff],di
 
       call     GetMemoryForFAT16__ES
       pop      si
       add      si,si
       jnc      .First64
       mov      ax,es
       add      ax, 1000h ; adjust segemnt for 2nd part of FAT16
       mov      es,ax
 
.First64:
mov si,word [es:si]
 
       ret
 
.iFileInMemorySeg dw 0
;.iFileInMemoryOff dw 0
 
 
FatalError:
mov ax,0e47
       int      10h ; 1st char
 xor      ax,ax
       int      0x16
       int      0x19
 
 
;read sectors BIOS
 
;in:
;es:di - buffer
;eax - LBA sector
;cx - sector count
 
ReadSectors:

       push     cx
       call     ReadSector
       pop      cx
;Adjust es eax (di=0 all times)
.l1:
       mov      dx,es
       add      dx,20h
       mov      es,dx
       inc      eax
       dec      cx
       jnz      .l1
 ret


ReadSector:
       mov      [.packet_Buffer_Segment],es
;       mov      [.packet_Buffer_Offset],di
       mov      [.packet_LBA],eax
       mov      [.packet_Sector_Count],cx
       mov      dl,[BPB.DrvNum]
       mov      si,.packet
       mov      ah,42h
       int      13h
       cmp      ah,0
       jne      FatalError 

       ret
 
 
.packet db 10h,0
.packet_Sector_Count dw 0
.packet_Buffer_Offset dw 0
.packet_Buffer_Segment dw 0
.packet_LBA dd 0,0
 
include 'inc/fat16.asm'
 
 
; set the BOOT-signature at byte 510. ;
       rb       boot+512-2-$
db 0x55, 0xAA

 
 
 
;EOF
