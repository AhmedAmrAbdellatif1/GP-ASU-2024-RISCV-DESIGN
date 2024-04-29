module riscv_mux3 #(parameter width= 64) (
  input  wire [1:0]       i_riscv_mux3_sel,
  input  wire [width-1:0] i_riscv_mux3_in0,
  input  wire [width-1:0] i_riscv_mux3_in1,
  input  wire [width-1:0] i_riscv_mux3_in2,
  output reg [width-1:0] o_riscv_mux3_out);
  
always @(*) 
begin
  case(i_riscv_mux3_sel)
  2'b00: o_riscv_mux3_out=i_riscv_mux3_in0;
  2'b01: o_riscv_mux3_out=i_riscv_mux3_in1;
  2'b10: o_riscv_mux3_out=i_riscv_mux3_in2;
  2'b11: o_riscv_mux3_out='b0;
  endcase
end
endmodule 