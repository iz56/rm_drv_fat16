;drv.asm
 
 
ReadFileMain:
 
       mov      [ExitCod],byte INIT_ERROR
 
;here set memory for work
       push     ax
       push     cs
       pop      ax
       add      ax,0x1000
       call     SetFreeMemorySeg
       pop      ax
 
 
       call     SetDrvNumForBios42fn
 
       push     cs
       pop      es
 
 
 
push cs
pop es
       call     ReadFile_IS_OS
 
       mov      ecx,dword [szFileBytes]
       ret
 
 
ReadFile_IS_OS:
 
       DbgDsplLine
DbgDspl '> Read BPB from realdisk: '
       mov      [ExitCod],byte DISK_IO_ERROR
       call     initBPB_fromRealDisk
 
; Reserve some memory for a FAT16 image (128KB max) and load it whole
 
       call     CalcFatsz_AX_CX ;ax=FAT size in paragrafs, cx= in sectors
 
       push     ax
       push     cx
       DbgDsplLine
DbgDspl '> Size of FAT (sectors): '
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
 
       DbgDsplLine
DbgDspl '> Size of FAT (paragrafs): '
       pop      ax
       push     ax
 
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
 
       DbgDsplLine
DbgDspl '> Size of FAT (bytes,dec): '
       xor      eax,eax
       pop      ax
       shl      eax,4
 
       DbgDsplEAXd
 
       DbgDsplLine
DbgDspl '> Sector (abs) of start Fat (1nd table): '
       call     CalcAddrOfFat ; eax = LBA
       DbgDsplEAXd
 
 
       DbgDsplLine
DbgDspl '> Read FAT : '
       call     GetMemoryForFAT16__ES ;ret es=buf for fat 128Kb, bx=0
 
       PrintSegs
 
       call     CalcFatsz_AX_CX ;ax=FAT size in paragrafs, cx= in sectors
       push     cx
       call     CalcAddrOfFat ; eax = LBA
       pop      cx
 
 
       xor      di,di
       push     cs
       pop      ds
 
       call     ReadSector
 
       PrintSegs
 
       DbgDsplLine
       DbgDspl  '> Ok - reading fat. '
 
;-------------------------------------------------------------------------------
; Reserve some memory for a root directory and load it whole (16KB max)
 
       DbgDsplLine
       DbgDspl  '> Read Root. '
       mov      ax,word [bpbRootEntries]
       push     ax
       DbgDsplLine
DbgDspl '> Root entries: '
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
 
       call     CalcSzRootSectors
 
       push     cx
       push     cx
       DbgDsplLine
DbgDspl '> Root size (sectors): '
       pop      ax
       DbgDsplAXh
DbgDspl '/dec: '
       DbgDsplAXd
       pop      cx
 
 
       DbgDsplLine
DbgDspl '> Total FAT (2?): '
       movzx    ax, [bpbNumberOfFATs]
       DbgDsplAXd
 
       movzx    ax, [bpbNumberOfFATs]
       cmp      ax,2
       jz       .okFats2
; DbgDsplLine
       DbgDspl  ',total FAT not 2 - error.'
       jmp      Error
 
.okFats2:
       call     GetMemoryForRoot__ES ;es,di sets to buf for root
       call     CalcSzRootSectors ;cx=sectors to read
       call     CalcStartOfRootDir ;ret eax=sector
 
       call     ReadSector
 
       DbgDsplLine
       DbgDspl  '> Read Root done. '
 
       PrintSegs
 
       DbgDsplLine
DbgDspl '> Sector (abs) of start Root: '
       call     CalcStartOfRootDir ;ret eax=sector
       DbgDsplEAXd
 
       call     GetMemoryForRoot__ES ;es,di sets to buf for root
 
 
       mov      dx, 512 ; dx = number of root entries
; ds/si -> program name
call GetFileName_si ;return user file name
 
; Looks for a file with particular name
; Input: DS:SI -> file name (11 chars)
; ES:DI -> root directory array
; DX = number of root entries
; Output: SI = cluster number
 
FindName:
       mov      cx, 11
.Cycle:
cmp byte [es:di], ch
       je       .Failed ; end of root directory
       pusha
       repe     cmpsb
       popa
       je       .Found
       add      di, 32
       dec      dx
       jnz      .Cycle ; next root entry
