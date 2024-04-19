onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_clk
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_pc
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_inst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_illegal_inst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_ecall_u
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_ecall_s
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_ecall_m
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_rdata
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_return_address
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_trap_address
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_returnfromTrap_cs
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_gotoTrap_cs
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_privlvl
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/priv_lvl_cs
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/mret
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/illegal_total
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/mstatus_sie_cs
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/mstatus_spie_cs
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/mstatus_spp_cs
add wave -noupdate -height 25 /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/mstatus_mpp_cs
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
add wave -noupdate -divider -height 50 {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {437967700 ps} 0}
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
WaveRestoreZoom {437820200 ps} {438229800 ps}
