%ifndef _PRINT_INC_
%define _PRINT_INC_

bits 16

; =============== Constants ===============
; BIOS interupt functions
; int 10h - Video Services
INT_VIDEO_SERVICE  equ 0x10
WRITE_TELETYPE     equ 0x0E

CR equ 0x0D
LF equ 0x0A

; Prints a string pointed to by the BX register using the BIOS
print_string:
    pusha
    mov si, bx      ; si = bx
    mov ah, WRITE_TELETYPE    ; int =10/ah=0x0e -> BIOS teletype function
.loop:
    lodsb           ; load byte from si into al and increments si
    cmp al, 0
    je .done
    int INT_VIDEO_SERVICE
    jmp .loop
.done:
    popa
    ret

; Prints the value of DX as a hexadecimal number followed by a newline
print_hex_nl:
    call print_hex
    ret

; Prints the value of DX as a hexadecimal number
print_hex:
    pusha
    mov ebx, hex_val+3  ; Point at the bytes to print
    mov ecx, 4          ; 4 nibbles in a word
.next_digit:
    mov ax, dx
    and ax, 0x000F
    cmp ax, 10
    jl .is_digit
    add al, 'A' - 10
    jmp .next
.is_digit:
    add al, '0'
.next:
    mov byte [ebx], al
    dec ebx
    shr dx, 4
    loop .next_digit  ; loop until all nibbles are printed
    mov bx, hex_out
    call print_string
    popa
    ret

; =============== Data ===============
hex_out: db '0x'
hex_val: db '0000', CR, LF, 0

%endif
