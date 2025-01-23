ORG 0 
BITS 16

_start:
    jmp short start ;ensures our code does not get written over by the BIOS.
    nop

times 33 db 0 ;fills in the BIOS parameter block

start:
    jmp 0x7c0:step2;this is where the bios loads the boot loader



step2:
    cli ;Clear interupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ;Enables interupts

    ;READING FROM DISK: FOR MORE INFO LOOK AT MIKE BROWN'S INTERRUPT LIST 13
    mov ah, 2 ;READ SECTOR COMMAND
    mov al, 1 ;ONE SECTOR TO READ
    mov ch, 0 ;CYLINDER LOW EIGHT BYTES
    mov cl, 2 ;READ SECTOR 2
    mov dh, 0 ;HEAD NUMBER TO READ FROM
    mov bx, buffer ;Loads memory address for the buffer label
    int 0x13
    jc error
    mov si, buffer
    call print
    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb ;moves whatever the SI register is pointing to into the AL register.
    cmp al, 0 ;Compares if the SI register loaded 0 into the AL register.
    je .done ;If AL is 0 then it will finish the subroutine.
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh ;why do we move 0eh in the ah register again?
    int 0x10
    ret

error_message: db 'Failed ot load sector', 0

times 510-($ - $$) db 0
dw 0xAA55 ;BOOT SIGNATURE: writes 0x5544 in the 511th and 512th bytes. The bios looks for this value at this position in RAM to indicate that it is a bootable device.

buffer:
