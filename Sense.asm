section .data
    threshold db 50              ; Threshold for water level (e.g., 50)
    motor_control db 0           ; Motor control bit (0 = off, 1 = on)
    alarm_control db 0           ; Alarm control bit (0 = off, 1 = triggered)
    sensor_value db 60           ; Simulated sensor value (e.g., 60)

section .text
global _start

_start:
    ; Step 1: Read the sensor value
    mov al, [sensor_value]      ; Load the sensor value into AL register for comparison

    ; Step 2: Compare sensor value with threshold
    movzx bl, byte [threshold]  ; Load the threshold value into BL (zero-extend)
    cmp al, bl                  ; Compare the sensor value (AL) with the threshold (BL)
                                 ; If AL <= BL, jump to .water_ok
    jbe .water_ok               ; Jump to water_ok if sensor value <= threshold

    ; Step 3: If water level is too high, turn on the motor and trigger alarm
    ; Turn on motor (set motor_control bit to 1)
    mov byte [motor_control], 1  ; Set motor_control to 1 (motor on)
    
    ; Trigger alarm (set alarm_control bit to 1)
    mov byte [alarm_control], 1  ; Set alarm_control to 1 (alarm triggered)

    ; Output motor and alarm status for testing
    movzx rdi, byte [motor_control] ; Move motor control value to rdi for output
    call print_int               ; Call print_int to display the motor control status
    movzx rdi, byte [alarm_control] ; Move alarm control value to rdi for output
    call print_int               ; Call print_int to display the alarm control status

    jmp .exit                    ; Exit the program

.water_ok:
    ; If the water level is ok, just output the status without turning on the motor or alarm
    mov byte [motor_control], 0  ; Ensure motor is off (set motor_control to 0)
    mov byte [alarm_control], 0  ; Ensure alarm is off (set alarm_control to 0)

    ; Output motor and alarm status for testing
    movzx rdi, byte [motor_control] ; Move motor control value to rdi for output
    call print_int               ; Call print_int to display the motor control status
    movzx rdi, byte [alarm_control] ; Move alarm control value to rdi for output
    call print_int               ; Call print_int to display the alarm control status

.exit:
    ; Exit the program
    mov rax, 60                  ; syscall: exit
    xor rdi, rdi                 ; exit code 0
    syscall

; Print Integer Subroutine: Prints an integer in rdi
print_int:
    push rbx                     ; Save rbx
    push rcx                     ; Save rcx
    push rdx                     ; Save rdx

    mov rax, rdi                 ; Move the integer to rax for division
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
