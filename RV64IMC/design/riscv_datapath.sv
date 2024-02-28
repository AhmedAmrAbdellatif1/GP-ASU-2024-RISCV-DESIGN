module riscv_datapath #(parameter width=64) (
  input  logic             i_riscv_datapath_clk,
  input  logic             i_riscv_datapath_rst,
  
  ///////////////////fetch//////////////////
  input  logic             i_riscv_datapath_stallpc,  ///output from hazard unit
 // input  logic             i_riscv_datapath_addermuxsel,
  output logic [width-1:0] o_riscv_datapath_pc ,      ///input to im
  ///////////////////fd_pff//////////////////
  input  logic [31:0]      i_riscv_datapath_inst,     ///output from im
  input  logic             i_riscv_datapath_flush_fd, ///output from hazard unit
  input  logic             i_riscv_datapath_stall_fd, ///output from hazard unit
  /////////////////////decode///////////// 
  input  logic [2:0]       i_riscv_datapath_immsrc,   ///output from control 
  output logic [6:0]       o_riscv_datapath_opcode,   ///input to control unit
  output logic [2:0]       o_riscv_datapath_func3,    ///input to control unit
  output logic             o_riscv_datapath_func7_5,  ///input to control unit
  output logic             o_riscv_datapath_func7_0,  ///input to control unit  
  output logic [4:0]       o_riscv_datapath_rs1addr_d,///input to hazard unit
  output logic [4:0]       o_riscv_datapath_rs2addr_d,///input to hazard unit
  
  ///////////////////de_pff//////////////////
  input  logic             i_riscv_datapath_regw,     ///output from control unit
  input  logic             i_riscv_datapath_jump,     ///output from control unit      
  input  logic             i_riscv_datapath_asel,     ///output from control unit
  input  logic             i_riscv_datapath_bsel,     ///output from control unit
  input  logic             i_riscv_datapath_memw,     ///output from control unit
  input  logic             i_riscv_datapath_memr,     ///output from control unit        newwwwwwwwwww
  input  logic [1:0]       i_riscv_datapath_storesrc, ///output from control unit
  input  logic [1:0]       i_riscv_datapath_resultsrc,///output from control unit
  input  logic [3:0]       i_riscv_datapath_bcond,    ///output from control unit
  input  logic [2:0]       i_riscv_datapath_memext,   ///output from control unit
  input  logic [5:0]       i_riscv_datapath_aluctrl,  ///output from control unit
  input  logic [3:0]       i_riscv_datapath_mulctrl,
  input  logic [3:0]       i_riscv_datapath_divctrl,
  input  logic [1:0]       i_riscv_datapath_funcsel,
  input  logic             i_riscv_datapath_flush_de, ///output from hazard unit
  /////////////////////execute/////////////
  input  logic [1:0]       i_riscv_datapath_fwda,        ///output from hazard unit
  input  logic [1:0]       i_riscv_datapath_fwdb,        ///output from hazard unit 
  output logic             o_riscv_datapath_icu_valid_e,     ///input to hazard unit   
  output logic             o_riscv_datapath_pcsrc_e,     ///input to hazard unit   
  output logic [4:0]       o_riscv_datapath_rs1addr_e,   ///input to hazard unit
  output logic [4:0]       o_riscv_datapath_rs2addr_e,   ///input to hazard unit
  output logic [4:0]       o_riscv_datapath_rdaddr_e ,   ///input to hazard unit
  output logic [1:0]       o_riscv_datapath_resultsrc_e, ///input to hazard unit
  output logic  [6:0]      o_riscv_datapath_opcode_m,
  output logic             o_datapath_div_en,   
  output logic             o_datapath_mul_en,  
  
  /////////////////////memory/////////////
  input  logic [width-1:0] i_riscv_datapath_dm_rdata,      ///output from dm
  output logic [4:0]       o_riscv_datapath_rdaddr_m ,     ///input to hazard unit
  output logic             o_riscv_datapath_memw_e,       ///input to dm &&&&&& input to hazard unit
  output logic             o_riscv_datapath_memr_e,      // -------------------->
  output logic [1:0]       o_riscv_datapath_storesrc_m,   ///input to dm
  output logic [width-1:0] o_riscv_datapath_memodata_addr,///input to dm
  output logic [width-1:0] o_riscv_datapath_storedata_m,  ///input to dm
  output logic             o_riscv_datapath_regw_m,       ///input to hazard unit
  
  /////////////////////write back ///////////
  output logic             o_riscv_datapath_regw_wb,     ///input to hazard unit   
  output logic [4:0]       o_riscv_datapath_rdaddr_wb ,   ///input to hazard unit
  //////////////////////////////////////////
  input  logic             i_riscv_datapath_stall_de,
  input  logic             i_riscv_datapath_stall_em,
  input  logic             i_riscv_datapath_stall_mw
 );
  
  ////// fetch internal signals ////////
  // logic                 riscv_pcsrc_fe;
  logic [width-1:0]     riscv_aluexe_fe;
  logic [width-1:0]     riscv_pcplus4_f;
  //logic                 riscv_rstctrl_f;
  logic [31:0]          riscv_inst_f;
  //////decode internal signals ////////
  logic [31:0]           riscv_inst_d;
  logic [4:0]            riscv_rdaddr_d;
  logic [4:0]            riscv_rdaddr_wb;
  logic [width-1:0]      riscv_rddata_wb;
  logic                  riscv_regw_wb;
  logic [width-1:0]      riscv_rs1data_d;
  logic [width-1:0]      riscv_rs2data_d;
  logic [width-1:0]      riscv_simm_d;
  logic [width-1:0]      riscv_pcplus4_d;
  logic [width-1:0]      riscv_pc_d;
  logic [4:0]            riscv_rs1addr_d;
  logic [4:0]            riscv_rs2addr_d;
  //logic                  riscv_rstctrl_d;
  logic [6:0]           riscv_opcode_d;
  logic [6:0]           riscv_opcode_e;

  //////execute internal signals ////////
  logic  [width-1:0]     riscv_pc_e;
  logic  [width-1:0]     riscv_pcplus4_e;
  logic  [4:0]           riscv_rs1addr_e;
  logic  [width-1:0]     riscv_rs1data_e;
  logic  [width-1:0]     riscv_rs2data_e;
  logic  [width-1:0]     riscv_store_data;
  logic  [4:0]           riscv_rs2addr_e;
  logic  [4:0]           riscv_rdaddr_e;
  logic  [width-1:0]     riscv_extendedimm_e;
  logic  [3:0]           riscv_b_condition_e;
  logic                  riscv_oprnd2sel_e;
  logic  [1:0]           riscv_storesrc_e;
  logic  [5:0]           riscv_alucontrol_e;
  logic  [3:0]           riscv_mulctrl_e;
  logic  [3:0]           riscv_divctrl_e;
  logic  [1:0]           riscv_funcsel_e;
  logic                  riscv_oprnd1sel_e;
  //logic                  riscv_memwrite_e;///output
  //logic                  riscv_memread_e; ///output
  logic  [2:0]           riscv_memext_e;
  logic  [1:0]           riscv_resultsrc_e;
  logic                  riscv_regwrite_e;
  logic                  riscv_jump_e;
  logic                  riscv_branchtaken;
  
  ////// memory internal signals ////////
  logic [width-1:0]     riscv_rddata_me ;
  logic                 riscv_regw_m;
  logic [1:0]           riscv_resultsrc_m;
  logic [2:0]           riscv_memext_m;
  logic [width-1:0]     riscv_pcplus4_m;
  logic [4:0]           riscv_rdaddr_m;
  logic [width-1:0]     riscv_imm_m;
  logic [width-1:0]     riscv_memload_m;

  ////// write back ineternal signals///////
  logic [width-1:0]     riscv_pcplus4_wb;
  logic [width-1:0]     riscv_result_wb;
  logic [width-1:0]     riscv_uimm_wb;
  logic [width-1:0]     riscv_memload_wb;
  logic [1:0]           riscv_resultsrc_wb;

  ////// tracer signals ///////
  //--------------------------------->
  `ifdef TEST
  logic [31:0]          riscv_inst_e;
  logic [15:0]          riscv_cinst_e;
  logic [31:0]          riscv_inst_m;
  logic [15:0]          riscv_cinst_m;
  logic [width-1:0]     riscv_pc_m;
  logic [15:0]          riscv_cinst_d;
  logic [31:0]          riscv_inst_wb;
  logic [15:0]          riscv_cinst_wb;
  logic [width-1:0]     riscv_memaddr_wb;
  logic [width-1:0]     riscv_pc_wb;
  logic [width-1:0]     riscv_rs2data_wb;
  `endif
  //<---------------------------------

  /////////
  //assign riscv_rstctrl_f              = i_riscv_datapath_flush_fd | i_riscv_datapath_rst;
  //assign riscv_rstctrl_d              = i_riscv_datapath_flush_de | i_riscv_datapath_rst;
  assign o_riscv_datapath_opcode        = riscv_opcode_d          ;
  assign o_riscv_datapath_pcsrc_e       = riscv_jump_e | riscv_branchtaken;
  assign o_riscv_datapath_rdaddr_m      = riscv_rdaddr_m          ;  // to hazard unit 
  assign o_riscv_datapath_memodata_addr = riscv_rddata_me         ;  // to data memory
  assign o_riscv_datapath_rdaddr_e      = riscv_rdaddr_e          ;  // to hazard unit
  assign o_riscv_datapath_rdaddr_wb     = riscv_rdaddr_wb         ;  // to hazard unit
  assign o_riscv_datapath_regw_m        = riscv_regw_m            ;  // to hazard unit
  assign o_riscv_datapath_regw_wb       = riscv_regw_wb           ;  // to hazard unit
  assign o_riscv_datapath_resultsrc_e   = riscv_resultsrc_e       ;  // to hazard unit
  assign o_riscv_datapath_rs1addr_d     = riscv_rs1addr_d         ;  //to hazard unit
  assign o_riscv_datapath_rs2addr_d     = riscv_rs2addr_d         ;  //to hazard unit
  
  
  ////fetch stage instantiation////
  riscv_fstage u_riscv_fstage(
    .i_riscv_fstage_clk       (i_riscv_datapath_clk)              ,
    .i_riscv_fstage_rst       (i_riscv_datapath_rst)              ,
    .i_riscv_fstage_stallpc   (i_riscv_datapath_stallpc)          ,
    .i_riscv_fstage_aluexe    (riscv_aluexe_fe)                   ,
    .i_riscv_fstage_inst      (i_riscv_datapath_inst)             ,
    .i_riscv_fstage_pcsrc     (o_riscv_datapath_pcsrc_e)          ,
    .o_riscv_fstage_pc        (o_riscv_datapath_pc)               ,
    .o_riscv_fstage_pcplus4   (riscv_pcplus4_f)                   ,
    .o_riscv_fstage_inst      (riscv_inst_f)
  );

  ////fetch decode pipeline flip flops ////
  riscv_fd_ppreg u_riscv_fd_ppreg(
    //------------------------------------------------------------>
    `ifdef TEST
    .i_riscv_fd_cinst_f         (i_riscv_datapath_inst[15:0])     ,
    .o_riscv_fd_cinst_d         (riscv_cinst_d)                   ,
    `endif
    //<------------------------------------------------------------
    .i_riscv_fd_clk             (i_riscv_datapath_clk)            ,
    .i_riscv_fd_rst             (i_riscv_datapath_rst)            ,
    .i_riscv_fd_flush           (i_riscv_datapath_flush_fd)       ,
    .i_riscv_fd_en              (i_riscv_datapath_stall_fd)       ,
    .i_riscv_fd_pc_f            (o_riscv_datapath_pc)             ,
    .i_riscv_fd_inst_f          (riscv_inst_f)                    ,
    .i_riscv_fd_pcplus4_f       (riscv_pcplus4_f)                 ,
    .o_riscv_fd_pc_d            (riscv_pc_d)                      ,
    .o_riscv_fd_inst_d          (riscv_inst_d)                    ,
    .o_riscv_fd_pcplus4_d       (riscv_pcplus4_d)
  );

  ////decode stage instantiation////
  riscv_dstage u_riscv_dstage(
    .i_riscv_dstage_clk_n       (i_riscv_datapath_clk)            ,
    .i_riscv_dstage_rst         (i_riscv_datapath_rst)            ,
    .i_riscv_dstage_regw        (riscv_regw_wb)                   ,
    .i_riscv_dstage_immsrc      (i_riscv_datapath_immsrc)         ,
    .i_riscv_dstage_inst        (riscv_inst_d)                    ,
    .i_riscv_dstage_rdaddr      (riscv_rdaddr_wb)                 ,
    .i_riscv_dstage_rddata      (riscv_rddata_wb)                 ,
    .o_riscv_dstage_rs1addr     (riscv_rs1addr_d)                 ,
    .o_riscv_dstage_rs2addr     (riscv_rs2addr_d)                 ,
    .o_riscv_dstage_rs1data     (riscv_rs1data_d)                 ,
    .o_riscv_dstage_rs2data     (riscv_rs2data_d)                 ,
    .o_riscv_dstage_rdaddr      (riscv_rdaddr_d)                  ,
    .o_riscv_dstage_simm        (riscv_simm_d)                    ,
    .o_riscv_dstage_opcode      (riscv_opcode_d)                  ,
    .o_riscv_dstage_funct3      (o_riscv_datapath_func3)          ,
    .o_riscv_dstage_func7_5     (o_riscv_datapath_func7_5)        ,
    .o_riscv_dstage_func7_0     (o_riscv_datapath_func7_0)
  );

  ////decode execute pipeline flip flops ////
  riscv_de_ppreg u_riscv_de_ppreg(
    //------------------------------------------------------------>
    `ifdef TEST
    .i_riscv_de_inst            (riscv_inst_d)                    ,
    .i_riscv_de_cinst           (riscv_cinst_d)                   ,
    .o_riscv_de_inst            (riscv_inst_e)                    ,
    .o_riscv_de_cinst           (riscv_cinst_e)                   ,
    `endif
    //<------------------------------------------------------------
    .i_riscv_de_en              (i_riscv_datapath_stall_de)       ,
    .i_riscv_de_clk             (i_riscv_datapath_clk)            ,
    .i_riscv_de_rst             (i_riscv_datapath_rst)            ,
    .i_riscv_de_flush           (i_riscv_datapath_flush_de)       ,
    .i_riscv_de_pc_d            (riscv_pc_d)                      ,
    .i_riscv_de_rs1addr_d       (riscv_rs1addr_d)                 ,
    .i_riscv_de_rs1data_d       (riscv_rs1data_d)                 ,
    .i_riscv_de_rs2data_d       (riscv_rs2data_d)                 ,
    .i_riscv_de_rs2addr_d       (riscv_rs2addr_d)                 ,
    .i_riscv_de_rdaddr_d        (riscv_rdaddr_d)                  ,
    .i_riscv_de_extendedimm_d   (riscv_simm_d)                    , 
    .i_riscv_de_b_condition_d   (i_riscv_datapath_bcond)          ,
    .i_riscv_de_oprnd2sel_d     (i_riscv_datapath_bsel)           ,
    .i_riscv_de_storesrc_d      (i_riscv_datapath_storesrc)       ,
    .i_riscv_de_alucontrol_d    (i_riscv_datapath_aluctrl)        ,
    .i_riscv_de_mulctrl_d       (i_riscv_datapath_mulctrl)        ,
    .i_riscv_de_divctrl_d       (i_riscv_datapath_divctrl)        ,
    .i_riscv_de_funcsel_d       (i_riscv_datapath_funcsel)        ,
    .i_riscv_de_oprnd1sel_d     (i_riscv_datapath_asel)           ,
    .i_riscv_de_memwrite_d      (i_riscv_datapath_memw)           ,
    .i_riscv_de_memread_d       (i_riscv_datapath_memr)           ,
    .i_riscv_de_memext_d        (i_riscv_datapath_memext)         ,
    .i_riscv_de_resultsrc_d     (i_riscv_datapath_resultsrc)      ,
    .i_riscv_de_regwrite_d      (i_riscv_datapath_regw)           ,
    .i_riscv_de_jump_d          (i_riscv_datapath_jump)           ,
    .i_riscv_de_pcplus4_d       (riscv_pcplus4_d)                 ,
    .i_riscv_de_opcode_d        (riscv_opcode_d)                  ,
    .o_riscv_de_pc_e            (riscv_pc_e)                      ,
    .o_riscv_de_pcplus4_e       (riscv_pcplus4_e)                 ,
    .o_riscv_de_rs1addr_e       (o_riscv_datapath_rs1addr_e)      ,
    .o_riscv_de_rs1data_e       (riscv_rs1data_e)                 ,
    .o_riscv_de_rs2data_e       (riscv_rs2data_e)                 ,
    .o_riscv_de_rs2addr_e       (o_riscv_datapath_rs2addr_e)      ,
    .o_riscv_de_rdaddr_e        (riscv_rdaddr_e)                  ,
    .o_riscv_de_extendedimm_e   (riscv_extendedimm_e)             ,
    .o_riscv_de_b_condition_e   (riscv_b_condition_e)             ,
    .o_riscv_de_oprnd2sel_e     (riscv_oprnd2sel_e)               ,
    .o_riscv_de_storesrc_e      (riscv_storesrc_e)                ,
    .o_riscv_de_alucontrol_e    (riscv_alucontrol_e)              ,
    .o_riscv_de_mulctrl_e       (riscv_mulctrl_e)                 ,
    .o_riscv_de_divctrl_e       (riscv_divctrl_e)                 ,
    .o_riscv_de_funcsel_e       (riscv_funcsel_e)                 ,
    .o_riscv_de_oprnd1sel_e     (riscv_oprnd1sel_e)               , 
    .o_riscv_de_memwrite_e      (o_riscv_datapath_memw_e)         ,//.o_riscv_de_memwrite_e      (riscv_memwrite_e)
    .o_riscv_de_memread_e       (o_riscv_datapath_memr_e)         ,///.o_riscv_de_memread_e       (riscv_memread_e)
    .o_riscv_de_memext_e        (riscv_memext_e)                  ,
    .o_riscv_de_resultsrc_e     (riscv_resultsrc_e)               ,
    .o_riscv_de_regwrite_e      (riscv_regwrite_e)                ,
    .o_riscv_de_jump_e          (riscv_jump_e)                    ,
    .o_riscv_de_opcode_e        (riscv_opcode_e)                  
  );

  ////execute stage instantiation////
  riscv_estage u_riscv_estage(
    .i_riscv_estage_clk         (i_riscv_datapath_clk)            ,
    .i_riscv_estage_rst         (i_riscv_datapath_rst)            ,
    .i_riscv_estage_rs1data     (riscv_rs1data_e)                 ,
    .i_riscv_estage_rs2data     (riscv_rs2data_e)                 ,
    .i_riscv_estage_fwda        (i_riscv_datapath_fwda)           ,
    .i_riscv_estage_fwdb        (i_riscv_datapath_fwdb)           ,
    .i_riscv_estage_rdata_wb    (riscv_rddata_wb)                 ,
    .i_riscv_estage_rddata_m    (riscv_rddata_me)                 ,
    .i_riscv_estage_imm_m       (riscv_imm_m)                     ,
    .i_riscv_estage_oprnd1sel   (riscv_oprnd1sel_e)               ,
    .i_riscv_estage_oprnd2sel   (riscv_oprnd2sel_e)               ,
    .i_riscv_estage_pc          (riscv_pc_e)                      ,
    .i_riscv_estage_aluctrl     (riscv_alucontrol_e)              ,
    .i_riscv_estage_mulctrl     (riscv_mulctrl_e)                 ,
    .i_riscv_estage_divctrl     (riscv_divctrl_e)                 ,
    .i_riscv_estage_funcsel     (riscv_funcsel_e)                 ,
    .i_riscv_estage_simm        (riscv_extendedimm_e)             ,
    .i_riscv_estage_bcond       (riscv_b_condition_e)             ,
    .o_riscv_estage_result      (riscv_aluexe_fe)                 ,
    .o_riscv_estage_store_data  (riscv_store_data)                ,
    .o_riscv_estage_branchtaken (riscv_branchtaken)               ,
    .o_riscv_estage_icu_valid   (o_riscv_datapath_icu_valid_e)    ,
    .o_riscv_estage_mul_en      (o_datapath_mul_en)               ,
    .o_riscv_estage_div_en      (o_datapath_div_en)
  );

   ////execute memory pipeline flip flops ////
  riscv_em_ppreg u_riscv_em_ppreg(
    //------------------------------------------------------------>
    `ifdef TEST
    .i_riscv_em_inst            (riscv_inst_e)                    ,
    .i_riscv_em_cinst           (riscv_cinst_e)                   ,
    .i_riscv_em_pc              (riscv_pc_e)                      ,
    .o_riscv_em_inst            (riscv_inst_m)                    ,
    .o_riscv_em_cinst           (riscv_cinst_m)                   ,
    .o_riscv_em_pc              (riscv_pc_m)                      ,
    `endif
    //<------------------------------------------------------------
    .i_riscv_em_en              (i_riscv_datapath_stall_em)       ,
    .i_riscv_em_clk             (i_riscv_datapath_clk)            ,
    .i_riscv_em_rst             (i_riscv_datapath_rst)            ,
  //.i_riscv_em_memw_e          (riscv_memwrite_e)                ,-------------------->
    .i_riscv_em_regw_e          (riscv_regwrite_e)                ,
    .i_riscv_em_resultsrc_e     (riscv_resultsrc_e)               ,
    .i_riscv_em_storesrc_e      (riscv_storesrc_e)                ,
    .i_riscv_em_memext_e        (riscv_memext_e)                  ,
    .i_riscv_em_pcplus4_e       (riscv_pcplus4_e)                 ,
    .i_riscv_em_result_e        (riscv_aluexe_fe)                 ,
    .i_riscv_em_storedata_e     (riscv_store_data)                ,
    .i_riscv_em_rdaddr_e        (riscv_rdaddr_e)                  ,
    .i_riscv_em_imm_e           (riscv_extendedimm_e)             ,
    .i_riscv_de_opcode_e        (riscv_opcode_e)                  ,
  //.o_riscv_em_memw_m        (o_riscv_datapath_memw_m)           ,-------------------->
    .o_riscv_em_regw_m          (riscv_regw_m)                    ,
    .o_riscv_em_resultsrc_m     (riscv_resultsrc_m)               ,
    .o_riscv_em_storesrc_m      (o_riscv_datapath_storesrc_m)     ,
    .o_riscv_em_memext_m        (riscv_memext_m)                  ,
    .o_riscv_em_pcplus4_m       (riscv_pcplus4_m)                 ,
    .o_riscv_em_result_m        (riscv_rddata_me )                ,
    .o_riscv_em_storedata_m     (o_riscv_datapath_storedata_m)    ,
    .o_riscv_em_rdaddr_m        (riscv_rdaddr_m)                  ,
    .o_riscv_em_imm_m           (riscv_imm_m)                     ,  
    .o_riscv_de_opcode_m        (o_riscv_datapath_opcode_m)       
  );

  ////memory stage instantiation////
  riscv_mstage uriscv_mstage(
    .i_riscv_mstage_dm_rdata    (i_riscv_datapath_dm_rdata)       ,
    .i_riscv_mstage_memext      (riscv_memext_m)                  ,     
    .o_riscv_mstage_memload     (riscv_memload_m)
  );

  ////memory write back pipeline flip flops ////
  riscv_mw_ppreg u_riscv_mw_ppreg(
    //------------------------------------------------------------>
    `ifdef TEST
    .i_riscv_mw_inst            (riscv_inst_m)                    ,
    .i_riscv_mw_cinst           (riscv_cinst_m)                   ,
    .i_riscv_mw_memaddr         (o_riscv_datapath_memodata_addr)  ,
    .i_riscv_mw_pc              (riscv_pc_m)                      ,
    .i_riscv_mw_rs2data         (i_riscv_datapath_dm_rdata)       ,
    .o_riscv_mw_inst            (riscv_inst_wb)                   ,
    .o_riscv_mw_cinst           (riscv_cinst_wb)                  ,
    .o_riscv_mw_memaddr         (riscv_memaddr_wb)                ,
    .o_riscv_mw_pc              (riscv_pc_wb)                     ,
    .o_riscv_mw_rs2data         (riscv_rs2data_wb)                ,
    `endif
    //<------------------------------------------------------------
    .i_riscv_mw_en              (i_riscv_datapath_stall_mw)       ,
    .i_riscv_mw_clk             (i_riscv_datapath_clk)            ,
    .i_riscv_mw_rst             (i_riscv_datapath_rst)            ,
    .i_riscv_mw_pcplus4_m       (riscv_pcplus4_m)                 ,
    .i_riscv_mw_result_m        (riscv_rddata_me)                 ,
    .i_riscv_mw_uimm_m          (riscv_imm_m)                     ,
    .i_riscv_mw_memload_m       (riscv_memload_m)                 ,
    .i_riscv_mw_rdaddr_m        (riscv_rdaddr_m)                  ,
    .i_riscv_mw_resultsrc_m     (riscv_resultsrc_m)               ,
    .i_riscv_mw_regw_m          (riscv_regw_m)                    ,
    .o_riscv_mw_pcplus4_wb      (riscv_pcplus4_wb)                ,
    .o_riscv_mw_result_wb       (riscv_result_wb)                 ,
    .o_riscv_mw_uimm_wb         (riscv_uimm_wb)                   ,
    .o_riscv_mw_memload_wb      (riscv_memload_wb)                ,
    .o_riscv_mw_rdaddr_wb       (riscv_rdaddr_wb)                 ,
    .o_riscv_mw_resultsrc_wb    (riscv_resultsrc_wb)              ,
    .o_riscv_mw_regw_wb         (riscv_regw_wb)             
  );

  ////write back stage instantiation////
  riscv_wbstage u_riscv_wbstage(
    .i_riscv_wb_resultsrc       (riscv_resultsrc_wb)              , 
    .i_riscv_wb_pcplus4         (riscv_pcplus4_wb)                ,
    .i_riscv_wb_result          (riscv_result_wb)                 ,
    .i_riscv_wb_memload         (riscv_memload_wb)                ,
    .i_riscv_wb_uimm            (riscv_uimm_wb)                   ,
    .o_riscv_wb_rddata          (riscv_rddata_wb)
  );


  ///tracer instantiation///
  // --------------------------------------------------->
  `ifdef TEST
  riscv_tracer u_riscv_tracer(
  .i_riscv_clk            (i_riscv_datapath_clk)        ,
  .i_riscv_rst            (i_riscv_datapath_rst)        ,
  .i_riscv_trc_inst       (riscv_inst_wb)               ,
  .i_riscv_trc_cinst      (riscv_cinst_wb)              ,
  .i_riscv_trc_rdaddr     (riscv_rdaddr_wb)             ,
  .i_riscv_trc_memaddr    (riscv_memaddr_wb)            ,
  .i_riscv_trc_pc         (riscv_pc_wb)                 ,
  .i_riscv_trc_rs2data    (riscv_rs2data_wb)            ,
  .i_riscv_trc_rddata     (riscv_rddata_wb)
  ); 
  `endif
  // <---------------------------------------------------

endmodule