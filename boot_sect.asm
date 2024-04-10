;
; A boot sector that just prints a message and hangs
;
[org 0x7c00]

start:
  mov bx, BOOT_MSG
  call print_string

  mov bx, CMD_LINE
  call print_string

end:
  jmp $               ; Hang

%include "print_string.asm"

; Data
BOOT_MSG db "PR-DOS v0.1 2024",0x0D,0x0A,0
CMD_LINE db "A:\> ", 0

; Padding and magic number
  times 510-($-$$) db 0

; Boot sector magic number
  dw 0xaa55