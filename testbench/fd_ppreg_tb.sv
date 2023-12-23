/**********************************************************/
/* Module Name: riscv_fd_ppreg                            */
/* Last Modified Date: 12/23/2023                         */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns

module riscv_fd_ppreg_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic clk,rst,en;
  logic [63:0]  pc_f, inst_f, pcplus4_f;
  logic [63:0]  pc_d, inst_d, pcplus4_d;

/********************* Initial Blocks *********************/
  initial begin : proc_testing
    en = 'b0;
    pc_f = 'b0;
    inst_f = 'b0;
    pcplus4_f = 'b0;
    enable_test();
    #CLK_PERIOD
    normal_test();
    #CLK_PERIOD $stop;
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
  task clear_test();
    begin
      rst = 1'b0;
      #CLK_PERIOD
      rst = 1'b0;
      #CLK_PERIOD
      if({pc_d,inst_d,pcplus4_d} != 'h0)  $display("[CLR] TEST FAILED");
      else                                $display("[CLR] TEST PASSED");
    end
  endtask

task enable_test();
  begin
    clear_test();
    en = 'b0;
    @(posedge clk)
    pc_f = $random;
    inst_f = $random;
    pcplus4_f = $random;
    #HALF_PERIOD
    @(posedge clk)
    if((pc_d != 'b0) && (inst_d != 'b0) && (pcplus4_d != 'b0)) 
      $display("[EN] TEST FAILED");
    else
      $display("[EN] TEST PASSED");
  end
endtask

task normal_test();
  begin
    en = 'b1;
    @(posedge clk)
    pc_f = 'h457ef8c2;
    inst_f = 'hff010113;
    pcplus4_f = pc_f + 'h4;
    #HALF_PERIOD
    @(posedge clk)
    if((pc_d != 'h457ef8c2) && (inst_d != 'hff010113) && (pcplus4_d != 'h457ef8c6)) 
      $display("[PPR] TEST FAILED");
    else
      $display("[PPR] TEST PASSED");
  end
endtask

/******************** DUT Instantiation *******************/

  riscv_fd_ppreg DUT
  (
    .i_riscv_fd_clk(clk),
    .i_riscv_fd_clr(rst),
    .i_riscv_fd_en(en),
    .i_riscv_fd_pc_f(pc_f),
    .i_riscv_fd_inst_f(inst_f),
    .i_riscv_fd_pcplus4_f(pcplus4_f),
    .o_riscv_fd_pc_d(pc_d),
    .o_riscv_fd_inst_d(inst_d),
    .o_riscv_fd_pcplus4_d(pcplus4_d)
  );
endmodule