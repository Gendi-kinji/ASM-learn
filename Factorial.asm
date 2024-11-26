section .data
    prompt db "Enter a number: ", 0xA, 0
    result_msg db "Factorial is: ", 10, 0

section .bss
    number resb 15
    result resd 0
    output resb 20            ; Buffer for output string

section .text
global _start

_start:
    ; Print the prompt message
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 17
    int 0x80

    ; Input number
    mov eax, 3
    mov ebx, 0
    mov ecx, number
    mov edx, 15
    int 0x80

    ; Convert input to integer
    mov esi, number
    xor eax, eax
    xor ecx, ecx
parse_input:
    movzx ecx, byte [esi]
    cmp ecx, 0xA
    je calculate_factorial
    sub ecx, '0'
    imul eax, eax, 10
    add eax, ecx
    inc esi
    jmp parse_input

calculate_factorial:
    mov [result], eax           ; Store the input number in result
    mov ebx, eax                ; Copy the input number to ebx
    dec ebx                     ; Decrement ebx (n-1)
    jz print_result             ; If input number is 1, skip calculation

factorial_loop:
    imul eax, ebx               ; Multiply eax by ebx
    dec ebx                     ; Decrement ebx
    jnz factorial_loop          ; Repeat until ebx is 0

    mov [result], eax           ; Store the result in memory

print_result:
    ; Print the result message
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, 15
    int 0x80

    ; Convert the result to ASCII and print
    mov eax, [result]
    mov edi, output + 20        ; Point to the end of the buffer
    call int_to_ascii

    ; Calculate the length of the string
    mov ecx, output + 20        ; End of the buffer
    sub ecx, edi                ; Calculate length
    mov edx, ecx                ; Move length to edx

    ; Print the result
    mov eax, 4
    mov ebx, 1
    mov ecx, edi 
    mov edx, ecx               ; Length of the output buffer
    int 0x80

    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Subroutine: Convert integer in eax to ASCII string
int_to_ascii:
    xor ecx, ecx              ; Clear ecx (digit counter)
    mov ebx, 10               ; Base 10
convert_loop:
    xor edx, edx              ; Clear remainder
    div ebx                   ; Divide eax by 10
    add dl, '0'               ; Convert remainder to ASCII
    dec edi                   ; Move buffer pointer backward
    mov [edi], dl             ; Store ASCII character
    inc ecx                   ; Increment digit count
    test eax, eax             ; Check if quotient is 0
    jnz convert_loop          ; Repeat if not zero
    sub edi, ecx              ; Adjust pointer to start of string
    ret