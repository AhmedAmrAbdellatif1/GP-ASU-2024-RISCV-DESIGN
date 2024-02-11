module riscv_im (
  input logic  [63:0] i_riscv_im_pc,
  output logic [31:0] o_riscv_im_inst);
  
  logic [31:0] RAM [0:127];
  logic [63:0] pcplus  ;
  
  always @(*)
  begin
    $readmemh("riscvtest.txt",RAM);       
    
  if (i_riscv_im_pc %4)
  o_riscv_im_inst={ RAM[pcplus[63:2]][15:0], RAM[i_riscv_im_pc[63:2]][31:16] } ;
  
  else
   o_riscv_im_inst=RAM[i_riscv_im_pc[63:2]];
  end
  
  assign pcplus = i_riscv_im_pc + 64'b10;
  
//assign o_riscv_im_inst=RAM[i_riscv_im_pc[63:2]];  //pc=0,4,8,12 ...> ram=0,1,2,3 [word aligned] 
endmodule

