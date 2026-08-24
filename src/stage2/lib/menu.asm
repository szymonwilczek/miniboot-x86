run_boot_menu:
	.menu_loop:
		; clear screen
		mov ax, 0x0003
		int 0x10

		mov si, navigation_hint
		call print_string
		call print_enter
		call print_enter

		mov cx, 0 ; draw loop counter
		.item_loop:
			cmp cx, MENU_COUNT
			je .handle_keyboard
			cmp [selected_item], cl
			je .selected
			jne .not_selected
			.selected:
				mov si, selected_mark
				call print_string
				jmp .continue
			.not_selected:
				mov si, not_selected_mark
				call print_string
				jmp .continue
			.continue:
				; offset calculation
				mov bx, cx
				add bx, bx
				mov dx, [menu_table + bx]
				mov si, dx
				call print_string
				call print_enter
				inc cx ; next item
				jmp .item_loop

		.handle_keyboard:
			mov ah, 0x00
			int 0x16

			cmp al, 0x0D
			je .dispatch_action

			cmp ah, 0x48 ; arrow up
			je .arrow_up

			cmp ah, 0x50 ; arrow down
			je .arrow_down

			jmp .menu_loop

			.arrow_up:
				cmp byte [selected_item], 0
				ja .decrement
				jmp .menu_loop
				.decrement:
					dec byte [selected_item]
				jmp .menu_loop

			.arrow_down:
				mov bx, MENU_COUNT
				sub bx, 1
				cmp [selected_item], bl
				jb .increment
				jmp .menu_loop
				.increment:
					inc byte [selected_item]
				jmp .menu_loop



	.dispatch_action:
		; clear screen
		mov ax, 0x0003
		int 0x10

		mov al, [selected_item]
		cmp al, 0
		je .boot_linux
		cmp al, 1
		je .start_shell
		cmp al, 2
		je .setup_utility
		cmp al, 3
		je .reboot_machine
	
.boot_linux:
	jmp linux_loader
.start_shell:
	call init_keyboard
.setup_utility:
	jmp $
.reboot_machine:
	int 0x19

%include "src/stage2/lib/constants/menu.asm"
