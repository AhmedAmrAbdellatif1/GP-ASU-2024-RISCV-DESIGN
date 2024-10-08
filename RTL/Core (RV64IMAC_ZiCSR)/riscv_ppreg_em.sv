  module riscv_ppreg_em (
    input  logic [63:0] i_riscv_em_pc                     ,
    input  logic        i_riscv_em_clk                    ,
    input  logic        i_riscv_em_rst                    ,
    input  logic        i_riscv_em_en                     ,
    input  logic        i_riscv_em_regw_e                 ,
    input  logic [ 2:0] i_riscv_em_resultsrc_e            ,
    input  logic [ 1:0] i_riscv_em_storesrc_e             ,
    input  logic [ 2:0] i_riscv_em_memext_e               ,
    input  logic [63:0] i_riscv_em_pcplus4_e              ,
    input  logic [63:0] i_riscv_em_result_e               ,
    input  logic [63:0] i_riscv_em_storedata_e            ,
    input  logic [63:0] i_riscv_em_dcache_addr            ,
    input  logic [ 4:0] i_riscv_em_rdaddr_e               ,
    input  logic [63:0] i_riscv_em_imm_e                  ,
    input  logic [ 6:0] i_riscv_em_opcode_e               ,
    input  logic        i_riscv_em_flush                  ,
    input  logic        i_riscv_em_ecall_m_e              ,
    input  logic        i_riscv_em_ecall_s_e              ,
    input  logic        i_riscv_em_ecall_u_e              ,
    input  logic [11:0] i_riscv_em_csraddress_e           ,
    input  logic        i_riscv_em_illegal_inst_e         ,
    input  logic        i_riscv_em_iscsr_e                ,
    input  logic [ 2:0] i_riscv_em_csrop_e                ,
    input  logic        i_riscv_em_inst_addr_misaligned_e ,
    input  logic        i_riscv_em_load_addr_misaligned_e ,
    input  logic        i_riscv_em_store_addr_misaligned_e,
    input  logic [63:0] i_riscv_em_csrwritedata_e         ,
    input  logic [ 4:0] i_riscv_em_rs1addr_e              ,
    input  logic        i_riscv_em_instret_e              ,
    input  logic [63:0] i_riscv_em_rddata_sc_e            ,
    input  logic [ 4:0] i_riscv_em_amo_op_e               ,
    input  logic [31:0] i_riscv_em_inst                   ,
    input  logic [15:0] i_riscv_em_cinst                  ,
    input  logic        i_riscv_em_timer_wren             ,
    input  logic        i_riscv_em_timer_rden             ,
    input  logic [ 1:0] i_riscv_em_timer_regsel           ,
    input  logic        i_riscv_em_uart_tx_valid          ,
    input  logic [ 2:0] i_riscv_em_mstage_mux_sel         ,
    input  logic        i_riscv_em_seg_en                 ,
    input  logic        i_riscv_em_led_en                 ,
    output logic        o_riscv_em_seg_en                 ,
    output logic        o_riscv_em_led_en                 ,
    output logic [ 2:0] o_riscv_em_mstage_mux_sel         ,
    output logic [31:0] o_riscv_em_inst                   ,
    output logic [15:0] o_riscv_em_cinst                  ,
    output logic [ 4:0] o_riscv_em_amo_op_m               ,
    output logic [63:0] o_riscv_em_rddata_sc_m            ,
    output logic [63:0] o_riscv_em_dcache_addr            ,
    output logic [63:0] o_riscv_em_pc                     ,
    output logic        o_riscv_em_instret_m              ,
    output logic        o_riscv_em_regw_m                 ,
    output logic [ 2:0] o_riscv_em_resultsrc_m            ,
    output logic [ 1:0] o_riscv_em_storesrc_m             ,
    output logic [ 2:0] o_riscv_em_memext_m               ,
    output logic [63:0] o_riscv_em_pcplus4_m              ,
    output logic [63:0] o_riscv_em_result_m               ,
    output logic [63:0] o_riscv_em_storedata_m            ,
    output logic [ 4:0] o_riscv_em_rdaddr_m               ,
    output logic [63:0] o_riscv_em_imm_m                  ,
    output logic [ 6:0] o_riscv_em_opcode_m               ,
    output logic        o_riscv_em_ecall_m_m              ,
    output logic        o_riscv_em_ecall_s_m              ,
    output logic        o_riscv_em_ecall_u_m              ,
    output logic [11:0] o_riscv_em_csraddress_m           ,
    output logic        o_riscv_em_illegal_inst_m         ,
    output logic        o_riscv_em_iscsr_m                ,
    output logic [ 2:0] o_riscv_em_csrop_m                ,
    output logic        o_riscv_em_inst_addr_misaligned_m ,
    output logic        o_riscv_em_load_addr_misaligned_m ,
    output logic        o_riscv_em_store_addr_misaligned_m,
    output logic [63:0] o_riscv_em_csrwritedata_m         ,
    output logic [ 4:0] o_riscv_em_rs1addr_m              ,
    output logic        o_riscv_em_timer_wren             ,
    output logic        o_riscv_em_timer_rden             ,
    output logic [ 1:0] o_riscv_em_timer_regsel           ,
    output logic        o_riscv_em_uart_tx_valid
  );

    always_ff @ (posedge i_riscv_em_clk or posedge i_riscv_em_rst)
      begin : em_pff_write_proc
        if (i_riscv_em_rst)
          begin : em_pff_write_proc
            o_riscv_em_regw_m                  <= 'b0;
            o_riscv_em_resultsrc_m             <= 'b0;
            o_riscv_em_memext_m                <= 'b0;
            o_riscv_em_pcplus4_m               <= 'b0;
            o_riscv_em_result_m                <= 'b0;
            o_riscv_em_rdaddr_m                <= 'b0;
            o_riscv_em_imm_m                   <= 'b0;
            o_riscv_em_opcode_m                <= 'b0;
            o_riscv_em_ecall_m_m               <= 'b0;
            o_riscv_em_ecall_s_m               <= 'b0;
            o_riscv_em_ecall_u_m               <= 'b0;
            o_riscv_em_csraddress_m            <= 'b0;
            o_riscv_em_illegal_inst_m          <= 'b0;
            o_riscv_em_iscsr_m                 <= 'b0;
            o_riscv_em_csrop_m                 <= 'b0;
            o_riscv_em_rs1addr_m               <= 'b0;
            o_riscv_em_csrwritedata_m          <= 'b0;
            o_riscv_em_inst_addr_misaligned_m  <= 'b0;
            o_riscv_em_load_addr_misaligned_m  <= 'b0;
            o_riscv_em_store_addr_misaligned_m <= 'b0;
            o_riscv_em_instret_m               <= 'b0;
            o_riscv_em_pc                      <= 'b0;
            o_riscv_em_rddata_sc_m             <= 'b0;
            o_riscv_em_amo_op_m                <= 'b0;
            o_riscv_em_inst                    <= 'b0;
            o_riscv_em_cinst                   <= 'b0;
            o_riscv_em_timer_wren              <= 'b0;
            o_riscv_em_timer_rden              <= 'b0;
            o_riscv_em_timer_regsel            <= 'b0;
            o_riscv_em_uart_tx_valid           <= 'b0;
            o_riscv_em_mstage_mux_sel          <= 'b0;
            o_riscv_em_seg_en                  <= 'b0;
            o_riscv_em_led_en                  <= 'b0;

          end
        else if(i_riscv_em_flush)
          begin
            o_riscv_em_regw_m                  <= 'b0;
            o_riscv_em_resultsrc_m             <= 'b0;
            o_riscv_em_memext_m                <= 'b0;
            o_riscv_em_pcplus4_m               <= 'b0;
            o_riscv_em_result_m                <= 'b0;
            o_riscv_em_rdaddr_m                <= 'b0;
            o_riscv_em_imm_m                   <= 'b0;
            o_riscv_em_opcode_m                <= 'b0;
            o_riscv_em_csrwritedata_m          <= 'b0;
            o_riscv_em_ecall_m_m               <= 'b0;
            o_riscv_em_ecall_s_m               <= 'b0;
            o_riscv_em_ecall_u_m               <= 'b0;
            o_riscv_em_csraddress_m            <= 'b0;
            o_riscv_em_illegal_inst_m          <= 'b0;
            o_riscv_em_iscsr_m                 <= 'b0;
            o_riscv_em_csrop_m                 <= 'b0;
            o_riscv_em_inst_addr_misaligned_m  <= 'b0;
            o_riscv_em_load_addr_misaligned_m  <= 'b0;
            o_riscv_em_store_addr_misaligned_m <= 'b0;
            o_riscv_em_rs1addr_m               <= 'b0;
            o_riscv_em_instret_m               <= 'b0;
            o_riscv_em_pc                      <= i_riscv_em_pc;
            o_riscv_em_rddata_sc_m             <= 'b0;
            o_riscv_em_amo_op_m                <= 'b0;
            o_riscv_em_inst                    <= 'b0;
            o_riscv_em_cinst                   <= 'b0;
            o_riscv_em_timer_wren              <= 'b0;
            o_riscv_em_timer_rden              <= 'b0;
            o_riscv_em_timer_regsel            <= 'b0;
            o_riscv_em_uart_tx_valid           <= 'b0;
            o_riscv_em_mstage_mux_sel          <= 'b0;
            o_riscv_em_seg_en                  <= 'b0;
            o_riscv_em_led_en                  <= 'b0;
          end
        else if(!i_riscv_em_en)
          begin
            o_riscv_em_regw_m                  <= i_riscv_em_regw_e ;
            o_riscv_em_resultsrc_m             <= i_riscv_em_resultsrc_e;
            o_riscv_em_memext_m                <= i_riscv_em_memext_e;
            o_riscv_em_pcplus4_m               <= i_riscv_em_pcplus4_e;
            o_riscv_em_result_m                <= i_riscv_em_result_e;
            o_riscv_em_rdaddr_m                <= i_riscv_em_rdaddr_e;
            o_riscv_em_imm_m                   <= i_riscv_em_imm_e;
            o_riscv_em_opcode_m                <= i_riscv_em_opcode_e;
            o_riscv_em_ecall_m_m               <= i_riscv_em_ecall_m_e;
            o_riscv_em_ecall_s_m               <= i_riscv_em_ecall_s_e;
            o_riscv_em_ecall_u_m               <= i_riscv_em_ecall_u_e;
            o_riscv_em_csraddress_m            <= i_riscv_em_csraddress_e;
            o_riscv_em_illegal_inst_m          <= i_riscv_em_illegal_inst_e;
            o_riscv_em_iscsr_m                 <= i_riscv_em_iscsr_e ;
            o_riscv_em_csrop_m                 <= i_riscv_em_csrop_e ;
            o_riscv_em_inst_addr_misaligned_m  <= i_riscv_em_inst_addr_misaligned_e;
            o_riscv_em_load_addr_misaligned_m  <= i_riscv_em_load_addr_misaligned_e;
            o_riscv_em_store_addr_misaligned_m <= i_riscv_em_store_addr_misaligned_e ;
            o_riscv_em_csrwritedata_m          <= i_riscv_em_csrwritedata_e ;
            o_riscv_em_rs1addr_m               <= i_riscv_em_rs1addr_e;
            o_riscv_em_instret_m               <= i_riscv_em_instret_e;
            o_riscv_em_pc                      <= i_riscv_em_pc;
            o_riscv_em_rddata_sc_m             <= i_riscv_em_rddata_sc_e;
            o_riscv_em_amo_op_m                <= i_riscv_em_amo_op_e;
            o_riscv_em_inst                    <= i_riscv_em_inst;
            o_riscv_em_cinst                   <= i_riscv_em_cinst;
            o_riscv_em_timer_wren              <= i_riscv_em_timer_wren  ;
            o_riscv_em_timer_rden              <= i_riscv_em_timer_rden  ;
            o_riscv_em_timer_regsel            <= i_riscv_em_timer_regsel;
            o_riscv_em_uart_tx_valid           <= i_riscv_em_uart_tx_valid;
            o_riscv_em_mstage_mux_sel          <= i_riscv_em_mstage_mux_sel;
            o_riscv_em_seg_en                  <= i_riscv_em_seg_en;
            o_riscv_em_led_en                  <= i_riscv_em_led_en;
          end
      end

    always @ (posedge i_riscv_em_clk)
      begin
        if (i_riscv_em_rst)
          begin
            o_riscv_em_storedata_m <= 'b0;
            o_riscv_em_dcache_addr <= 'b0;
            o_riscv_em_storesrc_m  <= 'b0;
          end
        else if(i_riscv_em_flush)
          begin
            o_riscv_em_storedata_m <= 'b0;
            o_riscv_em_dcache_addr <= 'b0;
            o_riscv_em_storesrc_m  <= 'b0;
          end
        else if(!i_riscv_em_en)
          begin
            o_riscv_em_storedata_m <= i_riscv_em_storedata_e;
            o_riscv_em_dcache_addr <= i_riscv_em_dcache_addr;
            o_riscv_em_storesrc_m  <= i_riscv_em_storesrc_e;
          end
      end
  endmodule