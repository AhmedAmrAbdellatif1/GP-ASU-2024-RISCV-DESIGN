/**********************************************************/
/* Module Name: riscv_dm (Data Memory)                  */
/* Last Modified Date: 20/12/2023                       */
/* By: Rana Mohamed                                     */
/**********************************************************/
`timescale 1ns/1ns

module riscv_dm_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic        i_riscv_dm_clk_n;
  logic        i_riscv_dm_rst;
  logic        i_riscv_dm_wen;
  logic [1:0]  i_riscv_dm_sel;
  logic [63:0] i_riscv_dm_wdata;
  logic [63:0] i_riscv_dm_waddr;
  logic [63:0] o_riscv_dm_rdata;   

/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_dm_clk_n = 1'b1;
   i_riscv_dm_rst = 1'b0;  
   i_riscv_dm_wen = 1'b0;
   i_riscv_dm_sel = 2'b0;
   i_riscv_dm_wdata = 64'b0;
   i_riscv_dm_waddr = 64'b0; 
   
  #CLK_PERIOD;
   
 // Test 1: Byte store and load
   i_riscv_dm_rst = 1'b1;  
   i_riscv_dm_wen = 1'b0;
   i_riscv_dm_sel = 2'b0;
   i_riscv_dm_wdata = 64'h1122334455667788;
   i_riscv_dm_waddr = 64'h0; 
   #CLK_PERIOD;
   i_riscv_dm_rst = 1'b0;

 // Perform byte store
   i_riscv_dm_wen = 1'b1;
   #CLK_PERIOD; 
    
 // Perform byte load
   i_riscv_dm_wen = 1'b0; 
   #CLK_PERIOD; 
   if (o_riscv_dm_rdata !== 64'h0088) 
   $display("Byte store and load failed");

 // Test 2: Halfword store and load
  /* i_riscv_dm_rst = 1'b1;  
   i_riscv_dm_wen = 1'b0;
   i_riscv_dm_sel = 2'b0;
   i_riscv_dm_wdata = 64'h1122334455667788;
   i_riscv_dm_waddr = 64'h10; 
   #CLK_PERIOD;
   i_riscv_dm_rst = 1'b1;

    // Perform halfword store
    i_riscv_dm_wen = 1'b1;
    #CLK_PERIOD; 
    i_riscv_dm_wen = 1'b0;

    // Perform byte load
    i_riscv_dm_wen = 1'b0;
    i_riscv_dm_waddr = 64'h10; 
    #CLK_PERIOD; 
    if (o_riscv_dm_rdata !== i_riscv_dm_wdata[15:0]) 
    $display("Halfword store and load failed");
    else
    $display("Halfword store and load passed"); */
  


    #(10*CLK_PERIOD);

     $stop;
  end

  /** Clock Generation Block **/
  initial begin : proc_clock
    i_riscv_dm_clk_n = 1'b1;
    forever begin
      #HALF_PERIOD i_riscv_dm_clk_n = ~ i_riscv_dm_clk_n;
    end
  end

/******************** Tasks & Functions *******************/



/******************** DUT Instantiation *******************/

  riscv_dm DUT
  (
    .i_riscv_dm_clk_n(i_riscv_dm_clk_n),
    .i_riscv_dm_rst(i_riscv_dm_rst),
    .i_riscv_dm_wen(i_riscv_dm_wen),
    .i_riscv_dm_sel(i_riscv_dm_sel),
    .i_riscv_dm_wdata(i_riscv_dm_wdata),
    .i_riscv_dm_waddr(i_riscv_dm_waddr),
    .o_riscv_dm_rdata(o_riscv_dm_rdata)
  );
  

endmodule