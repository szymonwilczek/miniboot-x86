linux_loader:
	call enable_a20
	cmp ax, 1
	jne .a20_error

	call enter_unreal_mode

	mov bx, KERNEL_LBA_START
	mov cx, 0
	mov ax, SETUP_SEGMENT
	mov es, ax
	mov ax, 32
	mov di, 0x0000
	mov dl, [BOOT_DRIVE]
	call read_sectors_lba

	mov cx, SETUP_SEGMENT
	mov es, cx
	cmp dword [es:0x0202], HEADER_MAGIC
	jne .invalid_kernel

	mov al, byte [es:0x01F1] ; setup_sects
	cmp al, 0
	jne .setup_sects_ready
	mov al, 4

	.setup_sects_ready:
		mov [setup_sects_count], al

		mov ax, word [es:0x01F4] ; syssize
		shr ax, 5 ; syssize / 32
		inc ax ; round up
		mov [kernel_sectors], ax

		movzx bx, byte [setup_sects_count]
		add bx, KERNEL_LBA_START + 1
		mov [payload_lba_start], bx

		mov byte [es:0x0210], 0xFF ; type_of_loader = custom bootloader
		or byte [es:0x0211], 0x01 ; loadflags: set LOADED_HIGH
		mov word [es:0x01Fa], 0xFFFF ; vid_mode = VGA_NORMAL (80x25)
		mov dword [es:0x0228], 0x00000000 ; cmd_line_ptr (0 if no params)

		mov edi, 0x100000 ; physical target in RAM: 1MB
		mov bx, [payload_lba_start] ; current LBA sector
		mov bp, [kernel_sectors] ; counter of remaining sectors

.load_kernel_loop:
	cmp bp, 0
	jbe .load_kernel_done

	; reading packet: min(bp, 64)
	mov ax, bp
	cmp ax, 64
	jbe .read_chunk
	mov ax, 64 ; max 64 sectors (32KB) on once

	.read_chunk:
		push ax
		mov cx, 0 ; LBA High
		mov dx, 0x2000 ; buffer segment
		mov es, dx
		mov di, 0x0000 ; buffer in 0x2000:0x0000 (physical of 0x20000)
		mov dl, [BOOT_DRIVE]
		call read_sectors_lba
		pop ax

		; copying from buffer 0x20000 directly to EDI address (>1MB)
		push ds
		push es
		push ax

		; set segments to copy
		xor dx, dx
		mov ds, dx ; ds=0
		mov es, dx ; es=0

		mov esi, 0x20000 ; target: buffer in conventional memory
		movzx ecx, ax ; number of sectors in this packet
		shl ecx, 7 ; convert sectors to dwords (sectors * 128)
		a32 rep movsd ; 32bit copying in Unreal Mode

		pop ax
		pop es
		pop ds

		; pointer moves
		sub bp, ax ; reduce number of remaining sectors
		add bx, ax ; move LBA sector on disk
		jmp .load_kernel_loop
	
	.load_kernel_done:
		cli
		lgdt [gdt_descriptor]

		mov eax, cr0
		or al, 1 ; turn on Protected Mode (PE=1)
		mov cr0, eax

		; far jump reloads CS register to 0x08 selector
		jmp 0x08:.protected_mode_entry

[bits 32]
.protected_mode_entry:
	; set segment registers for data selector (0x10)
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esi, 0x10000 ; pointer to Real-Mode Setup (0x1000:0x0000)
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor ebp, ebp
	xor edi, edi

	; JUMP TO LINUX!!!
	jmp 0x100000

[bits 16]
.a20_error:
	mov si, msg_a20_error
	call print_string
	cli
	hlt
	jmp $

.invalid_kernel:
	mov si, msg_invalid_kernel
	call print_string
	cli
	hlt
	jmp $

%include "src/stage2/drivers/a20.asm"
%include "src/stage2/drivers/unreal.asm"
%include "src/stage2/lib/constants/dap.asm"
%include "loader/dap.asm"
%include "src/stage1/lib/constants/stage1_const.asm"

msg_a20_error: db "FATAL: Could not enable A20!", 0x0D, 0x0A, 0
msg_invalid_kernel: db "ERROR: Invalid Linux Kernel header!", 0x0D, 0x0A, 0
setup_sects_count: db 0
payload_lba_start: dw 0
kernel_sectors: dw 0
