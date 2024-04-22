set PERIOD 10.000

set MAX_RATIO 0.2
set MIN_RATIO 0.05

set HALF      [expr $PERIOD * 0.5 ]
set CLK_LAT   [expr $PERIOD * 0.3 ]
set MAX_DELAY [expr $PERIOD * $MAX_RATIO ]
set MIN_DELAY [expr $PERIOD * $MIN_RATIO ]

create_clock -period $PERIOD -name i_riscv_core_clk -waveform "0.000 $HALF" [get_ports {i_riscv_core_clk}]
set_clock_latency $CLK_LAT [get_clocks {i_riscv_core_clk}]


set_input_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {i_riscv_core_imem_data_out[*]}]
set_input_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {i_riscv_core_imem_data_out[*]}]

set_input_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {i_riscv_core_mem_data_out[*]}]
set_input_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {i_riscv_core_mem_data_out[*]}]

set_input_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {i_riscv_core_external_interrupt}]
set_input_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {i_riscv_core_external_interrupt}]

set_input_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {i_riscv_core_imem_ready}]
set_input_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {i_riscv_core_imem_ready}]

set_input_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {i_riscv_core_mem_ready}]
set_input_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {i_riscv_core_mem_ready}]

set_input_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {i_riscv_core_rst}]
set_input_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {i_riscv_core_rst}]


set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_cache_data_out[*]}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_cache_data_out[*]}]

set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_icache_data_out[*]}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_icache_data_out[*]}]

set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_imem_addr[*]}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_imem_addr[*]}]

set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_mem_addr[*]}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_mem_addr[*]}]

set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_fsm_imem_rden}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_fsm_imem_rden}]

set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_fsm_mem_rden}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_fsm_mem_rden}]

set_output_delay -clock [get_clocks {i_riscv_core_clk}] -min -add_delay $MIN_DELAY [get_ports {o_riscv_core_fsm_mem_wren}]
set_output_delay -clock [get_clocks {i_riscv_core_clk}] -max -add_delay $MAX_DELAY [get_ports {o_riscv_core_fsm_mem_wren}]