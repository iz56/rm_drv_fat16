rem make and execute drver on ms-dos and fat16 hdd (fasm needed)
del fsdrv.bin
cd i37h
call make
cd ..
cd i87h
call make
cd ..
fasm fsdrv.asm fsdrv.bin
cd setdrv
del fsdrv.bin
cd ..
copy fsdrv.bin .\setdrv\fsdrv.bin
cd setdrv
call make
setdrv