module riscv_mstage (
  input  logic [63:0] i_riscv_mstage_addr          ,
  input  logic [63:0] i_riscv_mstage_dm_rdata      ,
  input  logic [63:0] i_riscv_mstage_timer_rdata   ,
  input  logic [ 2:0] i_riscv_mstage_load_mux_sel  ,
  input  logic [ 7:0] i_riscv_mstage_switches_upper,
  input  logic [ 7:0] i_riscv_mstage_switches_lower,
  input  logic        i_riscv_mstage_button1       ,
  input  logic        i_riscv_mstage_button2       ,
  input  logic        i_riscv_mstage_button3       ,
  input  logic [ 2:0] i_riscv_mstage_memext        ,
  input  logic        i_riscv_mstage_mux2_sel      ,
  input  logic [63:0] i_riscv_mux2_in0             ,
  input  logic [63:0] i_riscv_mux2_in1             ,
  output logic [63:0] o_riscv_mstage_memload       ,
  output logic [63:0] o_riscv_mstage_mux2_out
);
  logic [63:0] riscv_memext_rddata;

  logic [63:0] riscv_mstage_switches_upper_ext;
  logic [63:0] riscv_mstage_switches_lower_ext;

  assign riscv_mstage_switches_upper_ext = {56'b0,i_riscv_mstage_switches_upper};
  assign riscv_mstage_switches_lower_ext = {56'b0,i_riscv_mstage_switches_lower};

  riscv_memext u_riscv_memext (
    .i_riscv_memext_addr  (i_riscv_mstage_addr    ),
    .i_riscv_memext_sel   (i_riscv_mstage_memext  ),
    .i_riscv_memext_data  (i_riscv_mstage_dm_rdata),
    .o_riscv_memext_loaded(riscv_memext_rddata    )
  );

  riscv_mux8 u_riscv_load_data_mux (
    .i_riscv_mux8_sel(i_riscv_mstage_load_mux_sel    ),
    .i_riscv_mux8_in0(riscv_memext_rddata            ),
    .i_riscv_mux8_in1(i_riscv_mstage_timer_rdata     ),
    .i_riscv_mux8_in2(riscv_mstage_switches_upper_ext),
    .i_riscv_mux8_in3(riscv_mstage_switches_lower_ext),
    .i_riscv_mux8_in4({63'b0,i_riscv_mstage_button1} ),
    .i_riscv_mux8_in5({63'b0,i_riscv_mstage_button2} ),
    .i_riscv_mux8_in6({63'b0,i_riscv_mstage_button3} ),
    .i_riscv_mux8_in7(64'b0                          ),
    .o_riscv_mux8_out(o_riscv_mstage_memload         )
  );

  riscv_mux2 u_riscv_muxcsr (
    .i_riscv_mux2_sel(i_riscv_mstage_mux2_sel),
    .i_riscv_mux2_in0(i_riscv_mux2_in0       ),
    .i_riscv_mux2_in1(i_riscv_mux2_in1       ),
    .o_riscv_mux2_out(o_riscv_mstage_mux2_out)
  );

endmodule