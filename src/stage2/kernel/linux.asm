%ifndef KERNEL_LINUX_ASM
%define KERNEL_LINUX_ASM

[bits 16]

LINUX_SETUP_SEG    equ 0x9000
LINUX_SETUP_OFFSET equ 0x0000

; Offsets of Linux Boot Protocol (x86)
HDR_SETUP_SECTS equ 0x01F1 ; number of setup sectors (byte)
HDR_SYSSIZE     equ 0x01F4 ; kernel payload size in 16bytes (dword)
HDR_SIGNATURE   equ 0x0202 ; HdrS (dword)
HDR_VERSION     equ 0x0206 ; protocol version (word)
HDR_LOADER_TYPE equ 0x0210 ; bootloader identifier (byte)
HDR_LOADFLAGS   equ 0x0211 ; (byte)

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
	or byte [es:bx + HDR_LOADFLAGS], 0x01 ; LOADED_HIGH

	pop si
	pop bx
	mov ax, 1
	ret

.invalid_kernel:
	pop si
	pop bx
	xor ax, ax
	ret

linux_setup_sectors:    dw 0
linux_payload_sectors: dd 0

%endif



