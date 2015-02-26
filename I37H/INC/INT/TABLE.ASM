;video.asm
 
 
int_table:
dw api_ax_0_ReadFile
 
       macro    end_int
       {
       jmp      int_exit ;intman.asm
       }
 
 
;#0 fun read file
api_ax_0_ReadFile:
 
       push     es
;restore ds
       mov      word ax,[saveall16_seg_regs.ds_reg]
       mov      es,ax
;restore si
       mov      dword esi,[saveall32regs.esireg]
 
       call     ReadFileMain ;drv.asm
 
       mov      ecx,dword [szFileBytes]
       mov      dword [returnEcx],ecx
 
       pop      es
       end_int
 
szFileBytes dd 0
 
 
;EOF
