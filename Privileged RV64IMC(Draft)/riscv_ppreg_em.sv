  module riscv_em_ppreg (
    //---------------------------------------------->
    `ifdef TEST
    input   logic [31:0]  i_riscv_em_inst                     ,
    input   logic [15:0]  i_riscv_em_cinst                    ,
    input   logic [63:0]  i_riscv_em_pc                       ,
    output  logic [31:0]  o_riscv_em_inst                     ,
    output  logic [15:0]  o_riscv_em_cinst                    ,
    output  logic [63:0]  o_riscv_em_pc                       ,
    `endif
    //<----------------------------------------------
    input   logic         i_riscv_em_clk                      ,
    input   logic         i_riscv_em_rst                      ,
    input   logic         i_riscv_em_en                       ,
    input   logic         i_riscv_em_regw_e                   ,
    input   logic [1:0]   i_riscv_em_resultsrc_e              ,
    input   logic [1:0]   i_riscv_em_storesrc_e               ,
    input   logic [2:0]   i_riscv_em_memext_e                 ,
    input   logic [63:0]  i_riscv_em_pcplus4_e                ,
    input   logic [63:0]  i_riscv_em_result_e                 ,
    input   logic [63:0]  i_riscv_em_storedata_e              ,
    input   logic [4:0]   i_riscv_em_rdaddr_e                 ,
    input   logic [63:0]  i_riscv_em_imm_e                    ,
    input   logic [6:0]   i_riscv_de_opcode_e                 ,
    input   logic         i_riscv_em_flush                    , //<--- trap
    input   logic         i_riscv_em_ecall_m_e                , //<--- trap 
    input   logic [11:0]  i_riscv_em_csraddress_e             , //<--- trap
    input   logic         i_riscv_em_illegal_inst_e           , //<--- trap
    input   logic         i_riscv_em_iscsr_e                  , //<--- csr
    input   logic [2:0]   i_riscv_em_csrop_e                  , //<--- csr
    input   logic [63:0]  i_riscv_em_addressalu_e             , //<--- csr
    input   logic         i_riscv_em_inst_addr_misaligned_e   , //<--- csr
    input   logic         i_riscv_em_load_addr_misaligned_e   , //<--- csr
    input   logic         i_riscv_em_store_addr_misaligned_e  , //<--- csr
    input   logic [63:0]  i_riscv_em_csrwritedata_e           , //<--- csr
    input   logic [4:0]   i_riscv_em_rs1addr_e                , //<--- csr
    output  logic         o_riscv_em_regw_m                   ,
    output  logic [1:0]   o_riscv_em_resultsrc_m              ,
    output  logic [1:0]   o_riscv_em_storesrc_m               ,
    output  logic [2:0]   o_riscv_em_memext_m                 ,
    output  logic [63:0]  o_riscv_em_pcplus4_m                ,
    output  logic [63:0]  o_riscv_em_result_m                 ,
    output  logic [63:0]  o_riscv_em_storedata_m              ,
    output  logic [4:0]   o_riscv_em_rdaddr_m                 ,
    output  logic [63:0]  o_riscv_em_imm_m                    ,
    output  logic [6:0]   o_riscv_de_opcode_m                 ,
    output  logic         o_riscv_em_ecall_m_m                , //<--- trap 
    output  logic [11:0]  o_riscv_em_csraddress_m             , //<--- trap
    output  logic         o_riscv_em_illegal_inst_m           , //<--- trap
    output  logic         o_riscv_em_iscsr_m                  , //<--- csr
    output  logic [2:0]   o_riscv_em_csrop_m                  , //<--- csr
    output  logic [63:0]  o_riscv_em_addressalu_m             , //<--- csr
    output  logic         o_riscv_em_inst_addr_misaligned_m   , //<--- csr
    output  logic         o_riscv_em_load_addr_misaligned_m   , //<--- csr
    output  logic         o_riscv_em_store_addr_misaligned_m  , //<--- csr
    output  logic [63:0]  o_riscv_em_csrwritedata_m           , //<--- csr  
    output  logic [4:0]   o_riscv_em_rs1addr_m                  //<--- csr
  );


  always_ff @ (posedge i_riscv_em_clk or posedge i_riscv_em_rst)
    begin :em_pff_write_proc
        if (i_riscv_em_rst)
          begin:em_pff_write_proc
            o_riscv_em_regw_m                   <= 'b0;
            o_riscv_em_resultsrc_m              <= 'b0;
            o_riscv_em_storesrc_m               <= 'b0;
            o_riscv_em_memext_m                 <= 'b0;
            o_riscv_em_pcplus4_m                <= 'b0;
            o_riscv_em_result_m                 <= 'b0;
            o_riscv_em_storedata_m              <= 'b0;
            o_riscv_em_rdaddr_m                 <= 'b0;
            o_riscv_em_imm_m                    <= 'b0;            
            o_riscv_de_opcode_m                 <= 'b0;
            o_riscv_em_ecall_m_m                <= 'b0; 
            o_riscv_em_csraddress_m             <= 'b0; 
            o_riscv_em_illegal_inst_m           <= 'b0;
            o_riscv_em_iscsr_m                  <= 'b0; 
            o_riscv_em_csrop_m                  <= 'b0; 
            o_riscv_em_rs1addr_m                <= 'b0;
            o_riscv_em_addressalu_m             <= 'b0;
            o_riscv_em_csrwritedata_m           <= 'b0;  
            o_riscv_em_inst_addr_misaligned_m   <= 'b0;
            o_riscv_em_load_addr_misaligned_m   <= 'b0;
            o_riscv_em_store_addr_misaligned_m  <= 'b0;  
            //---------------------------->
            `ifdef TEST
            o_riscv_em_inst                     <= 'b0;
            o_riscv_em_cinst                    <= 'b0;
            o_riscv_em_pc                       <= 'b0;
            `endif
            //<----------------------------
          end
        else if(i_riscv_em_flush)
          begin
            o_riscv_em_regw_m                   <= 'b0;
            o_riscv_em_resultsrc_m              <= 'b0;
            o_riscv_em_storesrc_m               <= 'b0;
            o_riscv_em_memext_m                 <= 'b0;
            o_riscv_em_pcplus4_m                <= 'b0;
            o_riscv_em_result_m                 <= 'b0;
            o_riscv_em_storedata_m              <= 'b0;
            o_riscv_em_rdaddr_m                 <= 'b0;
            o_riscv_em_imm_m                    <= 'b0;
            o_riscv_de_opcode_m                 <= 'b0;
            o_riscv_em_csrwritedata_m           <= 'b0; 
            o_riscv_em_ecall_m_m                <= 'b0; 
            o_riscv_em_csraddress_m             <= 'b0; 
            o_riscv_em_illegal_inst_m           <= 'b0;
            o_riscv_em_iscsr_m                  <= 'b0; 
            o_riscv_em_csrop_m                  <= 'b0; 
            o_riscv_em_addressalu_m             <= 'b0;
            o_riscv_em_inst_addr_misaligned_m   <= 'b0;
            o_riscv_em_load_addr_misaligned_m   <= 'b0;
            o_riscv_em_store_addr_misaligned_m  <= 'b0;  
            o_riscv_em_rs1addr_m                <= 'b0;
            //---------------------------------------->
            `ifdef TEST
            o_riscv_em_inst                     <= 'b0;
            o_riscv_em_cinst                    <= 'b0;
            o_riscv_em_pc                       <= 'b0;
            `endif
            //<----------------------------------------
          end
        else if(!i_riscv_em_en)
          begin
            o_riscv_em_regw_m                   <= i_riscv_em_regw_e ;
            o_riscv_em_resultsrc_m              <= i_riscv_em_resultsrc_e;
            o_riscv_em_storesrc_m               <= i_riscv_em_storesrc_e;
            o_riscv_em_memext_m                 <= i_riscv_em_memext_e;
            o_riscv_em_pcplus4_m                <= i_riscv_em_pcplus4_e;
            o_riscv_em_result_m                 <= i_riscv_em_result_e;
            o_riscv_em_storedata_m              <= i_riscv_em_storedata_e;
            o_riscv_em_rdaddr_m                 <= i_riscv_em_rdaddr_e;
            o_riscv_em_imm_m                    <= i_riscv_em_imm_e;
            o_riscv_de_opcode_m                 <= i_riscv_de_opcode_e;
            o_riscv_em_ecall_m_m                <= i_riscv_em_ecall_m_e; 
            o_riscv_em_csraddress_m             <= i_riscv_em_csraddress_e; 
            o_riscv_em_illegal_inst_m           <= i_riscv_em_illegal_inst_e;
            o_riscv_em_iscsr_m                  <= i_riscv_em_iscsr_e ; 
            o_riscv_em_csrop_m                  <= i_riscv_em_csrop_e ; 
            o_riscv_em_addressalu_m             <= i_riscv_em_addressalu_e;
            o_riscv_em_inst_addr_misaligned_m   <= i_riscv_em_inst_addr_misaligned_e;
            o_riscv_em_load_addr_misaligned_m   <= i_riscv_em_load_addr_misaligned_e;
            o_riscv_em_store_addr_misaligned_m  <= i_riscv_em_store_addr_misaligned_e ; 
            o_riscv_em_csrwritedata_m           <= i_riscv_em_csrwritedata_e ;
            o_riscv_em_rs1addr_m                <= i_riscv_em_rs1addr_e;
            //----------------------------------------->
            `ifdef TEST
            o_riscv_em_inst                     <= i_riscv_em_inst;
            o_riscv_em_cinst                    <= i_riscv_em_cinst;
            o_riscv_em_pc                       <= i_riscv_em_pc;
            `endif
            //<-----------------------------------------
          end
    end
endmodule