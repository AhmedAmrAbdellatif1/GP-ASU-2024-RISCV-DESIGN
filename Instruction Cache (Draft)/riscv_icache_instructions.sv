//decoumentation
// the whole block is read cobinationally and same for the block after the indexed one and the output 32_bit instruction is determinded by 
//--the byte offset and missalignment at top module
//index_sel=0: the block is written at the real index
//index_sel=1: the block is written at the following index for missalignment
module instructions_array #(
    parameter INDEX       = 12,
    parameter DWIDTH      = 128,
    parameter IWIDTH      = 32,
    parameter CACHE_DEPTH = 4096,
    parameter BYTE_OFFSET = 4
  )
  (
    input   logic                    clk                     ,     
    input   logic                    wren                    ,// input from ram
    input   logic                    rden                    ,// for cpu out
    input   logic [INDEX-1:0]        index                   ,
    input   logic [INDEX-1:0]        index_missallign        ,// index of the following block (used for missalignment)
    input   logic                    index_sel               , // used to identify the written block from ram to cache is the addressed one or the one after it for alignment
    input   logic [DWIDTH-1:0]       data_in                 ,
    output  logic [DWIDTH-1:0]       data_out                ,//total block and word selection done in top module 
    output  logic [DWIDTH-1:0]       data_out_align           // the block of the following index (used for missalignment)  
  );

  logic [DWIDTH-1:0] icache [0:CACHE_DEPTH-1];

  always_ff @(negedge clk) begin
    if(wren && !index_sel) begin
      //index_sel=0: the block is written at the real index
      icache[index] <= data_in; //for total block at cache miss
    
    end
    else if(wren && index_sel) begin
    //index_sel=1: the block is written at the following index
      icache[index_missallign] <= data_in;
    
    end
  end
  // instruction read output
  assign data_out      = icache[index];
  assign data_out_align=icache[index_missallign];
  

endmodule