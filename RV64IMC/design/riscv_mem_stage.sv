module riscv_mstage (
    input  logic [63:0]  i_riscv_mstage_dm_rdata   ,
    input  logic [2:0]   i_riscv_mstage_memext     ,
    input  logic         i_riscv_mstage_mux2_sel   ,
    input  logic [63:0]  i_riscv_mux2_in0          ,  
    input  logic [63:0]  i_riscv_mux2_in1          ,
    output logic [63:0]  o_riscv_mstage_memload    ,
    output logic [63:0]  o_riscv_mstage_mux2_out
 );
  riscv_memext u_riscv_memext(
    .i_riscv_memext_sel     (i_riscv_mstage_memext)   ,
    .i_riscv_memext_data    (i_riscv_mstage_dm_rdata) ,
    .o_riscv_memext_loaded  (o_riscv_mstage_memload)
  );

  riscv_mux2  u_riscv_mux2 (
    .i_riscv_mux2_sel       (i_riscv_mstage_mux2_sel)  ,
    .i_riscv_mux2_in0       (i_riscv_mux2_in0)         , 
    .i_riscv_mux2_in1       (i_riscv_mux2_in1)         ,
    .o_riscv_mux2_out       (o_riscv_mstage_mux2_out)    
  );
    
endmodule