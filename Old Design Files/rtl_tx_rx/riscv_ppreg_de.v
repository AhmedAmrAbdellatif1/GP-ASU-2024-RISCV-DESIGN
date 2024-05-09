  module riscv_ppreg_de (
    input   wire         i_riscv_de_clk              ,
    input   wire         i_riscv_de_rst              ,
    input   wire         i_riscv_de_flush            ,
    input   wire         i_riscv_de_en               ,
    input   wire [63:0]  i_riscv_de_pc_d             ,
    input   wire [4:0]   i_riscv_de_rs1addr_d        ,
    input   wire [63:0]  i_riscv_de_rs1data_d        ,
    input   wire [63:0]  i_riscv_de_rs2data_d        ,
    input   wire [4:0]   i_riscv_de_rs2addr_d        ,
    input   wire [4:0]   i_riscv_de_rdaddr_d         ,
    input   wire [63:0]  i_riscv_de_extendedimm_d    ,
    input   wire [3:0]   i_riscv_de_b_condition_d    ,
    input   wire         i_riscv_de_oprnd2sel_d      ,
    input   wire [1:0]   i_riscv_de_storesrc_d       ,
    input   wire [5:0]   i_riscv_de_alucontrol_d     ,
    input   wire [3:0]   i_riscv_de_mulctrl_d        ,
    input   wire [3:0]   i_riscv_de_divctrl_d        ,
    input   wire [1:0]   i_riscv_de_funcsel_d        , 
    input   wire         i_riscv_de_oprnd1sel_d      ,
    input   wire         i_riscv_de_memwrite_d       ,
    input   wire         i_riscv_de_memread_d        ,
    input   wire [2:0]   i_riscv_de_memext_d         ,
    input   wire [2:0]   i_riscv_de_resultsrc_d      ,
    input   wire         i_riscv_de_regwrite_d       ,    
    input   wire         i_riscv_de_jump_d           ,
    input   wire [63:0]  i_riscv_de_pcplus4_d        ,
    input   wire [6:0]   i_riscv_de_opcode_d         ,
    input   wire         i_riscv_de_ecall_m_d        ,
    input   wire         i_riscv_de_ecall_s_d        ,
    input   wire         i_riscv_de_ecall_u_d        ,
    input   wire [11:0]  i_riscv_de_csraddress_d     ,
    input   wire         i_riscv_de_illegal_inst_d   ,
    input   wire         i_riscv_de_iscsr_d          ,
    input   wire [2:0]   i_riscv_de_csrop_d          ,
    input   wire         i_riscv_de_immreg_d         ,
    input   wire [63:0]  i_riscv_de_immzeroextend_d  ,
    input   wire         i_riscv_de_instret_d        ,
    input   wire [1:0]   i_riscv_de_lr_d             ,    
    input   wire [1:0]   i_riscv_de_sc_d             ,
    input   wire [4:0]   i_riscv_de_amo_op_d         ,
    input   wire         i_riscv_de_amo_d            ,
    input   wire [31:0]  i_riscv_de_inst             ,
    input   wire [15:0]  i_riscv_de_cinst            ,
    output  reg [31:0]  o_riscv_de_inst             ,
    output  reg [15:0]  o_riscv_de_cinst            ,
    output  reg [1:0]   o_riscv_de_lr_e             ,
    output  reg [1:0]   o_riscv_de_sc_e             ,
    output  reg [4:0]   o_riscv_de_amo_op_e         ,
    output  reg         o_riscv_de_amo_e            ,
    output  reg         o_riscv_de_instret_e        ,
    output  reg [63:0]  o_riscv_de_pc_e             ,
    output  reg [63:0]  o_riscv_de_pcplus4_e        ,
    output  reg [4:0]   o_riscv_de_rs1addr_e        ,
    output  reg [63:0]  o_riscv_de_rs1data_e        , 
    output  reg [63:0]  o_riscv_de_rs2data_e        ,
    output  reg [4:0]   o_riscv_de_rs2addr_e        ,
    output  reg [4:0]   o_riscv_de_rdaddr_e         ,  
    output  reg [63:0]  o_riscv_de_extendedimm_e    ,
    output  reg [3:0]   o_riscv_de_b_condition_e    ,
    output  reg         o_riscv_de_oprnd2sel_e      ,
    output  reg [1:0]   o_riscv_de_storesrc_e       ,
    output  reg [5:0]   o_riscv_de_alucontrol_e     ,
    output  reg [3:0]   o_riscv_de_mulctrl_e        ,
    output  reg [3:0]   o_riscv_de_divctrl_e        ,
    output  reg [1:0]   o_riscv_de_funcsel_e        ,
    output  reg         o_riscv_de_oprnd1sel_e      ,   
    output  reg         o_riscv_de_memwrite_e       ,
    output  reg         o_riscv_de_memread_e        ,
    output  reg [2:0]   o_riscv_de_memext_e         ,
    output  reg [2:0]   o_riscv_de_resultsrc_e      ,
    output  reg         o_riscv_de_regwrite_e       ,
    output  reg         o_riscv_de_jump_e           ,
    output  reg [6:0]   o_riscv_de_opcode_e         ,
    output  reg         o_riscv_de_ecall_m_e        , //<--- CSR 
    output  reg         o_riscv_de_ecall_s_e        , //<--- CSR 
    output  reg         o_riscv_de_ecall_u_e        , //<--- CSR 
    output  reg [11:0]  o_riscv_de_csraddress_e     , //<--- CSR
    output  reg         o_riscv_de_illegal_inst_e   , //<--- CSR
    output  reg         o_riscv_de_iscsr_e          , //<--- CSR
    output  reg [2:0]   o_riscv_de_csrop_e          , //<--- CSR
    output  reg         o_riscv_de_immreg_e         , //<--- CSR
    output  reg [63:0]  o_riscv_de_immzeroextend_e    //<--- CSR
  );

  always @(posedge i_riscv_de_clk or posedge i_riscv_de_rst )
    begin:de_pff_write_proc
      if(i_riscv_de_rst)
      begin
          o_riscv_de_pc_e            <=  'b0;
          o_riscv_de_pcplus4_e       <=  'b0;
          o_riscv_de_rs1addr_e       <=  'b0;
          o_riscv_de_rs1data_e       <=  'b0;
          o_riscv_de_rs2data_e       <=  'b0;
          o_riscv_de_rs2addr_e       <=  'b0;
          o_riscv_de_rdaddr_e        <=  'b0;
          o_riscv_de_extendedimm_e   <=  'b0;
          o_riscv_de_b_condition_e   <=  'b0;
          o_riscv_de_oprnd2sel_e     <=  'b0;
          o_riscv_de_storesrc_e      <=  'b0;
          o_riscv_de_alucontrol_e    <=  'b0;
          o_riscv_de_mulctrl_e       <=  'b0;
          o_riscv_de_divctrl_e       <=  'b0;
          o_riscv_de_funcsel_e       <=  'b0;
          o_riscv_de_oprnd1sel_e     <=  'b0;
          o_riscv_de_memwrite_e      <=  'b0;
          o_riscv_de_memread_e       <=  'b0;
          o_riscv_de_memext_e        <=  'b0;
          o_riscv_de_resultsrc_e     <=  'b0;
          o_riscv_de_regwrite_e      <=  'b0;
          o_riscv_de_jump_e          <=  'b0;
          o_riscv_de_opcode_e        <=  'b0;
          o_riscv_de_ecall_m_e       <=  'b0; 
          o_riscv_de_ecall_s_e       <=  'b0; // <--
          o_riscv_de_ecall_u_e       <=  'b0; // <--
          o_riscv_de_csraddress_e    <=  'b0;
          o_riscv_de_illegal_inst_e  <=  'b0;
          o_riscv_de_iscsr_e         <=  'b0;
          o_riscv_de_csrop_e         <=  'b0;
          o_riscv_de_immreg_e        <=  'b0;
          o_riscv_de_immzeroextend_e <=  'b0;
          o_riscv_de_instret_e       <=  'b0;
          o_riscv_de_lr_e            <=  'b0;  
          o_riscv_de_sc_e            <=  'b0;
          o_riscv_de_amo_op_e        <=  'b0;
          o_riscv_de_amo_e           <=  'b0;
          o_riscv_de_inst            <=  'b0;
          o_riscv_de_cinst           <=  'b0;
      end
    else if(i_riscv_de_flush)
      begin
          o_riscv_de_pc_e            <=  'b0;
          o_riscv_de_pcplus4_e       <=  'b0;
          o_riscv_de_rs1addr_e       <=  'b0;
          o_riscv_de_rs1data_e       <=  'b0;
          o_riscv_de_rs2data_e       <=  'b0;
          o_riscv_de_rs2addr_e       <=  'b0;
          o_riscv_de_rdaddr_e        <=  'b0;
          o_riscv_de_extendedimm_e   <=  'b0;
          o_riscv_de_b_condition_e   <=  'b0;
          o_riscv_de_oprnd2sel_e     <=  'b0;
          o_riscv_de_storesrc_e      <=  'b0;
          o_riscv_de_alucontrol_e    <=  'b0;
          o_riscv_de_mulctrl_e       <=  'b0;
          o_riscv_de_divctrl_e       <=  'b0;
          o_riscv_de_funcsel_e       <=  'b0;
          o_riscv_de_oprnd1sel_e     <=  'b0;
          o_riscv_de_memwrite_e      <=  'b0;
          o_riscv_de_memread_e       <=  'b0;
          o_riscv_de_memext_e        <=  'b0;
          o_riscv_de_resultsrc_e     <=  'b0;
          o_riscv_de_regwrite_e      <=  'b0;
          o_riscv_de_jump_e          <=  'b0;
          o_riscv_de_opcode_e        <=  'b0;
          o_riscv_de_ecall_m_e       <=  'b0; 
          o_riscv_de_ecall_s_e       <=  'b0; // <--
          o_riscv_de_ecall_u_e       <=  'b0;// <--
          o_riscv_de_csraddress_e    <=  'b0;
          o_riscv_de_illegal_inst_e  <=  'b0;
          o_riscv_de_iscsr_e         <=  'b0;
          o_riscv_de_csrop_e         <=  'b0;
          o_riscv_de_immreg_e        <=  'b0;
          o_riscv_de_immzeroextend_e <=  'b0;
          o_riscv_de_instret_e       <=  'b0;
          o_riscv_de_lr_e            <=  'b0;  
          o_riscv_de_sc_e            <=  'b0;
          o_riscv_de_amo_op_e        <=  'b0;
          o_riscv_de_amo_e           <=  'b0;
          o_riscv_de_inst            <=  'b0;
          o_riscv_de_cinst           <=  'b0;
      end
    else if (!i_riscv_de_en)
      begin
          o_riscv_de_pc_e            <=  i_riscv_de_pc_d;
          o_riscv_de_pcplus4_e       <=  i_riscv_de_pcplus4_d;
          o_riscv_de_rs1addr_e       <=  i_riscv_de_rs1addr_d;
          o_riscv_de_rs1data_e       <=  i_riscv_de_rs1data_d;
          o_riscv_de_rs2data_e       <=  i_riscv_de_rs2data_d;
          o_riscv_de_rs2addr_e       <=  i_riscv_de_rs2addr_d;
          o_riscv_de_rdaddr_e        <=  i_riscv_de_rdaddr_d;
          o_riscv_de_extendedimm_e   <=  i_riscv_de_extendedimm_d;
          o_riscv_de_b_condition_e   <=  i_riscv_de_b_condition_d;
          o_riscv_de_oprnd2sel_e     <=  i_riscv_de_oprnd2sel_d;
          o_riscv_de_storesrc_e      <=  i_riscv_de_storesrc_d;
          o_riscv_de_alucontrol_e    <=  i_riscv_de_alucontrol_d;
          o_riscv_de_mulctrl_e       <=  i_riscv_de_mulctrl_d;
          o_riscv_de_divctrl_e       <=  i_riscv_de_divctrl_d;
          o_riscv_de_funcsel_e       <=  i_riscv_de_funcsel_d;
          o_riscv_de_oprnd1sel_e     <=  i_riscv_de_oprnd1sel_d;
          o_riscv_de_memwrite_e      <=  i_riscv_de_memwrite_d;
          o_riscv_de_memread_e       <=  i_riscv_de_memread_d;
          o_riscv_de_memext_e        <=  i_riscv_de_memext_d;
          o_riscv_de_resultsrc_e     <=  i_riscv_de_resultsrc_d;
          o_riscv_de_regwrite_e      <=  i_riscv_de_regwrite_d;
          o_riscv_de_jump_e          <=  i_riscv_de_jump_d;    
          o_riscv_de_opcode_e        <=  i_riscv_de_opcode_d;
          o_riscv_de_ecall_m_e       <=  i_riscv_de_ecall_m_d; 
          o_riscv_de_ecall_s_e       <=  i_riscv_de_ecall_s_d; //<--
          o_riscv_de_ecall_u_e       <=  i_riscv_de_ecall_u_d; //<--
          o_riscv_de_csraddress_e    <=  i_riscv_de_csraddress_d;
          o_riscv_de_illegal_inst_e  <=  i_riscv_de_illegal_inst_d;
          o_riscv_de_iscsr_e         <=  i_riscv_de_iscsr_d;
          o_riscv_de_csrop_e         <=  i_riscv_de_csrop_d;
          o_riscv_de_immreg_e        <=  i_riscv_de_immreg_d;
          o_riscv_de_immzeroextend_e <=  i_riscv_de_immzeroextend_d;
          o_riscv_de_instret_e       <=  i_riscv_de_instret_d;
          o_riscv_de_lr_e            <=  i_riscv_de_lr_d;  
          o_riscv_de_sc_e            <=  i_riscv_de_sc_d;
          o_riscv_de_amo_op_e        <=  i_riscv_de_amo_op_d;
          o_riscv_de_amo_e           <=  i_riscv_de_amo_d;
          o_riscv_de_inst          <= i_riscv_de_inst;
          o_riscv_de_cinst         <= i_riscv_de_cinst;
      end
    end
endmodule