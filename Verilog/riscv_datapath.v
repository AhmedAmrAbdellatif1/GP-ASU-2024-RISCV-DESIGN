module riscv_datapath #(parameter MXLEN = 64) (
  input  wire              i_riscv_datapath_clk,
  input  wire              i_riscv_datapath_rst,
/************************* Fetch Stage Signals *************************/
  input  wire              i_riscv_datapath_stallpc           ,
  output wire [63:0]       o_riscv_datapath_pc                , 
/************************* Fetch PP wireister Signals *************************/ 
  input  wire [31:0]       i_riscv_datapath_inst              ,
  input  wire              i_riscv_datapath_flush_fd          ,  
  input  wire              i_riscv_datapath_stall_fd          ,
/************************* Decode Stage Signals *************************/ 
  input  wire [2:0]        i_riscv_datapath_immsrc            , 
  output wire [6:0]        o_riscv_datapath_opcode            , 
  output wire [2:0]        o_riscv_datapath_func3             , 
  output wire [6:0]        o_riscv_datapath_func7             ,
  output wire [4:0]        o_riscv_datapath_rs1addr_d         , 
  output wire [4:0]        o_riscv_datapath_rs2addr_d         ,
/************************* Decoder PP wireister Signals *************************/ 
  input  wire              i_riscv_datapath_wirew              ,  
  input  wire              i_riscv_datapath_jump              ,        
  input  wire              i_riscv_datapath_asel              ,  
  input  wire              i_riscv_datapath_bsel              ,  
  input  wire              i_riscv_datapath_memw              ,  
  input  wire              i_riscv_datapath_memr              ,  
  input  wire [1:0]        i_riscv_datapath_storesrc          ,  
  input  wire [2:0]        i_riscv_datapath_resultsrc         ,  
  input  wire [3:0]        i_riscv_datapath_bcond             ,  
  input  wire [2:0]        i_riscv_datapath_memext            ,  
  input  wire [5:0]        i_riscv_datapath_aluctrl           ,  
  input  wire [3:0]        i_riscv_datapath_mulctrl           ,
  input  wire [3:0]        i_riscv_datapath_divctrl           ,
  input  wire [1:0]        i_riscv_datapath_funcsel           ,  
  input  wire              i_riscv_datapath_flush_de          ,
  input  wire              i_riscv_datapath_instret           ,
  input  wire [1:0]        i_riscv_datapath_lr                ,  
  input  wire [1:0]        i_riscv_datapath_sc                ,  
  input  wire [4:0]        i_riscv_datapath_amo_op            ,
  input  wire              i_riscv_datapath_amo               ,   
/************************* Execute Stage Signals *************************/ 
  input  wire [1:0]        i_riscv_datapath_fwda              ,  
  input  wire [1:0]        i_riscv_datapath_fwdb              ,   
  output wire              o_riscv_datapath_icu_valid_e       ,    
  output wire              o_riscv_datapath_pcsrc_e           ,    
  output wire [4:0]        o_riscv_datapath_rs1addr_e         ,  
  output wire [4:0]        o_riscv_datapath_rs2addr_e         ,  
  output wire [4:0]        o_riscv_datapath_rdaddr_e          ,  
  output wire [2:0]        o_riscv_datapath_resultsrc_e       ,  
  output wire [6:0]        o_riscv_datapath_opcode_m          ,
  output wire              o_datapath_div_en                  ,   
  output wire              o_datapath_mul_en                  ,
/************************* Memory Stage Signals *************************/ 
  input  wire [63:0]       i_riscv_datapath_dm_rdata          ,
  output wire [4:0]        o_riscv_datapath_rdaddr_m          ,  
  output wire              o_riscv_datapath_memw_e            ,
  output wire              o_riscv_datapath_memr_e            ,
  output wire              o_riscv_datapath_amo               ,
  output wire [4:0]        o_riscv_datapath_amo_op            ,
  output wire [1:0]        o_riscv_datapath_storesrc_m        ,
  output wire [63:0]       o_riscv_datapath_memodata_addr     ,
  output wire [63:0]       o_riscv_datapath_storedata_m       ,
  output wire              o_riscv_datapath_wirew_m            ,  
  
/************************* WB Stage Signals *************************/
  input  wire              i_riscv_datapath_icache_stall_wb   ,
  output wire              o_riscv_datapath_wirew_wb           ,    
  output wire [4:0]        o_riscv_datapath_rdaddr_wb         ,  
/************************* Stall Signals *************************/ 
  input  wire              i_riscv_datapath_stall_de          ,
  input  wire              i_riscv_datapath_stall_em          ,
  input  wire              i_riscv_datapath_stall_mw          ,
/************************* CSR Signals *************************/ 
  input  wire              i_riscv_datapath_muxcsr_sel        ,
  input  wire              i_riscv_datapath_globstall         ,
  output wire              o_riscv_datapath_iscsr_w_trap      ,
  output wire              o_riscv_datapath_iscsr_m_trap      ,
  output wire              o_riscv_datapath_iscsr_e_trap      ,
  output wire              o_riscv_datapath_iscsr_d_trap      ,
  output wire              o_riscv_datapath_tsr               ,
