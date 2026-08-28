%ifndef DRIVERS_A20_ASM
%define DRIVERS_A20_ASM

[bits 16]

enable_a20:
	push bx
	push cx

	call check_a20
	cmp ax, 1
	je .success

	mov ax, 0x2401
	int 0x15
	jc .try_fast_a20

	call check_a20
	cmp ax, 1
	je .success

.try_fast_a20:
	in al, 0x92
	test al, 2 ; check bit 1
	jnz .try_kbc
	or al, 2 ; set bit 1 (A20 enable)
	and al, 0xFE ; zero-out bit 0 (to NOT reset the CPU :))
	out 0x92, al

	call check_a20
	cmp ax, 1
	je .success

.try_kbc:
	cli
	call a20_kbc_wait_input
	mov al, 0xAD ; turn off the keyboard
	out 0x64, al

	call a20_kbc_wait_input
	mov al, 0xD0 ; read Controller Output Port
	out 0x64, al

	call a20_kbc_wait_output
	in al, 0x60
	push ax ; save old port state

	call a20_kbc_wait_input
	mov al, 0xD1 ; save to Controller Output Port
	out 0x64, al

	call a20_kbc_wait_input
	pop ax
	or al, 2 ; bit 1 = A20 Enable
	out 0x60, al

	call a20_kbc_wait_input
	mov al, 0xAE ; turn ON keyboard back again
	out 0x64, al

	sti

	call check_a20
	cmp ax, 1
	je .success

	pop cx
	pop bx
	xor ax, ax ; AX = 0
	ret

.success:
	pop cx
	pop bx
	mov ax, 1 ; AX = 1
	ret

check_a20:
	pushf
	push ds
	push es
	push di
	push si

	cli

	xor ax, ax
	mov es, ax
	not ax
	mov ds, ax

	mov di, 0x7DFE ; 0x0000:0x7DFE
	mov si, 0x7E0E ; 0xFFFF:0x7E0E

	; save old values
	mov al, [es:di]
	push ax
	mov al, [ds:si]
	push ax

	; test values
	mov byte [es:di], 0x00
	mov byte [ds:si], 0xFF

	; check to see if writing under the 0x107DFE overwrote 0x007DFE
	cmp byte [es:di], 0xFF

	pop ax
	mov [ds:si], al
	pop ax
	mov [es:di], al

	je .a20_disabled

	; A20 is working correctly (no wrapping)
	pop si
	pop di
	pop es
	pop ds
	popf
	mov ax, 1
	ret

.a20_disabled:
	pop si
	pop di
	pop es
	pop ds
	popf
	xor ax, ax
	ret

a20_kbc_wait_input:
	in al, 0x64
	test al, 2 ; is the input buffer full?
	jnz a20_kbc_wait_input
	ret

a20_kbc_wait_output:
	in al, 0x64
	test al, 1 ; is the output buffer ready to read?
	jnz a20_kbc_wait_output
	ret

%endif

