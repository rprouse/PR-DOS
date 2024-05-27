; ==============================================================================
; A boot sector that enters protected mode
;
bits 16
org 0x7C00
kernel_offet equ 0x1000

  jmp start_rm

; ==============================================================================
; Start real mode
start_rm:
    mov [boot_drive], dl    ; Save boot drive

    mov ax, 0x0000          ; Set up segments
    mov ds, ax
    mov es, ax

    mov bp, 0x7C00          ; Set up stack. It grows downwards
    mov sp, bp

    mov bx, msg_real_mode
    call print_string       ; Print message using 16-bit real mode

    call load_kernel        ; Load the kernel

    call switch_to_pm       ; Switch to protected mode

%include "print.inc"
%include "print_pm.inc"
%include "disk.inc"
%include "protected_mode.inc"

bits 16
load_kernel:
    mov bx, msg_load_kernel
    call print_string

    mov bx, kernel_offet    ; Set up parameters for disk load
    mov dh, 15              ; Head
    mov dl, [boot_drive]    ; Boot drive
    call disk_load

    ret

; ==============================================================================
; Start protected mode
bits 32
start_pm:
    mov bx, msg_prot_mode
    call print_string_pm    ; Print message using 32-bit protected mode

    call kernel_offet       ; Call the kernel

end:
  jmp $                     ; Hang

; ==============================================================================
; Data
; Global variables
boot_drive      db 0
msg_real_mode   db " Started in 16-bit Real Mode " , 0
msg_prot_mode   db " Successfully landed in 32-bit Protected Mode " , 0
msg_load_kernel db " Loading Kernel " , 0

; ==============================================================================
times 510-($-$$) db 0    ; Pad the rest of the sector with zeros
dw 0xAA55                ; Boot signature
