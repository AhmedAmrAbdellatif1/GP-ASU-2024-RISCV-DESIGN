transcript file questa_post_syn.txt

vopt riscv_top_tb glbl -o opt +acc
vsim opt -voptargs=+acc

puts "run -all"
run -all
transcript file ""