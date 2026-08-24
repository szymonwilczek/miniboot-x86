read_sectors_lba:
	push ax
	push cx
	push bx
	push es
	push di
	push dx

	mov [dap_count], ax
	mov [dap_offset], di
	mov [dap_segment], es

	mov [dap_lba_low], bx           ; first 2 bytes of LBA address
	mov [dap_lba_low + 2], cx       ; next 2 bytes of LBA address
	mov dword [dap_lba_high], 0

	mov si, dap_packet
	mov ah, 0x42
	int 0x13

	jc .disk_error
	pop dx
	pop di
	pop es
	pop bx
	pop cx
	pop ax
	ret

.disk_error:
	mov si, msg_disk_error
	call print_string
	cli
	hlt
	jmp $

msg_disk_error: db "FATAL: Disk read error (LBA Extended Read failed)!", 0x0D, 0x0A, 0
