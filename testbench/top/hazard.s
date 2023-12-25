# Hazards !!!
# case (1)
addi x8, x0, 15          # (0x3c)
sub x27, x8, x9          # (0x40)
or x29, x9, x8           # (0x44)
slliw x28, x9, 2         # (0x4c)
nop                      # (0x50)

# case (2)
addi x9, x0, 30          # (0x54)
add  x0, x9, x9          # (0x58)

# case (3)
lb x7, 0(x6)             # (0x5c)
add x4, x0, x7           # (0x60)

# case (4)
beq x0, x0, 16           # (0x64) Branch Taken : Flush --> F/D && D/E
addi x1, x2, 124         # (0x68)
addi x1, x2, 125         # (0x6c)
addi x1, x2, 127         # (0x70) 
addi x1, x0, 10          # (0x74)

# case (5)
 jal x5, 8                  # (0xc)    jump will be taken 
 nop                        # (0xc)   WON'T BE EXECUTED
 nop                        # (0x14)   WON'T BE EXECUTED
 jalr x11, x0, 0x38         # (0x30)
 nop                        # (0x34)