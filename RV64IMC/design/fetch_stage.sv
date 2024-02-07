module riscv_fstage #(parameter width=64)(
  input  logic             i_riscv_fstage_clk,
  input  logic             i_riscv_fstage_rst,
  input  logic             i_riscv_fstage_stallpc,
  input  logic             i_riscv_fstage_pcsrc,
  input  logic             i_riscv_fstage_addermuxsel,
  input  logic [width-1:0] i_riscv_fstage_aluexe,
  output logic [width-1:0] o_riscv_fstage_pc,
  //output logic [width-1:0] o_riscv_fstage_inst,
  output logic [width-1:0] o_riscv_fstage_pcplus4
  );

logic [width-1:0] o_riscv_pcmux_nextpc;
logic [width-1:0] riscv_pcadder1_operand;

///////////////////////////PC MUX//////////////////////
riscv_mux2 u_pcmux(
.i_riscv_mux2_sel(i_riscv_fstage_pcsrc),
.i_riscv_mux2_in0(o_riscv_fstage_pcplus4),
.i_riscv_mux2_in1(i_riscv_fstage_aluexe),
.o_riscv_mux2_out(o_riscv_pcmux_nextpc));

///////////////////////////PC Counter//////////////////////
riscv_pc u_riscv_pc (
.i_riscv_pc_clk(i_riscv_fstage_clk),
.i_riscv_pc_rst(i_riscv_fstage_rst),
.i_riscv_pc_stallpc(i_riscv_fstage_stallpc),
.i_riscv_pc_nextpc(o_riscv_pcmux_nextpc),
.o_riscv_pc_pc(o_riscv_fstage_pc));

///////////////////////////PC ADDER//////////////////////
riscv_pcadder u_riscv_pcadder (
.i_riscv_pcadder_size(riscv_pcadder1_operand),
.i_riscv_pcadder_pc(o_riscv_fstage_pc),
.o_riscv_pcadder_pcplussize(o_riscv_fstage_pcplus4));
///////////////////////////PC ADDER MUX//////////////////////
riscv_mux2 u_pcmuxadder(
.i_riscv_mux2_sel(i_riscv_fstage_addermuxsel),
.i_riscv_mux2_in0(64'd4),
.i_riscv_mux2_in1(64'd2),
.o_riscv_mux2_out(riscv_pcadder1_operand));

endmodule