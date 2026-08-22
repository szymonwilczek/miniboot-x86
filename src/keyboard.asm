read_char:
	mov ah, 0x00
	int 0x16
	call print_char
	cmp al, 0x0D
	jne read_char
	je .enter

	.enter:
		call print_enter
		jmp read_char

