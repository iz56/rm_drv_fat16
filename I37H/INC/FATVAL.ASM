;fatval.asm
 
FatContent:
.EOC dw 0x0ffff ; End of Clusterchain
.EOC2 dw 0x0fff8 ; End of Clusterchain 2 variant
.Free dw 0 ;Rfee Cluster
.Bad dw 0x0fff7 ;Bad Cluster
 
 
 
;EOF
