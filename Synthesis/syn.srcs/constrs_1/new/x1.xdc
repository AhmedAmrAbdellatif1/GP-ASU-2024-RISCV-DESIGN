create_generated_clock -name uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg_0 -source [get_pins u_driving_clock/inst/plle2_adv_inst/CLKOUT0] -divide_by 6945 [get_pins uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg/Q]
create_clock -period 30.000 -name VIRTUAL_clk_out1_clk_wiz_0 -waveform {0.000 15.000}
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min -add_delay 1.500 [get_ports i_riscv_rst]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max -add_delay 6.000 [get_ports i_riscv_rst]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min -add_delay 1.500 [get_ports i_riscv_top_external_interrupt]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max -add_delay 6.000 [get_ports i_riscv_top_external_interrupt]
create_clock -period 208349.984 -name VIRTUAL_uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg_0 -waveform {0.000 104174.992}
set_output_delay -clock [get_clocks VIRTUAL_uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg_0] -min -add_delay -1.500 [get_ports o_riscv_top_tx_busy]
set_output_delay -clock [get_clocks VIRTUAL_uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg_0] -max -add_delay 6.000 [get_ports o_riscv_top_tx_busy]
set_output_delay -clock [get_clocks VIRTUAL_uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg_0] -min -add_delay -1.500 [get_ports o_riscv_top_tx_data]
set_output_delay -clock [get_clocks VIRTUAL_uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg_0] -max -add_delay 6.000 [get_ports o_riscv_top_tx_data]
