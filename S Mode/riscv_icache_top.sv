module riscv_instructions_cache 
  import my_pkg::*;
  (
    input   logic                   i_riscv_icache_clk            ,
    input   logic                   i_riscv_icache_rst            ,
    input   logic [63:0]            i_riscv_icache_phys_addr      ,
    input   logic                   i_riscv_icache_mem_ready      ,
    input   logic [DATA_WIDTH-1:0]  i_riscv_icache_mem_data_out   ,
    output  logic [DATA_WIDTH-1:0]  o_riscv_icache_cache_data_out ,
    output  logic [S_ADDR-1:0]      o_riscv_icache_mem_addr       ,
    output  logic                   o_riscv_icache_fsm_mem_rden   ,
    output  logic [31:0]            o_riscv_icache_cpu_instr_out  ,
    output  logic                   o_riscv_icache_cpu_stall
  );

  //****************** internal signals declarations ******************//

  // physical address concatenation
  logic [     TAG-1:0] tag        ;
  logic [   INDEX-1:0] index      ;
  logic [BYTE_OFF-1:0] byte_offset;

  // fsm signals
  logic fsm_set_valid  ;
  logic fsm_replace_tag;
  logic fsm_cache_wren ;
  logic fsm_addr_sel   ;
  logic fsm_valid_align;
  logic fsm_tag_align  ;

  //  cache signals
  logic [DATA_WIDTH-1:0] cache_data_in       ;
  logic [DATA_WIDTH-1:0] cache_data_out_align;
  // tag signals

  logic [  TAG-1:0] tag_missalign    ;
  logic [INDEX-1:0] index_missallign ;
  logic             tag_hit_out      ;
  logic             tag_missalign_out;

  // memory model signals
  logic                  mem_wren    ;
  logic                  mem_rden    ;
  logic                  mem_tag     ;
  logic [DATA_WIDTH-1:0] mem_data_in ;


  // internal signals declaration
  assign {tag,index,byte_offset}          = i_riscv_icache_phys_addr;
  assign cache_data_in                    = i_riscv_icache_mem_data_out ;
  assign {tag_missalign,index_missallign} = {tag,index} +1'b1;
  assign o_riscv_icache_mem_addr          = (fsm_addr_sel)?{tag_missalign,index_missallign}:{tag,index};

  always_comb begin
    case(byte_offset)// the whole block is fetched from instruction array of the indexed and the following index for missalignment
      // the odd addresses are just in case
      4'b0000 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[31:0];
      4'b0001 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[39:8];
      4'b0010 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[47:16];
      4'b0011 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[55:24];
      4'b0100 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[63:32];
      4'b0101 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[71:40];
      4'b0110 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[79:48];
      4'b0111 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[87:56];
      4'b1000 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[95:64];
      4'b1001 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[103:72];
      4'b1010 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[111:80];
      4'b1011 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[119:88];
      4'b1100 : o_riscv_icache_cpu_instr_out  =  o_riscv_icache_cache_data_out[127:96];
      4'b1101 : o_riscv_icache_cpu_instr_out  =  {cache_data_out_align[7:0],o_riscv_icache_cache_data_out[127:104]};
      4'b1110 : o_riscv_icache_cpu_instr_out  =  {cache_data_out_align[15:0],o_riscv_icache_cache_data_out[127:112]}; // offest 14 used for missalignment
      4'b1111 : o_riscv_icache_cpu_instr_out  =  {cache_data_out_align[23:0],o_riscv_icache_cache_data_out[127:120]};
    endcase
  end


  //****************** Instantiation ******************//
  tag_array_i #(
    .IDX        (INDEX      ),
    .TAG        (TAG        ),
    .CACHE_DEPTH(CACHE_DEPTH),
    .ADDR       (ADDR       )
  ) u_tag_array_i (
    .clk              (i_riscv_icache_clk ),
    .tag_missalign    (tag_missalign      ),
    .index_missallign (index_missallign   ),
    .index            (index              ),
    .tag_in           (tag                ),
    .valid_in         (fsm_set_valid      ),
    .replace_tag      (fsm_replace_tag    ),
    .hit              (tag_hit_out        ),
    .hit_missalign    (tag_missalign_out  ),
    .valid_in_align   (fsm_valid_align    ),
    .replace_tag_align(fsm_tag_align      )
  );

  ///////////////////////////
  riscv_icache_inst #(
    .INDEX      (INDEX      ),
    .DWIDTH     (DATA_WIDTH ),
    .CACHE_DEPTH(CACHE_DEPTH)
  ) u_icache_inst (
    .clk              (i_riscv_icache_clk             )  ,
    .wren             (fsm_cache_wren                 )  ,
    .index            (index                          )  ,
    .data_in          (cache_data_in                  )  ,
    .index_missallign (index_missallign               )  ,
    .index_sel        (fsm_addr_sel                   )  ,
    .data_out         (o_riscv_icache_cache_data_out  ),
    .data_out_align   (cache_data_out_align           )  
  );


  ////////////////////////
  icache_fsm u_icache_fsm (
    .clk              (i_riscv_icache_clk           ),
    .rst              (i_riscv_icache_rst           ),
    .hit              (tag_hit_out                  ),
    .hit_missalign    (tag_missalign_out            ),
    .mem_ready        (i_riscv_icache_mem_ready     ),
    .block_offset     (byte_offset                  ),
    .cache_wren       (fsm_cache_wren               ),
    .mem_rden         (o_riscv_icache_fsm_mem_rden  ),
    .set_valid        (fsm_set_valid                ),
    .replace_tag      (fsm_replace_tag              ),
    .stall            (o_riscv_icache_cpu_stall     ),
    .addr_sel         (fsm_addr_sel                 ),
    .replace_tag_align(fsm_tag_align                ),
    .set_valid_align  (fsm_valid_align              )
  );
  
endmodule