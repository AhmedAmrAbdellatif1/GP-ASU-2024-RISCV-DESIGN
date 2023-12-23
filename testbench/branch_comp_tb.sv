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
     bcond[3] = 1'b1;
     
     // (1) Branch if equal test
     bcond[2:0] = BEQ;
      // (1.1) rs1 > rs2
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      #DELAY;
      if(branch != 1'b0) $display("[BEQ]  Testcase (1): Failed");
      else               $display("[BEQ]  Testcase (1): Passed");
      // (1.2) rs1 = rs2
      rs1 = 'sd2044;
      rs2 = 'sd2044;
      #DELAY;
      if(branch != 1'b1) $display("[BEQ]  Testcase (2): Failed");
      else               $display("[BEQ]  Testcase (2): Passed");
      // (1.3) rs1 = -rs2
      rs1 = 'sd1505;
      rs2 =-'sd1505;
      #DELAY;
      if(branch != 1'b0) $display("[BEQ]  Testcase (3): Failed");
      else               $display("[BEQ]  Testcase (3): Passed");


      // (2) Branch if not equal test
     bcond[2:0] = BNE;
      // (2.1) rs1 > rs2
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      #DELAY;
      if(branch != 1'b1) $display("[BNE]  Testcase (1): Failed");
      else               $display("[BNE]  Testcase (1): Passed");
      // (2.2) rs1 = rs2
      rs1 = 'sd2044;
      rs2 = 'sd2044;
      #DELAY;
      if(branch != 1'b0) $display("[BNE]  Testcase (2): Failed");
      else               $display("[BNE]  Testcase (2): Passed");
      // (2.3) rs1 = -rs2
      rs1 = 'sd1505;
      rs2 =-'sd1505;
      #DELAY;
      if(branch != 1'b1) $display("[BNE]  Testcase (3): Failed");
      else               $display("[BNE]  Testcase (3): Passed");


      // (3) Branch if less than test
     bcond[2:0] = BLT;
      // (3.1) two possitive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      #DELAY;
      if(branch != 1'b0) $display("[BLT]  Testcase (1): Failed");
      else               $display("[BLT]  Testcase (1): Passed");
      // (3.2) two possitive negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      #DELAY;
      if(branch != 1'b1) $display("[BLT]  Testcase (2): Failed");
      else               $display("[BLT]  Testcase (2): Passed");
      // (3.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      #DELAY;
      if(branch != 1'b0) $display("[BLT]  Testcase (3): Failed");
      else               $display("[BLT]  Testcase (3): Passed");
      // (3.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      #DELAY;
      if(branch != 1'b1) $display("[BLT]  Testcase (4): Failed");
      else               $display("[BLT]  Testcase (4): Passed");
      // (3.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      #DELAY;
      if(branch != 1'b0) $display("[BLT]  Testcase (5): Failed");
      else               $display("[BLT]  Testcase (5): Passed");
      // (3.6) not equal numbers
      rs1 = 'sd12457;
      rs2 =-'sd12457;
      #DELAY;
      if(branch != 1'b0) $display("[BLT]  Testcase (6): Failed");
      else               $display("[BLT]  Testcase (6): Passed");


      // (4) Branch if greater than or equal test
     bcond[2:0] = BLT;
      // (4.1) two possitive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      #DELAY;
      if(branch != 1'b1) $display("[BGE]  Testcase (1): Failed");
      else               $display("[BGE]  Testcase (1): Passed");
      // (4.2) two possitive negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      #DELAY;
      if(branch != 1'b0) $display("[BGE]  Testcase (2): Failed");
      else               $display("[BGE]  Testcase (2): Passed");
      // (4.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      #DELAY;
      if(branch != 1'b1) $display("[BGE]  Testcase (3): Failed");
      else               $display("[BGE]  Testcase (3): Passed");
      // (4.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      #DELAY;
      if(branch != 1'b0) $display("[BGE]  Testcase (4): Failed");
      else               $display("[BGE]  Testcase (4): Passed");
      // (4.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      #DELAY;
      if(branch != 1'b1) $display("[BGE]  Testcase (5): Failed");
      else               $display("[BGE]  Testcase (5): Passed");
      // (4.6) not equal numbers
      rs1 =-'sd12457;
      rs2 = 'sd12457;
      #DELAY;
      if(branch != 1'b0) $display("[BGE]  Testcase (6): Failed");
      else               $display("[BGE]  Testcase (6): Passed");


      // (5) Branch if less than unsigned test
     bcond[2:0] = BLTU;
      // (5.1) two possitive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      #DELAY;
      if(branch != 1'b0) $display("[BLTU] Testcase (1): Failed");
      else               $display("[BLTU] Testcase (1): Passed");
      // (5.2) two possitive negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      #DELAY;
      if(branch != 1'b0) $display("[BLTU] Testcase (2): Failed");
      else               $display("[BLTU] Testcase (2): Passed");
      // (5.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      #DELAY;
      if(branch != 1'b1) $display("[BLTU] Testcase (3): Failed");
      else               $display("[BLTU] Testcase (3): Passed");
      // (5.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      #DELAY;
      if(branch != 1'b0) $display("[BLTU] Testcase (4): Failed");
      else               $display("[BLTU] Testcase (4): Passed");
      // (5.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      #DELAY;
      if(branch != 1'b0) $display("[BLTU] Testcase (5): Failed");
      else               $display("[BLTU] Testcase (5): Passed");
      // (5.6) not equal numbers
      rs1 = 'sd12457;
      rs2 =-'sd12457;
      #DELAY;
      if(branch != 1'b1) $display("[BLTU] Testcase (6): Failed");
      else               $display("[BLTU] Testcase (6): Passed");


      // (6) Branch if greater than or equal test
     bcond[2:0] = BGEU;
      // (6.1) two possitive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      #DELAY;
      if(branch != 1'b1) $display("[BGEU] Testcase (1): Failed");
      else               $display("[BGEU] Testcase (1): Passed");
      // (6.2) two possitive negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      #DELAY;
      if(branch != 1'b1) $display("[BGEU] Testcase (2): Failed");
      else               $display("[BGEU] Testcase (2): Passed");
      // (6.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      #DELAY;
      if(branch != 1'b0) $display("[BGEU] Testcase (3): Failed");
      else               $display("[BGEU] Testcase (3): Passed");
      // (6.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      #DELAY;
      if(branch != 1'b1) $display("[BGEU] Testcase (4): Failed");
      else               $display("[BGEU] Testcase (4): Passed");
      // (6.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      #DELAY;
      if(branch != 1'b1) $display("[BGEU] Testcase (5): Failed");
      else               $display("[BGEU] Testcase (5): Passed");
      // (6.6) not equal numbers
      rs1 = 'sd12457;
      rs2 =-'sd12457;
      #DELAY;
      if(branch != 1'b0) $display("[BGEU] Testcase (6): Failed");
      else               $display("[BGEU] Testcase (6): Passed");
      
  end

/******************** Tasks & Functions *******************/


/******************** DUT Instantiation *******************/

  riscv_branch DUT
  (
    .i_riscv_branch_cond(bcond),
    .i_riscv_branch_rs1data(rs1),
    .i_riscv_branch_rs2data(rs2),
    .o_riscv_branch_taken(taken)
  );
endmodule
