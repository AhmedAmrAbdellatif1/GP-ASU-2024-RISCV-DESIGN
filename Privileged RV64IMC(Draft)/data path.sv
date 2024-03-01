module riscv_datapath #(parameter width=64,parameter MXLEN = 64) (
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
  input  logic             i_riscv_datapath_stall_mw ,

//traps 
 /* input logic   [1:0] i_riscv_cu_privlvl ,   //come From CSR 
  //input logic         i_riscv_cu_tsr ,          //come From CSR
  //check the below 2 signals
  input  logic        i_riscv_cu_is_illegal ,    //check it comes from csr
 input   logic [4:0]  i_riscv_cu_rs1 ,      //come From F/D register
  input logic  [11:0] i_riscv_cu_cosntimm12  ,//12-bit input cosntimm12[31:20] ////come From F/D register
    // output logic [MXLEN-1:0]  o_riscv_cu_mtval ,

  input logic [3:0]   o_riscv_cu_ex_cause ,  //we encode for interupt , exception from value 0 >15 so need 4 bits
  input logic [3:0]   o_riscv_cu_int_cause ,
  input logic         o_riscv_cu_sel_rs_imm ,   // to d/e to have two signals to mux stable
  input logic  [2:0]  o_riscv_cu_csrop ,     // To CSR  //[?] 
  input  logic        o_riscv_cu_illgalinst ,    //[?] 
  input logic         o_riscv_cu_iscsr     ,
  input logic         o_riscv_cu_mret      ,
  input logic         o_riscv_cu_ecall_u  ,
  input logic         o_riscv_cu_ecall_s  ,
  input logic         o_riscv_cu_ecall_m   */





  //trap  
  // From cu to de
 input logic i_riscv_datapath_illgalinst_cu_de     ,
  input logic [2:0] i_riscv_datapath_csrop_cu_de   ,
  input logic i_riscv_datapath_iscsr_cu_de       ,
  input logic i_riscv_datapath_ecallu_cu_de       ,
  input logic i_riscv_datapath_ecalls_cu_de        ,
  input logic i_riscv_datapath_ecallm_cu_de        ,
  input logic i_riscv_datapath_immreg_cu_de        ,
               
    //logic [11:0]  csraddress_cu_de;

  output logic [4:0] o_riscv_datapath_rs1_fd_cu ,
  output logic [11:0] o_riscv_datapath_constimm12_fd_cu ,
  output  logic [1:0] o_riscv_core_privlvl_csr_cu, // to cu
     //trap 
     //input from top system 
     input logic          i_riscv_core_timerinterupt  ,
     input logic          i_riscv_core_externalinterupt
   
  

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


  //trap 
  //from mw to trap(wb)
  logic riscv_reg_flush  ;
  logic           gototrap_mw_trap       ;
  logic           returnfromtrap_mw_trap ;
  logic         iscsr_mw_trap  ;
  logic [width-1:0]  csrout_mw_trap   ;
  //must be changed 
  //assign flsuh_fd  = i_riscv_datapath_flush_fd | riscv_reg_flush ;
  //assign flsuh_de = i_riscv_datapath_flush_de | riscv_reg_flush  ;
  //from trap to pcmux (fetcch)
    logic [1:0]   pcsel_trap_fetchpc ;
    
  //from CSR(MEM) to mw direct

  logic             gototrap_csr_mw         ;
  logic             returnfromtrap_csr_mw   ;
  logic             iscsr_csr_mw              ;
  logic  [MXLEN-1:0] csrout_csr_mw           ; 
  //from CSR(MEM) to pctrap mux 
  logic  [MXLEN-1:0] mtvec_csr_pctrap        ; 
  logic  [MXLEN-1:0] mepc_csr_pctrap           ; 




  // From de to em direct
    logic ecallu_de_em  ;
    logic ecalls_de_em ;
    logic ecallm_de_em  ;
    
    
    logic [11:0]  csraddress_de_em ;
    logic illegal_inst_de_em      ;
    logic iscsr_de_em  ;
    logic [2:0]   csrop_de_em  ;


      //logic immreg_de_em  ; 
    logic [63:0] addressalu_de_em ;

    //From esatge to em
    logic inst_addr_misaligned_estage_em  ;
    logic load_addr_misaligned_estage_em  ;
    logic store_addr_misaligned_estage_em ;

      //From em to csr
  logic             riscv_datapath_ecall_u_em_csr ;
  logic             riscv_datapath_ecall_s_em_csr ;
  logic             riscv_datapath_ecall_m_em_csr ;

  logic [11:0]      riscv_datapath_csraddress_em_csr  ;
  logic             riscv_datapath_illegal_inst_em_csr ;
 logic             riscv_datapath_iscsr_em_csr   ;
  logic [2:0]       riscv_datapath_csrop_em_csr  ;

  logic [width-1:0] riscv_datapath_addressalu_em_csr  ;
  logic             riscv_datapath_inst_addr_misaligned_em_csr  ;
  logic             riscv_datapath_load_addr_misaligned_em_csr  ;
  logic             riscv_datapath_store_addr_misaligned_em_csr  ;
  logic [width-1:0] riscv_datapath_csrwdata_em_csr ;


