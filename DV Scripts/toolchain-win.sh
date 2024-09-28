#!/bin/bash

# Check if a filename is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 filename.c"
    exit 1
fi

# Extract the base name without extension
FILENAME=$(basename "$1" .c)

# Set the target architecture and ABI
ARCH="rv64imac_zicsr"
ABI="lp64"

# Compile the C code to assembly, specifying the architecture and ABI
riscv64-unknown-elf-gcc -O0 -march=$ARCH -mabi=$ABI -S "$1" -o "$FILENAME.s"

# Assemble the assembly code into an object file, specifying the architecture
riscv64-unknown-elf-as -march=$ARCH -mabi=$ABI "$FILENAME.s" -o "$FILENAME.o"

# Link the object file to create an executable, specifying the entry point as 'main'
riscv64-unknown-elf-ld -melf64lriscv -e main "$FILENAME.o" -o "$FILENAME.elf"

# Disassemble the executable to view the assembly instructions alongside their machine code
riscv64-unknown-elf-objdump -d "$FILENAME.elf" > "${FILENAME}_disassembly.txt"

# Extract the hex codes from the disassembly
#riscv64-unknown-elf-objdump -d "$FILENAME.elf" | grep '^[ ]*[0-9a-f]\+:' | awk '{print $2}' > "${FILENAME}_hexdump.txt"

# Alternatively, directly generate a hex dump of the binary executable
riscv64-unknown-elf-objcopy -O binary "$FILENAME.elf" "$FILENAME.bin"
#hexdump -v -e '/4 "%08X\n"' "$FILENAME.bin" > "${FILENAME}_hexdump.txt"
hexdump -v -e '/1 "%02X\n"' "$FILENAME.bin" > "${FILENAME}_hexdump.txt"


echo "Compilation and hex dump completed for $ARCH architecture."
echo "Assembly code: $FILENAME.s"
echo "Object file: $FILENAME.o"
echo "Executable: $FILENAME.elf"
echo "Disassembly: ${FILENAME}_disassembly.txt"
echo "Hex dump: ${FILENAME}_hexdump.txt"
