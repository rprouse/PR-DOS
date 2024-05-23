%ifndef _PRINT32_H_
%define _PRINT32_H_

[bits 32]

; Define constants
video_memory equ 0xb8000
white_on_black equ 0x0f

; Print a null-terminated string at EBX to the screen pointed to by EDX
; This function will always write to the top-left corner of the screen
; but it is good enough until we jump to a higher level language
print_string_pm:
    pusha
    mov edx, video_memory  ; Set edx to the start of video memory

print_string_pm_loop:
    mov al, [ebx]          ; Store the current character in al
    mov ah, white_on_black ; Store the attribute byte in ah

    cmp al, 0              ; Check if the current character is null
    je print_string_pm_done

    mov [edx], ax          ; Store the character and attribute at the current
                           ; position in video memory

    inc ebx                ; Move to the next character in the string
    add edx, 2             ; Move to the next position in video memory

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret

%endif ; _PRINT32_H_
