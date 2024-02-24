module tag_array #( 
    parameter IDX         = 12          ,
    parameter TAG         = 9           ,
    parameter CACHE_DEPTH = 4096        
  )
  (
    input   logic           clk         ,
    input   logic           rst         ,
    input   logic [IDX-1:0] index       ,
    input   logic [TAG-1:0] tag_in      ,
    input   logic           dirty_in    ,
    input   logic           valid_in    ,
    input   logic           replace_tag ,
    output  logic           hit         ,
    output  logic           dirty       
  );

  logic [TAG-1:0] tag_buffer   [0:CACHE_DEPTH-1];
  logic           valid_buffer [0:CACHE_DEPTH-1];
  logic           dirty_buffer [0:CACHE_DEPTH-1];

  int i;

  always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i=0;i<CACHE_DEPTH;i++) begin
        valid_buffer[i] <= 'b0;
      end
    end
    else if (replace_tag) begin
      {valid_buffer[index],tag_buffer[index],dirty_buffer[index]} <= {valid_in,tag_in,dirty_in};
    end
  end

  assign dirty = dirty_buffer[index];
  assign hit   = (valid_buffer[index]) && ((tag_buffer[index]) == tag_in);

endmodule