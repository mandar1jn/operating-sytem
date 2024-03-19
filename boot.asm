ORG 0 ; origin
BITS 16 ; architecture

_start:
	jmp short entrypoint
	nop

times 33 db 0

entrypoint:
	jmp 0x7C0:start ; set code segment to 0x7C0

handle_zero:
	mov ah, 0eh
	mov al, 'A'
	mov bx, 0x00
	int 0x10
	iret

start:
	cli ; CLear Interrupts
	mov ax, 0x7C0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax ; set Stack Segment to 0
	mov sp, 0x7C00 ; set Stack Pointer to 0x7C00
	sti ; Enables Interrupts

	mov word[ss:0x00], handle_zero
	mov word[ss:0x02], 0x7C0

	mov si, message
	call print
	jmp $

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

message: db 'Hello World!', 0

times 510-($ - $$) db 0 ; pad to 510 bytes
dw 0xAA55 ; set magic bytes