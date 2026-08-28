%ifndef KERNEL_UNREAL_ASM
%define KERNEL_UNREAL_ASM

[bits 16]

enable_unreal_mode:
	push es
	push ds

	cli ; turn OFF interrupts

	lgdt [gdt_descriptor] ; load GDT

	; temp turn ON Protected Mode
	mov eax, cr0
	or al, 1 ; set PE bit (Protected Mode Enable)
	mov cr0, eax

	; IMMEDIATELY load segment registers with 4GB selector
	; clever trick, ain't it?
	mov bx, UNREAL_DATA_SEL
	mov ds, bx
	mov es, bx

	; turn OFF Protected Mode (back to 16-bit)
	mov eax, cr0
	and al, 0xFE ; zero-out PE bit
	mov cr0, eax

	; segment normalization to Real Mode standard
	; 0x0000
	xor ax, ax
	mov ds, ax
	mov es, ax

	sti ; turn ON interrupts

	pop ds
	pop es
	mov ax, 1 ; AX = 1 (success)
	ret

%include "src/stage2/lib/gdt.asm"

%endif


