module riscv_wbstage (
   input    logic [2:0]    i_riscv_wb_resultsrc       ,
   input    logic [63:0]   i_riscv_wb_pcplus4         ,
   input    logic [63:0]   i_riscv_wb_result          ,
   input    logic [63:0]   i_riscv_wb_memload         ,
   input    logic [63:0]   i_riscv_wb_uimm            ,
   input    logic [63:0]   i_riscv_wb_csrout          ,
   input    logic          i_riscv_wb_iscsr           ,
   input    logic          i_riscv_wb_gototrap        ,
   input    logic [1:0]    i_riscv_wb_returnfromtrap  ,
   input    logic          i_riscv_wb_icache_stall    ,
   input    logic [63:0]   i_riscv_wb_rddata_sc       ,
   output   logic [1:0]    o_riscv_wb_pcsel           ,
   output   logic          o_riscv_wb_flush           ,
   output   logic [63:0]   o_riscv_wb_rddata           
);

logic [63:0] riscv_wb_rddata ;

riscv_mux5 u_result_mux (
   .i_riscv_mux5_sel  (i_riscv_wb_resultsrc),
   .i_riscv_mux5_in0  (i_riscv_wb_pcplus4)  ,
   .i_riscv_mux5_in1  (i_riscv_wb_result)   ,
   .i_riscv_mux5_in2  (i_riscv_wb_memload)  ,
   .i_riscv_mux5_in3  (i_riscv_wb_uimm)     , 
   .i_riscv_mux5_in4  (i_riscv_wb_rddata_sc),
   .o_riscv_mux5_out  (riscv_wb_rddata)
);

riscv_trap_wb trap_wb (
  .i_riscv_trap_gototrap        (i_riscv_wb_gototrap)         ,                  
  .i_riscv_trap_returnfromtrap  (i_riscv_wb_returnfromtrap)   ,
  .i_riscv_trap_icache_stall    (i_riscv_wb_icache_stall)     ,
  .o_riscv_trap_flush           (o_riscv_wb_flush)            ,                    
  .o_riscv_trap_pcsel           (o_riscv_wb_pcsel)                       
);

riscv_mux2 mux2_wb (
  .i_riscv_mux2_sel (i_riscv_wb_iscsr)  ,   
  .i_riscv_mux2_in0 (riscv_wb_rddata)   ,     
  .i_riscv_mux2_in1 (i_riscv_wb_csrout) ,  
  .o_riscv_mux2_out (o_riscv_wb_rddata)  
);

endmodule 