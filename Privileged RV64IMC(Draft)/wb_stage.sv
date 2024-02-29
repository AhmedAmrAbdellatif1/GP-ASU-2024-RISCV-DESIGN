module riscv_wbstage #(parameter width=64) (
input  logic [1:0]         i_riscv_wb_resultsrc,
input  logic [width-1:0]   i_riscv_wb_pcplus4,
input  logic [width-1:0]   i_riscv_wb_result,
input  logic [width-1:0]   i_riscv_wb_memload,
input  logic [width-1:0]   i_riscv_wb_uimm,
output logic [width-1:0]   o_riscv_wb_rddata ,  //modified position

//trap (//From mw Register input signals )
input logic  [width-1:0]   i_riscv_wb_csrout ,
input logic                i_riscv_wb_iscsr  ,
input logic                i_riscv_wb_gototrap  ,
input logic                i_riscv_wb_returnfromtrap  ,
output logic  [1:0]        o_riscv_wb_pcsel  ,
output logic               o_riscv_wb_flush
);
//added
logic [width-1:0] riscv_wb_rddata ;

riscv_mux4 u_result_mux (
.i_riscv_mux4_sel(i_riscv_wb_resultsrc),
.i_riscv_mux4_in0(i_riscv_wb_pcplus4),
.i_riscv_mux4_in1(i_riscv_wb_result),
.i_riscv_mux4_in2(i_riscv_wb_memload),
.i_riscv_mux4_in3(i_riscv_wb_uimm),
.o_riscv_mux4_out(riscv_wb_rddata));  //chnaged

riscv_trap_wb trap_wb (
     
.i_riscv_trap_gototrap(i_riscv_wb_gototrap) ,              //From mw Register       
.i_riscv_trap_returnfromtrap(i_riscv_wb_returnfromtrap)  ,  //From mw Register  
.o_riscv_trap_flush(o_riscv_wb_flush)  ,                    //to all piplene or hazard ??
.o_riscv_trap_pcsel(o_riscv_wb_pcsel)                       //to fetch stage
     
   ) ;


riscv_mux2 mux2_wb (
.i_riscv_mux2_sel(i_riscv_wb_iscsr),   //From mw Register
.i_riscv_mux2_in0(riscv_wb_rddata),    //  from above reuslt mux
.i_riscv_mux2_in1(i_riscv_wb_csrout),  //From mw Register
.o_riscv_mux2_out(o_riscv_wb_rddata)  

);
  
  
endmodule 

