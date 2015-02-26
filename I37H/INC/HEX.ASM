;.hex.asm
 
 
CreateStringEAxHex:
       push     ax
       shr      eax,16
       call     CreateStringAxHex
 
       mov      bx,.strBuf
 
       macro    saveStrToBuf {
       mov      al,[si]
       mov      [bx],al
       inc      si
       inc      bx
       }
 
       saveStrToBuf
       saveStrToBuf
       saveStrToBuf
       saveStrToBuf
 
       pop      ax
       push     bx
       call     CreateStringAxHex
       pop      bx
 
       saveStrToBuf
       saveStrToBuf
       saveStrToBuf
       saveStrToBuf
 
       mov      al,'$'
       mov      [bx],al
       mov      si,.strBuf
       ret
 
.strBuf rb 20
 
CreateStringAxHex:
 
       pusha
       mov      bx,.strBuf
       mov      [.i],word bx
 
       macro    std_puth
       {
       pusha
       mov      bx,word [.i]
       mov      [bx],al
       inc      word [.i]
       popa
       }
 
       mov      bx,ax
       shr      ah,4
       mov      al,ah
       mov      ah,0
       mov      si,.hex
       add      si,ax
       mov      al,[si]
       std_puth
       mov      ax,bx
       shl      ah,4
       shr      ah,4
       mov      al,ah
       mov      ah,0
       mov      si,.hex
       add      si,ax
       mov      al,[si]
       std_puth
       mov      ax,bx
       shr      al,4
       mov      ah,0
       mov      si,.hex
       add      si,ax
       mov      al,[si]
       std_puth
       mov      ax,bx
       shl      al,4
       shr      al,4
       mov      ah,0
       mov      si,.hex
       add      si,ax
       mov      al,[si]
       std_puth
       mov      al,'$'
       std_puth
       mov      al,0
       std_puth
 
       popa
       mov      si,word .strBuf
       ret
 
.hex db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
.strBuf rb 10
.i dw 0
 
CreateStringAlHex:
 
       pusha
       mov      bx,.strBuf
       mov      [.i],word bx
 
       macro    std_put1
       {
       pusha
       mov      bx,word [.i]
       mov      [bx],al
       inc      word [.i]
       popa
       }
 
       mov      bx,ax
       mov      ah,al
       shr      ah,4
       mov      al,ah
       mov      ah,0
       mov      si,.hex
       add      si,ax
       mov      al,[si]
       std_put1
       mov      ax,bx
       mov      ah,al
       shl      ah,4
       shr      ah,4
       mov      al,ah
       mov      ah,0
       mov      si,.hex
       add      si,ax
       mov      al,[si]
       std_put1
 
       mov      al,'$'
       std_put1
       mov      al,0
       std_put1
 
       popa
       mov      si,word .strBuf
       ret
 
.hex db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
.strBuf rb 10
.i dw 0
 
 
;EOF
