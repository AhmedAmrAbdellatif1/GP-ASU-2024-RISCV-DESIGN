module riscv_im (
  input   logic   [63:0]  i_riscv_im_pc,
  output  logic   [31:0]  o_riscv_im_inst,
  output  logic           o_riscv_icache_cpu_stall);
  
  logic [31:0] RAM [0:1216330];
  logic [63:0] pcplus ;

  initial begin
    $readmemh("word_instructions.txt",RAM);
  end
  
  always @(*)  begin
    if (i_riscv_im_pc %4)
    o_riscv_im_inst={ RAM[pcplus[63:2]][15:0], RAM[i_riscv_im_pc[63:2]][31:16] } ;
    else
    o_riscv_im_inst=RAM[i_riscv_im_pc[63:2]];
  end
  
  assign pcplus = i_riscv_im_pc + 64'b10;
  assign o_riscv_icache_cpu_stall = 1'b0;

endmodule

