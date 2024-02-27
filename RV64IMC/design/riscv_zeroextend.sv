module riscv_zeroextend
 (
   input  logic  [4:0]  i_riscv_zeroextend_imm ,
   output logic  [63:0] o_riscv_zeroextend_immextend
 ) ;

  always @(*) begin 
  	
  	o_riscv_zeroextend_immextend = { {59{1'b0}} , i_riscv_zeroextend_imm } ;
                                   
  end
 
 endmodule 
