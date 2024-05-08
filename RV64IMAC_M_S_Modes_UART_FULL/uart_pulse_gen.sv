module uart_pulse_gen  (
  input   logic  i_pulse_gen_clk       ,   // Clock Signal 
  input   logic  i_pulse_gen_rst_n       ,   // Active Low Reset
  input   logic  i_pulse_gen_lvl_sig   ,   // Level signal
  output  logic  o_pulse_gen_pulse_sig );  // Pulse signal
  
  // register declaration
  logic buffer_reg;
  
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
