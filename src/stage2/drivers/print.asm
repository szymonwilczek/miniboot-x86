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
	mov al, 0x0D
	call print_char
	mov al, 0x0A
	call print_char
	ret

print_boot_logo:
	push si
	push ax
	push cx
	push dx

	; clear screen
	mov ax, 0x0003
	int 0x10

	mov dx, 0x03D4      ; CRT index register
	mov al, 0x09        ; 9 = Maximum Scan Line
	out dx, al

	inc dx              ; 0x03D5 (data)
	mov al, 17          ; 17 + 1 = 18 pixel lines
	out dx, al

	; print boot logo
	mov si, boot_logo
	call print_string
	call print_random_slogan

	; wait 2.5 second
	mov ah, 0x86
	mov cx, 0x0026
	mov dx, 0x25a0
	int 0x15
	
	; clear screan again
	mov ax, 0x0003
	int 0x10

	pop dx
	pop cx
	pop ax
	pop si
	ret

print_random_slogan:
	push ax
	push bx
	push cx
	push dx
	push si

	; get system time
	mov ah, 0x00
	int 0x1A

	mov ax, dx ; random seed into ax
	xor dx, dx
	mov cx, SLOGAN_COUNT
	div cx ; modulo from division in dx

	; calculate offset
	mov bx, dx ; bx = index
	add bx, bx ; bx = index * 2 (dw size)

	; get the address from array
	mov si, [slogans_table+bx]
	call print_string

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret

%include "src/stage2/lib/constants/boot.asm"
