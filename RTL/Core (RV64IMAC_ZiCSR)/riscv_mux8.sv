module riscv_mux8 (
  input  logic [ 2:0] i_riscv_mux8_sel,
  input  logic [63:0] i_riscv_mux8_in0,
  input  logic [63:0] i_riscv_mux8_in1,
  input  logic [63:0] i_riscv_mux8_in2,
  input  logic [63:0] i_riscv_mux8_in3,
  input  logic [63:0] i_riscv_mux8_in4,
  input  logic [63:0] i_riscv_mux8_in5,
  input  logic [63:0] i_riscv_mux8_in6,
  input  logic [63:0] i_riscv_mux8_in7,
  output logic [63:0] o_riscv_mux8_out
);

  always_comb
    begin
      case(i_riscv_mux8_sel)
        3'b000 :
          o_riscv_mux8_out = i_riscv_mux8_in0;
        3'b001 :
          o_riscv_mux8_out = i_riscv_mux8_in1;
        3'b010 :
          o_riscv_mux8_out = i_riscv_mux8_in2;
        3'b011 :
          o_riscv_mux8_out = i_riscv_mux8_in3;
        3'b100 :
          o_riscv_mux8_out = i_riscv_mux8_in4;
        3'b101 :
          o_riscv_mux8_out = i_riscv_mux8_in5;
        3'b110 :
          o_riscv_mux8_out = i_riscv_mux8_in6;
        3'b111 :
          o_riscv_mux8_out = i_riscv_mux8_in7;
        default :
          o_riscv_mux8_out = 'b0;
      endcase
    end
endmodule
