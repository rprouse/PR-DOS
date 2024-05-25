; Ensures that we jump straight into the kernel's entry function
[bits 32]
[extern main]

section .text
    global _start

_start:
    jmp main       ; Jump to the kernel's entry function
    jmp $          ; Infinite loop
