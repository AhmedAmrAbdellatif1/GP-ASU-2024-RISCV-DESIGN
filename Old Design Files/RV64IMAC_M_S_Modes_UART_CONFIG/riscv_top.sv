module riscv_top #(
  parameter DATA_WIDTH  = 128                    ,
  parameter CACHE_SIZE  = 4*(2**10)              , //64 * (2**10)
  parameter MEM_SIZE    = 4*CACHE_SIZE           , //128*(2**20)
  parameter DMEM_DEPTH  = MEM_SIZE/16            , //128*(2**20)
  parameter DATAPBLOCK  = 16                     ,
  parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK  , //  4096
  parameter ADDR        = $clog2(MEM_SIZE)       , //    27 bits
  parameter BYTE_OFF    = $clog2(DATAPBLOCK)     , //     4 bits
  parameter INDEX       = $clog2(CACHE_DEPTH)    , //    12 bits
  parameter TAG         = ADDR - BYTE_OFF - INDEX, //    11 bits
  parameter KERNEL_PC   = 'h00000000             ,
  parameter S_ADDR      = ADDR - BYTE_OFF        ,
  parameter FIFO_DEPTH  = 256
) (
  input  logic i_riscv_clk                   ,
  input  logic i_riscv_rst                   ,
  input  logic i_riscv_top_external_interrupt,
  output logic o_riscv_top_tx_data
);

  logic riscv_top_external_interrupt_debounced;
  logic riscv_top_external_interrupt_pulse    ;

  /************************** Datapath to IM **************************/
  logic [63:0] riscv_datapath_pc_im;
  /************************** IM to Datapath **************************/
  logic [31:0] riscv_im_inst_datapath;

  /************************** Datapath to DM **************************/
  logic        riscv_datapath_memw_e_dm       ;
  logic        riscv_datapath_memr_e_dm       ;
  logic        riscv_datapath_stall_m_dm      ;
  logic        riscv_datapath_stall_m_im      ;
  logic [ 1:0] riscv_datapath_storesrc_m_dm   ;
  logic [63:0] riscv_datapath_memodata_addr_dm;
  logic [63:0] riscv_datapath_storedata_m_dm  ;
  logic        riscv_datapath_amo_dm          ;
  logic [ 4:0] riscv_datapath_amo_op_dm       ;

  /************************** IM to Datapath **************************/
  logic [63:0] riscv_datapath_rdata_dm;

  /************************** Core to DRAM **************************/
  logic                  core_mem_ready     ;
  logic [DATA_WIDTH-1:0] core_mem_data_out  ;
  logic                  core_fsm_mem_wren  ;
  logic                  core_fsm_mem_rden  ;
  logic [    S_ADDR-1:0] core_mem_addr      ;
  logic [DATA_WIDTH-1:0] core_cache_data_out;

  logic                  core_imem_ready     ;
  logic [DATA_WIDTH-1:0] core_imem_data_out  ;
  logic [DATA_WIDTH-1:0] core_icache_data_out;
  logic [    S_ADDR-1:0] core_imem_addr      ;
  logic                  core_fsm_imem_rden  ;

  /************************** Core to UART **************************/
  logic [ 7:0] core_uart_tx_pdata           ;
  logic        core_uart_tx_valid           ;
  logic [19:0] core_config_baud_divisor     ;
  logic [ 1:0] core_config_parity           ;
  logic        core_config_baud_divisor_wren;
  logic        core_config_parity_wren      ;

  logic [19:0] uart_config_baud_divisor;
  logic        uart_config_parity_en   ;
  logic        uart_config_parity_type ;

  /************************** UART to Core **************************/
  logic uart_tx_fifo_full;
  logic uart_tx_busy     ;

  riscv_core #(
    .KERNEL_PC  (KERNEL_PC  ),
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
  ) u_top_core (
    .i_riscv_core_clk               (i_riscv_clk                       ),
    .i_riscv_core_rst               (riscv_sync_rst                    ),
    .i_riscv_core_external_interrupt(riscv_top_external_interrupt_pulse),
    .i_riscv_core_mem_ready         (core_mem_ready                    ),
    .i_riscv_core_mem_data_out      (core_mem_data_out                 ),
    .i_riscv_core_imem_ready        (core_imem_ready                   ),
    .i_riscv_core_imem_data_out     (core_imem_data_out                ),
    .i_riscv_core_fifo_full         (uart_tx_fifo_full                 ),
    .o_riscv_core_baud_divisor      (core_config_baud_divisor          ),
    .o_riscv_core_baud_divisor_wren (core_config_baud_divisor_wren     ),
    .o_riscv_core_parity            (core_config_parity                ),
    .o_riscv_core_parity_wren       (core_config_parity_wren           ),
    .o_riscv_core_uart_tx_data      (core_uart_tx_pdata                ),
    .o_riscv_core_uart_tx_valid     (core_uart_tx_valid                ),
    .o_riscv_core_imem_addr         (core_imem_addr                    ),
    .o_riscv_core_fsm_imem_rden     (core_fsm_imem_rden                ),
    .o_riscv_core_fsm_mem_wren      (core_fsm_mem_wren                 ),
    .o_riscv_core_fsm_mem_rden      (core_fsm_mem_rden                 ),
    .o_riscv_core_mem_addr          (core_mem_addr                     ),
    .o_riscv_core_cache_data_out    (core_cache_data_out               )
  );

  riscv_dram_model #(
    .DATA_WIDTH (DATA_WIDTH ),
    .CACHE_SIZE (CACHE_SIZE ),
    .MEM_SIZE   (DMEM_DEPTH ),
    .DATAPBLOCK (DATAPBLOCK ),
    .CACHE_DEPTH(CACHE_DEPTH),
    .ADDR       (ADDR       ),
    .BYTE_OFF   (BYTE_OFF   ),
    .INDEX      (INDEX      ),
    .TAG        (TAG        ),
    .S_ADDR     (S_ADDR     )
  ) u_riscv_dram_model (
    .clk      (i_riscv_clk        ),
    .wren     (core_fsm_mem_wren  ),
    .rden     (core_fsm_mem_rden  ),
    .addr     (core_mem_addr      ),
    .data_in  (core_cache_data_out),
    .data_out (core_mem_data_out  ),
    .mem_ready(core_mem_ready     )
  );

  riscv_iram_model #(
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
  ) u_riscv_iram_model (
    .clk      (i_riscv_clk       ),
    .rden     (core_fsm_imem_rden),
    .addr     (core_imem_addr    ),
    .data_out (core_imem_data_out),
    .mem_ready(core_imem_ready   )
  );

  uart_peripheral_top #(.FIFO_DEPTH(FIFO_DEPTH)) uart_peripheral_top_inst (
    .i_uart_clk         (i_riscv_clk             ),
    .i_uart_rst         (riscv_sync_rst          ),
    .i_uart_baud_divisor(uart_config_baud_divisor),
    .i_uart_parity_en   (uart_config_parity_en   ),
    .i_uart_parity_type (uart_config_parity_type ),
    .i_uart_tx_pdata    (core_uart_tx_pdata      ),
    .i_uart_tx_valid    (core_uart_tx_valid      ),
    .o_uart_fifo_full   (uart_tx_fifo_full       ),
    .o_uart_tx_sdata    (o_riscv_top_tx_data     ),
    .o_uart_tx_busy     (uart_tx_busy            )
  );

  riscv_uart_config riscv_uart_config_inst (
    .i_riscv_config_clk              (i_riscv_clk                  ),
    .i_riscv_config_rst              (riscv_sync_rst               ),
    .i_riscv_uart_tx_busy            (uart_tx_busy                 ),
    .i_riscv_config_baud_divisor     (core_config_baud_divisor     ),
    .i_riscv_config_baud_divisor_wren(core_config_baud_divisor_wren),
    .i_riscv_config_parity           (core_config_parity           ),
    .i_riscv_config_parity_wren      (core_config_parity_wren      ),
    .o_riscv_config_baud_divisor     (uart_config_baud_divisor     ),
    .o_riscv_config_parity_en        (uart_config_parity_en        ),
    .o_riscv_config_parity_type      (uart_config_parity_type      )
  );

  riscv_button_debouncer u_riscv_button_debouncer_ext (
    .clk             (i_riscv_clk                           ),
    .rst             (riscv_sync_rst                        ),
    .glitchy_signal  (i_riscv_top_external_interrupt        ),
    .debounced_signal(riscv_top_external_interrupt_debounced)
  );

  uart_pulse_gen u_riscv_ext_int_pulse_gen (
    .i_pulse_gen_clk      (i_riscv_clk                           ),
    .i_pulse_gen_rst      (riscv_sync_rst                        ),
    .i_pulse_gen_lvl_sig  (riscv_top_external_interrupt_debounced),
    .o_pulse_gen_pulse_sig(riscv_top_external_interrupt_pulse    )
  );

  uart_rst_sync u_rst_sync_glob (
    .CLK     (i_riscv_clk   ),
    .RST     (i_riscv_rst   ),
    .SYNC_RST(riscv_sync_rst)
  );

endmodule
