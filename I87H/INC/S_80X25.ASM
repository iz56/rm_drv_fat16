;s_80x25.asm
 
 
       align    4
 
vd_CharsOnLine dd 80
vd_LinesOnPage dd 25
vd_DefColorForChar dd 7
vd_MaxCursorPos dd 80*25
vd_StyleString dd ptrDosStyleString
vd_SegMemory dd 0x0b800 ;real value shift on 4 right (!)
 
 
       OFFSET_STRING_TERMINATOR = 4
       OFFSET_NEWLINE_CHAR = 12
       OFFSET_NEWLINE_CHAR2 = 16
       OFFSET_NEWLINE_SIZE = 8
 
       align    4
 
ptrDosStyleString:
.sizeOfItStruc dd 5*4
.StrTerminator db '$',0,0,0
.sNewLine dd 2 ;2 bytes
.NewLineByte1 dd 13
.NewLineByte2 dd 10
 
 
       align    4
 
ptrUnixStyleString:
.sizeOfItStruc dd 4*4
.StrTerminator dd 0
.sNewLine dd 1 ;1 bytes
.NewLineByte1 dd 10
 
 
       align    4
 
setCur:
       mov      [.saveReg_eax], eax
       mov      [.saveReg_edx], edx ; can it get any uglier?
       mov      al, 0x0E
       mov      ah, bh
       mov      dx, 0x3D4
       out      dx, ax
       inc      ax
       mov      ah, bl
       out      dx, ax
       mov      edx, [.saveReg_edx]
       mov      eax, [.saveReg_eax]
       ret
 
.saveReg_edx dd 0
.saveReg_eax dd 0
 
       align    4
 
getCur:
       mov      [.saveReg_eax], eax
       mov      [.saveReg_edx], edx
       mov      dx, 0x3D4
       mov      al, 0x0E
       out      dx, al
       inc      dx
       in       al, dx
       mov      bh, al
       mov      al, 0x0F
       dec      dx
       out      dx, al
       inc      dx
       in       al, dx
       mov      bl, al
       mov      edx, [.saveReg_edx]
       mov      eax, [.saveReg_eax]
       ret
 
.saveReg_edx dd 0
.saveReg_eax dd 0
 
 
 
       align    4
 
; subfunction to print a char ;
; bl = char, bh = attrib ;
PrintChar:
       push     es
 
       mov      [.saveReg_eax], eax
       mov      [.saveReg_ebx], ebx
 
       mov      eax,dword [vd_SegMemory]
       push     ax
       pop      es
 
 
       call     getCur
       mov      di,bx
       shl      di,1
       mov      ebx, [.saveReg_ebx]
mov [es:0+di],word bx
 
       call     incCur
       mov      ebx, [.saveReg_ebx]
       mov      eax, [.saveReg_eax]
 
       pop      es
       ret
 
.saveReg_ebx dd 0
.saveReg_eax dd 0
 
 
incCur:
       call     getCur
       inc      ebx
       call     ShiftPageUp
       call     setCur
       ret
 
 
 
       align    4
 
; Subfunction to display ascii(z,$) string
; Input: si = string
print:
 
;mov dx,si
;mov ah,9
;int 21h
;ret
 
       .NO_USAGE = 0x0fa
 
       call     SaveRegs32
 
       mov      al,byte .NO_USAGE
       mov      [.newline_byte_noview],al
 
 
       mov      eax,[vd_DefColorForChar]
       mov      [.attribut_byte],al
 
       mov      ebx,[vd_StyleString]
 
       mov      eax, dword [ebx+OFFSET_NEWLINE_SIZE]
       cmp      eax,1
       jz       .Unix
 
;not set this, if unix style str
       mov      eax,dword [ebx+OFFSET_NEWLINE_CHAR2]
       mov      [.newline_byte_noview],al ;here trash if unix
 
.Unix:
 
       mov      eax, dword [ebx+OFFSET_STRING_TERMINATOR]
       mov      [.string_terminator_byte],al
       mov      eax,dword [ebx+OFFSET_NEWLINE_CHAR]
       mov      [.newline_byte],al
 
 
.nextChar:
       mov      al, byte [si]
       inc      si
 
       cmp      [.newline_byte_noview],byte .NO_USAGE
       jz       .no10
 
       cmp      al,byte [.newline_byte_noview]
       jz       .nextChar
.no10:
       cmp      al,byte [.string_terminator_byte]
       jz       .done
 
       cmp      al,byte [.newline_byte]
       jz       .nl
 
.doit:
       mov      bl, al
       mov      bh, [.attribut_byte] ; standard color for this...
       call     PrintChar
       jmp      .nextChar
 
.nl:
       call     getCur
       call     EbxDiv80
       call     ShiftPageUp ;in ebx = if need shift page and update ebx
       call     setCur
       jmp      .nextChar
 
.done:
 
       call     SaveRegs32.restore
       ret
 
 
.attribut_byte db 0
.string_terminator_byte db 0
.newline_byte db 0
.newline_byte_noview db 0
 
 
 
EbxDiv80:
       xor      eax,eax
.l1:
       cmp      ebx,[vd_CharsOnLine]
       jb       .ok
       sub      ebx,[vd_CharsOnLine]
       add      eax,[vd_CharsOnLine]
       jmp      .l1
 
.ok:
       add      eax,[vd_CharsOnLine]
       mov      ebx,eax
       ret
 
 
ShiftPageUp:
;in ebx = if need shift page and update ebx
 
       cmp      ebx,dword [vd_MaxCursorPos]
       jae      .work
.err:
 
       ret
 
.work:
;-------\
       push     es
       call     SaveRegs32
       jc       .err
 
       mov      eax,dword [vd_SegMemory]
       push     ax
       pop      es
 
       xor      di,di
       mov      esi,[vd_CharsOnLine]
       shl      esi,1
 
       mov      ecx,dword [vd_MaxCursorPos]
       sub      ecx,[vd_CharsOnLine]
 
.nextWord:
mov ax,word [es:0+si]
mov [es:0+di],word ax
       add      di,2
       add      si,2
       dec      ecx
       jnz      .nextWord
 
       mov      ecx,[vd_CharsOnLine]
       mov      ax,word 0x0720
.nextWord2:
mov [es:0+di],word ax
       add      di,2
       dec      ecx
       jnz      .nextWord2
 
;-------/
 
 
       call     SaveRegs32.restore
 
       mov      ebx,dword [vd_MaxCursorPos]
       sub      ebx,[vd_CharsOnLine]
 
       pop      es
       ret
 
 
;EOF
