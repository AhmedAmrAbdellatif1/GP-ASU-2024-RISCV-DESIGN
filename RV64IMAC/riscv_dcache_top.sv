module riscv_data_cache #(
    parameter DATA_WIDTH  = 128                           ,
    parameter CACHE_SIZE  = 4*(2**10)                     ,   //64 * (2**10)   
    parameter MEM_SIZE    = (CACHE_SIZE)*128              ,   //128*(2**20)       
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
    input   logic         i_riscv_dcache_globstall     ,
    input   logic         i_riscv_dcache_cpu_wren      ,
    input   logic         i_riscv_dcache_cpu_rden      ,
    input   logic [1:0]   i_riscv_dcache_store_src     ,
    input   logic [5:0]   i_riscv_dcache_amo_unit_en   ,  //new //amo
    input   logic [63:0]  i_riscv_dcache_phys_addr     ,
    input   logic [63:0]  i_riscv_dcache_cpu_data_in   ,
    output  logic [63:0]  o_riscv_dcache_cpu_data_out  ,
    output  logic         o_riscv_dcache_cpu_stall               
  );

  //****************** internal signals declarations ******************//

  // amo buffer 
  logic [63:0]          cache_data_out_buffer ;

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
  logic mux_cache_insel;
  logic fsm_mem_wren;
  logic fsm_mem_rden;
  logic fsm_stall;
  logic fsm_tag_sel; 
  logic fsm_amo_buffer_en; //new //amo
  logic fsm_amo_unit_en;  //new //amo

  //  cache signals
  logic [DATA_WIDTH-1:0]  cache_data_in;
  logic [DATA_WIDTH-1:0]  cache_data_out;

  // tag signals
  logic           tag_dirty_out;
  logic           tag_hit_out;
  logic [TAG-1:0] tag_old_out;
  // memory model signals
  logic                   mem_wren;
  logic                   mem_rden;
  logic                   mem_ready;
  logic                   mem_tag;
  logic [INDEX+TAG-1:0]   mem_addr;
  logic [DATA_WIDTH-1:0]  mem_data_in;
  logic [DATA_WIDTH-1:0]  mem_data_out;

  // amo unit 
  logic [63:0]            amo_result;

  // internal signals declaration  
  assign {tag,index,byte_offset}      = i_riscv_dcache_phys_addr;
  assign mem_addr                     = (fsm_tag_sel)?{tag_old_out,index}:{tag,index};
  //assign cache_data_in                = (fsm_cache_insel)? mem_data_out:{64'b0,i_riscv_dcache_cpu_data_in };
  assign o_riscv_dcache_cpu_data_out  = (i_riscv_dcache_phys_addr[3])?cache_data_out[127:64]:cache_data_out[63:0];

  //****************** cache data out buffering ******************//
  always_ff @(posedge i_riscv_dcache_clk or posedge i_riscv_dcache_rst) begin 
    if (i_riscv_dcache_rst)
     cache_data_out_buffer <= 'b0 ;
    else if (fsm_amo_buffer_en)
      cache_data_out_buffer <= cache_data_out[63:0] ;
  end

  //****************** cache data in sel ******************//
  always_comb
  begin
    case(fsm_cache_insel)
    2'b00 : cache_data_in = {64'b0,i_riscv_dcache_cpu_data_in } ;
    2'b01 : cache_data_in = mem_data_out ;
    2'b10 : cache_data_in = {64'b0,amo_result };
    endcase 
  end

  //****************** Instantiation ******************//
  riscv_dcache_tag #(
    .IDX          (INDEX)               ,
    .TAG          (TAG)                 ,
    .CACHE_DEPTH  (CACHE_DEPTH)
  ) u_dcache_tag (
    .clk          (i_riscv_dcache_clk)  ,
    .index        (index)               ,
    .tag_in       (tag)                 ,
    .dirty_in     (fsm_set_dirty)       ,
    .valid_in     (fsm_set_valid)       ,
    .replace_tag  (fsm_replace_tag)     ,
    .hit          (tag_hit_out)         ,
    .dirty        (tag_dirty_out)       ,
    .tag_old      (tag_old_out)
  );

  ///////////////////////////
  riscv_dcache_data #(
    .INDEX        (INDEX),
    .DWIDTH       (DATA_WIDTH),
    .CACHE_DEPTH  (CACHE_DEPTH)
  ) u_dcache_data (
      .clk        (i_riscv_dcache_clk)        ,    
      .wren       (fsm_cache_wren)            ,
      .rden       (fsm_cache_rden)            ,
      .index      (index)                     ,
      .data_in    (cache_data_in)             ,
      .data_out   (cache_data_out)            ,
      .byte_offset(byte_offset)               ,
      .storesrc   (i_riscv_dcache_store_src)  ,
      .mem_in     (fsm_cache_insel)      
  );

 //////////////
 dram #(
    .AWIDTH     (INDEX+TAG)             ,
    .DWIDTH     (DATA_WIDTH)            ,
    .MEM_DEPTH  (MEM_SIZE)
  ) u_dram (
    .clk        (i_riscv_dcache_clk)    ,     
    .wren       (fsm_mem_wren)          ,
    .rden       (fsm_mem_rden)          ,
    .addr       (mem_addr)              ,
    .data_in    (cache_data_out)        ,
    .data_out   (mem_data_out)          ,
    .mem_ready  (mem_ready)
  );

  ////////////////////////
  riscv_dcache_fsm u_dcache_fsm  (
  .clk            (i_riscv_dcache_clk)       ,
  .rst            (i_riscv_dcache_rst)       ,
  .cpu_wren       (i_riscv_dcache_cpu_wren)  ,
  .cpu_rden       (i_riscv_dcache_cpu_rden)  ,
  .hit            (tag_hit_out)              ,
  .dirty          (tag_dirty_out)            ,
  .mem_ready      (mem_ready)                ,
  .cache_rden     (fsm_cache_rden)           ,
  .cache_wren     (fsm_cache_wren)           ,
  .cache_insel    (fsm_cache_insel)          ,
  .mem_rden       (fsm_mem_rden)             ,
  .mem_wren       (fsm_mem_wren)             ,
  .set_dirty      (fsm_set_dirty)            ,
  .set_valid      (fsm_set_valid)            ,
  .replace_tag    (fsm_replace_tag)          ,
  .dcache_stall   (o_riscv_dcache_cpu_stall) ,
  .glob_stall     (i_riscv_dcache_globstall) ,
  .tag_sel        (fsm_tag_sel)
);


////////////////////////
riscv_amo_unit u_riscv_amo_unit  (
  .i_riscv_amo_ctrl     (i_riscv_dcache_amo_unit_en),  
  .i_riscv_amo_rs1data  (cache_data_out_buffer),
  .i_riscv_amo_rs2data  (i_riscv_dcache_cpu_data_in),
  .i_riscv_amo_enable   (fsm_amo_unit_en),
  .o_riscv_amo_result   (amo_result)
);

endmodule