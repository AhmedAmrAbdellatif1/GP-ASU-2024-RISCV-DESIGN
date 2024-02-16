module riscv_ICU (
input  logic signed [63:0]     i_riscv_icu_rs1data,
input  logic signed [63:0]     i_riscv_icu_rs2data,
input  logic signed [63:0]     i_riscv_icu_alurs1data,
input  logic signed [63:0]     i_riscv_icu_alurs2data,
input  logic        [3:0]      i_riscv_icu_bcond,
input  logic        [2:0]      i_riscv_icu_mulctrl,
input  logic        [2:0]      i_riscv_icu_divctrl,
input  logic        [5:0]      i_riscv_icu_aluctrl,
input  logic        [1:0]      i_riscv_icu_funcsel,
input  logic                   i_riscv_icu_clk,
input  logic                   i_riscv_icu_rst,
output logic signed            o_riscv_branch_taken,
output logic signed            o_riscv_icu_valid,
output logic signed [63:0]     o_riscv_icu_result
);

logic signed [63:0]     alu_result;
logic signed [63:0]     div_result;
logic signed [63:0]     mul_result;

////////////////////////////////ALU//////////////////////
riscv_alu u_ALU (
    .i_riscv_alu_ctrl    (i_riscv_icu_aluctrl),
    .i_riscv_alu_rs1data (i_riscv_icu_alurs1data),
    .i_riscv_alu_rs2data (i_riscv_icu_alurs2data),
    .o_riscv_alu_result  (alu_result)
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
    .i_riscv_mul_clk     (i_riscv_icu_clk),
    .i_riscv_mul_rst     (i_riscv_icu_rst),
    .o_riscv_mul_valid   (o_riscv_icu_valid),
    .o_riscv_mul_product (mul_result)
);

////////////////////////////////divider///////////////////////////
riscv_divider u_divider (
    .i_riscv_div_rs1data (i_riscv_icu_rs1data),
    .i_riscv_div_rs2data (i_riscv_icu_rs2data),
    .i_riscv_div_divctrl (i_riscv_icu_divctrl),
    .o_riscv_div_result (div_result)
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