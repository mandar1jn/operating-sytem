ORG 0x7c00 ; origin
BITS 16 ; architecture

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
	jmp short entrypoint
	nop

times 33 db 0

entrypoint:
	jmp 0:start ; set code segment to 0

start:
	cli ; CLear Interrupts
	mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov ss, ax ; set Stack Segment to 0
	mov sp, 0x00 ; set Stack Pointer to 0x7C00
	sti ; Enables Interrupts

load_protected:
	cli ; CLear Interrupts
	lgdt[gdt_descriptor] ; Load Global Descriptor Table
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:load32

; Global Descriptor Table
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0

; GDT offset 0x8
gdt_code: ; CS should point to this
	dw 0xFFFF ; Segment limit first 0-15 bits
	dw 0 ; Base first 0-15 bits
	db 0  ; Base 16-23 bits
	db 0x9A ; Access byte
	db 11001111b ; High 4 bit flags and low 4 bit flags
	db 0 ; Base 24-31 bits

; GDT offset 0x10
gdt_data:
	dw 0xFFFF ; Segment limit first 0-15 bits
	dw 0 ; Base first 0-15 bits
	db 0  ; Base 16-23 bits
	db 0x92 ; Access byte
	db 11001111b ; High 4 bit flags and low 4 bit flags
	db 0 ; Base 24-31 bits

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

[BITS 32]
load32:
	mov eax, 1
	mov ecx, 100
	mov edi, 0x0100000
	call ata_lba_read
	jmp CODE_SEG:0x0100000

ata_lba_read:
	mov ebx, eax ; Backup the LBA
	; Send the highest 8 bits of the LBA to the hard disk controller
	shr eax, 24
	or eax, 0xE0 ; Select the master drive
	mov dx, 0x1F6
	out dx, al
	; Finished sending the highest 8 bits of the LBA

	; Send the total amount of sectors to read
	mov eax, ecx
	mov dx, 0x1F2
	out dx, al
	; Finished sending the total amount of sectors to read

	; Send more bits of the LBA
	mov eax, ebx ; Restore the backup LBA
	mov dx, 0x1F3
	out dx, al
	; Finished sending more bits of the LBA

	; Send more bits of the LBA
	mov eax, ebx ; Restore the backup LBA
	mov dx, 0x1F4
	shr eax, 8
	out dx, al
	; Finished sending more bits of the LBA

	; Send upper 16 bits of the LBA
	mov eax, ebx ; Restore the backup LBA
	mov dx, 0x1F5
	shr eax, 16
	out dx, al
	; Finished sending the upper 16 bits of the LBA

	mov dx, 0x1F7
	mov al, 0x20
	out dx, al

	; Read all sectors into memory
.next_sector:
	push ecx

	; Check if we need to read
.check_read:
	mov dx, 0x1F7
	in al, dx
	test al, 8
	jz .check_read

	; Read 256 words
	mov ecx, 256
	mov dx, 0x1F0
	rep insw
	pop ecx
	loop .next_sector

	; Done reading sectors
	ret

times 510-($ - $$) db 0 ; pad to 510 bytes
dw 0xAA55 ; set magic bytes