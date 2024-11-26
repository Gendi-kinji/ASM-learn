section .bss
    array resb 5                 ; Reserve 5 bytes for the array
    buffer resb 15               ; Reserve buffer for reading input (includes spaces)
    out_buffer resb 10           ; Buffer for output (ASCII digits and spaces)

section .data
    prompt db 'Enter 5 integers (0-9) separated by space: ', 0
    prompt_len equ $ - prompt
    newline db 10, 0

section .text
    global _start

_start:
    ; Print the prompt
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; file descriptor 1 (stdout)
    mov ecx, prompt               ; message to write
    mov edx, prompt_len           ; message length
    int 0x80

    ; Read user input
    mov eax, 3                    ; sys_read
    mov ebx, 0                    ; file descriptor 0 (stdin)
    mov ecx, buffer               ; buffer to store input
    mov edx, 15                   ; number of bytes to read (including spaces)
    int 0x80

    ; Convert input to array of integers
    mov esi, buffer               ; ESI points to input buffer
    mov edi, array                ; EDI points to array
    mov ecx, 5                    ; We expect 5 integers
convert_loop:
    mov al, [esi]                 ; Load byte from buffer
    cmp al, ' '                   ; Check if it's a space
    je skip_space                 ; If space, skip to next character
    sub al, '0'                   ; Convert ASCII to integer
    mov [edi], al                 ; Store integer in array
    inc edi                       ; Move to next position in array
    dec ecx                       ; Decrement counter
    jz finish_conversion          ; If we've converted 5 integers, finish
skip_space:
    inc esi                       ; Move to next character in buffer
    jmp convert_loop              ; Repeat conversion loop
finish_conversion:

    ; Initialize pointers for reversing
    mov esi, array                ; ESI points to start of array
    mov edi, array                ; EDI points to start of array
    add edi, 4                    ; EDI points to end of array (0-based index)
    mov ecx, 2                    ; Loop counter (5/2 = 2 iterations)

reverse_loop:
    ; Swap the elements at the current positions
    mov al, [esi]                 ; Load byte at ESI into AL
    mov bl, [edi]                 ; Load byte at EDI into BL
    mov [esi], bl                 ; Store BL at the location of ESI
    mov [edi], al                 ; Store AL at the location of EDI

    ; Move the pointers towards the center
    inc esi                       ; Move ESI to the next element
    dec edi                       ; Move EDI to the previous element

    ; Decrement the loop counter
    dec ecx                       ; Decrement ECX
    jnz reverse_loop              ; Repeat the loop

    ; Convert reversed array to ASCII for output
    mov esi, array                ; ESI points to start of array
    mov edi, out_buffer           ; EDI points to output buffer
    mov ecx, 5                    ; Loop counter for 5 integers
convert_to_ascii:
    mov al, [esi]                 ; Load integer from array
    add al, '0'                   ; Convert to ASCII
    mov [edi], al                 ; Store ASCII character in output buffer
    inc esi                       ; Move to next integer in array
    inc edi                       ; Move to next position in output buffer
    mov byte [edi], ' '           ; Add space after the digit
    inc edi                       ; Move to next position
    dec ecx                       ; Decrement loop counter
    jnz convert_to_ascii          ; Repeat until all integers are processed
    dec edi                       ; Remove last space
    mov byte [edi], 10            ; Add newline character

    ; Output the reversed array
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; file descriptor 1 (stdout)
    mov ecx, out_buffer           ; Address of the output buffer
    mov edx, 10                   ; Number of bytes to write (5 digits + 4 spaces + newline)
    int 0x80

    ; Exit the program
    mov eax, 1                    ; sys_exit
    xor ebx, ebx                  ; Return code 0
    int 0x80                      ; Make the syscall