[bits 16]           ; generate 16-bits instructions
[org 0x7C00]        ; BIOS loading this under that address in RAM

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00

	mov ah, 0x0E    ; BIOS: output character to the screen
	mov si, title_string
	call print_string

	mov si, subtitle_string
	call print_string

hang:
	jmp hang

title_string:
	db "Hello in this funny little bootloader!", 0x0D, 0x0A, 0
subtitle_string:
	db "I guess we are doing things kind of modular now", 0x0D, 0x0A, 0

%include "src/print.asm"


;; END SECTOR

; fill out with zeros to 510 bytes
times 510 - ($ - $$) db 0

; bootable sector signature (last 2 bytes: 511, 512)
dw 0xAA55
