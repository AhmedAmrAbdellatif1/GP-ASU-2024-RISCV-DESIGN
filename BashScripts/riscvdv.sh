cd $HOME
sudo apt update
sudo apt install git
sudo apt install python3 python3-pip
git clone https://github.com/google/riscv-dv.git
cd riscv-dv
export PATH=$HOME/.local/bin/:$PATH
pip3 install --user -e
run --help
cov --help
