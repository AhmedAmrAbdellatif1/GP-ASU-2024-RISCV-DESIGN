module riscv_extend (i_riscv_extend_inst, i_riscv_extend_immsrc, o_riscv_extend_simm);

  input   logic   [2:0]   i_riscv_extend_immsrc;
  input   logic   [31:7]  i_riscv_extend_inst;
  output  logic   [63:0]  o_riscv_extend_simm;

  always_comb begin
    case(i_riscv_extend_immsrc)
      3'b000: begin // I-type
        o_riscv_extend_simm = { {53{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:20] };
      end
      3'b001: begin // U-type
        o_riscv_extend_simm = { {33{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:12], {12{1'b0}} };
      end
      3'b010: begin // J-type
        o_riscv_extend_simm = { {44{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[19:12], i_riscv_extend_inst[20], i_riscv_extend_inst[30:21], 1'b0 };
      end
      3'b011: begin // S-type
        o_riscv_extend_simm = { {53{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[30:25], i_riscv_extend_inst[11:7] };
      end
      3'b100: begin // B-type
        o_riscv_extend_simm = { {52{i_riscv_extend_inst[31]}}, i_riscv_extend_inst[7], i_riscv_extend_inst[30:25], i_riscv_extend_inst[11:8], 1'b0 };
      end
      default: o_riscv_extend_simm = 'bx;
    endcase
  end

endmodule : riscv_extend 
