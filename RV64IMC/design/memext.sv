module riscv_memext(
  input logic  [2:0]  i_riscv_memext_sel,          //the lower 2-bits for determining the size of loading and the MSB for signed/zero extension selection.
  input logic  [63:0] i_riscv_memext_data,
  output logic [63:0] o_riscv_memext_loaded);
  
  always_comb 
  begin
    case(i_riscv_memext_sel)
  //load byte 
  3'b000: o_riscv_memext_loaded={{56{i_riscv_memext_data[7]}},i_riscv_memext_data[7:0]};  // Lb
  3'b100: o_riscv_memext_loaded={{56{0}},i_riscv_memext_data[7:0]};                      // Lbu
    
  //load half word
  3'b001: o_riscv_memext_loaded={{48{i_riscv_memext_data[15]}},i_riscv_memext_data[15:0]};  // Lh
  3'b101: o_riscv_memext_loaded={{48{0}},i_riscv_memext_data[15:0]};                       // Lhu

//load word
  3'b010: o_riscv_memext_loaded={{32{i_riscv_memext_data[31]}},i_riscv_memext_data[31:0]} ; // Lw
  3'b110: o_riscv_memext_loaded={{32{0}},i_riscv_memext_data[31:0]} ;                      // Lwu


//load double word
3'b011: o_riscv_memext_loaded=i_riscv_memext_data;
default: o_riscv_memext_loaded=i_riscv_memext_data;
endcase
      
  end 
endmodule
  