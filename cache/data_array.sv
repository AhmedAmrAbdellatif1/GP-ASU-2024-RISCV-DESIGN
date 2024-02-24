module data_array #(
    parameter INDEX       = 12,
    parameter DWIDTH      = 128,
    parameter CACHE_DEPTH = 4096
  )
  (
    input   logic                   clk                     ,
    //input   logic                   rst                     ,      
    input   logic                   wren                    ,
    input   logic                   rden                    ,
    input   logic [INDEX-1:0]       index                   ,
    input   logic [DWIDTH-1:0]      data_in                 ,
    output  logic [DWIDTH-1:0]      data_out                
  );

  logic [DWIDTH-1:0] dcache [0:CACHE_DEPTH-1];

  always_ff @(negedge clk) begin
    if(wren && !rden) begin
      dcache[index] <= data_in;
    end
  end
  
  assign data_out = dcache[index];

endmodule