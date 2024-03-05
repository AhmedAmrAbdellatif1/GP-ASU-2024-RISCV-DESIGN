module riscv_datapath #(parameter MXLEN = 64) (
  input  logic              i_riscv_datapath_clk,
  input  logic              i_riscv_datapath_rst,
/************************* Fetch Stage Signals *************************/
  input  logic              i_riscv_datapath_stallpc           ,
  output logic [63:0]       o_riscv_datapath_pc                , 
/************************* Fetch PP Register Signals *************************/ 
  input  logic [31:0]       i_riscv_datapath_inst              ,
  input  logic              i_riscv_datapath_flush_fd          ,  
  input  logic              i_riscv_datapath_stall_fd          ,
/************************* Decode Stage Signals *************************/ 
  input  logic [2:0]        i_riscv_datapath_immsrc            , 
  output logic [6:0]        o_riscv_datapath_opcode            , 
  output logic [2:0]        o_riscv_datapath_func3             , 
  output logic              o_riscv_datapath_func7_5           ,
  output logic              o_riscv_datapath_func7_0           , 
  output logic [4:0]        o_riscv_datapath_rs1addr_d         , 
  output logic [4:0]        o_riscv_datapath_rs2addr_d         ,
/************************* Decoder PP Register Signals *************************/ 
  input  logic              i_riscv_datapath_regw              ,  
  input  logic              i_riscv_datapath_jump              ,        
  input  logic              i_riscv_datapath_asel              ,  
  input  logic              i_riscv_datapath_bsel              ,  
  input  logic              i_riscv_datapath_memw              ,  
  input  logic              i_riscv_datapath_memr              ,  
  input  logic [1:0]        i_riscv_datapath_storesrc          ,  
  input  logic [1:0]        i_riscv_datapath_resultsrc         ,  
  input  logic [3:0]        i_riscv_datapath_bcond             ,  
  input  logic [2:0]        i_riscv_datapath_memext            ,  
  input  logic [5:0]        i_riscv_datapath_aluctrl           ,  
  input  logic [3:0]        i_riscv_datapath_mulctrl           ,
  input  logic [3:0]        i_riscv_datapath_divctrl           ,
  input  logic [1:0]        i_riscv_datapath_funcsel           ,  
  input  logic              i_riscv_datapath_flush_de          ,
/************************* Execute Stage Signals *************************/ 
  input  logic [1:0]        i_riscv_datapath_fwda              ,  
  input  logic [1:0]        i_riscv_datapath_fwdb              ,   
  output logic              o_riscv_datapath_icu_valid_e       ,    
  output logic              o_riscv_datapath_pcsrc_e           ,    
  output logic [4:0]        o_riscv_datapath_rs1addr_e         ,  
  output logic [4:0]        o_riscv_datapath_rs2addr_e         ,  
  output logic [4:0]        o_riscv_datapath_rdaddr_e          ,  
  output logic [1:0]        o_riscv_datapath_resultsrc_e       ,  
  output logic [6:0]        o_riscv_datapath_opcode_m          ,
  output logic              o_datapath_div_en                  ,   
  output logic              o_datapath_mul_en                  ,  
/************************* Memory Stage Signals *************************/ 
  input  logic [63:0]       i_riscv_datapath_dm_rdata          ,
  output logic [4:0]        o_riscv_datapath_rdaddr_m          ,  
  output logic              o_riscv_datapath_memw_e            ,
  output logic              o_riscv_datapath_memr_e            ,
  output logic [1:0]        o_riscv_datapath_storesrc_m        ,
  //output logic [1:0]        o_riscv_datapath_loadsrc_m         ,
  output logic [63:0]       o_riscv_datapath_memodata_addr     ,
  output logic [63:0]       o_riscv_datapath_storedata_m       ,
  output logic              o_riscv_datapath_regw_m            ,  
  
/************************* WB Stage Signals *************************/ 
  output logic              o_riscv_datapath_regw_wb           ,    
  output logic [4:0]        o_riscv_datapath_rdaddr_wb         ,  
/************************* Stall Signals *************************/ 
  input  logic              i_riscv_datapath_stall_de          ,
  input  logic              i_riscv_datapath_stall_em          ,
  input  logic              i_riscv_datapath_stall_mw          ,
/************************* CSR Signals *************************/ 
  input logic               i_riscv_datapath_muxcsr_sel        ,
  output logic              o_riscv_datapath_iscsr_w_trap      ,
  output logic              o_riscv_datapath_iscsr_m_trap      ,
  output logic              o_riscv_datapath_iscsr_e_trap      ,
  output logic              o_riscv_datapath_iscsr_d_trap      ,
