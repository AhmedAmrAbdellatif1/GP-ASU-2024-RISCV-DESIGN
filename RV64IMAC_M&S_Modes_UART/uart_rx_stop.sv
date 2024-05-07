module uart_rx_stop (
  input  logic enable          ,
  input  logic sampled_stop_bit,
  output logic error
);

  always_comb
    begin
      if(enable && !sampled_stop_bit)
        error = 1'b1;
      else
        error = 1'b0;
    end
endmodule

