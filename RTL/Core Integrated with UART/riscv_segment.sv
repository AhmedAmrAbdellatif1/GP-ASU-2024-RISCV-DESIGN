module riscv_segment (
  input  logic        i_riscv_segment_clk    ,
  input  logic        i_riscv_segment_rst    ,
  input  logic        i_riscv_segment_en     ,
  input  logic [63:0] i_riscv_segment_cathode,
  output logic [ 6:0] o_riscv_segment_cathode
);

  always_ff @(posedge i_riscv_segment_clk or posedge i_riscv_segment_rst) begin
    if(i_riscv_segment_rst)
      o_riscv_segment_cathode <= 7'b0000001;
    else if(i_riscv_segment_en) begin
      case(i_riscv_segment_cathode)
        63'd0   : o_riscv_segment_cathode <= 7'b0000001;
        63'd1   : o_riscv_segment_cathode <= 7'b1001111;
        63'd2   : o_riscv_segment_cathode <= 7'b0010010;
        63'd3   : o_riscv_segment_cathode <= 7'b0000110;
        63'd4   : o_riscv_segment_cathode <= 7'b1001100;
        63'd5   : o_riscv_segment_cathode <= 7'b0100100;
        63'd6   : o_riscv_segment_cathode <= 7'b0100000;
        63'd7   : o_riscv_segment_cathode <= 7'b0001111;
        63'd8   : o_riscv_segment_cathode <= 7'b0000000;
        63'd9   : o_riscv_segment_cathode <= 7'b0000100;
        default : o_riscv_segment_cathode <= 7'b0000001;
      endcase
    end
  end
endmodule