/************************* Traps Signals *************************/ 
  input   logic             i_riscv_datapath_illgalinst_cu_de  ,
  input   logic [2:0]       i_riscv_datapath_csrop_cu_de       ,
  input   logic             i_riscv_datapath_iscsr_cu_de       ,
  input   logic             i_riscv_datapath_ecallu_cu_de      ,
  input   logic             i_riscv_datapath_ecalls_cu_de      ,
  input   logic             i_riscv_datapath_ecallm_cu_de      ,
  input   logic             i_riscv_datapath_immreg_cu_de      ,
  input   logic             i_riscv_core_timerinterupt         ,
  input   logic             i_riscv_core_externalinterupt      ,
  output  logic [4:0]       o_riscv_datapath_rs1_fd_cu         ,
  output  logic [11:0]      o_riscv_datapath_constimm12_fd_cu  ,
  output  logic [1:0]       o_riscv_core_privlvl_csr_cu        ,
  output  logic [4:0]       o_riscv_datapath_rs1addr_m
 );

/************************* Fetch Stage Signals *************************/
  logic  [63:0]  riscv_aluexe_fe     ;  
  logic  [63:0]  riscv_pcplus4_f     ;
  logic  [31:0]  riscv_inst_f        ;
/************************* Decode Stage Signals *************************/
  logic  [31:0]  riscv_inst_d        ;
  logic  [4:0]   riscv_rdaddr_d      ;
  logic  [4:0]   riscv_rdaddr_wb     ; 
  logic  [63:0]  riscv_rddata_wb     ;
  logic          riscv_regw_wb       ;
  logic  [63:0]  riscv_rs1data_d     ;
  logic  [63:0]  riscv_rs2data_d     ;
  logic  [63:0]  riscv_simm_d        ;
  logic  [63:0]  riscv_pcplus4_d     ;
  logic  [63:0]  riscv_pc_d          ;
  logic  [4:0]   riscv_rs1addr_d     ;
  logic  [4:0]   riscv_rs2addr_d     ;
  logic  [6:0]   riscv_opcode_d      ;
/************************* Execute Stage Signals *************************/
  logic  [6:0]   riscv_opcode_e      ;
  logic  [63:0]  riscv_pc_e          ;
  logic  [63:0]  riscv_pcplus4_e     ;
  logic  [4:0]   riscv_rs1addr_e     ;
  logic  [63:0]  riscv_rs1data_e     ;
  logic  [63:0]  riscv_rs2data_e     ;
  logic  [63:0]  riscv_store_data    ;
  logic  [4:0]   riscv_rs2addr_e     ;
  logic  [4:0]   riscv_rdaddr_e      ;
  logic  [63:0]  riscv_extendedimm_e ;
  logic  [3:0]   riscv_b_condition_e ;
  logic          riscv_oprnd2sel_e   ;
  logic  [1:0]   riscv_storesrc_e    ;
  logic  [5:0]   riscv_alucontrol_e  ;
  logic  [3:0]   riscv_mulctrl_e     ;
  logic  [3:0]   riscv_divctrl_e     ;
  logic  [1:0]   riscv_funcsel_e     ;
  logic          riscv_oprnd1sel_e   ;
  logic  [2:0]   riscv_memext_e      ;
  logic  [1:0]   riscv_resultsrc_e   ;
  logic          riscv_regwrite_e    ;
  logic          riscv_jump_e        ;
  logic          riscv_branchtaken   ;
/************************* Memory Stage Signals *************************/
  logic  [63:0]  riscv_rddata_me     ;
  logic          riscv_regw_m        ;
  logic  [1:0]   riscv_resultsrc_m   ;
  logic  [2:0]   riscv_memext_m      ;
  logic  [63:0]  riscv_pcplus4_m     ;
  logic  [4:0]   riscv_rdaddr_m      ;
  logic  [63:0]  riscv_imm_m         ;
  logic  [63:0]  riscv_memload_m     ;
/************************* WB Stage Signals *************************/      
  logic  [63:0]  riscv_pcplus4_wb    ;
  logic  [63:0]  riscv_result_wb     ;
  logic  [63:0]  riscv_uimm_wb       ;
  logic  [63:0]  riscv_memload_wb    ;
  logic  [1:0]   riscv_resultsrc_wb  ; 

