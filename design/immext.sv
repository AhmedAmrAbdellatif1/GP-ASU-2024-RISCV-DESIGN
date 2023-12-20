module riscv_extend (i_riscv_extend_inst, i_riscv_extend_immsrc, o_riscv_extend_simm);

  typedef enum logic [2:0] {i_imm = 3'b000,
                            u_imm = 3'b001,
                            j_imm = 3'b010,
                            s_imm = 3'b011,
                            b_imm = 3'b100} imm_type;

  input   logic   [2:0]   i_riscv_extend_immsrc;
  input   logic   [31:7]  i_riscv_extend_inst;
  output  logic   [63:0]  o_riscv_extend_simm;

  imm_type immsrc;

  always_comb begin
    case(immsrc)
      i_imm: o_riscv_extend_simm = { {53{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:20] };
      u_imm: o_riscv_extend_simm = { {33{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:12], {12{1'b0}} };
      j_imm: o_riscv_extend_simm = { {44{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[19:12], i_riscv_extend_inst[20], i_riscv_extend_inst[30:21], 1'b0 };
      s_imm: o_riscv_extend_simm = { {53{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:25], i_riscv_extend_inst[11:7] };
      b_imm: o_riscv_extend_simm = { {52{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[7], i_riscv_extend_inst[30:25], i_riscv_extend_inst[11:8], 1'b0 };
      default: o_riscv_extend_simm = 'bx;
    endcase
  end

  assign immsrc = imm_type'(i_riscv_extend_immsrc);

endmodule : riscv_extend 
