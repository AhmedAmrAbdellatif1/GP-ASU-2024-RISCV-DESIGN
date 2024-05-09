module riscv_mux2 #(parameter width= 64) (
  input  logic             i_riscv_mux2_sel,
  input  logic [width-1:0] i_riscv_mux2_in0,
  input  logic [width-1:0] i_riscv_mux2_in1,
  output logic [width-1:0] o_riscv_mux2_out);
  
  assign o_riscv_mux2_out= (i_riscv_mux2_sel)? i_riscv_mux2_in1:i_riscv_mux2_in0;
endmodule 