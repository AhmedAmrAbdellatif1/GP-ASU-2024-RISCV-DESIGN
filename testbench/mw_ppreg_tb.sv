/**********************************************************/
/* Module Name: riscv_mw_ppreg (Register)               */
/* Last Modified Date: 21/12/2023                       */
/* By: Rana Mohamed                                     */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_mw_ppreg_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic        i_riscv_mw_clk;
  logic [63:0] i_riscv_mw_pcplus4_m;
  logic [63:0] i_riscv_mw_aluresult_m;
  logic [63:0] i_riscv_mw_uimm_m;
  logic [63:0] i_riscv_mw_memload_m;
  logic [63:0] i_riscv_mw_rdaddr_m;
  logic [1:0]  i_riscv_mw_resultsrc_m;
  logic        i_riscv_mw_regw_m;
  logic [63:0] o_riscv_mw_pcplus4_wb;  
  logic [63:0] o_riscv_mw_aluresult_wb;
  logic [63:0] o_riscv_mw_uimm_wb;
  logic [63:0] o_riscv_mw_memload_wb;
  logic [63:0] o_riscv_mw_rdaddr_wb;
  logic [1:0]  o_riscv_mw_resultsrc_wb;
  logic        o_riscv_mw_regw_wb;

/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_mw_clk = 1'b0;
   i_riscv_mw_pcplus4_m = 64'd0;
   i_riscv_mw_aluresult_m = 64'd0;
   i_riscv_mw_uimm_m = 64'd0;
   i_riscv_mw_memload_m = 64'd0;
   i_riscv_mw_rdaddr_m = 64'd0;
   i_riscv_mw_resultsrc_m = 2'd0;
   i_riscv_mw_regw_m = 1'b0; 


   #CLK_PERIOD ;
   i_riscv_mw_pcplus4_m = 64'd7688;
   i_riscv_mw_aluresult_m = 64'd980;
   i_riscv_mw_uimm_m = 64'd879;
   i_riscv_mw_storedata_m = 64'd689;
   i_riscv_mw_rdaddr_m = 64'd8808;
   i_riscv_mw_resultsrc_m = 2'd2;
   i_riscv_mw_regw_m = 1'b1;

   #CLK_PERIOD ; 

   if (o_riscv_mw_pcplus4_wb != i_riscv_mw_pcplus4_m)
    $display ("riscv_mw_pcplus4 capture  falied")

   if (o_riscv_mw_aluresult_wb != i_riscv_mw_aluresult_m)
    $display ("riscv_mw_aluresult capture falied")

   if (o_riscv_mw_uimm_wb != i_riscv_mw_uimm_m)
    $display ("riscv_mw_uimm capture falied")

   if (o_riscv_mw_storedata_wb != i_riscv_mw_storedata_m)
    $display ("riscv_mw_storedata capture falied")

   if (o_riscv_mw_rdaddr_wb != i_riscv_mw_rdaddr_m)
    $display ("riscv_mw_rdaddr capture falied")

   if (o_riscv_mw_resultsrc_wb != i_riscv_mw_resultsrc_m)
    $display ("riscv_mw_mmwext capture falied")

   if (o_riscv_mw_regw_wb != i_riscv_mw_regw_m)
    $display ("riscv_mw_regw capture falied")

   #(10*CLK_PERIOD) ;

   $stop 

  end



  /** Clock Generation Block **/
  initial begin : proc_clock
    i_riscv_mw_clk = 1'b0;
    forever begin
      #HALF_PERIOD i_riscv_mw_clk = ~ i_riscv_mw_clk;
    end
  end



/******************** DUT Instantiation *******************/

  riscv_mw_ppreg DUT
  (
   .*
  );


endmodule