;data.asm
 
 
;ptr to dword value = first sector on first patr
       MBR_1ST_SECTOR_1ST_PATR_OFFSET = 454
 
 
;in: eax=sector (LBA48)/64 bit ?
MapBS:
;mov eax,0x026
       mov      di,Fat_32_BPB
       mov      cx,1 ; SecToLoad
       read42
 
 
       mov      di,Fat_12_16_BPB
       mov      cx,1 ; SecToLoad
       read42
 
       ret
 
 
Read:
       call     .ReadFatBS
       push     si di
;input:
;si = ptr to data (512bytes)
;eax = num of sector (LBA)
       push     di
       call     DisplayToUser ;disp512.asm
       keyWx
       pop      si
       call     DisplayToUser ;disp512.asm
 
       pop      di si
       call     .DisplayBS_FAT
       ret
 
 
.ReadFatBS:
       keyWx
       DbgDspl  '> Read first sector from 80h . '
 
 
       push     ds
       pop      es
       mov      di, .Buf512
       mov      cx,1 ; SecToLoad
       xor      eax,eax ;mbr sector 1th
 
       read42
 
       mov      si, .Buf512
       xor      eax,eax ;mbr sector 1th
       call     DisplayToUser ;disp512.asm
       keyWx
DbgDspl '> Microsoft disk ID (4bytes): '
 
 
       mov      bx,word BS_MBR_OFFSET_4BYTES_ID_MICROSOFT
       add      bx,word .Buf512
       mov      eax,dword [bx]
       DbgDsplEAXh
 
       DbgDsplLine
DbgDspl '> 1 patrition start (4 bytes LBA sector): '
 
       mov      bx, MBR_1ST_SECTOR_1ST_PATR_OFFSET
       add      bx,word .Buf512
       mov      eax,dword [bx]
; DbgDsplEAXh
       DbgDsplEAXh_prefix0x
 
 
       DbgDsplLine
DbgDspl '> BS from 1th patrition : '
 
       mov      bx, MBR_1ST_SECTOR_1ST_PATR_OFFSET
       add      bx, .Buf512
       mov      eax,dword [bx]
 
       mov      [OffsetToVolimeFromStartDiskAbs],eax
 
       call     MapBS
       mov      si,Fat_12_16_BPB
       mov      di,Fat_32_BPB
 
       ret
 
 
.DisplayBS_FAT:
 
       DbgDsplLine
DbgDspl '> Now parsing BS from 1th ptrition FAT12/16: '
       DbgDsplLine
       mov      si,Fat_12_16_BPB
       call     .parseEQ
 
       mov      si,Fat_12_16_BPB
       call     .parse12_16
 
 
       DbgDsplLine
DbgDspl '> Now parsing BS from 1th ptrition FAT32: '
       DbgDsplLine
 
       mov      si,Fat_32_BPB
       call     .parseEQ
 
       mov      si,Fat_32_BPB
       call     .parse32
 
 
       DbgDsplLine
DbgDspl '> Add count of sectors in reserved region and First sec of patrition:'
       DbgDsplLine
DbgDspl ' >Count of sectors in reserved region (dec) : '
       DbgDsplLine
DbgDspl ' >calc : '
 
       mov      ax,word [Fat_12_16_BPB.RsvdSecCnt]
       DbgDsplAXd
 
       DbgDspl  ' + '
 
       mov      ax,word [Fat_12_16_BPB.RsvdSecCnt]
       push     ax
       mov      bx, MBR_1ST_SECTOR_1ST_PATR_OFFSET
       add      bx,word .Buf512
       mov      eax,dword [bx]
       DbgDsplEAXd
       DbgDspl  ' = '
 
       mov      bx, MBR_1ST_SECTOR_1ST_PATR_OFFSET
       add      bx,word .Buf512
       mov      eax,dword [bx]
 
       xor      ebx,ebx
       pop      bx
       add      eax,ebx
       DbgDsplEAXd
       DbgDsplLine
       ret
 
.parse12_16:
       DbgDsplLine
DbgDspl '> FAT12 FAT16 spec: '
 
       DbgDsplLine
DbgDspl ' > BootSig0x29 : '
       mov      al,[_f1216.BootSig]
       DbgDsplALh
       DbgDspl  ' {0x29 only for 12/16} '
 
       DbgDsplLine
