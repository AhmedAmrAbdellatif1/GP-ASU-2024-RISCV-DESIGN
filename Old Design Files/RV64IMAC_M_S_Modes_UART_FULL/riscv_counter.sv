module riscv_counter (
  input  logic        incr_en ,
  input  logic        clk, rst,
  input  logic        write_en,
  input  logic [63:0] i_value ,
  output logic [63:0] o_value
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