/************************* Traps Signals *************************/ 
  input   wire             i_riscv_datapath_illgalinst_cu_de  ,
  input   wire [2:0]       i_riscv_datapath_csrop_cu_de       ,
  input   wire             i_riscv_datapath_iscsr_cu_de       ,
  input   wire             i_riscv_datapath_ecallu_cu_de      ,
  input   wire             i_riscv_datapath_ecalls_cu_de      ,
  input   wire             i_riscv_datapath_ecallm_cu_de      ,
  input   wire             i_riscv_datapath_immwire_cu_de      ,
  input   wire             i_riscv_core_timer_interrupt       ,
  input   wire             i_riscv_core_external_interrupt    ,
  input   wire [63:0]      i_riscv_timer_datapath_rdata       ,
  input   wire [63:0]      i_riscv_timer_datapath_time        ,
  output  wire [4:0]       o_riscv_datapath_rs1_fd_cu         ,
  output  wire [11:0]      o_riscv_datapath_constimm12_fd_cu  ,
  output  wire [1:0]       o_riscv_core_privlvl_csr_cu        ,
  output  wire [4:0]       o_riscv_datapath_rs1addr_m         ,
  output wire              o_riscv_datapath_timer_wren        ,
  output wire              o_riscv_datapath_timer_rden        ,
  output wire [1:0]        o_riscv_datapath_timer_wiresel      
 );

/************************* Fetch Stage Signals *************************/
  wire  [63:0]  riscv_aluexe_fe     ;  
  wire  [63:0]  riscv_pcplus4_f     ;
  wire  [31:0]  riscv_inst_f        ;
/************************* Decode Stage Signals *************************/
  wire  [31:0]  riscv_inst_d        ;
  wire  [4:0]   riscv_rdaddr_d      ;
  wire  [4:0]   riscv_rdaddr_wb     ; 
  wire  [63:0]  riscv_rddata_wb     ;
  wire          riscv_wirew_wb       ;
  wire  [63:0]  riscv_rs1data_d     ;
  wire  [63:0]  riscv_rs2data_d     ;
  wire  [63:0]  riscv_simm_d        ;
  wire  [63:0]  riscv_pcplus4_d     ;
  wire  [63:0]  riscv_pc_d          ;
  wire  [4:0]   riscv_rs1addr_d     ;
  wire  [4:0]   riscv_rs2addr_d     ;
  wire  [6:0]   riscv_opcode_d      ;
 
/************************* Execute Stage Signals *************************/
  wire  [6:0]   riscv_opcode_e      ;
  wire  [63:0]  riscv_pc_e          ;
  wire  [63:0]  riscv_pcplus4_e     ;
  wire  [4:0]   riscv_rs1addr_e     ;
  wire  [63:0]  riscv_rs1data_e     ;
  wire  [63:0]  riscv_rs2data_e     ;
  wire  [63:0]  riscv_store_data    ;
  wire  [4:0]   riscv_rs2addr_e     ;
  wire  [4:0]   riscv_rdaddr_e      ;
  wire  [63:0]  riscv_extendedimm_e ;
  wire  [3:0]   riscv_b_condition_e ;
  wire          riscv_oprnd2sel_e   ;
  wire  [1:0]   riscv_storesrc_e    ;
  wire  [5:0]   riscv_alucontrol_e  ;
  wire  [3:0]   riscv_mulctrl_e     ;
  wire  [3:0]   riscv_divctrl_e     ;
  wire  [1:0]   riscv_funcsel_e     ;
  wire          riscv_oprnd1sel_e   ;
  wire  [2:0]   riscv_memext_e      ;
  wire  [2:0]   riscv_resultsrc_e   ;
  wire          riscv_wirewrite_e    ;
  wire          riscv_jump_e        ;
  wire          riscv_branchtaken   ;
  wire          riscv_instret_e     ;
  wire  [1:0]   riscv_lr_e          ;    
  wire  [1:0]   riscv_sc_e          ;    
  wire  [4:0]   riscv_amo_op_e      ;
  wire          riscv_amo_e         ;
  wire  [63:0]  riscv_rddata_sc_e   ;
/************************* Memory Stage Signals *************************/
  wire  [63:0]  riscv_pc_m                   ;
  wire  [63:0]  riscv_pcplus4_m              ;
  wire  [63:0]  riscv_rddata_me              ;
  wire          riscv_wirew_m                 ;
  wire  [2:0]   riscv_resultsrc_m            ;
  wire  [2:0]   riscv_memext_m               ;
  wire  [4:0]   riscv_rdaddr_m               ;
  wire  [63:0]  riscv_imm_m                  ;
  wire  [63:0]  riscv_memload_m              ;
  wire          riscv_instret_m              ;
  wire  [4:0]   riscv_amo_op_m               ;
  wire  [63:0]  riscv_rddata_sc_m            ;
  wire          datapath_memw_e              ;
  wire          datapath_memr_e              ;
  wire  [63:0]  riscv_datapath_memodata_addr ;
  wire          riscv_em_timer_wren          ;
  wire          riscv_em_timer_rden          ;
  wire  [1:0]   riscv_em_timer_wiresel        ;
