print_string:
	mov al, [si]
	cmp al, 0
	je return
	int 0x10
	inc si
	jmp print_string

return:
	ret
