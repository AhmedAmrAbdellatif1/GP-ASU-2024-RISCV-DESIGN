module riscv_zeroextend (
  input  wire [ 4:0] i_riscv_zeroextend_imm      ,
  output reg  [63:0] o_riscv_zeroextend_immextend
);
  always @(*)
    begin
      o_riscv_zeroextend_immextend = { {59{1'b0}} , i_riscv_zeroextend_imm } ;
    end
endmodule 