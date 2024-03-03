module riscv_data_cache #(
    parameter DATA_WIDTH  = 128                           ,
    parameter CACHE_SIZE  = 64                            ,   //for DV: 4*(2**10) 
    parameter MEM_SIZE    = (CACHE_SIZE)*32               ,   // 
    parameter DATAPBLOCK  = 16                            ,
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK         ,   //  4096
    parameter ADDR        = $clog2(MEM_SIZE)              ,   //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)            ,   //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)           ,   //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX           //    11 bits
  )
  (  
    input   logic         i_riscv_dcache_clk           ,
    input   logic         i_riscv_dcache_rst           ,
    input   logic         i_riscv_dcache_cpu_wren      ,
    input   logic         i_riscv_dcache_cpu_rden      ,
    input   logic [1:0]   i_riscv_dcache_store_src     ,
    input   logic [1:0]   i_riscv_dcache_load_src      ,
    input   logic [63:0]  i_riscv_dcache_phys_addr     ,
    input   logic [63:0]  i_riscv_dcache_cpu_data_in   ,
    output  logic [63:0]  o_riscv_dcache_cpu_data_out  ,
    output  logic         o_riscv_dcache_cpu_stall               
  );

  //****************** internal signals declarations ******************//

  // physical address concatenation
  logic [TAG-1:0]       tag;
  logic [INDEX-1:0]     index;
  logic [BYTE_OFF-1:0]  byte_offset;

  // physical address of the next block (MISALIGNMENT)
  logic [63:0] original_address;      //<-------------MISALIGNMENT
  logic [63:0] misaligned_address;    //<-------------MISALIGNMENT

  logic misaligned;
  
  // fsm signals
  logic fsm_set_dirty;
  logic fsm_set_valid;
  logic fsm_replace_tag;
  logic fsm_cache_wren;
  logic fsm_cache_rden;
  logic fsm_cache_insel;
  logic fsm_cache_outsel;
  logic fsm_addr_sel;     //<-------------MISALIGNMENT
  logic mux_cache_insel;
  logic fsm_mem_wren;
  logic fsm_mem_rden;
  logic fsm_cpu_wren_reg;
  logic fsm_cpu_rden_reg;
  logic fsm_stall;
  logic fsm_tag_sel;

  //  cache signals
  logic [DATA_WIDTH-1:0]  cache_data_in;
  logic [DATA_WIDTH-1:0]  cache_data_out;

  // tag signals
  logic                   tag_dirty_out;
  logic                   tag_hit_out;
  logic                   tag_hit_misaligned_out;
  logic                   tag_dirty_misaligned_out;
  logic [TAG-1:0]         tag_old_out;
  // memory model signals
  logic                   mem_wren;
  logic                   mem_rden;
  logic                   mem_ready;
  logic                   mem_tag;
  logic [INDEX+TAG-1:0]   mem_addr;
  logic [DATA_WIDTH-1:0]  mem_data_in;
  logic [DATA_WIDTH-1:0]  mem_data_out;

  // internal signals declaration  
  assign original_address   = i_riscv_dcache_phys_addr;       //<-------------MISALIGNMENT
  assign misaligned_address = i_riscv_dcache_phys_addr+'d16;  //<-------------MISALIGNMENT

  assign {tag,index,byte_offset} = (fsm_addr_sel)? misaligned_address:original_address; //<-------------MISALIGNMENT

  assign mem_addr                     = (fsm_tag_sel)?{tag_old_out,index}:{tag,index};
  assign cache_data_in                = (fsm_cache_insel)? mem_data_out:{64'b0,i_riscv_dcache_cpu_data_in };
  assign o_riscv_dcache_cpu_data_out  = cache_data_out[63:0];

  //****************** Instantiation ******************//
  tag_array #(
    .IDX          (INDEX)                       ,
    .TAG          (TAG)                         ,
    .CACHE_DEPTH  (CACHE_DEPTH)     
  ) u_tag_array (     
    .clk              (i_riscv_dcache_clk)        ,
    .rst              (i_riscv_dcache_rst)        ,
    .index            (index)                     ,
    .tag_in           (tag)                       ,
    .dirty_in         (fsm_set_dirty)             ,
    .valid_in         (fsm_set_valid)             ,
    .replace_tag      (fsm_replace_tag)           ,
    .hit              (tag_hit_out)               ,
    .dirty            (tag_dirty_out)             ,
    .hit_misaligned   (tag_hit_misaligned_out)    ,
    .dirty_misaligned (tag_dirty_misaligned_out)  ,
    .tag_old          (tag_old_out)
  );

  ///////////////////////////
  data_array #(
    .INDEX        (INDEX),
    .DWIDTH       (DATA_WIDTH),
    .CACHE_DEPTH  (CACHE_DEPTH)
  ) u_data_array (
      .clk        (i_riscv_dcache_clk)          ,    
      .wren       (fsm_cache_wren)              ,
      .rden       (fsm_cache_rden)              ,
      .index      (index)                       ,
      .data_in    (cache_data_in)               ,
      .data_out   (cache_data_out)              ,
      .byte_offset(byte_offset)                 ,
      .storesrc   (i_riscv_dcache_store_src)    ,
      .loadsrc    (i_riscv_dcache_load_src)     ,
      .mem_in     (fsm_cache_insel)             ,
      .mem_out    (fsm_cache_outsel)            
  );

 //////////////
 dram #(
    .AWIDTH     (INDEX+TAG)                     ,
    .DWIDTH     (DATA_WIDTH)                    ,
    .MEM_DEPTH  (MEM_SIZE)        
  ) u_dram (        
    .clk        (i_riscv_dcache_clk)            ,     
    .wren       (fsm_mem_wren)                  ,
    .rden       (fsm_mem_rden)                  ,
    .addr       (mem_addr)                      ,
    .data_in    (cache_data_out)                ,
    .data_out   (mem_data_out)                  ,
    .mem_ready  (mem_ready)
  );

  ////////////////////////
  cache_fsm u_cache_fsm  (
  .clk              (i_riscv_dcache_clk)          ,
  .rst              (i_riscv_dcache_rst)          ,
  .cpu_wren         (i_riscv_dcache_cpu_wren)     ,
  .cpu_rden         (i_riscv_dcache_cpu_rden)     ,
  .hit              (tag_hit_out)                 ,
  .dirty            (tag_dirty_out)               ,
  .hit_misaligned   (tag_hit_misaligned_out)      ,
  .dirty_misaligned (tag_dirty_misaligned_out)    ,
  .mem_ready        (mem_ready)                   ,
  .misaligned       (misaligned)                  , //<-------------MISALIGNMENT
  .cache_rden       (fsm_cache_rden)              ,
  .cache_wren       (fsm_cache_wren)              ,
  .cache_insel      (fsm_cache_insel)             ,
  .cache_outsel     (fsm_cache_outsel)            ,
  .addr_insel       (fsm_addr_sel)                , //<-------------MISALIGNMENT
  .mem_rden         (fsm_mem_rden)                ,
  .mem_wren         (fsm_mem_wren)                ,
  .set_dirty        (fsm_set_dirty)               ,
  .set_valid        (fsm_set_valid)               ,
  .replace_tag      (fsm_replace_tag)             ,
  .stall            (o_riscv_dcache_cpu_stall)    ,
  .cpu_wren_reg     (fsm_cpu_wren_reg)            , //<-------------MISALIGNMENT
  .cpu_rden_reg     (fsm_cpu_rden_reg)            , //<-------------MISALIGNMENT
  .tag_sel          (fsm_tag_sel)
);

cache_misalign #( //<-------------MISALIGNMENT
  .OFFSET(BYTE_OFF)
) u_cache_misalign (
  .wren           (fsm_cpu_wren_reg)            ,
  .stall          (o_riscv_dcache_cpu_stall)    ,
  .rden           (fsm_cpu_rden_reg)            ,
  .load_src       (i_riscv_dcache_load_src)     ,
  .store_src      (i_riscv_dcache_store_src)    ,
  .byte_offset    (byte_offset)                 ,
  .misaligned     (misaligned)
);
endmodule