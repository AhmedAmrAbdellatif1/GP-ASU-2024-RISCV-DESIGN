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

set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraTimingOpt [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]

create_generated_clock -name UART_CLK -source [get_pins clk_wiz_0/inst/plle2_adv_inst/CLKOUT0] -divide_by 6945 [get_pins uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg/Q]
set_input_delay -clock [get_clocks UART_CLK] -min -add_delay 1.500 [get_ports i_riscv_rst]
set_input_delay -clock [get_clocks UART_CLK] -max -add_delay 4.500 [get_ports i_riscv_rst]
set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_data]
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 4.500 [get_ports o_riscv_top_tx_data]
set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_busy]
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 4.500 [get_ports o_riscv_top_tx_busy]

set_input_delay -clock [get_clocks {clk_out1_clk_wiz_0}] -min -add_delay 1.5 [get_ports {i_riscv_rst}]
set_input_delay -clock [get_clocks {clk_out1_clk_wiz_0}] -max -add_delay 4.5 [get_ports {i_riscv_rst}]
set_input_delay -clock [get_clocks {clk_out1_clk_wiz_0}] -min -add_delay 1.5 [get_ports {i_riscv_top_external_interrupt}]
set_input_delay -clock [get_clocks {clk_out1_clk_wiz_0}] -max -add_delay 4.5 [get_ports {i_riscv_top_external_interrupt}]
