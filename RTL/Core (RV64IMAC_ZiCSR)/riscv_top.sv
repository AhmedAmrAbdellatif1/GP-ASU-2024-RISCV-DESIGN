module riscv_top (
  input logic i_riscv_clk,
  input logic i_riscv_rst
);

  parameter DATA_WIDTH  = 128                    ;
  parameter CACHE_SIZE  = 64*(2**10)             ; //64 * (2**10)
  parameter MEM_SIZE    = 128*CACHE_SIZE         ; //128*(2**20)
  parameter DMEM_DEPTH  = MEM_SIZE/16            ; //128*(2**20)
  parameter DATAPBLOCK  = 16                     ;
  parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK  ; //  4096
  parameter ADDR        = $clog2(MEM_SIZE)       ; //    27 bits
  parameter BYTE_OFF    = $clog2(DATAPBLOCK)     ; //     4 bits
  parameter INDEX       = $clog2(CACHE_DEPTH)    ; //    12 bits
  parameter TAG         = ADDR - BYTE_OFF - INDEX; //    11 bits
  parameter KERNEL_PC   = 'h80000062             ;
  parameter S_ADDR      = ADDR - BYTE_OFF        ;
  parameter FIFO_DEPTH  = 256                    ;
  parameter bit       TESTING     = 1                      ;

  logic riscv_clk;

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

  generate;
    if (TESTING) begin : gen_tb_clock
      assign riscv_clk = i_riscv_clk;
    end
    else begin : gen_clk_wiz_clock
      clk_wiz_0 clk_wiz_0 (
        // Clock out ports
        .clk_out1(riscv_clk  ), // output clk_out1
        // Status and control signals
        .reset   (i_riscv_rst), // input reset
        // Clock in ports
        .clk_in1 (i_riscv_clk)
      );
    end
  endgenerate


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
    .i_riscv_core_clk               (riscv_clk),
    .i_riscv_core_rst               (i_riscv_rst),
    .i_riscv_core_external_interrupt('b0),
    .i_riscv_core_mem_ready         (core_mem_ready),
    .i_riscv_core_mem_data_out      (core_mem_data_out),
    .i_riscv_core_imem_ready        (core_imem_ready),
    .i_riscv_core_imem_data_out     (core_imem_data_out),
    .i_riscv_core_fifo_full         ('b0),
    .i_riscv_core_switches_upper    ('b0),
    .i_riscv_core_switches_lower    ('b0),
    .i_riscv_core_button1           ('b0),
    .i_riscv_core_button2           ('b0),
    .i_riscv_core_button3           ('b0),
    .o_riscv_core_uart_tx_data      (),
    .o_riscv_core_uart_tx_valid     (),
    .o_riscv_core_imem_addr         (core_imem_addr),
    .o_riscv_core_fsm_imem_rden     (core_fsm_imem_rden),
    .o_riscv_core_fsm_mem_wren      (core_fsm_mem_wren),
    .o_riscv_core_fsm_mem_rden      (core_fsm_mem_rden),
    .o_riscv_core_mem_addr          (core_mem_addr),
    .o_riscv_core_cache_data_out    (core_cache_data_out),
    .o_riscv_core_storedata_m_dm    (),
    .o_riscv_core_seg_en            (),
    .o_riscv_core_led_en            ()
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

endmodule