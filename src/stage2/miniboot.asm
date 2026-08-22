[bits 16]
[org 0x8000]

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

	call init_keyboard

hang:
	jmp hang

%include "src/print.asm"
%include "src/keyboard.asm"
%include "src/commands.asm"
%include "src/string.asm"
%include "src/constants.asm"

;; END SECTOR

; fill out with zeros to 510 bytes
times 510 - ($ - $$) db 0

; bootable sector signature (last 2 bytes: 511, 512)
dw 0xAA55
