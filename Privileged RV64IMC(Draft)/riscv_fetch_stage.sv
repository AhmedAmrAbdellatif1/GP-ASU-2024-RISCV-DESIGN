module riscv_fstage #(parameter width=64)(
  input  logic             i_riscv_fstage_clk,
  input  logic             i_riscv_fstage_rst,
  input  logic             i_riscv_fstage_stallpc,
  input  logic             i_riscv_fstage_pcsrc,
  //input  logic             i_riscv_fstage_addermuxsel,
  input  logic [width-1:0] i_riscv_fstage_aluexe,
  input  logic [31:0]    i_riscv_fstage_inst ,  
  output logic [width-1:0] o_riscv_fstage_pc,
  output logic [31:0]         o_riscv_fstage_inst,
  output logic [width-1:0] o_riscv_fstage_pcplus4 ,

  //trap
  
 input logic [1:0] i_riscv_fstage_pcsel,   //[1:0]
  input logic [width-1:0]  i_riscv_fstage_mtval,      //[width-1:0]    //2'b01
  input logic [width-1:0]  i_riscv_fstage_mepc     //[width-1:0]   //2'b10


  );
logic [width-1:0]  o_riscv_fstage_pcmux_trap;  //[width-1:0]
logic [width-1:0] o_riscv_pcmux_nextpc;
logic [width-1:0] riscv_pcadder1_operand;
//logic riscv_fstage_addermuxsel;
logic [width-1:0] riscv_fstage_pc;

///////////////////////////PC MUX//////////////////////
riscv_mux2 u_pcmux (
.i_riscv_mux2_sel(i_riscv_fstage_pcsrc),
.i_riscv_mux2_in0(o_riscv_fstage_pcplus4),
.i_riscv_mux2_in1(i_riscv_fstage_aluexe),
.o_riscv_mux2_out(o_riscv_pcmux_nextpc));

///////////////////////////PC Counter//////////////////////
riscv_pc u_riscv_pc (
.i_riscv_pc_clk(i_riscv_fstage_clk),
.i_riscv_pc_rst(i_riscv_fstage_rst),
.i_riscv_pc_stallpc(i_riscv_fstage_stallpc),
.i_riscv_pc_nextpc(o_riscv_fstage_pcmux_trap),
.o_riscv_pc_pc(o_riscv_fstage_pc));

///////////////////////////PC ADDER//////////////////////
riscv_pcadder u_riscv_pcadder (
.i_riscv_pcadder_size(riscv_pcadder1_operand),
.i_riscv_pcadder_pc(o_riscv_fstage_pc),
.o_riscv_pcadder_pcplussize(o_riscv_fstage_pcplus4));
///////////////////////////PC ADDER MUX//////////////////////
riscv_mux2 u_pcmuxadder(
.i_riscv_mux2_sel(riscv_fstage_addermuxsel),
.i_riscv_mux2_in0(64'd4),
.i_riscv_mux2_in1(64'd2),
.o_riscv_mux2_out(riscv_pcadder1_operand));
///////////////////////////COMPRESSED DECODER//////////////////////
riscv_compressed_decoder u_top_cdecoder(
.i_riscv_cdecoder_inst(i_riscv_fstage_inst),
.o_riscv_cdecoder_inst(o_riscv_fstage_inst),
.o_riscv_cdecoder_compressed(riscv_fstage_addermuxsel)

);


riscv_mux3 u_pcmuxfortrap (
  .i_riscv_mux3_sel(i_riscv_fstage_pcsel),   //[1:0]
  .i_riscv_mux3_in0(o_riscv_pcmux_nextpc),   //   //2'b00
  .i_riscv_mux3_in1(i_riscv_fstage_mtval),   //    //2'b01
  .i_riscv_mux3_in2(i_riscv_fstage_mepc),   //  //2'b10
  .o_riscv_mux3_out(o_riscv_fstage_pcmux_trap)  //[width-1:0]   //to IM
 );
endmodule 

