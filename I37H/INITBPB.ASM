;bsi.asm
 
       ER_HDD_READ = 0x01 ;total error cod ( read error)
       BS_MBR_OFFSET_4BYTES_ID_MICROSOFT = 440
 
 
;mov di,boot ; set di=memory for BPB (+3 bytes at start)
;mov dl,80h
 
       push     cs
       pop      ax
       mov      ds,ax
       mov      es,ax
 
 
       DbgDspl  '>BS from hdd BIOS number = 80h '
       call     Read
 
       DbgDspl  ' Stop.'
 
       jmp      ExitInitBPB
 
 
ptrErrorTramp dw .ErrorTramp
.ErrorTramp:
       DbgDspl  ' (tramp error exit) .'
       jmp      FatalError
 
 
OffsetToVolimeFromStartDiskAbs dd 0
 
ExitInitBPB:
       mov      ax,word Fat_12_16_BPB
 
 
;EOF
