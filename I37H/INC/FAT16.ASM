;fat16.asm
 
 
;FirstDataSector dd 0
RootDirSectors dd 0
ImageLoadOffset dw 0
ImageLoadSeg dw 0
FileName11b db 'XXXXXXXXXXX'
OffsetToVolFat16 dd 0 ;offset sectors from start to volime
 
 
GetFirstSectorOfCluster:
       pusha
;ax=num of clus
       cmp      ax,2
       jb       FatalError
       sub      ax,word 2
 
       movzx    ecx,byte [bpbSectorsPerCluster]
; cx = sector count
       mul      ecx
       test     edx,edx
       jnz      FatalError
 
       mov      [.tmpEax],eax
 
       call     GetFirstDataAreaSector
 
       add      eax,dword [.tmpEax]
       mov      [.tmpEax],eax
       popa
       mov      eax, [.tmpEax]
 
       ret
.tmpEax dd 0
 
 
GetFirstDataAreaSector:
       pusha
       call     CalcSzRootSectors
;cx=root sectors
       movzx    eax,cx
       mov      [.tmpEax],eax
 
       call     CalcStartOfRootDir
       add      eax,dword [.tmpEax]
; add eax,dword [OffsetToVolFat16]
       mov      [.tmpEax],eax
       popa
       mov      eax, [.tmpEax]
 
       ret
.tmpEax dd 0
 
 
;ret eax=sector
CalcStartOfRootDir:
       push     es bx cx
       call     CalcFatsz_AX_CX ;ax=FAT size in paragrafs, cx= in sectors
       xor      eax,eax
       mov      ax,cx
       shl      eax,1 ;*2
       mov      [.saveSzFat_x2],eax ;save size of 2 fats ,sectors
       call     CalcAddrOfFat ; eax = LBA
       add      eax, [.saveSzFat_x2]
       pop      cx bx es
       ret
.saveSzFat_x2 dd 0
 
 
CalcFatsz_AX_CX:
       mov      ax, [bpbBytesPerSector]
       shr      ax, 4 ; ax = sector size in paragraphs
       mov      cx, [bpbSectorsPerFAT] ; cx = FAT size in sectors
       mul      cx ; ax = FAT size in paragraphs
       ret
 
 
CalcAddrOfFat:
       mov      ax,word [bpbHiddenSectors+2]
       shl      eax,16
       mov      ax,word [bpbHiddenSectors]
       movzx    edx,word [bpbReservedSectors]
       add      eax,edx
       ret
 
 
;call CalcSzRootSectors
CalcSzRootSectors:
       push     si ax
       mov      ax, 32
       mov      si,word [bpbRootEntries]
       mul      si
       div      word [bpbBytesPerSector]
       mov      cx, ax ; cx = root directory size in sectors
       pop      ax si
       ret
 
GetMemoryForFAT16__ES:
       push     ax
; push cs
; pop ax
 
       call     GetFreeMemorySeg
 
; add ax,0x1000
       mov      es,ax
       xor      di,di ; es/di -> buffer for the FAT
       pop      ax
       ret
 
GetMemoryForRoot__ES:
       push     ax
; push cs
; pop ax
 
       call     GetFreeMemorySeg
 
       add      ax,0x2000
       mov      es,ax
       xor      di,di ; es/di -> buffer for the Root
       pop      ax
       ret
 
GetMemoryForFileReading_ES_DI:
       push     ax
       mov      edi,dword [saveall32regs.edireg]
       mov      ax,di
       shl      al,4
       test     al,al
       jz       .ok
       mov      [ExitCod],byte API_TARGET_OFFSET_ALIGN_ERROR
       jmp      FatalError
.ok:
       shr      di,4
       mov      ax,word [saveall16_seg_regs.es_reg]
       add      ax,di
       mov      es,ax
       xor      edi,edi ; es/di -> buffer for the File
       pop      ax
       ret
 
 
FreeMemoryForWork dw 0
 
SetFreeMemorySeg:
       mov      [FreeMemoryForWork],ax
       ret
 
GetFreeMemorySeg:
       mov      ax,[FreeMemoryForWork]
       ret
 
 
 
;EOF
