section .data
    prompt db 'Give number between 1 and 10: ', 0
    result_msg db 'The factorial is: ', 0
    newline db 0x0A, 0  ; Newline character for formatting
    error_msg db 'Invalid input. Enter a number between 1 and 10.', 0

section .bss
    buffer resb 4  ; Buffer to store the input number as a string
    input_num resb 1  ; Store the converted input number
    factorial_result resd 1  ; Store the result of the factorial

section .text
    global _start

_start:
    ; Print the prompt message
    mov eax, 4                ; syscall number for sys_write
    mov ebx, 1                ; file descriptor (1 = stdout)
    lea ecx, [prompt]         ; load address of prompt
    mov edx, 29               ; length of the prompt string
    int 0x80                  ; Make the syscall to write to stdout

    ; Read the input from the user
    mov eax, 3                ; syscall number for sys_read
    mov ebx, 0                ; file descriptor (0 = stdin)
    lea ecx, [buffer]         ; load address of buffer
    mov edx, 4                ; number of bytes to read
    int 0x80                  ; Make the syscall to read from stdin

    ; Convert the input string to an integer
    mov eax, 0                ; Clear eax
    lea esi, [buffer]         ; Point to the buffer
    xor ebx, ebx              ; Clear ebx for multiplication
    mov bl, byte [esi]        ; Move the first byte to bl
    sub bl, '0'               ; Convert ASCII to integer
    mov [input_num], bl       ; Store the integer in input_num

    ; Validate the input (must be between 1 and 10)
    cmp byte [input_num], 1
    jb .invalid_input         ; If less than 1, jump to invalid input
    cmp byte [input_num], 10
    ja .invalid_input         ; If greater than 10, jump to invalid input

    ; Calculate the factorial
    movzx eax, byte [input_num] ; Move the input number to eax
    call factorial
    ; The result (factorial) is now in eax
    mov [factorial_result], eax ; Store the result in factorial_result

    ; Print the result message
    mov eax, 4                ; syscall number for sys_write
    mov ebx, 1                ; file descriptor (1 = stdout)
    lea ecx, [result_msg]     ; load address of result_msg
    mov edx, 19               ; length of the result_msg string
    int 0x80                  ; Make the syscall to write to stdout

    ; Convert the result to a string
    lea edi, [buffer + 3]     ; Point to the end of the buffer
    mov byte [edi], 0x0A      ; Add a newline character at the end

    ; Call the conversion logic to convert the number in eax to string
    mov eax, [factorial_result]
    call convert

    ; Write the result to the console
    mov eax, 4                ; syscall number for sys_write
    mov ebx, 1                ; file descriptor (1 = stdout)
    lea ecx, [edi]            ; pointer to the string to be printed
    lea edx, [buffer + 4]     ; buffer length (4 bytes)
    sub edx, ecx              ; calculate length by subtracting addresses
    int 0x80                  ; Make the syscall to write to stdout

    ; Exit the program
    mov eax, 1                ; syscall number for sys_exit
    xor ebx, ebx              ; exit status 0
    int 0x80                  ; Make the syscall to exit

.invalid_input:
    ; Print the error message
    mov eax, 4                ; syscall number for sys_write
    mov ebx, 1                ; file descriptor (1 = stdout)
    lea ecx, [error_msg]      ; load address of error_msg
    mov edx, 39               ; length of the error_msg string
    int 0x80                  ; Make the syscall to write to stdout

    ; Exit the program
    mov eax, 1                ; syscall number for sys_exit
    xor ebx, ebx              ; exit status 0
    int 0x80                  ; Make the syscall to exit

; Factorial function using recursion
factorial:
    cmp eax, 1                ; Check if eax is 1 (base case)
    jz end_recursion          ; If eax == 1, jump to the end

    ; Save the current value of eax
    push eax

    ; Decrement eax and call factorial recursively
    dec eax
    call factorial

    ; Multiply the result returned in eax with the saved value of eax
    pop ebx
    imul eax, ebx             ; eax = eax * ebx

    ret

end_recursion:
    mov eax, 1                ; Return 1 when eax is 1 (base case)
    ret

; Conversion of eax to string (ASCII digits)
convert:
    dec edi                   ; Move buffer pointer backwards
    xor edx, edx              ; Clear edx for division
    mov ecx, 10               ; Base 10 for division
    div ecx                   ; Divide eax by 10, result in eax, remainder in edx
    add dl, '0'               ; Convert remainder to ASCII character
    mov [edi], dl             ; Store ASCII character in buffer
    test eax, eax             ; Check if eax is zero
    jnz convert               ; If eax is not zero, continue converting
    ret