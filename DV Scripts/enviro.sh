## TOOL CHAIN
echo 'export PATH="$HOME/riscv-demo/bin":$PATH' >> ~/.bashrc
echo 'export RISCV_TOOLCHAIN="$HOME/riscv-demo/"' >> ~/.bashrc
echo 'export RISCV_GCC="$RISCV_TOOLCHAIN/bin/riscv64-unknown-elf-gcc"' >> ~/.bashrc
echo 'export RISCV_OBJCOPY="$RISCV_TOOLCHAIN/bin/riscv64-unknown-elf-objcopy"' >> ~/.bashrc


## SPIKE
echo 'export RISCV=$HOME/riscv-demo' >> ~/.bashrc
echo 'export SPIKE_PATH=$RISCV/bin' >> ~/.bashrc


# RISCV-DV
echo 'export PATH=$HOME/.local/bin/:$PATH' >> ~/.bashrc

# QuestaSim
echo 'export QUESTA_HOME="$HOME/questa/questasim"' >> ~/.bashrc


source ~/.bashrc
