.section .text

.global _uart_init

    MTIME_BASE = 0x2000BFF8
    MTIMECMP_BASE = 0x2004000
    UART_BASE = 0x10000000
    GPIOU_BASE = 0x20000000
    GPIOL_BASE = 0x20000008
    BUT1_BASE  = 0x20000010
    BUT2_BASE  = 0x20000018
    BUT3_BASE  = 0x20000020
    LED_BASE = 0x30000000
    SEG_BASE = 0x40000000
    PHYS_MEM  = 0x80000000
    UART_THR_OFFSET = 0

_main:
    ########################
    li gp, UART_BASE
    li s10, GPIOU_BASE
    li s11, GPIOL_BASE

    lb s0, 0(s10)
    lb s1, 0(s11)

    li t0, 'G'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'A'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'f'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ','
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'G'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'l'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'W'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'E'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'C'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'E'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'A'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'S'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'U'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'W'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'A'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'h'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ','
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'R'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ','
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'O'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ','
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'H'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'b'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ','
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'A'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'b'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'l'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'h'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ','
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'B'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'h'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'y'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'W'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'w'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'c'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'y'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'R'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'I'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'S'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'C'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'V'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'F'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'P'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'g'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'A'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'h'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'c'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'O'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'p'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)

    li t1, BUT1_BASE
wait_program_1:
    ld t0, 0(t1)
    beqz t0, wait_program_1
    
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
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
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
    li t0, ':'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
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
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)

    li t3, BUT3_BASE
    j wait_for_button_3

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

wait_for_button_3:
    lb s0, 0(t3)
    beqz s0, wait_for_button_3
    nop
    j start_timer_irq

start_timer_irq:
    li t0, 0b00001000
    csrw mstatus, t0                # set MIE (Machine Interrupt Enable) in mstatus
    li t0, 0b100010001000           # 
    csrw mie, t0                    # set MEIE(Machine External Interrupt Enable),MTIE(Machine Timer Interrupt Enable), and MSIE(Machine Software Interrupt Enable) in mie 
    la t0, interrupt_handler               
    csrw mtvec, t0                # set mtvec (trap_address) to interrupt_handler
    
    li t0, 'S'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'c'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'P'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'g'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'C'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'D'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'w'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 's'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'g'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'T'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'i'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'm'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'I'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'e'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'p'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, '\n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'S'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'a'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'r'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, ' '
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'C'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'u'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 't'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'd'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'o'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'w'
    sb t0, UART_THR_OFFSET(gp)
    li t0, 'n'
    sb t0, UART_THR_OFFSET(gp)
    li t0, '!'
    sb t0, UART_THR_OFFSET(gp)
    li a0, 9
    li a7, 3
    j wait_one_sec

wait_one_sec:
    li ra, MTIME_BASE       
    ld sp, 0(ra)                 
    li gp,10000000
    add sp, sp,gp                  
    li gp, MTIMECMP_BASE
    sd sp, 0(gp)
    li tp, SEG_BASE
    sd a0, 0(tp)

wait_for_interrupt:
  j wait_for_interrupt
     
interrupt_handler:
        # determine cause of interrupt   
        csrr sp, mcause                 # save mcause to sp
        li  gp, 0x800000000000000b      # mcause for external interrupt
        li  t0, 0x8000000000000007      # mcause for timer interrupt
        beq sp, t0, timer_interrupt_handler    # cause is timer interrupt

timer_interrupt_handler:
        li sp, 0                       
        li gp, MTIME_BASE
        sd sp, 0(gp)                    # set MTIME_BASE to all 0s
        addi a0,a0,-1
        beqz a0, blinking_led
        j wait_one_sec
  
  blinking_led:
    beqz a7, loop
    call turn_on_led
    li s8, 6000000

    nop_loop_1:
    addi s8, s8, -1
    bnez s8, nop_loop_1

    call turn_off_led
    li s8, 6000000
    nop_loop_2:
    addi s8, s8, -1
    bnez s8, nop_loop_2

    addi a7, a7, -1
    j blinking_led

  turn_on_led:
    li gp, LED_BASE
    li s0, 65535
    sd s0, 0(gp)
    ret
  
  turn_off_led:
    li gp, LED_BASE
    li s0, 0
    sd s0, 0(gp)
    ret

  loop:
    j loop