`timescale 1ns/100ps

module riscv_top_tb();
  /********************** Declarations **********************/
  `include "declare.svh"

  parameter DEBUG = 0;

  /********* to define when to stop the simulation *********/

  generate;
    if(DEBUG)
    begin
      always@(instr.hexa)
      begin
        if(instr.hexa == 'h00000073)
        begin // last instruction in the text file
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
        if(instr.pc == 'h800c8b4e)  // last pc in the text file
          #(CLK_PERIOD) $stop;
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
        if(instr.illegal)
          begin
            $display("exception trap_illegal_instruction, epc 0x%16h\n\t    tval 0x%16h",instr.pc,instr.hexa);  // illegal instruction
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
        
              else if(instr.funct3 == 'b101) // csrrwi rd, csr, uimm
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h %s 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata,instr.mreg,instr.csrw);
                end
        
              else if(instr.funct3 == 'b110) // csrrsi rd, csr, uimm
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end
        
              else if(instr.funct3 == 'b111) // csrrci rd, csr, uimm
                begin
                  if(instr.rd > 'd9)
                    $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                  else
                    $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.hexa,instr.rd,instr.rddata);
                end

              else if((instr.funct3 == 'b000) && (instr.csr == 'b0))  // ecall
                begin
                  $display("exception trap_machine_ecall, epc 0x%16h",instr.pc);
                end
          
              else if((instr.funct3 == 'b000) && (instr.rd == 'b0) && (instr.rs1 == 'b0) && (instr.csr == 'd770)) // mret
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