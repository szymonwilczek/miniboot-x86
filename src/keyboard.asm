init_keyboard:
	mov di, cmd_buffer
	xor cx, cx ; counter=0

read_char:
	mov ah, 0x00
	int 0x16

	cmp al, 0x0D
	je .enter
	cmp al, 0x08
	je .backspace

	call print_char
	mov [di], al ; zapamietanie kodu ASCII
	inc di ; nastepny wolny bajt (do zapamietania nastepnego)
	inc cx
	jmp read_char

	.enter:
		call print_enter
		xor cx, cx
		mov byte [di], 0
		call handle_command
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
		dec di
		mov byte [di], 0
		dec cx
		jmp read_char
