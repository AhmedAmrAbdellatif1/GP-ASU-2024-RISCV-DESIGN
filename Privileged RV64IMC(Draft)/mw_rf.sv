  module riscv_mw_ppreg(
    //------------------------------------------------>
    `ifdef TEST
    input   logic [31:0]  i_riscv_mw_inst             ,
    input   logic [15:0]  i_riscv_mw_cinst            ,
    input   logic [63:0]  i_riscv_mw_memaddr          ,
    input   logic [63:0]  i_riscv_mw_pc               ,
    input   logic [63:0]  i_riscv_mw_rs2data          ,
    output  logic [31:0]  o_riscv_mw_inst             ,
    output  logic [15:0]  o_riscv_mw_cinst            ,
    output  logic [63:0]  o_riscv_mw_memaddr          ,
    output  logic [63:0]  o_riscv_mw_pc               ,
    output  logic [63:0]  o_riscv_mw_rs2data          ,
    `endif
    //<------------------------------------------------
    input   logic         i_riscv_mw_clk              , 
    input   logic         i_riscv_mw_rst              , 
    input   logic         i_riscv_mw_en               , 
    input   logic [63:0]  i_riscv_mw_pcplus4_m        ,
    input   logic [63:0]  i_riscv_mw_result_m         ,
    input   logic [63:0]  i_riscv_mw_uimm_m           ,
    input   logic [63:0]  i_riscv_mw_memload_m        ,
    input   logic [4:0]   i_riscv_mw_rdaddr_m         ,
    input   logic [1:0]   i_riscv_mw_resultsrc_m      ,
    input   logic         i_riscv_mw_regw_m           ,
    output  logic [63:0]  o_riscv_mw_pcplus4_wb       ,
    output  logic [63:0]  o_riscv_mw_result_wb        ,
    output  logic [63:0]  o_riscv_mw_uimm_wb          ,
    output  logic [63:0]  o_riscv_mw_memload_wb       ,
    output  logic [4:0]   o_riscv_mw_rdaddr_wb        ,
    output  logic [1:0]   o_riscv_mw_resultsrc_wb     ,
    output  logic         o_riscv_mw_regw_wb          ,

    //Trap 
    input logic            i_riscv_mw_flush           ,
    input logic  [63:0]    i_riscv_mw_csrout_m         ,
    input logic           i_riscv_mw_iscsr_m          ,
    input logic           i_riscv_mw_gototrap_m       ,
    input logic           i_riscv_mw_returnfromtrap_m ,


    output logic  [63:0]  o_riscv_mw_csrout_wb         ,
    output logic          o_riscv_mw_iscsr_wb          ,
    output logic          o_riscv_mw_gototrap_wb       ,
    output logic          o_riscv_mw_returnfromtrap_wb 
  );  
  always_ff @(posedge i_riscv_mw_clk or posedge i_riscv_mw_rst )
    begin:mw_pff_write_proc
      if(i_riscv_mw_rst)
        begin
         o_riscv_mw_pcplus4_wb    <='b0;
         o_riscv_mw_result_wb     <='b0;
         o_riscv_mw_uimm_wb       <='b0;
         o_riscv_mw_memload_wb    <='b0;
         o_riscv_mw_rdaddr_wb     <='b0;
         o_riscv_mw_resultsrc_wb  <='b0;
         o_riscv_mw_regw_wb       <='b0;


         //trap
         o_riscv_mw_csrout_wb         <='b0;
         o_riscv_mw_iscsr_wb          <='b0;
         o_riscv_mw_gototrap_wb       <='b0;
         o_riscv_mw_returnfromtrap_wb <='b0;
         //---------------------------->
         `ifdef TEST
         o_riscv_mw_inst          <='b0;  
         o_riscv_mw_cinst         <='b0;
         o_riscv_mw_memaddr       <='b0;
         o_riscv_mw_pc            <='b0;
         o_riscv_mw_rs2data       <='b0;
     
         `endif
         //<----------------------------
        end
      else
        begin
         
         if (i_riscv_mw_flush) begin
          o_riscv_mw_pcplus4_wb    <='b0;
         o_riscv_mw_result_wb     <='b0;
         o_riscv_mw_uimm_wb       <='b0;
         o_riscv_mw_memload_wb    <='b0;
         o_riscv_mw_rdaddr_wb     <='b0;
         o_riscv_mw_resultsrc_wb  <='b0;
         o_riscv_mw_regw_wb       <='b0;
         //trap
         o_riscv_mw_csrout_wb         <='b0;
         o_riscv_mw_iscsr_wb          <='b0;
         o_riscv_mw_gototrap_wb       <='b0;
         o_riscv_mw_returnfromtrap_wb <='b0;

            `ifdef TEST
         o_riscv_mw_inst          <='b0;  
         o_riscv_mw_cinst         <='b0;
         o_riscv_mw_memaddr       <='b0;
         o_riscv_mw_pc            <='b0;
         o_riscv_mw_rs2data       <='b0;
     
         `endif
            

         end

         else if (i_riscv_mw_en)
          begin
          o_riscv_mw_pcplus4_wb     <= o_riscv_mw_pcplus4_wb;
          o_riscv_mw_result_wb      <= o_riscv_mw_result_wb;
          o_riscv_mw_uimm_wb        <= o_riscv_mw_uimm_wb;
          o_riscv_mw_memload_wb     <= o_riscv_mw_memload_wb;
          o_riscv_mw_rdaddr_wb      <= o_riscv_mw_rdaddr_wb;
          o_riscv_mw_resultsrc_wb   <= o_riscv_mw_resultsrc_wb;
          o_riscv_mw_regw_wb        <= o_riscv_mw_regw_wb;

          //trap

          o_riscv_mw_csrout_wb         <= o_riscv_mw_csrout_wb;
          o_riscv_mw_iscsr_wb          <= o_riscv_mw_iscsr_wb;
          o_riscv_mw_gototrap_wb       <= o_riscv_mw_gototrap_wb;
          o_riscv_mw_returnfromtrap_wb <= o_riscv_mw_returnfromtrap_wb;
          //--------------------------------------------->
          `ifdef TEST
          o_riscv_mw_inst           <= o_riscv_mw_inst;
          o_riscv_mw_cinst          <= o_riscv_mw_cinst;
          `endif
          //<---------------------------------------------
          end
        else
          begin
          o_riscv_mw_pcplus4_wb   <=  i_riscv_mw_pcplus4_m;
          o_riscv_mw_result_wb    <=  i_riscv_mw_result_m;
          o_riscv_mw_uimm_wb      <=  i_riscv_mw_uimm_m;
          o_riscv_mw_memload_wb   <=  i_riscv_mw_memload_m;
          o_riscv_mw_rdaddr_wb    <=  i_riscv_mw_rdaddr_m;
          o_riscv_mw_resultsrc_wb <=  i_riscv_mw_resultsrc_m;
          o_riscv_mw_regw_wb      <=  i_riscv_mw_regw_m;
          //trap
          o_riscv_mw_csrout_wb         <= i_riscv_mw_csrout_m ;
          o_riscv_mw_iscsr_wb          <= i_riscv_mw_iscsr_m ;
          o_riscv_mw_gototrap_wb       <= i_riscv_mw_gototrap_m ;
          o_riscv_mw_returnfromtrap_wb <= i_riscv_mw_returnfromtrap_m;
          //------------------------------------------->
          `ifdef TEST
          o_riscv_mw_inst         <=  i_riscv_mw_inst;
          o_riscv_mw_cinst        <=  i_riscv_mw_cinst;
          o_riscv_mw_memaddr      <=  i_riscv_mw_memaddr;
          o_riscv_mw_pc           <=  i_riscv_mw_pc;
          o_riscv_mw_rs2data      <=  i_riscv_mw_rs2data;
          `endif
         //<---------------------------------------------
        end
      end
    end
  endmodule