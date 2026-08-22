handle_command:
	.help:
		mov si, cmd_buffer
		mov di, cmd_help
		mov cx, max_command_chars
		call strncmp
		jne .unknown
		mov si, msg_help
		call print_string
		jmp new_command_reset

	.unknown:
		mov si, msg_unknown
		call print_string
		jmp new_command_reset

new_command_reset:
	mov di, cmd_buffer
	xor cx, cx
	ret





; COMMANDS STRINGS
cmd_help: db "help", 0
msg_help: db "Available commands: help", 0x0D, 0x0A, 0
msg_unknown: db "Unknown command, type: help", 0x0D, 0x0A, 0

