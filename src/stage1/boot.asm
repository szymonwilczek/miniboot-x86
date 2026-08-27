[bits 16]
[org 0x7C00]

STAGE2_LOAD_SEG equ 0x0000
STAGE2_LOAD_OFFSET equ 0x8000
STAGE2_SECTORS_NUM equ 16

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

	mov ax, STAGE2_LOAD_SEG
	mov es, ax
	mov bx, STAGE2_LOAD_OFFSET

	mov ah, 0x02 ; BIOS read sectors
	mov al, STAGE2_SECTORS_NUM
	mov ch, 0   ; cylinder 0
	mov cl, 2 ; sector 2 (LBA 1, right after MBR)
	mov dh, 0 ; header 0
	mov dl, [boot_drive]
	int 0x13
	jc .disk_error

	mov dl, [boot_drive]
	jmp STAGE2_LOAD_SEG:STAGE2_LOAD_OFFSET

.disk_error:
	mov si, msg_disk_error
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
msg_disk_error: db "FATAL: Disk read error!", 0x0D, 0x0A, 0
boot_drive: db 0

times 510 - ($ - $$) db 0
dw 0xAA55
