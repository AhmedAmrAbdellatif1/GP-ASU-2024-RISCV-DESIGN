# Files Hierarchy

├── riscv_top.sv  
│   ├── riscv_core.sv  
│   │   ├── riscv_datapath.sv  
│   │   │   ├── riscv_control_unit.sv  
│   │   │   ├── riscv_fetch_stage.sv  
│   │   │   │   ├── riscv_mux2.sv  
│   │   │   │   ├── riscv_pc.sv  
│   │   │   │   ├── riscv_pcadder.sv  
│   │   │   │   ├── riscv_compressed_decoder.sv  
│   │   │   │   └── riscv_mux4.sv  
│   │   │   ├── riscv_ppreg_fd.sv  
│   │   │   ├── riscv_decode_stage.sv  
│   │   │   │   ├── riscv_rf.sv  
│   │   │   │   ├── riscv_extend.sv  
│   │   │   │   └── riscv_zeroextend.sv  
│   │   │   ├── riscv_ppreg_de.sv  
│   │   │   ├── riscv_execute_stage.sv  
│   │   │   │   ├── riscv_mux2.sv  
│   │   │   │   ├── riscv_mux4.sv  
│   │   │   │   ├── riscv_lsu.sv  
│   │   │   │   ├── riscv_misalignment_unit.sv  
│   │   │   │   └── riscv_icu.sv  
│   │   │   │   │   ├── riscv_alu.sv  
│   │   │   │   │   ├── riscv_branch.sv  
│   │   │   │   │   ├── riscv_multipliers.sv  
│   │   │   │   │   ├── riscv_divider.sv  
│   │   │   │   │   └── riscv_mux3.sv  
│   │   │   ├── riscv_ppreg_em.sv  
│   │   │   ├── riscv_mem_stage.sv  
│   │   │   │   ├── riscv_mux8.sv  
│   │   │   │   ├── riscv_memext.sv  
│   │   │   │   └── riscv_mux2.sv  
│   │   │   ├── riscv_ppreg_mw.sv  
│   │   │   ├── riscv_wb_stage.sv  
│   │   │   │   ├── riscv_mux5.sv  
│   │   │   │   ├── riscv_trap_wb.sv  
│   │   │   │   └── riscv_mux2.sv  
│   │   │   ├── riscv_csrfile.sv  
│   │   │   │   └── riscv_counter.sv  
│   │   │   └── riscv_hazardunit.sv  
│   │   ├── riscv_dcache_top.sv  
│   │   │   ├── riscv_dcache_tag.sv  
│   │   │   ├── riscv_dcache_data.sv  
│   │   │   ├── riscv_dcache_fsm.sv  
│   │   │   └── riscv_dcache_amo.sv  
│   │   ├── riscv_icache_top.sv  
│   │   │   ├── riscv_icache_tag.sv  
│   │   │   ├── riscv_icache_inst.sv  
│   │   │   └── riscv_icache_fsm.sv  
│   │   └── riscv_timer_irq.sv  
│   ├── riscv_dram_model.sv  
│   │   ├── riscv_dram_data.sv  
│   │   └── riscv_dram_counter.sv  
│   ├── riscv_iram_model.sv  
│   │   ├── riscv_iram_data.sv  
│   │   └── riscv_iram_counter.sv  
│   ├── uart_peripheral_top.sv  
│   │   ├── uart_clk_div.sv  
│   │   ├── uart_fifo_top.sv  
│   │   │   ├── uart_fifo_mem_ctrl.sv  
│   │   │   ├── uart_fifo_rd.sv  
│   │   │   ├── uart_fifo_wr.sv  
│   │   │   ├── uart_fifo_df_sync.sv  
│   │   │   └── uart_fifo_gray_conv.sv  
│   │   ├── uart_tx_top.sv  
│   │   │   ├── uart_tx_serializer.sv  
│   │   │   ├── uart_tx_fsm.sv  
│   │   │   ├── uart_tx_parity_calc.sv  
│   │   │   └── uart_tx_mux.sv  
│   │   └── uart_pulse_gen.sv  
│   ├── riscv_button_debouncer.sv  
│   │   ├── uart_fifo_df_sync.sv  
│   │   └── riscv_button_debouncer_delayed.sv  
│   │   │   ├── riscv_button_debouncer_fsm.sv  
│   │   │   └── riscv_button_debouncer_timer.sv  
│   ├── riscv_rst_sync.sv  
│   ├── riscv_dff.sv  
│   ├── riscv_segment.sv  
│   └── riscv_dff_en.sv  
