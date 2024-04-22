module riscv_top
  import icache_pkg::*;
  import dcache_pkg::*;
  (
    input logic i_riscv_clk,
    input logic i_riscv_rst
  );

  /************************** Datapath to IM **************************/
  logic [63:0] riscv_datapath_pc_im;
  /************************** IM to Datapath **************************/
  logic [31:0] riscv_im_inst_datapath;

  /************************** Datapath to DM **************************/
  logic        riscv_datapath_memw_e_dm;
  logic        riscv_datapath_memr_e_dm;
  logic        riscv_datapath_stall_m_dm;
  logic        riscv_datapath_stall_m_im;
  logic [1:0]  riscv_datapath_storesrc_m_dm;
  logic [63:0] riscv_datapath_memodata_addr_dm;
  logic [63:0] riscv_datapath_storedata_m_dm;
  logic        riscv_datapath_amo_dm;
  logic [4:0]  riscv_datapath_amo_op_dm;

  /************************** IM to Datapath **************************/
  logic [63:0] riscv_datapath_rdata_dm;

  /************************** Core to DRAM **************************/
  logic                   core_mem_ready      ;
  logic [DATA_WIDTH-1:0]  core_mem_data_out   ;
  logic                   core_fsm_mem_wren   ;
  logic                   core_fsm_mem_rden   ;
  logic [INDEX+TAG-1:0]   core_mem_addr       ;
  logic [DATA_WIDTH-1:0]  core_cache_data_out ;

  logic               core_imem_ready       ;
  logic [IDWIDTH-1:0] core_imem_data_out    ;
  logic [IDWIDTH-1:0] core_icache_data_out  ;
  logic [IAWIDTH-1:0] core_imem_addr        ;
  logic               core_fsm_imem_rden    ;

  riscv_core u_top_core(
    .i_riscv_core_clk               (i_riscv_clk)               ,
    .i_riscv_core_rst               (i_riscv_rst)               ,
    .i_riscv_core_external_interrupt  ()                          , 
    .i_riscv_core_mem_ready         (core_mem_ready)            ,
    .i_riscv_core_mem_data_out      (core_mem_data_out)         ,
    .i_riscv_core_imem_ready        (core_imem_ready     )      ,
    .i_riscv_core_imem_data_out     (core_imem_data_out  )      ,
    .o_riscv_core_icache_data_out   (core_icache_data_out)      ,
    .o_riscv_core_imem_addr         (core_imem_addr      )      ,
    .o_riscv_core_fsm_imem_rden     (core_fsm_imem_rden  )      ,
    .o_riscv_core_fsm_mem_wren      (core_fsm_mem_wren)         ,
    .o_riscv_core_fsm_mem_rden      (core_fsm_mem_rden)         ,
    .o_riscv_core_mem_addr          (core_mem_addr)             ,  
    .o_riscv_core_cache_data_out    (core_cache_data_out)         
  );

  //----------------------------------------------->
  riscv_dram_model u_riscv_dram_model (
    .clk        (i_riscv_clk)         ,  
    .wren       (core_fsm_mem_wren)   ,
    .rden       (core_fsm_mem_rden)   ,
    .addr       (core_mem_addr)       ,
    .data_in    (core_cache_data_out) ,
    .data_out   (core_mem_data_out)   ,
    .mem_ready  (core_mem_ready)
  );

  riscv_iram_model u_riscv_iram_model (
    .clk        (i_riscv_clk)            ,
    .rden       (core_fsm_imem_rden   )  ,
    .addr       (core_imem_addr       )  ,
    .data_in    (core_icache_data_out )  ,
    .data_out   (core_imem_data_out   )  ,
    .mem_ready  (core_imem_ready      )
  );
  //----------------------------------------------->

endmodule