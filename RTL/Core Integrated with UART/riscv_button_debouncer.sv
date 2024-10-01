module riscv_button_debouncer (
  input  logic clk, reset,
  input  logic noisy    ,
  output logic debounced
);

  logic noisy_sync;

  uart_fifo_df_sync #(
    .BUS_WIDTH (1),
    .NUM_STAGES(2)
  ) u_button_synchronizer (
    .i_fifo_dfsync_clk  (clk       ),
    .i_fifo_dfsync_rst_n(~reset    ),
    .i_fifo_dfsync_async(noisy     ),
    .o_fifo_dfsync_sync (noisy_sync)
  );

  riscv_button_debouncer_delayed DD0 (
    .clk      (clk       ),
    .reset    (reset     ),
    .noisy    (noisy_sync),
    .debounced(debounced )
  );

endmodule