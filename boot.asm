ORG 0x7C00 ; origin
BITS 16 ; architecture

start:
	mov si, message
	call print
	jmp $

print:
	mov bx, 0
.loop:
	lodsb ; increment index in message by one, load into register al
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