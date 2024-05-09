module uart_fifo_top #(parameter FIFO_DEPTH = 256, parameter PTR_WIDTH = ($clog2(FIFO_DEPTH)+1)) (
  input  logic       i_riscv_fifo_wclk  ,
  input  logic       i_riscv_fifo_wrst_n,
  input  logic       i_riscv_fifo_winc  ,
  input  logic       i_riscv_fifo_rclk  ,
  input  logic       i_riscv_fifo_rrst_n,
  input  logic       i_riscv_fifo_rinc  ,
  input  logic [7:0] i_riscv_fifo_wdata ,
  output logic       o_riscv_fifo_full  ,
  output logic [7:0] o_riscv_fifo_rdata ,
  output logic       o_riscv_fifo_empty
);

  // internal signal declaration
  logic [PTR_WIDTH-2:0] x_waddr    ;
  logic [PTR_WIDTH-2:0] x_raddr    ;
  logic [PTR_WIDTH-1:0] x_wptr     ;
  logic [PTR_WIDTH-1:0] x_rptr     ;
  logic [PTR_WIDTH-1:0] x_wptr_conv;
  logic [PTR_WIDTH-1:0] x_rptr_conv;
  logic [PTR_WIDTH-1:0] x_wq2_rptr ;
  logic [PTR_WIDTH-1:0] x_rq2_wptr ;

  // FIFO memory buffer
  uart_fifo_mem_ctrl #(.FIFO_DEPTH(FIFO_DEPTH), .PTR_WIDTH(PTR_WIDTH)) u_uart_fifo_mem_ctrl (
    .i_mem_ctrl_wclk_en((!o_riscv_fifo_full)&i_riscv_fifo_winc),
    .i_mem_ctrl_wdata  (i_riscv_fifo_wdata                    ),
    .i_mem_ctrl_waddr  (x_waddr                               ),
    .i_mem_ctrl_wclk   (i_riscv_fifo_wclk                     ),
    .i_mem_ctrl_wrst_n (i_riscv_fifo_wrst_n                   ),
    .o_mem_ctrl_rdata  (o_riscv_fifo_rdata                    ),
    .i_mem_ctrl_raddr  (x_raddr                               )
  );

  // FIFO empty and read address generator
  uart_fifo_rd #(.PTR_WIDTH(PTR_WIDTH)) u_uart_fifo_rd (
    .i_fifo_rd_clk      (i_riscv_fifo_rclk  ),
    .i_fifo_rd_rst_n    (i_riscv_fifo_rrst_n),
    .i_fifo_rd_rinc     (i_riscv_fifo_rinc  ),
    .i_fifo_rd_wptr_conv(x_rq2_wptr         ),
    .i_fifo_rd_rptr_conv(x_rptr_conv        ),
    .o_fifo_rd_rptr     (x_rptr             ),
    .o_fifo_rd_raddr    (x_raddr            ),
    .o_fifo_rd_empty    (o_riscv_fifo_empty )
  );

  // FIFO full and write address generator
  uart_fifo_wr #(.PTR_WIDTH(PTR_WIDTH)) u_uart_fifo_wr (
    .i_fifo_wr_clk      (i_riscv_fifo_wclk  ),
    .i_fifo_wr_rst_n    (i_riscv_fifo_wrst_n),
    .i_fifo_wr_winc     (i_riscv_fifo_winc  ),
    .i_fifo_wr_wptr_conv(x_wptr_conv        ),
    .i_fifo_wr_rptr_conv(x_wq2_rptr         ),
    .o_fifo_wr_wptr     (x_wptr             ),
    .o_fifo_wr_waddr    (x_waddr            ),
    .o_fifo_wr_full     (o_riscv_fifo_full  )
  );

  // Write-to-Read Synchronizer
  uart_fifo_df_sync #(.BUS_WIDTH(PTR_WIDTH)) u_uart_fifo_df_rsync (
    .i_fifo_dfsync_clk  (i_riscv_fifo_rclk  ),
    .i_fifo_dfsync_rst_n(i_riscv_fifo_rrst_n),
    .i_fifo_dfsync_async(x_wptr_conv        ),
    .o_fifo_dfsync_sync (x_rq2_wptr         )
  );

  // Read-to-Write Synchronizer
  uart_fifo_df_sync #(.BUS_WIDTH(PTR_WIDTH)) u_uart_fifo_df_wsync (
    .i_fifo_dfsync_clk  (i_riscv_fifo_wclk  ),
    .i_fifo_dfsync_rst_n(i_riscv_fifo_wrst_n),
    .i_fifo_dfsync_async(x_rptr_conv        ),
    .o_fifo_dfsync_sync (x_wq2_rptr         )
  );

  // Write-PTR Gray Converter
  uart_fifo_gray_conv #(.PTR_WIDTH(PTR_WIDTH)) u_uart_gray_conv_w (
    .i_fifo_conv_bin_ptr (x_wptr     ),
    .o_fifo_conv_gray_ptr(x_wptr_conv)
  );

  // Read-PTR Gray Converter
  uart_fifo_gray_conv #(.PTR_WIDTH(PTR_WIDTH)) u_uart_gray_conv_r (
    .i_fifo_conv_bin_ptr (x_rptr     ),
    .o_fifo_conv_gray_ptr(x_rptr_conv)
  );

endmodule
