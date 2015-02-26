;dec.asm
 
 
;eax max number = 4294967295
;перевод числа в регистре eax в десятичное число в виде ASCIIZ строки
; вывод: esi = адрес строки
 
Bin2AsciiDecFIX:
 
mov [Bin2AsciiDec.flagNoDeleteZ], 1
jmp Bin2AsciiDec.work
 
Bin2AsciiDec:
mov [.flagNoDeleteZ], 0
.work:
 
       mov      ecx,dword 9 ;количество разрядов - 1
       xor      edx,edx
       xor      edi,edi
 
;обнуляем индекс таблицы
       mov      [.Index],dword 0
 
       add      edi,.String
       mov      ebx,dword 1000000000 ;10 разрядов
 
.l1:
       cmp      eax,ebx
       jb       .l11
       inc      dword edx
       sub      eax,ebx
       jae      .l1
 
.l11:
       add      edx,dword 48
       mov      [edi],byte dl
       inc      dword edi
 
; push eax
       mov      [.Regs32bitTempSave],dword eax
 
       mov      eax,ebx
 
;--------------------------------------------\
; push ecx
       mov      [.Regs32bitTempSave+4],dword ecx
 
 
       mov      ebx,.Table
       mov      eax,dword [.Index]
       add      ebx,eax
       add      eax,dword 4
       mov      [.Index],dword eax
 
       mov      eax,dword [ebx] ;результат
 
; pop ecx
       mov      ecx, dword [.Regs32bitTempSave+4]
 
       mov      ebx,eax
; pop eax
       mov      eax, dword [.Regs32bitTempSave]
 
       xor      edx,edx
       dec      ecx
       jnz      .l1
 
       add      al,byte 48
       mov      [edi],byte al
       inc      dword edi
 
       xor      edx,edx
       mov      [edi+1],byte dl
       mov      dl,'$'
       mov      [edi],byte dl
       mov      si,word .String
       call     .DeleteFirstZeroChars
       ret
 
.String rb 12 ;буфер для формирования ASCIIZ строки
.Regs32bitTempSave dd 0,0 ;здесь место для 32бит регистров
 
.Index dd 0
.Table:
dd 100000000
dd 10000000
dd 1000000
dd 100000
dd 10000
dd 1000
dd 100
dd 10
 
.DeleteFirstZeroChars:
mov al,[.flagNoDeleteZ]
test al,al
jz .workDel
ret
.workDel:
 
       mov      cl,12
.l1d:
       dec      cl
       jz       .errStrDec
 
       mov      al,[si]
       inc      si
       cmp      al,'0'
       jz       .l1d
       cmp      al,'$'
       jnz      .okAll
       dec      si
.okAll:
       dec      si
       ret
 
.flagNoDeleteZ db 0
 
.errStrDec:
DbgDspl ' error: inc\dec.asm '
       mov      si,.errDefStr
       ret
.errDefStr db 'err$',0
 
 
 
 
;EOF
 
