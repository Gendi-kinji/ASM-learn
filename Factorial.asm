section .data
    prompt db "Enter a number: ", 0
    result_msg db "Factorial is: ", 10, 0

section .bss
    number resd 1               ; Reserve space for 1 integer (input number)

section .text
global _start

_start:
    ; Step 1: Print prompt to ask for input
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, prompt              ; address of the prompt string
    mov rdx, 16                  ; length of the prompt string
    syscall

    ; Read user input (integer)
    mov rax, 0                   ; syscall: read
    mov rdi, 0                   ; file descriptor: stdin
    lea rsi, [number]            ; address of the number variable
    mov rdx, 4                   ; read 4 bytes (size of an integer)
    syscall

    ; Step 2: Compute the factorial of the input number
    mov eax, [number]            ; Load the number into eax (argument for factorial)
    call factorial               ; Call the factorial subroutine

    ; Step 3: Print the result message
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    mov rsi, result_msg          ; result message
    mov rdx, 15                  ; length of the result message
    syscall

    ; Step 4: Print the result (factorial in eax)
    mov rdi, eax                 ; Move the result to rdi for printing
    call print_int               ; Call print_int function to print the integer

    ; Exit program
    mov rax, 60                  ; syscall: exit
    xor rdi, rdi                 ; exit code 0
    syscall

; Factorial Subroutine: Computes factorial of a number in eax
factorial:
    cmp eax, 1                   ; Compare eax with 1
    jbe .base_case               ; If eax <= 1, jump to base case

    push rdi                      ; Save the value of rdi (n) on the stack
    dec eax                       ; Decrease eax (n = n-1)
    call factorial                ; Call factorial(n-1)
    pop rdi                       ; Restore the value of rdi (n)

    mul rdi                       ; Multiply eax by rdi (eax = eax * n)
    ret                           ; Return to the caller (main program)

.base_case:
    mov eax, 1                    ; Return 1 for base case (factorial(0) or factorial(1))
    ret                           ; Return to the caller (main program)

; Print Integer Subroutine: Prints an integer in rdi
print_int:
    push rbx                     ; Save rbx
    push rcx                     ; Save rcx
    push rdx                     ; Save rdx

    mov rbx, 10                  ; Base 10
    xor rcx, rcx                 ; Clear rcx (digit count)

.print_loop:
    xor rdx, rdx                 ; Clear rdx
    div rbx                      ; Divide rax by 10
    add dl, '0'                  ; Convert remainder to ASCII
    push rdx                     ; Save ASCII digit on the stack
    inc rcx                      ; Increment digit count
    test rax, rax                ; Check if quotient is zero
    jnz .print_loop              ; If not, repeat

.print_digits:
    pop rax                      ; Pop digit from the stack
    mov rsi, rsp                 ; Address of the digit
    mov rdx, 1                   ; Length of the digit
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; file descriptor: stdout
    syscall
    loop .print_digits           ; Repeat for all digits

    pop rdx                      ; Restore rdx
    pop rcx                      ; Restore rcx
    pop rbx                      ; Restore rbx
    ret                          ; Return to the caller (main program)
