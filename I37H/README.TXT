readme.txt
 
in file macro.asm
 
see
 
       macro    printDXstrDos {
 
mov ah,9
int 21h  <---------- IF NEED DOS >>outfile.txt
 
 ;       mov      ax,0
 ;       mov      si,dx
 ;       int      87h   <--------IF FROM BOOT OS
 
       }
 
 
uncomment and comment it
 
EOF
