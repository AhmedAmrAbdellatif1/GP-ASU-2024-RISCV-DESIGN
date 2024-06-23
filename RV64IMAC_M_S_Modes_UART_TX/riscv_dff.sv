module riscv_dff #(parameter N = 1) (
  input  logic         clk,
  input  logic         rst,
  input  logic [N-1:0] D  ,
  output logic [N-1:0] Q
);
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      Q <= 'b0;
    else
      Q <= D;
  end
endmodule