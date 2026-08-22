xor cx, cx ; counter=0

read_char:
	mov ah, 0x00
	int 0x16

	cmp al, 0x0D
	je .enter
	cmp al, 0x08
	je .backspace

	call print_char
	inc cx
	jmp read_char

	.enter:
		call print_enter
		xor cx, cx
		jmp read_char

	.backspace:
		cmp cx, 0
		je read_char
		mov al, 0x08
		call print_char
		mov al, 0x20
		call print_char
		mov al, 0x08
		call print_char
		dec cx
		jmp read_char
