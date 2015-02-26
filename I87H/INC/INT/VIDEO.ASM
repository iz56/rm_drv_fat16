;video.asm
 
MAX_SZ_OF_PRINTED_STRING = 80
 
       PRINT_ON = 0x09a
       PRINT_OFF = 0x0f7
 
 
int_table:
dw video_0_print ;ax=0
dw video_1_off ;ax=1
dw video_2_on ;ax=2
dw reserved
dw reserved
dw reserved
dw reserved
dw reserved
dw reserved
dw reserved
 
       macro    end_video
       {
       jmp      int_exit ;intman.asm
       }
 
 
video_0_print:
       cmp      byte [on_off_switch], PRINT_ON
       jz       .work
       end_video
.work:
 
;restore ds
       mov      word ax,[saveall16_seg_regs.ds_reg]
       mov      es,ax
;restore si
       mov      dword esi,[saveall32regs.esireg]
       mov      di,msg_buf
mov cl,byte MAX_SZ_OF_PRINTED_STRING
 
.l1:
mov byte al,[es:si]
       mov      [di],al
       inc      di
       inc      si
dec cl
       jnz      .l1
       mov      si,msg_buf
       call     print
macro ifdosee {
push cs
pop es
mov dx,si
mov ah,9
int 21h
}
 
       end_video
on_off_switch db PRINT_ON
msg_buf rb MAX_SZ_OF_PRINTED_STRING
db '$',0
video_1_off: ;ax=1
 
       mov      byte [on_off_switch], PRINT_OFF
 
       end_video
 
 
video_2_on: ;ax=2
 
       mov      byte [on_off_switch], PRINT_ON
 
       end_video
 
reserved:
 
       push     cs
       pop      es
 
       mov      si,msg_test
       call     print
 
       mov  eax,    dword [meman_asm_counter_used]
   DbgDsplEAXh
 
       mov      si,msg_test2
       call     print
 
 
       mov  eax,    dword [meman_asm_counter_used_restore]
   DbgDsplEAXh
 
       mov      si,msg_test2
       call     print
mov eax, dword [errors_to_restore]
   DbgDsplEAXh
 
       mov      si,msg_test3
       call     print
 
mov eax,dword [meman_asm_currently_top_max]
   DbgDsplEAXh
 
 
       end_video
 
msg_test db ' *i87h.bin - fun is reserved* used: $',0
msg_test2 db ' : $',0
msg_test3 db ' M $',0
 
;EOF
