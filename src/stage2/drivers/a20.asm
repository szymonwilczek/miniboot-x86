check_a20:
	push es
	push di
	push ds
	push si
	push bx
	push cx
	push dx

	mov ax, 0x0000
	mov es, ax

	mov di, 0x7DfE
	mov si, 0x7E0E

	mov ax, 0xFFFF
	mov ds, ax

	mov dl, byte [es:di]
	mov dh, byte [ds:si]

	mov byte [es:di], 0x00
	mov byte [ds:si], 0xFF

	cmp byte [es:di], 0xFF
	je .wrapping
	cmp byte [es:di], 0x00
	je .not_wrapping

	.wrapping:
		mov ax, 0
		jmp .reset
	.not_wrapping:
		mov ax, 1
		jmp .reset
	
	.reset:
		mov byte [es:di], dl
		mov byte [ds:si], dh

		pop dx
		pop cx
		pop bx
		pop si
		pop ds
		pop di
		pop es

		ret
