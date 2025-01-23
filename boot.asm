ORG 0x7c00 
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start ;ensures our code does not get written over by the BIOS.
    nop

times 33 db 0 ;fills in the BIOS parameter block

start:
    jmp 0:step2;this is where the bios loads the boot loader



step2:
    cli ;Clear interupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ;Enables interupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32



;Creating the global descriptor table GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

;offset 0x8
gdt_code:     ;  CS should point to this
    dw 0xffff ;Segment limit first 0-15
    dw 0      ;base first 0-15 bits
    db 0      ;Base 16-23 bits  
    db 0x9a   ;Access byte  
    db 11001111b ;High 4 bit flags and low 4 bit flags
    db 0        ;base 24-31 bits

;offset 0x10
gdt_data:  ;Linked to DS, SS, ES, FS, GS 
    dw 0xffff ;Segment limit first 0-15
    dw 0      ;base first 0-15 bits
    db 0      ;Base 16-23 bits  
    db 0x92   ;Access byte  
    db 11001111b ;High 4 bit flags and low 4 bit flags
    db 0        ;base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    jmp $    

times 510-($ - $$) db 0
dw 0xAA55 ;BOOT SIGNATURE: writes 0x5544 in the 511th and 512th bytes. The bios looks for this value at this position in RAM to indicate that it is a bootable device.


