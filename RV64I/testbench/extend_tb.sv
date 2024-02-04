/**********************************************************/
/* Module Name: riscv_extend                              */
/* Last Modified Date: 12/21/2023                         */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns

module riscv_extend_tb();

/*********************** Parameters ***********************/
  parameter DELAY       = 50;
  parameter IN_WIDTH    = 25;
  parameter INST_WIDTH  = 32;
  parameter SIMM_WIDTH  = 64;
  parameter CTRL_WIDTH  = 3;

/************** Internal Signals Declaration **************/
  logic [CTRL_WIDTH-1:0]  immsrc;
  logic [SIMM_WIDTH-1:0]  simm;
  logic [IN_WIDTH-1:0]    inst;

  logic [INST_WIDTH-1:0]  i_type_inst [4:0],
                          u_type_inst [1:0],
                          j_type_inst      ,
                          s_type_inst [3:0],
                          b_type_inst [5:0];

/********************* Initial Blocks *********************/
  initial begin : proc_testing
    #DELAY
    // (1) I-type Instructions test
    test_itype(i_type_inst[0],'sd0);
    #DELAY
    test_itype(i_type_inst[1],'sd15);
    #DELAY
    test_itype(i_type_inst[2],-'sd684);
    #DELAY
    test_itype(i_type_inst[3],'sd2047);
    #DELAY
    test_itype(i_type_inst[4],-'sd2048);
    #DELAY

    // (2) U-type Instructions test
    test_utype(u_type_inst[0],'sd4098883584);
    #DELAY
    test_utype(u_type_inst[1],'sd465027072);
    #DELAY

    // (3) J-type Instructions test
    test_jtype(j_type_inst,'sd330144);
    #DELAY

    // (4) S-type Instructions test
    test_stype(s_type_inst[0],'sd7);
    #DELAY
    test_stype(s_type_inst[1],-'sd20);
    #DELAY
    test_stype(s_type_inst[2],'sd44);
    #DELAY
    test_stype(s_type_inst[3],-'sd808);
    #DELAY

    // (5) B-type Instructions test
    test_btype(b_type_inst[0],'sd20);
    #DELAY
    test_btype(b_type_inst[1],-'sd356);
    #DELAY
    test_btype(b_type_inst[2],'sd1242);
    #DELAY
    test_btype(b_type_inst[3],-'sd1246);
    #DELAY
    test_btype(b_type_inst[4],'sd420);
    #DELAY
    test_btype(b_type_inst[5],-'sd422);

    #DELAY $stop;
  end

  initial begin : proc_decoding
    // (1) I-type Instructions
    i_type_inst[0] = 'h0004f413;  // andi s0, s1, 0
    i_type_inst[1] = 'h00f98913;  // addi s2, s3, 15
    i_type_inst[2] = 'hd54aca13;  // xori x20 x21 -684
    i_type_inst[3] = 'h7ffbea13;  // ori  x20 x23 2047
    i_type_inst[4] = 'h800cac13;  // slti x24 x25 -2048

    // (2) U-type Instructions
    u_type_inst[0] = 'hf4500437;  // lui   s0,  1000704
    u_type_inst[1] = 'h1bb7cd17;  // auipc s10, 113532

    // (3) U-type Instructions
    j_type_inst    = 'h1a150bef;  // jal s7, 330144

    // (4) U-type Instructions
    s_type_inst[0] = 'h008483a3;  // sb s0, 7(s1)
    s_type_inst[1] = 'hff299623;  // sh s2, -20(s3)
    s_type_inst[2] = 'h034aa623;  // sw s4, 44(s5)
    s_type_inst[3] = 'hcd6bbc23;  // sd s6, -808(s7)

    // (5) B-type Instructions
    b_type_inst[0] = 'h00940a63;  // beq  s0, s1,  20
    b_type_inst[1] = 'he9391ee3;  // bne  s2, s3, -356
    b_type_inst[2] = 'h4d495d63;  // bge  s2, s4,  1242
    b_type_inst[3] = 'hb37af1e3;  // bgeu s5, s7, -1246
    b_type_inst[4] = 'h1b4c4263;  // blt  s8, s4,  420
    b_type_inst[5] = 'he54c6de3;  // bltu s8, s4, -422

  end

/******************** Tasks & Functions *******************/
  task test_itype;
    input logic [INST_WIDTH-1:0] instruction;
    input logic [SIMM_WIDTH-1:0] immediate;
    begin
      immsrc = 3'b000;
      inst = instruction[31:7];
      #DELAY
      if(simm != immediate) begin
        $display("(%16h): TESTING-Itype FAILED",immediate);
      end else begin
        $display("(%16h): TESTING-Itype PASSED",immediate);
      end
    end
  endtask

  task test_utype;
    input logic [INST_WIDTH-1:0] instruction;
    input logic [SIMM_WIDTH-1:0] immediate;
    begin
      immsrc = 3'b001;
      inst = instruction[31:7];
      #DELAY
      if(simm != immediate) begin
        $display("(%16h): TESTING-Utype FAILED",immediate);
      end else begin
        $display("(%16h): TESTING-Utype PASSED",immediate);
      end
    end
  endtask

  task test_jtype;
    input logic [INST_WIDTH-1:0] instruction;
    input logic [SIMM_WIDTH-1:0] immediate;
    begin
      immsrc = 3'b010;
      inst = instruction[31:7];
      #DELAY
      if(simm != immediate) begin
        $display("(%16h): TESTING-Jtype FAILED",immediate);
      end else begin
        $display("(%16h): TESTING-Jtype PASSED",immediate);
      end
    end
  endtask

  task test_stype;
    input logic [INST_WIDTH-1:0] instruction;
    input logic [SIMM_WIDTH-1:0] immediate;
    begin
      immsrc = 3'b011;
      inst = instruction[31:7];
      #DELAY
      if(simm != immediate) begin
        $display("(%16h): TESTING-Stype FAILED",immediate);
      end else begin
        $display("(%16h): TESTING-Stype PASSED",immediate);
      end
    end
  endtask

  task test_btype;
    input logic [INST_WIDTH-1:0] instruction;
    input logic [SIMM_WIDTH-1:0] immediate;
    begin
      immsrc = 3'b100;
      inst = instruction[31:7];
      #DELAY
      if(simm != immediate) begin
        $display("(%16h): TESTING-Btype FAILED",immediate);
      end else begin
        $display("(%16h): TESTING-Btype PASSED",immediate);
      end
    end
  endtask


/******************** DUT Instantiation *******************/

  riscv_extend DUT
  (
    .i_riscv_extend_immsrc(immsrc),
    .i_riscv_extend_inst(inst),
    .o_riscv_extend_simm(simm)
  );
endmodule
