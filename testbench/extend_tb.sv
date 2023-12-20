/**********************************************************/
/* Module Name: riscv_extend                              */
/* Last Modified Date:                                    */
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
  parameter TEST_CASES  = 5;

/*********************** Enumerate ************************/
  typedef enum logic [2:0] {i_imm = 3'b000,
                            u_imm = 3'b001,
                            j_imm = 3'b010,
                            s_imm = 3'b011,
                            b_imm = 3'b100} imm_type;
  

/************** Internal Signals Declaration **************/
  logic [CTRL_WIDTH-1:0]  immsrc;
  logic [SIMM_WIDTH-1:0]  simm;
  logic [IN_WIDTH-1:0]    inst;

  logic [INST_WIDTH-1:0]  i_type_inst [TEST_CASES-1:0],
                          u_type_inst [TEST_CASES-1:0],
                          j_type_inst [TEST_CASES-1:0],
                          s_type_inst [TEST_CASES-1:0],
                          b_type_inst [TEST_CASES-1:0];

/********************* Initial Blocks *********************/
  initial begin : proc_testing
    #DELAY
    test_itype(i_type_inst[0],'sd0);
    #DELAY
    test_itype(i_type_inst[1],'sd15);
    #DELAY
    test_itype(i_type_inst[2],-'sd684);
    #DELAY
    test_itype(i_type_inst[3],'sd2047);
    #DELAY
    test_itype(i_type_inst[4],-'sd2048);
    #DELAY $stop;
  end

  initial begin : proc_decoding
    // (1) I-type Instructions
    i_type_inst[0] = 'h0004f413;  // andi s0, s1, 0
    i_type_inst[1] = 'h00f98913;  // addi s2, s3, 15
    i_type_inst[2] = 'hd54aca13;  // xori x20 x21 -684
    i_type_inst[3] = 'h7ffbea13;  // ori x20 x23 2047
    i_type_inst[4] = 'h800cac13;  // slti x24 x25 -2048
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


/******************** DUT Instantiation *******************/

  riscv_extend DUT
  (
    .i_riscv_extend_immsrc(immsrc),
    .i_riscv_extend_inst(inst),
    .o_riscv_extend_simm(simm)
  );
endmodule
