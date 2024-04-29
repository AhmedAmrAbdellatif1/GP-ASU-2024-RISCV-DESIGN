module riscv_dcache_tag #( 
    parameter IDX         = 12          ,
    parameter TAG         = 9           ,
    parameter CACHE_DEPTH = 4096        
  )
  (
    input   wire           clk         ,   //  negative edge clock signal
    input   wire [IDX-1:0] index       ,   //  input index
    input   wire [TAG-1:0] tag_in      ,   //  input tag to be compared or to replace the old tag
    input   wire           dirty_in    ,   //  input set dirty signal
    input   wire           valid_in    ,   //  input set valid signal
    input   wire           replace_tag ,   //  input replace enable signal
    output  wire           hit         ,   //  output hit signal
    output  wire           dirty       ,   //  output dirty signal
    output  wire [TAG-1:0] tag_old         //  output old tag stored given input index
  );

  // distributed RAM blocks
  reg [TAG-1:0] tag_buffer   [0:CACHE_DEPTH-1];
  reg           valid_buffer [0:CACHE_DEPTH-1];
  reg           dirty_buffer [0:CACHE_DEPTH-1];

  // initialize the RAM
  integer i;
  initial begin
    for(i=0;i<CACHE_DEPTH;i=i+1) begin
      tag_buffer  [i] <= 'b0;
      valid_buffer[i] <= 'b0;
      dirty_buffer[i] <= 'b0;
    end
  end

  // negative edge synchronous write
  always @(negedge clk) begin
    if (replace_tag) begin
      valid_buffer[index] <= valid_in;
      tag_buffer  [index] <= tag_in;
      dirty_buffer[index] <= dirty_in;
    end
  end

  // FSM asynchronous flags 
  assign dirty   = dirty_buffer[index];
  assign hit     = (valid_buffer[index]) && ((tag_buffer[index]) == tag_in);
  assign tag_old = tag_buffer[index];

endmodule