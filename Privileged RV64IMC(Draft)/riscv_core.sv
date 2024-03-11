module riscv_core #(parameter MXLEN=64) (
    input  logic         i_riscv_core_clk              , 
    input  logic         i_riscv_core_rst              ,
    input  logic [31:0]  i_riscv_core_inst             ,
    input  logic [63:0]  i_riscv_core_rdata            ,
    input  logic         i_riscv_core_stall_m          ,
    input  logic         i_riscv_core_timerinterupt    ,
    input  logic         i_riscv_core_externalinterupt ,   
    output logic [63:0]  o_riscv_core_pc               ,
    output logic         o_riscv_core_memw_e           ,
    output logic         o_riscv_core_memr_e           ,
    output logic [1:0]   o_riscv_core_storesrc_m       ,
    //output logic [1:0]   o_riscv_core_loadsrc_m        ,
    output logic [63:0]  o_riscv_core_memodata_addr    ,
    output logic [63:0]  o_riscv_core_storedata_m
  ) ;

  ///////////// Signal From DataPath to CU ////////////////
  logic [6:0] riscv_datapath_opcode_cu    ;
  logic [2:0] riscv_datapath_func3_cu     ;
  logic       riscv_datapath_func7_5_cu   ;
  logic       riscv_datapath_func7_0_cu   ;

  ///////////// Signal From CU to datapath ////////////////
  logic       riscv_cu_regw_datapath      ;   
  logic       riscv_cu_jump_datapath      ;     
  logic       riscv_cu_asel_datapath      ;    
  logic       riscv_cu_bsel_datapath      ;     
  logic       riscv_cu_memw_datapath      ;   
  logic       riscv_cu_memr_datapath      ;    
  logic [1:0] riscv_cu_storesrc_datapath  ; 
  logic [1:0] riscv_cu_resultsrc_datapath ;
  logic [3:0] riscv_cu_bcond_datapath     ;   
  logic [2:0] riscv_cu_memext_datapath    ;  
  logic [5:0] riscv_cu_aluctrl_datapath   ; 
  logic [3:0] riscv_cu_mulctrl_datapath   ;
  logic [3:0] riscv_cu_divctrl_datapath   ;
  logic [1:0] riscv_cu_funcsel_datapath   ;
  logic [2:0] riscv_cu_immsrc_datapath    ;
  logic       riscv_cu_instret_datapath   ;

 /////////////  Signals datapath >< haazard unit /////////////
  logic [1:0] riscv_datapath_fwda_hzrdu         ;        
  logic [1:0] riscv_datapath_fwdb_hzrdu         ;        
  logic       riscv_datapath_pcsrc_e_hzrdu      ;     
  logic       riscv_datapath_icu_valid_e_hzrdu  ;     
  logic       riscv_datapath_mul_en_e_hzrdu     ;   
  logic       riscv_datapath_div_en_e_hzrdu     ; 
  logic [4:0] riscv_datapath_rs1addr_e_hzrdu    ;   
  logic [4:0] riscv_datapath_rs2addr_e_hzrdu    ;  
  logic [4:0] riscv_datapath_rdaddr_e_hzrdu     ;   
  logic [1:0] riscv_datapath_resultsrc_e_hzrdu  ;   
  logic [6:0] riscv_datapath_opcode_hzrdu       ; 
  logic [4:0] riscv_datapath_rdaddr_m_hzrdu     ;   
  logic       riscv_datapath_regw_m_hzrdu       ;      
  
  ///////////// WB Stage Signals /////////////
  logic       riscv_datapath_regw_wb_hzrdu      ; 
  logic [4:0] riscv_datapath_rdaddr_wb_hzrdu    ;  

  ///////////// Hazard Unit Signals /////////////
  logic       riscv_datapath_stall_pc_hzrdu     ; 
  logic       riscv_datapath_flush_fd_hzrdu     ;     
  logic       riscv_datapath_stall_fd_hzrdu     ;
  logic       riscv_datapath_stall_de_hzrdu     ;
  logic       riscv_datapath_stall_em_hzrdu     ;
  logic       riscv_datapath_stall_mw_hzrdu     ;
  logic       riscv_datapath_flush_de_hzrdu     ; 
  logic [4:0] riscv_datapath_rs1addr_d_hzrdu    ;
  logic [4:0] riscv_datapath_rs2addr_d_hzrdu    ;

  ///////////// Trap Signals /////////////
  // From cu to de
  logic         riscv_cu_ecallu_de                            ;
  logic         riscv_cu_ecalls_de                            ;
  logic         riscv_cu_ecallm_de                            ;
  logic         riscv_cu_illgalinst_de                        ;
  logic [2:0]   riscv_cu_csrop_de                             ;
  logic         riscv_cu_iscsr_de                             ;
  logic         riscv_cu_selrsimm_de                          ;
  logic [1:0]   riscv_core_privlvl_csr_cu                     ; 
  logic [4:0]   riscv_datapath_rs1_fd_cu                      ; 
  logic [11:0]  riscv_datapath_constimm12_fd_cu               ;
  logic         riscv_datapath_ecall_u_em_csr                 ;
  logic         riscv_datapath_ecall_s_em_csr                 ;
  logic         riscv_datapath_ecall_m_em_csr                 ;
  logic         riscv_datapath_illegal_inst_em_csr            ;
  logic         riscv_datapath_inst_addr_misaligned_em_csr    ;
  logic         riscv_datapath_load_addr_misaligned_em_csr    ;
  logic         riscv_datapath_store_addr_misaligned_em_csr   ;
  logic [11:0]  riscv_datapath_csraddress_em_csr              ;  
  logic [2:0]   riscv_datapath_csrop_em_csr                   ;
  logic [63:0]  riscv_datapath_addressalu_em_csr              ;
  logic [63:0]  riscv_datapath_csrwdata_em_csr                ;
  logic [4:0]   riscv_hzrdu_rs1addr_m                         ;
                       
  ///////////// CSR Signals /////////////
  logic         muxcsr_sel_hzrd_datapath  ;
  logic         iscsr_w_hzrd_datapath     ;
  logic         iscsr_e_hzrd_datapath     ;
  logic         iscsr_m_hzrd_datapath     ;
  logic         iscsr_d_hzrd_datapath     ; 

  /************************* ************** *************************/
  /************************* Instantiations *************************/
  /************************* ************** *************************/
  riscv_datapath u_top_datapath (
    .i_riscv_datapath_clk               (i_riscv_core_clk)                , 
    .i_riscv_datapath_rst               (i_riscv_core_rst)                ,
  /************************* Fetch Stage Signals *************************/
    .i_riscv_datapath_stallpc           (riscv_datapath_stall_pc_hzrdu)    ,  
    .o_riscv_datapath_pc                (o_riscv_core_pc)                 ,                       
  /************************* Fetch PP Register Signals *************************/
    .i_riscv_datapath_inst              (i_riscv_core_inst)               , 
    .i_riscv_datapath_flush_fd          (riscv_datapath_flush_fd_hzrdu)   , 
    .i_riscv_datapath_stall_fd          (riscv_datapath_stall_fd_hzrdu)   , 
  /************************* Decode Stage Signals *************************/
    .i_riscv_datapath_immsrc            (riscv_cu_immsrc_datapath)        ,     
    .o_riscv_datapath_opcode            (riscv_datapath_opcode_cu)        ,     
    .o_riscv_datapath_func3             (riscv_datapath_func3_cu)         ,        
    .o_riscv_datapath_func7_5           (riscv_datapath_func7_5_cu)       ,  
    .o_riscv_datapath_func7_0           (riscv_datapath_func7_0_cu)       ,   
    .o_riscv_datapath_rs1addr_d         (riscv_datapath_rs1addr_d_hzrdu)  ,
    .o_riscv_datapath_rs2addr_d         (riscv_datapath_rs2addr_d_hzrdu)  , 
  /************************* Decode PP Register Signals *************************/
    .i_riscv_datapath_regw              (riscv_cu_regw_datapath)          ,         
    .i_riscv_datapath_jump              (riscv_cu_jump_datapath)          ,            
    .i_riscv_datapath_asel              (riscv_cu_asel_datapath)          ,       
    .i_riscv_datapath_bsel              (riscv_cu_bsel_datapath)          ,       
    .i_riscv_datapath_memw              (riscv_cu_memw_datapath)          ,        
    .i_riscv_datapath_memr              (riscv_cu_memr_datapath)          ,
    .i_riscv_datapath_storesrc          (riscv_cu_storesrc_datapath)      , 
    .i_riscv_datapath_resultsrc         (riscv_cu_resultsrc_datapath)     ,
    .i_riscv_datapath_bcond             (riscv_cu_bcond_datapath)         ,       
    .i_riscv_datapath_memext            (riscv_cu_memext_datapath)        ,    
    .i_riscv_datapath_aluctrl           (riscv_cu_aluctrl_datapath)       ,    
    .i_riscv_datapath_mulctrl           (riscv_cu_mulctrl_datapath)       , 
    .i_riscv_datapath_divctrl           (riscv_cu_divctrl_datapath)       , 
    .i_riscv_datapath_funcsel           (riscv_cu_funcsel_datapath)       , 
    .i_riscv_datapath_flush_de          (riscv_datapath_flush_de_hzrdu)   , 
    .i_riscv_datapath_stall_de          (riscv_datapath_stall_de_hzrdu)   ,
    .i_riscv_datapath_instret           (riscv_cu_instret_datapath)       ,
  /************************* Execute Stage Signals *************************/
    .i_riscv_datapath_fwda              (riscv_datapath_fwda_hzrdu)       ,        
    .i_riscv_datapath_fwdb              (riscv_datapath_fwdb_hzrdu)       ,       
    .o_riscv_datapath_pcsrc_e           (riscv_datapath_pcsrc_e_hzrdu)    ,     
    .o_riscv_datapath_rs1addr_e         (riscv_datapath_rs1addr_e_hzrdu)  ,   
    .o_riscv_datapath_rs2addr_e         (riscv_datapath_rs2addr_e_hzrdu)  ,   
    .o_riscv_datapath_rdaddr_e          (riscv_datapath_rdaddr_e_hzrdu)   ,  
    .o_riscv_datapath_resultsrc_e       (riscv_datapath_resultsrc_e_hzrdu),  
    .o_riscv_datapath_opcode_m          (riscv_datapath_opcode_hzrdu)     ,
    .o_riscv_datapath_icu_valid_e       (riscv_datapath_icu_valid_e_hzrdu),
    .o_datapath_div_en                  (riscv_datapath_div_en_e_hzrdu)   ,
    .o_datapath_mul_en                  (riscv_datapath_mul_en_e_hzrdu)   ,
  /************************* Memory Stage Signals *************************/
    .i_riscv_datapath_dm_rdata          (i_riscv_core_rdata)              ,    
    .o_riscv_datapath_storesrc_m        (o_riscv_core_storesrc_m)         ,   
    //.o_riscv_datapath_loadsrc_m         (o_riscv_core_loadsrc_m)          ,
    .o_riscv_datapath_memodata_addr     (o_riscv_core_memodata_addr)      ,
    .o_riscv_datapath_storedata_m       (o_riscv_core_storedata_m)        , 
    .o_riscv_datapath_memw_e            (o_riscv_core_memw_e)             ,     
    .o_riscv_datapath_memr_e            (o_riscv_core_memr_e)             ,
    .o_riscv_datapath_rdaddr_m          (riscv_datapath_rdaddr_m_hzrdu)   ,      
    .o_riscv_datapath_regw_m            (riscv_datapath_regw_m_hzrdu)     ,      
    .o_riscv_datapath_rs1addr_m         (riscv_hzrdu_rs1addr_m)           ,
  /************************* WB Stage Signals *************************/
    .o_riscv_datapath_regw_wb           (riscv_datapath_regw_wb_hzrdu)    ,        
    .o_riscv_datapath_rdaddr_wb         (riscv_datapath_rdaddr_wb_hzrdu)  ,   

  /************************* Memory and Writeback PP Register Stage Signals *************************/
    .i_riscv_datapath_stall_em          (riscv_datapath_stall_em_hzrdu)   ,
    .i_riscv_datapath_stall_mw          (riscv_datapath_stall_mw_hzrdu)   ,
    
  /************************* CSR and Traps Signals *************************/
    .i_riscv_datapath_illgalinst_cu_de  (riscv_cu_illgalinst_de)          ,
    .i_riscv_datapath_csrop_cu_de       (riscv_cu_csrop_de)               ,  
    .i_riscv_datapath_iscsr_cu_de       (riscv_cu_iscsr_de)               ,
    .i_riscv_datapath_ecallu_cu_de      (riscv_cu_ecallu_de)              ,
    .i_riscv_datapath_ecalls_cu_de      (riscv_cu_ecalls_de)              ,
    .i_riscv_datapath_ecallm_cu_de      (riscv_cu_ecallm_de)              ,
    .i_riscv_datapath_immreg_cu_de      (riscv_cu_selrsimm_de)            , 
    .i_riscv_core_timerinterupt         (i_riscv_core_timerinterupt)      ,
    .i_riscv_core_externalinterupt      (i_riscv_core_externalinterupt)   ,  
    .i_riscv_datapath_muxcsr_sel        (muxcsr_sel_hzrd_datapath)        ,
    .o_riscv_datapath_rs1_fd_cu         (riscv_datapath_rs1_fd_cu)        ,     
    .o_riscv_datapath_constimm12_fd_cu  (riscv_datapath_constimm12_fd_cu) ,  
    .o_riscv_core_privlvl_csr_cu        (riscv_core_privlvl_csr_cu)       ,
    .o_riscv_datapath_iscsr_w_trap      (iscsr_w_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_m_trap      (iscsr_m_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_e_trap      (iscsr_e_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_d_trap      (iscsr_d_hzrd_datapath)
);

riscv_cu u_top_cu (
/************************* DP -> CU Signals *************************/  
  .i_riscv_cu_opcode        (riscv_datapath_opcode_cu)                    ,
  .i_riscv_cu_funct3        (riscv_datapath_func3_cu)                     , 
  .i_riscv_cu_funct7_5      (riscv_datapath_func7_5_cu)                   ,  
  .i_riscv_cu_funct7_0      (riscv_datapath_func7_0_cu)                   , 
  .i_riscv_cu_privlvl       (riscv_core_privlvl_csr_cu)                   ,    
  .i_riscv_cu_rs1           (riscv_datapath_rs1_fd_cu)                    ,     
  .i_riscv_cu_cosntimm12    (riscv_datapath_constimm12_fd_cu)             ,
 /************************* CU -> DP Signals *************************/   
  .o_riscv_cu_jump          (riscv_cu_jump_datapath)                      , 
  .o_riscv_cu_regw          (riscv_cu_regw_datapath)                      ,
  .o_riscv_cu_asel          (riscv_cu_asel_datapath)                      ,
  .o_riscv_cu_bsel          (riscv_cu_bsel_datapath)                      ,
  .o_riscv_cu_memw          (riscv_cu_memw_datapath)                      ,
  .o_riscv_cu_memr          (riscv_cu_memr_datapath)                      ,  
  .o_riscv_cu_storesrc      (riscv_cu_storesrc_datapath)                  ,                                  
  .o_riscv_cu_resultsrc     (riscv_cu_resultsrc_datapath)                 ,                                 
  .o_riscv_cu_bcond         (riscv_cu_bcond_datapath)                     ,
  .o_riscv_cu_memext        (riscv_cu_memext_datapath)                    ,
  .o_riscv_cu_immsrc        (riscv_cu_immsrc_datapath)                    ,    
  .o_riscv_cu_aluctrl       (riscv_cu_aluctrl_datapath)                   , 
  .o_riscv_cu_funcsel       (riscv_cu_funcsel_datapath)                   ,
  .o_riscv_cu_mulctrl       (riscv_cu_mulctrl_datapath)                   ,
  .o_riscv_cu_divctrl       (riscv_cu_divctrl_datapath)                   ,
  .o_riscv_cu_csrop         (riscv_cu_csrop_de)                           ,   
  .o_riscv_cu_sel_rs_imm    (riscv_cu_selrsimm_de)                        ,   
  .o_riscv_cu_illgalinst    (riscv_cu_illgalinst_de)                      ,    
  .o_riscv_cu_iscsr         (riscv_cu_iscsr_de)                           ,
  .o_riscv_cu_ecall_u       (riscv_cu_ecallu_de)                          ,
  .o_riscv_cu_ecall_s       (riscv_cu_ecalls_de)                          ,
  .o_riscv_cu_ecall_m       (riscv_cu_ecallm_de)                          ,
  .o_riscv_cu_instret       (riscv_cu_instret_datapath)
);

riscv_hazardunit u_top_hzrdu (  
  .i_riscv_hzrdu_rs1addr_d  (riscv_datapath_rs1addr_d_hzrdu)              ,  
  .i_riscv_hzrdu_rs2addr_d  (riscv_datapath_rs2addr_d_hzrdu)              , 
  .i_riscv_hzrdu_rs1addr_e  (riscv_datapath_rs1addr_e_hzrdu)              , 
  .i_riscv_hzrdu_rs2addr_e  (riscv_datapath_rs2addr_e_hzrdu)              , 
  .i_riscv_hzrdu_resultsrc_e(riscv_datapath_resultsrc_e_hzrdu)            ,  
  .i_riscv_hzrdu_rdaddr_e   (riscv_datapath_rdaddr_e_hzrdu)               ,  
  .i_riscv_hzrdu_valid      (riscv_datapath_icu_valid_e_hzrdu)            ,
  .o_riscv_hzrdu_fwda       (riscv_datapath_fwda_hzrdu)                   ,  
  .o_riscv_hzrdu_fwdb       (riscv_datapath_fwdb_hzrdu)                   ,  
  .i_riscv_hzrdu_rdaddr_m   (riscv_datapath_rdaddr_m_hzrdu)               ,
  .i_riscv_hzrdu_regw_m     (riscv_datapath_regw_m_hzrdu)                 ,
  .i_riscv_dcahe_stall_m    (i_riscv_core_stall_m)                        ,   
  .i_riscv_hzrdu_pcsrc      (riscv_datapath_pcsrc_e_hzrdu)                ,   
  .i_riscv_hzrdu_rdaddr_w   (riscv_datapath_rdaddr_wb_hzrdu)              , 
  .i_riscv_hzrdu_regw_w     (riscv_datapath_regw_wb_hzrdu)                ,
  .i_riscv_hzrdu_opcode_m   (riscv_datapath_opcode_hzrdu)                 ,
  .i_riscv_hzrdu_mul_en     (riscv_datapath_mul_en_e_hzrdu)               ,
  .i_riscv_hzrdu_div_en     (riscv_datapath_div_en_e_hzrdu)               ,
  .o_riscv_hzrdu_stallpc    (riscv_datapath_stall_pc_hzrdu)               , 
  .o_riscv_hzrdu_stallfd    (riscv_datapath_stall_fd_hzrdu)               , 
  .o_riscv_hzrdu_flushfd    (riscv_datapath_flush_fd_hzrdu)               ,  
  .o_riscv_hzrdu_flushde    (riscv_datapath_flush_de_hzrdu)               , 
  .o_riscv_hzrdu_stallmw    (riscv_datapath_stall_mw_hzrdu)               ,
  .o_riscv_hzrdu_stallem    (riscv_datapath_stall_em_hzrdu)               ,
  .o_riscv_hzrdu_stallde    (riscv_datapath_stall_de_hzrdu)               ,
  .i_riscv_hzrdu_iscsr_e    (iscsr_e_hzrd_datapath)                       ,   
  .i_riscv_hzrdu_iscsr_d    (iscsr_d_hzrd_datapath)                       ,  
  .i_riscv_hzrdu_iscsr_w    (iscsr_w_hzrd_datapath)                       ,   
  .i_riscv_hzrdu_iscsr_m    (iscsr_m_hzrd_datapath)                       ,
  .o_riscv_hzrdu_passwb     (muxcsr_sel_hzrd_datapath)                    ,   
  .i_riscv_hzrdu_rs1addr_m  (riscv_hzrdu_rs1addr_m)
  );
endmodule