/************************* WB Stage Signals *************************/      
  wire  [63:0]  riscv_pc_wb         ;
  wire  [63:0]  riscv_pcplus4_wb    ;
  wire  [63:0]  riscv_result_wb     ;
  wire  [63:0]  riscv_uimm_wb       ;
  wire  [63:0]  riscv_memload_wb    ;
  wire  [63:0]  riscv_rddata_sc_wb  ;
  wire  [2:0]   riscv_resultsrc_wb  ; 
  wire          riscv_instret_wb    ;
/************************* Tracer Signals *************************/
  //--------------------------------->
 
  wire [31:0]   riscv_inst_wb       ;
  wire [15:0]   riscv_cinst_wb      ;     
  wire [63:0]   riscv_memaddr_wb    ;
  wire [63:0]   riscv_rs2data_wb    ;
 
  //<---------------------------------
  wire [31:0]   riscv_inst_e        ;
  wire [15:0]   riscv_cinst_e       ;
  wire [31:0]   riscv_inst_m        ;
  wire [15:0]   riscv_cinst_d       ;
  wire [15:0]   riscv_cinst_m       ;
/************************* Trap & CSR Signals *************************/
  wire               riscv_wire_flush                  ;
  wire               gototrap_mw_trap                 ;
  wire [1:0]         returnfromtrap_mw_trap           ;
  wire               iscsr_mw_trap                    ;
  wire [63:0]        csrout_mw_trap                   ;
  wire [1:0]         pcsel_trap_fetchpc               ;
  wire               gototrap_csr_mw                  ;
  wire [1:0]         returnfromtrap_csr_mw            ;
  wire               iscsr_csr_mw                     ;
  wire [MXLEN-1:0]   csrout_csr_mw                    ; 
  wire [MXLEN-1:0]   mtvec_csr_pctrap                 ; 
  wire [MXLEN-1:0]   mepc_csr_pctrap                  ; 
  wire               ecallu_de_em                     ;  
  wire               ecalls_de_em                     ;
  wire               ecallm_de_em                     ;
  wire               illegal_inst_de_em               ;
  wire               iscsr_de_em                      ;  
  wire [2:0]         csrop_de_em                      ;
  wire [2:0]         csrop_de_em_illegal              ;
  wire [11:0]        csraddress_de_em                 ;
  wire [63:0]        addressalu_de_em                 ;
  wire               ecall_u_em_csr                   ;
  wire               ecall_s_em_csr                   ;
  wire               m_em_csr                         ;
  wire [11:0]        csraddress_em_csr                ;
  wire               illegal_inst_em_csr              ;
  wire               iscsr_em_csr                     ;
  wire [2:0]         csrop_em_csr                     ;
  wire [63:0]        addressalu_em_csr                ;
  wire [63:0]        csrwdata_em_csr                  ;
  wire [2:0]         csrop_de                         ;
  wire [63:0]        immzeroextend_dstage_de          ; 
  wire [63:0]        immzeroextend_de_estage          ;
  wire               immwire_de_estage                 ;
  wire               inst_addr_misaligned_em_csr      ;
  wire               load_addr_misaligned_em_csr      ;
  wire               store_addr_misaligned_em_csr     ;
  wire [63:0]        csrwritedata_em_csr              ;
  wire [63:0]        csrwritedata_estage_em           ;
  wire               load_addr_misaligned_estage_em   ;    
  wire               store_addr_misaligned_estage_em  ;
  wire               inst_addr_misaligned_estage_em   ;
  wire               riscv_cillegal_inst_d            ;
  wire [63:0]        muxout_csr                       ;
  wire               csr_is_compressed_flag           ;
  wire [63:0]        csr_sepc                             ;
  
  ////////////////////////////////////////////////////////////////////////////////////
  
  assign o_riscv_datapath_pcsrc_e       = riscv_jump_e | riscv_branchtaken;
  assign o_riscv_datapath_opcode        = riscv_opcode_d          ;
  assign o_riscv_datapath_rdaddr_m      = riscv_rdaddr_m          ;  // to hazard unit
  assign o_riscv_datapath_rdaddr_e      = riscv_rdaddr_e          ;  // to hazard unit
  assign o_riscv_datapath_rdaddr_wb     = riscv_rdaddr_wb         ;  // to hazard unit
  assign o_riscv_datapath_wirew_m        = riscv_wirew_m            ;  // to hazard unit
  assign o_riscv_datapath_wirew_wb       = riscv_wirew_wb           ;  // to hazard unit
  assign o_riscv_datapath_resultsrc_e   = riscv_resultsrc_e       ;  // to hazard unit
  assign o_riscv_datapath_rs1addr_d     = riscv_rs1addr_d         ;  // to hazard unit
  assign o_riscv_datapath_rs2addr_d     = riscv_rs2addr_d         ;  // to hazard unit
  
  assign o_riscv_datapath_amo     = riscv_amo_e ;
  assign o_riscv_datapath_amo_op  = riscv_amo_op_m ;
  
  assign csrop_de_em_illegal    = (gototrap_csr_mw || returnfromtrap_csr_mw)? 3'b000:csrop_de_em;
  assign csr_is_compressed_flag = ~&(riscv_cinst_m[1:0]);
  
  assign riscv_rstctrl_f  = i_riscv_datapath_flush_fd | i_riscv_datapath_rst | riscv_wire_flush;
  assign riscv_rstctrl_d  = i_riscv_datapath_flush_de | i_riscv_datapath_rst | riscv_wire_flush | gototrap_csr_mw | returnfromtrap_csr_mw;
  
  assign o_riscv_datapath_iscsr_w_trap  = iscsr_mw_trap                 ;
  assign o_riscv_datapath_iscsr_m_trap  = iscsr_csr_mw                  ; 
  assign o_riscv_datapath_iscsr_e_trap  = iscsr_de_em                   ;
  assign o_riscv_datapath_iscsr_d_trap  = i_riscv_datapath_iscsr_cu_de  ;
  assign illegal_inst_d = i_riscv_datapath_illgalinst_cu_de | riscv_cillegal_inst_d ;
  
  /************************* ************** *************************/
  /************************* Instantiations *************************/
  /************************* ************** *************************/
  
  riscv_fstage u_riscv_fstage (
    .i_riscv_fstage_clk           (i_riscv_datapath_clk)              ,
    .i_riscv_fstage_rst           (i_riscv_datapath_rst)              ,
    .i_riscv_fstage_stallpc       (i_riscv_datapath_stallpc)          ,
    .i_riscv_fstage_aluexe        (riscv_aluexe_fe)                   ,
    .i_riscv_fstage_inst          (i_riscv_datapath_inst)             ,
    .i_riscv_fstage_pcsrc         (o_riscv_datapath_pcsrc_e)          ,
    .i_riscv_fstage_pcsel         (pcsel_trap_fetchpc)                ,   
    .i_riscv_fstage_mtvec         (mtvec_csr_pctrap)                  ,         
    .i_riscv_fstage_mepc          (mepc_csr_pctrap)                   ,   
    .i_riscv_fstage_sepc          (csr_sepc)                          ,
    .o_riscv_fstage_pc            (o_riscv_datapath_pc)               ,
    .o_riscv_fstage_pcplus4       (riscv_pcplus4_f)                   ,
    .o_riscv_fstage_inst          (riscv_inst_f)                      ,
    .o_riscv_fstage_cillegal_inst (riscv_cillegal_inst)                    
  );

  riscv_ppwire_fd u_riscv_fd_ppwire(
    .i_riscv_fd_clk             (i_riscv_datapath_clk)            ,
    .i_riscv_fd_rst             (i_riscv_datapath_rst)            ,
    .i_riscv_fd_flush           (riscv_rstctrl_f)                 ,   
    .i_riscv_fd_en              (i_riscv_datapath_stall_fd)       ,
    .i_riscv_fd_pc_f            (o_riscv_datapath_pc)             ,
    .i_riscv_fd_inst_f          (riscv_inst_f)                    ,
    .i_riscv_fd_pcplus4_f       (riscv_pcplus4_f)                 ,
    .i_riscv_fd_cillegal_inst_f (riscv_cillegal_inst)             ,
    .i_riscv_fd_cinst_f         (i_riscv_datapath_inst[15:0])     ,
    .o_riscv_fd_cinst_d         (riscv_cinst_d)                   ,  
    .o_riscv_fd_pc_d            (riscv_pc_d)                      ,
    .o_riscv_fd_inst_d          (riscv_inst_d)                    ,
    .o_riscv_fd_pcplus4_d       (riscv_pcplus4_d)                 ,
    .o_riscv_fd_rs1_d           (o_riscv_datapath_rs1_fd_cu)      ,  
    .o_riscv_fd_cillegal_inst_d (riscv_cillegal_inst_d)           ,  
    .o_riscv_fd_constimm12_d    (o_riscv_datapath_constimm12_fd_cu)   
  );

  riscv_dstage u_riscv_dstage(
    .i_riscv_dstage_clk_n       (i_riscv_datapath_clk)            ,
    .i_riscv_dstage_wirew        (riscv_wirew_wb)                   ,
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
    .o_riscv_dstage_func7        (o_riscv_datapath_func7)         ,
    .o_riscv_dstage_immzeroextend(immzeroextend_dstage_de)                   

  );

  riscv_ppwire_de u_riscv_de_ppwire(
    .i_riscv_de_en              (i_riscv_datapath_stall_de)           ,
    .i_riscv_de_clk             (i_riscv_datapath_clk)                ,
    .i_riscv_de_rst             (i_riscv_datapath_rst)                ,
    .i_riscv_de_flush           (riscv_rstctrl_d)                     ,       
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
    .i_riscv_de_wirewrite_d      (i_riscv_datapath_wirew)               ,
    .i_riscv_de_jump_d          (i_riscv_datapath_jump)               ,
    .i_riscv_de_pcplus4_d       (riscv_pcplus4_d)                     ,
    .i_riscv_de_opcode_d        (riscv_opcode_d)                      ,
    .i_riscv_de_ecall_m_d       (i_riscv_datapath_ecallm_cu_de)       , 
    .i_riscv_de_ecall_u_d       (i_riscv_datapath_ecallu_cu_de)       ,                                             //>>
    .i_riscv_de_ecall_s_d       (i_riscv_datapath_ecalls_cu_de)       ,                                              //<<
    .i_riscv_de_csraddress_d    (riscv_inst_d[31:20])                 ,     
    .i_riscv_de_illegal_inst_d  (illegal_inst_d)                      ,  
    .i_riscv_de_iscsr_d         (i_riscv_datapath_iscsr_cu_de)        ,   
    .i_riscv_de_csrop_d         (i_riscv_datapath_csrop_cu_de)        ,     
    .i_riscv_de_immwire_d        (i_riscv_datapath_immwire_cu_de)       ,  
    .i_riscv_de_immzeroextend_d (immzeroextend_dstage_de)             ,    
    .i_riscv_de_instret_d       (i_riscv_datapath_instret)            ,  
    .i_riscv_de_lr_d            (i_riscv_datapath_lr)                 ,
    .i_riscv_de_sc_d            (i_riscv_datapath_sc)                 ,
    .i_riscv_de_amo_op_d        (i_riscv_datapath_amo_op)             ,
    .i_riscv_de_amo_d           (i_riscv_datapath_amo)                ,
    .i_riscv_de_inst            (riscv_inst_d)                        ,
    .i_riscv_de_cinst           (riscv_cinst_d)                       ,
    
    .o_riscv_de_inst            (riscv_inst_e)                        ,
    .o_riscv_de_cinst           (riscv_cinst_e)                       ,
    .o_riscv_de_lr_e            (riscv_lr_e)                          ,
    .o_riscv_de_sc_e            (riscv_sc_e)                          ,
    .o_riscv_de_amo_op_e        (riscv_amo_op_e)                      ,
    .o_riscv_de_amo_e           (riscv_amo_e)                         ,
    .o_riscv_de_instret_e       (riscv_instret_e )                    ,   
    .o_riscv_de_ecall_m_e       (ecallm_de_em)                        ,  
    .o_riscv_de_ecall_s_e       (ecalls_de_em)                       ,   // >>
    .o_riscv_de_ecall_u_e       (ecallu_de_em)                        ,  //>>

    .o_riscv_de_csraddress_e    (csraddress_de_em)                    ,           
    .o_riscv_de_illegal_inst_e  (illegal_inst_de_em)                  ,  
    .o_riscv_de_iscsr_e         (iscsr_de_em)                         ,  
    .o_riscv_de_csrop_e         (csrop_de_em)                         ,     
    .o_riscv_de_immwire_e        (immwire_de_estage)                    ,  
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
    .o_riscv_de_memwrite_e      (datapath_memw_e)                     ,
    .o_riscv_de_memread_e       (datapath_memr_e)                     ,
    .o_riscv_de_memext_e        (riscv_memext_e)                      ,
    .o_riscv_de_resultsrc_e     (riscv_resultsrc_e)                   ,
    .o_riscv_de_wirewrite_e      (riscv_wirewrite_e)                    ,
    .o_riscv_de_jump_e          (riscv_jump_e)                        ,
    .o_riscv_de_opcode_e        (riscv_opcode_e)                      
  );

  riscv_estage u_riscv_estage(
    .i_riscv_estage_clk                   (i_riscv_datapath_clk)             ,
    .i_riscv_estage_rst                   (i_riscv_datapath_rst)             ,
    .i_riscv_estage_globstall             (i_riscv_datapath_globstall)       ,
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
    .i_riscv_estage_opcode                (riscv_opcode_e)                   ,  
    .i_riscv_estage_memext                (riscv_memext_e)                   ,  
    .i_riscv_estage_storesrc              (riscv_storesrc_e)                 ,  
    .i_riscv_estage_imm_wire               (immwire_de_estage)                 ,  
    .i_riscv_estage_immextended           (immzeroextend_de_estage)          ,   
    .i_riscv_estage_lr                    (riscv_lr_e)                       ,  
    .i_riscv_estage_sc                    (riscv_sc_e)                       ,   
    .i_riscv_estage_amo                   (riscv_amo_e)                      ,
    .i_riscv_estage_memw                  (datapath_memw_e)                  ,
    .i_riscv_estage_memr                  (datapath_memr_e)                  ,
    .i_riscv_estage_gtrap                 (gototrap_csr_mw)                  ,
    .i_riscv_estage_rtrap                 (returnfromtrap_csr_mw)            ,
    .o_riscv_estage_dcache_wren           (o_riscv_datapath_memw_e)          ,
    .o_riscv_estage_dcache_rden           (o_riscv_datapath_memr_e)          ,
    .o_riscv_estage_dcache_addr           (riscv_datapath_memodata_addr)     ,
    .o_riscv_estage_rddata_sc             (riscv_rddata_sc_e)                ,
    .o_riscv_estage_result                (riscv_aluexe_fe)                  ,
    .o_riscv_estage_store_data            (riscv_store_data)                 ,
    .o_riscv_estage_branchtaken           (riscv_branchtaken)                ,
    .o_riscv_estage_icu_valid             (o_riscv_datapath_icu_valid_e)     ,
    .o_riscv_estage_mul_en                (o_datapath_mul_en)                ,
    .o_riscv_estage_div_en                (o_datapath_div_en)                ,
    .o_riscv_estage_csrwritedata          (csrwritedata_estage_em)           ,     
    .o_riscv_estage_inst_addr_misaligned  (inst_addr_misaligned_estage_em)   ,  
    .o_riscv_estage_store_addr_misaligned ()  ,    
    .o_riscv_estage_load_addr_misaligned  ()  ,
    .o_riscv_estage_timer_wren            (riscv_em_timer_wren)              ,
    .o_riscv_estage_timer_rden            (riscv_em_timer_rden)              ,
    .o_riscv_estage_timer_wiresel          (riscv_em_timer_wiresel)
  );

  riscv_ppwire_em u_riscv_em_ppwire(
    .i_riscv_em_pc                      (riscv_pc_e)                       ,
    .i_riscv_em_en                      (i_riscv_datapath_stall_em)        ,
    .i_riscv_em_clk                     (i_riscv_datapath_clk)             ,
    .i_riscv_em_rst                     (i_riscv_datapath_rst)             ,
    .i_riscv_em_wirew_e                  (riscv_wirewrite_e)                 ,
    .i_riscv_em_resultsrc_e             (riscv_resultsrc_e)                ,
    .i_riscv_em_storesrc_e              (riscv_storesrc_e)                 ,
    .i_riscv_em_memext_e                (riscv_memext_e)                   ,
    .i_riscv_em_pcplus4_e               (riscv_pcplus4_e)                  ,
    .i_riscv_em_result_e                (riscv_aluexe_fe)                  ,
    .i_riscv_em_storedata_e             (riscv_store_data)                 ,
    .i_riscv_em_dcache_addr             (riscv_datapath_memodata_addr)     ,
    .i_riscv_em_rdaddr_e                (riscv_rdaddr_e)                   ,
    .i_riscv_em_imm_e                   (riscv_extendedimm_e)              ,
    .i_riscv_em_opcode_e                (riscv_opcode_e)                   ,
    .i_riscv_em_flush                   (riscv_wire_flush)                  ,  
    .i_riscv_em_ecall_m_e               (ecallm_de_em)                     ,   
    .i_riscv_em_ecall_s_e               (ecalls_de_em)                     ,  //>>
    .i_riscv_em_ecall_u_e               (ecallu_de_em)                     ,  //>>
    .i_riscv_em_csraddress_e            (csraddress_de_em)                 ,    
    .i_riscv_em_illegal_inst_e          (illegal_inst_de_em)               ,  
    .i_riscv_em_iscsr_e                 (iscsr_de_em)                      ,  
    .i_riscv_em_csrop_e                 (csrop_de_em_illegal)              ,     
    .i_riscv_em_inst_addr_misaligned_e  (inst_addr_misaligned_estage_em)   ,  
    .i_riscv_em_load_addr_misaligned_e  (load_addr_misaligned_estage_em)   ,  
    .i_riscv_em_store_addr_misaligned_e (store_addr_misaligned_estage_em)  ,   
    .i_riscv_em_csrwritedata_e          (csrwritedata_estage_em)           ,  
    .i_riscv_em_rs1addr_e               (o_riscv_datapath_rs1addr_e)       ,  
    .i_riscv_em_instret_e               (riscv_instret_e)                  ,   
    .i_riscv_em_rddata_sc_e             (riscv_rddata_sc_e)                ,
    .i_riscv_em_amo_op_e                (riscv_amo_op_e)                   ,
    .i_riscv_em_inst                    (riscv_inst_e)                     ,
    .i_riscv_em_cinst                   (riscv_cinst_e)                    ,
    .i_riscv_em_timer_wren              (riscv_em_timer_wren)              ,
    .i_riscv_em_timer_rden              (riscv_em_timer_rden)              ,
    .i_riscv_em_timer_wiresel            (riscv_em_timer_wiresel)            ,
    .o_riscv_em_inst                    (riscv_inst_m)                     , 
    .o_riscv_em_cinst                   (riscv_cinst_m)                    , 
    .o_riscv_em_amo_op_m                (riscv_amo_op_m)                   ,
    .o_riscv_em_rddata_sc_m             (riscv_rddata_sc_m)                ,
    .o_riscv_em_pc                      (riscv_pc_m)                       ,
    .o_riscv_em_instret_m               (riscv_instret_m)                  ,   
    .o_riscv_em_rs1addr_m               (o_riscv_datapath_rs1addr_m)       ,       
    .o_riscv_em_ecall_m_m               (m_em_csr)                         ,   
    .o_riscv_em_ecall_s_m               (s_em_csr)                         , 
    .o_riscv_em_ecall_u_m               (u_em_csr)                         , 
    .o_riscv_em_csraddress_m            (csraddress_em_csr)                , 
    .o_riscv_em_illegal_inst_m          (illegal_inst_em_csr)              ,  
    .o_riscv_em_iscsr_m                 (iscsr_csr_mw)                     ,  
    .o_riscv_em_csrop_m                 (csrop_em_csr)                     ,      
    .o_riscv_em_inst_addr_misaligned_m  (inst_addr_misaligned_em_csr)      ,  
    .o_riscv_em_load_addr_misaligned_m  (load_addr_misaligned_em_csr)      ,  
    .o_riscv_em_store_addr_misaligned_m (store_addr_misaligned_em_csr)     ,  
    .o_riscv_em_csrwritedata_m          (csrwdata_em_csr)                  ,  
    .o_riscv_em_wirew_m                  (riscv_wirew_m)                     ,
    .o_riscv_em_dcache_addr             (o_riscv_datapath_memodata_addr)   ,
    .o_riscv_em_resultsrc_m             (riscv_resultsrc_m)                ,
    .o_riscv_em_storesrc_m              (o_riscv_datapath_storesrc_m)      ,
    .o_riscv_em_memext_m                (riscv_memext_m)                   ,
    .o_riscv_em_pcplus4_m               (riscv_pcplus4_m)                  ,
    .o_riscv_em_result_m                (riscv_rddata_me )                 ,
    .o_riscv_em_storedata_m             (o_riscv_datapath_storedata_m)     ,
    .o_riscv_em_rdaddr_m                (riscv_rdaddr_m)                   ,
    .o_riscv_em_imm_m                   (riscv_imm_m)                      ,  
    .o_riscv_em_opcode_m                (o_riscv_datapath_opcode_m)        ,
    .o_riscv_em_timer_wren              (o_riscv_datapath_timer_wren  )    ,
    .o_riscv_em_timer_rden              (o_riscv_datapath_timer_rden  )    ,
    .o_riscv_em_timer_wiresel            (o_riscv_datapath_timer_wiresel)
  );

  riscv_mstage u_riscv_mstage(
    .i_riscv_mstage_dm_rdata      (i_riscv_datapath_dm_rdata)         ,
    .i_riscv_mstage_timer_rden    (o_riscv_datapath_timer_rden)       ,
    .i_riscv_mstage_timer_rdata   (i_riscv_timer_datapath_rdata)      ,
    .i_riscv_mstage_memext        (riscv_memext_m)                    ,
    .i_riscv_mstage_addr          (riscv_rddata_me)		                ,
    .i_riscv_mstage_mux2_sel      (i_riscv_datapath_muxcsr_sel)       ,  
    .i_riscv_mux2_in0             (csrwdata_em_csr)                   ,  
    .i_riscv_mux2_in1             (csrout_csr_mw)                     ,   
    .o_riscv_mstage_memload       (riscv_memload_m)                   ,
    .o_riscv_mstage_mux2_out      (muxout_csr)                            
  );

  ////memory write back pipeline flip flops ////
  riscv_ppwire_mw u_riscv_mw_ppwire(
    //------------------------------------------------------------>
   
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
   
    // <---------------------------------------------------
    .i_riscv_mw_wirew_m            (riscv_wirew_m && !gototrap_csr_mw && !returnfromtrap_csr_mw),  
    .i_riscv_mw_en                (i_riscv_datapath_stall_mw)     ,
    .i_riscv_mw_clk               (i_riscv_datapath_clk)          ,
    .i_riscv_mw_rst               (i_riscv_datapath_rst)          ,
    .i_riscv_mw_pcplus4_m         (riscv_pcplus4_m)               ,
    .i_riscv_mw_result_m          (riscv_rddata_me)               ,
    .i_riscv_mw_uimm_m            (riscv_imm_m)                   ,
    .i_riscv_mw_memload_m         (riscv_memload_m)               ,
    .i_riscv_mw_rdaddr_m          (riscv_rdaddr_m)                ,
    .i_riscv_mw_resultsrc_m       (riscv_resultsrc_m)             ,
    .i_riscv_mw_flush             (riscv_wire_flush)               ,  
    .i_riscv_mw_csrout_m          (csrout_mw_trap)                ,  
    .i_riscv_mw_iscsr_m           (iscsr_csr_mw)                  ,  
    .i_riscv_mw_returnfromtrap_m  (returnfromtrap_csr_mw)         ,  
    .i_riscv_mw_gototrap_m        (gototrap_csr_mw)               ,  
    .i_riscv_mw_instret_m         (riscv_instret_m)               ,   
    .i_riscv_mw_rddata_sc_m       (riscv_rddata_sc_m)             ,
    .o_riscv_mw_rddata_sc_wb      (riscv_rddata_sc_wb)            ,
    .o_riscv_mw_instret_wb        (riscv_instret_wb)              ,   
    .o_riscv_mw_pcplus4_wb        (riscv_pcplus4_wb)              ,
    .o_riscv_mw_result_wb         (riscv_result_wb)               ,
    .o_riscv_mw_uimm_wb           (riscv_uimm_wb)                 ,
    .o_riscv_mw_memload_wb        (riscv_memload_wb)              ,
    .o_riscv_mw_rdaddr_wb         (riscv_rdaddr_wb)               ,
    .o_riscv_mw_resultsrc_wb      (riscv_resultsrc_wb)            ,
    .o_riscv_mw_wirew_wb           (riscv_wirew_wb)                 ,
    .o_riscv_mw_csrout_wb         (csrout_csr_mw)                 ,  
    .o_riscv_mw_iscsr_wb          (iscsr_mw_trap)                 ,  
    .o_riscv_mw_gototrap_wb       (gototrap_mw_trap)              ,  
    .o_riscv_mw_returnfromtrap_wb (returnfromtrap_mw_trap)           
    );
    
    ////////////////////////////////
  riscv_wbstage u_riscv_wbstage(
    .i_riscv_wb_resultsrc       (riscv_resultsrc_wb)                , 
    .i_riscv_wb_pcplus4         (riscv_pcplus4_wb)                  ,
    .i_riscv_wb_result          (riscv_result_wb)                   ,
    .i_riscv_wb_memload         (riscv_memload_wb)                  ,
    .i_riscv_wb_uimm            (riscv_uimm_wb)                     ,
    .i_riscv_wb_rddata_sc       (riscv_rddata_sc_wb)                ,
    .i_riscv_wb_csrout          (csrout_csr_mw)                     ,    
    .i_riscv_wb_iscsr           (iscsr_mw_trap)                     , 
    .i_riscv_wb_gototrap        (gototrap_mw_trap)                  , 
    .i_riscv_wb_returnfromtrap  (returnfromtrap_mw_trap)            , 
    .i_riscv_wb_icache_stall    (i_riscv_datapath_icache_stall_wb)  ,
    .o_riscv_wb_rddata          (riscv_rddata_wb)                   ,
    .o_riscv_wb_pcsel           (pcsel_trap_fetchpc)                , 
    .o_riscv_wb_flush           (riscv_wire_flush)            
); 

