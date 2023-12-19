module riscv_extend (inst, immsrc, ext_imm);

  typedef enum {i_imm, u_imm, j_imm, s_imm, b_imm} imm_type;

  input   logic   [31:7]  inst;
  output  logic   [63:0]  ext_imm;
  input imm_type  immsrc;
  


  always_comb begin
    case(immsrc)
      i_imm: ext_imm = { {53{inst[31]}}, inst[30:20] };
      u_imm: ext_imm = { {33{inst[31]}}, inst[30:12], {12{1'b0}} };
      j_imm: ext_imm = { {44{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
      s_imm: ext_imm = { {53{inst[31]}}, inst[30:25], inst[11:7] };
      b_imm: ext_imm = { {52{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
      default: ext_imm = 'bx;
    endcase
  end

endmodule : riscv_extend 
