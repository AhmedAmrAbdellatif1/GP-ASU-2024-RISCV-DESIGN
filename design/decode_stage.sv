module  riscv_dstage #(parameter width=64) (
input logic                       i_riscv_dstage_clk_n,
input logic                       i_riscv_dstage_rst,
input logic                       i_riscv_dstage_regw,
input logic [2:0]                 i_riscv_dstage_immsrc,
input logic [31:0]                i_riscv_dstage_inst, 
input logic [4:0]                 i_riscv_dstage_rdaddr,
input logic [width-1:0]           i_riscv_dstage_rddata,

output logic [width-1:0]          o_riscv_dstage_rs1data,  
output logic [width-1:0]          o_riscv_dstage_rs2data,  
output logic [4:0]                o_riscv_dstage_rs1addr,  
output logic [4:0]                o_riscv_dstage_rs2addr,  
output logic [4:0]                o_riscv_dstage_rdaddr,   
output logic [width-1:0]          o_riscv_dstage_simm,
output logic [6:0]                o_riscv_dstage_opcode,
output logic [2:0]                o_riscv_dstage_funct3,    
output logic                      o_riscv_dstage_func7_5); 



assign o_riscv_dstage_rs1addr=i_riscv_dstage_inst[19:15];
assign o_riscv_dstage_rs2addr=i_riscv_dstage_inst[24:20];
assign o_riscv_dstage_rdaddr=i_riscv_dstage_inst[11:7];
assign func_7_5= i_riscv_dstage_inst[30];
assign func_3= i_riscv_dstage_inst[14:12];
assign op_code= i_riscv_dstage_inst[6:0];




///////////////////////////// RF////////////////////////
riscv_rf u_riscv_rf(
.i_riscv_rf_clk_n(i_riscv_dstage_clk_n),
.i_riscv_rf_rst(i_riscv_dstage_rst),
.i_riscv_rf_regwrite(i_riscv_dstage_regw),
.i_riscv_rf_rs1addr(i_riscv_dstage_inst[19:15]),
.i_riscv_rf_rs2addr(i_riscv_dstage_inst[24:20]),
.i_riscv_rf_rdaddr(i_riscv_dstage_rdaddr),
.i_riscv_rf_rddata(i_riscv_dstage_rddata),
.o_riscv_rf_rs1data(o_riscv_dstage_rs1data),
.o_riscv_rf_rs2data(o_riscv_dstage_rs2data));



//////////////////////////extension unit////////////////
riscv_extend u_riscv_extend(
.i_riscv_extend_immsrc(i_riscv_dstage_immsrc),
.i_riscv_extend_inst(i_riscv_dstage_inst[31:7]),
.o_riscv_extend_simm(o_riscv_dstage_simm));


endmodule