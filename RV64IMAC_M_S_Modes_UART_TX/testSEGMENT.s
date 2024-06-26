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
    li gp, SEG_BASE
    li a0, 3

  print: 
    sb a0, 0(gp)
    li s0, 10000000

  wait:
    addi s0, s0, -1
    bnez s0, wait
    addi a0, a0, -1
    bnez a0, print
    sb a0, 0(gp)
    li a7, 3

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