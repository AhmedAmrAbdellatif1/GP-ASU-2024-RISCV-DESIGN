/**********************************************************/
/* Module Name:                                           */
/* Last Modified Date:                                    */
/* By:  Abderlrahman                                      */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_de_ppreg_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;
  parameter Long_Delay = 500;

/************** Internal Signals Declaration **************/
  logic clk;
  // Inputs (D)
  logic  [63:0]  PC_D;
  logic  [4:0]   Rs1Addr_D;
  logic  [63:0]  Rs1Data_D;
  logic  [63:0]  Rs2Data_D;
  logic  [4:0]   Rs2Addr_D;
  logic  [4:0]   RdAddr_D;
  logic  [63:0]  Extendedimm_D;
  logic  [2:0]   B_condition_D;
  logic          Oprnd2sel_D;
  logic  [1:0]   StoreSrc_D;
  logic  [4:0]   ALUControl_D;
  logic          Oprnd1sel_D;
  logic          MemWrite_D;
  logic  [2:0]   MemExt_D;
  logic  [1:0]   ResultSrc_D;
  logic          RegWrite_D;
  logic  [63:0]  pcplus4_D;
  logic          Flush;
  logic          Jump_D;
  // Outputs (E)
  logic  [63:0] PC_E;
  logic  [63:0] pcplus4_E;
  logic  [4:0]  Rs1Addr_E;
  logic  [63:0] Rs1Data_E;
  logic  [63:0] Rs2Data_E;
  logic  [4:0]  Rs2Addr_E;
  logic  [4:0]  RdAddr_E;
  logic  [63:0] Extendedimm_E;
  logic  [2:0]  B_condition_E;
  logic         Oprnd2sel_E;
  logic  [1:0]  StoreSrc_E;
  logic  [4:0]  ALUControl_E;
  logic         Oprnd1sel_E;
  logic         MemWrite_E;
  logic  [2:0]  MemExt_E;
  logic  [1:0]  ResultSrc_E;
  logic         RegWrite_E;
  logic          Jump_E;
/********************* Initial Blocks *********************/
  initial begin : proc_testing
    
    PC_D = 64'h123456789ABCDEF0;
    Rs1Addr_D = 5'b101;
    Rs1Data_D = 64'h1111222233334444;
    Rs2Data_D = 64'h5555666677778888;
    Rs2Addr_D = 5'b1111;
    RdAddr_D = 32'h11223344;
    Extendedimm_D = 64'hAAAAAAAABBBBBBBB;
    B_condition_D = 3'b001;
    Oprnd2sel_D = 1'b1;
    StoreSrc_D = 2'b01;
    ALUControl_D = 5'b00100;
    Oprnd1sel_D = 1'b1;
    MemWrite_D = 1'b1;
    MemExt_D = 3'b010;
    ResultSrc_D = 2'b10;
    RegWrite_D = 1'b1;
    Flush = 1'b0;
    pcplus4_D= 64'h123456789ABCDEF4;
    Jump_D = 1'b1;
  #CLK_PERIOD
 
  check_outputs();
  Flush = 1'b1;
     
  # CLK_PERIOD
  
  check_output_flushed();
   
  #Long_Delay  
  check_output_flushed();  // check that they are still zero
  Flush = 1'b0;
  
  # CLK_PERIOD
  check_outputs();
 #Long_Delay
   check_outputs(); 
  end
  
  
  /** Clock Generation Block **/
  initial begin : proc_clock
    clk = 1'b0;
    forever begin
      #HALF_PERIOD clk = ~clk;
    end
  end

/******************** Tasks & Functions *******************/
task check_outputs();
    CheckEquality("PC", PC_D, PC_E);
    CheckEquality("Rs1Addr", Rs1Addr_D, Rs1Addr_E);
    CheckEquality("Rs1Data", Rs1Data_D, Rs1Data_E);
    CheckEquality("Rs2Data", Rs2Data_D, Rs2Data_E);
    CheckEquality("Rs2Addr", Rs2Addr_D, Rs2Addr_E);
    CheckEquality("RdAddr", RdAddr_D, RdAddr_E);
    CheckEquality("Extendedimm", Extendedimm_D, Extendedimm_E);
    CheckEquality("B_condition", B_condition_D, B_condition_E);
    CheckEquality("Oprnd2se", Oprnd2sel_D, Oprnd2sel_E);
    CheckEquality("StoreSrc", StoreSrc_D, StoreSrc_E);
    CheckEquality("ALUControl", ALUControl_D, ALUControl_E);
    CheckEquality("Oprnd1sel", Oprnd1sel_D, Oprnd1sel_E);
    CheckEquality("MemWrite", MemWrite_D, MemWrite_E);
    CheckEquality("MemExt", MemExt_D, MemExt_E);
    CheckEquality("ResultSrc", ResultSrc_D, ResultSrc_E);
    CheckEquality("RegWrite", RegWrite_D, RegWrite_E);
    CheckEquality("PCplus4", pcplus4_D, pcplus4_E);
    CheckEquality("Jump", Jump_D, Jump_E);
  endtask
  
  
