logic clk,rst;

struct {
  logic [31:0]  hexa;
  logic [4:0]   addr;
  logic [63:0]  data;
} instr ;

 logic regWrite;

  assign regWrite   = DUT.u_top_core.u_top_datapath.u_riscv_mw_ppreg.o_riscv_mw_regw_wb;
  assign instr.hexa = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_inst;
  assign instr.addr = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rdaddr;
  assign instr.data = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;

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