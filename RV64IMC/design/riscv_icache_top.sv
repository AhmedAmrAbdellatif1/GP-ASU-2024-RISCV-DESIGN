//documentation 
// the pc(physical address)is the input and we get the tag and the index to find instructions,
// the missaligned tag and index are related to the next address after the address held by the PC
// after fetching 2 block from instruction array , according to the byte offset the 32-bit instruction is selected to be the output

module riscv_instructions_cache #(
    parameter DATA_WIDTH  = 128                           ,
    parameter MEM_SIZE    = 16*(2**20)                    ,   //128*(2**20)       
    parameter CACHE_SIZE  = 4*(2**10)                     ,   //64 * (2**10)   
    parameter DATAPBLOCK  = 16                            ,
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK         ,   //  4096
    parameter ADDR        = $clog2(MEM_SIZE)              ,   //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)            ,   //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)           ,   //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX           //    11 bits
  )
  (  
    input   logic                 i_riscv_icache_clk           ,
    input   logic                 i_riscv_icache_rst           ,
    input   logic [63:0]          i_riscv_icache_phys_addr     ,
    output  logic [31:0]          o_riscv_icache_cpu_instr_out ,
    output  logic                 o_riscv_icache_cpu_stall               
  );

  //****************** internal signals declarations ******************//

  // physical address concatenation
  logic [TAG-1:0]       tag;
  logic [INDEX-1:0]     index;
  logic [BYTE_OFF-1:0]  byte_offset;

  // fsm signals
  logic fsm_set_valid;
  logic fsm_replace_tag;
  logic fsm_cache_wren;
  logic fsm_cache_rden;
  logic fsm_mem_rden;
  logic fsm_addr_sel;
  logic fsm_valid_align;
  logic fsm_tag_align;

  //  cache signals
  logic [DATA_WIDTH-1:0]  cache_data_in;
  logic [DATA_WIDTH-1:0]  cache_data_out;// connected to o_riscv_icache_cpu_instr_out by case statment 
  logic [DATA_WIDTH-1:0]  cache_data_out_align;
  // tag signals

  logic [TAG-1:0]   tag_missalign;
  logic [INDEX-1:0] index_missallign;
  logic             tag_hit_out;
  logic             tag_missalign_out;

  // memory model signals
  logic                   mem_wren;
  logic                   mem_rden;
  logic                   mem_ready;
  logic                   mem_tag;
  logic [INDEX+TAG-1:0]   mem_addr;
  logic [DATA_WIDTH-1:0]  mem_data_in;
  logic [DATA_WIDTH-1:0]  mem_data_out;
  

  // internal signals declaration  
  assign {tag,index,byte_offset}          = i_riscv_icache_phys_addr;
  assign cache_data_in                    = mem_data_out ;
  assign {tag_missalign,index_missallign} = {tag,index} +1'b1;//input to the other modules to handle the missalignment
  assign mem_addr                         = (fsm_addr_sel)?{tag_missalign,index_missallign}:{tag,index};// for block address selection

  always_comb begin
   case(byte_offset)// the whole block is fetched from instruction array of the indexed and the following index for missalignment 
   // the odd addresses are just in case 
     4'b0000:o_riscv_icache_cpu_instr_out  =  cache_data_out[31:0];
     4'b0001:o_riscv_icache_cpu_instr_out  =  cache_data_out[39:8];
     4'b0010:o_riscv_icache_cpu_instr_out  =  cache_data_out[47:16];
     4'b0011:o_riscv_icache_cpu_instr_out  =  cache_data_out[55:24];
     4'b0100:o_riscv_icache_cpu_instr_out  =  cache_data_out[63:32];
     4'b0101:o_riscv_icache_cpu_instr_out  =  cache_data_out[71:40];
     4'b0110:o_riscv_icache_cpu_instr_out  =  cache_data_out[79:48];
     4'b0111:o_riscv_icache_cpu_instr_out  =  cache_data_out[87:56];
     4'b1000:o_riscv_icache_cpu_instr_out  =  cache_data_out[95:64];
     4'b1001:o_riscv_icache_cpu_instr_out  =  cache_data_out[103:72];
     4'b1010:o_riscv_icache_cpu_instr_out  =  cache_data_out[111:80];
     4'b1011:o_riscv_icache_cpu_instr_out  =  cache_data_out[119:88];
     4'b1100:o_riscv_icache_cpu_instr_out  =  cache_data_out[127:96];
     4'b1101:o_riscv_icache_cpu_instr_out  =  {cache_data_out_align[7:0],cache_data_out[127:104]};
     4'b1110:o_riscv_icache_cpu_instr_out  =  {cache_data_out_align[15:0],cache_data_out[127:112]}; // offest 14 used for missalignment
     4'b1111:o_riscv_icache_cpu_instr_out  =  {cache_data_out_align[23:0],cache_data_out[127:120]};
   endcase
  end
  

  //****************** Instantiation ******************//
  tag_array_i #(
    .IDX          (INDEX)                  ,
    .TAG          (TAG)                    ,
    .CACHE_DEPTH  (CACHE_DEPTH)            ,
    .ADDR         (ADDR)
  ) u_tag_array_i (
    .clk              (i_riscv_icache_clk)      ,
    .tag_missalign    (tag_missalign)           ,
    .index_missallign (index_missallign)        ,
    .index            (index)                   ,
    .tag_in           (tag)                     ,
    .valid_in         (fsm_set_valid)           ,
    .replace_tag      (fsm_replace_tag)         ,
    .hit              (tag_hit_out)             ,
    .hit_missalign    (tag_missalign_out)       ,
    .valid_in_align   (fsm_valid_align)         ,
    .replace_tag_align(fsm_tag_align)
  );

  ///////////////////////////
  riscv_icache_inst #(
    .INDEX        (INDEX),
    .DWIDTH       (DATA_WIDTH),
    .CACHE_DEPTH  (CACHE_DEPTH)
  ) u_icache_inst (
      .clk             (i_riscv_icache_clk)  ,    
      .wren            (fsm_cache_wren)      ,
      .rden            (fsm_cache_rden)      ,
      .index           (index)               ,
      .data_in         (cache_data_in)       ,
      .index_missallign(index_missallign)    ,  
      .index_sel       (fsm_addr_sel)        ,
      .data_out        (cache_data_out)      ,
      .data_out_align  (cache_data_out_align)  
         
  );

 //////////////
 idram #(
    .AWIDTH     (INDEX+TAG)             ,
    .DWIDTH     (DATA_WIDTH)            ,
    .MEM_DEPTH  (MEM_SIZE)
  ) u_dram (
    .clk        (i_riscv_icache_clk)    ,     
    .rden       (fsm_mem_rden)          ,
    .addr       (mem_addr)              ,
    .data_in    (cache_data_out)        ,
    .data_out   (mem_data_out)          ,
    .mem_ready  (mem_ready)
  );

  ////////////////////////
  icache_fsm u_icache_fsm  (
  .clk              (i_riscv_icache_clk)       ,
  .rst              (i_riscv_icache_rst)       ,
  .hit              (tag_hit_out)              ,
  .hit_missalign    (tag_missalign_out)        ,
  .mem_ready        (mem_ready)                ,
  .block_offset     (byte_offset)              ,
  .cache_rden       (fsm_cache_rden)           ,
  .cache_wren       (fsm_cache_wren)           ,
  .mem_rden         (fsm_mem_rden)             ,
  .set_valid        (fsm_set_valid)            ,
  .replace_tag      (fsm_replace_tag)          ,
  .stall            (o_riscv_icache_cpu_stall) ,
  .addr_sel         (fsm_addr_sel)             ,
  .replace_tag_align(fsm_tag_align)            ,
  .set_valid_align  (fsm_valid_align)
  );
endmodule