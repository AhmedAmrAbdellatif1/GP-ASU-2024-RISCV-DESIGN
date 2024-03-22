onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /riscv_top_tb/clk
add wave -noupdate /riscv_top_tb/stall
add wave -noupdate /riscv_top_tb/instr.pc
add wave -noupdate /riscv_top_tb/csr.mepc
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/csr_we
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_address
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_pc
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/csr_wdata
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/go_to_trap
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/mepc_cs
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/o_riscv_csr_rdata
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/i_riscv_csr_illegal_inst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/illegal_csr_priv
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/illegal_csr_write
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/illegal_csr_address
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/illegal_csr
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_csrfile/illegal_total
add wave -noupdate -divider {New Divider}
add wave -noupdate /riscv_top_tb/clk
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/i_riscv_em_en
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/i_riscv_em_pc
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/o_riscv_em_pc
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/i_riscv_em_illegal_inst_e
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_em_ppreg/o_riscv_em_illegal_inst_m
add wave -noupdate -divider {New Divider}
add wave -noupdate /riscv_top_tb/stall
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_de_ppreg/i_riscv_de_en
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_cu/o_riscv_cu_illgalinst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_de_ppreg/i_riscv_de_illegal_inst_d
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_de_ppreg/o_riscv_de_illegal_inst_e
add wave -noupdate -divider {New Divider}
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/i_riscv_datapath_illgalinst_cu_de
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/riscv_cillegal_inst_d
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_fstage/u_top_cdecoder/i_riscv_cdecoder_inst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_fstage/u_top_cdecoder/o_riscv_cdecoder_inst
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_fstage/u_top_cdecoder/o_riscv_cdecoder_compressed
add wave -noupdate /riscv_top_tb/DUT/u_top_core/u_top_datapath/u_riscv_fstage/u_top_cdecoder/o_riscv_cdecoder_cillegal_inst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {958084000 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 155
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
WaveRestoreZoom {957834100 ps} {958253100 ps}
