ORG 0x7C00 ; origin
BITS 16 ; architecture

start:
	mov ah, 0eh
	mov al, 'A'
	mov bx, 0
	int 0x10

	jmp $

times 510-($ - $$) db 0 ; pad to 510 bytes
dw 0xAA55 ; set magic bytes