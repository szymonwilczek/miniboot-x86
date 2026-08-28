%ifndef LIB_GDT_ASM
%define LIB_GDT_ASM

[bits 16]

gdt_start:
	; Null Descriptor
	dd 0x0
	dd 0x0

gdt_unreal_data:
	dw 0xFFFF    ; Low limit (bits 0-15)
	dw 0x0000    ; Low base (bits 0-15)
	db 0x00      ; Mid base (bits 16-23)
	db 10010010b ; Access (Present, Ring 0, Data, Writable)
	db 11001111b ; Flags / Limit (4KB, 32-bits operands, Limit 16-19)
	db 0x00      ; High base (bits 24-31

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; GDT limit (size - 1)
	dd gdt_start ; GDT base address (in Real Mode)

UNREAL_DATA_SEL equ gdt_unreal_data - gdt_start

%endif

