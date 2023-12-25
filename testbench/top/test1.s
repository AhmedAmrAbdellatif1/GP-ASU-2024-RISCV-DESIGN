# Assembly code for testing RV64I pipelined processor

# Testing different instruction formats
addi x8, x0, 10          # (0x0) Initialize x1 with value 10 (I-type instruction)
addi x9, x0, 20          # (0x4) Initialize x2 with value 20 (I-type instruction)
auipc x6, 0x100          # (0x8) Load immediate PC-relative (U-type instruction)
jal x5, 8                # (0xc) Jump and Link (J-type instruction)
nop                      # (0x10) No operation (I-type instruction)
nop                      # (0x14) No operation (I-type instruction)
sd x6, 0(x0)             # (0x18) Store x6 at address 0 in memory (S-type instruction)
ld x7, 0(x6)             # (0x1c) Load value from address 0 in memory to x7 (I-type instruction)
add x10, x8, x9          # (0x20) Addition  
lui x5, 0x20000          # (0x24) Load upper immediate (U-type instruction)
bne x6, x7, -20          # (0x28) Assume Branch not taken (B-type instruction)
addiw x1, x0, 18         # (0x2c)
jalr x4, x1, 8           # (0x30) Jump and Link Register (I-type instruction)
nop                      # (0x34) No operation (I-type instruction)
sltu x3, x8, x9          # (0x38) No operation (I-type instruction)

# Hazards !!!
# case (1)
addi x8, x0, 15          # (0x3c) Initialize x8 with value 15 (R-type instruction)
sub x27, x8, x9           # (0x40) [ForwardAE = 10]   x8 before was 10, recently it's 15
or x29, x9, x8            # (0x44) [ForwardBE = 01]   x8 before was 10, recently it's 15
slliw x28, x9, 2         # (0x4c) No Forwarding
nop                      # (0x50) No operation (I-type instruction)

# case (2)
addi x9, x0, 30          # (0x54) Initialize x9 with value 30 (R-type instruction)
add  x0, x9, x9          # (0x58) No Forwarding

# case (3)
lb x7, 0(x6)             # (0x5c) Load value from address 0 in memory to x7 (I-type instruction)
add x4, x0, x7           # (0x60) Stall for one cycle --> PC && F/D pipe  // Flush --> D/E pipe

# case (4)
beq x0, x0, 16           # (0x64) Branch Taken : Flush --> F/D && D/E
addi x1, x2, 124         # (0x68)
addi x1, x2, 125         # (0x6c)
addi x1, x2, 127         # (0x70) 
addi x1, x0, 10          # (0x74) 
