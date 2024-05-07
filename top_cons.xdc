set CLK_PERIOD 26.000
set HALF_PERIOD [expr CLK_PERIOD *  0.5]
set MIN_DELAY   [expr CLK_PERIOD * 0.05]
set MAX_DELAY   [expr CLK_PERIOD * 0.25]

create_clock -period $CLK_PERIOD -name i_riscv_clk -waveform {0.000 $HALF_PERIOD} [get_ports i_riscv_clk]

set_clock_latency 0.3 [get_clocks i_riscv_clk]

set_input_delay -clock [get_clocks i_riscv_clk] -min -add_delay $MIN_DELAY [get_ports i_riscv_rst]
set_input_delay -clock [get_clocks i_riscv_clk] -max -add_delay $MAX_DELAY [get_ports i_riscv_rst]

set_input_delay -clock [get_clocks i_riscv_clk] -min -add_delay $MIN_DELAY [get_ports i_riscv_top_external_interrupt]
set_input_delay -clock [get_clocks i_riscv_clk] -max -add_delay $MAX_DELAY [get_ports i_riscv_top_external_interrupt]

set_input_delay -clock [get_clocks i_riscv_clk] -min -add_delay $MIN_DELAY [get_ports i_riscv_top_rx_data]
set_input_delay -clock [get_clocks i_riscv_clk] -max -add_delay $MAX_DELAY [get_ports i_riscv_top_rx_data]

set_output_delay -clock [get_clocks i_riscv_clk] -min -add_delay $MIN_DELAY [get_ports o_riscv_top_tx_data]
set_output_delay -clock [get_clocks i_riscv_clk] -max -add_delay $MAX_DELAY [get_ports o_riscv_top_tx_data]