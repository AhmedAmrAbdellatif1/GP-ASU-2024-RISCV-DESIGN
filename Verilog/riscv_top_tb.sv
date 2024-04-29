`timescale 1ns/100ps

module riscv_top_tb();
  /********************** Declarations **********************/
  `include "declare.svh"

  parameter DEBUG = 0;
  parameter logic [63:0] LAST_PC    = 'h80002e16; //800c6bce
  parameter logic [63:0] LAST_INSTR = 'hbfe5; 

  /********* to define when to stop the simulation *********/

  generate;
    if(DEBUG)
    begin
      always@(instr.hexa)
      begin
        if(instr.hexa == LAST_INSTR) // last instruction in the text file
        begin
          #(CLK_PERIOD);
          wait(!stall);
          #(CLK_PERIOD);
          $stop;
        end
      end
    end

    else
    begin
      always@(instr.pc)
      begin
        if(instr.pc == LAST_PC)  // last pc in the text file
        begin
          #(CLK_PERIOD);
          wait(!stall);
          //#(CLK_PERIOD);
          $stop;
        end
      end
    end

  endgenerate

  /**************************************** Initial Blocks ****************************************/
  initial
  begin
    forever
    begin
      if(!stall)
      begin
        if((instr.illegal) && (instr.pc != 'b0))
          begin
            if(instr.c[1:0] == 2'b11)
              $display("exception trap_illegal_instruction, epc 0x%16h\n\t    tval 0x%16h",instr.pc,instr.hexa);  // illegal instruction
            else
              $display("exception trap_illegal_instruction, epc 0x%16h\n\t    tval 0x%16h",instr.pc,instr.c);  // illegal instruction
          end
        else
            begin
          case(instr.op)

            OPCODE_OP, OPCODE_OP_IMM, OPCODE_OP_WORD, OPCODE_OP_WORD_IMM, OPCODE_LUI, OPCODE_AUIPC: begin
              if(instr.c[1:0] == 2'b11)
                begin
                  if(!instr.rd)
                    $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
                  else if(instr.rd > 'd9)
                    $display("0x%16h (0x%8h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%8h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
              else
                begin
                  if(!instr.rd)
                    $display("0x%16h (0x%4h)",instr.pc,instr.c);
                  else if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.c,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.c,instr.rd,instr.rddata);
                end
            end

            OPCODE_LOAD: begin
              if(instr.c[1:0] == 2'b11)
                begin
                  if(!instr.rd)
                    $display("0x%16h (0x%8h) mem 0x%16h",instr.pc,instr.hexa,instr.memaddr);
                  else if(instr.rd > 'd9)
                    $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr);
                  else
                    $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr);
                end
              else
                begin
                  if(!instr.rd)
                    $display("0x%16h (0x%4h) mem 0x%16h",instr.pc,instr.c,instr.memaddr);
                  else if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h mem 0x%16h",instr.pc,instr.c,instr.rd,instr.rddata,instr.memaddr);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h mem 0x%16h",instr.pc,instr.c,instr.rd,instr.rddata,instr.memaddr);
                end
            end

            OPCODE_STORE: begin
              if(instr.c[1:0] == 2'b11)
                begin
                  if(instr.funct3 == BYTE)
                    $display("0x%16h (0x%8h) mem 0x%16h 0x%2h",instr.pc,instr.hexa,instr.memaddr,instr.store[7:0]);
                  if(instr.funct3 == HALFWORD)
                    $display("0x%16h (0x%8h) mem 0x%16h 0x%4h",instr.pc,instr.hexa,instr.memaddr,instr.store[15:0]);
                  if(instr.funct3 == WORD)
                    $display("0x%16h (0x%8h) mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.memaddr,instr.store[31:0]);
                  if(instr.funct3 == DOUBLEWORD)
                    $display("0x%16h (0x%8h) mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.memaddr,instr.store);
                end
              else
                begin
                  if(instr.funct3 == BYTE)
                    $display("0x%16h (0x%4h) mem 0x%16h 0x%2h",instr.pc,instr.c,instr.memaddr,instr.store[7:0]);
                  if(instr.funct3 == HALFWORD)
                    $display("0x%16h (0x%4h) mem 0x%16h 0x%4h",instr.pc,instr.c,instr.memaddr,instr.store[15:0]);
                  if(instr.funct3 == WORD)
                    $display("0x%16h (0x%4h) mem 0x%16h 0x%8h",instr.pc,instr.c,instr.memaddr,instr.store[31:0]);
                  if(instr.funct3 == DOUBLEWORD)
                    $display("0x%16h (0x%4h) mem 0x%16h 0x%16h",instr.pc,instr.c,instr.memaddr,instr.store);
                end
            end

            OPCODE_BRANCH: begin
              if(instr.c[1:0] == 2'b11)
                $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
              else
                $display("0x%16h (0x%4h)",instr.pc,instr.c);
            end

            OPCODE_JAL, OPCODE_JALR: begin
              if(instr.c[1:0] == 2'b11)
                begin
                  if(!instr.rd)
                    $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
                  else if(instr.rd > 'd9)
                    $display("0x%16h (0x%8h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%8h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
                else
                  begin
                    if(!instr.rd)
                      $display("0x%16h (0x%4h)",instr.pc,instr.c);
                    else if(instr.rd > 'd9)
                      $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.c,instr.rd,instr.rddata);
                    else
                      $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.c,instr.rd,instr.rddata);
                  end
            end

            OPCODE_ATOMIC: begin
              if(amo_op_flag)
                begin
                  if(instr.funct3 == ATOMIC_D)
                  begin
                    if(!instr.rd)
                      $display("0x%16h (0x%8h) mem 0x%16h mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.memaddr,instr.memaddr,instr.amo_result);
                    else if(instr.rd > 'd9)
                      $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.memaddr,instr.memaddr,instr.amo_result);
                    else
                      $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.memaddr,instr.memaddr,instr.amo_result);
                  end
                  else if(instr.funct3 == ATOMIC_W)
                    begin
                      if(!instr.rd)
                        $display("0x%16h (0x%8h) mem 0x%16h mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.memaddr,instr.memaddr,instr.amo_result[31:0]);
                      else if(instr.rd > 'd9)
                        $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.memaddr,instr.memaddr,instr.amo_result[31:0]);
                      else
                        $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.memaddr,instr.memaddr,instr.amo_result[31:0]);
                    end
                end
              else if(instr.funct7[31:27] == LR)
                begin
                  if(!instr.rd)
                    $display("0x%16h (0x%8h) mem 0x%16h",instr.pc,instr.hexa,instr.memaddr);
                  else if(instr.rd > 'd9)
                    $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr);
                  else
                    $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr);
                end
                
              else if(instr.funct7[31:27] == SC)
                begin
                  if(!instr.rddata)
                    begin
                      if(instr.funct3 == ATOMIC_D)
                        begin
                          if(!instr.rd)
                            $display("0x%16h (0x%8h) mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.memaddr,instr.store);
                          else if(instr.rd > 'd9)
                            $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr,instr.store);
                          else
                            $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr,instr.store);
                        end
                        if(instr.funct3 == ATOMIC_W)
                        begin
                          if(!instr.rd)
                            $display("0x%16h (0x%8h) mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.memaddr,instr.store[31:0]);
                          else if(instr.rd > 'd9)
                            $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr,instr.store[31:0]);
                          else
                            $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.rd,instr.load,instr.memaddr,instr.store[31:0]);
                        end
                    end
                  else
                    begin
                      if(instr.funct3 == ATOMIC_D)
                        begin
                          if(!instr.rd)
                            $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
                          else if(instr.rd > 'd9)
                            $display("0x%16h (0x%8h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load);
                          else
                            $display("0x%16h (0x%8h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.load);
                        end
                        if(instr.funct3 == ATOMIC_W)
                        begin
                          if(!instr.rd)
                            $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
                          else if(instr.rd > 'd9)
                            $display("0x%16h (0x%8h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.load);
                          else
                            $display("0x%16h (0x%8h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.load);
                        end
                    end
                end
            end

            OPCODE_CSR: begin
              if((instr.funct3 == 'b010) && (instr.rs1 == 'b0)) // csrr rd, csr
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
        
              else if((instr.funct3 == 'b010) && (instr.rs1 != 'b0)) // csrrs rd, csr, rs1
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if((instr.funct3 == 'b001) && (instr.rd == 'b0)) // csrw csr, rs1
                begin
                  $display("0x%16h (0x%4h) %s 0x%16h",instr.pc,instr.hexa,instr.mreg,instr.csrw);
                end
                
              else if((instr.funct3 == 'b001) && (instr.rs1 != 'b0)) // csrrw rd, csr, rs1
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if((instr.funct3 == 'b011) && (instr.rs1 == 'b0)) // csrrc rd, csr, x0
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
        
              else if((instr.funct3 == 'b011) && (instr.rs1 != 'b0))// csrrc rd, csr, rs1
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if((instr.funct3 == 'b101) && (instr.rs1 != 'b0)) // csrrwi rd, csr, uimm
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if((instr.funct3 == 'b101) && (instr.rs1 == 'b0)) // csrrwi rd, csr, 0
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
        
              else if((instr.funct3 == 'b110) && (instr.rs1 != 'b0)) // csrrsi rd, csr, uimm
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if((instr.funct3 == 'b110) && (instr.rs1 == 'b0)) // csrrsi rd, csr, 0
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
      
              else if((instr.funct3 == 'b111) && (instr.rs1 != 'b0)) // csrrci rd, csr, uimm
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if((instr.funct3 == 'b111) && (instr.rs1 == 'b0)) // csrrci rd, csr, 0
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end

              else if((instr.funct3 == 'b000) && (instr.csr == 'b0))  // ecall
                begin
                  if(csr.priv_lvl == 'd3)
                    $display("exception trap_machine_ecall, epc 0x%16h",instr.pc);
                  else if(csr.priv_lvl == 'd1)
                    $display("exception trap_supervisor_ecall, epc 0x%16h",instr.pc);
                  else if(csr.priv_lvl == 'd0)
                    $display("exception trap_user_ecall, epc 0x%16h",instr.pc);
                end
          
              else if(mret_flag) // mret
                begin
                  $display("0x%16h (0x%4h) %s 0x%16h",instr.pc,instr.hexa,instr.mreg,instr.csrw);
                end
            end
          endcase
        end
      end
      #CLK_PERIOD;
    end
  end
endmodule