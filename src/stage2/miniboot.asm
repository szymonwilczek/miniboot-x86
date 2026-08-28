[bits 16]
[org 0x8000]

stage2_entry:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov [boot_drive], dl

	call screen_clear

	mov dh, 1
	mov dl, 2
	call screen_set_cursor

	mov si, boot_logo
	mov bl, 0x0B
	call screen_print_color

	mov ah, 0x00
	int 0x1A
	mov ax, dx
	xor dx, dx
	mov cx, SLOGAN_COUNT
	div cx ; dx = dx % SLOGAN_COUNT

	shl dx, 1 ; dx * 2
	mov bx, dx
	mov si, [slogans_table + bx]

	mov dh, 6
	mov dl, 4
	mov bl, 0x0E
	call screen_print_color

	; A20 test (and enabling)
	call enable_a20
	test ax, ax
	jz .failed

	; Unreal mode
	call enable_unreal_mode
	test ax, ax
	jz .failed

	; test of disk reading through LBA
	mov eax, 0 ; LBA 0
	mov cx, 1 ; 1 sector
	mov bx, 0x9000 ; target buffer 0x0000:0x9000
	mov dl, [boot_drive]
	call disk_read_lba
	test ax, ax
	jz .failed

	mov dh, 8
	mov dl, 4
	call screen_set_cursor
	mov si, msg_disk_ok
	mov bl, 0x0A
	call screen_print_color

.continue:
	; next episode!

.hang:
	cli
	hlt
	jmp .hang

.failed:
	mov dh, 8
	mov dl, 4
	call screen_set_cursor
	mov si, msg_fatal_err
	mov bl, 0x0C
	call screen_print_color
	cli
	hlt
	jmp $

%include "src/stage2/io/screen.asm"
%include "src/stage2/lib/constants/boot.asm"
%include "src/stage2/kernel/unreal.asm"
%include "src/stage2/drivers/a20.asm"
%include "src/stage2/drivers/disk.asm"

msg_disk_ok: db 0x0D, 0x0A, "[OK] BIOS LBA Disk Extensions verified.", 0x0D, 0x0A, 0
msg_fatal_err: db 0x0D, 0x0A, "[FAIL] Fatal error! System halted.", 0x0D, 0x0A, 0
boot_drive: db 0