////////////////////////////////
 riscv_csrfile u_riscv_csrfile (  
  .i_riscv_csr_clk                    (i_riscv_datapath_clk)           ,
  .i_riscv_csr_rst                    (i_riscv_datapath_rst)           ,
  .i_riscv_csr_flush                  (riscv_wire_flush)                ,
  .i_riscv_csr_address                (csraddress_em_csr)              ,
  .i_riscv_csr_op                     (csrop_em_csr)                   ,
  .i_riscv_csr_wdata                  (muxout_csr)                     ,
  .i_riscv_csr_external_int           (i_riscv_core_external_interrupt), 
  .i_riscv_csr_timer_int              (i_riscv_core_timer_interrupt)   ,
  .i_riscv_csr_timer_time             (i_riscv_timer_datapath_time   ) ,
  .i_riscv_csr_ecall_u                (u_em_csr)                       ,
  .i_riscv_csr_ecall_s                (s_em_csr)                       ,
  .i_riscv_csr_ecall_m                (m_em_csr)                       ,
  .i_riscv_csr_illegal_inst           (illegal_inst_em_csr)            , //illegal_inst_em_csr
  .i_riscv_csr_inst_addr_misaligned   (inst_addr_misaligned_em_csr)    , 
  .i_riscv_csr_load_addr_misaligned   (load_addr_misaligned_em_csr)    ,   
  .i_riscv_csr_store_addr_misaligned  (store_addr_misaligned_em_csr)   ,
  .i_riscv_csr_pc                     (riscv_pc_m)                     ,
  .i_riscv_csr_instret                (riscv_instret_wb)               ,
  .i_riscv_csr_addressALU             (riscv_rddata_me)                ,
  .i_riscv_csr_globstall              (i_riscv_datapath_globstall)     ,
  .i_riscv_csr_inst                   (riscv_inst_m)                   ,
  .i_riscv_csr_cinst                  (riscv_cinst_m)                  ,
  .i_riscv_csr_is_compressed          (csr_is_compressed_flag)         ,
  .o_riscv_csr_return_address         (mepc_csr_pctrap)                ,
  .o_riscv_csr_trap_address           (mtvec_csr_pctrap)               , 
  .o_riscv_csr_gotoTrap_cs            (gototrap_csr_mw)                ,
  .o_riscv_csr_returnfromTrap         (returnfromtrap_csr_mw)          ,
  .o_riscv_csr_rdata                  (csrout_mw_trap)                 ,  
  .o_riscv_csr_privlvl                (o_riscv_core_privlvl_csr_cu)    ,
  .o_riscv_csr_tsr                    (o_riscv_datapath_tsr)           ,
  .o_riscv_sepc                       (csr_sepc)                           
 );

 
  ///tracer instantiation///
  // --------------------------------------------------->
 
  riscv_tracer u_riscv_tracer(
    .i_riscv_clk            (i_riscv_datapath_clk)        ,
    .i_riscv_rst            (i_riscv_datapath_rst)        ,
    .i_riscv_trc_inst       (riscv_inst_wb)               ,
    .i_riscv_trc_cinst      (riscv_cinst_wb)              ,
    .i_riscv_trc_rdaddr     (riscv_rdaddr_wb)             ,
    .i_riscv_trc_memaddr    (riscv_memaddr_wb)            ,
    .i_riscv_trc_pc         (riscv_pc_wb)                 ,
    .i_riscv_trc_store      (riscv_rs2data_wb)            ,
    .i_riscv_trc_rddata     (riscv_rddata_wb)             ,
    .o_riscv_trc_inst       (),
    .o_riscv_trc_cinst      (),
    .o_riscv_trc_rdaddr     (),
    .o_riscv_trc_memaddr    (),
    .o_riscv_trc_pc         (),
    .o_riscv_trc_store      (),
    .o_riscv_trc_rddata     ()
  ); 
 
// <---------------------------------------------------

endmodule
