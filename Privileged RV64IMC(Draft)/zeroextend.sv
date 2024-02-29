module riscv_zeroextend  #(parameter width=64)
 (
   input  logic  [4:0]  i_riscv_zeroextend_imm ,
  output logic  [width-1:0] o_riscv_zeroextend_immextend
 ) ;

  always @(*) begin 
    
    o_riscv_zeroextend_immextend = { {59{1'b0}} , i_riscv_zeroextend_imm } ;
                                   
  end
 
 endmodule 