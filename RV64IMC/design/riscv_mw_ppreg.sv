  module riscv_mw_ppreg(
    input   logic         i_riscv_mw_clk, 
    input   logic         i_riscv_mw_rst, 
    input   logic [63:0]  i_riscv_mw_pcplus4_m,
    input   logic [63:0]  i_riscv_mw_result_m,
    input   logic [63:0]  i_riscv_mw_uimm_m,
    input   logic [63:0]  i_riscv_mw_memload_m,
    input   logic [4:0]   i_riscv_mw_rdaddr_m,
    input   logic [1:0]   i_riscv_mw_resultsrc_m,
    input   logic         i_riscv_mw_regw_m,
    output  logic [63:0]  o_riscv_mw_pcplus4_wb,
    output  logic [63:0]  o_riscv_mw_result_wb,
    output  logic [63:0]  o_riscv_mw_uimm_wb,
    output  logic [63:0]  o_riscv_mw_memload_wb,
    output  logic [4:0]   o_riscv_mw_rdaddr_wb,
    output  logic [1:0]   o_riscv_mw_resultsrc_wb,
    output  logic         o_riscv_mw_regw_wb,
    //--------------------------------->
    input   logic [31:0]  i_riscv_mw_inst,
    output  logic [31:0]  o_riscv_mw_inst
    //<---------------------------------
  );  
  always_ff @(posedge i_riscv_mw_clk or posedge i_riscv_mw_rst )
    begin:mw_pff_write_proc
      if(i_riscv_mw_rst)
        begin
         o_riscv_mw_pcplus4_wb    <='b0;
         o_riscv_mw_result_wb     <='b0;
         o_riscv_mw_uimm_wb       <='b0;
         o_riscv_mw_memload_wb    <='b0;
         o_riscv_mw_rdaddr_wb     <='b0;
         o_riscv_mw_resultsrc_wb  <='b0;
         o_riscv_mw_regw_wb       <='b0; 
         o_riscv_mw_inst          <='b0;
        end
      else
        begin
          o_riscv_mw_pcplus4_wb   <=  i_riscv_mw_pcplus4_m;
          o_riscv_mw_result_wb    <=  i_riscv_mw_result_m;
          o_riscv_mw_uimm_wb      <=  i_riscv_mw_uimm_m;
          o_riscv_mw_memload_wb   <=  i_riscv_mw_memload_m;
          o_riscv_mw_rdaddr_wb    <=  i_riscv_mw_rdaddr_m;
          o_riscv_mw_resultsrc_wb <=  i_riscv_mw_resultsrc_m;
          o_riscv_mw_regw_wb      <=  i_riscv_mw_regw_m;
          o_riscv_mw_inst         <=  i_riscv_mw_inst;
        end
    end
  endmodule 