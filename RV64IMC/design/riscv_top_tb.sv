`timescale 1ns/1ns

module riscv_top_tb();
/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;
  parameter NO_INST = 12211;
  `include "declare.svh"
  int i;
/********************* Initial Blocks *********************/

initial begin
  forever begin
    if(regWrite) begin  // if the register file will be updated
      if(!instr.addr)
        $display("(0x%8h)",instr.hexa);
      else if(instr.addr > 'd9)
        $display("(0x%8h) x%2d 0x%16h",instr.hexa,instr.addr,instr.data);
      else
        $display("(0x%8h) x%1d  0x%16h",instr.hexa,instr.addr,instr.data);
    end
    #CLK_PERIOD;
  end
end
initial begin
  #(6*NO_INST*CLK_PERIOD) $stop;
end
/******************** DUT Instantiation *******************/
  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );

endmodule