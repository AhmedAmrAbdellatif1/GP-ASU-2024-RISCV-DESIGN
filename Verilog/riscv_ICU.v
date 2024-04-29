module riscv_icu (
  input  wire signed [63:0]  i_riscv_icu_rs1data     ,
  input  wire signed [63:0]  i_riscv_icu_rs2data     ,
  input  wire signed [63:0]  i_riscv_icu_alurs1data  ,
  input  wire signed [63:0]  i_riscv_icu_alurs2data  ,
  input  wire        [3:0]   i_riscv_icu_bcond       ,
  input  wire        [3:0]   i_riscv_icu_mulctrl     ,
  input  wire        [3:0]   i_riscv_icu_divctrl     ,
  input  wire        [5:0]   i_riscv_icu_aluctrl     ,
  input  wire        [1:0]   i_riscv_icu_funcsel     ,
  input  wire                i_riscv_icu_clk         ,
  input  wire                i_riscv_icu_rst         ,
  output wire signed         o_riscv_branch_taken    ,
  output wire signed         o_riscv_icu_valid       ,
  output wire signed [63:0]  o_riscv_icu_result
);

  wire               riscv_mul_valid;
  wire               riscv_div_valid;
  wire signed [63:0] alu_result;
  wire signed [63:0] div_result;
  wire signed [63:0] mul_result;

  assign o_riscv_icu_valid = riscv_div_valid || riscv_mul_valid;

/************************ ALU ************************/
riscv_alu u_ALU (
  .i_riscv_alu_ctrl    (i_riscv_icu_aluctrl)    ,
  .i_riscv_alu_rs1data (i_riscv_icu_alurs1data) ,
  .i_riscv_alu_rs2data (i_riscv_icu_alurs2data) ,
  .o_riscv_alu_result  (alu_result)
);

/************************ Branch ************************/
riscv_branch u_branch_comp  (
  .i_riscv_branch_cond    (i_riscv_icu_bcond)   ,
  .i_riscv_branch_rs1data (i_riscv_icu_rs1data) ,  
  .i_riscv_branch_rs2data (i_riscv_icu_rs2data) ,
  .o_riscv_branch_taken   (o_riscv_branch_taken)
);


/************************ Multiplier ************************/
riscv_multiplier u_mul (
  .i_riscv_mul_rs1data (i_riscv_icu_alurs1data) ,
  .i_riscv_mul_rs2data (i_riscv_icu_alurs2data) ,
  .i_riscv_mul_mulctrl (i_riscv_icu_mulctrl)    ,
  .i_riscv_mul_clk     (i_riscv_icu_clk)        ,
  .i_riscv_mul_rst     (i_riscv_icu_rst)        ,
  .o_riscv_mul_valid   (riscv_mul_valid)        ,
  .o_riscv_mul_product (mul_result)
);

/************************ Divider ************************/
riscv_divider u_divider (
  .i_riscv_div_rs1data (i_riscv_icu_alurs1data) ,
  .i_riscv_div_rs2data (i_riscv_icu_alurs2data) ,
  .i_riscv_div_divctrl (i_riscv_icu_divctrl)    ,
  .i_riscv_div_clk     (i_riscv_icu_clk)        , 
  .i_riscv_div_rst     (i_riscv_icu_rst)        ,
  .o_riscv_div_valid   (riscv_div_valid)        ,     
  .o_riscv_div_result  (div_result)
);

/************************ ICU Output MUX ************************/
riscv_mux3 u_mux (
    .i_riscv_mux3_sel (i_riscv_icu_funcsel) ,
    .i_riscv_mux3_in0 (mul_result)          ,
    .i_riscv_mux3_in1 (div_result)          ,
    .i_riscv_mux3_in2 (alu_result)          ,
    .o_riscv_mux3_out (o_riscv_icu_result)
);

endmodule