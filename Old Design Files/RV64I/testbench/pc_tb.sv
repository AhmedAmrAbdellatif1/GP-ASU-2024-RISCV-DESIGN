/**********************************************************/
/* Module Name:                                           */
/* Last Modified Date:                                    */
/* By:Adbelrahman                                         */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_pc_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;
   parameter WIDTH = 64;
    parameter DELAY = 500;
/************** Internal Signals Declaration **************/
  logic  clk;
  logic  rst;
  logic  stall;
  logic [WIDTH-1:0] nextpc;
  logic [WIDTH-1:0] pc;
  
/********************* Initial Blocks *********************/
  initial begin : proc_testing
    Reset();
    nextpc = 'h7ffff;
    stall = 'b0;
    CheckEquality("PC reset value equal 0 ", pc, 0); 
    #CLK_PERIOD
    nextpc = 'h80000;
    CheckEquality("PC ", pc, 'h7ffff);
    #CLK_PERIOD
     nextpc = 'h80004;
     stall = 'b1;
    CheckEquality("PC ", pc, 'h80000);
    #CLK_PERIOD
    CheckEquality("PC Stalling ", pc, 'h80000);
    #DELAY //10 CLK_PERIOD
    CheckEquality("PC Stalling ", pc, 'h80000);
    stall = 'b0;
    #DELAY 
    CheckEquality("PC Unstalling ", pc, 'h80004);
    
    $stop;
    
    
  end


  /** Clock Generation Block **/
  initial begin : proc_clock
    clk = 1'b0;
    forever begin
      #HALF_PERIOD clk = ~clk;
    end
  end

/******************** Tasks & Functions *******************/
task CheckEquality(string signal_name, logic [WIDTH-1:0] A, logic [WIDTH-1:0] B);
    if (A === B)
      begin
      $display("%s Success", signal_name);
      end
    else
      begin
      $display("%s Failure", signal_name);
      end
endtask

task Reset();
 #CLK_PERIOD
 rst=1'b1;
 #CLK_PERIOD
 rst=1'b0;
endtask


/******************** DUT Instantiation *******************/

  riscv_pc DUT
  (
    .i_riscv_pc_clk(clk),
    .i_riscv_pc_stallpc(stall),
    .i_riscv_pc_rst(rst),
    .i_riscv_pc_nextpc(nextpc),
    .o_riscv_pc_pc(pc)
  );
endmodule


