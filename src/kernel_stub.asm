times 0x01F1 - ($ - $$) db 0
db 4 ; setup_sects = 4
times 0x01F4 - ($ - $$) db 0
dd 0x00010000 ; syssize = 1MB
times 0x0202 - ($ - $$) db 0
db "HdrS"
dw 0x020D ; 2.13 protocol version
times 2048 - ($ - $$) db 0
