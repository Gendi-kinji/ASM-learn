section .data
    prompt db "Enter a number: ", 0
    positive_msg db "POSITIVE", 10, 0
    negative_msg db "NEGATIVE", 10, 0
    zero_msg db "ZERO", 10, 0

section .bss
    number resd 1               ; Reserve space for 1 integer

section .text
global _start

_start:
    ; Step 1: Prompt the user for input
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, prompt              ; address of the prompt string
    mov rdx, 16                  ; length of the prompt string
    syscall

    ; Read user input (number)
    mov rax, 0                   ; syscall: read
    mov rdi, 0                   ; file descriptor: stdin
    lea rsi, [number]            ; address of the number variable
    mov rdx, 4                   ; read 4 bytes (size of an integer)
    syscall

    ; Step 2: Classify the number
    mov eax, [number]            ; Load the user input into eax

    cmp eax, 0                   ; Compare the number with 0
    je zero_case                 ; If the number is 0, jump to zero_case

    jg positive_case             ; If the number is greater than 0, jump to positive_case

negative_case:
    ; Handle negative case
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, negative_msg        ; message to print
    mov rdx, 8                   ; length of the message ("NEGATIVE")
    syscall
    jmp done                     ; Unconditional jump to the end

positive_case:
    ; Handle positive case
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, positive_msg        ; message to print
    mov rdx, 8                   ; length of the message ("POSITIVE")
    syscall
    jmp done                     ; Unconditional jump to the end

zero_case:
    ; Handle zero case
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, zero_msg            ; message to print
    mov rdx, 4                   ; length of the message ("ZERO")
    syscall

done:
    ; Exit the program
    mov rax, 60                  ; syscall: exit
    xor rdi, rdi                 ; exit code 0
    syscall
