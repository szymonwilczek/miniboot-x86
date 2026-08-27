%ifndef DRIVERS_UNREAL
%define DRIVERS_UNREAL

[bits 16]
enter_unreal_mode:
	push ds
	push es

	cli ; turn off BIOS interrupts
	lgdt [gdt_descriptor] ; load GDT with 4GB limit

	; turn on Protected Mode (just for a sec)
	mov eax, cr0
	or al, 1
	mov cr0, eax

	; load HIDDEN segment cache with 4GB descriptor (0x10 selector)
	mov bx, 0x10
	mov ds, bx
	mov es, bx

	; turn off Protected Mode (back to the 16-bit Real Mode baby)
	mov eax, cr0
	and al, 0xFE
	mov cr0, eax

	pop es
	pop ds
	sti ; turn on BIOS interrupts
	ret

align 8
gdt_start:
	; 0x00: Null Descriptor (x86 requirement)
	dd 0x00000000
	dd 0x00000000

	; 0x08: 32-bit Code Segment (Base=0, Limit=4GB)
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 10011010b
	db 11001111b
	db 0x00

	; 0x10: 32bit Data Descriptor (4GB limit, base 0)
	dw 0xFFFF    ; limit 0..15
	dw 0x0000    ; base 0..15
	db 0x00      ; base 16..23
	db 10010010b ; P=1, DPL=0, Type=Data, Writable
	db 11001111b ; G=1 (4KB blocks), Big=1 (32bit) + Limit 16..19
	db 0x00      ; base 24..31
gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; GDT size - 1
	dd gdt_start               ; physical address of GDT table

%endif
