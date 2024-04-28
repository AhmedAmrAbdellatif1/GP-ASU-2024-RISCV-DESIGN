set period 15.00
set min_delay [expr $period * 0.05]
set max_delay [expr $period * 0.2]
set half   [ expr $period / 2 ]
create_clock -period $period -name i_riscv_clk -waveform "0.000 $half" [get_ports i_riscv_clk]
set_input_delay -clock [get_clocks i_riscv_clk] -min -add_delay $min_delay [get_ports i_riscv_rst]
set_input_delay -clock [get_clocks i_riscv_clk] -max -add_delay $max_delay [get_ports i_riscv_rst]