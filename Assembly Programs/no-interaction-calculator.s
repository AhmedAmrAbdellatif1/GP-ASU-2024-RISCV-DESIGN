.section .text

.global _uart_init

    UART_BASE = 0x10000000
    PHYS_MEM  = 0x80000000
    UART_THR_OFFSET = 0

_main:
    li s0, 50
    li s1, 25
    li gp, UART_BASE

    li t0, 'O'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'p'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '1'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '='
    sb t0, UART_THR_OFFSET(gp)
    addi a0, s0, 0
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)

    li t0, 'O'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'p'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '2'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '='
    sb t0, UART_THR_OFFSET(gp)
    addi a0, s1, 0
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    
    li t0, 'A'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    add a0, s0, s1
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)


    li t0, 'M'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'l'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'p'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'l'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'y'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    mul a0, s0, s1
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)


    li t0, 'S'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'b'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'c'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    sub a0, s0, s1
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)


    li t0, 'D'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'v'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    div a0, s0, s1
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)


    li t0, 'R'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'E'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'M'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    rem a0, s0, s1
    call convert_init
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)

    j loop

convert_init:
    li t1, 10           # Divisor for decimal conversion
    li sp, PHYS_MEM     # Base address of the buffer array
    li t5, 0            # Initialize buffer index counter to 0
    bnez a0, convert_loop
    li t0, '0'
    sb t0, UART_THR_OFFSET(gp)
    ret

convert_loop:
    beqz a0, send_loop      # If binary number is zero, proceed to send
    addi sp, sp, 1          # Increment buffer pointer
    addi t5, t5, 1          # Increment buffer index counter
    rem t2, a0, t1          # Remainder of division by 10 (extracts next digit)
    addi t2, t2, '0'        # Convert digit to ASCII ('0' + digit)
    sb t2, 0(sp)            # Store ASCII character in buffer
    div a0, a0, t1          # Divide binary number by 10 to process next digit
    j convert_loop

send_loop:
    bltz t5, end_calcu         # If buffer index counter is less than zero, end
    lb a0, 0(sp)               # Load ASCII character from buffer
    sb a0, UART_THR_OFFSET(gp) # Send ASCII character via UART
    addi sp, sp, -1            # Decrement buffer pointer
    addi t5, t5, -1            # Decrement buffer index counter
    j send_loop

end_calcu:
    ret

loop:
    j loop