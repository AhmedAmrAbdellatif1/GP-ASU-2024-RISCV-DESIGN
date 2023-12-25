# Assembly code for testing RV64I pipelined processor

# Testing different instruction formats
    addi x8, x0, 10             # (0x0)
    addi x9, x0, 20             # (0x4)
    auipc x6, 0x100             # (0x8)
    sd x6, 0(x0)                # (0xc)
    ld x7, 0(x0)                # (0x10)
    add x10, x8, x9             # (0x14)  
    lui x5, 0x20000             # (0x18)
    bne x6, x7, -20             # (0x1c)
    addiw x4, x0, 18            # (0x20)
    sltu x3, x8, x9             # (0x24)


