module riscv_top (
  input  logic        i_riscv_clk                   ,
  input  logic        i_riscv_rst                   ,
  input  logic        i_riscv_top_external_interrupt,
  input  logic [ 7:0] i_riscv_top_switches_upper    ,
  input  logic [ 7:0] i_riscv_top_switches_lower    ,
  input  logic        i_riscv_top_button1           ,
  input  logic        i_riscv_top_button2           ,
  input  logic        i_riscv_top_button3           ,
  output logic        o_riscv_top_anode             ,
  output logic [ 6:0] o_riscv_top_segment           ,
  output logic [15:0] o_riscv_top_leds              ,
  output logic        o_riscv_top_tx_data
);

  parameter    DATA_WIDTH   = 128                    ;
  parameter    CACHE_SIZE   = 4*(2**10)              ; //64 * (2**10)
  parameter    MEM_SIZE     = 4*CACHE_SIZE           ; //128*(2**20)
  parameter    DMEM_DEPTH   = MEM_SIZE/16            ; //128*(2**20)
  parameter    DATAPBLOCK   = 16                     ;
  parameter    CACHE_DEPTH  = CACHE_SIZE/DATAPBLOCK  ; //  4096
  parameter    ADDR         = $clog2(MEM_SIZE)       ; //    27 bits
  parameter    BYTE_OFF     = $clog2(DATAPBLOCK)     ; //     4 bits
  parameter    INDEX        = $clog2(CACHE_DEPTH)    ; //    12 bits
  parameter    TAG          = ADDR - BYTE_OFF - INDEX; //    11 bits
  parameter    KERNEL_PC    = 'h00000000             ;
  parameter    S_ADDR       = ADDR - BYTE_OFF        ;
  parameter    FIFO_DEPTH   = 256                    ;
  parameter logic [19:0] BAUD_DIVISOR = 6945                   ;
  parameter logic [ 0:0] PAR_EN       = 1                      ;
  parameter logic [ 0:0] PAR_TYPE     = 0                      ;

  logic riscv_top_external_interrupt_debounced;
  logic riscv_rst_sync                        ;

  logic riscv_clk;

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

  /************************** Core to Peripheral **************************/
  logic [ 7:0] core_uart_tx_pdata           ;
  logic        core_uart_tx_valid           ;
  logic [63:0] riscv_core_top_storedata_m_dm;


  /************************** Peripheral to Core **************************/
  logic       uart_tx_fifo_full               ;
  logic       uart_tx_busy                    ;
  logic [7:0] riscv_top_switches_core_upper   ;
  logic [7:0] riscv_top_switches_core_lower   ;
  logic       riscv_top_button1_debounced     ;
  logic       riscv_top_button2_debounced     ;
  logic       riscv_top_button3_debounced     ;
  logic       riscv_top_button1_core_debounced;
  logic       riscv_top_button2_core_debounced;
  logic       riscv_top_button3_core_debounced;
  logic       riscv_top_segment_en            ;
  logic       riscv_top_leds_en               ;

  assign o_riscv_top_anode = 1'b0;

  clk_wiz_0 clk_wiz_0 (
    // Clock out ports
    .clk_out1(riscv_clk  ), // output clk_out1
    // Status and control signals
    .reset   (i_riscv_rst), // input reset
    // Clock in ports
    .clk_in1 (i_riscv_clk)
  );

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
    .i_riscv_core_clk               (riscv_clk                             ),
    .i_riscv_core_rst               (riscv_rst_sync                        ),
    .i_riscv_core_external_interrupt(riscv_top_external_interrupt_debounced),
    .i_riscv_core_mem_ready         (core_mem_ready                        ),
    .i_riscv_core_mem_data_out      (core_mem_data_out                     ),
    .i_riscv_core_imem_ready        (core_imem_ready                       ),
    .i_riscv_core_imem_data_out     (core_imem_data_out                    ),
    .i_riscv_core_fifo_full         (uart_tx_fifo_full                     ),
    .i_riscv_core_switches_upper    (riscv_top_switches_core_upper         ),
    .i_riscv_core_switches_lower    (riscv_top_switches_core_lower         ),
    .i_riscv_core_button1           (riscv_top_button1_core_debounced      ),
    .i_riscv_core_button2           (riscv_top_button2_core_debounced      ),
    .i_riscv_core_button3           (riscv_top_button3_core_debounced      ),
    .o_riscv_core_uart_tx_data      (core_uart_tx_pdata                    ),
    .o_riscv_core_uart_tx_valid     (core_uart_tx_valid                    ),
    .o_riscv_core_imem_addr         (core_imem_addr                        ),
    .o_riscv_core_fsm_imem_rden     (core_fsm_imem_rden                    ),
    .o_riscv_core_fsm_mem_wren      (core_fsm_mem_wren                     ),
    .o_riscv_core_fsm_mem_rden      (core_fsm_mem_rden                     ),
    .o_riscv_core_mem_addr          (core_mem_addr                         ),
    .o_riscv_core_cache_data_out    (core_cache_data_out                   ),
    .o_riscv_core_storedata_m_dm    (riscv_core_top_storedata_m_dm         ),
    .o_riscv_core_seg_en            (riscv_top_segment_en                  ),
    .o_riscv_core_led_en            (riscv_top_leds_en                     )
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
    .clk      (riscv_clk          ),
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
    .clk      (riscv_clk         ),
    .rden     (core_fsm_imem_rden),
    .addr     (core_imem_addr    ),
    .data_out (core_imem_data_out),
    .mem_ready(core_imem_ready   )
  );

  uart_peripheral_top #(
    .FIFO_DEPTH  (FIFO_DEPTH  ),
    .BAUD_DIVISOR(BAUD_DIVISOR),
    .PAR_EN      (PAR_EN      ),
    .PAR_TYPE    (PAR_TYPE    )
  ) uart_peripheral_top_inst (
    .i_uart_clk      (riscv_clk          ),
    .i_uart_rst_n    (~riscv_rst_sync    ),
    .i_uart_tx_pdata (core_uart_tx_pdata ),
    .i_uart_tx_valid (core_uart_tx_valid ),
    .o_uart_fifo_full(uart_tx_fifo_full  ),
    .o_uart_tx_sdata (o_riscv_top_tx_data),
    .o_uart_tx_busy  (uart_tx_busy       )
  );

  riscv_button_debouncer u_riscv_rst_debouncer (
    .clk      (riscv_clk                             ),
    .reset    (riscv_rst_sync                        ),
    .noisy    (i_riscv_top_external_interrupt        ),
    .debounced(riscv_top_external_interrupt_debounced)
  );

  riscv_rst_sync riscv_rst_sync_inst (
    .CLK     (riscv_clk     ),
    .RST     (i_riscv_rst   ),
    .SYNC_RST(riscv_rst_sync)
  );

  riscv_dff #(.N(8)) u_riscv_switches_upper (
    .clk(riscv_clk                    ),
    .rst(i_riscv_rst                  ),
    .D  (i_riscv_top_switches_upper   ),
    .Q  (riscv_top_switches_core_upper)
  );

  riscv_dff #(.N(8)) u_riscv_switches_lower (
    .clk(riscv_clk                    ),
    .rst(i_riscv_rst                  ),
    .D  (i_riscv_top_switches_lower   ),
    .Q  (riscv_top_switches_core_lower)
  );

  riscv_button_debouncer u_riscv_button_1_debouncer (
    .clk      (riscv_clk                  ),
    .reset    (riscv_rst_sync             ),
    .noisy    (i_riscv_top_button1        ),
    .debounced(riscv_top_button1_debounced)
  );

  riscv_dff #(.N(1)) u_riscv_button_1 (
    .clk(riscv_clk                       ),
    .rst(i_riscv_rst                     ),
    .D  (riscv_top_button1_debounced     ),
    .Q  (riscv_top_button1_core_debounced)
  );

  riscv_button_debouncer u_riscv_button_2_debouncer (
    .clk      (riscv_clk                  ),
    .reset    (riscv_rst_sync             ),
    .noisy    (i_riscv_top_button2        ),
    .debounced(riscv_top_button2_debounced)
  );
  riscv_dff #(.N(1)) u_riscv_button_2 (
    .clk(riscv_clk                       ),
    .rst(i_riscv_rst                     ),
    .D  (riscv_top_button2_debounced     ),
    .Q  (riscv_top_button2_core_debounced)
  );

  riscv_button_debouncer u_riscv_button_3_debouncer (
    .clk      (riscv_clk                  ),
    .reset    (riscv_rst_sync             ),
    .noisy    (i_riscv_top_button3        ),
    .debounced(riscv_top_button3_debounced)
  );

  riscv_dff #(.N(1)) u_riscv_button_3 (
    .clk(riscv_clk                       ),
    .rst(i_riscv_rst                     ),
    .D  (riscv_top_button3_debounced     ),
    .Q  (riscv_top_button3_core_debounced)
  );

  riscv_segment riscv_segment_inst (
    .i_riscv_segment_clk    (riscv_clk                    ),
    .i_riscv_segment_rst    (i_riscv_rst                  ),
    .i_riscv_segment_en     (riscv_top_segment_en         ),
    .i_riscv_segment_cathode(riscv_core_top_storedata_m_dm),
    .o_riscv_segment_cathode(o_riscv_top_segment          )
  );


  riscv_dff_en #(.N(16)) u_riscv_leds (
    .clk(riscv_clk                          ),
    .rst(i_riscv_rst                        ),
    .en (riscv_top_leds_en                  ),
    .D  (riscv_core_top_storedata_m_dm[15:0]),
    .Q  (o_riscv_top_leds                   )
  );

endmodule