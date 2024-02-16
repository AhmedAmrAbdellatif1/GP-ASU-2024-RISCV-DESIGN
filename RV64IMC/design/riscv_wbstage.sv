module riscv_wbstage #(parameter width=64) (
input  logic [1:0]         i_riscv_wb_resultsrc,
input  logic [width-1:0]   i_riscv_wb_pcplus4,
input  logic [width-1:0]   i_riscv_wb_result,
input  logic [width-1:0]   i_riscv_wb_memload,
input  logic [width-1:0]   i_riscv_wb_uimm,
output logic [width-1:0]   o_riscv_wb_rddata);

riscv_mux4 u_result_mux (
.i_riscv_mux4_sel(i_riscv_wb_resultsrc),
.i_riscv_mux4_in0(i_riscv_wb_pcplus4),
.i_riscv_mux4_in1(i_riscv_wb_result),
.i_riscv_mux4_in2(i_riscv_wb_memload),
.i_riscv_mux4_in3(i_riscv_wb_uimm),
.o_riscv_mux4_out(o_riscv_wb_rddata));

endmodule