.Failed:
       DbgDspl  '( File not found )'
       mov      [ExitCod],byte FILE_NOT_FAUND
       jmp      Error
 
.Found:
mov si, [es:di+1Ah] ; si = cluster no.
mov eax,dword [es:di+1Ah+2] ; size of file bytes
 
       mov      [szFileBytes],eax
       push     si
 
       DbgDsplLine
       DbgDspl  '> Find file name in root done. '
 
       DbgDsplLine
DbgDspl '> Size of File, bytes : '
       mov      eax,[szFileBytes]
       DbgDsplEAXd
 
 
       PrintSegs
 
 
       DbgDsplLine
       DbgDspl  '> Start read file from disk. '
       DbgDsplLine
       DbgDspl  '> Get cluster from fat. '
 
 
       DbgDsplLine
DbgDspl '> Data area first sector: '
 
       call     GetFirstDataAreaSector
       DbgDsplEAXd
 
 
       DbgDsplLine
DbgDspl '> First cluster: '
 
       pop      ax
       push     ax
       DbgDsplAXh
 
       DbgDsplLine
 
       pop      si
 
       MAX_SIZE_OF_FILE_IN_CLUSTERS=0x0ffff
 
       mov      cx,MAX_SIZE_OF_FILE_IN_CLUSTERS
ReadNextCluster:
       push     cx
       call     ReadClusterFat16
 
       push     si
       DbgDspl  ' '
       pop      ax
       push     ax
       DbgDsplAXh
       pop      si
 
       pop      cx
       dec      cx
       jz       FatalError
 
; Type checking \
       cmp      si,word [FatContent.Free]
       jz       FatalError
 
       cmp      si,word [FatContent.Bad]
       jz       FatalError
 
       cmp      si,word [FatContent.EOC]
       jz       .Done
 
       cmp      si,word [FatContent.EOC2]
       jnz      ReadNextCluster
; Type checking /
 
 
.Done:
       DbgDsplLine
       DbgDspl  ' ------ '
       mov      [ExitCod],byte FILE_OK
 
; call movedReadedFileData
 
       ret
 
 
; Reads a FAT16 cluster
; Inout: ES:BX -> buffer
; SI = cluster no
; Output: SI = next cluster
; ES:BX -> next addr
 
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
       mov      di,word [.iFileInMemoryOff]
.okEs_Di:
       pop      ax
 
       movzx    ecx,byte [bpbSectorsPerCluster]
 
       call     ReadSector
 
       push     es
       pop      ax
       mov      word [.iFileInMemorySeg],ax
       mov      word [.iFileInMemoryOff],di
 
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
.iFileInMemoryOff dw 0
 
 
ReadSector:
;in:
;es:di - buffer
;eax - LBA sector
;cx - sector count
 
       push     cx
       read42
 
       pop      cx
 
;Adjust es eax (di=0 all times)
.l1:
       push     cx
       call     AdjustSegmentForNextSector
       pop      cx
       dec      cx
       jnz      .l1
       ret
 
 
initBPB_fromRealDisk:
 
;get real sector
       mov      di,boot ; set di=memory for BPB (+3 bytes at start)
       mov      cx,SIZE_BPB
       call     GetMBR_GetVBR_GetBPBfromIt ;copy bpb from disk to di (cx=size)
 
       ret
 
 
;call AdjustSegmentForNextSector
AdjustSegmentForNextSector:
       cmp      word [bpbBytesPerSector],200h ;512
       jnz      .no200h
       push     ax
       mov      ax,es
       add      ax,20h
       mov      es,ax
       pop      ax
       inc      eax
       ret
 
.no200h:
       push     di si
       mov      di, [bpbBytesPerSector]
       shr      di, 4 ; paragraphs per sector
       mov      si, es
       add      si, di
       mov      es, si ; adjust segment for next sector
       inc      eax
       pop      si di
       ret
 
 
SetDrvNumForBios42fn:
       push     dx
       mov      edx,dword [saveall32regs.edxreg] ;api dl= 80h|81h
 
       cmp      dl,80h
       jz       .driveNumIsOk
 
       cmp      dl,81h
       jz       .driveNumIsOk
 
       mov      dl,80h ;default number
.driveNumIsOk:
       mov      [ReadSectors.DriveNumber80_81],dl
       pop      dx
       ret
 
 
;ptrToFileName dw 0 ;init from program
szFileBytes dd 0
 
 
 
;EOF
