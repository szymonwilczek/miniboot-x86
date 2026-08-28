%ifndef KERNEL_LINUX_ASM
%define KERNEL_LINUX_ASM

[bits 16]

%include "src/stage2/lib/constants/initrd.asm"

LINUX_SETUP_SEG    equ 0x9000
LINUX_SETUP_OFFSET equ 0x0000
LINUX_CMDLINE_SEG equ 0x9800
LINUX_KERNEL_ADDR equ 0x00100000 ; 1MB
LINUX_INITRD_ADDR equ 0x04000000 ; 64MB

; Offsets of Linux Boot Protocol (x86)
HDR_SETUP_SECTS  equ 0x01F1 ; number of setup sectors (byte)
HDR_SYSSIZE      equ 0x01F4 ; kernel payload size in 16bytes (dword)
HDR_SIGNATURE    equ 0x0202 ; HdrS (dword)
HDR_LOADER_TYPE  equ 0x0210 ; bootloader identifier (byte)
HDR_LOADFLAGS    equ 0x0211 ; (byte)
HDR_CODE32_START equ 0x0214
HDR_INITRD_ADDR  equ 0x0218
HDR_INITRD_SIZE  equ 0x021C
HDR_HEAP_END_PTR equ 0x0224
HDR_CMD_LINE_PTR equ 0x0228

; Verification and preparing Linux header
; Input: ES:BX - bufor with first kernel sector
; Output: AX = 1 (success), AX = 0 (error, invalid kernel)
linux_parse_header:
	push bx
	push si

	mov eax, [es:bx + HDR_SIGNATURE]
	cmp eax, 0x53726448
	jne .invalid_kernel

	xor ax, ax
	mov al, [es:bx + HDR_SETUP_SECTS]
	test al, al
	jnz .setup_sects_ok
	mov al, 4 ; if this field is 0, protocol orders to take 4 sectors

.setup_sects_ok:
	inc al ; +1 sector boot
	mov [linux_setup_sectors], ax

	mov eax, [es:bx + HDR_SYSSIZE] ; Custom bootloader
	shl eax, 4 ; * 16
	add eax, 511
	shr eax, 9 ; / 512
	mov [linux_payload_sectors], eax

	; Registering bootloader in Linux header
	mov byte [es:bx + HDR_LOADER_TYPE], 0xFF ; Custom bootloader
	mov byte [es:bx + HDR_LOADFLAGS], 0x81 ; LOADED_HIGH | CAN_USE_HEAP
	mov word [es:bx + HDR_HEAP_END_PTR], 0x7E00
	mov dword [es:bx + HDR_CODE32_START], LINUX_KERNEL_ADDR

	mov dword [es:bx + HDR_CMD_LINE_PTR], (LINUX_CMDLINE_SEG << 4)
	mov dword [es:bx + HDR_INITRD_ADDR], LINUX_INITRD_ADDR
	mov dword [es:bx + HDR_INITRD_SIZE], INITRD_SIZE_BYTES

	pop si
	pop bx
	mov ax, 1
	ret

.invalid_kernel:
	pop si
	pop bx
	xor ax, ax
	ret

linux_load_kernel_payload:
	pushad

	mov ax, LINUX_CMDLINE_SEG
	mov es, ax
	xor di, di
	mov si, linux_cmdline

.copy_cmdline:
	lodsb
	stosb
	test al, al
	jnz .copy_cmdline

	mov eax, 17 ; LBA 17
	mov cx, [linux_setup_sectors]
	mov bx, LINUX_SETUP_SEG
	mov es, bx
	mov bx, LINUX_SETUP_OFFSET
	mov dl, [boot_drive]
	call disk_read_lba
	test ax, ax
	jz .failed

	mov bx, LINUX_SETUP_SEG
	mov es, bx
	mov bx, LINUX_SETUP_OFFSET
	call linux_parse_header
	test ax, ax
	jz .failed

	mov eax, 17
	xor edx, edx
	mov dx, [linux_setup_sectors]
	add eax, edx
	mov ecx, [linux_payload_sectors]
	mov edi, LINUX_KERNEL_ADDR
	call copy_lba_to_high_ram
	test ax, ax
	jz .failed

	mov eax, INITRD_LBA_START
	mov ecx, INITRD_SECTORS_CNT
	mov edi, LINUX_INITRD_ADDR
	call copy_lba_to_high_ram
	test ax, ax
	jz .failed

	popad
	mov ax, 1
	ret

.failed:
	popad
	xor ax, ax
	ret

copy_lba_to_high_ram:
	.sector_loop:
		cmp ecx, 0
		je .done
		
		push eax
		push ecx

		mov cx, 1
		xor bx, bx
		mov es, bx
		mov bx, 0x7E00
		mov dl, [boot_drive]
		call disk_read_lba
		test ax, ax
		jz .read_error

		push ds
		push es
		xor bx, bx
		mov ds, bx
		mov es, bx

		mov si, 0x7E00
		mov dx, 128

	.dword_copy:
		mov ebx, [ds:si]
		mov [es:edi], ebx
		add si, 4
		add edi, 4
		dec dx
		jnz .dword_copy

		pop es
		pop ds

		pop ecx
		pop eax
		inc eax
		dec ecx
		jmp .sector_loop
	
	.done:
		mov ax, 1
		ret
	
	.read_error:
		pop ecx
		pop eax
		xor ax, ax
		ret

linux_boot_jump:
	cli
	cld
	
	lidt [real_mode_idt]

	mov ax, LINUX_SETUP_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov sp, 0xDE00

	jmp 0x9020:0x0000

align 4
real_mode_idt:
	dw 0x03FF
	dd 0x00000000

linux_setup_sectors:    dw 0
linux_payload_sectors: dd 0
linux_cmdline: db "console=tty0 rdinit=/init quiet", 0

%endif



