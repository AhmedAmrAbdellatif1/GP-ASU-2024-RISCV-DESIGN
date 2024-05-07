module uart_config #(
  parameter PRESCALE    = 32                ,
  parameter BAUD_RATE   = 115200            ,
  parameter UART_RX_CLK = BAUD_RATE/PRESCALE
) (
  output logic                           uart_parity_enable,
  output logic                           uart_parity_type  ,
  output logic [ $clog2(PRESCALE+1)-1:0] uart_prescale     ,
  output logic [  $clog2(BAUD_RATE)-1:0] uart_baud_rate    ,
  output logic [$clog2(UART_RX_CLK)-1:0] uart_rx_clk_ratio
);

  localparam  PARITY_ON = 1'b1,
    PARITY_OFF  = 1'b0,
    PARITY_EVEN = 1'b0,
    PARITY_ODD  = 1'b1;

  assign uart_parity_enable = PARITY_ON;
  assign uart_parity_type   = PARITY_EVEN;
  assign uart_prescale      = PRESCALE;
  assign uart_baud_rate     = BAUD_RATE;
  assign uart_rx_clk_ratio  = UART_RX_CLK;

endmodule