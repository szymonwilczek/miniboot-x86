; STRINGS

title_string:
	db "Hello in this funny little bootloader!", 0x0D, 0x0A, 0
subtitle_string:
	db "I guess we are doing things kind of modular now", 0x0D, 0x0A, 0

; INTEGERS
cmd_buffer: equ 0x7E00
max_command_chars: equ 32

