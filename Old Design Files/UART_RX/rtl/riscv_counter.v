module riscv_counter (
  input  wire        incr_en ,
  input  wire        clk, rst,
  input  wire        write_en,
  input  wire [63:0] i_value ,
  output reg [63:0] o_value
);

  always @ (posedge clk or posedge rst)
    begin
      if(rst)
        o_value <= 'b0;
      else if(write_en)
        o_value <= i_value;
      else if(incr_en)
        o_value <= o_value + 1 ;
      else
        o_value <= o_value ;
    end
endmodule

