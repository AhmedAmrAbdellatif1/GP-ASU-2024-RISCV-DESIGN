module uart_peripheral_top #(
  parameter FIFO_DEPTH  = 256               ,
  parameter BAUD_RATE   = 115200            ,
  parameter PRESCALE    = 32                ,
  parameter UART_RX_CLK = BAUD_RATE/PRESCALE
) (
  input  wire       i_uart_clk       ,
  input  wire       i_uart_rst_n     ,
  input  wire       i_uart_tx_valid  ,
  input  wire       i_uart_rx_request,
  input  wire       i_uart_rx_sdata  ,
  input  wire [7:0] i_uart_tx_pdata  ,
  output wire       o_uart_fifo_full ,
  output wire       o_uart_tx_sdata  ,
  output wire [7:0] o_uart_rx_pdata
);

  /************************************ ------------ Internal Signals ------------ ************************************/
  wire       uart_tx_clk       ;
  wire [7:0] uart_tx_pdata     ;
  wire       uart_fifo_empty   ;
  wire       uart_tx_busy      ;
  wire       uart_tx_busy_pulse;

  wire                           uart_parity_enable;
  wire                           uart_parity_type  ;
  wire [ $clog2(PRESCALE+1)-1:0] uart_prescale     ;
  wire [  $clog2(BAUD_RATE)-1:0] uart_baud_rate    ;
  wire [$clog2(UART_RX_CLK)-1:0] uart_rx_clk_ratio ;

  wire       uart_rx_clk  ;
  wire [7:0] uart_rx_pdata;
  wire       uart_rx_valid;

  /************************************ -------------- Instantiation ------------- ************************************/
  uart_clk_div #(.DIV_RATIO(BAUD_RATE)) u_uart_clk_div_tx (
    .i_clk_div_ref_clk (i_uart_clk    ),
    .i_clk_div_rst_n   (i_uart_rst_n  ),
    .i_clk_div_clk_en  (1'b1          ),
    .i_clk_div_ratio   (uart_baud_rate),
    .o_clk_div_baud_clk(uart_tx_clk   )
  );

  uart_clk_div #(.DIV_RATIO(UART_RX_CLK)) u_uart_clk_div_rx (
    .i_clk_div_ref_clk (i_uart_clk       ),
    .i_clk_div_rst_n   (i_uart_rst_n     ),
    .i_clk_div_clk_en  (1'b1             ),
    .i_clk_div_ratio   (uart_rx_clk_ratio),
    .o_clk_div_baud_clk(uart_rx_clk      )
  );

  uart_fifo_top #(.FIFO_DEPTH(FIFO_DEPTH)) u_uart_fifo_tx (
    .i_riscv_fifo_wclk  (i_uart_clk        ),
    .i_riscv_fifo_wrst_n(i_uart_rst_n      ),
    .i_riscv_fifo_winc  (i_uart_tx_valid   ),
    .i_riscv_fifo_rclk  (uart_tx_clk       ),
    .i_riscv_fifo_rrst_n(i_uart_rst_n      ),
    .i_riscv_fifo_rinc  (uart_tx_busy_pulse),
    .i_riscv_fifo_wdata (i_uart_tx_pdata   ),
    .o_riscv_fifo_full  (o_uart_fifo_full  ),
    .o_riscv_fifo_rdata (uart_tx_pdata     ),
    .o_riscv_fifo_empty (uart_fifo_empty   )
  );

  uart_tx_top uart_tx_top_inst (
    .CLK       (uart_tx_clk       ),
    .RST       (i_uart_rst_n      ),
    .P_DATA    (uart_tx_pdata     ),
    .DATA_VALID(!uart_fifo_empty  ),
    .PAR_EN    (uart_parity_enable),
    .PAR_TYP   (uart_parity_type  ),
    .TX_OUT    (o_uart_tx_sdata   ),
    .Busy      (uart_tx_busy      )
  );

  uart_fifo_top #(.FIFO_DEPTH(FIFO_DEPTH)) u_uart_fifo_rx (
    .i_riscv_fifo_wclk  (uart_rx_clk      ),
    .i_riscv_fifo_wrst_n(i_uart_rst_n     ),
    .i_riscv_fifo_winc  (uart_rx_valid    ),
    .i_riscv_fifo_rclk  (i_uart_clk       ),
    .i_riscv_fifo_rrst_n(i_uart_rst_n     ),
    .i_riscv_fifo_rinc  (i_uart_rx_request),
    .i_riscv_fifo_wdata (uart_rx_pdata    ),
    .o_riscv_fifo_full  (                 ),
    .o_riscv_fifo_rdata (o_uart_rx_pdata  ),
    .o_riscv_fifo_empty (                 )
  );

  uart_rx_top uart_rx_top_inst (
    .i_clk          (uart_rx_clk       ),
    .i_rst_n        (i_uart_rst_n      ),
    .i_prescale     (uart_prescale     ),
    .i_serial_data  (i_uart_rx_sdata   ),
    .i_parity_enable(uart_parity_enable),
    .i_parity_type  (uart_parity_type  ),
    .o_data_valid   (uart_rx_valid     ),
    .o_parity_error (                  ),
    .o_stop_error   (                  ),
    .o_parallel_data(uart_rx_pdata     )
  );

  uart_pulse_gen uart_pulse_gen_inst (
    .i_pulse_gen_clk      (uart_tx_clk       ),
    .i_pulse_gen_rst_n    (i_uart_rst_n      ),
    .i_pulse_gen_lvl_sig  (uart_tx_busy      ),
    .o_pulse_gen_pulse_sig(uart_tx_busy_pulse)
  );

  uart_config #(
    .PRESCALE (PRESCALE ),
    .BAUD_RATE(BAUD_RATE)
  ) uart_config_inst (
    .uart_parity_enable(uart_parity_enable),
    .uart_parity_type  (uart_parity_type  ),
    .uart_prescale     (uart_prescale     ),
    .uart_baud_rate    (uart_baud_rate    ),
    .uart_rx_clk_ratio (uart_rx_clk_ratio )
  );

endmodule