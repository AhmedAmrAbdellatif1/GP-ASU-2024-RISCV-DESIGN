module riscv_leds (
  input  logic i_riscv_leds_clk,
  input  logic i_riscv_leds_rst,
  input  logic i_riscv_leds_en ,
  input  logic i_riscv_leds_d  ,
  output logic o_riscv_leds_q
);
  always_ff @(posedge i_riscv_leds_clk or posedge i_riscv_leds_rst) begin
    if(i_riscv_leds_rst)
      o_riscv_leds_q <= 1'b0;
    else if(i_riscv_leds_en)
      o_riscv_leds_q <= i_riscv_leds_d;
  end
endmodule