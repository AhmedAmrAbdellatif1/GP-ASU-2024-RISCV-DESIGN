/**********************************************************/
/* Module Name: riscv branch                              */
/* Last Modified Date:  12/22/2023                        */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns

module riscv_branch_tb()

/*********************** Parameters ***********************/
  parameter DELAY = 50;

/************************ Enumerate ***********************/
  typedef enum logic [2:0] {BEQ, BNE, BLT, BGE, BLTU, BGEU} types;

/************** Internal Signals Declaration **************/
  logic         taken;
  logic [3:0]   bcond;
  logic [63:0]  rs1, rs2;

/********************* Initial Blocks *********************/
  initial begin : proc_testing
    
  end

/******************** Tasks & Functions *******************/
  task beq_test();
    begin
    end
  endtask


/******************** DUT Instantiation *******************/

  riscv_branch DUT
  (
    .i_riscv_branch_cond(bcond),
    .i_riscv_branch_rs1data(rs1),
    .i_riscv_branch_rs2data(rs2),
    .o_riscv_branch_taken(taken)
  );
endmodule
