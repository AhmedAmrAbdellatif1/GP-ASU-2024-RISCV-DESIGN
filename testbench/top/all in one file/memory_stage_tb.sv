   logic [63:0] data;
   logic [2:0] memext;
   logic [63:0] memload;
   logic       memwrite;
   logic [1:0]  storesrc;
   logic [63:0] data_addr;
   logic [63:0] store_data;

  integer m;
     
    assign memload = DUT.u_top_datapath.uriscv_mstage.o_riscv_mstage_memload;
    assign memext = DUT.u_top_datapath.uriscv_mstage.i_riscv_mstage_memext;
    assign data = DUT.u_top_datapath.uriscv_mstage.i_riscv_mstage_dm_rdata;
    assign storesrc = DUT.riscv_datapath_storesrc_m_dm;
    assign memwrite = DUT.riscv_datapath_memw_m_dm;
    assign data_addr = DUT.riscv_datapath_memodata_addr_dm;
    assign store_data = DUT.riscv_datapath_storedata_m_dm;
/********************* Initial Blocks *********************/
  initial begin : proc_mem
  #(3*CLK_PERIOD);
 #CLK_PERIOD;
CheckEquality("auipc x6, 0x100 memwrite", memwrite, 0);
#CLK_PERIOD;
CheckEquality("addi x8, x0, 10 memwrite", memwrite, 0);

#CLK_PERIOD;
CheckEquality("addi x9, x0, 20 memwrite", memwrite, 0);

#CLK_PERIOD;
CheckEquality("sd x6, 0(x0) data", data, 0);
CheckEquality("sd x6, 0(x0) memext", memext, 0);
CheckEquality("sd x6, 0(x0) memload", memload, 0);
CheckEquality("sd x6, 0(x0) memwrite", memwrite, 1);
CheckEquality("sd x6, 0(x0) storesrc", storesrc, 'b11);
CheckEquality("sd x6, 0(x0) data_addr", data_addr, 0);
CheckEquality("sd x6, 0(x0) store_data", store_data, 'h100000);

#CLK_PERIOD;
CheckEquality("ld x7, 0(x0) memext", memext,'b011);
CheckEquality("ld x7, 0(x0) memload", memload, 'h100000);
CheckEquality("ld x7, 0(x0) memwrite", memwrite, 0);
CheckEquality("ld x7, 0(x0) data_addr", data_addr, 0);


#CLK_PERIOD;

CheckEquality("add x10, x8, x9 memwrite", memwrite, 0);

#CLK_PERIOD;

CheckEquality("lui x5, 0x20000 memwrite", memwrite, 0);

#CLK_PERIOD;

CheckEquality("addiw x4, x0, 18 memwrite", memwrite, 0);

#CLK_PERIOD;

CheckEquality("sltu x3, x8, x9 memwrite", memwrite, 0);

#CLK_PERIOD;

CheckEquality("bne x6, x7, -20 memwrite", memwrite, 0);

  end

/******************** Tasks & Functions *******************/
task CheckEquality(string signal_name, logic [63:0] A, logic [63:0] B);
    if (A !== B)
      begin
      $display("%s Failure", signal_name);
      end
endtask