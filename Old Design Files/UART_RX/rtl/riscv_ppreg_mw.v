  module riscv_ppreg_mw(
    //------------------------------------------------>
   
    input   wire [31:0]  i_riscv_mw_inst             ,
    input   wire [15:0]  i_riscv_mw_cinst            ,
    input   wire [63:0]  i_riscv_mw_memaddr          ,
    input   wire [63:0]  i_riscv_mw_pc               ,
    input   wire [63:0]  i_riscv_mw_rs2data          ,
    output  reg [31:0]  o_riscv_mw_inst             ,
    output  reg [15:0]  o_riscv_mw_cinst            ,
    output  reg [63:0]  o_riscv_mw_memaddr          ,
    output  reg [63:0]  o_riscv_mw_pc               ,
    output  reg [63:0]  o_riscv_mw_rs2data          ,
   
    //<------------------------------------------------
    input   wire         i_riscv_mw_clk              , 
    input   wire         i_riscv_mw_rst              , 
    input   wire         i_riscv_mw_en               , 
    input   wire [63:0]  i_riscv_mw_pcplus4_m        ,
    input   wire [63:0]  i_riscv_mw_result_m         ,
    input   wire [63:0]  i_riscv_mw_uimm_m           ,
    input   wire [63:0]  i_riscv_mw_memload_m        ,
    input   wire [4:0]   i_riscv_mw_rdaddr_m         ,
    input   wire [2:0]   i_riscv_mw_resultsrc_m      ,
    input   wire         i_riscv_mw_regw_m           ,
    input   wire         i_riscv_mw_flush            , //<--- trap
    input   wire [63:0]  i_riscv_mw_csrout_m         , //<--- trap
    input   wire         i_riscv_mw_iscsr_m          , //<--- trap
    input   wire         i_riscv_mw_gototrap_m       , //<--- trap
    input   wire [1:0]   i_riscv_mw_returnfromtrap_m , //<--- trap
    input   wire         i_riscv_mw_instret_m        , //<--- csr
    input   wire [63:0]  i_riscv_mw_rddata_sc_m      ,
    output  reg [63:0]  o_riscv_mw_rddata_sc_wb     ,
    output  reg         o_riscv_mw_instret_wb       , //<--- csr
    output  reg [63:0]  o_riscv_mw_pcplus4_wb       ,
    output  reg [63:0]  o_riscv_mw_result_wb        ,
    output  reg [63:0]  o_riscv_mw_uimm_wb          ,
    output  reg [63:0]  o_riscv_mw_memload_wb       ,
    output  reg [4:0]   o_riscv_mw_rdaddr_wb        ,
    output  reg [2:0]   o_riscv_mw_resultsrc_wb     ,
    output  reg         o_riscv_mw_regw_wb          ,
    output  reg [63:0]  o_riscv_mw_csrout_wb        , //<--- csr
    output  reg         o_riscv_mw_iscsr_wb         , //<--- csr
    output  reg         o_riscv_mw_gototrap_wb      , //<--- csr
    output  reg [1:0]   o_riscv_mw_returnfromtrap_wb  //<--- csr
  );  

  always @(posedge i_riscv_mw_clk or posedge i_riscv_mw_rst)
    begin:mw_pff_write_proc
      if(i_riscv_mw_rst)
        begin
          o_riscv_mw_pcplus4_wb        <='b0;
          o_riscv_mw_result_wb         <='b0;
          o_riscv_mw_uimm_wb           <='b0;
          o_riscv_mw_memload_wb        <='b0;
          o_riscv_mw_rdaddr_wb         <='b0;
          o_riscv_mw_resultsrc_wb      <='b0;
          o_riscv_mw_regw_wb           <='b0;
          o_riscv_mw_csrout_wb         <='b0;
          o_riscv_mw_iscsr_wb          <='b0;
          o_riscv_mw_gototrap_wb       <='b0;
          o_riscv_mw_returnfromtrap_wb <='b0;
          o_riscv_mw_instret_wb        <='b0;
          o_riscv_mw_rddata_sc_wb      <='b0;
          //---------------------------->
         
          o_riscv_mw_inst              <='b0;  
          o_riscv_mw_cinst             <='b0;
          o_riscv_mw_pc                <='b0;
          o_riscv_mw_memaddr           <='b0;
          o_riscv_mw_rs2data           <='b0;
         
          //<----------------------------
        end
      else if (i_riscv_mw_flush) begin
          o_riscv_mw_pcplus4_wb         <='b0;
          o_riscv_mw_result_wb          <='b0;
          o_riscv_mw_uimm_wb            <='b0;
          o_riscv_mw_memload_wb         <='b0;
          o_riscv_mw_rdaddr_wb          <='b0;
          o_riscv_mw_resultsrc_wb       <='b0;
          o_riscv_mw_regw_wb            <='b0;
          o_riscv_mw_csrout_wb          <='b0;
          o_riscv_mw_iscsr_wb           <='b0;
          o_riscv_mw_gototrap_wb        <='b0;
          o_riscv_mw_returnfromtrap_wb  <='b0;
          o_riscv_mw_instret_wb         <='b0;
          o_riscv_mw_rddata_sc_wb       <='b0;
          //---------------------------->
         
          o_riscv_mw_inst               <='b0;  
          o_riscv_mw_cinst              <='b0;
          o_riscv_mw_pc                 <='b0;
          o_riscv_mw_memaddr            <='b0;
          o_riscv_mw_rs2data            <='b0;
         
          //<----------------------------
        end
        else if (!i_riscv_mw_en) begin
          o_riscv_mw_pcplus4_wb         <=  i_riscv_mw_pcplus4_m;
          o_riscv_mw_result_wb          <=  i_riscv_mw_result_m;
          o_riscv_mw_uimm_wb            <=  i_riscv_mw_uimm_m;
          o_riscv_mw_memload_wb         <=  i_riscv_mw_memload_m;
          o_riscv_mw_rdaddr_wb          <=  i_riscv_mw_rdaddr_m;
          o_riscv_mw_resultsrc_wb       <=  i_riscv_mw_resultsrc_m;
          o_riscv_mw_regw_wb            <=  i_riscv_mw_regw_m;
          o_riscv_mw_csrout_wb          <=  i_riscv_mw_csrout_m ;
          o_riscv_mw_iscsr_wb           <=  i_riscv_mw_iscsr_m ;
          o_riscv_mw_gototrap_wb        <=  i_riscv_mw_gototrap_m ;
          o_riscv_mw_returnfromtrap_wb  <=  i_riscv_mw_returnfromtrap_m;
          o_riscv_mw_instret_wb         <=  i_riscv_mw_instret_m;
          o_riscv_mw_rddata_sc_wb       <=  i_riscv_mw_rddata_sc_m;

          //------------------------------------------->
         
          o_riscv_mw_inst               <=  i_riscv_mw_inst;
          o_riscv_mw_cinst              <=  i_riscv_mw_cinst;
          o_riscv_mw_pc                 <=  i_riscv_mw_pc;
          o_riscv_mw_memaddr            <=  i_riscv_mw_memaddr;
          o_riscv_mw_rs2data            <=  i_riscv_mw_rs2data;
         
         //<---------------------------------------------
        end
        else
         o_riscv_mw_instret_wb        <='b0;
      end
endmodule