module riscv_compressed_decoder (
  input  logic [31:0] i_riscv_cdecoder_inst,
  output logic [31:0] o_riscv_cdecoder_inst,
  output logic o_riscv_cdecoder_compressed
);

  typedef enum logic [6:0] {
    OPCODE_LOAD     = 7'h03,
    OPCODE_OP_IMM   = 7'h13,
    OPCODE_STORE    = 7'h23,
    OPCODE_OP       = 7'h33,
    OPCODE_LUI      = 7'h37,
    OPCODE_BRANCH   = 7'h63,
    OPCODE_JALR     = 7'h67,
    OPCODE_JAL      = 7'h6f
  }opcode;
  
  
 always_comb begin
   o_riscv_cdecoder_inst  = i_riscv_cdecoder_inst;
     case (i_riscv_cdecoder_inst[1:0])
      // C0
      2'b00: begin
         case (i_riscv_cdecoder_inst[15:13])
          3'b000: begin
            // c.addi4spn -> addi rd', x2, imm
            o_riscv_cdecoder_inst = {2'b0, i_riscv_cdecoder_inst[10:7], i_riscv_cdecoder_inst[12:11], i_riscv_cdecoder_inst[5],
                       i_riscv_cdecoder_inst[6], 2'b00, 5'h02, 3'b000, 2'b01, i_riscv_cdecoder_inst[4:2], {OPCODE_OP_IMM}};
          end

          3'b010: begin
            // c.lw -> lw rd', imm(rs1')
            o_riscv_cdecoder_inst = {5'b0, i_riscv_cdecoder_inst[5], i_riscv_cdecoder_inst[12:10], i_riscv_cdecoder_inst[6],
                       2'b00, 2'b01, i_riscv_cdecoder_inst[9:7], 3'b010, 2'b01, i_riscv_cdecoder_inst[4:2], {OPCODE_LOAD}};
          end

          3'b110: begin
            // c.sw -> sw rs2', imm(rs1')
            o_riscv_cdecoder_inst = {5'b0, i_riscv_cdecoder_inst[5], i_riscv_cdecoder_inst[12], 2'b01, i_riscv_cdecoder_inst[4:2],
                       2'b01, i_riscv_cdecoder_inst[9:7], 3'b010, i_riscv_cdecoder_inst[11:10], i_riscv_cdecoder_inst[6],
                       2'b00, {OPCODE_STORE}};
          end
        endcase
      end

      // C1
      2'b01: begin
        case (i_riscv_cdecoder_inst[15:13])
          3'b000: begin
            // c.addi -> addi rd, rd, nzimm
            // c.nop
            o_riscv_cdecoder_inst = {{6 {i_riscv_cdecoder_inst[12]}}, i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[6:2],
                       i_riscv_cdecoder_inst[11:7], 3'b0, i_riscv_cdecoder_inst[11:7], {OPCODE_OP_IMM}};
          end

          3'b001, 3'b101: begin
            // 001: c.jal -> jal x1, imm
            // 101: c.j   -> jal x0, imm
            o_riscv_cdecoder_inst = {i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[8], i_riscv_cdecoder_inst[10:9], i_riscv_cdecoder_inst[6],
                       i_riscv_cdecoder_inst[7], i_riscv_cdecoder_inst[2], i_riscv_cdecoder_inst[11], i_riscv_cdecoder_inst[5:3],
                       {9 {i_riscv_cdecoder_inst[12]}}, 4'b0, ~i_riscv_cdecoder_inst[15], {OPCODE_JAL}};
          end

          3'b010: begin
            // c.li -> addi rd, x0, nzimm
            o_riscv_cdecoder_inst = {{6 {i_riscv_cdecoder_inst[12]}}, i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[6:2], 5'b0,
                       3'b0, i_riscv_cdecoder_inst[11:7], {OPCODE_OP_IMM}};
          end

          3'b011: begin
            // c.lui -> lui rd, imm
            o_riscv_cdecoder_inst = {{15 {i_riscv_cdecoder_inst[12]}}, i_riscv_cdecoder_inst[6:2], i_riscv_cdecoder_inst[11:7], {OPCODE_LUI}};

            if (i_riscv_cdecoder_inst[11:7] == 5'h02) begin
              // c.addi16sp -> addi x2, x2, nzimm
              o_riscv_cdecoder_inst = {{3 {i_riscv_cdecoder_inst[12]}}, i_riscv_cdecoder_inst[4:3], i_riscv_cdecoder_inst[5], i_riscv_cdecoder_inst[2],
                         i_riscv_cdecoder_inst[6], 4'b0, 5'h02, 3'b000, 5'h02, {OPCODE_OP_IMM}};
            end
          end

          3'b100: begin
            case (i_riscv_cdecoder_inst[11:10])
              2'b00,
              2'b01: begin
                // 00: c.srli -> srli rd, rd, shamt
                // 01: c.srai -> srai rd, rd, shamt
                o_riscv_cdecoder_inst = {1'b0, i_riscv_cdecoder_inst[10], 5'b0, i_riscv_cdecoder_inst[6:2], 2'b01, i_riscv_cdecoder_inst[9:7],
                           3'b101, 2'b01, i_riscv_cdecoder_inst[9:7], {OPCODE_OP_IMM}};
              end

              2'b10: begin
                // c.andi -> andi rd, rd, imm
                o_riscv_cdecoder_inst = {{6 {i_riscv_cdecoder_inst[12]}}, i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[6:2], 2'b01, i_riscv_cdecoder_inst[9:7],
                           3'b111, 2'b01, i_riscv_cdecoder_inst[9:7], {OPCODE_OP_IMM}};
              end

              2'b11: begin
                case ({i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[6:5]})
                  3'b000: begin
                    // c.sub -> sub rd', rd', rs2'
                    o_riscv_cdecoder_inst = {2'b01, 5'b0, 2'b01, i_riscv_cdecoder_inst[4:2], 2'b01, i_riscv_cdecoder_inst[9:7],
                               3'b000, 2'b01, i_riscv_cdecoder_inst[9:7], {OPCODE_OP}};
                  end

                  3'b001: begin
                    // c.xor -> xor rd', rd', rs2'
                    o_riscv_cdecoder_inst = {7'b0, 2'b01, i_riscv_cdecoder_inst[4:2], 2'b01, i_riscv_cdecoder_inst[9:7], 3'b100,
                               2'b01, i_riscv_cdecoder_inst[9:7], {OPCODE_OP}};
                  end

                  3'b010: begin
                    // c.or  -> or  rd', rd', rs2'
                    o_riscv_cdecoder_inst = {7'b0, 2'b01, i_riscv_cdecoder_inst[4:2], 2'b01, i_riscv_cdecoder_inst[9:7], 3'b110,
                               2'b01, i_riscv_cdecoder_inst[9:7], {OPCODE_OP}};
                  end

                  3'b011: begin
                    // c.and -> and rd', rd', rs2'
                    o_riscv_cdecoder_inst = {7'b0, 2'b01, i_riscv_cdecoder_inst[4:2], 2'b01, i_riscv_cdecoder_inst[9:7], 3'b111,
                               2'b01, i_riscv_cdecoder_inst[9:7], {OPCODE_OP}};
                  end
                endcase
              end
            endcase
          end

          3'b110, 3'b111: begin
            // 0: c.beqz -> beq rs1', x0, imm
            // 1: c.bnez -> bne rs1', x0, imm
            o_riscv_cdecoder_inst = {{4 {i_riscv_cdecoder_inst[12]}}, i_riscv_cdecoder_inst[6:5], i_riscv_cdecoder_inst[2], 5'b0, 2'b01,
                       i_riscv_cdecoder_inst[9:7], 2'b00, i_riscv_cdecoder_inst[13], i_riscv_cdecoder_inst[11:10], i_riscv_cdecoder_inst[4:3],
                       i_riscv_cdecoder_inst[12], {OPCODE_BRANCH}};
          end
        endcase
      end

      // C2
      2'b10: begin
        case (i_riscv_cdecoder_inst[15:13])
          3'b000: begin
            // c.slli -> slli rd, rd, shamt
            o_riscv_cdecoder_inst = {7'b0, i_riscv_cdecoder_inst[6:2], i_riscv_cdecoder_inst[11:7], 3'b001, i_riscv_cdecoder_inst[11:7], {OPCODE_OP_IMM}};
          end

          3'b010: begin
            // c.lwsp -> lw rd, imm(x2)
            o_riscv_cdecoder_inst = {4'b0, i_riscv_cdecoder_inst[3:2], i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[6:4], 2'b00, 5'h02,
                       3'b010, i_riscv_cdecoder_inst[11:7], OPCODE_LOAD};
          end

          3'b100: begin
            if (i_riscv_cdecoder_inst[12] == 1'b0) begin
              if (i_riscv_cdecoder_inst[6:2] != 5'b0) begin
                // c.mv -> add rd/rs1, x0, rs2
                o_riscv_cdecoder_inst = {7'b0, i_riscv_cdecoder_inst[6:2], 5'b0, 3'b0, i_riscv_cdecoder_inst[11:7], {OPCODE_OP}};
              end else begin
                // c.jr -> jalr x0, rd/rs1, 0
                o_riscv_cdecoder_inst = {12'b0, i_riscv_cdecoder_inst[11:7], 3'b0, 5'b0, {OPCODE_JALR}};
              end
            end else begin
              if (i_riscv_cdecoder_inst[6:2] != 5'b0) begin
                // c.add -> add rd, rd, rs2
                o_riscv_cdecoder_inst = {7'b0, i_riscv_cdecoder_inst[6:2], i_riscv_cdecoder_inst[11:7], 3'b0, i_riscv_cdecoder_inst[11:7], {OPCODE_OP}};
              end else begin
                if (i_riscv_cdecoder_inst[11:7] == 5'b0) begin
                  // c.ebreak -> ebreak
                  o_riscv_cdecoder_inst = {32'h00_10_00_73};
                end else begin
                  // c.jalr -> jalr x1, rs1, 0
                  o_riscv_cdecoder_inst = {12'b0, i_riscv_cdecoder_inst[11:7], 3'b000, 5'b00001, {OPCODE_JALR}};
                end
              end
            end
          end

          3'b110: begin
            // c.swsp -> sw rs2, imm(x2)
            o_riscv_cdecoder_inst = {4'b0, i_riscv_cdecoder_inst[8:7], i_riscv_cdecoder_inst[12], i_riscv_cdecoder_inst[6:2], 5'h02, 3'b010,
                       i_riscv_cdecoder_inst[11:9], 2'b00, {OPCODE_STORE}};
          end
        endcase
      end
    endcase
  end
  
assign o_riscv_cdecoder_compressed = (i_riscv_cdecoder_inst[1:0] != 2'b11);
endmodule