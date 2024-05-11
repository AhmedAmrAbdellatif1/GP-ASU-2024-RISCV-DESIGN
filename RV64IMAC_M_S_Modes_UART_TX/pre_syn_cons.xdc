#create_clock -period 10.000 -name MASTER_CLK -waveform {0.000 5.000} [get_ports i_riscv_clk];
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports i_riscv_clk]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports i_riscv_rst]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_external_interrupt]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_tx_data]

set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_tx_busy]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_tx_busy]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_tx_busy]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

create_clock -period 30.000 -name VIRTUAL_CLK -waveform {0.000 15.000}
set_input_delay -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_rst}]
set_input_delay -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 4.5 [get_ports {i_riscv_rst}]
set_input_delay -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_external_interrupt}]
set_input_delay -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 4.5 [get_ports {i_riscv_top_external_interrupt}]

create_generated_clock -name UART_CLK -source [get_ports i_riscv_clk] -divide_by 20834 [get_pins {uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg/Q}]
set_input_delay -clock [get_clocks UART_CLK] -min -add_delay 1.500 [get_ports i_riscv_rst];
set_input_delay -clock [get_clocks UART_CLK] -max -add_delay 4.500 [get_ports i_riscv_rst];

set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_data];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 4.500 [get_ports o_riscv_top_tx_data];
set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_busy];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 4.500 [get_ports o_riscv_top_tx_busy];