;
; A boot sector that just prints a message and hangs
;
[org 0x7c00]
  jmp start

%include "print.asm"
%include "disk.asm"

start:
  mov [BOOT_DRIVE], dl ; BIOS stores the boot drive in dl

  mov bx, BOOT_MSG
  call print_string

  mov bx, CMD_LINE
  call print_string

  ; Read some sectors from the boot disk
  mov bx, 0x8000  ; Set the stack out of the way to 0x8000
  mov sp, bp      ; Note we cannot use an absolute address here

  mov bx, 0x9000  ; Load 5 sectors to 0x0000(ES):0x9000(BX)
  mov dh, 5       ; from the boot disk
  mov dl, [BOOT_DRIVE]
  call disk_load

  mov dx, [0x9000] ; Print the first word of the loaded sector
  call print_hex_nl

  mov dx, [0x9000 + 512] ; Print the first word from the second sector
  call print_hex_nl

end:
  jmp $               ; Hang

; Data
BOOT_DRIVE db 0
BOOT_MSG db 'PR-DOS v0.1 2024',0x0D,0x0A,0
CMD_LINE db 'A:\> ',0x0D,0x0A,0

; Bootsector padding
  times 510-($-$$) db 0

; Boot sector magic number
magic_number:
  dw 0xAA55

; We know that BIOS will load only the first 512-byte sector from the disk ,
; so if we purposely add a few more sectors to our code by repeating some
; familiar numbers , we can prove to ourselfs that we actually loaded those
; additional two sectors from the disk we booted from.
times 256 dw 0xDEAD
times 256 dw 0xFACE
