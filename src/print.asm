print_string:
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
		ret

print_char:
	push ax
	mov ah, 0x0E
	int 0x10
	pop ax
	ret

print_enter:
	mov al, 0x0A
	call print_char
	ret
