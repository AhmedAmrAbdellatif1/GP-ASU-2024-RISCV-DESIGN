module riscv_core #(
  parameter MXLEN       = 64                     ,
  parameter DATA_WIDTH  = 128                    ,
  parameter CACHE_SIZE  = 4*(2**10)              , //64 * (2**10)
  parameter MEM_SIZE    = 128*(2**20)            , //128*(2**20)
  parameter DATAPBLOCK  = 16                     ,
  parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK  , //  4096
  parameter ADDR        = $clog2(MEM_SIZE)       , //    27 bits
  parameter BYTE_OFF    = $clog2(DATAPBLOCK)     , //     4 bits
  parameter INDEX       = $clog2(CACHE_DEPTH)    , //    12 bits
  parameter TAG         = ADDR - BYTE_OFF - INDEX, //    11 bits
  parameter KERNEL_PC   = 'h80000000             ,
  parameter S_ADDR      = ADDR - BYTE_OFF
) (
  input  logic                  i_riscv_core_clk               ,
  input  logic                  i_riscv_core_rst               ,
  input  logic                  i_riscv_core_external_interrupt,
  input  logic                  i_riscv_core_mem_ready         ,
  input  logic                  i_riscv_core_imem_ready        ,
  input  logic [DATA_WIDTH-1:0] i_riscv_core_mem_data_out      ,
  input  logic [DATA_WIDTH-1:0] i_riscv_core_imem_data_out     ,
  input  logic                  i_riscv_core_fifo_full         ,
  output logic [           7:0] o_riscv_core_uart_tx_data      ,
  output logic                  o_riscv_core_uart_tx_valid     ,
  output logic [DATA_WIDTH-1:0] o_riscv_core_cache_data_out    ,
  output logic [    S_ADDR-1:0] o_riscv_core_imem_addr         ,
  output logic [    S_ADDR-1:0] o_riscv_core_mem_addr          ,
  output logic                  o_riscv_core_fsm_imem_rden     ,
  output logic                  o_riscv_core_fsm_mem_wren      ,
  output logic                  o_riscv_core_fsm_mem_rden
);


  /************************ Datapath to CU ************************/
  logic        riscv_datapath_stall_m_dm;
  logic [63:0] riscv_datapath_rdata_dm  ;

  /************************ Datapath & Hazard Unit ************************/
  logic [4:0] riscv_datapath_rdaddr_m_hzrdu ;
  logic       riscv_datapath_globstall_hzrdu;

  /************************ Data Cache Signals ************************/
  logic        riscv_datapath_memw_e_dm       ;
  logic        riscv_datapath_memr_e_dm       ;
  logic [ 1:0] riscv_datapath_storesrc_m_dm   ;
  logic        riscv_datapath_amo_dm          ;
  logic [ 4:0] riscv_datapath_amo_op_dm       ;
  logic [63:0] riscv_datapath_memodata_addr_dm;
  logic [63:0] riscv_datapath_storedata_m_dm  ;

  /************************ Instruction Cache Signals ************************/
  logic [63:0] riscv_datapath_pc_im     ;
  logic [31:0] riscv_im_inst_datapath   ;
  logic        riscv_datapath_stall_m_im;

  /************************ Timer Interrupts ************************/
  logic        riscv_datapath_timer_wren  ;
  logic        riscv_datapath_timer_rden  ;
  logic [ 1:0] riscv_datapath_timer_regsel;
  logic [63:0] riscv_timer_datapath_rdata ;
  logic [63:0] riscv_timer_datapath_time  ;

  /************************* ************** *************************/
  /************************* Instantiations *************************/
  /************************* ************** *************************/

  assign o_riscv_core_uart_tx_data = riscv_datapath_storedata_m_dm[7:0];

  riscv_datapath u_riscv_datapath (
    .i_riscv_datapath_clk            (i_riscv_core_clk               ),
    .i_riscv_datapath_rst            (i_riscv_core_rst               ),
    .o_riscv_datapath_pc             (riscv_datapath_pc_im           ),
    .i_riscv_datapath_inst           (riscv_im_inst_datapath         ),
    .i_riscv_datapath_dm_rdata       (riscv_datapath_rdata_dm        ),
    .o_riscv_datapath_rdaddr_m       (riscv_datapath_rdaddr_m_hzrdu  ),
    .o_riscv_datapath_memw_e         (riscv_datapath_memw_e_dm       ),
    .o_riscv_datapath_memr_e         (riscv_datapath_memr_e_dm       ),
    .o_riscv_datapath_amo            (riscv_datapath_amo_dm          ),
    .o_riscv_datapath_amo_op         (riscv_datapath_amo_op_dm       ),
    .o_riscv_datapath_storesrc_m     (riscv_datapath_storesrc_m_dm   ),
    .o_riscv_datapath_memodata_addr  (riscv_datapath_memodata_addr_dm),
    .o_riscv_datapath_storedata_m    (riscv_datapath_storedata_m_dm  ),
    .i_riscv_datapath_icache_stall_wb(riscv_datapath_stall_m_im      ),
    .i_riscv_datapath_stall_dm       (riscv_datapath_stall_m_dm      ),
    .i_riscv_datapath_stall_im       (riscv_datapath_stall_m_im      ),
    .o_riscv_datapath_hzrdu_globstall(riscv_datapath_globstall_hzrdu ),
    .i_riscv_core_timer_interrupt    (riscv_core_timer_interrupt     ),
    .i_riscv_core_external_interrupt (i_riscv_core_external_interrupt),
    .i_riscv_timer_datapath_rdata    (riscv_timer_datapath_rdata     ),
    .i_riscv_timer_datapath_time     (riscv_timer_datapath_time      ),
    .o_riscv_datapath_timer_wren     (riscv_datapath_timer_wren      ),
    .o_riscv_datapath_timer_rden     (riscv_datapath_timer_rden      ),
    .o_riscv_datapath_timer_regsel   (riscv_datapath_timer_regsel    ),
    .i_riscv_datapath_fifo_full      (i_riscv_core_fifo_full         ),
    .o_riscv_datapath_uart_tx_valid  (o_riscv_core_uart_tx_valid     )
  );

  riscv_data_cache #(
    .DATA_WIDTH (DATA_WIDTH ),
    .CACHE_SIZE (CACHE_SIZE ),
    .MEM_SIZE   (MEM_SIZE   ),
    .DATAPBLOCK (DATAPBLOCK ),
    .CACHE_DEPTH(CACHE_DEPTH),
    .ADDR       (ADDR       ),
    .BYTE_OFF   (BYTE_OFF   ),
    .INDEX      (INDEX      ),
    .TAG        (TAG        ),
    .S_ADDR     (S_ADDR     )
  ) u_data_cache (
    .i_riscv_dcache_clk           (i_riscv_core_clk                         ),
    .i_riscv_dcache_rst           (i_riscv_core_rst                         ),
    .i_riscv_dcache_globstall     (riscv_datapath_globstall_hzrdu           ),
    .i_riscv_dcache_cpu_wren      (riscv_datapath_memw_e_dm                 ),
    .i_riscv_dcache_cpu_rden      (riscv_datapath_memr_e_dm                 ),
    .i_riscv_dcache_store_src     (riscv_datapath_storesrc_m_dm             ),
    .i_riscv_dcache_amo           (riscv_datapath_amo_dm                    ),
    .i_riscv_dcache_amo_op        (riscv_datapath_amo_op_dm                 ),
    .i_riscv_dcache_phys_addr     (riscv_datapath_memodata_addr_dm[ADDR-1:0]),
    .i_riscv_dcache_cpu_data_in   (riscv_datapath_storedata_m_dm            ),
    .i_riscv_dcache_mem_ready     (i_riscv_core_mem_ready                   ),
    .i_riscv_dcache_mem_data_out  (i_riscv_core_mem_data_out                ),
    .o_riscv_dcache_fsm_mem_wren  (o_riscv_core_fsm_mem_wren                ),
    .o_riscv_dcache_fsm_mem_rden  (o_riscv_core_fsm_mem_rden                ),
    .o_riscv_dcache_mem_addr      (o_riscv_core_mem_addr                    ),
    .o_riscv_dcache_cache_data_out(o_riscv_core_cache_data_out              ),
    .o_riscv_dcache_cpu_data_out  (riscv_datapath_rdata_dm                  ),
    .o_riscv_dcache_cpu_stall     (riscv_datapath_stall_m_dm                )
  );

  riscv_instructions_cache #(
    .DATA_WIDTH (DATA_WIDTH ),
    .CACHE_SIZE (CACHE_SIZE ),
    .MEM_SIZE   (MEM_SIZE   ),
    .DATAPBLOCK (DATAPBLOCK ),
    .CACHE_DEPTH(CACHE_DEPTH),
    .ADDR       (ADDR       ),
    .BYTE_OFF   (BYTE_OFF   ),
    .INDEX      (INDEX      ),
    .TAG        (TAG        ),
    .S_ADDR     (S_ADDR     )
  ) u_inst_cache (
    .i_riscv_icache_clk          (i_riscv_core_clk                ),
    .i_riscv_icache_rst          (i_riscv_core_rst                ),
    .i_riscv_icache_phys_addr    ((riscv_datapath_pc_im-KERNEL_PC)),
    .i_riscv_icache_mem_ready    (i_riscv_core_imem_ready         ),
    .i_riscv_icache_mem_data_out (i_riscv_core_imem_data_out      ),
    .o_riscv_icache_mem_addr     (o_riscv_core_imem_addr          ),
    .o_riscv_icache_fsm_mem_rden (o_riscv_core_fsm_imem_rden      ),
    .o_riscv_icache_cpu_instr_out(riscv_im_inst_datapath          ),
    .o_riscv_icache_cpu_stall    (riscv_datapath_stall_m_im       )
  );

  riscv_timer_irq u_riscv_timer_irq (
    .i_riscv_timer_clk   (i_riscv_core_clk             ),
    .i_riscv_timer_rst   (i_riscv_core_rst             ),
    .i_riscv_timer_wren  (riscv_datapath_timer_wren    ),
    .i_riscv_timer_rden  (riscv_datapath_timer_rden    ),
    .i_riscv_timer_regsel(riscv_datapath_timer_regsel  ),
    .i_riscv_timer_wdata (riscv_datapath_storedata_m_dm),
    .o_riscv_timer_rdata (riscv_timer_datapath_rdata   ),
    .o_riscv_timer_time  (riscv_timer_datapath_time    ),
    .o_riscv_timer_irq   (riscv_core_timer_interrupt   )
  );

endmodule