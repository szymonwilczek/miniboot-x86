[bits 16]           ; generate 16-bits instructions
[org 0x7C00]        ; BIOS loading this under that address in RAM

hello_string:
	db "Hello in this funny little bootloader!", 0x0D, 0x0A, 0

start:
	mov ah, 0x0E    ; BIOS: output character to the screen
	mov si, hello_string ; zaladuj stringa do rejestru si

write:
	; zaladowac do al wartosc wskaznika napisu si
	mov al, [si]
	; sprawdzic czy obecny wskaznik nie jest zerem
	cmp al, 0
	; jesli jest zerem, skocz do hang
	je hang
	; jesli nie jest zerem, wypisz
	int 0x10
	; oraz inkrementuj licznik
	inc si
	; wroc do funkcji start
	jmp write

hang:
	jmp hang

; fill out with zeros to 510 bytes
times 510 - ($ - $$) db 0

; bootable sector signature (last 2 bytes: 511, 512)
dw 0xAA55
