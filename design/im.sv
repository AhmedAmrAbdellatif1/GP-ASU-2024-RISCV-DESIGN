module riscv_im (
  input logic  [63:0] i_riscv_im_pc,
  output logic [31:0] o_riscv_im_inst);
  
  logic [31:0] RAM [0:127];
  
  initial 
  begin
    $readmemh("riscvtest.txt",RAM);       
  end
  
assign o_riscv_im_inst=RAM[i_riscv_im_pc[63:2]];  //pc=0,4,8,12 ...> ram=0,1,2,3 [word aligned] 
endmodule