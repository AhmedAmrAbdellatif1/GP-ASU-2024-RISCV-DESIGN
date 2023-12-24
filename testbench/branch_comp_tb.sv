/**********************************************************/
/* Module Name: riscv taken                              */
/* Last Modified Date:  12/22/2023                        */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns

module riscv_branch_tb();

/*********************** Parameters ***********************/
  parameter DELAY = 50;
  integer i;

/************************ Enumerate ***********************/
  typedef enum logic [2:0] {BEQ = 3'b000, BNE = 3'b001, BLT = 3'b100,
                            BGE = 3'b101, BLTU = 3'b110, BGEU = 3'b111} types;

/************** Internal Signals Declaration **************/
  logic         taken;
  logic [3:0]   bcond;
  logic [63:0]  rs1, rs2;

/********************* Initial Blocks *********************/
  initial begin : proc_testing
     bcond[3] = 1'b1;
     i = 0;
     // (1) Branch if equal test
     bcond[2:0] = BEQ;
      // (1.1) rs1 > rs2
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BEQ]  Testcase (1): Failed",i);
      else               $display("%2d-[BEQ]  Testcase (1): Passed",i);
      // (1.2) rs1 = rs2
      rs1 = 'sd2044;
      rs2 = 'sd2044;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BEQ]  Testcase (2): Failed",i);
      else               $display("%2d-[BEQ]  Testcase (2): Passed",i);
      // (1.3) rs1 = -rs2
      rs1 = 'sd1505;
      rs2 =-'sd1505;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BEQ]  Testcase (3): Failed",i);
      else               $display("%2d-[BEQ]  Testcase (3): Passed",i);


      // (2) Branch if not equal test
     bcond[2:0] = BNE;
      // (2.1) rs1 > rs2
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BNE]  Testcase (1): Failed",i);
      else               $display("%2d-[BNE]  Testcase (1): Passed",i);
      // (2.2) rs1 = rs2
      rs1 = 'sd2044;
      rs2 = 'sd2044;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BNE]  Testcase (2): Failed",i);
      else               $display("%2d-[BNE]  Testcase (2): Passed",i);
      // (2.3) rs1 = -rs2
      rs1 = 'sd1505;
      rs2 =-'sd1505;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BNE]  Testcase (3): Failed",i);
      else               $display("%2d-[BNE]  Testcase (3): Passed",i);


      // (3) Branch if less than test
     bcond[2:0] = BLT;
      // (3.1) two positive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLT]  Testcase (1): Failed",i);
      else               $display("%2d-[BLT]  Testcase (1): Passed",i);
      // (3.2) two negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BLT]  Testcase (2): Failed",i);
      else               $display("%2d-[BLT]  Testcase (2): Passed",i);
      // (3.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLT]  Testcase (3): Failed",i);
      else               $display("%2d-[BLT]  Testcase (3): Passed",i);
      // (3.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BLT]  Testcase (4): Failed",i);
      else               $display("%2d-[BLT]  Testcase (4): Passed",i);
      // (3.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLT]  Testcase (5): Failed",i);
      else               $display("%2d-[BLT]  Testcase (5): Passed",i);
      // (3.6) not equal numbers
      rs1 = 'sd12457;
      rs2 =-'sd12457;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLT]  Testcase (6): Failed",i);
      else               $display("%2d-[BLT]  Testcase (6): Passed",i);


      // (4) Branch if greater than or equal test
     bcond[2:0] = BGE;
      // (4.1) two positive numbers
      rs1 = 'sd306;
      rs2 = 'sd296;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BGE]  Testcase (1): Failed",i);
      else               $display("%2d-[BGE]  Testcase (1): Passed",i);
      // (4.2) two negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BGE]  Testcase (2): Failed",i);
      else               $display("%2d-[BGE]  Testcase (2): Passed",i);
      // (4.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BGE]  Testcase (3): Failed",i);
      else               $display("%2d-[BGE]  Testcase (3): Passed",i);
      // (4.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BGE]  Testcase (4): Failed",i);
      else               $display("%2d-[BGE]  Testcase (4): Passed",i);
      // (4.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BGE]  Testcase (5): Failed",i);
      else               $display("%2d-[BGE]  Testcase (5): Passed",i);
      // (4.6) not equal numbers
      rs1 =-'sd12457;
      rs2 = 'sd12457;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BGE]  Testcase (6): Failed",i);
      else               $display("%2d-[BGE]  Testcase (6): Passed",i);


      // (5) Branch if less than unsigned test
     bcond[2:0] = BLTU;
      // (5.1) two positive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLTU] Testcase (1): Failed",i);
      else               $display("%2d-[BLTU] Testcase (1): Passed",i);
      // (5.2) two negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BLTU] Testcase (2): Failed",i);
      else               $display("%2d-[BLTU] Testcase (2): Passed",i);
      // (5.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BLTU] Testcase (3): Failed",i);
      else               $display("%2d-[BLTU] Testcase (3): Passed",i);
      // (5.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLTU] Testcase (4): Failed",i);
      else               $display("%2d-[BLTU] Testcase (4): Passed",i);
      // (5.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BLTU] Testcase (5): Failed",i);
      else               $display("%2d-[BLTU] Testcase (5): Passed",i);
      // (5.6) not equal numbers
      rs1 = 'sd12457;
      rs2 =-'sd12457;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BLTU] Testcase (6): Failed",i);
      else               $display("%2d-[BLTU] Testcase (6): Passed",i);


      // (6) Branch if greater than or equal test
     bcond[2:0] = BGEU;
      // (6.1) two positive numbers
      rs1 = 'sd3060;
      rs2 = 'sd2965;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BGEU] Testcase (1): Failed",i);
      else               $display("%2d-[BGEU] Testcase (1): Passed",i);
      // (6.2) two negative numbers
      rs1 =-'sd3060;
      rs2 =-'sd2965;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BGEU] Testcase (2): Failed",i);
      else               $display("%2d-[BGEU] Testcase (2): Passed",i);
      // (6.3) one positive one negative
      rs1 = 'sd4124;
      rs2 =-'sd5688;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BGEU] Testcase (3): Failed",i);
      else               $display("%2d-[BGEU] Testcase (3): Passed",i);
      // (6.4) one negative one positive
      rs1 =-'sd4124;
      rs2 = 'sd5688;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BGEU] Testcase (4): Failed",i);
      else               $display("%2d-[BGEU] Testcase (4): Passed",i);
      // (6.5) two equal numbers
      rs1 = 'sd12457;
      rs2 = 'sd12457;
      i++; #DELAY;
      if(taken != 1'b1) $display("%2d-[BGEU] Testcase (5): Failed",i);
      else               $display("%2d-[BGEU] Testcase (5): Passed",i);
      // (6.6) not equal numbers
      rs1 = 'sd12457;
      rs2 =-'sd12457;
      i++; #DELAY;
      if(taken != 1'b0) $display("%2d-[BGEU] Testcase (6): Failed",i);
      else               $display("%2d-[BGEU] Testcase (6): Passed",i);
      
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
