section .data
    sensor_value dw 0        ; Simulated sensor value
    motor_status db 0        ; Motor status: 0 = OFF, 1 = ON
    alarm_status db 0        ; Alarm status: 0 = OFF, 1 = ON
    prompt_sensor db "Enter sensor value (0-100):", 0
    motor_on_msg db "Motor ON", 0
    motor_off_msg db "Motor OFF", 0
    alarm_on_msg db "Alarm ON", 0
    alarm_off_msg db "Alarm OFF", 0

section .bss
    input_buffer resb 4      ; Buffer for user input

section .text
    global _start

_start:
    ; Print sensor input prompt
    mov eax, 4               ; syscall: write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, prompt_sensor   ; pointer to message
    mov edx, 30              ; message length
    int 0x80

    ; Read user input for sensor value
    mov eax, 3               ; syscall: read
    mov ebx, 0               ; file descriptor: stdin
    mov ecx, input_buffer    ; buffer to store input
    mov edx, 4               ; buffer length
    int 0x80

    ; Convert input to integer
    mov esi, input_buffer    ; pointer to input buffer
    xor eax, eax             ; clear eax
    xor ecx, ecx             ; clear ecx
parse_input:
    movzx ecx, byte [esi]    ; load byte
    cmp ecx, 0xA             ; check for newline
    je process_sensor
    sub ecx, '0'             ; convert ASCII to integer
    imul eax, eax, 10        ; shift left by 10 (decimal)
    add eax, ecx             ; add digit
    inc esi                  ; move to next character
    jmp parse_input

process_sensor:
    mov [sensor_value], eax  ; Store the sensor value

    ; Check sensor value and take action
    mov ax, [sensor_value]   ; Load sensor value
    cmp ax, 30               ; Compare to low threshold
    jl activate_motor        ; If less than 30, activate motor

    cmp ax, 70               ; Compare to high threshold
    jg activate_alarm        ; If greater than 70, activate alarm

    ; Moderate level: stop motor
    jmp stop_motor

activate_motor:
    mov byte [motor_status], 1 ; Turn motor ON
    mov byte [alarm_status], 0 ; Ensure alarm is OFF
    jmp display_status

activate_alarm:
    mov byte [alarm_status], 1 ; Turn alarm ON
    mov byte [motor_status], 0 ; Ensure motor is OFF
    jmp display_status

stop_motor:
    mov byte [motor_status], 0 ; Turn motor OFF
    mov byte [alarm_status], 0 ; Ensure alarm is OFF

display_status:
    ; Display motor status
    cmp byte [motor_status], 1
    je print_motor_on
    jmp print_motor_off

print_motor_on:
    mov eax, 4               ; syscall: write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, motor_on_msg    ; pointer to message
    mov edx, 9               ; message length
    int 0x80
    jmp print_alarm_status

print_motor_off:
    mov eax, 4               ; syscall: write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, motor_off_msg   ; pointer to message
    mov edx, 10              ; message length
    int 0x80

print_alarm_status:
    ; Display alarm status
    cmp byte [alarm_status], 1
    je print_alarm_on
    jmp print_alarm_off

print_alarm_on:
    mov eax, 4               ; syscall: write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, alarm_on_msg    ; pointer to message
    mov edx, 9               ; message length
    int 0x80
    jmp exit_program

print_alarm_off:
    mov eax, 4               ; syscall: write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, alarm_off_msg   ; pointer to message
    mov edx, 10              ; message length
    int 0x80

exit_program:
    mov eax, 1               ; syscall: exit
    xor ebx, ebx             ; return code 0
    int 0x80