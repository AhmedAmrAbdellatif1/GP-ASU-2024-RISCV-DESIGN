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
  logic        i_riscv_em_rst;
  logic [63:0] i_riscv_em_pcplus4_e;
  logic [63:0] i_riscv_em_aluresult_e;
  logic [63:0] i_riscv_em_storedata_e;
  logic [63:0] i_riscv_em_rdaddr_e;
  logic [63:0] i_riscv_em_imm_e;
  logic        i_riscv_em_memw_e; 
  logic [2:0]  i_riscv_em_memext_e;
  logic [1:0]  i_riscv_em_storesrc_e;
  logic [1:0]  i_riscv_em_resultsrc_e;
  logic        i_riscv_em_regw_e;
  logic [63:0] o_riscv_em_pcplus4_m;  
  logic [63:0] o_riscv_em_aluresult_m;
  logic [63:0] o_riscv_em_storedata_m;
  logic [63:0] o_riscv_em_rdaddr_m;
  logic [63:0] o_riscv_em_imm_m;
  logic        o_riscv_em_memw_m; 
  logic [2:0]  o_riscv_em_memext_m;
  logic [1:0]  o_riscv_em_storesrc_m;
  logic [1:0]  o_riscv_em_resultsrc_m;
  logic        o_riscv_em_regw_m;

/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_em_clk = 1'b0;
   i_riscv_em_rst = 1'b0;
   i_riscv_em_pcplus4_e = 64'd0;
   i_riscv_em_aluresult_e = 64'd0;
   i_riscv_em_storedata_e = 64'd0;
   i_riscv_em_rdaddr_e = 64'd0;
   i_riscv_em_imm_e = 64'd0;
   i_riscv_em_memw_e = 1'b0; 
   i_riscv_em_memext_e = 3'd0;
   i_riscv_em_resultsrc_e = 2'd0;
   i_riscv_em_storesrc_e = 2'd0;
   i_riscv_em_regw_e = 1'b0; 

   #CLK_PERIOD ;
   i_riscv_mw_rst = 1'b1;
   #CLK_PERIOD ;
   i_riscv_em_rst = 1'b0;
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

   //testing reg capture

   if (o_riscv_em_pcplus4_m != i_riscv_em_pcplus4_e)
    $display ("riscv_em_pcplus4 capture  falied");

   if (o_riscv_em_aluresult_m != i_riscv_em_aluresult_e)
    $display ("riscv_em_aluresult capture falied");

   if (o_riscv_em_storedata_m != i_riscv_em_storedata_e)
    $display ("riscv_em_storedata capture falied");

  if (o_riscv_em_storesrc_m != i_riscv_em_storesrc_e)
    $display ("riscv_em_storesrc capture falied");

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


   #CLK_PERIOD ;
   i_riscv_mw_rst = 1'b1;
   #CLK_PERIOD ;
   i_riscv_em_rst = 1'b0;
   #1;


   //testing reg rst

   if (o_riscv_em_pcplus4_m != 0)
    $display ("riscv_em_pcplus4 rst  falied");

   if (o_riscv_em_aluresult_m != 0)
    $display ("riscv_em_aluresult rst falied");

   if (o_riscv_em_storedata_m != 0)
    $display ("riscv_em_storedata rst falied");

  if (o_riscv_em_storesrc_m != 0)
    $display ("riscv_em_storesrc rst falied");

   if (o_riscv_em_rdaddr_m != 0)
    $display ("riscv_em_rdaddr rst falied");

   if (o_riscv_em_imm_m != 0)
    $display ("riscv_em_imm rst falied");

   if (o_riscv_em_memw_m != 0)
    $display ("riscv_em_memw rst falied");

   if (o_riscv_em_memext_m != 0)
    $display ("riscv_em_memext rst falied");

   if (o_riscv_em_resultsrc_m != 0)
    $display ("riscv_em_memext rst falied");

   if (o_riscv_em_regw_m != 0)
    $display ("riscv_em_regw rst falied");

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