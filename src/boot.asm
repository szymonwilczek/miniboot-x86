[bits 16]           ; generate 16-bits instructions
[org 0x7C00]        ; BIOS loading this under that address in RAM

start:
    mov ah, 0x0E    ; BIOS: output character to the screen

    mov al, 'H'
    int 0x10

    mov al, 'e'
    int 0x10

    mov al, 'j'
    int 0x10

    mov al, '!'
    int 0x10

hang:
    jmp hang

; fill out with zeros to 510 bytes
times 510 - ($ - $$) db 0

; bootable sector signature (last 2 bytes: 511, 512)
dw 0xAA55
