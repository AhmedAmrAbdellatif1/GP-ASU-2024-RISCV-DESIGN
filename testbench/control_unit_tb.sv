/**********************************************************/
/* Module Name: riscv_cu                                  */
/* Last Modified Date: 12/22/2023                         */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_cu_tb();
/*********************** Parameters ***********************/
  parameter DELAY     = 10;
  parameter TESTCASES = 49;
  parameter INST_SIZE = 32;

  integer i;

/************** Internal Signals Declaration **************/
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic       funct7_5;
  logic       regw;
  logic       memw;
  logic       asel;
  logic       bsel;
  logic [2:0] immsrc;
  logic [4:0] aluctrl;
  logic [1:0] storesrc;
  logic [3:0] bcond;
  logic [2:0] memext;
  logic [1:0] resultsrc;
  logic       jump;

  logic [INST_SIZE-1:0] instruction [0:TESTCASES-1];

/********************* Initial Blocks *********************/
  initial begin : proc_testing
    $readmemh("cu_testcases.txt", instruction);
    
    for(i=0;i<TESTCASES;i++) begin
      opcode    = instruction[i][6:0];
      funct3    = instruction[i][14:12];
      funct7_5  = instruction[i][30];
      #DELAY
      if((opcode == 'd51) || (opcode == 'd59)) begin
        r_type_test();
        #DELAY;
      end
    end
  end
  
/******************** Tasks & Functions *******************/
task control_signals_test;
  input [2:0] immsrc_test;
  input       regw_test;
  input       asel_test;
  input       bsel_test;
  input [4:0] aluctrl_test;
  input [1:0] storesrc_test;
  input [2:0] bcond_test;
  input       memw_test;
  input [2:0] memext_test;
  input [1:0] resultsrc_test;
  input       jump_test;
  begin
    if( (immsrc     != immsrc_test)     ||
        (regw       != regw_test)       ||
        (asel       != asel_test)       ||
        (bsel       != bsel_test)       ||
        (aluctrl    != aluctrl_test)    ||
        (storesrc   != storesrc_test)   ||
        (bcond      != bcond_test)      ||
        (memw       != memw_test)       ||
        (memext     != memext_test)     ||
        (resultsrc  != resultsrc_test)  ||
        (jump       !=  jump_test)      
      ) begin
        $display("instruction(#%2d): There's an error",(i+1));
      end else begin
        $display("instruction(#%2d): Passed",(i+1));
      end
  end
endtask

task r_type_test();
  begin
      case(funct3)
      3'b000:  begin
            if((funct7_5 == 1'b0) && (opcode[3] == 1'b0)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00000) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end else if((funct7_5 == 1'b1) && (opcode[3] == 1'b0)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00001) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end else if((funct7_5 == 1'b0) && (opcode[3] == 1'b1)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b10000) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end else if((funct7_5 == 1'b1) && (opcode[3] == 1'b1)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b10001) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
            end
      end

      3'b001:  begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00010) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
      end

      3'b010:  begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00011) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
      end

      3'b011:  begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00100) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
      end

      3'b100:  begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00101) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
      end

      3'b101:  begin
            if((funct7_5 == 1'b0) && (opcode[3] == 1'b0)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00110) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end else if((funct7_5 == 1'b1) && (opcode[3] == 1'b0)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b00111) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end else if((funct7_5 == 1'b0) && (opcode[3] == 1'b1)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b10101) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end else if((funct7_5 == 1'b1) && (opcode[3] == 1'b1)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b10110) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
            end
      end

      3'b110:  begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b01000) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
      end

      3'b111:  begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b01001) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));
      end
    endcase
  end
endtask


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