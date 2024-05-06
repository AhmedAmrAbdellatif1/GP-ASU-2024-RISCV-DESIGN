module uart_pulse_gen (
  input  wire i_pulse_gen_clk      , // Clock Signal
  input  wire i_pulse_gen_rst_n    , // Active Low Reset
  input  wire i_pulse_gen_lvl_sig  , // Level signal
  output wire o_pulse_gen_pulse_sig
);

  // register declaration
  reg buffer_reg;

  // shifting the input
  always @(posedge i_pulse_gen_clk or negedge i_pulse_gen_rst_n)
    begin
      if(!i_pulse_gen_rst_n)
        buffer_reg <= 1'b0;
      else
        buffer_reg <= i_pulse_gen_lvl_sig;
    end

  // pulse generation
  assign o_pulse_gen_pulse_sig = (~buffer_reg) & i_pulse_gen_lvl_sig;

endmodule
