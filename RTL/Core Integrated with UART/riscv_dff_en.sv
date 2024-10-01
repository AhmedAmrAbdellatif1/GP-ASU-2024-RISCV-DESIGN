module riscv_dff_en #(parameter N = 1) (
  input  logic         clk,
  input  logic         rst,
  input  logic         en ,
  input  logic [N-1:0] D  ,
  output logic [N-1:0] Q
);
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      Q <= 'b0;
    else if(en)
      Q <= D;
  end
endmodule