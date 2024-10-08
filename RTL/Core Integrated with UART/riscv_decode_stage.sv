module  riscv_dstage (
  input   logic         i_riscv_dstage_clk_n          ,
  input   logic         i_riscv_dstage_regw           ,
  input   logic [2:0]   i_riscv_dstage_immsrc         ,
  input   logic [31:0]  i_riscv_dstage_inst           ,
  input   logic [4:0]   i_riscv_dstage_rdaddr         ,    
  input   logic [63:0]  i_riscv_dstage_rddata         ,
  output  logic [63:0]  o_riscv_dstage_rs1data        ,  
  output  logic [63:0]  o_riscv_dstage_rs2data        ,  
  output  logic [4:0]   o_riscv_dstage_rs1addr        ,  
  output  logic [4:0]   o_riscv_dstage_rs2addr        ,  
  output  logic [4:0]   o_riscv_dstage_rdaddr         ,   
  output  logic [63:0]  o_riscv_dstage_simm           ,
  output  logic [6:0]   o_riscv_dstage_opcode         ,
  output  logic [2:0]   o_riscv_dstage_funct3         ,
  output  logic [6:0]   o_riscv_dstage_func7        ,
  output  logic [63:0]  o_riscv_dstage_immzeroextend    //<---
); 


  assign o_riscv_dstage_func7   = i_riscv_dstage_inst[31:25];
  assign o_riscv_dstage_opcode  = i_riscv_dstage_inst[6:0];
  assign o_riscv_dstage_rs1addr = i_riscv_dstage_inst[19:15];
  assign o_riscv_dstage_rs2addr = i_riscv_dstage_inst[24:20];
  assign o_riscv_dstage_funct3  = i_riscv_dstage_inst[14:12];
  assign o_riscv_dstage_rdaddr  = i_riscv_dstage_inst[11:7];


/************************* ************** *************************/
/************************* Instantiations *************************/
/************************* ************** *************************/

  riscv_rf u_riscv_rf(
    .i_riscv_rf_clk_n     (i_riscv_dstage_clk_n)      ,
    .i_riscv_rf_regwrite  (i_riscv_dstage_regw)       ,
    .i_riscv_rf_rs1addr   (i_riscv_dstage_inst[19:15]),
    .i_riscv_rf_rs2addr   (i_riscv_dstage_inst[24:20]),
    .i_riscv_rf_rdaddr    (i_riscv_dstage_rdaddr)     ,
    .i_riscv_rf_rddata    (i_riscv_dstage_rddata)     ,
    .o_riscv_rf_rs1data   (o_riscv_dstage_rs1data)    ,
    .o_riscv_rf_rs2data   (o_riscv_dstage_rs2data)
  );

  riscv_extend u_riscv_extend(
    .i_riscv_extend_immsrc(i_riscv_dstage_immsrc)     ,
    .i_riscv_extend_inst  (i_riscv_dstage_inst[31:7]) ,
    .o_riscv_extend_simm  (o_riscv_dstage_simm)
  );


  riscv_zeroextend  u_riscv_zeroextend (
    .i_riscv_zeroextend_imm       (i_riscv_dstage_inst[19:15])  ,     
    .o_riscv_zeroextend_immextend (o_riscv_dstage_immzeroextend)  
  ) ;

endmodule