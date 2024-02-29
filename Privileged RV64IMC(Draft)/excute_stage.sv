module riscv_estage #(parameter width=64)(
  input   logic                     i_riscv_estage_clk            ,
  input   logic                     i_riscv_estage_rst            ,
  input   logic [width-1:0]         i_riscv_estage_imm_m          ,
  input   logic signed [width-1:0]  i_riscv_estage_rs1data        ,   //Common Signals to Forward_mux_A,B
  input   logic signed [width-1:0]  i_riscv_estage_rs2data        ,   //Common Signals to Forward_mux_A,B
  input   logic  [1:0]              i_riscv_estage_fwda           ,   //u_Forward_mux_A Signals
  input   logic   [1:0]             i_riscv_estage_fwdb           ,   //u_Forward_mux_B Signals
  input   logic signed [width-1:0]  i_riscv_estage_rdata_wb       ,   //u_Forward_mux_A,B Signals                      
  input   logic signed [width-1:0]  i_riscv_estage_rddata_m       ,   //u_Forward_mux_A,B Signals         
  input   logic                     i_riscv_estage_oprnd1sel      ,   //u_Forward_mux_ operand A ,B Signals
  input   logic                     i_riscv_estage_oprnd2sel      ,   //u_Forward_mux_ operand A ,B Signals
  input   logic [width-1:0]         i_riscv_estage_pc             ,   //u_ALU Signals
  input   logic  [ 5 : 0 ]          i_riscv_estage_aluctrl        ,   //u_ALU Signals                             
  input   logic  [ 3 : 0 ]          i_riscv_estage_mulctrl        , 
  input   logic [ 3 : 0 ]           i_riscv_estage_divctrl        , 
  input   logic [ 1 : 0 ]           i_riscv_estage_funcsel        , 
  input   logic signed [width-1:0]  i_riscv_estage_simm           ,   //Operand2 MUX signal
  input   logic [ 3:0 ]             i_riscv_estage_bcond          ,   //u_Branch Comparator Siganls
  output  logic signed [width-1:0]  o_riscv_estage_result         ,   //  Signals to E/M FF
  output  logic signed [width-1:0]  o_riscv_estage_store_data     ,   //  Signals to E/M FF
  output  logic                     o_riscv_estage_branchtaken    ,   // Branch Comparator  Signals to hazard_unit
  output  logic                     o_riscv_estage_div_en         ,   // Branch Comparator  Signals to hazard_unit
  output  logic                     o_riscv_estage_mul_en         ,   // Branch Comparator  Signals to hazard_unit
  output  logic                     o_riscv_estage_icu_valid      ,
  
  //trap 
  input  logic                      i_riscv_estage_imm_reg        ,
  input  logic  [width-1:0]         i_riscv_estage_immextended    ,
  output logic  [width-1:0]         o_riscv_estage_csrwritedata   ,
  
  input  logic  [6:0]               i_riscv_stage_opcode          ,
  input  logic  [2:0]               i_riscv_estage_memext         ,
  input  logic  [1:0]               i_riscv_estage_storesrc       ,   
  
  output logic                      o_riscv_estage_inst_addr_misaligned,
  output logic                      o_riscv_estage_store_addr_misaligned,
  output logic                      o_riscv_estage_load_addr_misaligned          

); 

//u_Forward_mux_A,B Connected to OperandA,B muxes Signals
 logic signed  [width-1:0]    o_riscv_FWmuxA_OperandmuxA ;
 logic signed  [width-1:0]    o_riscv_FWmuxB_OperandmuxB ;

//u_OperandA,B muxes  Connected to ALU  Signals
logic  signed  [width-1:0]  o_riscv_OperandmuxA_OperandALUA ;
logic  signed [width-1:0]   o_riscv_OperandmuxB_OperandALUB ;


assign o_riscv_estage_mul_en      = i_riscv_estage_mulctrl [3];
assign o_riscv_estage_div_en      = i_riscv_estage_divctrl [3]; 
assign o_riscv_estage_store_data  = o_riscv_FWmuxB_OperandmuxB;


/////////////////////////// ForwardA MUX //////////////////////
riscv_mux4 u_Forward_mux_A (
.i_riscv_mux4_sel(i_riscv_estage_fwda),
.i_riscv_mux4_in0(i_riscv_estage_rs1data),
.i_riscv_mux4_in1(i_riscv_estage_rdata_wb),
.i_riscv_mux4_in2(i_riscv_estage_rddata_m),
.i_riscv_mux4_in3(i_riscv_estage_imm_m),
.o_riscv_mux4_out(o_riscv_FWmuxA_OperandmuxA) );


