#create_clock -period 10.000 -name MASTER_CLK -waveform {0.000 5.000} [get_ports i_riscv_clk];

create_generated_clock -name CLK      -source [get_ports i_riscv_clk]  -divide_by 3    [get_ports u_driving_clock/clk_out1];
create_generated_clock -name UART_CLK -source [get_clocks CLK]         -divide_by 6945 [get_pins uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg/Q];

set_input_delay -clock [get_clocks CLK] -min -add_delay 1.500 [get_ports i_riscv_rst];
set_input_delay -clock [get_clocks CLK] -max -add_delay 6.000 [get_ports i_riscv_rst];

set_input_delay -clock [get_clocks UART_CLK] -min -add_delay 1.500 [get_ports i_riscv_rst];
set_input_delay -clock [get_clocks UART_CLK] -max -add_delay 6.000 [get_ports i_riscv_rst];


set_input_delay -clock [get_clocks CLK] -min -add_delay 1.500 [get_ports i_riscv_top_external_interrupt];
set_input_delay -clock [get_clocks CLK] -max -add_delay 6.000 [get_ports i_riscv_top_external_interrupt];

set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_data];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 6.000 [get_ports o_riscv_top_tx_data];

set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_busy];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 6.000 [get_ports o_riscv_top_tx_busy];

set_property -dict {PACKAGE_PIN W5    IOSTANDARD LVCMOS33} [get_ports i_riscv_clk];
set_property -dict {PACKAGE_PIN U18  IOSTANDARD LVCMOS33}  [get_ports i_riscv_rst];
set_property -dict {PACKAGE_PIN T18  IOSTANDARD LVCMOS33}  [get_ports i_riscv_top_external_interrupt];
set_property -dict {PACKAGE_PIN A18  IOSTANDARD LVCMOS33}  [get_ports o_riscv_top_tx_data];
set_property -dict {PACKAGE_PIN A18  IOSTANDARD LVCMOS33}  [get_ports o_riscv_top_tx_busy];

set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { o_riscv_top_tx_busy }];
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { o_riscv_top_tx_busy }];
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { o_riscv_top_tx_busy }];

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]