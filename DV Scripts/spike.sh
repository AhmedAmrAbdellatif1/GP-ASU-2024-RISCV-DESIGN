cd $HOME

git clone https://github.com/riscv-software-src/riscv-isa-sim.git spike

cd spike

sudo apt-get install device-tree-compiler

mkdir build

cd build

../configure --enable-commitlog --enable-misaligned --prefix=$RISCV 

make

sudo make install

export SPIKE_PATH=$RISCV/bin


