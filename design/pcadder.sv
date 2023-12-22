module riscv_pcadder #(parameter width=64)(
  input  logic [width-1:0] i_riscv_pcadder_size,
  input  logic [width-1:0] i_riscv_pcadder_pc,
  output logic [width-1:0] o_riscv_pcadder_pcplussize);
  
  assign o_riscv_pcadder_pcplussize= i_riscv_pcadder_size+i_riscv_pcadder_pc;
endmodule 
  