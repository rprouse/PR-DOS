%ifndef _print_h_
%define _print_h_

; Prints a string pointed to by the BX register using the BIOS
print_string:
    pusha
    mov si, bx      ; si = bx
    mov ah, 0x0E    ; int =10/ah=0x0e -> BIOS teletype function
.loop:
    lodsb           ; load byte from si into al and increments si
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

; Prints the value of DX as a hexadecimal number
print_hex:
    pusha
    mov ah, 0x0E      ; int =10/ah=0x0e -> BIOS teletype function
    mov al, '0'
    int 0x10
    mov al, 'x'
    int 0x10
    mov ecx, 4        ; 4 nibbles in a word
.next_digit:
    mov ax, dx
    and ax, 0x000F
    cmp ax, 10
    jl .is_digit
    add al, 'A' - 10
    jmp .print
.is_digit:
    add al, '0'
.print:
    mov ah, 0x0E      ; int =10/ah=0x0e -> BIOS teletype function
    int 0x10
    shr dx, 4
    loop .next_digit  ; loop until all nibbles are printed
    popa
    ret

HEX_OUT: db "0x0000", 0

%endif
