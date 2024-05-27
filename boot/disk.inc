%ifndef _DISK_INC_
%define _DISK_INC_

%include "print.inc"

bits 16

; =============== Constants ===============
; BIOS interrupt functions
INT_DISK    equ 0x13
DISK_READ   equ 0x02

; load DH sectors to ES:BX from drive DL
disk_load:
  push dx         ; Store DX on stack so later we can recall
                  ; how many sectors were request to be read ,
                  ; even if it is altered in the meantime
  mov ah, DISK_READ
  mov al, dh      ; Read DH sectors
  mov ch, 0x00    ; Select cylinder 0
  mov dh, 0x00    ; Select head 0
  mov cl, 0x02    ; Start reading from second sector (i.e.
                  ; after the boot sector)
  int INT_DISK    ; BIOS interrupt
  jc disk_error   ; Jump if error (i.e. carry flag set)
  pop dx          ; Restore DX from the stack
  cmp dh, al      ; if AL (sectors read) != DH (sectors expected)
  jne disk_error  ; display error message
  ret
disk_error :
  mov bx, disk_error_msg
  call print_string
  jmp $

; =============== VARIABLES ===============
disk_error_msg db "Disk read error!", 0

%endif ; _DISK_INC_
