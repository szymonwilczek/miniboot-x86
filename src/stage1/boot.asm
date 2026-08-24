[bits 16]
[org 0x7C00]

boot:
	xor ax, ax
	mov ds, ax
	mov es, ax ; target sector in RAM
	mov ss, ax
	mov sp, 0x7C00
	mov [BOOT_DRIVE], dl

	mov ah, 0x02 ; read sectors
	mov al, 0x04 ; 4 sectors, so thats about 2kB for stage 2
	mov ch, 0x00 ; cylinder 0
	mov cl, 0x02 ; start from sector 2
	mov dh, 0x00 ; start from header 0 (glowica)
	mov dl, [BOOT_DRIVE] ; read remembered boot drive number
	mov bx, 0x8000 ; target offset in RAM (physical address)
	int 0x13
	jc .disk_error

	mov dl, [BOOT_DRIVE]
	jmp 0x0000:0x8000

	.disk_error:
		mov si, error_string
		jmp .print_string
		jmp .hang
	.hang:
		jmp .hang

.print_string:
	push ax
	push si
	mov ah, 0x0E

	.loop:
		mov al, [si]
		cmp al, 0
		je .done
		int 0x10
		inc si
		jmp .loop

	.done:
		pop si
		pop ax
		jmp .hang

%include "src/stage1/lib/constants/stage1_const.asm"

error_string:
	db "Oh noo. I am very sorry that I failed you... I could not do that.", 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0
dw 0xAA55
