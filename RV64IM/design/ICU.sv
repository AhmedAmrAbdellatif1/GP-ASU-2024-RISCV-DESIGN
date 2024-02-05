module riscv_ICU (
input  logic signed [63:0]     i_riscv_icu_rs1data,
input  logic signed [63:0]     i_riscv_icu_rs2data,
input  logic        [3:0]      i_riscv_icu_bcond,
input  logic        [2:0]      i_riscv_icu_mulctrl,
input  logic        [2:0]      i_riscv_icu_divctrl,
input  logic        [5:0]      i_riscv_icu_aluctrl,
input  logic        [1:0]      i_riscv_icu_funcsel,
output logic signed            o_riscv_branch_taken,
output logic signed [63:0]     o_riscv_icu_result
);

logic signed [63:0]     alu_result;
logic signed [63:0]     div_result;
logic signed [63:0]     mul_result;

////////////////////////////////ALU//////////////////////
riscv_alu u_ALU (
    .i_riscv_alu_ctrl    (i_riscv_icu_aluctrl),
    .i_riscv_alu_rs1data (i_riscv_icu_rs1data),
    .i_riscv_alu_rs2data (i_riscv_icu_rs2data),
    .o_riscv_alu_result  (o_riscv_icu_result)
);

////////////////////////////BRANCH///////////////////////
riscv_branch u_Branch(
    .i_riscv_branch_cond    (i_riscv_icu_bcond),
    .i_riscv_branch_rs1data (i_riscv_icu_rs1data),
    .i_riscv_branch_rs2data (i_riscv_icu_rs2data),
    .o_riscv_branch_taken   (o_riscv_branch_taken)
);


//////////////////////////////multiplier////////////////////////
riscv_multiplier u_mul (
    .i_riscv_mul_rs1data (i_riscv_icu_rs1data),
    .i_riscv_mul_rs2data (i_riscv_icu_rs2data),
    .i_riscv_mul_mulctrl (i_riscv_icu_mulctrl),
    .o_riscv_mul_product (mul_result)
);

////////////////////////////////divider///////////////////////////
riscv_divider u_divider (
    .i_riscv_div_rs1data (i_riscv_icu_rs1data),
    .i_riscv_div_rs2data (i_riscv_icu_rs2data),
    .i_riscv_div_divctrl (i_riscv_icu_divctrl),
    .o_riscv_div_product (div_result)
);

////////////////////////////////mux//////////////////////////////
riscv_mux3 u_mux (
    .i_riscv_mux3_sel (i_riscv_icu_funcsel),
    .i_riscv_mux3_in0 (mul_result),
    .i_riscv_mux3_in1 (div_result),
    .i_riscv_mux3_in2 (alu_result),
    .o_riscv_mux3_out (o_riscv_icu_result)
);

endmodule