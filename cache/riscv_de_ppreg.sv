  module riscv_de_ppreg(
      //------------------------------------------------>
      `ifdef TEST
      input  logic [31:0]  i_riscv_de_inst              ,
      input  logic [15:0]  i_riscv_de_cinst             ,
      output logic [31:0]  o_riscv_de_inst              ,
      output logic [15:0]  o_riscv_de_cinst             ,
      `endif
      //<------------------------------------------------
      input  logic          i_riscv_de_clk              ,
      input  logic          i_riscv_de_rst              ,
      input  logic          i_riscv_de_flush            ,
      input  logic          i_riscv_de_en               ,
      input  logic  [63:0]  i_riscv_de_pc_d             ,
      input  logic  [4:0]   i_riscv_de_rs1addr_d        ,
      input  logic  [63:0]  i_riscv_de_rs1data_d        ,
      input  logic  [63:0]  i_riscv_de_rs2data_d        ,
      input  logic  [4:0]   i_riscv_de_rs2addr_d        ,
      input  logic  [4:0]   i_riscv_de_rdaddr_d         ,
      input  logic  [63:0]  i_riscv_de_extendedimm_d    ,
      input  logic  [3:0]   i_riscv_de_b_condition_d    ,
      input  logic          i_riscv_de_oprnd2sel_d      ,
      input  logic  [1:0]   i_riscv_de_storesrc_d       ,
      input  logic  [5:0]   i_riscv_de_alucontrol_d     ,
      input  logic  [3:0]   i_riscv_de_mulctrl_d        ,
      input  logic  [3:0]   i_riscv_de_divctrl_d        ,
      input  logic  [1:0]   i_riscv_de_funcsel_d        , 
      input  logic          i_riscv_de_oprnd1sel_d      ,
      input  logic          i_riscv_de_memwrite_d       ,
      input  logic  [2:0]   i_riscv_de_memext_d         ,
      input  logic  [1:0]   i_riscv_de_resultsrc_d      ,
      input  logic          i_riscv_de_regwrite_d       ,    
      input  logic          i_riscv_de_jump_d           ,
      input  logic  [63:0]  i_riscv_de_pcplus4_d        ,
      input  logic  [6:0]   i_riscv_de_opcode_d         ,
      output logic  [63:0]  o_riscv_de_pc_e             ,
      output logic  [63:0]  o_riscv_de_pcplus4_e        ,
      output logic  [4:0]   o_riscv_de_rs1addr_e        ,
      output logic  [63:0]  o_riscv_de_rs1data_e        , 
      output logic  [63:0]  o_riscv_de_rs2data_e        ,
      output logic  [4:0]   o_riscv_de_rs2addr_e        ,
      output logic  [4:0]   o_riscv_de_rdaddr_e         ,  
      output logic  [63:0]  o_riscv_de_extendedimm_e    ,
      output logic  [3:0]   o_riscv_de_b_condition_e    ,
      output logic          o_riscv_de_oprnd2sel_e      ,
      output logic  [1:0]   o_riscv_de_storesrc_e       ,
      output logic  [5:0]   o_riscv_de_alucontrol_e     ,
      output logic  [3:0]   o_riscv_de_mulctrl_e        ,
      output logic  [3:0]   o_riscv_de_divctrl_e        ,
      output logic  [1:0]   o_riscv_de_funcsel_e        ,
      output logic          o_riscv_de_oprnd1sel_e      ,   
      output logic          o_riscv_de_memwrite_e       ,
      output logic  [2:0]   o_riscv_de_memext_e         ,
      output logic  [1:0]   o_riscv_de_resultsrc_e      ,
      output logic          o_riscv_de_regwrite_e       ,
      output logic          o_riscv_de_jump_e           ,
      output logic [6:0]    o_riscv_de_opcode_e
  );
    always_ff @(posedge i_riscv_de_clk or posedge i_riscv_de_rst )
      begin:de_pff_write_proc
        if(i_riscv_de_rst)
        begin
           o_riscv_de_pc_e          <=  'b0;
           o_riscv_de_pcplus4_e     <=  'b0;
           o_riscv_de_rs1addr_e     <=  'b0;
           o_riscv_de_rs1data_e     <=  'b0;
           o_riscv_de_rs2data_e     <=  'b0;
           o_riscv_de_rs2addr_e     <=  'b0;
           o_riscv_de_rdaddr_e      <=  'b0;
           o_riscv_de_extendedimm_e <=  'b0;
           o_riscv_de_b_condition_e <=  'b0;
           o_riscv_de_oprnd2sel_e   <=  'b0;
           o_riscv_de_storesrc_e    <=  'b0;
           o_riscv_de_alucontrol_e  <=  'b0;
           o_riscv_de_mulctrl_e     <=  'b0;
           o_riscv_de_divctrl_e     <=  'b0;
           o_riscv_de_funcsel_e     <=  'b0;
           o_riscv_de_oprnd1sel_e   <=  'b0;
           o_riscv_de_memwrite_e    <=  'b0;
           o_riscv_de_memext_e      <=  'b0;
           o_riscv_de_resultsrc_e   <=  'b0;
           o_riscv_de_regwrite_e    <=  'b0;
           o_riscv_de_jump_e        <=  'b0;
           o_riscv_de_opcode_e      <=  'b0;
          //<------------------------------>
          `ifdef TEST
           o_riscv_de_inst          <=  'b0;
           o_riscv_de_cinst         <=  'b0;
           `endif
           //<------------------------------
        end
      else
        begin
      if(i_riscv_de_flush)
        begin
           o_riscv_de_pc_e          <=  'b0;
           o_riscv_de_pcplus4_e     <=  'b0;
           o_riscv_de_rs1addr_e     <=  'b0;
           o_riscv_de_rs1data_e     <=  'b0;
           o_riscv_de_rs2data_e     <=  'b0;
           o_riscv_de_rs2addr_e     <=  'b0;
           o_riscv_de_rdaddr_e      <=  'b0;
           o_riscv_de_extendedimm_e <=  'b0;
           o_riscv_de_b_condition_e <=  'b0;
           o_riscv_de_oprnd2sel_e   <=  'b0;
           o_riscv_de_storesrc_e    <=  'b0;
           o_riscv_de_alucontrol_e  <=  'b0;
           o_riscv_de_mulctrl_e     <=  'b0;
           o_riscv_de_divctrl_e     <=  'b0;
           o_riscv_de_funcsel_e     <=  'b0;
           o_riscv_de_oprnd1sel_e   <=  'b0;
           o_riscv_de_memwrite_e    <=  'b0;
           o_riscv_de_memext_e      <=  'b0;
           o_riscv_de_resultsrc_e   <=  'b0;
           o_riscv_de_regwrite_e    <=  'b0;
           o_riscv_de_jump_e        <=  'b0;
           o_riscv_de_opcode_e      <=  'b0;
          //<------------------------------>
          `ifdef TEST
           o_riscv_de_inst          <=  'b0;
           o_riscv_de_cinst         <=  'b0;
           `endif
           //<------------------------------
        end

