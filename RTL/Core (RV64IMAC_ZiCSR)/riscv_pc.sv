module riscv_pc # (parameter KERNEL_PC = 'h0  ) (
 input  logic         i_riscv_pc_clk      ,
 input  logic         i_riscv_pc_rst      ,
 input  logic         i_riscv_pc_stallpc  ,
 input  logic [63:0]  i_riscv_pc_nextpc   ,
 output logic [63:0]  o_riscv_pc_pc
 );
 
  always_ff @(posedge i_riscv_pc_clk) begin
    if(i_riscv_pc_rst)
      o_riscv_pc_pc  <=  KERNEL_PC;
    else if(!i_riscv_pc_stallpc)
      o_riscv_pc_pc  <=  i_riscv_pc_nextpc;
  end 
 endmodule