module uart_config #(parameter BAUD_RATE = 115200) (
  output logic                         uart_parity_enable,
  output logic                         uart_parity_type  ,
  output logic [$clog2(BAUD_RATE)-1:0] uart_baud_rate
);

  localparam  PARITY_ON = 1'b1,
    PARITY_OFF  = 1'b0,
    PARITY_EVEN = 1'b0,
    PARITY_ODD  = 1'b1;

  assign uart_parity_enable = PARITY_ON;
  assign uart_parity_type   = PARITY_EVEN;
  assign uart_baud_rate     = BAUD_RATE;

endmodule