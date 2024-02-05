auipc x6, 0x100             # (0x0)
addi x8, x0, 10             # (0x4)
addi x9, x0, 20             # (0x8)
sd x6, 0(x0)                # (0xc)
ld x7, 0(x0)                # (0x10)
add x10, x8, x9             # (0x14)  
lui x5, 0x20000             # (0x18)
addiw x4, x0, 18            # (0x1c)
sltu x3, x8, x9             # (0x20)
bne x6, x7, -20             # (0x24)

# Hazards !!!
# case (1)
addi x8, x0, 15             # (0x28)
sub x27, x8, x9             # (0x2c)
or x29, x9, x8              # (0x30)
slliw x28, x8, 2            # (0x34)
nop                         # (0x38)

# case (2)
addi x9, x0, 30             # (0x3c)
add  x0, x9, x9             # (0x40)

# case (3)
lb x7, 0(x6)                # (0x44)
add x4, x0, x7              # (0x48)

# case (4)
beq x0, x0, 16              # (0x4c) Branch Taken : Flush --> F/D && D/E
addi x17, x17, 124          # (0x50)
addi x18, x18, 125          # (0x54)
addi x19, x19, 127          # (0x58) 
addi x20, x20, 10           # (0x5c)

# case (5)
jal x5, 8                   # (0x60)   jump will be taken 
nop                         # (0x64)   WON'T BE EXECUTED
nop                         # (0x68)   WON'T BE EXECUTED
jalr x11, x0, 0x78          # (0x6c)
addi x1, x2, 124            # (0x70)
addi x1, x2, 125            # (0x74)
addi x1, x2, 127            # (0x78) 
addi x1, x0, 10             # (0x7c)