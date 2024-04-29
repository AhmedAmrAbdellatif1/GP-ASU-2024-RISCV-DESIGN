  module riscv_mstage #(parameter width=64)(
  input  logic [width-1:0] i_riscv_mstage_dm_rdata,
   input  logic [2:0]      i_riscv_mstage_memext,
  output logic [width-1:0] o_riscv_mstage_memload
 );
  riscv_memext u_riscv_memext(
    .i_riscv_memext_sel(i_riscv_mstage_memext),
    .i_riscv_memext_data(i_riscv_mstage_dm_rdata),
    .o_riscv_memext_loaded(o_riscv_mstage_memload)
  );    

 
 endmodule



