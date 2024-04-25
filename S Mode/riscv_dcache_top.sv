module riscv_data_cache
  #(  
    parameter DATA_WIDTH  = 128                     ,
    parameter CACHE_SIZE  = 4*(2**10)               ,   //64 * (2**10)   
    parameter MEM_SIZE    = 128*(2**20)             ,   //128*(2**20) 
    parameter DATAPBLOCK  = 16                      ,
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK   ,   //  4096
    parameter ADDR        = $clog2(MEM_SIZE)        ,   //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)      ,   //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)     ,   //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX ,  //    11 bits
    parameter S_ADDR      = 23    
  )
  (  
    input   logic                   i_riscv_dcache_clk            ,
    input   logic                   i_riscv_dcache_rst            ,
    input   logic                   i_riscv_dcache_globstall      ,
    input   logic                   i_riscv_dcache_cpu_wren       ,
    input   logic                   i_riscv_dcache_cpu_rden       ,
    input   logic [1:0]             i_riscv_dcache_store_src      ,
    input   logic                   i_riscv_dcache_amo            ,
    input   logic [4:0]             i_riscv_dcache_amo_op         , 
    input   logic [ADDR-1:0]        i_riscv_dcache_phys_addr      ,
    input   logic [63:0]            i_riscv_dcache_cpu_data_in    ,
    input   logic                   i_riscv_dcache_mem_ready      ,
    input   logic [DATA_WIDTH-1:0]  i_riscv_dcache_mem_data_out   ,
    output  logic [DATA_WIDTH-1:0]  o_riscv_dcache_cache_data_out ,
    output  logic [S_ADDR-1:0]      o_riscv_dcache_mem_addr       ,
    output  logic                   o_riscv_dcache_fsm_mem_wren   ,
    output  logic                   o_riscv_dcache_fsm_mem_rden   ,
    output  logic [63:0]            o_riscv_dcache_cpu_data_out   ,
    output  logic                   o_riscv_dcache_cpu_stall               
  );

  //****************** internal signals declaration ******************//
  // amo buffer 
  logic [63:0]            cache_data_out_buffer ;

  // physical address concatenation
  logic [TAG-1:0]         tag                   ;
  logic [INDEX-1:0]       index                 ;
  logic [BYTE_OFF-1:0]    byte_offset           ;
  // fsm signals
  logic                   fsm_set_dirty         ;
  logic                   fsm_set_valid         ;
  logic                   fsm_replace_tag       ;
  logic                   fsm_cache_wren        ;
  logic                   fsm_cache_rden        ;
  logic [1:0]             fsm_cache_insel       ;
  logic                   fsm_tag_sel           ; 
  logic                   fsm_amo_buffer_en     ;
  logic                   fsm_amo_unit_en       ;
  //  cache signals
  logic [DATA_WIDTH-1:0]  cache_data_in         ;
  // tag signals
  logic                   tag_dirty_out         ;
  logic                   tag_hit_out           ;
  logic [TAG-1:0]         tag_old_out           ;
  // amo unit 
  logic [63:0]            amo_result            ;
  logic                   amo_xlen              ;

  //****************** Connections ******************//
  // physical address sectioning
  assign {tag,index,byte_offset}      = i_riscv_dcache_phys_addr;
  // DDR input address
  assign o_riscv_dcache_mem_addr      = (fsm_tag_sel)                 ? {tag_old_out,index}   : {tag,index};
  // AMO Operation xlen
  assign amo_xlen                     = (i_riscv_dcache_store_src == 2'b11)?  1'b1:1'b0;  // 1: doubleword -- 0: word

  //****************** cache data out buffering ******************//
  always_ff @(posedge i_riscv_dcache_clk or posedge i_riscv_dcache_rst) begin 
    if (i_riscv_dcache_rst)
     cache_data_out_buffer <= 'b0 ;
    else if (fsm_amo_buffer_en)
      cache_data_out_buffer <= o_riscv_dcache_cache_data_out[63:0] ;
  end

  //****************** cache data in sel ******************//
  always_comb
  begin
    case(fsm_cache_insel)
    2'b00 : cache_data_in = {64'b0,i_riscv_dcache_cpu_data_in } ;
    2'b01 : cache_data_in = i_riscv_dcache_mem_data_out ;
    2'b10 : cache_data_in = {64'b0,amo_result};
    2'b11 : cache_data_in = 128'b0;
    endcase 
  end

  //****************** cache data out sel ******************//
  always_comb
  begin
    if(i_riscv_dcache_amo)
      o_riscv_dcache_cpu_data_out = cache_data_out_buffer;
    else
      o_riscv_dcache_cpu_data_out  = (i_riscv_dcache_phys_addr[3]) ? o_riscv_dcache_cache_data_out[127:64]: o_riscv_dcache_cache_data_out[63:0];
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
      .clk        (i_riscv_dcache_clk)            ,    
      .wren       (fsm_cache_wren)                ,
      .rden       (fsm_cache_rden)                ,
      .index      (index)                         ,
      .data_in    (cache_data_in)                 ,
      .data_out   (o_riscv_dcache_cache_data_out) ,  
      .byte_offset(byte_offset)                   ,
      .storesrc   (i_riscv_dcache_store_src)      ,
      .mem_in     (fsm_cache_insel[0])      
  );

  ////////////////////////
  riscv_dcache_fsm u_dcache_fsm  (
  .clk            (i_riscv_dcache_clk)       ,
  .rst            (i_riscv_dcache_rst)       ,
  .cpu_wren       (i_riscv_dcache_cpu_wren)  ,
  .cpu_rden       (i_riscv_dcache_cpu_rden)  ,
  .cpu_amoen      (i_riscv_dcache_amo)       ,
  .hit            (tag_hit_out)              ,
  .dirty          (tag_dirty_out)            ,
  .mem_ready      (i_riscv_dcache_mem_ready) ,
  .glob_stall     (i_riscv_dcache_globstall) ,
  .cache_rden     (fsm_cache_rden)           ,
  .cache_wren     (fsm_cache_wren)           ,
  .cache_insel    (fsm_cache_insel)          ,
  .mem_rden       (o_riscv_dcache_fsm_mem_rden)             ,
  .mem_wren       (o_riscv_dcache_fsm_mem_wren)             ,
  .set_dirty      (fsm_set_dirty)            ,
  .set_valid      (fsm_set_valid)            ,
  .replace_tag    (fsm_replace_tag)          ,
  .dcache_stall   (o_riscv_dcache_cpu_stall) ,
  .tag_sel        (fsm_tag_sel)              ,
  .amo_unit_en    (fsm_amo_unit_en)          ,
  .amo_buffer_en  (fsm_amo_buffer_en)
);


////////////////////////
riscv_dcache_amo u_riscv_dcache_amo  (
  .i_riscv_amo_enable   (fsm_amo_unit_en)             ,
  .i_riscv_amo_ctrl     (i_riscv_dcache_amo_op)       ,
  .i_riscv_amo_xlen     (amo_xlen)                    ,  
  .i_riscv_amo_rs1data  (cache_data_out_buffer)       ,
  .i_riscv_amo_rs2data  (i_riscv_dcache_cpu_data_in)  ,
  .o_riscv_amo_result   (amo_result)
);

endmodule