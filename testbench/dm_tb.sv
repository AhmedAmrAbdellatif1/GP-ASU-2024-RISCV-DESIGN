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
   i_riscv_dm_rst = 1'b1;  
   i_riscv_dm_wen = 1'b0;
   i_riscv_dm_sel = 2'b0;
   i_riscv_dm_wdata = 64'b0;
   i_riscv_dm_waddr = 64'b0; 
   
   #CLK_PERIOD;
   i_riscv_dm_rst = 1'b0;
   
 // Test 1: Doubleword store and load
 load_store ( 'd0 , 'h1122334455667788 ,'b11 , 'h1122334455667788) ;
 
 // Test 2: Word store and load
 load_store ( 'd4 , 'h5566778811223344 ,'b10 , 'h11223344) ;

 // Test 3: Halfword store and load 
 load_store ( 'd8 , 'h5566778844112233 ,'b01 , 'h2233) ;
 
 // Test 4: Byte store and load 
 load_store ( 'd10 , 'h5566778844332211 ,'b00 , 'h11) ;
  


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
task load_store ; 
  input [63:0] address ;
  input [63:0] data ;
  input [1:0]  sel  ;
  input [63:0] expected_out ;
    
  begin 
   i_riscv_dm_wen = 1'b0;
   i_riscv_dm_sel = sel;
   i_riscv_dm_wdata = data ;
   i_riscv_dm_waddr = address; 
   #CLK_PERIOD;
   
   // Perform store
   i_riscv_dm_wen = 1'b1;
   #CLK_PERIOD; 
    
   // Perform load
   i_riscv_dm_wen = 1'b0; 
   #CLK_PERIOD; 
   if (o_riscv_dm_rdata !== expected_out) 
   $display("(%2b)store and load failed" , sel);
   else
   $display("(%2b)store and load passed" , sel);
 end
  
endtask 


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