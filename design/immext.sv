module riscv_extend (i_riscv_extend_inst, i_riscv_extend_immsrc, o_riscv_extend_simm);

  typedef enum {i_imm, u_imm, j_imm, s_imm, b_imm} imm_type;

  input   logic   [31:7]  i_riscv_extend_inst;
  output  logic   [63:0]  o_riscv_extend_simm;
  input imm_type  i_riscv_extend_immsrc;
  


  always_comb begin
    case(i_riscv_extend_immsrc)
      i_imm: o_riscv_extend_simm = { {53{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:20] };
      u_imm: o_riscv_extend_simm = { {33{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:12], {12{1'b0}} };
      j_imm: o_riscv_extend_simm = { {44{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[19:12], i_riscv_extend_inst[20], i_riscv_extend_inst[30:21], 1'b0 };
      s_imm: o_riscv_extend_simm = { {53{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:25], i_riscv_extend_inst[11:7] };
      b_imm: o_riscv_extend_simm = { {52{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[7], i_riscv_extend_inst[30:25], i_riscv_extend_inst[11:8], 1'b0 };
      default: o_riscv_extend_simm = 'bx;
    endcase
  end

endmodule : riscv_extend 
