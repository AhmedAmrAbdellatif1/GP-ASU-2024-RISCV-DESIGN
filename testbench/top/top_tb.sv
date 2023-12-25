`timescale 1ns/1ns

module riscv_top_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic clk,rst;

/********************* Initial Blocks *********************/
  initial begin : proc_fetch
    
  end

  initial begin : proc_decode
    
  end

  initial begin : proc_execute
    
  end

  initial begin : proc_mem
    
  end

  initial begin : proc_wb
    
  end


  /** Reseting Block **/
  initial begin : proc_reseting
    rst = 1'b0;
    #CLK_PERIOD;
    rst = 1'b1;
  end

  /** Clock Generation Block **/
  initial begin : proc_clock
    clk = 1'b0;
    forever begin
      #HALF_PERIOD clk = ~clk;
    end
  end

/******************** Tasks & Functions *******************/



/******************** DUT Instantiation *******************/

  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );
endmodule