/************************* Tracer Signals *************************/
  //--------------------------------->
  `ifdef TEST
  logic [31:0]   riscv_inst_e        ;
  logic [15:0]   riscv_cinst_e       ;
  logic [31:0]   riscv_inst_m        ;
  logic [15:0]   riscv_cinst_m       ;
  logic [63:0]   riscv_pc_m          ;
  logic [15:0]   riscv_cinst_d       ;
  logic [31:0]   riscv_inst_wb       ;
  logic [15:0]   riscv_cinst_wb      ;     
  logic [63:0]   riscv_memaddr_wb    ;
  logic [63:0]   riscv_pc_wb         ;
  logic [63:0]   riscv_rs2data_wb    ;
  `endif
  //<---------------------------------

/************************* Trap & CSR Signals *************************/
  logic               riscv_reg_flush                  ;
  logic               gototrap_mw_trap                 ;
  logic               returnfromtrap_mw_trap           ;
  logic               iscsr_mw_trap                    ;
  logic [63:0]        csrout_mw_trap                   ;
  logic [1:0]         pcsel_trap_fetchpc               ;
  logic               gototrap_csr_mw                  ;
  logic               returnfromtrap_csr_mw            ;
  logic               iscsr_csr_mw                     ;
  logic [MXLEN-1:0]   csrout_csr_mw                    ; 
  logic [MXLEN-1:0]   mtvec_csr_pctrap                 ; 
  logic [MXLEN-1:0]   mepc_csr_pctrap                  ; 
  logic               ecallu_de_em                     ;  
  logic               ecalls_de_em                     ;
  logic               ecallm_de_em                     ;
  logic               illegal_inst_de_em               ;
  logic               iscsr_de_em                      ;  
  logic [2:0]         csrop_de_em                      ;
  logic [11:0]        csraddress_de_em                 ;
  logic [63:0]        addressalu_de_em                 ;
  logic               ecall_u_em_csr                   ;
  logic               ecall_s_em_csr                   ;
  logic               m_em_csr                         ;
  logic [11:0]        csraddress_em_csr                ;
  logic               illegal_inst_em_csr              ;
  logic               iscsr_em_csr                     ;
  logic [2:0]         csrop_em_csr                     ;
  logic [63:0]        addressalu_em_csr                ;
  logic [63:0]        csrwdata_em_csr                  ;
  logic [2:0]         csrop_de                         ;
  logic [63:0]        immzeroextend_dstage_de          ; 
  logic [63:0]        immzeroextend_de_estage          ;
  logic               immreg_de_estage                 ;
  logic               inst_addr_misaligned_em_csr      ;
  logic               load_addr_misaligned_em_csr      ;
  logic               store_addr_misaligned_em_csr     ;
  logic [63:0]        csrwritedata_em_csr              ;
  logic [63:0]        csrwritedata_estage_em           ;
  logic               load_addr_misaligned_estage_em   ;    
  logic               store_addr_misaligned_estage_em  ;
  logic               inst_addr_misaligned_estage_em   ;
  logic [63:0]        muxout_csr                       ;          
  
  ////////////////////////////////////////////////////////////////////////////////////

  assign o_riscv_datapath_pcsrc_e       = riscv_jump_e | riscv_branchtaken;
  assign o_riscv_datapath_opcode        = riscv_opcode_d          ;
  assign o_riscv_datapath_rdaddr_m      = riscv_rdaddr_m          ;  // to hazard unit 
  assign o_riscv_datapath_memodata_addr = riscv_rddata_me         ;  // to data memory
  assign o_riscv_datapath_rdaddr_e      = riscv_rdaddr_e          ;  // to hazard unit
  assign o_riscv_datapath_rdaddr_wb     = riscv_rdaddr_wb         ;  // to hazard unit
  assign o_riscv_datapath_regw_m        = riscv_regw_m            ;  // to hazard unit
  assign o_riscv_datapath_regw_wb       = riscv_regw_wb           ;  // to hazard unit
  assign o_riscv_datapath_resultsrc_e   = riscv_resultsrc_e       ;  // to hazard unit
  assign o_riscv_datapath_rs1addr_d     = riscv_rs1addr_d         ;  //to hazard unit
  assign o_riscv_datapath_rs2addr_d     = riscv_rs2addr_d         ;  //to hazard unit
  //assign o_riscv_datapath_loadsrc_m     = riscv_memext_m[1:0]     ;  // to data memory

  assign riscv_rstctrl_f                = i_riscv_datapath_flush_fd | i_riscv_datapath_rst;
  assign riscv_rstctrl_d                = i_riscv_datapath_flush_de | i_riscv_datapath_rst;
  assign o_riscv_datapath_iscsr_w_trap  = iscsr_mw_trap                 ;
  assign o_riscv_datapath_iscsr_m_trap  = iscsr_csr_mw                  ; 
  assign o_riscv_datapath_iscsr_e_trap  = iscsr_de_em                   ;
  assign o_riscv_datapath_iscsr_d_trap  = i_riscv_datapath_iscsr_cu_de  ;
  

  /************************* ************** *************************/
  /************************* Instantiations *************************/
  /************************* ************** *************************/

  riscv_fstage u_riscv_fstage (
    .i_riscv_fstage_clk       (i_riscv_datapath_clk)              ,
    .i_riscv_fstage_rst       (i_riscv_datapath_rst)              ,
    .i_riscv_fstage_stallpc   (i_riscv_datapath_stallpc)          ,
    .i_riscv_fstage_aluexe    (riscv_aluexe_fe)                   ,
    .i_riscv_fstage_inst      (i_riscv_datapath_inst)             ,
    .i_riscv_fstage_pcsrc     (o_riscv_datapath_pcsrc_e)          ,
    .i_riscv_fstage_pcsel     (pcsel_trap_fetchpc)                , //<--- 
    .i_riscv_fstage_mtval     (mtvec_csr_pctrap)                  , //<---       
    .i_riscv_fstage_mepc      (mepc_csr_pctrap)                   , //<--- 
    .o_riscv_fstage_pc        (o_riscv_datapath_pc)               ,
    .o_riscv_fstage_pcplus4   (riscv_pcplus4_f)                   ,
    .o_riscv_fstage_inst      (riscv_inst_f)                      
  );

  riscv_fd_ppreg u_riscv_fd_ppreg(
    //------------------------------------------------------------>
    `ifdef TEST
    .i_riscv_fd_cinst_f         (i_riscv_datapath_inst[15:0])     ,
    .o_riscv_fd_cinst_d         (riscv_cinst_d)                   ,
    `endif
    //<------------------------------------------------------------
    .i_riscv_fd_clk             (i_riscv_datapath_clk)            ,
    .i_riscv_fd_rst             (i_riscv_datapath_rst)            ,
    .i_riscv_fd_flush           (riscv_rstctrl_f)                 , //<--- 
    .i_riscv_fd_en              (i_riscv_datapath_stall_fd)       ,
    .i_riscv_fd_pc_f            (o_riscv_datapath_pc)             ,
    .i_riscv_fd_inst_f          (riscv_inst_f)                    ,
    .i_riscv_fd_pcplus4_f       (riscv_pcplus4_f)                 ,
    .o_riscv_fd_pc_d            (riscv_pc_d)                      ,
    .o_riscv_fd_inst_d          (riscv_inst_d)                    ,
    .o_riscv_fd_pcplus4_d       (riscv_pcplus4_d)                 ,
    .o_riscv_fd_rs1_d           (o_riscv_datapath_rs1_fd_cu)      , //<--- 
    .o_riscv_fd_constimm12_d    (o_riscv_datapath_constimm12_fd_cu) //<--- 
  );

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
    .o_riscv_dstage_immzeroextend(immzeroextend_dstage_de)         //<---         

  );

  riscv_de_ppreg u_riscv_de_ppreg(
    //------------------------------------------------------------>
    `ifdef TEST
    .i_riscv_de_inst            (riscv_inst_d)                    ,
    .i_riscv_de_cinst           (riscv_cinst_d)                   ,
    .o_riscv_de_inst            (riscv_inst_e)                    ,
    .o_riscv_de_cinst           (riscv_cinst_e)                   ,
    `endif    
    //<-----------------------------------------------------------    -
    .i_riscv_de_en              (i_riscv_datapath_stall_de)           ,
    .i_riscv_de_clk             (i_riscv_datapath_clk)                ,
    .i_riscv_de_rst             (i_riscv_datapath_rst)                ,
    .i_riscv_de_flush           (riscv_rstctrl_d)                     , //<---     
    .i_riscv_de_pc_d            (riscv_pc_d)                          ,
    .i_riscv_de_rs1addr_d       (riscv_rs1addr_d)                     ,
    .i_riscv_de_rs1data_d       (riscv_rs1data_d)                     ,
    .i_riscv_de_rs2data_d       (riscv_rs2data_d)                     ,
    .i_riscv_de_rs2addr_d       (riscv_rs2addr_d)                     ,
    .i_riscv_de_rdaddr_d        (riscv_rdaddr_d)                      ,
    .i_riscv_de_extendedimm_d   (riscv_simm_d)                        , 
    .i_riscv_de_b_condition_d   (i_riscv_datapath_bcond)              ,
    .i_riscv_de_oprnd2sel_d     (i_riscv_datapath_bsel)               ,
    .i_riscv_de_storesrc_d      (i_riscv_datapath_storesrc)           ,
    .i_riscv_de_alucontrol_d    (i_riscv_datapath_aluctrl)            ,
    .i_riscv_de_mulctrl_d       (i_riscv_datapath_mulctrl)            ,
    .i_riscv_de_divctrl_d       (i_riscv_datapath_divctrl)            ,
    .i_riscv_de_funcsel_d       (i_riscv_datapath_funcsel)            ,
    .i_riscv_de_oprnd1sel_d     (i_riscv_datapath_asel)               ,
    .i_riscv_de_memwrite_d      (i_riscv_datapath_memw)               ,
    .i_riscv_de_memread_d       (i_riscv_datapath_memr)               ,
    .i_riscv_de_memext_d        (i_riscv_datapath_memext)             ,
    .i_riscv_de_resultsrc_d     (i_riscv_datapath_resultsrc)          ,
    .i_riscv_de_regwrite_d      (i_riscv_datapath_regw)               ,
    .i_riscv_de_jump_d          (i_riscv_datapath_jump)               ,
    .i_riscv_de_pcplus4_d       (riscv_pcplus4_d)                     ,
    .i_riscv_de_opcode_d        (riscv_opcode_d)                      ,
    .i_riscv_de_ecall_m_d       (i_riscv_datapath_ecallm_cu_de)       , //<---  
    .i_riscv_de_csraddress_d    (riscv_inst_d[31:20])                 , //<---   
    .i_riscv_de_illegal_inst_d  (i_riscv_datapath_illgalinst_cu_de)   , //<---
    .i_riscv_de_iscsr_d         (i_riscv_datapath_iscsr_cu_de)        , //<--- 
    .i_riscv_de_csrop_d         (i_riscv_datapath_csrop_cu_de)        , //<---   
    .i_riscv_de_immreg_d        (i_riscv_datapath_immreg_cu_de)       , //<---
    .i_riscv_de_immzeroextend_d (immzeroextend_dstage_de)             , //<---  
    .o_riscv_de_ecall_m_e       (ecallm_de_em)                        , //<--- 
    .o_riscv_de_csraddress_e    (csraddress_de_em)                    , //<---         
    .o_riscv_de_illegal_inst_e  (illegal_inst_de_em)                  , //<---
    .o_riscv_de_iscsr_e         (iscsr_de_em)                         , //<---
    .o_riscv_de_csrop_e         (csrop_de_em)                         , //<---   
    .o_riscv_de_immreg_e        (immreg_de_estage)                    , //<---
    .o_riscv_de_immzeroextend_e (immzeroextend_de_estage)             ,
    .o_riscv_de_pc_e            (riscv_pc_e)                          ,
    .o_riscv_de_pcplus4_e       (riscv_pcplus4_e)                     ,
    .o_riscv_de_rs1addr_e       (o_riscv_datapath_rs1addr_e)          ,
    .o_riscv_de_rs1data_e       (riscv_rs1data_e)                     ,
    .o_riscv_de_rs2data_e       (riscv_rs2data_e)                     ,
    .o_riscv_de_rs2addr_e       (o_riscv_datapath_rs2addr_e)          ,
    .o_riscv_de_rdaddr_e        (riscv_rdaddr_e)                      ,
    .o_riscv_de_extendedimm_e   (riscv_extendedimm_e)                 ,
    .o_riscv_de_b_condition_e   (riscv_b_condition_e)                 ,
    .o_riscv_de_oprnd2sel_e     (riscv_oprnd2sel_e)                   ,
    .o_riscv_de_storesrc_e      (riscv_storesrc_e)                    ,
    .o_riscv_de_alucontrol_e    (riscv_alucontrol_e)                  ,
    .o_riscv_de_mulctrl_e       (riscv_mulctrl_e)                     ,
    .o_riscv_de_divctrl_e       (riscv_divctrl_e)                     ,
    .o_riscv_de_funcsel_e       (riscv_funcsel_e)                     ,
    .o_riscv_de_oprnd1sel_e     (riscv_oprnd1sel_e)                   , 
    .o_riscv_de_memwrite_e      (o_riscv_datapath_memw_e)             ,
    .o_riscv_de_memread_e       (o_riscv_datapath_memr_e)             ,
    .o_riscv_de_memext_e        (riscv_memext_e)                      ,
    .o_riscv_de_resultsrc_e     (riscv_resultsrc_e)                   ,
    .o_riscv_de_regwrite_e      (riscv_regwrite_e)                    ,
    .o_riscv_de_jump_e          (riscv_jump_e)                        ,
    .o_riscv_de_opcode_e        (riscv_opcode_e)                      
  );

  riscv_estage u_riscv_estage(
    .i_riscv_estage_clk                   (i_riscv_datapath_clk)             ,
    .i_riscv_estage_rst                   (i_riscv_datapath_rst)             ,
    .i_riscv_estage_rs1data               (riscv_rs1data_e)                  ,
    .i_riscv_estage_rs2data               (riscv_rs2data_e)                  ,
    .i_riscv_estage_fwda                  (i_riscv_datapath_fwda)            ,
    .i_riscv_estage_fwdb                  (i_riscv_datapath_fwdb)            ,
    .i_riscv_estage_rdata_wb              (riscv_rddata_wb)                  ,
    .i_riscv_estage_rddata_m              (riscv_rddata_me)                  ,
    .i_riscv_estage_imm_m                 (riscv_imm_m)                      ,
    .i_riscv_estage_oprnd1sel             (riscv_oprnd1sel_e)                ,
    .i_riscv_estage_oprnd2sel             (riscv_oprnd2sel_e)                ,
    .i_riscv_estage_pc                    (riscv_pc_e)                       ,
    .i_riscv_estage_aluctrl               (riscv_alucontrol_e)               ,
    .i_riscv_estage_mulctrl               (riscv_mulctrl_e)                  ,
    .i_riscv_estage_divctrl               (riscv_divctrl_e)                  ,
    .i_riscv_estage_funcsel               (riscv_funcsel_e)                  ,
    .i_riscv_estage_simm                  (riscv_extendedimm_e)              ,
    .i_riscv_estage_bcond                 (riscv_b_condition_e)              ,
    .i_riscv_stage_opcode                 (riscv_opcode_e)                   , //<---
    .i_riscv_estage_memext                (riscv_memext_e)                   , //<---
    .i_riscv_estage_storesrc              (riscv_storesrc_e)                 , //<---
    .i_riscv_estage_imm_reg               (immreg_de_estage)                 , //<---
    .i_riscv_estage_immextended           (immzeroextend_de_estage)          , //<---     
    .o_riscv_estage_result                (riscv_aluexe_fe)                  ,
    .o_riscv_estage_store_data            (riscv_store_data)                 ,
    .o_riscv_estage_branchtaken           (riscv_branchtaken)                ,
    .o_riscv_estage_icu_valid             (o_riscv_datapath_icu_valid_e)     ,
    .o_riscv_estage_mul_en                (o_datapath_mul_en)                ,
    .o_riscv_estage_div_en                (o_datapath_div_en)                ,
    .o_riscv_estage_csrwritedata          (csrwritedata_estage_em)           ,     
    .o_riscv_estage_inst_addr_misaligned  (inst_addr_misaligned_estage_em)   , //<---
    .o_riscv_estage_store_addr_misaligned (store_addr_misaligned_estage_em)  , //<---  
    .o_riscv_estage_load_addr_misaligned  (load_addr_misaligned_estage_em)     //<---
  );

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
    .i_riscv_em_en                      (i_riscv_datapath_stall_em)        ,
    .i_riscv_em_clk                     (i_riscv_datapath_clk)             ,
    .i_riscv_em_rst                     (i_riscv_datapath_rst)             ,
    .i_riscv_em_regw_e                  (riscv_regwrite_e)                 ,
    .i_riscv_em_resultsrc_e             (riscv_resultsrc_e)                ,
    .i_riscv_em_storesrc_e              (riscv_storesrc_e)                 ,
    .i_riscv_em_memext_e                (riscv_memext_e)                   ,
    .i_riscv_em_pcplus4_e               (riscv_pcplus4_e)                  ,
    .i_riscv_em_result_e                (riscv_aluexe_fe)                  ,
    .i_riscv_em_storedata_e             (riscv_store_data)                 ,
    .i_riscv_em_rdaddr_e                (riscv_rdaddr_e)                   ,
    .i_riscv_em_imm_e                   (riscv_extendedimm_e)              ,
    .i_riscv_de_opcode_e                (riscv_opcode_e)                   ,
    .i_riscv_em_flush                   (riscv_reg_flush)                  , //<---
    .i_riscv_em_ecall_m_e               (ecallm_de_em)                     , //<--- 
    .i_riscv_em_csraddress_e            (csraddress_de_em)                 , //<---  
    .i_riscv_em_illegal_inst_e          (illegal_inst_de_em)               , //<---
    .i_riscv_em_iscsr_e                 (iscsr_de_em)                      , //<---
    .i_riscv_em_csrop_e                 (csrop_de_em)                      , //<---   
    .i_riscv_em_addressalu_e            (addressalu_de_em)                 , //<---
    .i_riscv_em_inst_addr_misaligned_e  (inst_addr_misaligned_estage_em)   , //<---
    .i_riscv_em_load_addr_misaligned_e  (load_addr_misaligned_estage_em)   , //<---
    .i_riscv_em_store_addr_misaligned_e (store_addr_misaligned_estage_em)  , //<--- 
    .i_riscv_em_csrwritedata_e          (csrwritedata_estage_em)           , //<---
    .i_riscv_em_rs1addr_e               (o_riscv_datapath_rs1addr_e)       , //<---
    .o_riscv_em_rs1addr_m               (o_riscv_datapath_rs1addr_m)       , //<---     
    .o_riscv_em_ecall_m_m               (m_em_csr)                         , //<--- 
    .o_riscv_em_csraddress_m            (csraddress_em_csr)                , //<---  
    .o_riscv_em_illegal_inst_m          (illegal_inst_em_csr)              , //<---
    .o_riscv_em_iscsr_m                 (iscsr_csr_mw)                     , //<---
    .o_riscv_em_csrop_m                 (csrop_em_csr)                     , //<---    
    .o_riscv_em_addressalu_m            (addressalu_em_csr)                , //<--- 
    .o_riscv_em_inst_addr_misaligned_m  (inst_addr_misaligned_em_csr)      , //<---
    .o_riscv_em_load_addr_misaligned_m  (load_addr_misaligned_em_csr)      , //<---
    .o_riscv_em_store_addr_misaligned_m (store_addr_misaligned_em_csr)     , //<---
    .o_riscv_em_csrwritedata_m          (csrwdata_em_csr)                  , //<---
    .o_riscv_em_regw_m                  (riscv_regw_m)                     ,
    .o_riscv_em_resultsrc_m             (riscv_resultsrc_m)                ,
    .o_riscv_em_storesrc_m              (o_riscv_datapath_storesrc_m)      ,
    .o_riscv_em_memext_m                (riscv_memext_m)                   ,
    .o_riscv_em_pcplus4_m               (riscv_pcplus4_m)                  ,
    .o_riscv_em_result_m                (riscv_rddata_me )                 ,
    .o_riscv_em_storedata_m             (o_riscv_datapath_storedata_m)     ,
    .o_riscv_em_rdaddr_m                (riscv_rdaddr_m)                   ,
    .o_riscv_em_imm_m                   (riscv_imm_m)                      ,  
    .o_riscv_de_opcode_m                (o_riscv_datapath_opcode_m)           
  );


  riscv_mstage u_riscv_mstage(
    .i_riscv_mstage_dm_rdata    (i_riscv_datapath_dm_rdata)         ,
    .i_riscv_mstage_memext      (riscv_memext_m)                    ,
    .i_riscv_mstage_addr        (riscv_rddata_me)		    ,
    .i_riscv_mstage_mux2_sel    (i_riscv_datapath_muxcsr_sel)       , //<---
    .i_riscv_mux2_in0           (csrwdata_em_csr)                   , //<---
    .i_riscv_mux2_in1           (csrout_csr_mw)                     , //<--- 
    .o_riscv_mstage_memload     (riscv_memload_m)                   ,
    .o_riscv_mstage_mux2_out    (muxout_csr)                           //<---
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
    .i_riscv_mw_en                (i_riscv_datapath_stall_mw)     ,
    .i_riscv_mw_clk               (i_riscv_datapath_clk)          ,
    .i_riscv_mw_rst               (i_riscv_datapath_rst)          ,
    .i_riscv_mw_pcplus4_m         (riscv_pcplus4_m)               ,
    .i_riscv_mw_result_m          (riscv_rddata_me)               ,
    .i_riscv_mw_uimm_m            (riscv_imm_m)                   ,
    .i_riscv_mw_memload_m         (riscv_memload_m)               , //<--- ?
    .i_riscv_mw_rdaddr_m          (riscv_rdaddr_m)                ,
    .i_riscv_mw_resultsrc_m       (riscv_resultsrc_m)             ,
    .i_riscv_mw_regw_m            (riscv_regw_m)                  , //<---
    .i_riscv_mw_flush             (riscv_reg_flush)               , //<---
    .i_riscv_mw_csrout_m          (csrout_mw_trap)                , //<---
    .i_riscv_mw_iscsr_m           (iscsr_csr_mw)                  , //<---
    .i_riscv_mw_returnfromtrap_m  (returnfromtrap_csr_mw)         , //<---
    .i_riscv_mw_gototrap_m        (gototrap_csr_mw)               , //<---
    .o_riscv_mw_pcplus4_wb        (riscv_pcplus4_wb)              ,
    .o_riscv_mw_result_wb         (riscv_result_wb)               ,
    .o_riscv_mw_uimm_wb           (riscv_uimm_wb)                 ,
    .o_riscv_mw_memload_wb        (riscv_memload_wb)              ,
    .o_riscv_mw_rdaddr_wb         (riscv_rdaddr_wb)               ,
    .o_riscv_mw_resultsrc_wb      (riscv_resultsrc_wb)            ,
    .o_riscv_mw_regw_wb           (riscv_regw_wb)                 ,
    .o_riscv_mw_csrout_wb         (csrout_csr_mw)                 , //<---
    .o_riscv_mw_iscsr_wb          (iscsr_mw_trap)                 , //<---
    .o_riscv_mw_gototrap_wb       (gototrap_mw_trap)              , //<---
    .o_riscv_mw_returnfromtrap_wb (returnfromtrap_mw_trap)          //<---
  );

