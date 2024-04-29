module riscv_mux2 #(parameter width= 64) (
  input  wire             i_riscv_mux2_sel,
  input  wire [width-1:0] i_riscv_mux2_in0,
  input  wire [width-1:0] i_riscv_mux2_in1,
  output wire [width-1:0] o_riscv_mux2_out);
  
  assign o_riscv_mux2_out= (i_riscv_mux2_sel)? i_riscv_mux2_in1:i_riscv_mux2_in0;
endmodule 