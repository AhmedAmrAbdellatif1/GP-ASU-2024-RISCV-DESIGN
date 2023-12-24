  module riscv_mstage #(parameter width=64)(
  input  logic [width-1:0] i_riscv_mstage_dm_rdata,
   input  logic [2:0]  i_riscv_mstage_memext,
  output logic [width-1:0] o_riscv_mstage_memload
  /*// input  logic             i_riscv_mstage_fw_mem
  input   logic [width-1:0]   i_riscv_mstage_storedata
  input   logic [width-1:0]   i_riscv_mstage_memload_w
  output  logic [width-1:0]   o_riscv_mstage_writedata_mem*/
 );

  riscv_memext u_riscv_memext(
    .i_riscv_memext_sel(i_riscv_mstage_memext),
    .i_riscv_memext_data(i_riscv_mstage_dm_rdata),
    .o_riscv_memext_loaded(o_riscv_mstage_memload)
  );    

 
 /*riscv_mux2 u_Writedata_mux(
.i_riscv_mux2_sel(i_riscv_mstage_fw_mem),
.i_riscv_mux2_in0(i_riscv_mstage_storedata),
.i_riscv_mux2_in1(i_riscv_mstage_memload_w),
.o_riscv_mux2_out(o_riscv_mstage_writedata_mem));
*/
 endmodule



