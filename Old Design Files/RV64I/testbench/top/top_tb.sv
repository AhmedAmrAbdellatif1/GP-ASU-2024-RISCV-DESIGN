`timescale 1ns/1ns

module riscv_top_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;
  parameter TEST_NUM = 10;

/************** Internal Signals Declaration **************/
  logic clk,rst;
  logic [4:0]   rs1addr, rs2addr, rdaddr;
  logic [63:0]  rs1data, rs2data, imm;
  logic [31:0]  instr;
  logic [63:0]  nextpc;
  logic [63:0]  pc;
  logic         stall_pc,pcsrc;
  logic [63:0]  pcplus4;
  logic [63:0]  aluexe;
  logic [63:0]  op1 ;
  logic [63:0]  op2 ;
  logic [63:0]  result;
  logic [63:0]  data;
  logic [2:0]   memext;
  logic [63:0]  memload;
  logic         memwrite;
  logic [1:0]   storesrc;
  logic [63:0]  data_addr;
  logic [63:0]  store_data;

  integer i,k,m;

  assign rs1addr    = DUT.u_top_core.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs1addr;  
  assign rs2addr    = DUT.u_top_core.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs2addr;
  assign rdaddr     = DUT.u_top_core.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rdaddr;
  assign rs1data    = DUT.u_top_core.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs1data;
  assign rs2data    = DUT.u_top_core.u_top_datapath.u_riscv_dstage.o_riscv_dstage_rs2data;  
  assign imm        = DUT.u_top_core.u_top_datapath.u_riscv_dstage.o_riscv_dstage_simm;
  assign pc         = DUT.u_top_core.u_top_datapath.u_riscv_fstage.o_riscv_fstage_pc;
  assign stall_pc   = DUT.u_top_core.u_top_datapath.u_riscv_fstage.i_riscv_fstage_stallpc;
  assign pcsrc      = DUT.u_top_core.u_top_datapath.u_riscv_fstage.i_riscv_fstage_pcsrc;
  assign aluexe     = DUT.u_top_core.u_top_datapath.u_riscv_fstage.i_riscv_fstage_aluexe;
  assign pcplus4    = DUT.u_top_core.u_top_datapath.u_riscv_fstage.o_riscv_fstage_pcplus4;
  assign nextpc     = DUT.u_top_core.u_top_datapath.u_riscv_fstage.o_riscv_pcmux_nextpc;
  assign instr      = DUT.riscv_im_inst_datapath;
  assign op1        = DUT.u_top_core.u_top_datapath.u_riscv_estage.o_riscv_OperandmuxA_OperandALUA ;
  assign op2        = DUT.u_top_core.u_top_datapath.u_riscv_estage.o_riscv_OperandmuxB_OperandALUB ;
  assign result     = DUT.u_top_core.u_top_datapath.u_riscv_estage.o_riscv_estage_result ;
  assign memload    = DUT.u_top_core.u_top_datapath.uriscv_mstage.o_riscv_mstage_memload;
  assign memext     = DUT.u_top_core.u_top_datapath.uriscv_mstage.i_riscv_mstage_memext;
  assign data       = DUT.u_top_core.u_top_datapath.uriscv_mstage.i_riscv_mstage_dm_rdata;
  assign storesrc   = DUT.riscv_datapath_storesrc_m_dm;
  assign memwrite   = DUT.riscv_datapath_memw_m_dm;
  assign data_addr  = DUT.riscv_datapath_memodata_addr_dm;
  assign store_data = DUT.riscv_datapath_storedata_m_dm;

/********************* Initial Blocks *********************/
  initial begin : proc_decode
      
$display("Testing Decode Stage");
    #CLK_PERIOD  ;
    #CLK_PERIOD   ;  // delay for first instruction to come
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

  end
initial begin : proc_execute
      
$display("Testing Execute Stage");
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD ;
  @(negedge clk)


  k = 1 ;  
  execute_stage_check ('d0, 'h100000, 'h100000) ;  //1  //auipc x6, 0x100 
  #CLK_PERIOD;
  k ++ ;
  execute_stage_check ('d0, 'd10, 'd10) ;          //2  //addi x8, x0, 10
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d0, 'd20, 'd20) ;          //3  //addi x9, x0, 20
  #CLK_PERIOD;
  k ++ ;   
  execute_stage_check ('d0, 'd0, 'd0) ;            //4  //sd x6, 0(x0)
  #CLK_PERIOD;
  k ++ ;
  execute_stage_check ('b0, 'd0, 'd0) ;            //5  //ld x7, 0(x0)
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d10, 'd20, 'd30) ;         //6  //add x10, x8, x9             
  #CLK_PERIOD;
  k ++ ;  
  /*execute_stage_check ('d0, 'd10, 'd10) ; */     //7  //lui x5, 0x20000
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d0, 'd18, 'd18) ;          //8  //addiw x4, x0, 18
  #CLK_PERIOD; 
  k ++ ;  
  execute_stage_check ('d10, 'd20, 'd1) ;          //9  //sltu x3, x8, x9 
  #CLK_PERIOD; 
  k ++ ; 
  execute_stage_check ('h24, -'sd20, 'd16) ;       //10  //bne x6, x7, -20 
   #CLK_PERIOD;


 //Testing Hazards : Case (1)
  k ++ ; 
  execute_stage_check ('d0, 'd15, 'd15) ;          //11  //addi x8, x0, 15 
  #CLK_PERIOD;
  k ++ ;   
  execute_stage_check ('d15, 'd20, -'sd5) ;        //12  //sub x27, x8, x9  --> rs1 value forwarded
  #CLK_PERIOD;
  k ++ ;
  execute_stage_check ('d20, 'd15, 'd31) ;         //13  //or x29, x9, x8  --> rs2 value forwarded
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d20, 'd2, 'd80) ;          //14  //slliw x28, x9, 2             
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d0, 'd0, 'd0) ;            //15  //nop
  #CLK_PERIOD;

 //Testing Hazards : Case (2)
  k ++ ;  
  execute_stage_check ('d0, 'd30, 'd30) ;          //16  //addi x9, x0, 30
  #CLK_PERIOD; 
  k ++ ;  
  //execute_stage_check ('d20, 'd20, 'd40) ;         //17  //add  x0, x9, x9  --> rs1,rs2 value not forwarded (rdaddr = 0x0)
 
 
  
  #(10*CLK_PERIOD) ;
  $stop ;
 
end

 initial begin : proc_mem
       
$display("Testing Memory Stage");
  #(3*CLK_PERIOD);
  #CLK_PERIOD;
  CheckEquality("auipc x6, 0x100 memwrite", memwrite, 0);
  #CLK_PERIOD;
  CheckEquality("addi x8, x0, 10 memwrite", memwrite, 0);

  #CLK_PERIOD;
  CheckEquality("addi x9, x0, 20 memwrite", memwrite, 0);

  #CLK_PERIOD;
  CheckEquality("sd x6, 0(x0) data", data, 0);
  CheckEquality("sd x6, 0(x0) memext", memext, 0);
  CheckEquality("sd x6, 0(x0) memload", memload, 0);
  CheckEquality("sd x6, 0(x0) memwrite", memwrite, 1);
  CheckEquality("sd x6, 0(x0) storesrc", storesrc, 'b11);
  CheckEquality("sd x6, 0(x0) data_addr", data_addr, 0);
  CheckEquality("sd x6, 0(x0) store_data", store_data, 'h100000);

  #CLK_PERIOD;
  CheckEquality("ld x7, 0(x0) memext", memext,'b011);
  CheckEquality("ld x7, 0(x0) memload", memload, 'h100000);
  CheckEquality("ld x7, 0(x0) memwrite", memwrite, 0);
  CheckEquality("ld x7, 0(x0) data_addr", data_addr, 0);


  #CLK_PERIOD;

  CheckEquality("add x10, x8, x9 memwrite", memwrite, 0);

  #CLK_PERIOD;

  CheckEquality("lui x5, 0x20000 memwrite", memwrite, 0);

  #CLK_PERIOD;

  CheckEquality("addiw x4, x0, 18 memwrite", memwrite, 0);

  #CLK_PERIOD;

  CheckEquality("sltu x3, x8, x9 memwrite", memwrite, 0);

  #CLK_PERIOD;

  CheckEquality("bne x6, x7, -20 memwrite", memwrite, 0);
  end

 initial begin : proc_fetch
   
    
$display("Testing Fetch Stage");
    /* #CLK_PERIOD;
      pc_check (0);
      instr_check('h00a00413);
      #CLK_PERIOD;
      pc_check (4);
      instr_check('h01400493);
      nextpc_check(8);
      #CLK_PERIOD;
      pc_check (8);
      instr_check('h00100317);
      #CLK_PERIOD; 
        pc_check (12);
      instr_check('h008002ef ); //jump 
      #CLK_PERIOD; 
        pc_check (16);
      instr_check('h00000013);  
      #CLK_PERIOD; 
        pc_check (20);
      instr_check('h00000013); 
      pcsrc_check(1);
        #CLK_PERIOD; 
        pc_check (24);
      instr_check('h00603023);
        #CLK_PERIOD; 
        pc_check (28);
      instr_check('h00033383);
        #CLK_PERIOD; 
        pc_check (32);
      instr_check('h00940533);
        #CLK_PERIOD; 
        pc_check (36);
      instr_check('h200002b7);
        #CLK_PERIOD; 
        pc_check (40);
      instr_check('hfe7316e3); //bne
      #CLK_PERIOD; 
        pc_check (44);
      instr_check('h0120009b);
      #CLK_PERIOD; 
        pc_check (48);
      instr_check('h00808267);
      #CLK_PERIOD; 
        pc_check (52);
      instr_check('h00000013);
      #CLK_PERIOD; 
        pc_check (56);
      instr_check('h009431b3);
      #CLK_PERIOD; 
        pc_check (60);
      instr_check('h00f00413);
        #CLK_PERIOD;
      pc_check (64);
      instr_check('h40940db3);
        #CLK_PERIOD;
      pc_check (68);
      instr_check('h0084eeb3);
        #CLK_PERIOD;
      pc_check (72);
      instr_check('h00249e1b);
        #CLK_PERIOD;
      pc_check (76);
      instr_check('h00000013);
        #CLK_PERIOD;
      pc_check (80);
      instr_check('h01e00493);
        #CLK_PERIOD;
      pc_check (84);
      instr_check('h00948033); 
        
      #CLK_PERIOD;
      
    pc_check (88);
      instr_check('h00030383);
        #CLK_PERIOD;
      pc_check (92);
      instr_check('h00700233);
      
      #CLK_PERIOD;
      pc_check (96);
      instr_check('h00000863);
        #CLK_PERIOD;
      pc_check (100);
      instr_check('h07c10093);
        #CLK_PERIOD;
      pc_check (104);
      instr_check('h07d10093);
        #CLK_PERIOD;
      pc_check (108);
      instr_check('h07f10093);
      #CLK_PERIOD;
      pc_check (112);
      instr_check('h00a00093); 
      */
      
    #CLK_PERIOD;
    pc_check(0);               // auipc x6, 0x100
    instr_check('h00100317);

    #CLK_PERIOD;
    pc_check(4);               // addi x8, x0, 10
    instr_check('h00a00413);

    #CLK_PERIOD;
    pc_check(8);               // addi x9, x0, 20
    instr_check('h01400493);

    #CLK_PERIOD;
    pc_check(12);              // sd x6, 0(x0)
    instr_check('h00603023);

    #CLK_PERIOD;
    pc_check(16);              // ld x7, 0(x0)
    instr_check('h00003383);

    #CLK_PERIOD;
    pc_check(20);              // add x10, x8, x9
    instr_check('h00940533);

    #CLK_PERIOD;
    pc_check(24);              // lui x5, 0x20000
    instr_check('h200002b7);

    #CLK_PERIOD;
    pc_check(28);              // addiw x4, x0, 18
    instr_check('h0120021b);

    #CLK_PERIOD;
    pc_check(32);              // sltu x3, x8, x9
    instr_check('h009431b3);

    #CLK_PERIOD;
    pc_check(36);              // bne x6, x7, -20
    instr_check('hfe7316e3);

    #CLK_PERIOD;
    pc_check(40);              // addi x8, x0, 15
    instr_check('h00f00413);

    #CLK_PERIOD;
    pc_check(44);              // sub x27, x8, x9
    instr_check('h40940db3);

    #CLK_PERIOD;
    pc_check(48);              // or x29, x9, x8
    instr_check('h0084eeb3);

    #CLK_PERIOD;
    pc_check(52);              // slliw x28, x9, 2
    instr_check('h00249e1b);

    #CLK_PERIOD;
    pc_check(56);              // nop
    instr_check('h00000013);

    #CLK_PERIOD;
    pc_check(60);              // addi x9, x0, 30
    instr_check('h01e00493);

    #CLK_PERIOD;
    pc_check(64);              // add x0, x9, x9
    instr_check('h00948033);

    #CLK_PERIOD;
    pc_check(68);              // lb x7, 0(x6) 
    instr_check('h00030383);   // stalling after 2 clk cycles

    #CLK_PERIOD;
    pc_check(72);              // add x4, x0, x7
    instr_check('h00700233);   

    #CLK_PERIOD;
    pc_check(76);              // beq x0, x0, 16
    instr_check('h00000863);   // pcsrc =1 after 2 cycles 
    stall_check(1);

    #CLK_PERIOD;
    pc_check(76);   
    #CLK_PERIOD;           // addi x17, x17, 124
    instr_check('h07c88893);

    #CLK_PERIOD;
    pc_check(84);              // addi x18, x18, 125
    instr_check('h07d90913);
    pcsrc_check (1);

    #CLK_PERIOD;
    pc_check(92);              // addi x20, x20, 10
    instr_check('h00aa0a13);

    #CLK_PERIOD;
    pc_check(96);              // jal x5, 8
    instr_check('h008002ef);   // pcsrc =1 after 2 cycles


    #CLK_PERIOD;
    pc_check(100);             // nop
    instr_check('h00000013);

    #CLK_PERIOD;
    pc_check(104);             // nop
    instr_check('h00000013);   // pcsrc =1
    pcsrc_check(1);

    #CLK_PERIOD;
    pc_check(104);             // nop (Jumped in) 
    instr_check('h00000013);

    #CLK_PERIOD;              
    pc_check(108);             // jalr x11, x0, 0x78
    instr_check('h078005e7);   // pcsrc =1 after 2 cycles

    #CLK_PERIOD;
    pc_check(112);             // addi x1, x2, 124
    instr_check('h07c10093);

    #CLK_PERIOD;
    pc_check(116);             // addi x1, x2, 125
    instr_check('h07d10093);
    pcsrc_check (1);

    #CLK_PERIOD;
    pc_check(120);             // addi x1, x2, 127
    instr_check('h07f10093);

    #CLK_PERIOD;
    pc_check(124);             // addi x1, x0, 10
    instr_check('h00a00093);

      
  end
  /** Reseting Block **/
  initial begin : proc_reseting
    rst = 1'b1;
    #CLK_PERIOD;
    rst = 1'b0;
  end

  /** Clock Generation Block **/
  initial begin : proc_clock
    clk = 1'b0;
    forever begin
      #HALF_PERIOD clk = ~clk;
    end
  end

/******************** Tasks & Functions *******************/

task CheckEquality(string signal_name, logic [63:0] A, logic [63:0] B);
    if (A !== B)
      begin
      $display("%s Failure", signal_name);
      end
endtask

task pc_check ;
  input [63:0] expected_pc;
    if(pc != expected_pc)
      $display("[%0t] %d pc failed",$time,expected_pc);
  endtask
  
task instr_check ;
  input [31:0] expected_instr;
    if(expected_instr != instr)
      $display("[%0t] instr failed",$time);
  endtask
  
task stall_check ;
input  expected_stall;
  if(expected_stall != stall_pc)
    $display("[%0t] stall failed",$time);
endtask

task pcsrc_check ;
input  expected_pcsrc;
  if(expected_pcsrc != pcsrc)
    $display("[%0t] pcsrc failed",$time);
endtask

task pcplus4_check ;
input [63:0] expected_pcplus4;
  if(pcplus4 != expected_pcplus4)
    $display("[%0t] pcplus4 failed",$time);
endtask

task nextpc_check ;
input [63:0] expected_nextpc;
  if(nextpc != expected_nextpc)
    $display("[%0t] nextpc failed",$time);
endtask

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

task rs1addr_check;
  input [4:0] expect_addr;
    begin
      if(rs1addr!= expect_addr) $display("[%2d] rs1 addr failed",i);
    end
endtask

task rs2addr_check;
    input [4:0] expect_addr;
    begin
      if(rs2addr!= expect_addr) $display("[%2d] rs2 addr failed",i);
    end
endtask

task rdaddr_check;
    input [4:0] expect_addr;
    begin
      if(rdaddr!= expect_addr) $display("[%2d] rd addr failed",i);
    end
endtask

task rs1data_check;
    input [63:0] expect_data;
    begin
      if(rs1data!= expect_data) $display("[%2d] rs1 data failed",i);
    end
endtask

task rs2data_check;
    input [63:0] expect_data;
    begin
      if(rs2data!= expect_data) $display("[%2d] rs2 data failed",i);
    end
endtask

task imm_check;
    input [63:0] expect_imm;
    begin
      if(imm!= expect_imm) $display("[%2d] imm failed",i);
    end
endtask

task execute_stage_check ;
  input [63:0] in1 ;
  input [63:0] in2 ;
  input [63:0] expected_result ;

  begin
    if ((op1 != in1)||(op2 != in2)||(result != expected_result))
      $display("[%2d] test failed. Expected: 0x%2h, Actual: 0x%2h", k, expected_result, result);
   //else 
      //$display("[%2d] test passed. Expected: 0x%2h, Actual: 0x%2h", k, expected_result, result);
    end 
  endtask



/******************** DUT Instantiation *******************/

  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );
endmodule