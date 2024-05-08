module uart_peripheral_top #(
  parameter FIFO_DEPTH = 256   ,
  parameter BAUD_RATE  = 115200
) (
  input  logic       i_uart_clk      ,
  input  logic       i_uart_rst_n    ,
  input  logic [7:0] i_uart_tx_pdata ,
  input  logic       i_uart_tx_valid ,
  output logic       o_uart_fifo_full,
  output logic       o_uart_tx_sdata
);

  /************************************ ------------ Internal Signals ------------ ************************************/
  logic       uart_tx_clk       ;
  logic [7:0] uart_tx_pdata     ;
  logic       uart_fifo_empty   ;
  logic       uart_tx_busy      ;
  logic       uart_tx_busy_pulse;

  logic                         uart_parity_enable;
  logic                         uart_parity_type  ;
  logic [$clog2(BAUD_RATE)-1:0] uart_baud_rate    ;

  /************************************ -------------- Instantiation ------------- ************************************/
  uart_clk_div #(.DIV_RATIO(BAUD_RATE)) uart_clk_div_inst (
    .i_clk_div_ref_clk (i_uart_clk    ),
    .i_clk_div_rst_n   (i_uart_rst_n  ),
    .i_clk_div_clk_en  (1'b1          ),
    .i_clk_div_ratio   (uart_baud_rate),
    .o_clk_div_baud_clk(uart_tx_clk   )
  );

  uart_fifo_top #(.FIFO_DEPTH(FIFO_DEPTH)) uart_fifo_top_inst (
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

  uart_pulse_gen uart_pulse_gen_inst (
    .i_pulse_gen_clk      (uart_tx_clk       ),
    .i_pulse_gen_rst_n    (i_uart_rst_n      ),
    .i_pulse_gen_lvl_sig  (uart_tx_busy      ),
    .o_pulse_gen_pulse_sig(uart_tx_busy_pulse)
  );

  uart_config #(.BAUD_RATE(BAUD_RATE)) uart_config_inst (
    .uart_parity_enable(uart_parity_enable),
    .uart_parity_type  (uart_parity_type  ),
    .uart_baud_rate    (uart_baud_rate    )
  );

endmodule