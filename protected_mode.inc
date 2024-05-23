%ifndef _PROTECTED_MODE_INC_
%define _PROTECTED_MODE_INC_

%include "gdt.inc"

[bits 16]
; Switch to protected mode (32-bit mode) from real mode (16-bit mode)
; This function is called from the bootloader
switch_to_pm:
    cli                     ; We must disable interrupts before switching to PM
                            ; and not re-enable them until we set up the protected
                            ; mode interrupt vector

    lgdt [gdt_descriptor]   ; Load the GDT

    mov eax, cr0            ; Get the value of CR0
    or eax, 0x1             ; Set the first bit of CR0 to 1
    mov cr0, eax            ; Load the value back to CR0

    jmp code_seg:init_pm    ; Jump to the next instruction in 32-bit mode
                            ; code_seg makes it a far jump to flush the prefetch

[bits 32]
init_pm:
    mov ax, data_seg        ; Load the data segment selector
    mov ds, ax              ; Set the data segment register
    mov ss, ax              ; Set the stack segment register
    mov es, ax              ; Set the extra segment register
    mov fs, ax              ; Set the fs segment register
    mov gs, ax              ; Set the gs segment register

    mov ebp, 0x90000        ; Set the stack pointer to 0x90000 which is the
    mov esp, ebp            ; top of the free space

    call start_pm           ; We can't return because the stack has changed,
                            ; so instead call back to the bootloader

%endif ; _PROTECTED_MODE_INC_
