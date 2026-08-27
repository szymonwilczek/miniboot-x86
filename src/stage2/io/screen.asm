%ifndef IO_SCREEN_ASM
%define IO_SCREEN_ASM

[bits 16]

screen_clear:
	push ax
	mov ax, 0x0003
	int 0x10
	pop ax
	ret

screen_set_cursor:
	push ax
	push bx
	mov ah, 0x02
	mov bh, 0x00
	int 0x10
	pop bx
	pop ax
	ret

screen_print_color:
	push ax
	push bx
	push cx
	push si

.loop:
	lodsb
	test al, al
	jz .done

	cmp al, 0x0D ; CR
	je .teletype_only
	cmp al, 0x0A ; LF
	je .teletype_only

	mov ah, 0x09
	mov bh, 0x00
	mov cx, 1
	int 0x10

.teletype_only:
	mov ah, 0x0E
	int 0x10
	jmp .loop

.done:
	pop si
	pop cx
	pop bx
	pop ax
	ret

%endif
