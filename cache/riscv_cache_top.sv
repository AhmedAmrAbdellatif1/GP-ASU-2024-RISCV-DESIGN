module data_cache_top #(
    parameter DATA_WIDTH  = 128                           ,
    parameter MEM_SIZE    = (2**6)*16                     ,   //128*(2**20)       
    parameter CACHE_SIZE  = 64                            ,   //64 * (2**10)   
    parameter DATAPBLOCK  = 16                            ,
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK         ,   //  4096
    parameter ADDR        = $clog2(MEM_SIZE)              ,   //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)            ,   //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)           ,   //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX           //    11 bits
  )
  (  
    input   logic         clk           ,
    input   logic         rst           ,
    input   logic         cpu_wren      ,
    input   logic         cpu_rden      ,
    input   logic [1:0]   store_src     ,
    input   logic [63:0]  phys_addr     ,
    input   logic [63:0]  cpu_data_in   ,
    output  logic [63:0]  cpu_data_out  ,
    output  logic         cpu_stall               
  );

  //****************** internal signals declarations ******************//

  // physical address concatenation
  logic [TAG-1:0]       tag;
  logic [INDEX-1:0]     index;
  logic [BYTE_OFF-1:0]  byte_offset;

  // fsm signals
  logic fsm_set_dirty;
  logic fsm_set_valid;
  logic fsm_replace_tag;
  logic fsm_cache_wren;
  logic fsm_cache_rden;
  logic fsm_cache_insel;
  logic fsm_mem_wren;
  logic fsm_mem_rden;
  logic fsm_stall;
  logic fsm_tag_sel;//new

  //  cache signals
  logic [DATA_WIDTH-1:0]  cache_data_in;
  logic [DATA_WIDTH-1:0]  cache_data_out;

  // tag signals
  logic           tag_dirty_out;
  logic           tag_hit_out;
  logic [TAG-1:0] tag_old_out;//new
  // memory model signals
  logic                   mem_wren;
  logic                   mem_rden;
  logic                   mem_ready;
  logic                   mem_tag;
  logic [INDEX+TAG-1:0]   mem_addr;
  logic [DATA_WIDTH-1:0]  mem_data_in;
  logic [DATA_WIDTH-1:0]  mem_data_out;

  // internal signals declaration  
  assign cache_data_in           = (fsm_cache_insel)? mem_data_out:{64'b0,cpu_data_in};
  assign {tag,index,byte_offset} = phys_addr;
  assign mem_addr                = (fsm_tag_sel)?{tag_old_out,index}:{tag,index};///new
  assign cpu_data_out            = (phys_addr[3])?cache_data_out[127:64]:cache_data_out[63:0];

  //****************** Instantiation ******************//
  tag_array #(
    .IDX          (INDEX)               ,
    .TAG          (TAG)                 ,
    .CACHE_DEPTH  (CACHE_DEPTH)
  ) u_tag_array (
    .clk          (clk)                 ,
    .rst          (rst)                 ,
    .index        (index)               ,
    .tag_in       (tag)                 ,
    .dirty_in     (fsm_set_dirty)       ,
    .valid_in     (fsm_set_valid)       ,
    .replace_tag  (fsm_replace_tag)     ,
    .hit          (tag_hit_out)         ,
    .dirty        (tag_dirty_out)       ,
    .tag_old      (tag_old_out)//new
  );

  ///////////////////////////
  data_array #(
    .INDEX        (INDEX),
    .DWIDTH       (DATA_WIDTH),
    .CACHE_DEPTH  (CACHE_DEPTH)
  ) u_data_array (
      .clk        (clk)                  ,    
      .wren       (fsm_cache_wren)       ,
      .rden       (fsm_cache_rden)       ,
      .index      (index)                ,
      .data_in    (cache_data_in)        ,
      .data_out   (cache_data_out)       ,
      .byte_offset(byte_offset)          ,
      .storesrc   (storesrc)             ,
      .mem_in     (cache_insel)      
  );

 //////////////
 dram #(
    .AWIDTH     (INDEX+TAG)             ,
    .DWIDTH     (DATA_WIDTH)            ,
    .MEM_DEPTH  (MEM_SIZE)
  ) u_dram (
    .clk        (clk)                   ,     
    .wren       (fsm_mem_wren)          ,
    .rden       (fsm_mem_rden)          ,
    .addr       (mem_addr)              ,
    .data_in    (cache_data_out)        ,
    .data_out   (mem_data_out)          ,
    .mem_ready  (mem_ready)
  );

  ////////////////////////
  cache_fsm u_cache_fsm  (
  .clk            (clk)                 ,
  .rst            (rst)                 ,
  .cpu_wren       (cpu_wren)            ,
  .cpu_rden       (cpu_rden)            ,
  .hit            (tag_hit_out)         ,
  .dirty          (tag_dirty_out)       ,
  .mem_ready      (mem_ready)           ,
  .cache_rden     (fsm_cache_rden)      ,
  .cache_wren     (fsm_cache_wren)      ,
  .cache_insel    (fsm_cache_insel)     ,
  .mem_rden       (fsm_mem_rden)        ,
  .mem_wren       (fsm_mem_wren)        ,
  .set_dirty      (fsm_set_dirty)       ,
  .set_valid      (fsm_set_valid)       ,
  .replace_tag    (fsm_replace_tag)     ,
  .stall          (cpu_stall)           ,
  .tag_sel        (fsm_tag_sel)//new
);
endmodule