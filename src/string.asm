strncmp:
	push ax

	.loop:
		cmp cx, 0
		je .equal

		mov al, [si]
		mov bl, [di]

		cmp al, bl
		jne .not_equal

		cmp al, 0
		je .equal

		inc si
		inc di
		dec cx
		jmp .loop

	.not_equal:
		pop ax
		ret

	.equal:
		pop ax
		cmp al, al
		ret