else if (i_riscv_de_en)
begin
    o_riscv_de_pc_e           <= o_riscv_de_pc_e;
    o_riscv_de_pcplus4_e     <= o_riscv_de_pcplus4_e;
    o_riscv_de_rs1addr_e     <= o_riscv_de_rs1addr_e;
    o_riscv_de_rs1data_e     <= o_riscv_de_rs1data_e;
    o_riscv_de_rs2data_e     <= o_riscv_de_rs2data_e;
    o_riscv_de_rs2addr_e     <= o_riscv_de_rs2addr_e;
    o_riscv_de_rdaddr_e      <= o_riscv_de_rdaddr_e;
    o_riscv_de_extendedimm_e <= o_riscv_de_extendedimm_e;
    o_riscv_de_b_condition_e <= o_riscv_de_b_condition_e;
    o_riscv_de_oprnd2sel_e   <= o_riscv_de_oprnd2sel_e;
    o_riscv_de_storesrc_e    <= o_riscv_de_storesrc_e;
    o_riscv_de_alucontrol_e  <= o_riscv_de_alucontrol_e;
    o_riscv_de_mulctrl_e     <= o_riscv_de_mulctrl_e;
    o_riscv_de_divctrl_e     <= o_riscv_de_divctrl_e;
    o_riscv_de_funcsel_e     <= o_riscv_de_funcsel_e;
    o_riscv_de_oprnd1sel_e   <= o_riscv_de_oprnd1sel_e;
    o_riscv_de_memwrite_e    <= o_riscv_de_memwrite_e;
    o_riscv_de_memext_e      <= o_riscv_de_memext_e;
    o_riscv_de_resultsrc_e   <= o_riscv_de_resultsrc_e;
    o_riscv_de_regwrite_e    <= o_riscv_de_regwrite_e;
    o_riscv_de_jump_e        <= o_riscv_de_jump_e;
    o_riscv_de_opcode_e      <= o_riscv_de_opcode_e;
    //<------------------------------------------
    `ifdef TEST
    o_riscv_de_inst          <= o_riscv_de_inst;
    o_riscv_de_cinst         <= o_riscv_de_cinst;
    `endif
    //<------------------------------------------
end

      else
        begin
           o_riscv_de_pc_e          <= i_riscv_de_pc_d;
           o_riscv_de_pcplus4_e     <= i_riscv_de_pcplus4_d;
           o_riscv_de_rs1addr_e     <= i_riscv_de_rs1addr_d;
           o_riscv_de_rs1data_e     <= i_riscv_de_rs1data_d;
           o_riscv_de_rs2data_e     <= i_riscv_de_rs2data_d;
           o_riscv_de_rs2addr_e     <= i_riscv_de_rs2addr_d;
           o_riscv_de_rdaddr_e      <= i_riscv_de_rdaddr_d;
           o_riscv_de_extendedimm_e <= i_riscv_de_extendedimm_d;
           o_riscv_de_b_condition_e <= i_riscv_de_b_condition_d;
           o_riscv_de_oprnd2sel_e   <= i_riscv_de_oprnd2sel_d;
           o_riscv_de_storesrc_e    <= i_riscv_de_storesrc_d;
           o_riscv_de_alucontrol_e  <= i_riscv_de_alucontrol_d;
           o_riscv_de_mulctrl_e     <= i_riscv_de_mulctrl_d;
           o_riscv_de_divctrl_e     <= i_riscv_de_divctrl_d;
           o_riscv_de_funcsel_e     <= i_riscv_de_funcsel_d;
           o_riscv_de_oprnd1sel_e   <= i_riscv_de_oprnd1sel_d;
           o_riscv_de_memwrite_e    <= i_riscv_de_memwrite_d;
           o_riscv_de_memext_e      <= i_riscv_de_memext_d;
           o_riscv_de_resultsrc_e   <= i_riscv_de_resultsrc_d;
           o_riscv_de_regwrite_e    <= i_riscv_de_regwrite_d;
           o_riscv_de_jump_e        <= i_riscv_de_jump_d;    
           o_riscv_de_opcode_e      <= i_riscv_de_opcode_d;
          //<-------------------------------------------
           `ifdef TEST
           o_riscv_de_inst          <= i_riscv_de_inst;
           o_riscv_de_cinst         <= i_riscv_de_cinst;
           `endif
           //<------------------------------------------
        end
      end
    end
  endmodule
