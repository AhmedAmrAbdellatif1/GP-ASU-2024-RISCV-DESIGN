module riscv_mstage (
  input  wire [63:0]  i_riscv_mstage_addr        ,
  input  wire [63:0]  i_riscv_mstage_dm_rdata    ,
  input  wire [63:0]  i_riscv_mstage_timer_rdata ,
  input  wire         i_riscv_mstage_timer_rden  ,
  input  wire [2:0]   i_riscv_mstage_memext      ,
  input  wire         i_riscv_mstage_mux2_sel    ,
  input  wire [63:0]  i_riscv_mux2_in0           ,  
  input  wire [63:0]  i_riscv_mux2_in1           ,
  output wire [63:0]  o_riscv_mstage_memload     ,
  output wire [63:0]  o_riscv_mstage_mux2_out
 );

  wire [63:0]  riscv_memext_rddata;

  riscv_memext u_riscv_memext(
    .i_riscv_memext_addr    (i_riscv_mstage_addr)     ,
    .i_riscv_memext_sel     (i_riscv_mstage_memext)   ,
    .i_riscv_memext_data    (i_riscv_mstage_dm_rdata) ,
    .o_riscv_memext_loaded  (riscv_memext_rddata)
  );

  riscv_mux2  u_riscv_memloadmux (
    .i_riscv_mux2_sel       (i_riscv_mstage_timer_rden)  ,
    .i_riscv_mux2_in0       (riscv_memext_rddata)        , 
    .i_riscv_mux2_in1       (i_riscv_mstage_timer_rdata) ,
    .o_riscv_mux2_out       (o_riscv_mstage_memload)    
  );

  riscv_mux2  u_riscv_muxcsr (
    .i_riscv_mux2_sel       (i_riscv_mstage_mux2_sel)  ,
    .i_riscv_mux2_in0       (i_riscv_mux2_in0)         , 
    .i_riscv_mux2_in1       (i_riscv_mux2_in1)         ,
    .o_riscv_mux2_out       (o_riscv_mstage_mux2_out)    
  );
    
endmodule