task check_output_flushed();
CheckEquality("PC", 0, PC_E);
    CheckEquality("Rs1Addr", 0, Rs1Addr_E);
    CheckEquality("Rs1Data", 0, Rs1Data_E);
    CheckEquality("Rs2Data", 0, Rs2Data_E);
    CheckEquality("Rs2Addr", 0, Rs2Addr_E);
    CheckEquality("RdAddr", 0, RdAddr_E);
    CheckEquality("Extendedimm", 0, Extendedimm_E);
    CheckEquality("B_condition", 0, B_condition_E);
    CheckEquality("Oprnd2se", 0, Oprnd2sel_E);
    CheckEquality("StoreSrc", 0, StoreSrc_E);
    CheckEquality("ALUControl", 0, ALUControl_E);
    CheckEquality("Oprnd1sel", 0, Oprnd1sel_E);
    CheckEquality("MemWrite", 0, MemWrite_E);
    CheckEquality("MemExt", 0, MemExt_E);
    CheckEquality("ResultSrc", 0, ResultSrc_E);
    CheckEquality("RegWrite", 0, RegWrite_E);
    CheckEquality("PCplus4", 0, pcplus4_E);
    CheckEquality("Jump", 0, Jump_E);
  endtask 
    
task CheckEquality(string signal_name, logic [63:0]signal_D, logic [63:0]signal_E);
    if (signal_D === signal_E)
      $display("%s Success", signal_name);
    else
      $display("%s Failure", signal_name);
endtask



/******************** DUT Instantiation *******************/

    riscv_de_ppreg DUT
  (
    .i_riscv_de_pc_d(PC_D),
    .i_riscv_de_rs1addr_d(Rs1Addr_D),
    .i_riscv_de_rs1data_d(Rs1Data_D),
    .i_riscv_de_rs2data_d(Rs2Data_D),
    .i_riscv_de_rs2addr_d(Rs2Addr_D),
    .i_riscv_de_rdaddr_d(RdAddr_D),
    .i_riscv_de_extendedimm_d(Extendedimm_D),
    .i_riscv_de_b_condition_d(B_condition_D),
    .i_riscv_de_oprnd2sel_d(Oprnd2sel_D),
    .i_riscv_de_storesrc_d(StoreSrc_D),
    .i_riscv_de_alucontrol_d(ALUControl_D),
    .i_riscv_de_oprnd1sel_d(Oprnd1sel_D),
    .i_riscv_de_memwrite_d(MemWrite_D),
    .i_riscv_de_memext_d(MemExt_D),
    .i_riscv_de_resultsrc_d(ResultSrc_D),
    .i_riscv_de_regwrite_d(RegWrite_D),
    .i_riscv_de_rst(Flush),
    .i_riscv_de_pcplus4_d(pcplus4_D),
    .i_riscv_de_clk(clk),
    .i_riscv_de_jump_d(Jump_D),

    .o_riscv_de_pc_e(PC_E),
    .o_riscv_de_rs1addr_e(Rs1Addr_E),
    .o_riscv_de_rs1data_e(Rs1Data_E),
    .o_riscv_de_rs2data_e(Rs2Data_E),
    .o_riscv_de_rs2addr_e(Rs2Addr_E),
    .o_riscv_de_rdaddr_e(RdAddr_E),
    .o_riscv_de_extendedimm_e(Extendedimm_E),
    .o_riscv_de_b_condition_e(B_condition_E),
    .o_riscv_de_oprnd2sel_e(Oprnd2sel_E),
    .o_riscv_de_storesrc_e(StoreSrc_E),
    .o_riscv_de_alucontrol_e(ALUControl_E),
    .o_riscv_de_oprnd1sel_e(Oprnd1sel_E),
    .o_riscv_de_memwrite_e(MemWrite_E),
    .o_riscv_de_memext_e(MemExt_E),
    .o_riscv_de_resultsrc_e(ResultSrc_E),
    .o_riscv_de_regwrite_e(RegWrite_E),
    .o_riscv_de_jump_e(Jump_E),
    .o_riscv_de_pcplus4_e(pcplus4_E)
  );
endmodule



