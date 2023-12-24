module riscv_datapath #(parameter width=64) (
input  logic             i_riscv_datapath_clk,
input  logic             i_riscv_datapath_rst,

///////////////////fetch//////////////////
input  logic             i_riscv_datapath_stallpc,
input  logic [31:0]      i_riscv_datapath_inst,      ////output from im
output logic [width-1:0] o_riscv_datapath_pc ,      ////input to im

/////////////////////decode/////////////
input  logic             i_riscv_datapath_regw,     ///output from control 
input  logic [2:0]       i_riscv_datapath_immsrc,   ///output from control 
output logic [6:0]       o_riscv_datapath_opcode,   ///input to control
output logic [2:0]       o_riscv_datapath_func3,   ///input to control
output logic             o_riscv_datapath_func7_5,   ///input to control



);

//////internal fetch////////

logic                 riscv_pcsrc;
logic [width-1:0]     riscv_aluexe;
logic [width-1:0]     riscv_pcplus4;

////////////////internal decode////////
logic [31:0]           riscv_inst;
logic [4:0]            riscv_rdaddr;
logic [width-1:0]      riscv_rddata;
logic [width-1:0]      riscv_rs1data;
logic [width-1:0]      riscv_rs2data;
logic [width-1:0]      riscv_rs1addr;
logic [width-1:0]      riscv_rs2addr;
logic [width-1:0]      riscv_simm;








endmodule


