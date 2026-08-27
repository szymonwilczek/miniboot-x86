[bits 16]
[org 0x7C00]

; segments normalization and stack configuration
boot:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00

	; save boot drive number
	mov [boot_drive], dl
	mov si, msg_hello
	call .print_string

.hang:
	cli
	hlt
	jmp .hang

.print_string:
	push ax
	push si
	mov ah, 0x0E

	.loop:
		lodsb
		test al, al
		jz .done
		int 0x10
		jmp .loop
	.done:
		pop si
		pop ax
		ret

msg_hello: db "Miniboot Stage 1 loaded successfully!", 0x0D, 0x0A, 0
boot_drive: db 0

times 510 - ($ - $$) db 0
dw 0xAA55
