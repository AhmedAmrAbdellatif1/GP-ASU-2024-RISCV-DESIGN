module riscv_estage (
  input  wire               i_riscv_estage_clk                  ,
  input  wire               i_riscv_estage_rst                  ,
  input  wire               i_riscv_estage_globstall            ,
  input  wire        [63:0] i_riscv_estage_imm_m                ,
  input  wire signed [63:0] i_riscv_estage_rs1data              , //  Common Signals to Forward_mux_A,B
  input  wire signed [63:0] i_riscv_estage_rs2data              , //  Common Signals to Forward_mux_A,B
  input  wire        [ 1:0] i_riscv_estage_fwda                 , //  u_Forward_mux_A Signals
  input  wire        [ 1:0] i_riscv_estage_fwdb                 , //  u_Forward_mux_B Signals
  input  wire signed [63:0] i_riscv_estage_rdata_wb             , //  u_Forward_mux_A,B Signals
  input  wire signed [63:0] i_riscv_estage_rddata_m             , //  u_Forward_mux_A,B Signals
  input  wire               i_riscv_estage_oprnd1sel            , //  u_Forward_mux_ operand A ,B Signals
  input  wire               i_riscv_estage_oprnd2sel            , //  u_Forward_mux_ operand A ,B Signals
  input  wire        [63:0] i_riscv_estage_pc                   , //  u_ALU Signals
  input  wire        [ 5:0] i_riscv_estage_aluctrl              , //  u_ALU Signals
  input  wire        [ 3:0] i_riscv_estage_mulctrl              ,
  input  wire        [ 3:0] i_riscv_estage_divctrl              ,
  input  wire        [ 1:0] i_riscv_estage_funcsel              ,
  input  wire signed [63:0] i_riscv_estage_simm                 , //  Operand2 MUX signal
  input  wire        [ 3:0] i_riscv_estage_bcond                , //  u_Branch Comparator Siganls
  input  wire               i_riscv_estage_imm_reg              , //<--- TRAPS AND CSR
  input  wire        [63:0] i_riscv_estage_immextended          , //<--- TRAPS AND CSR
  input  wire        [ 2:0] i_riscv_estage_memext               , //<--- TRAPS AND CSR
  input  wire        [ 6:0] i_riscv_estage_opcode               , //<--- TRAPS AND CSR
  input  wire        [ 1:0] i_riscv_estage_storesrc             , //<--- TRAPS AND CSR
  input  wire        [ 1:0] i_riscv_estage_lr                   ,
  input  wire        [ 1:0] i_riscv_estage_sc                   ,
  input  wire               i_riscv_estage_amo                  ,
  input  wire               i_riscv_estage_memw                 ,
  input  wire               i_riscv_estage_memr                 ,
  input  wire               i_riscv_estage_gtrap                ,
  input  wire        [ 1:0] i_riscv_estage_rtrap                ,
  output wire signed [63:0] o_riscv_estage_result               ,
  output wire signed [63:0] o_riscv_estage_store_data           ,
  output wire               o_riscv_estage_branchtaken          ,
  output wire               o_riscv_estage_div_en               ,
  output wire               o_riscv_estage_mul_en               ,
  output wire               o_riscv_estage_icu_valid            ,
  output wire        [63:0] o_riscv_estage_csrwritedata         ,
  output wire               o_riscv_estage_inst_addr_misaligned ,
  output wire               o_riscv_estage_store_addr_misaligned,
  output wire               o_riscv_estage_load_addr_misaligned ,
  output wire               o_riscv_estage_dcache_wren          ,
  output wire               o_riscv_estage_dcache_rden          ,
  output wire        [63:0] o_riscv_estage_dcache_addr          ,
  output wire        [63:0] o_riscv_estage_rddata_sc            ,
  output wire               o_riscv_estage_timer_wren           ,
  output wire               o_riscv_estage_timer_rden           ,
  output wire        [ 1:0] o_riscv_estage_timer_regsel         ,
  output wire               o_riscv_estage_uart_tx_valid
);

//u_Forward_mux_A,B Connected to OperandA,B muxes Signals
  wire signed [63:0] o_riscv_FWmuxA_OperandmuxA;
  wire signed [63:0] o_riscv_FWmuxB_OperandmuxB;

//u_OperandA,B muxes  Connected to ALU  Signals
  wire signed [63:0] o_riscv_OperandmuxA_OperandALUA;
  wire signed [63:0] o_riscv_OperandmuxB_OperandALUB;

  assign o_riscv_estage_mul_en     = i_riscv_estage_mulctrl [3];
  assign o_riscv_estage_div_en     = i_riscv_estage_divctrl [3];
  assign o_riscv_estage_store_data = o_riscv_FWmuxB_OperandmuxB;


/************************ Forward A MUX ************************/
  riscv_mux4 u_Forward_mux_A (
    .i_riscv_mux4_sel(i_riscv_estage_fwda       ),
    .i_riscv_mux4_in0(i_riscv_estage_rs1data    ),
    .i_riscv_mux4_in1(i_riscv_estage_rdata_wb   ),
    .i_riscv_mux4_in2(i_riscv_estage_rddata_m   ),
    .i_riscv_mux4_in3(i_riscv_estage_imm_m      ),
    .o_riscv_mux4_out(o_riscv_FWmuxA_OperandmuxA)
  );

/************************ Forward B MUX ************************/
  riscv_mux4 u_Forward_mux_B (
    .i_riscv_mux4_sel(i_riscv_estage_fwdb       ),
    .i_riscv_mux4_in0(i_riscv_estage_rs2data    ),
    .i_riscv_mux4_in1(i_riscv_estage_rdata_wb   ),
    .i_riscv_mux4_in2(i_riscv_estage_rddata_m   ),
    .i_riscv_mux4_in3(i_riscv_estage_imm_m      ),
    .o_riscv_mux4_out(o_riscv_FWmuxB_OperandmuxB)
  );

