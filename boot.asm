ORG 0 ; origin
BITS 16 ; architecture

_start:
	jmp short entrypoint
	nop

times 33 db 0

entrypoint:
	jmp 0x7C0:start ; set code segment to 0x7C0

start:
	cli ; CLear Interrupts
	mov ax, 0x7C0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax ; set Stack Segment to 0
	mov sp, 0x7C00 ; set Stack Pointer to 0x7C00
	sti ; Enables Interrupts

	mov ah, 2 ; read sector command
	mov al, 1 ; read one sector
	mov ch, 0 ; cylinder number to 0
	mov cl, 2 ; read sector 2
	mov dh, 0 ; head number to 0
	mov bx, buffer
	int 0x13
	
	jc error

	mov si, buffer
	call print

	jmp $

error:
	mov si, error_message
	call print
	ret

print:
	mov bx, 0
.loop:
	lodsb ; increment index in message by one, load next character into register al
	cmp al, 0
	je .done
	call print_char
	jmp .loop
.done:
	ret

print_char:
	mov ah, 0eh
	int 0x10
	ret

error_message: db 'Failed to load sector'

times 510-($ - $$) db 0 ; pad to 510 bytes
dw 0xAA55 ; set magic bytes

buffer: