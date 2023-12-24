  module riscv_em_ppreg(
    input  logic        i_riscv_em_clk,
    input  logic        i_riscv_em_rst,
    input  logic        i_riscv_em_memw_e,
    input  logic        i_riscv_em_regw_e,
    input  logic [1:0]  i_riscv_em_resultsrc_e,
    input  logic [1:0]  i_riscv_em_storesrc_e,
    input  logic [2:0]  i_riscv_em_memext_e,
    input  logic [63:0] i_riscv_em_pcplus4_e,
    input  logic [63:0] i_riscv_em_aluresult_e,
    input  logic [63:0] i_riscv_em_storedata_e,
    input  logic [63:0] i_riscv_em_rdaddr_e,
    input  logic [63:0] i_riscv_em_imm_e,
    output logic        o_riscv_em_memw_m, 
    output logic        o_riscv_em_regw_m,
    output logic [1:0]  o_riscv_em_resultsrc_m,
    output logic [1:0]  o_riscv_em_storesrc_m,
    output logic [2:0]  o_riscv_em_memext_m,
    output logic [63:0] o_riscv_em_pcplus4_m,
    output logic [63:0] o_riscv_em_aluresult_m,
    output logic [63:0] o_riscv_em_storedata_m,
    output logic [63:0] o_riscv_em_rdaddr_m,
    output logic [63:0] o_riscv_em_imm_m    
  );

  always_ff @ (posedge i_riscv_em_clk)
    begin :em_pff_write_proc
        if (i_riscv_em_rst)
          begin:em_pff_write_proc
            o_riscv_em_memw_m      <='b0;
            o_riscv_em_regw_m      <='b0;
            o_riscv_em_resultsrc_m <='b0;
            o_riscv_em_storesrc_m  <='b0;
            o_riscv_em_memext_m    <='b0;
            o_riscv_em_pcplus4_m   <='b0;
            o_riscv_em_aluresult_m <='b0;
            o_riscv_em_storedata_m <='b0;
            o_riscv_em_rdaddr_m    <='b0;
            o_riscv_em_imm_m       <='b0;            
          end
        else
          begin
            o_riscv_em_memw_m      <= i_riscv_em_memw_e ; 
            o_riscv_em_regw_m      <= i_riscv_em_regw_e ;
            o_riscv_em_resultsrc_m <= i_riscv_em_resultsrc_e;
            o_riscv_em_storesrc_m  <= i_riscv_em_storesrc_e;
            o_riscv_em_memext_m    <= i_riscv_em_memext_e;
            o_riscv_em_pcplus4_m   <= i_riscv_em_pcplus4_e;
            o_riscv_em_aluresult_m <= i_riscv_em_aluresult_e;
            o_riscv_em_storedata_m <= i_riscv_em_storedata_e;
            o_riscv_em_rdaddr_m    <= i_riscv_em_rdaddr_e;
            o_riscv_em_imm_m       <= i_riscv_em_imm_e;
          end
    end
  endmodule