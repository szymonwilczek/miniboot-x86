; STRINGS
title_string:
	db "Hello in this funny little bootloader!", 0x0D, 0x0A, 0
subtitle_string:
	db "I guess we are doing things kind of modular now", 0x0D, 0x0A, 0

boot_logo:
	db " __  __ ___ _  _ ___ ___  ___   ___ _____", 0x0D, 0x0A
 	db "|  \/  |_ _| \| |_ _| _ )/ _ \ / _ \_   _|", 0x0D, 0x0A
 	db "| |\/| || || .` || || _ \ (_) | (_) || |", 0x0D, 0x0A
 	db "|_|  |_|___|_|\_|___|___/\___/ \___/ |_|", 0x0D, 0x0A
	db 0x0D, 0x0A, 0

slogan_0: db "Your mini friend for big boot", 0x0D, 0x0A, 0
slogan_1: db "Small footprint, big ambitions", 0x0D, 0x0A, 0
slogan_2: db "A boot-iful way to start", 0x0D, 0x0A, 0
slogan_3: db "To boot or not to boot?", 0x0D, 0x0A, 0
slogan_4: db "Sector zero, but #1 hero", 0x0D, 0x0A, 0
slogan_5: db "Big loader energy, whole 16 bits...", 0x0D, 0x0A, 0
slogan_6: db "Waking up at 0x7C00 everyday", 0x0D, 0x0A, 0
slogan_7: db "Look ma! No OS!", 0x0D, 0x0A, 0
slogan_8: db "I want to put on my, my, my, my, my bootin' shoes!", 0x0D, 0x0A, 0
slogan_9: db "Just a warm hug for your processor :)", 0x0D, 0x0A, 0
slogan_10: db "Your friendly neighborhood miniboot.", 0x0D, 0x0A, 0
slogan_11: db "You know, I am something of a bootloader myself.", 0x0D, 0x0A, 0
slogan_12: db "I can do this all day. Literally, I loop.", 0x0D, 0x0A, 0
slogan_13: db "And I am... Iron Boot *snaps into 32-bit mode*", 0x0D, 0x0A, 0
slogan_14: db "Don't blink, or you'll miss the entire boot sequence!", 0x0D, 0x0A, 0

SLOGAN_COUNT equ 15
slogans_table:
	dw slogan_0
	dw slogan_1
	dw slogan_2
	dw slogan_3
	dw slogan_4
	dw slogan_5
	dw slogan_6
	dw slogan_7
	dw slogan_8
	dw slogan_9
	dw slogan_10
	dw slogan_11
	dw slogan_12
	dw slogan_13
	dw slogan_14

; INTEGERS
cmd_buffer: equ 0x7E00
max_command_chars: equ 32

