
create_clock -period 26.000 -name i_riscv_clk -waveform {0.000 13.000} [get_ports i_riscv_clk]
set_input_delay -clock [get_clocks i_riscv_clk] -min -add_delay 1.450 [get_ports i_riscv_rst]
set_input_delay -clock [get_clocks i_riscv_clk] -max -add_delay 5.800 [get_ports i_riscv_rst]