////////////////////////////////
  riscv_wbstage u_riscv_wbstage(
    .i_riscv_wb_resultsrc       (riscv_resultsrc_wb)        , 
    .i_riscv_wb_pcplus4         (riscv_pcplus4_wb)          ,
    .i_riscv_wb_result          (riscv_result_wb)           ,
    .i_riscv_wb_memload         (riscv_memload_wb)          ,
    .i_riscv_wb_uimm            (riscv_uimm_wb)             ,
    .i_riscv_wb_csrout          (csrout_csr_mw)             , //<---    
    .i_riscv_wb_iscsr           (iscsr_mw_trap)             , //<---
    .i_riscv_wb_gototrap        (gototrap_mw_trap)          , //<---
    .i_riscv_wb_returnfromtrap  (returnfromtrap_mw_trap)    , //<---
    .o_riscv_wb_rddata          (riscv_rddata_wb)           ,
    .o_riscv_wb_pcsel           (pcsel_trap_fetchpc)        , //<---
    .o_riscv_wb_flush           (riscv_reg_flush)             //<---
); 

////////////////////////////////
 riscv_csrfile u_riscv_csrfile (  
  .i_riscv_csr_clk                    (i_riscv_datapath_clk)           ,
  .i_riscv_csr_rst                    (i_riscv_datapath_rst)           ,
  .i_riscv_csr_address                (csraddress_em_csr)              ,
  .i_riscv_csr_op                     (csrop_em_csr)                   ,
  .i_riscv_csr_wdata                  (muxout_csr)                     ,
  .i_riscv_csr_external_int           (i_riscv_core_externalinterupt)  , 
  .i_riscv_csr_timer_int              (i_riscv_core_timerinterupt)     ,
  .i_riscv_csr_ecall_u                (ecall_u_em_csr)                 ,
  .i_riscv_csr_ecall_s                (ecall_s_em_csr)                 ,
  .i_riscv_csr_ecall_m                (m_em_csr)                       ,
  .i_riscv_csr_illegal_inst           ()                               , //illegal_inst_em_csr
  .i_riscv_csr_inst_addr_misaligned   (inst_addr_misaligned_em_csr)    , 
  .i_riscv_csr_load_addr_misaligned   (load_addr_misaligned_em_csr)    ,   
  .i_riscv_csr_store_addr_misaligned  (store_addr_misaligned_em_csr)   ,
  .i_riscv_csr_pc                     (riscv_pcplus4_m)                ,
  .i_riscv_csr_addressALU             (addressalu_em_csr)              , 
  .o_riscv_csr_return_address         (mepc_csr_pctrap)                ,
  .o_riscv_csr_trap_address           (mtvec_csr_pctrap)               , 
  .o_riscv_csr_gotoTrap_cs            (gototrap_csr_mw)                ,
  .o_riscv_csr_returnfromTrap_cs      (returnfromtrap_csr_mw)          ,
  .o_riscv_csr_rdata                  (csrout_mw_trap)                 ,  
  .o_riscv_csr_privlvl                (o_riscv_core_privlvl_csr_cu)    ,
  .o_riscv_csr_sideeffect_flush       ()                               ,
  .o_riscv_csr_flush                  ()
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
  .i_riscv_trc_store      (riscv_rs2data_wb)            ,
  .i_riscv_trc_rddata     (riscv_rddata_wb)
  ); 
  `endif
// <---------------------------------------------------

endmodule
