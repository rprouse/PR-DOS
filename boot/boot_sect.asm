; ==============================================================================
; A boot sector that enters protected mode
;
bits 16
org 0x7C00
KERNEL_OFFET equ 0x1000

; ==============================================================================
; Fat 12 boot record headers

; BPB (BIOS Parameter Block)
; https://wiki.osdev.org/FAT#BPB_.28BIOS_Parameter_Block.29
bpb:
  jmp short start_rm
  nop
bpb_oem_identifier:       db 'PRDOS1.0'   ; 8 bytes
bpb_bytes_per_sector:     dw 512
bpb_sectors_per_cluster:  db 1
bpb_reserved_sectors:     dw 1
bpb_number_fats:          db 2
bpb_root_entries:         dw 0x00E0
bpb_total_sectors:        dw 2880
bpb_media:                db 0xF0
bpb_sectors_per_fat:      dw 9
bpb_sectors_per_track:    dw 18
bpb_heads:                dw 2
bpb_hidden_sectors:       dd 0
bpb_large_sector_count:   dd 0

; EBPB (Extended Boot Record)
; https://wiki.osdev.org/FAT#Extended_Boot_Record
ebpb:
ebpb_drive_number:        db 0
ebpb_reserved:            db 0
ebpb_signature:           db 0x29
ebpb_volume_id:           dd 0xDEADBEEF
ebpb_volume_label:        db 'PR-DOS     '    ; 11 bytes
ebpb_filesystem:          db 'FAT12   '       ; 8 bytes

; ==============================================================================
; Start real mode
start_rm:
    mov ax, 0x0000          ; Set up segments
    mov ds, ax
    mov es, ax

    mov bp, 0x7C00          ; Set up stack. It grows downwards
    mov sp, bp

    mov bx, msg_real_mode
    call print_string       ; Print message using 16-bit real mode

    ; read data from the floppy disk
    mov [ebpb_drive_number], dl ; Save the boot drive number
    mov ax, 1                   ; LBA=1, second sector on the disk
    mov cl, 1                   ; 1 sector to read
    ; mov bx, bpb               ; Buffer to read into
    mov bx, 0x7E00              ; Buffer to read into
    call disk_read

    ;call load_kernel        ; Load the kernel

    ; call switch_to_pm       ; Switch to protected mode

    jmp $                    ; Hang

%include "print.inc"
%include "print_pm.inc"
%include "disk.inc"
%include "protected_mode.inc"

bits 16
; load_kernel:
;     mov bx, msg_load_kernel
;     call print_string

;     mov bx, KERNEL_OFFET    ; Set up parameters for disk load
;     mov dh, 15              ; Head
;     mov dl, [boot_drive]    ; Boot drive
;     call disk_load

;     ret

; ==============================================================================
; Start protected mode
bits 32
start_pm:
    mov bx, msg_prot_mode
    call print_string_pm    ; Print message using 32-bit protected mode

    call KERNEL_OFFET       ; Call the kernel

end:
  jmp $                     ; Hang

; ==============================================================================
; Data
; Global variables
msg_real_mode   db "Started in 16-bit Real Mode ", CR, LF, 0
msg_prot_mode   db "Successfully landed in 32-bit Protected Mode " , 0
msg_load_kernel db "Loading Kernel...", CR, LF , 0

; ==============================================================================
times 510-($-$$) db 0    ; Pad the rest of the sector with zeros
dw 0xAA55                ; Boot signature
