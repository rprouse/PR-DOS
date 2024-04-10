;
; Prints a string pointed to by the bx register using the BIOS
;
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