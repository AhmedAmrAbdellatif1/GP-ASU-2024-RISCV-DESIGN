onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/o_riscv_em_inst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/o_riscv_em_pc
add wave -noupdate -divider TOP
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_clk
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_rst
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_cpu_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_cpu_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_store_src
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_phys_addr
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_cpu_data_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/o_riscv_dcache_cpu_data_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/o_riscv_dcache_cpu_stall
add wave -noupdate -divider Tag
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/index
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/tag_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/dirty_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/valid_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/replace_tag
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/hit
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/dirty
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/tag_buffer
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/valid_buffer
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_tag/dirty_buffer
add wave -noupdate -divider Data
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/index
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/byte_offset
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/storesrc
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/mem_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/data_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/data_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/dcache
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_data/strdouble
add wave -noupdate -divider FSM
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cpu_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cpu_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/hit
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/dirty
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/mem_ready
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cache_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cache_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cache_insel
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/mem_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/mem_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/set_dirty
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/set_valid
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/replace_tag
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/stall
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/tag_sel
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/current_state
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/next_state
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cpu_rden_reg
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/cpu_wren_reg
add wave -noupdate -divider RAM
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/addr
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/data_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/data_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/mem_ready
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/base_addr
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dram/mem
add wave -noupdate -divider {MEM EXT}
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_mstage/u_riscv_memext/i_riscv_memext_sel
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_mstage/u_riscv_memext/i_riscv_memext_data
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_mstage/u_riscv_memext/o_riscv_memext_loaded
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {146384225200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {54121800 ps} {54125200 ps}
