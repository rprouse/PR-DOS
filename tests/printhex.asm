%include "io.inc"

section .data

hex_out: db '0x'
hex_val: db '0000', 0

section .text
global main
main:
    mov ebp, esp ; for correct debugging
    mov dx, 0x89AB
    call print_hex
    NEWLINE ; print newline
    xor eax, eax ; set eax to 0
    ret ; return

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
    PRINT_STRING hex_out
    popa
    ret
