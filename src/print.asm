print_string:
	push ax
	mov al, [si]
	cmp al, 0
	je return
	int 0x10
	inc si
	jmp print_string

return:
	pop ax
	ret
