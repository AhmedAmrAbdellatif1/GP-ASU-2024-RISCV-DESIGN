/**********************************************************/
/* Module Name: riscv_em_ppreg (Register)               */
/* Last Modified Date: 21/12/2023                       */
/* By: Rana Mohamed                                     */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_em_ppreg_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic        i_riscv_em_clk;
  logic [63:0] i_riscv_em_pcplus4_e;
  logic [63:0] i_riscv_em_aluresult_e;
  logic [63:0] i_riscv_em_storedata_e;
  logic [63:0] i_riscv_em_rdaddr_e;
  logic [63:0] i_riscv_em_imm_e;
  logic        i_riscv_em_memw_e; 
  logic [2:0]  i_riscv_em_memext_e;
  logic [1:0]  i_riscv_em_resultsrc_e;
  logic        i_riscv_em_regw_e;
  logic [63:0] o_riscv_em_pcplus4_m;  
  logic [63:0] o_riscv_em_aluresult_m;
  logic [63:0] o_riscv_em_storedata_m;
  logic [63:0] o_riscv_em_rdaddr_m;
  logic [63:0] o_riscv_em_imm_m;
  logic        o_riscv_em_memw_m; 
  logic [2:0]  o_riscv_em_memext_m;
  logic [1:0]  o_riscv_em_resultsrc_m;
  logic        o_riscv_em_regw_m;

/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_em_clk = 1'b0;
   i_riscv_em_pcplus4_e = 64'd0;
   i_riscv_em_aluresult_e = 64'd0;
   i_riscv_em_storedata_e = 64'd0;
   i_riscv_em_rdaddr_e = 64'd0;
   i_riscv_em_imm_e = 64'd0;
   i_riscv_em_memw_e = 1'b0; 
   i_riscv_em_memext_e = 3'd0;
   i_riscv_em_resultsrc_e = 2'd0;
   i_riscv_em_regw_e = 1'b0; 


   #CLK_PERIOD ;
   i_riscv_em_pcplus4_e = 64'd7688;
   i_riscv_em_aluresult_e = 64'd980;
   i_riscv_em_storedata_e = 64'd689;
   i_riscv_em_rdaddr_e = 64'd8808;
   i_riscv_em_imm_e = 64'd567;
   i_riscv_em_memw_e = 1'b1; 
   i_riscv_em_memext_e = 3'd3;
   i_riscv_em_resultsrc_e = 2'd2;
   i_riscv_em_regw_e = 1'b1;

   #CLK_PERIOD ; 

   if (o_riscv_em_pcplus4_m != i_riscv_em_pcplus4_e)
    $display ("riscv_em_pcplus4 capture  falied");

   if (o_riscv_em_aluresult_m != i_riscv_em_aluresult_e)
    $display ("riscv_em_aluresult capture falied");

   if (o_riscv_em_storedata_m != i_riscv_em_storedata_e)
    $display ("riscv_em_storedata capture falied");

   if (o_riscv_em_rdaddr_m != i_riscv_em_rdaddr_e)
    $display ("riscv_em_rdaddr capture falied");

   if (o_riscv_em_imm_m != i_riscv_em_imm_e)
    $display ("riscv_em_imm capture falied");

   if (o_riscv_em_memw_m != i_riscv_em_memw_e)
    $display ("riscv_em_memw capture falied");

   if (o_riscv_em_memext_m != i_riscv_em_memext_e)
    $display ("riscv_em_memext capture falied");

   if (o_riscv_em_resultsrc_m != i_riscv_em_resultsrc_e)
    $display ("riscv_em_memext capture falied");

   if (o_riscv_em_regw_m != i_riscv_em_regw_e)
    $display ("riscv_em_regw capture falied");

   #(10*CLK_PERIOD) ;

   $stop 

  end



  /** Clock Generation Block **/
  initial begin : proc_clock
    i_riscv_em_clk = 1'b0;
    forever begin
      #HALF_PERIOD i_riscv_em_clk = ~ i_riscv_em_clk;
    end
  end



/******************** DUT Instantiation *******************/

  riscv_em_ppreg DUT
  (
   .*
  );


endmodule