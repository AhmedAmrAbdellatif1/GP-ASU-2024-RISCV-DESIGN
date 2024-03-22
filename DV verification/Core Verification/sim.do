transcript file questa.txt

vlog +define+TEST=1 -f files.f
vsim -gui -voptargs=+acc work.riscv_top_tb -novopt

puts "run -all"
run -all
transcript file ""