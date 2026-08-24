%ifndef CONSTANTS_DAP
%define CONSTANTS_DAP

KERNEL_LBA_START equ 64
SETUP_SEGMENT equ 0x1000
HEADER_MAGIC equ 0x53726448 ; HdrS

align 4
dap_packet:
	dap_size:	db 0x10  ; byte 0
	dap_reserved:	db 0x00  ; byte 1 (reserved, always 0x00)
	dap_count:	dw 0     ; byte 2-3 (number of sectors to load)
	dap_offset:	dw 0     ; byte 4-5 (offset in RAM)
	dap_segment:	dw 0     ; byte 6-7 (segment in RAM)
	dap_lba_low:	dd 0     ; byte 8-11 (low 32 bits of LBA sector number)
	dap_lba_high:	dd 0     ; byte 12-15 (high 32 bits of LBA sector number)

%endif
