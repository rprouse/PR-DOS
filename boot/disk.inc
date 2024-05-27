%ifndef _DISK_INC_
%define _DISK_INC_

%include "print.inc"

bits 16

; =============== Constants ===============
; BIOS interrupt functions
INT_DISK    equ 0x13
DISK_READ   equ 0x02

; =============== FUNCTIONS ===============
; Convert a logical sector number to CHS address
; Params:
;   AX = logical sector number
; Return:
;   CX [bit 0-5]:  sector number
;   CX [bit 6-15]: cylinder number
;   DH:            head number
lba_to_chs:
    push ax
    push dx

    xor dx, dx                        ; DX = 0
    div word [bpb_sectors_per_track]  ; AX = LBA / sectors_per_track
                                    ; DX = LBA % sectors_per_track

    inc dx                            ; LBA is 0-based
    mov cx, dx                        ; CX = sector

    xor dx, dx                        ; DX = 0
    div word [bpb_heads]              ; AX = (LBA / sectors_per_track) / heads = cylinder
                                      ; DX = (LBA / sectors_per_track) % heads = head

    mov dh, dl                        ; DH = head
    mov ch, al                        ; CH = cylinder (lower 8 bits)
    shl ah, 6
    or  cl, ah                        ; Put the upper two bits of cylinder in CL

    pop ax
    mov dl, al
    pop ax

    ret

; Read sectors from disk
; Params:
;   ax: LBA address
;   cl: number of sectors to read (1-128)
;   dl: drive number (0x00-0x7F)
;   es:bx: buffer address
disk_read:
    push ax                             ; save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                             ; save number of sectors to read
    call lba_to_chs
    pop ax                              ; restore number of sectors to Read to AX
    mov ah, DISK_READ
    mov di, 3                           ; retry counter
.retry:
    pusha
    stc                                ; set carry flag, some BIOSes require this
    int INT_DISK
    jnc .success

    ; Disk read error
    popa
    call .disk_reset
    dec di
    test di, di
    jnz .retry                          ; retry

.fail:
    mov bx, disk_error_msg
    call print_string
    jmp wait_key_and_reboot

.success:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; restore registers modified
    ret

.disk_reset:
    pusha
    mov ah, 0
    stc
    int INT_DISK
    jne .fail
    popa
    ret

wait_key_and_reboot:
    mov ah, 0
    int 0x16
    jmp 0xFFFF:0                        ; reboot by jumping to beginning of BIOS ROM

; =============== VARIABLES ===============
disk_error_msg db "Disk read error!", CR, LF, 0

%endif ; _DISK_INC_
