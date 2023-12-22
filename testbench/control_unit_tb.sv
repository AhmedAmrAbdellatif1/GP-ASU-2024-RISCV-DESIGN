/**********************************************************/
/* Module Name: riscv_cu                                  */
/* Last Modified Date: 12/22/2023                         */
/* By: Ahmed Amr Abdellatif                               */
/**********************************************************/
`timescale 1ns/1ns

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
      case(opcode)
        'd51:   r_type_test();
        'd59:   r_type_test();
        'd19:   imm_type_test();
        'd27:   imm_type_test();
        'd03:   load_test();
        'd103:  jump_test();
        'd111:  jump_test();
        'd55:   lui_test();
        'd23:   auipc_test();
        'd35:   store_test();
        'd99:   branch_test();
      endcase
      #DELAY;
    end
  end
  
/******************** Tasks & Functions *******************/

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
            if((funct7_5 == 1'b0) && (opcode[3] == 1'b0)) begin
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

            end else if((funct7_5 == 1'b0) && (opcode[3] == 1'b1)) begin
              if( (regw == 1'b1) &&
                  (asel == 1'b1) &&
                  (bsel == 1'b0) &&
                  (aluctrl == 5'b10010) &&
                  (bcond == 4'b0000) &&
                  (memw == 1'b0) &&
                  (resultsrc == 2'b01) &&
                  (jump == 1'b0) )
                    $display("Instruction(#%2d): Passed",(i+1));
                  else
                    $display("Instruction(#%2d): Failed",(i+1));

            end
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
                  (aluctrl == 5'b10110) &&
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
                  (aluctrl == 5'b10111) &&
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

task imm_type_test();
  begin
    case(funct3)
    3'b000: begin
      if(opcode == 7'd19) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b00000) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end else if(opcode == 7'd27) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b10000) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end
    end
    3'b001: begin
      if((funct7_5 == 1'b0) && (opcode[3] == 1'b0)) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b00010) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end else if((funct7_5 == 1'b0) && (opcode[3] == 1'b1)) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b10010) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end      
    end
    3'b010: begin
      if( (immsrc == 3'b000) &&
          (regw == 1'b1) &&
          (asel == 1'b1) &&
          (bsel == 1'b1) &&
          (aluctrl == 5'b00011) &&
          (bcond == 4'b0000) &&
          (memw == 1'b0) &&
          (resultsrc == 2'b01) &&
          (jump == 1'b0) )
            $display("Instruction(#%2d): Passed",(i+1));
          else
            $display("Instruction(#%2d): Failed",(i+1));
    end
    3'b011: begin
      if( (immsrc == 3'b000) &&
          (regw == 1'b1) &&
          (asel == 1'b1) &&
          (bsel == 1'b1) &&
          (aluctrl == 5'b00100) &&
          (bcond == 4'b0000) &&
          (memw == 1'b0) &&
          (resultsrc == 2'b01) &&
          (jump == 1'b0) )
            $display("Instruction(#%2d): Passed",(i+1));
          else
            $display("Instruction(#%2d): Failed",(i+1));
    end
    3'b100: begin
      if( (immsrc == 3'b000) &&
          (regw == 1'b1) &&
          (asel == 1'b1) &&
          (bsel == 1'b1) &&
          (aluctrl == 5'b00101) &&
          (bcond == 4'b0000) &&
          (memw == 1'b0) &&
          (resultsrc == 2'b01) &&
          (jump == 1'b0) )
            $display("Instruction(#%2d): Passed",(i+1));
          else
            $display("Instruction(#%2d): Failed",(i+1));
    end
    3'b101: begin
      if((funct7_5 == 1'b0) && (opcode[3] == 1'b0)) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b00110) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end else if((funct7_5 == 1'b1) && (opcode[3] == 1'b0)) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b00111) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end else if((funct7_5 == 1'b0) && (opcode[3] == 1'b1)) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b10110) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end else if((funct7_5 == 1'b1) && (opcode[3] == 1'b1)) begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b10111) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end      
    end
    3'b110: begin
      if( (immsrc == 3'b000) &&
          (regw == 1'b1) &&
          (asel == 1'b1) &&
          (bsel == 1'b1) &&
          (aluctrl == 5'b01000) &&
          (bcond == 4'b0000) &&
          (memw == 1'b0) &&
          (resultsrc == 2'b01) &&
          (jump == 1'b0) )
            $display("Instruction(#%2d): Passed",(i+1));
          else
            $display("Instruction(#%2d): Failed",(i+1));
    end
    3'b111: begin
      if( (immsrc == 3'b000) &&
          (regw == 1'b1) &&
          (asel == 1'b1) &&
          (bsel == 1'b1) &&
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

task load_test();
  begin
    if( (immsrc == 3'b000) &&
        (regw == 1'b1) &&
        (asel == 1'b1) &&
        (bsel == 1'b1) &&
        (aluctrl == 5'b00000) &&
        (bcond == 4'b0000) &&
        (memw == 1'b0) &&
        (memext == funct3) &&
        (resultsrc == 2'b10) &&
        (jump == 1'b0) )
          $display("Instruction(#%2d): Passed",(i+1));
    else
          $display("Instruction(#%2d): Failed",(i+1));
  end
endtask

task jump_test();
  begin
    case(opcode)
      'd103: begin
        if( (immsrc == 3'b000) &&
            (regw == 1'b1) &&
            (asel == 1'b1) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b01010) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b00) &&
            (jump == 1'b1) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end
      'd111: begin
        if( (immsrc == 3'b010) &&
            (regw == 1'b1) &&
            (asel == 1'b0) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b00000) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b00) &&
            (jump == 1'b1) )
              $display("Instruction(#%2d): Passed",(i+1));
            else
              $display("Instruction(#%2d): Failed",(i+1));
      end
    endcase
  end
endtask

task lui_test();
  begin
    if( (immsrc == 3'b001) &&
        (regw == 1'b1) &&
        (bcond == 4'b0000) &&
        (memw == 1'b0) &&
        (resultsrc == 2'b11) &&
        (jump == 1'b0) )
          $display("Instruction(#%2d): Passed",(i+1));
    else
          $display("Instruction(#%2d): Failed",(i+1));
  end
endtask

task auipc_test();
  begin
    if( (immsrc == 3'b001) &&
            (regw == 1'b1) &&
            (asel == 1'b0) &&
            (bsel == 1'b1) &&
            (aluctrl == 5'b00000) &&
            (bcond == 4'b0000) &&
            (memw == 1'b0) &&
            (resultsrc == 2'b01) &&
            (jump == 1'b0) )
              $display("Instruction(#%2d): Passed",(i+1));
    else
              $display("Instruction(#%2d): Failed",(i+1));
  end
endtask

task store_test();
  begin
    if( (immsrc == 3'b011) &&
        (regw == 1'b0) &&
        (asel == 1'b1) &&
        (bsel == 1'b1) &&
        (aluctrl == 5'b00000) &&
        (storesrc == funct3[1:0]) &&
        (bcond == 4'b0000) &&
        (memw == 1'b1) &&
        (jump == 1'b0) )
          $display("Instruction(#%2d): Passed",(i+1));
    else
          $display("Instruction(#%2d): Failed",(i+1));
  end
endtask

task branch_test();
  begin
    if( (immsrc == 3'b100) &&
          (regw == 1'b0) &&
          (asel == 1'b0) &&
          (bsel == 1'b1) &&
          (aluctrl == 5'b00000) &&
          (bcond[3] == 1'b1) &&
          (bcond[2:0] == funct3) &&
          (memw == 1'b1) &&
          (jump == 1'b0) )
            $display("Instruction(#%2d): Passed",(i+1));
      else
            $display("Instruction(#%2d): Failed",(i+1));
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