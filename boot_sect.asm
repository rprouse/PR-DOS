; ==============================================================================
; A boot sector that enters protected mode
;
[bits 16]
[org 0x7c00]
  jmp start_rm

; ==============================================================================
start_rm:
    mov bp, 0x9000      ; Set up stack
    mov sp, bp

    mov bx, msg_real_mode
    call print_string   ; Print message using 16-bit real mode

    call switch_to_pm   ; Switch to protected mode

%include "print.inc"
%include "print_pm.inc"
%include "disk.inc"
%include "protected_mode.inc"

[bits 32]
start_pm:
    mov bx, msg_prot_mode
    call print_string_pm ; Print message using 32-bit protected mode

end:
  jmp $               ; Hang

; ==============================================================================
; Data
; Global variables
msg_real_mode db " Started in 16-bit Real Mode " , 0
msg_prot_mode db " Successfully landed in 32-bit Protected Mode " , 0

; Bootsector padding
times 510-($-$$) db 0
dw 0xAA55
