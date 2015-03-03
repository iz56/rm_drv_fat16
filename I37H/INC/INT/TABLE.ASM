;video.asm
 
 
int_table:
dw api_ax_0_ReadFile
 
       macro    end_int
       {
       jmp      int_exit ;intman.asm
       }
 
 
;#0 fun read file
api_ax_0_ReadFile:
 
       call     ReadFileMain ;drv.asm
       mov      dword [returnEcx],ecx
       end_int
 
 
;EOF
