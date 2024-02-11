module riscv_top (
input i_riscv_clk,
input i_riscv_rst
);

////////////////////////signals from datapath to IM/////////////////////////
logic [63:0] riscv_datapath_pc_im;
////////////////////////signals from im to datapath/////////////////////////
logic [31:0] riscv_im_inst_datapath;

///////////////////////signals from datapath to DM/////////////////////////
logic        riscv_datapath_memw_m_dm;
logic [1:0]  riscv_datapath_storesrc_m_dm;
logic [63:0] riscv_datapath_memodata_addr_dm;
logic [63:0] riscv_datapath_storedata_m_dm;

////////////////////////signals from im to datapath/////////////////////////
logic [63:0] riscv_datapath_rdata_dm;


riscv_core u_top_core(
     .i_riscv_core_inst(riscv_im_inst_datapath),
     .i_riscv_core_clk(i_riscv_clk),
     .i_riscv_core_rst(i_riscv_rst),
     .i_riscv_core_rdata(riscv_datapath_rdata_dm),
     .o_riscv_core_pc(riscv_datapath_pc_im),
     .o_riscv_core_memw_m(riscv_datapath_memw_m_dm),
     .o_riscv_core_storesrc_m(riscv_datapath_storesrc_m_dm),
     .o_riscv_core_memodata_addr(riscv_datapath_memodata_addr_dm),
     .o_riscv_core_storedata_m(riscv_datapath_storedata_m_dm)
);
riscv_dm u_top_dm(
  .i_riscv_dm_clk_n(!i_riscv_clk),
  .i_riscv_dm_rst(i_riscv_rst),
  .i_riscv_dm_wen(riscv_datapath_memw_m_dm),
  .i_riscv_dm_sel(riscv_datapath_storesrc_m_dm),
  .i_riscv_dm_wdata(riscv_datapath_storedata_m_dm),
  .i_riscv_dm_waddr(riscv_datapath_memodata_addr_dm),
  .o_riscv_dm_rdata(riscv_datapath_rdata_dm)
);

riscv_im u_top_im(
  .i_riscv_im_pc(riscv_datapath_pc_im),
  .o_riscv_im_inst(riscv_im_inst_datapath)
);
endmodule