/************************ Operand A MUX ************************/
  riscv_mux2 u_Operand_mux_A (
    .i_riscv_mux2_sel(i_riscv_estage_oprnd1sel       ),
    .i_riscv_mux2_in0(i_riscv_estage_pc              ),
    .i_riscv_mux2_in1(o_riscv_FWmuxA_OperandmuxA     ),
    .o_riscv_mux2_out(o_riscv_OperandmuxA_OperandALUA)
  );

/************************ Operand B MUX ************************/
  riscv_mux2 u_Operand_mux_B (
    .i_riscv_mux2_sel(i_riscv_estage_oprnd2sel       ),
    .i_riscv_mux2_in0(o_riscv_FWmuxB_OperandmuxB     ),
    .i_riscv_mux2_in1(i_riscv_estage_simm            ),
    .o_riscv_mux2_out(o_riscv_OperandmuxB_OperandALUB)
  );

/************************ Integrated Computational Unit ************************/
  riscv_icu u_icu (
    .i_riscv_icu_rs1data   (o_riscv_FWmuxA_OperandmuxA     ),
    .i_riscv_icu_rs2data   (o_riscv_FWmuxB_OperandmuxB     ),
    .i_riscv_icu_alurs1data(o_riscv_OperandmuxA_OperandALUA),
    .i_riscv_icu_alurs2data(o_riscv_OperandmuxB_OperandALUB),
    .i_riscv_icu_bcond     (i_riscv_estage_bcond           ),
    .i_riscv_icu_mulctrl   (i_riscv_estage_mulctrl         ),
    .i_riscv_icu_divctrl   (i_riscv_estage_divctrl         ),
    .i_riscv_icu_aluctrl   (i_riscv_estage_aluctrl         ),
    .i_riscv_icu_funcsel   (i_riscv_estage_funcsel         ),
    .i_riscv_icu_clk       (i_riscv_estage_clk             ),
    .i_riscv_icu_rst       (i_riscv_estage_rst             ),
    .o_riscv_branch_taken  (o_riscv_estage_branchtaken     ),
    .o_riscv_icu_valid     (o_riscv_estage_icu_valid       ),
    .o_riscv_icu_result    (o_riscv_estage_result          )
  );

/************************ Load Store Unit ************************/
  riscv_lsu u_riscv_lsu (
    .i_riscv_lsu_clk          (i_riscv_estage_clk          ),
    .i_riscv_lsu_rst          (i_riscv_estage_rst          ),
    .i_riscv_lsu_globstall    (i_riscv_estage_globstall    ),
    .i_riscv_lsu_address      (o_riscv_FWmuxA_OperandmuxA  ),
    .i_riscv_lsu_alu_result   (o_riscv_estage_result       ),
    .i_riscv_lsu_lr           (i_riscv_estage_lr           ),
    .i_riscv_lsu_sc           (i_riscv_estage_sc           ),
    .i_riscv_lsu_amo          (i_riscv_estage_amo          ),
    .i_riscv_lsu_dcache_wren  (i_riscv_estage_memw         ),
    .i_riscv_lsu_dcache_rden  (i_riscv_estage_memr         ),
    .i_riscv_lsu_goto_trap    (i_riscv_estage_gtrap        ),
    .i_riscv_lsu_return_trap  (i_riscv_estage_rtrap        ),
    .i_riscv_lsu_misalignment (1'b0                        ),
    .o_riscv_lsu_dcache_wren  (o_riscv_estage_dcache_wren  ),
    .o_riscv_lsu_dcache_rden  (o_riscv_estage_dcache_rden  ),
    .o_riscv_lsu_phy_address  (o_riscv_estage_dcache_addr  ),
    .o_riscv_lsu_sc_rdvalue   (o_riscv_estage_rddata_sc    ),
    .o_riscv_lsu_timer_wren   (o_riscv_estage_timer_wren   ),
    .o_riscv_lsu_timer_rden   (o_riscv_estage_timer_rden   ),
    .o_riscv_lsu_timer_regsel (o_riscv_estage_timer_regsel ),
    .o_riscv_lsu_uart_tx_valid(o_riscv_estage_uart_tx_valid)
  );

/************************ Exception Unit ************************/
  riscv_misalignment_unit u_riscv_misalignment_unit (
    .i_riscv_misalignment_opcode               (i_riscv_estage_opcode               ),
    .i_riscv_misalignment_icu_result           (o_riscv_estage_result               ),
    .i_riscv_misalignment_branch_taken         (o_riscv_estage_branchtaken          ),
    .i_riscv_misalignment_load_sel             (i_riscv_estage_memext               ),
    .i_riscv_misalignment_store_sel            (i_riscv_estage_storesrc             ),
    .o_riscv_misalignment_store_addr_misaligned(o_riscv_estage_store_addr_misaligned),
    .o_riscv_misalignment_load_addr_misaligned (o_riscv_estage_load_addr_misaligned ),
    .o_riscv_misalignment_inst_addr_misaligned (o_riscv_estage_inst_addr_misaligned )
  );

/************************ Zero Extend Imm ************************/
  riscv_mux2 u_imm_reg_mux (
    .i_riscv_mux2_sel(i_riscv_estage_imm_reg     ),
    .i_riscv_mux2_in0(o_riscv_FWmuxA_OperandmuxA ),
    .i_riscv_mux2_in1(i_riscv_estage_immextended ),
    .o_riscv_mux2_out(o_riscv_estage_csrwritedata)
  );

endmodule