/////////////////////////// ForwardB MUX //////////////////////
riscv_mux4 u_Forward_mux_B (
.i_riscv_mux4_sel(i_riscv_estage_fwdb),
.i_riscv_mux4_in0(i_riscv_estage_rs2data),
.i_riscv_mux4_in1(i_riscv_estage_rdata_wb),
.i_riscv_mux4_in2(i_riscv_estage_rddata_m),
.i_riscv_mux4_in3(i_riscv_estage_imm_m),
.o_riscv_mux4_out(o_riscv_FWmuxB_OperandmuxB) );

///////////////////////////Operand_mux_A//////////////////////
riscv_mux2 u_Operand_mux_A(
.i_riscv_mux2_sel(i_riscv_estage_oprnd1sel),
.i_riscv_mux2_in0(i_riscv_estage_pc),
.i_riscv_mux2_in1(o_riscv_FWmuxA_OperandmuxA),
.o_riscv_mux2_out(o_riscv_OperandmuxA_OperandALUA));


///////////////////////////Operand_mux_B//////////////////////
riscv_mux2 u_Operand_mux_B(
.i_riscv_mux2_sel(i_riscv_estage_oprnd2sel),
.i_riscv_mux2_in0(o_riscv_FWmuxB_OperandmuxB),
.i_riscv_mux2_in1(i_riscv_estage_simm),
.o_riscv_mux2_out(o_riscv_OperandmuxB_OperandALUB));

/*
///////////////////////////ALU//////////////////////
 riscv_alu u_ALU (
   .i_riscv_alu_ctrl(i_riscv_estage_aluctrl),
   .i_riscv_alu_rs1data(o_riscv_OperandmuxA_OperandALUA),
   .i_riscv_alu_rs2data(o_riscv_OperandmuxB_OperandALUB),
   .o_riscv_alu_result(o_riscv_estage_aluresult)
   );

 riscv_branch u_risc_branch (
    .i_riscv_branch_cond(i_riscv_estage_bcond)    , 
    .i_riscv_branch_rs1data(i_riscv_estage_rs1data) ,   
    .i_riscv_branch_rs2data(i_riscv_estage_rs2data) , 
    .o_riscv_branch_taken(o_riscv_estage_branchtaken)
    );
    */

  ///////////////////////////////////ICU//////////////////
riscv_ICU u_icu (
  .i_riscv_icu_rs1data      (o_riscv_FWmuxA_OperandmuxA),
  .i_riscv_icu_rs2data      (o_riscv_FWmuxB_OperandmuxB),
  .i_riscv_icu_alurs1data   (o_riscv_OperandmuxA_OperandALUA),
  .i_riscv_icu_alurs2data   (o_riscv_OperandmuxB_OperandALUB),
  .i_riscv_icu_bcond        (i_riscv_estage_bcond),
  .i_riscv_icu_mulctrl      (i_riscv_estage_mulctrl),
  .i_riscv_icu_divctrl      (i_riscv_estage_divctrl),
  .i_riscv_icu_aluctrl      (i_riscv_estage_aluctrl),
  .i_riscv_icu_funcsel      (i_riscv_estage_funcsel),
  .i_riscv_icu_clk          (i_riscv_estage_clk),
  .i_riscv_icu_rst          (i_riscv_estage_rst),
  .o_riscv_branch_taken     (o_riscv_estage_branchtaken),
  .o_riscv_icu_valid        (o_riscv_estage_icu_valid),
  .o_riscv_icu_result       (o_riscv_estage_result)
);

exception_unit u_exception(
.i_riscv_exception_opcode(i_riscv_stage_opcode),
.i_riscv_exception_icu_result(o_riscv_estage_result),
.i_riscv_exception_branch_taken(o_riscv_estage_branchtaken),
.i_riscv_exception_load_sel(i_riscv_estage_memext ),
.i_riscv_exception_store_sel(i_riscv_estage_storesrc),
.o_riscv_exception_store_addr_misaligned(o_riscv_estage_store_addr_misaligned),
.o_riscv_exception_load_addr_misaligned(o_riscv_estage_load_addr_misaligned),
.o_riscv_exception_inst_addr_misaligned(o_riscv_estage_inst_addr_misaligned)
);



////////////////////////ImmReg MUX/////////////////////////
riscv_mux2 u_imm_reg_mux(
.i_riscv_mux2_sel(i_riscv_estage_imm_reg),  // >> need to be checked  ?? where come from
.i_riscv_mux2_in0(i_riscv_estage_rs1data),    // >> is as it is signed will make problem
.i_riscv_mux2_in1(i_riscv_estage_immextended),
.o_riscv_mux2_out(i_riscv_estage_csrwritedata));

endmodule
