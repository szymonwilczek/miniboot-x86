[bits 16]
[org 0x8000]

stage2_entry:
	mov [boot_drive], dl
	
	mov si, msg_stage2
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

msg_stage2: db 0x0D, 0x0A, "WELCOME TO STAGE 2!", 0x0D, 0x0A, 0
boot_drive: db 0
