/**********************************************************/
/* Module Name: riscv_im                                  */
/* Last Modified Date: 12/23/2023                         */
/* By: Ahmed Amr Abdellatif Mahmoud                       */
/**********************************************************/
`timescale 1ns/1ns

module riscv_im_tb();

/*********************** Parameters ***********************/
  parameter DELAY = 10;
  parameter FIRST_ADDR = 0;
  parameter LAST_ADDR  = 22;

  integer i;

/************** Internal Signals Declaration **************/
  logic [63:0]  pc;
  logic [31:0]  inst;

  logic [31:0]  test_inst [FIRST_ADDR:LAST_ADDR];

/********************* Initial Blocks *********************/
  initial begin : proc_testing
  $readmemh("riscvtest.txt",test_inst);
  pc = 'h0;
    for(i=0; i<=LAST_ADDR; i++) begin
      #DELAY
      if(inst == test_inst[i]) $display("Correct data at address 0x%2h",pc);
      else                     $display("Wrong data at address 0x%2h",pc);
      pc += 'h4;  
    end 
  end

/******************** DUT Instantiation *******************/
  riscv_im DUT
  (
    .i_riscv_im_pc(pc),
    .o_riscv_im_inst(inst)
  );
endmodule