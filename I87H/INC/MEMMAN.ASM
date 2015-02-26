;memman.asm
 
 
       align    4
 
SaveRegs32:
       .NUM_OF_SAVED_REGS = 7
       .MAX_SIZE_OF_BUF = 7*5
 
 
       call     .PushAll
       mov      edi,[.offsetToPlace]
       cmp      edi,dword .MAX_SIZE_OF_BUF*4
       jb       .bufOk
       stc
       ret
 
.bufOk:
 
       inc      dword [meman_asm_counter_used]
 
       inc      dword [meman_asm_currently_top]
pushad
       mov eax, dword [meman_asm_currently_top]
       cmp eax, dword [meman_asm_currently_top_max]
jb .noNewMaxTop
 
       mov dword [meman_asm_currently_top_max],eax
 
.noNewMaxTop:
      popad
 
       add      di,word [.ptrBuf]
 
       mov      si,word .saveRegs
       mov      cx,word .NUM_OF_SAVED_REGS
.l1:
       mov      eax,dword [si]
       mov      [di],dword eax
       add      di,4
       add      si,4
       dec      cx
       jnz      .l1
 
       mov      eax,dword .NUM_OF_SAVED_REGS*4
       add      eax,dword [.offsetToPlace]
       mov      [.offsetToPlace],eax
 
       call     .PopAll
       clc
       ret
 
.reset:
       xor      eax,eax
       mov      [.offsetToPlace],eax
       mov      dword [meman_asm_currently_top],eax
 
       clc
       ret
 
 
.restore:
 
       inc      dword [meman_asm_counter_used_restore]
       dec      dword [meman_asm_currently_top]
 
 
       mov      eax,[.offsetToPlace]
test eax,eax
jnz .okOffsetOfPlace
 
inc dword [errors_to_restore]
       mov      eax,dword .NUM_OF_SAVED_REGS*4
 
 
.okOffsetOfPlace:
       sub      eax,dword .NUM_OF_SAVED_REGS*4
       mov      [.offsetToPlace],eax
 
       mov      esi,dword [.ptrBuf]
       add      esi,eax
       mov      di,word .saveRegs
       mov      cx,word .NUM_OF_SAVED_REGS
.l1_1:
       mov      eax,dword [si]
       mov      [di],dword eax
       add      di,4
       add      si,4
       dec      cx
       jnz      .l1_1
 
       call     .PopAll
       ret
 
 
.PushAll:
       mov      dword [.saveRegs],eax
       mov      dword [.saveRegs+4],ebx
       mov      dword [.saveRegs+8],edx
       mov      dword [.saveRegs+12],edi
       mov      dword [.saveRegs+16],esi
       mov      dword [.saveRegs+20],ecx
       ret
 
.PopAll:
       mov      eax,dword [.saveRegs]
       mov      ebx,dword [.saveRegs+4]
       mov      edx,dword [.saveRegs+8]
       mov      edi,dword [.saveRegs+12]
       mov      esi,dword [.saveRegs+16]
       mov      ecx,dword [.saveRegs+20]
       ret
 
.offsetToPlace dd 0
.ptrBuf dw .buf
.saveRegs dd 0,0,0,0,0,0,0
.buf rd .MAX_SIZE_OF_BUF
 
meman_asm_counter_used dd 0
meman_asm_counter_used_restore dd 0
errors_to_restore dd 0
meman_asm_currently_top dd 0
meman_asm_currently_top_max dd 0
 
;EOF
