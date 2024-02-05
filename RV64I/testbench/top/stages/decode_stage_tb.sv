`timescale 1ns/1ns

module riscv_top_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

  integer i;

/************** Internal Signals Declaration **************/
  logic clk,rst;
  logic [4:0] rs1addr, rs2addr, rdaddr;
  logic [63:0] rs1data, rs2data, imm;

/********************* Initial Blocks *********************/
  initial begin : proc_decode
    #CLK_PERIOD     // delay for first instruction to come
    i = 1;
    @(negedge clk)
    #1
    // auipc x6, 0x100 
      utype_check('d6,'h100000);  // 1
    
    // addi x8, x0, 10
      itype_check('d0,'d8,'d0,'sd10);  // 2

    // addi x9, x0, 20
      itype_check('d0,'d9,'d0,'sd20);  // 3

    // sd x6 0 x0
      store_check('d0,'d6,'d0);  // 4  

    // ld x7 0 x0
      load_check('d0,'d7,'d0);  // 5

    // add x10 x8 x9
      rtype_check('d8, 'd9, 'd10, 10, 20);  // 6

    // lui x5 0x20000
      utype_check('d5,'sh20000000);  // 7

    // addiw x4 x0 18
      itype_check('d0,'d4,'d0,'sd18);  // 8
      
    // sltu x3 x8 x9
      rtype_check('d8, 'd9, 'd3, 'd10, 'd20);  // 9

    // bne x6 x7 -20
      btype_check('d6,'d7,'h100000,'h100000,-'sd20);  // 10

    // addi x8 x0 15
      itype_check('d0,'d8,'d0,'d15);  // 11

    // sub x27 x8 x9
      rtype_check('d8, 'd9, 'd27, 'd10, 'd20);  // 12

    // or x29 x9 x8
      rtype_check('d9, 'd8, 'd29, 'd20, 'd10);  // 13

    // slliw x28 x9 2
      itype_check('d9, 'd28, 'd20, 'd2);  // 14

    // addi x0 x0 0
      itype_check('d0, 'd0, 'd0, 'd0);  // 15

    // addi x9 x0 30
      itype_check('d0, 'd9, 'd0, 'd30);  // 16

    // add x0 x9 x9
      rtype_check('d9, 'd9, 'd0, 'd20, 'd20);  // 17
    
    // lb x7 0 x6
      load_check('d6, 'd7, 'd0);  // 18
    
    // add x4 x0 x7
      rtype_check('d0, 'd7, 'd4, 'd0, 'sd1048576);  // 19

    // add x4 x0 x7 --> stalled  due to load
      rtype_check('d0, 'd7, 'd4, 'd0, 'sd1048576);  // 20
    
    // beq x0 x0 16
      btype_check('d0,'d0,'d0,'d0,'sd16);  // 21
    
    // addi x17 x17 124
      itype_check('d17,'d17,'d0, 'd124);  // 22

    // addi x18 x18 125 --> flushed = nop
      itype_check('d0, 'd0, 'd0, 'd0);  // 23
    // addi x19 x19 127 --> ignored due to branch

    // addi x20 x20 10 --> branched to this inst
      itype_check('d20, 'd20, 'd0, 'd10);  // 24

    // jal x5 8
      jtype_check('d5, 'd8);  // 25

    // addi x0 x0 0
      itype_check('d0, 'd0, 'd0, 'd0);  // 26
    
    // addi x0 x0 0 --> flushed = nop
      itype_check('d0, 'd0, 'd0, 'd0);  // 27
    
    // addi x0 x0 0 --> jumped to this inst
      itype_check('d0, 'd0, 'd0, 'd0);  // 28

    // jalr x11 x0 120
      itype_check('d0, 'd11, 'd0, 'd120);  // 29
    
    // addi x1 x2 124
      itype_check('d2, 'd1, 'd56, 'd124);  // 30
    
    // addi x0 x0 0 --> flushed = nop
      itype_check('d0, 'd0, 'd0, 'd0);  // 31

    // addi x1 x2 127
      itype_check('d2, 'd1, 'd56, 'd127);  // 32
    
    // addi x1, x0, 10
      itype_check('d0, 'd1, 'd0, 'd10);  // 33
    $stop;
  end

  /** Reseting Block **/
  initial begin : proc_reseting
    rst = 1'b1;
    #CLK_PERIOD
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

task rtype_check;
  input [4:0] a1,a2,a3;
  input [63:0] d1,d2;
  begin
    rs1addr_check(a1);
    rs2addr_check(a2);
    rdaddr_check(a3);
    rs1data_check(d1);
    rs2data_check(d2);
  end
  #CLK_PERIOD; i++;
endtask

task itype_check;
  input [4:0] a1,a3;
  input [63:0] d1,imm_i;
  begin
    rs1addr_check(a1);
    rdaddr_check(a3);
    rs1data_check(d1);
    imm_check(imm_i);
    #CLK_PERIOD; i++;
  end
endtask  

task utype_check;
  input [4:0] a3;
  input [63:0] imm_u;
  begin
    rdaddr_check(a3);
    imm_check(imm_u);
    #CLK_PERIOD; i++;
  end
endtask

task btype_check;
  input [4:0] a1,a2;
  input [63:0] d1,d2,imm_b;
  begin
    rs1addr_check(a1);
    rs2addr_check(a2);
    rs1data_check(d1);
    rs2data_check(d2);
    imm_check(imm_b);
  end
   #CLK_PERIOD; i++;
endtask

task jtype_check;
  input [4:0] a3;
  input [63:0] imm_j;
  begin
    rdaddr_check('d5);
    imm_check('sd8);
    #CLK_PERIOD; i++;
  end
endtask

task store_check;
  input [4:0] a1,a2;
  input [63:0] imm_s;
  //input [63:0] d2;
  begin
    rs1addr_check(a1);
    rs2addr_check(a2);
    //rs2data_check(d2);
    imm_check(imm_s);
    #CLK_PERIOD; i++;
  end
endtask

task load_check;
  input [4:0] a1,a3;
  input [63:0] imm_s;
  //input [63:0] d2;
  begin
    rs1addr_check(a1);
    rdaddr_check(a3);
    imm_check(imm_s);
    #CLK_PERIOD; i++;
  end
endtask


assign rs1addr  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs1addr;  
task rs1addr_check;
  input [4:0] expect_addr;
    begin
      if(rs1addr!= expect_addr) $display("[%2d] rs1 addr failed",i);
    end
endtask


assign rs2addr  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs2addr;
task rs2addr_check;
    input [4:0] expect_addr;
    begin
      if(rs2addr!= expect_addr) $display("[%2d] rs2 addr failed",i);
    end
endtask


assign rdaddr   = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rdaddr;
task rdaddr_check;
    input [4:0] expect_addr;
    begin
      if(rdaddr!= expect_addr) $display("[%2d] rd addr failed",i);
    end
endtask


assign rs1data  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs1data;
task rs1data_check;
    input [63:0] expect_data;
    begin
      if(rs1data!= expect_data) $display("[%2d] rs1 data failed",i);
    end
endtask


assign rs2data  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs2data;  
task rs2data_check;
    input [63:0] expect_data;
    begin
      if(rs2data!= expect_data) $display("[%2d] rs2 data failed",i);
    end
endtask


assign imm  = DUT.u_top_datapath.u_riscv_dstage.o_riscv_dstage_simm;
task imm_check;
    input [63:0] expect_imm;
    begin
      if(imm!= expect_imm) $display("[%2d] imm failed",i);
    end
endtask

/******************** DUT Instantiation *******************/

  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );

endmodule