DbgDspl ' > Text 8 bytes ASCII :['
 
       mov      al,[_f1216.FilSysType]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+1]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+2]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+3]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+4]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+5]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+6]
       DbgDsplALmm
       mov      al,[_f1216.FilSysType+7]
       DbgDsplALmm
       DbgDspl  ']'
 
       DbgDsplLine
       ret
 
 
.parse32:
       DbgDsplLine
DbgDspl '> FAT32 spec: '
 
       DbgDsplLine
       ret
 
 
.parseEQ:
       mov      [.ptrBuf],si
 
       macro    printDwordBS argOffset {
       mov      bx, word argOffset
       mov      si,[.ptrBuf]
       add      bx,si
       mov      eax,dword [bx]
       DbgDsplEAXh
       }
 
       macro    printWordBS argOffset {
       mov      bx, word argOffset
       mov      si,[.ptrBuf]
       add      bx,si
       mov      eax,dword [bx]
       DbgDsplAXh
       }
 
 
       DbgDsplLine
DbgDspl ' >Sig of boot sector (for BIOS) word hex : '
       printWordBS 510
 
       DbgDsplLine
DbgDspl ' >Total sectors dword hex : '
 
       mov      eax,dword [Fat_12_16_BPB.TotSec32]
       DbgDsplEAXh
 
DbgDspl '|dec : '
 
       mov      eax,dword [Fat_12_16_BPB.TotSec32]
       DbgDsplEAXd
 
 
       DbgDsplLine
DbgDspl ' >Size (dec) , Kbytes : '
 
       mov      eax,dword [Fat_12_16_BPB.TotSec32]
       shr      eax,1
 
       DbgDsplEAXd
 
DbgDspl ' | Mbytes : '
 
       mov      eax,dword [Fat_12_16_BPB.TotSec32]
       shr      eax,1
 
       shr      eax,10
       DbgDsplEAXd
 
 
       DbgDsplLine
DbgDspl ' >Media type byte : '
 
       movzx    eax,byte [Fat_12_16_BPB.Media]
       DbgDsplALh
       DbgDspl  ' {f0,f8,f9,fa,fb,fc,fd,fe,ff} '
 
 
       DbgDsplLine
DbgDspl ' >Count of sectors in reserved region (dec) : '
 
       mov      ax,word [Fat_12_16_BPB.RsvdSecCnt]
       DbgDsplAXd
       DbgDsplLine
 
       ret
.ptrBuf dw ?
.Buf512 rb 512
 
 
Fat_12_16_BPB:
       rb       11
.BytsPerSec rw 1
.SecPerClus rb 1
.RsvdSecCnt rw 1; or =32 for fat32
.NumFats rb 1; or 1 for usb-stick
.RootEntCnt rw 1 ;for fat32 = 0
.TotSec16 rw 1 ;=0 for fat32
.Media rb 1
.FATSz16 rw 1; =0 for fat32
.SecPerTrk rw 1;
.NumHeads rw 1;
.HiddSec rd 1;
.TotSec32 rd 1;must be > 0x10000 and .TotSec16=0
_f1216:
.DrvNum rb 1; only OS --!
.Reserved1 rb 1 ;use NT
.BootSig rb 1 ;
.VolID rd 1;
.VolLab rb 11
.FilSysType rb 8
 
; set the BOOT-signature at byte 510. ;
       rb       Fat_12_16_BPB+512-2-$
.Sig rb 2
 
 
 
Fat_32_BPB:
       rb       11
.BytsPerSec rw 1
.SecPerClus rb 1
.RsvdSecCnt rw 1; or =32 for fat32
.NumFats rb 1; or 1 for usb-stick
.RootEntCnt rw 1 ;for fat32 = 0
.TotSec16 rw 1 ;=0 for fat32
.Media rb 1
.FATSz16 rw 1; =0 for fat32
.SecPerTrk rw 1;
.NumHeads rw 1;
.HiddSec rd 1;
.TotSec32 rd 1 ;must be > 0x10000 and .TotSec16=0
_f32:
.FATSz32 rd 1;size of 1fat
.ExtFlags rw 1
.FSVer rw 1;must be 0
.RootClus rd 1
.FSInfo rw 1
.BkBootSec rw 1
.Reserwed rb 12 ;0000000000000
 
.DrvNum rb 1
.Reserved1 rb 1 ;use NT
.BootSig rb 1 ;
.VolID rd 1;
.VolLab rb 11
.FilSysType rb 8
 
; set the BOOT-signature at byte 510. ;
       rb       Fat_32_BPB+512-2-$
.Sig rb 2
 
 
;EOF
