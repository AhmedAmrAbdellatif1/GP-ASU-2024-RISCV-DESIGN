
module riscv_dram_model
  #(  
    parameter DATA_WIDTH  = 128                     ,
    parameter CACHE_SIZE  = 4*(2**10)               , //64 * (2**10)   
    parameter MEM_SIZE    = 4*CACHE_SIZE            , //128*(2**20) 
    parameter DATAPBLOCK  = 16                      ,
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK   , //  4096
    parameter ADDR        = $clog2(MEM_SIZE)        , //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)      , //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)     , //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX , //    11 bits
    parameter S_ADDR      = ADDR - BYTE_OFF
  )
  (
    input   wire                   clk       ,
    input   wire                   wren      ,
    input   wire                   rden      ,
    input   wire [S_ADDR-1:0]      addr      ,
    input   wire [DATA_WIDTH-1:0]  data_in   ,
    output  wire [DATA_WIDTH-1:0]  data_out  ,
    output  wire                   mem_ready
    );

    riscv_dram_data  #(
      .DATA_WIDTH   (DATA_WIDTH)  ,
      .CACHE_SIZE   (CACHE_SIZE)  ,
      .MEM_SIZE     (MEM_SIZE)    ,
      .DATAPBLOCK   (DATAPBLOCK)  ,
      .CACHE_DEPTH  (CACHE_DEPTH) ,
      .ADDR         (ADDR)        ,
      .BYTE_OFF     (BYTE_OFF)    ,
      .INDEX        (INDEX)       ,
      .TAG          (TAG)         ,
      .S_ADDR       (S_ADDR)
    ) u_riscv_dram_data (
      .clk      (clk)     ,
      .wren     (wren)    ,
      .rden     (rden)    ,
      .addr     (addr)    ,
      .data_in  (data_in) ,
      .data_out (data_out)
    );

    riscv_dram_counter  u_riscv_dram_counter (
      .clk        (clk)       ,
      .wren       (wren)      ,
      .rden       (rden)      ,
      .mem_ready  (mem_ready)
    );

endmodule