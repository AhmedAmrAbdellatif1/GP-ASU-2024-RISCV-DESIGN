module riscv_mstage (
  input  logic [63:0] i_riscv_mstage_addr           ,
  input  logic [63:0] i_riscv_mstage_dm_rdata       ,
  input  logic [63:0] i_riscv_mstage_timer_rdata    ,
  input  logic [ 7:0] i_riscv_mstage_uart_rx_rdata  ,
  input  logic        i_riscv_mstage_timer_rden     ,
  input  logic        i_riscv_mstage_uart_rx_request,
  input  logic [ 2:0] i_riscv_mstage_memext         ,
  input  logic        i_riscv_mstage_mux2_sel       ,
  input  logic [63:0] i_riscv_mux2_in0              ,
  input  logic [63:0] i_riscv_mux2_in1              ,
  output logic [63:0] o_riscv_mstage_memload        ,
  output logic [63:0] o_riscv_mstage_mux2_out
);

  logic [63:0] riscv_memext_rddata;

  riscv_memext u_riscv_memext (
    .i_riscv_memext_addr  (i_riscv_mstage_addr    ),
    .i_riscv_memext_sel   (i_riscv_mstage_memext  ),
    .i_riscv_memext_data  (i_riscv_mstage_dm_rdata),
    .o_riscv_memext_loaded(riscv_memext_rddata    )
  );

  riscv_mux3 u_riscv_memloadmux (
    .i_riscv_mux3_sel({i_riscv_mstage_uart_rx_request,i_riscv_mstage_timer_rden}),
    .i_riscv_mux3_in0(riscv_memext_rddata                                       ),
    .i_riscv_mux3_in1(i_riscv_mstage_timer_rdata                                ),
    .i_riscv_mux3_in2({56'b0,i_riscv_mstage_uart_rx_rdata}                      ),
    .o_riscv_mux3_out(o_riscv_mstage_memload                                    )
  );

  riscv_mux2 u_riscv_muxcsr (
    .i_riscv_mux2_sel(i_riscv_mstage_mux2_sel),
    .i_riscv_mux2_in0(i_riscv_mux2_in0       ),
    .i_riscv_mux2_in1(i_riscv_mux2_in1       ),
    .o_riscv_mux2_out(o_riscv_mstage_mux2_out)
  );

endmodule