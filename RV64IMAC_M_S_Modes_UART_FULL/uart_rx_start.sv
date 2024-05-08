module uart_rx_start (
  input  logic enable           ,
  input  logic sampled_start_bit,
  output logic  glitch
);

  always_comb
    begin
      if(enable && sampled_start_bit)
        glitch = 1'b1;
      else
        glitch = 1'b0;
    end
endmodule

