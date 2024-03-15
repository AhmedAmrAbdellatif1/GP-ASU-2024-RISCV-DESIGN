module exception_unit(
input  logic  [6:0]       i_riscv_exception_opcode,
input  logic  [63:0]      i_riscv_exception_icu_result,
input  logic              i_riscv_exception_branch_taken,
input  logic  [2:0]       i_riscv_exception_load_sel,
input  logic  [1:0]       i_riscv_exception_store_sel,
output logic              o_riscv_exception_store_addr_misaligned,
output logic              o_riscv_exception_load_addr_misaligned,
output logic              o_riscv_exception_inst_addr_misaligned
);
typedef enum logic [6:0] {
    OPCODE_LOAD        = 7'h03,
    OPCODE_OP_IMM      = 7'h13,
    OPCODE_STORE       = 7'h23,
    OPCODE_OP          = 7'h33,
    OPCODE_LUI         = 7'h37,
    OPCODE_BRANCH      = 7'h63,
    OPCODE_JALR        = 7'h67,
    OPCODE_JAL         = 7'h6f,
    OPCODE_OP_WORD     = 7'h3b,
    OPCODE_OP_WORD_IMM = 7'h1b
  }opcode;
  
  always_comb begin  
    o_riscv_exception_inst_addr_misaligned = 'b0;
    o_riscv_exception_load_addr_misaligned = 'b0;
    o_riscv_exception_store_addr_misaligned = 'b0;

    case(i_riscv_exception_opcode)

    OPCODE_JAL,OPCODE_JALR:begin
    if(i_riscv_exception_icu_result[1:0] == 'b00 || i_riscv_exception_icu_result[1:0] == 'b10 )
    o_riscv_exception_inst_addr_misaligned = 'b0;
    else
    o_riscv_exception_inst_addr_misaligned = 'b1;
     end
    
     OPCODE_BRANCH:begin
    if(i_riscv_exception_icu_result[1:0] == 'b00 || i_riscv_exception_icu_result[1:0] == 'b10 )
      o_riscv_exception_inst_addr_misaligned = 'b0;
    else if(i_riscv_exception_branch_taken)
      o_riscv_exception_inst_addr_misaligned = 'b1;
    else
      o_riscv_exception_inst_addr_misaligned = 'b0;
     end

    OPCODE_LOAD:begin
    case(i_riscv_exception_load_sel)
        3'b000,3'b100:begin //lb,lbu
            o_riscv_exception_load_addr_misaligned = 1'b0; 
        end

        3'b101,3'b001:begin // lh,lhu
            if(i_riscv_exception_icu_result[0] != 1'b0 )
            o_riscv_exception_load_addr_misaligned = 1'b1;
            else
            o_riscv_exception_load_addr_misaligned = 1'b0;
        end

        3'b110,3'b010: begin // lw,lwu
            if(i_riscv_exception_icu_result[1:0] != 2'b00 )
            o_riscv_exception_load_addr_misaligned = 1'b1;
            else
            o_riscv_exception_load_addr_misaligned = 1'b0;
            end

        3'b011:begin // ld
             if(i_riscv_exception_icu_result[2:0] != 3'b000 )
             o_riscv_exception_load_addr_misaligned = 1'b1;
             else
             o_riscv_exception_load_addr_misaligned = 1'b0;
        end
        default:begin
            o_riscv_exception_inst_addr_misaligned = 1'b0;
            o_riscv_exception_load_addr_misaligned = 1'b0;
        end
        endcase
    end
    OPCODE_STORE:begin
        case(i_riscv_exception_store_sel)

        2'b00:begin //sb
            o_riscv_exception_store_addr_misaligned = 1'b0; 
        end
        2'b01:begin //sh
             if(i_riscv_exception_icu_result[0] != 1'b0 )
            o_riscv_exception_store_addr_misaligned = 1'b1;
            else
            o_riscv_exception_store_addr_misaligned = 1'b0;           
        end
        2'b10:begin //sw
            if(i_riscv_exception_icu_result[1:0] != 2'b00 )
            o_riscv_exception_store_addr_misaligned = 1'b1;
            else
            o_riscv_exception_store_addr_misaligned = 1'b0;
            end
        2'b11:begin //sd
             if(i_riscv_exception_icu_result[2:0] != 3'b000 )
             o_riscv_exception_store_addr_misaligned = 1'b1;
             else
             o_riscv_exception_store_addr_misaligned = 1'b0;
        end
        default:begin
            o_riscv_exception_inst_addr_misaligned = 1'b0;
            o_riscv_exception_store_addr_misaligned = 1'b0;
        end        
         endcase
    end
         default:begin
             o_riscv_exception_inst_addr_misaligned = 'b0;
             o_riscv_exception_load_addr_misaligned = 'b0;
            o_riscv_exception_store_addr_misaligned = 'b0;

        end
    endcase
  end 

endmodule