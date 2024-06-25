create_clock -period 30.000 -name VIRTUAL_CLK -waveform {0.000 15.000}
create_generated_clock -name UART_CLK -source [get_ports i_riscv_clk] -divide_by 20834 [get_pins {uart_peripheral_top_inst/uart_clk_div_inst/div_clk_reg/Q}]

set_clock_latency 0.3 [get_clocks i_riscv_clk]
set_clock_latency 0.3 [get_clocks VIRTUAL_CLK]
set_clock_latency 0.3 [get_clocks UART_CLK]

set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_0/inst/plle2_adv_inst/CLKOUT0]] -to [get_clocks UART_CLK]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_rst}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 7.5 [get_ports {i_riscv_rst}]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_external_interrupt}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_external_interrupt}]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_switches_upper}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 7.5 [get_ports {i_riscv_top_switches_upper}]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_switches_lower}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 7.5 [get_ports {i_riscv_top_switches_lower}]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_button1}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 7.5 [get_ports {i_riscv_top_button1}]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_button2}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 7.5 [get_ports {i_riscv_top_button2}]

set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -min -add_delay 1.5 [get_ports {i_riscv_top_button3}]
set_input_delay  -clock [get_clocks {VIRTUAL_CLK}] -max -add_delay 7.5 [get_ports {i_riscv_top_button3}]


set_input_delay  -clock [get_clocks UART_CLK] -min -add_delay 1.500 [get_ports i_riscv_rst];
set_input_delay  -clock [get_clocks UART_CLK] -max -add_delay 7.500 [get_ports i_riscv_rst];


set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_tx_data];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 7.500 [get_ports o_riscv_top_tx_data];

set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_anode];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 7.500 [get_ports o_riscv_top_anode];

set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_segment];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 7.500 [get_ports o_riscv_top_segment];

set_output_delay -clock [get_clocks UART_CLK] -min -add_delay -1.500 [get_ports o_riscv_top_leds];
set_output_delay -clock [get_clocks UART_CLK] -max -add_delay 7.500 [get_ports o_riscv_top_leds];


set_property -dict {PACKAGE_PIN W5  IOSTANDARD LVCMOS33} [get_ports i_riscv_clk]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_tx_data]

set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports i_riscv_rst]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_external_interrupt]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_button1]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_button2]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_button3]

set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[0]]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[1]]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[2]]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[3]]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[4]]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[5]]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[6]]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_upper[7]]


set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[0]]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[1]]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[2]]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[3]]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[4]]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[5]]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[6]]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports i_riscv_top_switches_lower[7]]


set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[0]]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[1]]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[2]]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[3]]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[4]]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[5]]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[6]]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[7]]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[8]]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[9]]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[10]]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[11]]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[12]]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[13]]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[14]]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[15]]

  set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[0]]
  set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[1]]
  set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[2]]
  set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[3]]
  set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[4]]
  set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[5]]
  set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[6]]
  set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[7]]

  set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[8]]
  set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[9]]
  set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[10]]
  set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[11]]
  set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[12]]
  set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[13]]
  set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[14]]
  set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[15]]

  set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[0]]
  set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[1]]
  set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[2]]
  set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[3]]
  set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[4]]
  set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[5]]
  set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[6]]
  set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[7]]

  set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[8]]
  set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[9]]
  set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[10]]
  set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[11]]
  set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[12]]
  set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[13]]
  set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[14]]
  set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_leds[15]]


set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[0]]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[1]]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[2]]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[3]]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[4]]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[5]]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_segment[6]]


set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_anode]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_anode]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_anode]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_anode]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports o_riscv_top_anode]



set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO        [current_design]