`timescale 1ns/1ns

module riscv_top_tb();
/********************** Declarations **********************/
  `include "declare.svh"

/********* to define when to stop the simulation *********/
/*always@(instr.hexa) begin
    if(instr.hexa == 'hb87a9283)  // last instruction in the text file
    #(CLK_PERIOD) $stop;
  end*/

  always@(instr.pc) begin
    if(instr.pc == 'h80011348)  // last instruction in the text file
    #(CLK_PERIOD) $stop;
  end

/******************** Initial Blocks ********************/
initial begin
  forever begin
    if(regWrite && !stall) begin  // if the register file will be updated
          ////// I-type instruction //////
          if(instr.c[1:0] == 2'b11) begin
            ////// Load instruction //////
              if(instr.op == 'd3) begin
                  // if rd = x0
                  if(!instr.gpr) 
                    $display("0x%16h (0x%8h) mem 0x%16h",instr.pc,instr.hexa,instr.memaddr);
                  // if rd > x9
                  else if(instr.gpr > 'd9)
                    $display("0x%16h (0x%8h) x%2d 0x%16h mem 0x%16h",instr.pc,instr.hexa,instr.gpr,instr.load,instr.memaddr);
                  // if rd < x9
                  else
                    $display("0x%16h (0x%8h) x%1d  0x%16h mem 0x%16h",instr.pc,instr.hexa,instr.gpr,instr.load,instr.memaddr);
              end
              else begin
                  // if rd = x0
                  if(!instr.gpr) 
                    $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
                  // if rd > x9
                  else if(instr.gpr > 'd9)
                    $display("0x%16h (0x%8h) x%2d 0x%16h",instr.pc,instr.hexa,instr.gpr,instr.rd);
                  // if rd < x9
                  else
                    $display("0x%16h (0x%8h) x%1d  0x%16h",instr.pc,instr.hexa,instr.gpr,instr.rd);
              end
          end
          ////// C-type instruction //////
          else begin
            // C-Load Instructions //
            if(instr.op == 'd3) begin
                // if rd = x0
                if(!instr.gpr)
                  $display("0x%16h (0x%4h) mem 0x%16h",instr.pc,instr.c,instr.memaddr);
                // if rd > x9
                else if(instr.gpr > 'd9)
                  $display("0x%16h (0x%4h) x%2d 0x%16h mem 0x%16h",instr.pc,instr.c,instr.gpr,instr.rd,instr.memaddr);
                // if rd < x9
                else  
                  $display("0x%16h (0x%4h) x%1d  0x%16h mem 0x%16h",instr.pc,instr.c,instr.gpr,instr.rd,instr.memaddr);
            end
            else begin
              // if rd = x0
              if(!instr.gpr)
                $display("0x%16h (0x%4h)",instr.pc,instr.c);
              // if rd > x9
              else if(instr.gpr > 'd9)
                $display("0x%16h (0x%4h) x%2d 0x%16h",instr.pc,instr.c,instr.gpr,instr.rd);
              // if rd < x9
              else  
                $display("0x%16h (0x%4h) x%1d  0x%16h",instr.pc,instr.c,instr.gpr,instr.rd);
          end
          end
    end
    ////// Store instruction //////
    else if((instr.op == 'd35) && !stall) begin
      if(instr.c[1:0] == 2'b11) begin
          if(instr.funct3 == 3'b000)
            $display("0x%16h (0x%8h) mem 0x%16h 0x%2h",instr.pc,instr.hexa,instr.memaddr,instr.store[7:0]);
          if(instr.funct3 == 3'b001)
            $display("0x%16h (0x%8h) mem 0x%16h 0x%4h",instr.pc,instr.hexa,instr.memaddr,instr.store[15:0]);
          if(instr.funct3 == 3'b010)
            $display("0x%16h (0x%8h) mem 0x%16h 0x%8h",instr.pc,instr.hexa,instr.memaddr,instr.store[31:0]);
          if(instr.funct3 == 3'b011)
            $display("0x%16h (0x%8h) mem 0x%16h 0x%16h",instr.pc,instr.hexa,instr.memaddr,instr.store);
      end
      else begin
        if(instr.funct3 == 3'b000)
          $display("0x%16h (0x%4h) mem 0x%16h 0x%2h",instr.pc,instr.c,instr.memaddr,instr.store[7:0]);
        if(instr.funct3 == 3'b001)
          $display("0x%16h (0x%4h) mem 0x%16h 0x%4h",instr.pc,instr.c,instr.memaddr,instr.store[15:0]);
        if(instr.funct3 == 3'b010)
          $display("0x%16h (0x%4h) mem 0x%16h 0x%8h",instr.pc,instr.c,instr.memaddr,instr.store[31:0]);
        if(instr.funct3 == 3'b011)
          $display("0x%16h (0x%4h) mem 0x%16h 0x%16h",instr.pc,instr.c,instr.memaddr,instr.store);
    end
    end
    ////// Branch and Jump instructions //////
    else if(((instr.op == 'd99) || (instr.op == 'd111) || (instr.op == 'd103)) && !stall) begin
      if(instr.c[1:0] == 2'b11)
        $display("0x%16h (0x%8h)",instr.pc,instr.hexa);
      else
        $display("0x%16h (0x%4h)",instr.pc,instr.c);
    end
    #CLK_PERIOD;
  end
end

endmodule