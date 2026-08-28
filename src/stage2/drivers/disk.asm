%ifndef DRIVERS_DISK_ASM
%define DRIVERS_DISK_ASM

[bits 16]

; we are gonna have a little lecture right here.

; Read disk sectors through LBA (BIOS EDD int 0x13, ah 0x42)
; Input:
;	EAX - 64bit number of starting LBA sector
;	CX - numbers of sectors to read
;	ES:BX - buffer in RAM memory (segment:offset)
;	DL - number of boot drive
; Output:
;	AX = 1 - success
;	AX = 0 - error (reading error)

disk_read_lba:
	push si
	push dx

	; filling out DAP structure
	mov [dap_sectors], cx
	mov [dap_buf_offset], bx
	mov word [dap_buf_seg], es
	mov [dap_lba_low], eax
	mov dword [dap_lba_high], 0

	; calling out extended BIOS read
	mov si, disk_address_packet
	mov ah, 0x42
	int 0x13
	jc .error

	pop dx
	pop si
	mov ax, 1 ; AX = 1 (success)
	ret

.error:
	pop dx
	pop si
	xor ax, ax ; AX = 0
	ret


; DAP Structure (Disk Address Packet - 16 bytes)
align 4
disk_address_packet:
	dap_size: db 0x10     ; Packet size (always 16 bytes)
	dap_reserved: db 0x00 ; Always 0
	dap_sectors: dw 0     ; Number of sectors to load
	dap_buf_offset: dw 0  ; Offset of RAM buffer
	dap_buf_seg: dw 0     ; Segment of RAM buffer
	dap_lba_low: dd 0     ; LBA bits 0-31
	dap_lba_high: dd  0   ; LBA bits 32-63

%endif

