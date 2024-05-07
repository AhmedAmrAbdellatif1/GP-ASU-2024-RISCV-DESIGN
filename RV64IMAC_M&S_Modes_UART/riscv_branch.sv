module riscv_branch (
  input  logic        [ 3:0] i_riscv_branch_cond   ,
  input  logic signed [63:0] i_riscv_branch_rs1data,
  input  logic signed [63:0] i_riscv_branch_rs2data,
  output logic signed        o_riscv_branch_taken
);

  localparam  BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111;

  // Comparator Flags
  logic EQ;
  logic LT ;
  logic LTU;
  assign EQ  = (i_riscv_branch_rs1data==i_riscv_branch_rs2data)? 1'b1:1'b0;
  assign LT  = (i_riscv_branch_rs1data<i_riscv_branch_rs2data)? 1'b1:1'b0;
  assign LTU = ($unsigned(i_riscv_branch_rs1data)<$unsigned(i_riscv_branch_rs2data))? 1'b1:1'b0;

  always_comb
    begin
      if (i_riscv_branch_cond[3]) // if branch comparator is enabled
        begin
          case (i_riscv_branch_cond[2:0])
            BEQ     : o_riscv_branch_taken =  (  EQ )    ? 1'b1 : 1'b0 ;
            BNE     : o_riscv_branch_taken =  ( ~EQ )    ? 1'b1 : 1'b0 ;
            BLT     : o_riscv_branch_taken =  (  LT )    ? 1'b1 : 1'b0 ;
            BGE     : o_riscv_branch_taken =  ( ~LT )    ? 1'b1 : 1'b0 ;
            BLTU    : o_riscv_branch_taken =  (  LTU )   ? 1'b1 : 1'b0 ;
            BGEU    : o_riscv_branch_taken =  ( ~LTU )   ? 1'b1 : 1'b0 ;
            default : o_riscv_branch_taken = 1'b0 ;
          endcase
        end
      else // if branch comparator is disabled -> outputs zeros
        o_riscv_branch_taken = 1'b0 ;
    end
endmodule




