parameter CLK_PERIOD = 50;
parameter HALF_PERIOD = CLK_PERIOD/2;
logic clk,rst;
int i;

struct {
  logic [31:0]  hexa;
  logic [15:0]  c;
  logic [6:0]   op;
  logic [4:0]   gpr;
  logic [63:0]  rd;
  logic [63:0]  pc;
  logic [63:0]  store;
  logic [63:0]  load;
  logic [63:0]  memaddr;
  logic [14:12] funct3;
} instr ;

 logic regWrite;
 logic stall;

  assign regWrite       = DUT.u_top_core.u_top_datapath.u_riscv_mw_ppreg.o_riscv_mw_regw_wb;
  assign stall          = DUT.u_top_core.u_top_hzrdu.glob_stall;
  assign instr.hexa     = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_inst;
  assign instr.c        = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_cinst;
  assign instr.gpr      = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rdaddr;
  assign instr.rd       = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;
  assign instr.load     = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;
  assign instr.pc       = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_pc;
  assign instr.memaddr  = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_memaddr;
  assign instr.op       = instr.hexa[6:0];
  assign instr.funct3   = instr.hexa[14:12];

/** Reseting Block **/
initial begin : proc_reseting
  rst = 1'b1;
  #1step;
  rst = 1'b0;
end

/** Clock Generation Block **/
initial begin : proc_clock
  clk = 1'b0;
  forever begin
    #HALF_PERIOD clk = ~clk;
  end
end

/** Stored Data FF **/
always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    instr.store <= 'b0;
  end
  else if(!stall)begin
    case(DUT.u_data_cache.u_dcache_data.storesrc)
      2'b00: instr.store <= DUT.u_data_cache.u_dcache_data.strdouble[7:0];
      2'b01: instr.store <= DUT.u_data_cache.u_dcache_data.strdouble[15:0];
      2'b10: instr.store <= DUT.u_data_cache.u_dcache_data.strdouble[31:0];
      2'b11: instr.store <= DUT.u_data_cache.u_dcache_data.strdouble[63:0];
    endcase
  end
end

/******************** DUT Instantiation *******************/
  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );