sudo apt update
sudo apt install git
sudo apt install python3 python3-pip

######################## RISCV GNU TOOLCHAIN #########################################
cd $HOME
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
cd riscv-gnu-toolchain
mkdir build
cd build/
export RISCV="/opt/riscv"
../configure --prefix=$RISCV --with-arch=rv64gc_zicsr_zifencei
export PATH="$RISCV/bin":$PATH
sudo make
which riscv64-unknown-elf-gcc

############################## SPIKE ###############################################
cd $HOME
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
sudo apt-get install device-tree-compiler
mkdir build
cd build
../configure --enable-commitlog --enable-misaligned --prefix=$RISCV 
make
sudo make install
export SPIKE_PATH=$RISCV/bin

########################### Proxy Kernel ############################################
cd $HOME
git clone https://github.com/riscv-software-src/riscv-pk.git
cd riscv-pk
mkdir build
cd build
../configure --prefix=$RISCV --host=riscv64-unknown-elf
make
sudo make install

############################# RISCV DV ##############################################
cd $HOME
git clone https://github.com/google/riscv-dv.git
cd riscv-dv
export PATH=$HOME/.local/bin/:$PATH
pip3 install --user -e.
run --help
cov --help

########################### ENVIRONMENTS ############################################
cd /home/juba/Documents
echo enviroments.txt >> ~/.bashrc
source ~/.bashrc