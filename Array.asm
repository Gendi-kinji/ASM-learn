section .data
    prompt db "Enter an integer: ", 0
    reversed_prompt db "Reversed array: ", 10, 0

section .bss
    array resd 5               ; Reserve space for 5 integers (4 bytes each)
    temp resd 1                ; Temporary storage for swapping values

section .text
global _start

_start:
    ; Step 1: Accept 5 integers from the user
    mov rbx, array             ; Load address of the array into rbx
    xor rcx, rcx               ; Clear rcx (counter to track the number of elements)

input_loop:
    cmp rcx, 5                 ; Compare counter with 5 (number of integers)
    je reverse_array           ; If we have 5 inputs, jump to reversal

    ; Print prompt
    mov rax, 1                 ; syscall: write
    mov rdi, 1                 ; file descriptor: stdout
    mov rsi, prompt            ; Address of the prompt string
    mov rdx, 18                ; Length of the prompt string
    syscall

    ; Read integer input (4 bytes)
    mov rax, 0                 ; syscall: read
    mov rdi, 0                 ; file descriptor: stdin
    lea rsi, [rbx]             ; Address of the current element in the array
    mov rdx, 4                 ; Read 4 bytes (integer size)
    syscall

    ; Move to the next element in the array
    add rbx, 4                 ; Increment the pointer to the next integer
    inc rcx                    ; Increment counter
    jmp input_loop             ; Repeat the input loop

reverse_array:
    ; Step 2: Reverse the array in place
    lea rbx, [array]           ; Load address of the first element (array[0])
    lea rcx, [array + 16]      ; Load address of the last element (array[4])

reverse_loop:
    cmp rbx, rcx               ; Compare pointers
    jge done_reverse           ; If the pointers have crossed, we're done

    ; Swap the values at [rbx] and [rcx]
    mov eax, [rbx]             ; Load value from the start (rbx)
    mov edx, [rcx]             ; Load value from the end (rcx)
    mov [rbx], edx             ; Store value from the end into the start
    mov [rcx], eax             ; Store value from the start into the end

    ; Move the pointers toward each other
    add rbx, 4                 ; Move rbx forward (next element)
    sub rcx, 4                 ; Move rcx backward (previous element)
    jmp reverse_loop           ; Repeat the loop

done_reverse:
    ; Step 3: Output the reversed array
    mov rbx, array             ; Reload address of the array (start)
    mov rcx, 5                 ; Number of elements to print

    ; Print reversed prompt
    mov rax, 1                 ; syscall: write
    mov rdi, 1                 ; file descriptor: stdout
    mov rsi, reversed_prompt   ; Address of the reversed prompt string
    mov rdx, 17                ; Length of the reversed prompt string
    syscall

output_loop:
    cmp rcx, 0                 ; Check if we've printed all elements
    je exit_program            ; If done, exit the program

    ; Print current array element (integer)
    mov eax, [rbx]             ; Load integer to print
    call print_int             ; Call print_int function to print the integer

    add rbx, 4                 ; Move to the next element
    dec rcx                    ; Decrement the counter
    jmp output_loop            ; Repeat the loop

exit_program:
    ; Exit program
    mov rax, 60                ; syscall: exit
    xor rdi, rdi               ; exit code 0
    syscall

print_int:
    ; Convert integer to string and print
    push rbx                   ; Save rbx
    push rcx                   ; Save rcx
    mov rbx, rsp               ; Use stack for temporary storage
    mov rcx, 10                ; Base 10
    xor rdx, rdx               ; Clear rdx

print_int_loop:
    div rcx                    ; Divide rax by 10
    add dl, '0'                ; Convert remainder to ASCII
    dec rbx                    ; Move pointer back
    mov [rbx], dl              ; Store ASCII character
    test rax, rax              ; Check if quotient is zero
    jnz print_int_loop         ; If not, repeat

    mov rdx, rsp               ; Set rdx to start of string
    sub rdx, rbx               ; Calculate string length
    mov rsi, rbx               ; Set rsi to start of string
    mov rax, 1                 ; syscall: write
    mov rdi, 1                 ; file descriptor: stdout
    syscall

    pop rcx                    ; Restore rcx
    pop rbx                    ; Restore rbx
    ret                        ; Return from function