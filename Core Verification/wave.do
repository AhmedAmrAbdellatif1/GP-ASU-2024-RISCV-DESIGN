onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /riscv_top_tb/amo_op_flag
add wave -noupdate -radix unsigned /riscv_top_tb/DUT/u_data_cache/BYTE_OFF
add wave -noupdate -radix unsigned /riscv_top_tb/DUT/u_data_cache/TAG
add wave -noupdate -radix unsigned /riscv_top_tb/DUT/u_data_cache/INDEX
add wave -noupdate -radix unsigned /riscv_top_tb/DUT/u_data_cache/u_dcache_data/CACHE_DEPTH
add wave -noupdate /riscv_top_tb/instr.amo_result
add wave -noupdate /riscv_top_tb/instr.rddata
add wave -noupdate -divider {New Divider}
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_clk
add wave -noupdate /riscv_top_tb/stall
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/o_riscv_em_inst
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/i_riscv_amo_enable
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/i_riscv_amo_xlen
add wave -noupdate -radix binary /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/i_riscv_amo_ctrl
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/i_riscv_amo_rs1data
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/i_riscv_amo_rs2data
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/o_riscv_amo_result
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_riscv_dcache_amo/amo_word_buffer
add wave -noupdate -divider {New Divider}
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_rst
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_globstall
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_cpu_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_cpu_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_store_src
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_amo
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_amo_op
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_phys_addr
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/o_riscv_em_pc
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/o_riscv_dcache_cpu_data_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/o_riscv_dcache_cpu_stall
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/i_riscv_dcache_cpu_data_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/cache_data_out_buffer
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/tag
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/index
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/byte_offset
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_set_dirty
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_set_valid
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_replace_tag
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_cache_insel
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_mem_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_mem_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_tag_sel
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_amo_buffer_en
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_amo_unit_en
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_cache_rden
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/fsm_cache_wren
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/u_dcache_fsm/current_state
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/cache_data_in
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/cache_data_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/tag_dirty_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/tag_hit_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/tag_old_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/mem_ready
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/mem_addr
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/mem_data_out
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/amo_result
add wave -noupdate /riscv_top_tb/DUT/u_data_cache/amo_xlen
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2025000 ps} 1} {{Cursor 2} {2175000 ps} 1} {{Cursor 3} {3875000 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 232
configure wave -valuecolwidth 292
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
WaveRestoreZoom {2218900 ps} {4202900 ps}
