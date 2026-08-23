[bits 16]
[org 0x8000]

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00

	call print_boot_logo

	call run_boot_menu
hang:
	jmp hang

%include "src/stage2/lib/string.asm"
%include "src/stage2/lib/constants.asm"
%include "src/stage2/lib/menu.asm"
%include "src/stage2/drivers/print.asm"
%include "src/stage2/drivers/keyboard.asm"
%include "src/stage2/shell/commands.asm"
