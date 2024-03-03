module riscv_memext(
  input logic  [2:0]  i_riscv_memext_sel,          //the lower 2-bits for determining the size of loading and the MSB for signed/zero extension selection.
  input logic  [63:0] i_riscv_memext_addr,
  input logic  [63:0] i_riscv_memext_data,
  output logic [63:0] o_riscv_memext_loaded);

  logic [2:0] byte_offset;

  assign byte_offset = i_riscv_memext_addr[2:0];
  
  always_comb 
  begin
    case(i_riscv_memext_sel)
  //load byte 
  3'b000: begin // lb
    case(byte_offset)
      3'b000: o_riscv_memext_loaded={{56{i_riscv_memext_data[7]}},i_riscv_memext_data[7:0]};
      3'b001: o_riscv_memext_loaded={{56{i_riscv_memext_data[15]}},i_riscv_memext_data[15:8]};
      3'b010: o_riscv_memext_loaded={{56{i_riscv_memext_data[23]}},i_riscv_memext_data[23:16]};
      3'b011: o_riscv_memext_loaded={{56{i_riscv_memext_data[31]}},i_riscv_memext_data[31:24]};
      3'b100: o_riscv_memext_loaded={{56{i_riscv_memext_data[39]}},i_riscv_memext_data[39:32]};
      3'b101: o_riscv_memext_loaded={{56{i_riscv_memext_data[47]}},i_riscv_memext_data[47:40]};
      3'b110: o_riscv_memext_loaded={{56{i_riscv_memext_data[55]}},i_riscv_memext_data[55:48]};
      3'b111: o_riscv_memext_loaded={{56{i_riscv_memext_data[63]}},i_riscv_memext_data[63:56]};
    endcase
  end                   
  3'b100: begin // lbu
    case(byte_offset)
      3'b000: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[7:0]};
      3'b001: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[15:8]};
      3'b010: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[23:16]};
      3'b011: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[31:24]};
      3'b100: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[39:32]};
      3'b101: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[47:40]};
      3'b110: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[55:48]};
      3'b111: o_riscv_memext_loaded={{56{1'b0}},i_riscv_memext_data[63:56]};
    endcase
  end
    
  //load half word
  3'b001: begin  // lh
    case(byte_offset[2:1])
      2'b00: o_riscv_memext_loaded={{48{i_riscv_memext_data[15]}},i_riscv_memext_data[15:0]};
      2'b01: o_riscv_memext_loaded={{48{i_riscv_memext_data[31]}},i_riscv_memext_data[31:16]};
      2'b10: o_riscv_memext_loaded={{48{i_riscv_memext_data[47]}},i_riscv_memext_data[47:32]};
      2'b11: o_riscv_memext_loaded={{48{i_riscv_memext_data[63]}},i_riscv_memext_data[63:48]};
    endcase
  end
  3'b101: begin // lhu
    case(byte_offset[2:1])
      2'b00: o_riscv_memext_loaded={{48{1'b0}},i_riscv_memext_data[15:0]};
      2'b01: o_riscv_memext_loaded={{48{1'b0}},i_riscv_memext_data[31:16]};
      2'b10: o_riscv_memext_loaded={{48{1'b0}},i_riscv_memext_data[47:32]};
      2'b11: o_riscv_memext_loaded={{48{1'b0}},i_riscv_memext_data[63:48]};
    endcase
  end
  //load word
  3'b010:    
    case(byte_offset[2]) // lw
      1'b0: o_riscv_memext_loaded={{32{i_riscv_memext_data[31]}},i_riscv_memext_data[31:0]} ;
      1'b1: o_riscv_memext_loaded={{32{i_riscv_memext_data[63]}},i_riscv_memext_data[63:32]} ;
    endcase
  3'b110:                   
    case(byte_offset[2]) // lwu
      1'b0: o_riscv_memext_loaded={{32{1'b0}},i_riscv_memext_data[31:0]} ;
      1'b1: o_riscv_memext_loaded={{32{1'b0}},i_riscv_memext_data[63:32]} ;
    endcase
  //load double word
  3'b011: o_riscv_memext_loaded=i_riscv_memext_data;
  default: o_riscv_memext_loaded=i_riscv_memext_data;
  endcase
end 
endmodule
  