logic [2:0] i_riscv_cu_csrop_de;
  //From decode stage to de register
  logic [width-1:0]  immzeroextend_dstage_de ; 

//From decode stage to estage 
  logic [width-1:0] immzeroextend_de_estage ;
  logic             immreg_de_estage   ;
  

  //From em to csr
      
   /* logic ecallu_em_csr  ;
    logic ecalls_em_csr ;
    logic ecallm_em_csr  ;
    
    
    logic [11:0]  csraddress_em_csr ;
    logic illegal_inst_em_csr      ;
    logic iscsr_em_csr  ;
    logic [2:0]   csrop_em_csr  ;  */
    //logic immreg_em_csr  ; 
    logic addressalu_em_csr ;
    logic inst_addr_misaligned_em_csr  ;
    logic load_addr_misaligned_em_csr  ;
    logic store_addr_misaligned_em_csr ;

    logic [width-1:0] csrwritedata_em_csr ;

   //from estage to em
     logic [width-1:0]  csrwritedata_estage_em ; 




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
    .o_riscv_fstage_inst      (riscv_inst_f)    ,

    .i_riscv_fstage_pcsel(pcsel_trap_fetchpc),   //[1:0]
    .i_riscv_fstage_mtval(mtvec_csr_pctrap),      //[width-1:0]    //2'b01
    .i_riscv_fstage_mepc(mepc_csr_pctrap)    //[width-1:0]   //2'b10
 //   o_riscv_fstage_pc(o_riscv_datapath_pc)  //[width-1:0]

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
    .o_riscv_fd_pcplus4_d       (riscv_pcplus4_d)                 ,

     .o_riscv_fd_rs1_d(o_riscv_datapath_rs1_fd_cu) ,
    .o_riscv_fd_constimm12_d(o_riscv_datapath_constimm12_fd_cu) 
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
    .o_riscv_dstage_func7_0     (o_riscv_datapath_func7_0)        ,

    //trap
    //From decode stage to de stage
    .o_riscv_dstage_immzeroextend(immzeroextend_dstage_de)   // [width-1:0] 

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
    .o_riscv_de_opcode_e        (riscv_opcode_e)                 ,
    
     
   

      //trap
    //                 i_riscv_de_ecall_u_d(i_riscv_cu_ecallu_de)        ,
    //                 i_riscv_de_ecall_s_d(i_riscv_cu_ecalls_de)  , 
    .i_riscv_de_ecall_m_d      (i_riscv_datapath_ecallm_cu_de)    , 
    .i_riscv_de_csraddress_d   (riscv_inst_d[31:20])  ,   // [11:0]
    .i_riscv_de_illegal_inst_d (i_riscv_datapath_illgalinst_cu_de)  ,
    //Control Signals 
    .i_riscv_de_iscsr_d        (i_riscv_datapath_iscsr_cu_de)  , 
   .i_riscv_de_csrop_d         (i_riscv_datapath_csrop_cu_de)  ,     // [2:0]
    .i_riscv_de_immreg_d       (i_riscv_datapath_immreg_cu_de)  ,
    .i_riscv_de_immzeroextend_d(immzeroextend_dstage_de) ,  //[width-1:0] 

     
    //                o_riscv_de_ecall_u_e(ecallu_de_em)  ,
    //                o_riscv_de_ecall_s_e(ecalls_de_em)  , 
    .o_riscv_de_ecall_m_e      (ecallm_de_em)     , 
    .o_riscv_de_csraddress_e   (csraddress_de_em)  ,   //[11:0]
    .o_riscv_de_illegal_inst_e (illegal_inst_de_em)  ,
    //Control Signals 
    .o_riscv_de_iscsr_e        (iscsr_de_em)  ,
    .o_riscv_de_csrop_e        (csrop_de_em) ,    //[2:0]
    .o_riscv_de_immreg_e       (immreg_de_estage)  ,

    .o_riscv_de_immzeroextend_e(immzeroextend_de_estage)       //[width-1:0]    
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
    .o_riscv_estage_div_en      (o_datapath_div_en)               ,

  //trap 
    .i_riscv_estage_imm_reg     (immreg_de_estage)        ,
    .i_riscv_estage_immextended (immzeroextend_de_estage)    ,   //[width-1:0] 
    .o_riscv_estage_csrwritedata(csrwritedata_estage_em)  ,     //[width-1:0]    //changed from i to o ??

    .i_riscv_stage_opcode(riscv_opcode_e)          ,
    .i_riscv_estage_memext(riscv_memext_e)         ,
    .i_riscv_estage_storesrc(riscv_storesrc_e)       ,   
  
    .o_riscv_estage_inst_addr_misaligned(inst_addr_misaligned_estage_em),
    .o_riscv_estage_store_addr_misaligned(store_addr_misaligned_estage_em),
    .o_riscv_estage_load_addr_misaligned(load_addr_misaligned_estage_em)  
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
    .o_riscv_de_opcode_m        (o_riscv_datapath_opcode_m)      , 
 
    //trap
    .i_riscv_em_flush           (riscv_reg_flush)   ,
    //From de to em direct 
    //  .i_riscv_em_ecall_u_e   (ecallu_de_em) ,
    //  .i_riscv_em_ecall_s_e   (ecalls_de_em)  , 
    .i_riscv_em_ecall_m_e       (ecallm_de_em)     , 
    .i_riscv_em_csraddress_e    (csraddress_de_em) ,    //[11:0]
    .i_riscv_em_illegal_inst_e  (illegal_inst_de_em)  ,
    //Control Signals 
    .i_riscv_em_iscsr_e         (iscsr_de_em)  ,
    .i_riscv_em_csrop_e         (csrop_de_em)  ,      // [2:0] 
    //.i_riscv_em_immreg_e()  ,
    .i_riscv_em_addressalu_e    (addressalu_de_em)  ,  // ?? check  //[63:0]
    //From misallignment block
    .i_riscv_em_inst_addr_misaligned_e(inst_addr_misaligned_estage_em)    ,
    .i_riscv_em_load_addr_misaligned_e(load_addr_misaligned_estage_em)     ,
    .i_riscv_em_store_addr_misaligned_e(store_addr_misaligned_estage_em)    , 
    .i_riscv_em_csrwritedata_e         (csrwritedata_estage_em)  , //[width-1:0]




     
    //             o_riscv_em_ecall_u_m(o_riscv_datapath_ecall_u_em_csr)  ,
    //             o_riscv_em_ecall_s_m(o_riscv_datapath_ecall_s_em_csr)  , 
    .o_riscv_em_ecall_m_m      (o_riscv_datapath_ecall_m_em_csr)     , 
    .o_riscv_em_csraddress_m   (riscv_datapath_csraddress_em_csr)  ,    //[11:0] 
    .o_riscv_em_illegal_inst_m (o_riscv_datapath_illegal_inst_em_csr)  ,
    //Control Signals 
    .o_riscv_em_iscsr_m      (iscsr_csr_mw)  ,
    .o_riscv_em_csrop_m        (riscv_datapath_csrop_em_csr)  ,    //[2:0]
    //.o_riscv_em_immreg_m()  ,
    .o_riscv_em_addressalu_m   (riscv_datapath_addressalu_em_csr)  ,  //[63:0]
    .o_riscv_em_inst_addr_misaligned_m(o_riscv_datapath_inst_addr_misaligned_em_csr)    ,
    .o_riscv_em_load_addr_misaligned_m(o_riscv_datapath_load_addr_misaligned_em_csr)     ,
    .o_riscv_em_store_addr_misaligned_m(o_riscv_datapath_store_addr_misaligned_em_csr)   ,

    .o_riscv_em_csrwritedata_m (riscv_datapath_csrwdata_em_csr)     //[width-1:0] 


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
    .i_riscv_mw_memload_m       (i_riscv_datapath_dm_rdata)       ,
    .i_riscv_mw_rdaddr_m        (riscv_rdaddr_m)                  ,
    .i_riscv_mw_resultsrc_m     (riscv_resultsrc_m)               ,
    .i_riscv_mw_regw_m          (riscv_regw_m)                    ,
    .o_riscv_mw_pcplus4_wb      (riscv_pcplus4_wb)                ,
    .o_riscv_mw_result_wb       (riscv_result_wb)                 ,
    .o_riscv_mw_uimm_wb         (riscv_uimm_wb)                   ,
    .o_riscv_mw_memload_wb      (riscv_memload_wb)                ,
    .o_riscv_mw_rdaddr_wb       (riscv_rdaddr_wb)                 ,
    .o_riscv_mw_resultsrc_wb    (riscv_resultsrc_wb)              ,
    .o_riscv_mw_regw_wb         (riscv_regw_wb)                   ,
       //Trap 
    .i_riscv_mw_flush           (riscv_reg_flush)           ,
    .i_riscv_mw_csrout_m        (csrout_mw_trap)          ,
    .i_riscv_mw_iscsr_m         (iscsr_csr_mw)           ,
   .i_riscv_mw_gototrap_m       (gototrap_csr_mw)        ,
    .i_riscv_mw_returnfromtrap_m(returnfromtrap_csr_mw)  ,


    .o_riscv_mw_csrout_wb        (csrout_csr_mw)          ,   //[63:0]
    .o_riscv_mw_iscsr_wb         (iscsr_mw_trap)           ,
    .o_riscv_mw_gototrap_wb      (gototrap_mw_trap)        ,
    .o_riscv_mw_returnfromtrap_wb(returnfromtrap_mw_trap)  
  );

  ////write back stage instantiation////
  riscv_wbstage u_riscv_wbstage(
    .i_riscv_wb_resultsrc       (riscv_resultsrc_wb)              , 
    .i_riscv_wb_pcplus4         (riscv_pcplus4_wb)                ,
    .i_riscv_wb_result          (riscv_result_wb)                 ,
    .i_riscv_wb_memload         (riscv_memload_wb)                ,
    .i_riscv_wb_uimm            (riscv_uimm_wb)                   ,
    .o_riscv_wb_rddata          (riscv_rddata_wb)                ,

    //trap (//From mw Register input signals )
   .i_riscv_wb_csrout          (csrout_csr_mw) ,    //[width-1:0]
    //Comes from m/wb regsiter 
    .i_riscv_wb_iscsr           (iscsr_mw_trap)   ,
    .i_riscv_wb_gototrap        (gototrap_mw_trap)   ,
    .i_riscv_wb_returnfromtrap  (returnfromtrap_mw_trap)   ,
    //to pc_sel_trap in fetch stage
    .o_riscv_wb_pcsel           (pcsel_trap_fetchpc)   ,    // [1:0] 
    // flush to all register
    .o_riscv_wb_flush           (riscv_reg_flush) 
);  


   
 riscv_csrfile u_riscv_csrfile 

    (  
    .i_riscv_csr_clk            (i_riscv_datapath_clk) ,
    .i_riscv_csr_rst            (i_riscv_datapath_rst) ,

        //Come From e/m register
    .i_riscv_csr_address        (riscv_datapath_csraddress_em_csr) ,  //[11:0]
     .i_riscv_csr_op            (riscv_datapath_csrop_em_csr) ,    //[2:0] ?? also check it
    .i_riscv_csr_wdata          (riscv_datapath_csrwdata_em_csr) ,  //[MXLEN-1:0]
    .o_riscv_csr_rdata          (csrout_mw_trap) ,  //[MXLEN-1:0]
        //.o_riscv_csr_sideeffect_flush() ,
     

            // Interrupts
    .i_riscv_csr_external_int   (i_riscv_core_externalinterupt) , //interrupt from external source
        //input wire i_riscv_csr_software_interrupt, //interrupt from software (inter-processor interrupt)
    .i_riscv_csr_timer_int      (i_riscv_core_timerinterupt), //interrupt from timer

            /// Exceptions ///
        
    .i_riscv_csr_ecall_u        (riscv_datapath_ecall_u_em_csr) ,        //ecall instruction from user mode
    .i_riscv_csr_ecall_s        (riscv_datapath_ecall_s_em_csr) ,        //ecall instruction from s mode
    .i_riscv_csr_ecall_m        (riscv_datapath_ecall_m_em_csr) ,        //ecall instruction from m mode
    .i_riscv_csr_illegal_inst   (riscv_datapath_illegal_inst_em_csr), //illegal instruction (From decoder) ??check if can come from csr
        //input csr_op_logic        i_is_mret,         //mret (return from trap) instruction
    .i_riscv_csr_inst_addr_misaligned(riscv_datapath_inst_addr_misaligned_em_csr) , 
    .i_riscv_csr_load_addr_misaligned(riscv_datapath_load_addr_misaligned_em_csr) , 
    .i_riscv_csr_store_addr_misaligned(riscv_datapath_store_addr_misaligned_em_csr) , 

     

    .o_riscv_csr_return_address    (mepc_csr_pctrap), //  [MXLEN-1:0]mepc CSR  
    .o_riscv_csr_trap_address      (mtvec_csr_pctrap),   // [MXLEN-1:0] mtvec CSR
 
        // Trap-Handler  // Interrupts/Exceptions

        .o_riscv_csr_gotoTrap_cs(gototrap_csr_mw), //high before going to trap (if exception/interrupt detected)  // Output the exception PC to PC Gen, the correct CSR (mepc, sepc) is set accordingly
        .o_riscv_csr_returnfromTrap_cs(returnfromtrap_csr_mw) , //high before returning from trap (via mret)
                   
        //output logic              eret_o,                     // Return from exception, set the PC of epc_o  //make mux input this signal to it asserted when mret instrution reaches csr


        .i_riscv_csr_pc(riscv_pcplus4_m) ,             //[63:0]
        .i_riscv_csr_addressALU(riscv_datapath_addressalu_em_csr),  //[63:0] //address  from ALU  used in load/store/jump/branch)
        .o_riscv_csr_privlvl(o_riscv_core_privlvl_csr_cu)   //[1:0]

        //.o_riscv_csr_flush()   //it should be inout to trap module to flush all 

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