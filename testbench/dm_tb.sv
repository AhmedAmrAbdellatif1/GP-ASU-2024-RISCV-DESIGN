/**********************************************************/
/* Module Name: riscv_dm (Data Memory)                  */
/* Last Modified Date: 20/12/2023                       */
/* By: Rana Mohamed                                     */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_dm_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic        i_riscv_dm_clk;
  logic        i_riscv_dm_Wen;
  logic [1:0]  i_riscv_dm_sel;
  logic [63:0] i_riscv_dm_wdata;
  logic [63:0] i_riscv_dm_addr;
  logic [63:0] o_riscv_dm_rdata;   

/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_dm_Wen = 1'b0;
   i_riscv_dm_sel = 2'b0;
   i_riscv_dm_wdata = 64'b0;
   i_riscv_dm_addr = 64'b0; 
  end



  /** Clock Generation Block **/
  initial begin : proc_clock
    i_riscv_dm_clk = 1'b0;
    forever begin
      #HALF_PERIOD i_riscv_dm_clk = ~ i_riscv_dm_clk;
    end
  end

/******************** Tasks & Functions *******************/



/******************** DUT Instantiation *******************/

  riscv_dm DUT
  (
    .i_riscv_dm_clk(i_riscv_dm_clk),
    .i_riscv_dm_Wen(i_riscv_dm_Wen),
    .i_riscv_dm_sel(i_riscv_dm_sel),
    .i_riscv_dm_wdata(i_riscv_dm_wdata),
    .i_riscv_dm_addr(i_riscv_dm_addr),
    .o_riscv_dm_rdata(o_riscv_dm_rdata)
  );
endmodule