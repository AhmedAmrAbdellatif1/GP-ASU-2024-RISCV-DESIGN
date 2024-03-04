module riscv_memext(
  input logic  [2:0]  i_riscv_memext_sel  , 
  input logic  [63:0] i_riscv_memext_data ,
  output logic [63:0] o_riscv_memext_loaded
  );

  localparam  LB  = 3'b000,
              LBU = 3'b100,
              LH  = 3'b001,
              LHU = 3'b101,
              LW  = 3'b010,
              LWU = 3'b110,
              LD  = 3'b011;
  
  always_comb 
  begin
    case(i_riscv_memext_sel)
      LB : o_riscv_memext_loaded  = { {56{i_riscv_memext_data[7]}} ,  i_riscv_memext_data[7:0]  }; 
      LH : o_riscv_memext_loaded  = { {48{i_riscv_memext_data[15]}},  i_riscv_memext_data[15:0] };  
      LW : o_riscv_memext_loaded  = { {32{i_riscv_memext_data[31]}},  i_riscv_memext_data[31:0] };
      LBU: o_riscv_memext_loaded  = { {56{1'b0}}, i_riscv_memext_data[7:0]  };                     
      LHU: o_riscv_memext_loaded  = { {48{1'b0}}, i_riscv_memext_data[15:0] };                      
      LWU: o_riscv_memext_loaded  = { {32{1'b0}}, i_riscv_memext_data[31:0] };                      
      LD : o_riscv_memext_loaded  = i_riscv_memext_data;

      default: o_riscv_memext_loaded  = i_riscv_memext_data;
    endcase
  end 
endmodule