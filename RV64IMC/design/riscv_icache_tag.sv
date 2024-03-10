// decoumentation 
// use the index to fetch block and compare the tag to test if the block is in the ICACHE or not
// use the tag_missalign and index_missalign for the same reason but these are used when the block is the next block referenced from the indexed address
// the write back of the valid in both indexes is at the negative edge and at replace tage equal 1


module tag_array_i #( 
    parameter IDX         = 12          ,
    parameter TAG         = 9           ,
    parameter CACHE_DEPTH = 4096        ,
    parameter ADDR        = 27
  )
  (
    input   logic           clk               ,
    input   logic           rst               ,
    input   logic [IDX-1:0] index             ,
    input   logic [TAG-1:0] tag_in            ,
    input   logic [TAG-1:0] tag_missalign     , // tag of the following block (used for missalignment)
    input   logic [IDX-1:0] index_missallign  , // index of the following block (used for missalignment)
    input   logic           valid_in          , // valid input of the addressed block to be written by fsm
    input   logic           replace_tag       , // controll the valid input of the addressed block to be written by fsm
    input   logic           valid_in_align    , // same as valid in except that it belongs to the next indexed block written by fsm (used for missalignment)
    input   logic           replace_tag_align , // same as replace tag in except that it belongs to the next indexed block written by fsm (used for missalignment)
    output  logic           hit               , // means the indexed block is found in cache 
    output  logic           hit_missalign       // same as hit but it searching if the next indexed block is found in cache or not (used for missalignment) 

  );

  logic [TAG-1:0]  tag_buffer     [0:CACHE_DEPTH-1];
  logic            valid_buffer   [0:CACHE_DEPTH-1];
  
  

  integer i; 

  always_ff @(negedge clk or posedge rst) begin
    if(rst) begin
      for(i=0;i<CACHE_DEPTH;i=i+1) begin
        valid_buffer[i] <= 'b0; //flushing the valid buffer means cache is empty
      end
    end
    else if (replace_tag) begin
      {valid_buffer[index],tag_buffer[index]} <= {valid_in,tag_in}; // write valid and tag of the fetched block from dram after cache miss
      
    end
    else if (replace_tag_align) begin
     {valid_buffer[index_missallign],tag_buffer[index_missallign]} <= {valid_in_align,tag_missalign}; // write valid and tag of the next indexed block from dram after cache miss

    end
  end

  assign hit           = (valid_buffer[index]) && ((tag_buffer[index]) == tag_in);
  assign hit_missalign = (valid_buffer[index_missallign]) && ((tag_buffer[index_missallign]) == tag_missalign);

endmodule