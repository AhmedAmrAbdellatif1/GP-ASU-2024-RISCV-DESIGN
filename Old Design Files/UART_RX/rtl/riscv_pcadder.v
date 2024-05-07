module riscv_pcadder  (
  input  wire [63:0] i_riscv_pcadder_size      ,
  input  wire [63:0] i_riscv_pcadder_pc        ,
  output wire [63:0] o_riscv_pcadder_pcplussize
  );
  
  assign o_riscv_pcadder_pcplussize = i_riscv_pcadder_size  + i_riscv_pcadder_pc;
endmodule 
  