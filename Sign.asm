section .data
    prompt db "Enter a number: ", 0
    positive_msg db "POSITIVE", 0
    negative_msg db "NEGATIVE", 0
    zero_msg db "ZERO", 0

section .bss
    user_input resb 4 ; Reserve space for user input

section .text
    global _start

_start:
    ; Print the prompt
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, prompt        ; pointer to message
    mov edx, 15            ; message length
    int 0x80               ; call kernel

    ; Read input
    mov eax, 3             ; syscall: read
    mov ebx, 0             ; file descriptor: stdin
    mov ecx, user_input    ; buffer to store input
    mov edx, 4             ; buffer length
    int 0x80               ; call kernel

    ; Convert input to integer
    mov esi, user_input    ; pointer to input
    xor eax, eax           ; clear eax
    xor ecx, ecx           ; clear ecx
parse_input:
    movzx ecx, byte [esi]  ; load byte
    cmp ecx, 0xA           ; check for newline
    je classify_number
    sub ecx, '0'           ; convert ASCII to integer
    imul eax, eax, 10      ; shift left by 10 (decimal)
    add eax, ecx           ; add digit
    inc esi                ; move to next character
    jmp parse_input

classify_number:
    ; Check if number is zero
    cmp eax, 0
    je print_zero

    ; Check if number is positive
    jl print_negative

    ; If not negative, it’s positive
    jmp print_positive

print_zero:
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, zero_msg      ; pointer to message
    mov edx, 4             ; message length
    int 0x80               ; call kernel
    jmp exit_program       ; avoid fall-through

print_negative:
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, negative_msg  ; pointer to message
    mov edx, 8             ; message length
    int 0x80
    jmp exit_program

print_positive:
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, positive_msg  ; pointer to message
    mov edx, 8             ; message length
    int 0x80

exit_program:
    mov eax, 1             ; syscall: exit
    xor ebx, ebx           ; return code 0
    int 0x80