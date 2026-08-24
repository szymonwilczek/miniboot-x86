linux_loader:
	call enable_a20
	cmp ax, 1
	jne .a20_error

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
		mov ax, word [es:0x01F4] ; syssize
		shr ax, 5 ; syssize / 32
		inc ax ; round up
		mov [kernel_sectors], ax

		movzx bx, byte [setup_sects_count]
		add bx, KERNEL_LBA_START + 1
		mov [payload_lba_start], bx

		mov byte [es:0x0210], 0xFF ; type_of_loader = custom bootloader
		or byte [es:0x0211], 0x01 ; loadflags: set LOADED_HIGH
		mov dword [es:0x0228], 0x00000000 ; cmd_line_ptr (0 if no params)

		ret


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
%include "src/stage2/lib/constants/dap.asm"
%include "loader/dap.asm"
%include "src/stage1/lib/constants/stage1_const.asm"

msg_a20_error: db "FATAL: Could not enable A20!", 0x0D, 0x0A, 0
msg_invalid_kernel: db "ERROR: Invalid Linux Kernel header!", 0x0D, 0x0A, 0
setup_sects_count: db 0
payload_lba_start: dw 0
kernel_sectors: dw 0
