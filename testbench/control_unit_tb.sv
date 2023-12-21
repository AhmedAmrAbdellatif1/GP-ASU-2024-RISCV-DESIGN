/**********************************************************/
/* Module Name: riscv_cu                                  */
/* Last Modified Date: 12/22/2023                         */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_cu_tb();
/*********************** Parameters ***********************/

/************** Internal Signals Declaration **************/
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic       funct7_5;
  logic [2:0] immsrc;
  logic       regw;
  logic       asel;
  logic       bsel;
  logic [4:0] aluctrl;
  logic [1:0] storesrc;
  logic [2:0] bcond;
  logic       memw;
  logic [2:0] memext;
  logic [1:0] resultsrc;
  logic       jump;

  logic [31:0] testcases [0:48];

/********************* Initial Blocks *********************/
  initial begin : proc_testing
    $readmemh("cu_testcases.txt", testcases);
  end
  
/******************** Tasks & Functions *******************/



/******************** DUT Instantiation *******************/

  riscv_cu DUT
  (
    .i_riscv_cu_opcode(opcode),
    .i_riscv_cu_funct3(funct3),
    .i_riscv_cu_funct7_5(funct7_5),
    .o_riscv_cu_immsrc(immsrc),
    .o_riscv_cu_regw(regw),
    .o_riscv_cu_asel(asel),
    .o_riscv_cu_bsel(bsel),
    .o_riscv_cu_aluctrl(aluctrl),
    .o_riscv_cu_storesrc(storesrc),
    .o_riscv_cu_bcond(bcond),
    .o_riscv_cu_memw(memw),
    .o_riscv_cu_memext(memext),
    .o_riscv_cu_resultsrc(resultsrc),
    .o_riscv_cu_jump(jump)
  );
endmodule