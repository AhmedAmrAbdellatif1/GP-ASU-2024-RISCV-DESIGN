`timescale 1ns/1ns

module riscv_top_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

/************** Internal Signals Declaration **************/
  logic clk,rst;

/********************* Initial Blocks *********************/
  initial begin : proc_decode
    #CLK_PERIOD // delay for reste
    #CLK_PERIOD // delay for first instruction to come
  end

  /** Reseting Block **/
  initial begin : proc_reseting
    rst = 1'b1;
    #CLK_PERIOD;
    rst = 1'b0;
  end

  /** Clock Generation Block **/
  initial begin : proc_clock
    clk = 1'b1;
    forever begin
      #HALF_PERIOD clk = ~clk;
    end
  end

/******************** Tasks & Functions *******************/
  
  
assign rs1addr  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs1addr;  
task rs1addr_check;
input [4:0] expect_addr;
  begin
    if(rs1addr!= expect_addr) $display("[%0t] rs1 addr failed",$time);
  end
endtask


assign rs2addr  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs2addr;
task rs2addr_check;
  input [4:0] expect_addr;
  begin
    if(rs2addr!= expect_addr) $display("[%0t] rs2 addr failed",$time);
  end
endtask


assign rdaddr   = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rdaddr;
task rdaddr_check;
  input [4:0] expect_addr;
  begin
    if(rdaddr!= expect_addr) $display("[%0t] rs1 addr failed",$time);
  end
endtask


assign rs1data  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs1data;
task rs1data_check;
  input [63:0] expect_data;
  begin
    if(rs1data!= expect_data) $display("[%0t] rs1 addr failed",$time);
  end
endtask


assign rs2data  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs2data;  
task rs2data_check;
  input [63:0] expect_data;
  begin
    if(rs2data!= expect_data) $display("[%0t] rs2 data failed",$time);
  end
endtask


assign imm  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_simm;
task imm_check;
  input [63:0] expect_imm;
  begin
    if(imm!= expect_imm) $display("[%0t] imm failed",$time);
  end
endtask

/******************** DUT Instantiation *******************/

  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );

endmodule