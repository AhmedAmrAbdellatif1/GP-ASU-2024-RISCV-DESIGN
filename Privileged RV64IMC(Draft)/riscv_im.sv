module riscv_im (
  input logic  [63:0] i_riscv_im_pc,
  output logic [31:0] o_riscv_im_inst);
  
  logic [31:0] RAM [0:160000];
  logic [63:0] pcplus  ;
  logic [63:0] new_pc_for_test;

  initial begin
    $readmemh("riscvtest.txt",RAM);
  end
  
  assign new_pc_for_test = i_riscv_im_pc -'h0;
  
  always @(*)  begin
    if (new_pc_for_test %4)
    o_riscv_im_inst={ RAM[pcplus[63:2]][15:0], RAM[new_pc_for_test[63:2]][31:16] } ;
    else
    o_riscv_im_inst=RAM[new_pc_for_test[63:2]];
  end
  
  assign pcplus = new_pc_for_test + 64'b10;
  
//assign o_riscv_im_inst=RAM[i_riscv_im_pc[63:2]];  //pc=0,4,8,12 ...> ram=0,1,2,3 [word aligned] 
endmodule

