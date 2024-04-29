module riscv_core 
    #(
      parameter MXLEN       = 64                      ,
      parameter DATA_WIDTH  = 128                     ,
      parameter CACHE_SIZE  = 4*(2**10)               ,   //64 * (2**10)
      parameter MEM_SIZE    = 128*(2**20)             ,   //128*(2**20)
      parameter DATAPBLOCK  = 16                      ,
      parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK   ,   //  4096
      parameter ADDR        = $clog2(MEM_SIZE)        ,   //    27 bits
      parameter BYTE_OFF    = $clog2(DATAPBLOCK)      ,   //     4 bits
      parameter INDEX       = $clog2(CACHE_DEPTH)     ,   //    12 bits
      parameter TAG         = ADDR - BYTE_OFF - INDEX ,  //    11 bits
      parameter KERNEL_PC   = 'h80000000              ,
      parameter S_ADDR      = ADDR - BYTE_OFF
    )
    (
      input   wire                   i_riscv_core_clk                , 
      input   wire                   i_riscv_core_rst                ,
      input   wire                   i_riscv_core_external_interrupt ,
      input   wire                   i_riscv_core_mem_ready          ,
      input   wire                   i_riscv_core_imem_ready         ,
      input   wire [DATA_WIDTH-1:0]  i_riscv_core_mem_data_out       ,
      input   wire [DATA_WIDTH-1:0]  i_riscv_core_imem_data_out      , 
      output  reg [DATA_WIDTH-1:0]  o_riscv_core_cache_data_out     ,
      output  reg [S_ADDR-1:0]      o_riscv_core_imem_addr          , 
      output  reg [S_ADDR-1:0]      o_riscv_core_mem_addr           ,
      output  reg                   o_riscv_core_fsm_imem_rden      , 
      output  reg                   o_riscv_core_fsm_mem_wren       ,
      output  reg                   o_riscv_core_fsm_mem_rden       
    ) ;
    

  /************************ Datapath to CU ************************/
    wire         riscv_datapath_stall_m_dm         ;
    wire [63:0]  riscv_datapath_rdata_dm           ;
    wire [6:0]   riscv_datapath_opcode_cu          ;
    wire [2:0]   riscv_datapath_func3_cu           ;
    wire [6:0]   riscv_datapath_func7              ;

  /************************ CU to Datapath ************************/
    wire         riscv_cu_regw_datapath            ;   
    wire         riscv_cu_jump_datapath            ;     
    wire         riscv_cu_asel_datapath            ;    
    wire         riscv_cu_bsel_datapath            ;     
    wire         riscv_cu_memw_datapath            ;   
    wire         riscv_cu_memr_datapath            ;    
    wire [1:0]   riscv_cu_storesrc_datapath        ; 
    wire [2:0]   riscv_cu_resultsrc_datapath       ;
    wire [3:0]   riscv_cu_bcond_datapath           ;   
    wire [2:0]   riscv_cu_memext_datapath          ;  
    wire [5:0]   riscv_cu_aluctrl_datapath         ; 
    wire [3:0]   riscv_cu_mulctrl_datapath         ;
    wire [3:0]   riscv_cu_divctrl_datapath         ;
    wire [1:0]   riscv_cu_funcsel_datapath         ;
    wire [2:0]   riscv_cu_immsrc_datapath          ;
    wire         riscv_cu_instret_datapath         ;
    wire [1:0]   riscv_cu_lr_datapath              ;   
    wire [1:0]   riscv_cu_sc_datapath              ;   
    wire [4:0]   riscv_cu_amo_op_datapath          ; 
    wire         riscv_cu_amo_datapath             ;

  /************************ Datapath & Hazard Unit ************************/
    wire [1:0]   riscv_datapath_fwda_hzrdu         ;        
    wire [1:0]   riscv_datapath_fwdb_hzrdu         ;        
    wire         riscv_datapath_pcsrc_e_hzrdu      ;     
    wire         riscv_datapath_icu_valid_e_hzrdu  ;     
    wire         riscv_datapath_mul_en_e_hzrdu     ;   
    wire         riscv_datapath_div_en_e_hzrdu     ; 
    wire [4:0]   riscv_datapath_rs1addr_e_hzrdu    ;   
    wire [4:0]   riscv_datapath_rs2addr_e_hzrdu    ;  
    wire [4:0]   riscv_datapath_rdaddr_e_hzrdu     ;   
    wire [2:0]   riscv_datapath_resultsrc_e_hzrdu  ;   
    wire [6:0]   riscv_datapath_opcode_hzrdu       ; 
    wire [4:0]   riscv_datapath_rdaddr_m_hzrdu     ;   
    wire         riscv_datapath_regw_m_hzrdu       ;
    wire         riscv_datapath_globstall_hzrdu    ; 

  /************************ Writeback Stage Signals ************************/
    wire         riscv_datapath_regw_wb_hzrdu      ; 
    wire [4:0]   riscv_datapath_rdaddr_wb_hzrdu    ;  

  /************************ Hazard Stage Signals ************************/
    wire         riscv_datapath_stall_pc_hzrdu     ; 
    wire         riscv_datapath_flush_fd_hzrdu     ;     
    wire         riscv_datapath_stall_fd_hzrdu     ;
    wire         riscv_datapath_stall_de_hzrdu     ;
    wire         riscv_datapath_stall_em_hzrdu     ;
    wire         riscv_datapath_stall_mw_hzrdu     ;
    wire         riscv_datapath_flush_de_hzrdu     ; 
    wire [4:0]   riscv_datapath_rs1addr_d_hzrdu    ;
    wire [4:0]   riscv_datapath_rs2addr_d_hzrdu    ;

  /************************ Trap Signals ************************/
    // From cu to de
    wire         riscv_cu_ecallu_de                ;
    wire         riscv_cu_ecalls_de                ;
    wire         riscv_cu_ecallm_de                ;
    wire         riscv_cu_illgalinst_de            ;
    wire [2:0]   riscv_cu_csrop_de                 ;
    wire         riscv_cu_iscsr_de                 ;
    wire         riscv_cu_selrsimm_de              ;
    wire [1:0]   riscv_core_privlvl_csr_cu         ; 
    wire [4:0]   riscv_datapath_rs1_fd_cu          ; 
    wire [11:0]  riscv_datapath_constimm12_fd_cu   ;
    wire [11:0]  riscv_datapath_csraddress_em_csr  ;  
    wire [4:0]   riscv_hzrdu_rs1addr_m             ;

  /************************ Data Cache Signals ************************/
    wire         riscv_datapath_memw_e_dm          ;
    wire         riscv_datapath_memr_e_dm          ;   
    wire [1:0]   riscv_datapath_storesrc_m_dm      ;
    wire         riscv_datapath_amo_dm             ;   
    wire [4:0]   riscv_datapath_amo_op_dm          ;
    wire [63:0]  riscv_datapath_memodata_addr_dm   ;
    wire [63:0]  riscv_datapath_storedata_m_dm     ;

  /************************ Instruction Cache Signals ************************/
    wire [63:0]  riscv_datapath_pc_im              ;                
    wire [31:0]  riscv_im_inst_datapath            ;
    wire         riscv_datapath_stall_m_im         ;
                        
  /************************ CSR Signals ************************/
    wire         muxcsr_sel_hzrd_datapath          ;
    wire         iscsr_w_hzrd_datapath             ;
    wire         iscsr_e_hzrd_datapath             ;
    wire         iscsr_m_hzrd_datapath             ;
    wire         iscsr_d_hzrd_datapath             ;

  /************************ Timer Interrupts ************************/
    wire         riscv_datapath_timer_wren         ; 
    wire         riscv_datapath_timer_rden         ;
    wire [1:0]   riscv_datapath_timer_regsel       ; 
    wire [63:0]  riscv_timer_datapath_rdata        ;   
    wire [63:0]  riscv_timer_datapath_time         ; 

  /************************* ************** *************************/
  /************************* Instantiations *************************/
  /************************* ************** *************************/

  riscv_datapath u_top_datapath (
    .i_riscv_datapath_clk               (i_riscv_core_clk)                , 
    .i_riscv_datapath_rst               (i_riscv_core_rst)                ,
  /************************* Fetch Stage Signals *************************/
    .i_riscv_datapath_stallpc           (riscv_datapath_stall_pc_hzrdu)   ,  
    .o_riscv_datapath_pc                (riscv_datapath_pc_im)            ,                       
  /************************* Fetch PP Register Signals *************************/
    .i_riscv_datapath_inst              (riscv_im_inst_datapath)          , 
    .i_riscv_datapath_flush_fd          (riscv_datapath_flush_fd_hzrdu)   , 
    .i_riscv_datapath_stall_fd          (riscv_datapath_stall_fd_hzrdu)   , 
  /************************* Decode Stage Signals *************************/
    .i_riscv_datapath_immsrc            (riscv_cu_immsrc_datapath)        ,     
    .o_riscv_datapath_opcode            (riscv_datapath_opcode_cu)        ,     
    .o_riscv_datapath_func3             (riscv_datapath_func3_cu)         ,        
    .o_riscv_datapath_func7             (riscv_datapath_func7)            ,
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
    .i_riscv_datapath_lr                (riscv_cu_lr_datapath)            ,
    .i_riscv_datapath_sc                (riscv_cu_sc_datapath)            ,
    .i_riscv_datapath_amo_op            (riscv_cu_amo_op_datapath)        ,
    .i_riscv_datapath_amo               (riscv_cu_amo_datapath)           ,
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
    .o_riscv_datapath_amo               (riscv_datapath_amo_dm)           ,
    .o_riscv_datapath_amo_op            (riscv_datapath_amo_op_dm)        ,
  /************************* Memory Stage Signals *************************/
    .i_riscv_datapath_dm_rdata          (riscv_datapath_rdata_dm)         ,    
    .o_riscv_datapath_storesrc_m        (riscv_datapath_storesrc_m_dm)    ,   
    .o_riscv_datapath_memodata_addr     (riscv_datapath_memodata_addr_dm) ,
    .o_riscv_datapath_storedata_m       (riscv_datapath_storedata_m_dm)   , 
    .o_riscv_datapath_memw_e            (riscv_datapath_memw_e_dm)        ,     
    .o_riscv_datapath_memr_e            (riscv_datapath_memr_e_dm)        ,
    .o_riscv_datapath_rdaddr_m          (riscv_datapath_rdaddr_m_hzrdu)   ,      
    .o_riscv_datapath_regw_m            (riscv_datapath_regw_m_hzrdu)     ,      
    .o_riscv_datapath_rs1addr_m         (riscv_hzrdu_rs1addr_m)           ,
  /************************* WB Stage Signals *************************/
    .i_riscv_datapath_icache_stall_wb   (riscv_datapath_stall_m_im)       ,
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
    .i_riscv_core_timer_interrupt       (riscv_core_timer_interrupt)      ,
    .i_riscv_core_external_interrupt    (i_riscv_core_external_interrupt) ,  
    .i_riscv_datapath_muxcsr_sel        (muxcsr_sel_hzrd_datapath)        ,
    .i_riscv_datapath_globstall         (riscv_datapath_globstall_hzrdu)  ,
    .i_riscv_timer_datapath_rdata       (riscv_timer_datapath_rdata )     ,
    .i_riscv_timer_datapath_time        (riscv_timer_datapath_time  )     ,
    .o_riscv_datapath_rs1_fd_cu         (riscv_datapath_rs1_fd_cu)        ,     
    .o_riscv_datapath_constimm12_fd_cu  (riscv_datapath_constimm12_fd_cu) ,  
    .o_riscv_core_privlvl_csr_cu        (riscv_core_privlvl_csr_cu)       ,
    .o_riscv_datapath_iscsr_w_trap      (iscsr_w_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_m_trap      (iscsr_m_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_e_trap      (iscsr_e_hzrd_datapath)           ,
    .o_riscv_datapath_tsr               (datapath_tsr)                    ,
    .o_riscv_datapath_iscsr_d_trap      (iscsr_d_hzrd_datapath)           ,
    .o_riscv_datapath_timer_wren        (riscv_datapath_timer_wren  )     ,
    .o_riscv_datapath_timer_rden        (riscv_datapath_timer_rden  )     ,
    .o_riscv_datapath_timer_regsel      (riscv_datapath_timer_regsel)     
  );

riscv_cu u_top_cu (
  /************************* DP -> CU Signals *************************/  
    .i_riscv_cu_opcode        (riscv_datapath_opcode_cu)                    ,
    .i_riscv_cu_funct3        (riscv_datapath_func3_cu)                     , 
    .i_riscv_cu_funct7        (riscv_datapath_func7)                        ,
    .i_riscv_cu_privlvl       (riscv_core_privlvl_csr_cu)                   ,    
    .i_riscv_cu_rs1           (riscv_datapath_rs1_fd_cu)                    ,     
    .i_riscv_cu_cosntimm12    (riscv_datapath_constimm12_fd_cu)             ,
    .i_riscv_cu_tsr           (datapath_tsr)                                ,
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
    .o_riscv_cu_instret       (riscv_cu_instret_datapath)                   ,
    .o_riscv_cu_lr            (riscv_cu_lr_datapath)                        ,
    .o_riscv_cu_sc            (riscv_cu_sc_datapath)                        ,
    .o_riscv_cu_amo_op        (riscv_cu_amo_op_datapath)                    ,
    .o_riscv_cu_amo           (riscv_cu_amo_datapath)
    
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
    .i_riscv_dcahe_stall_m    (riscv_datapath_stall_m_dm)                   ,   
    .i_riscv_icahe_stall_m    (riscv_datapath_stall_m_im)                   ,  
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
    .o_riscv_hzrdu_globstall  (riscv_datapath_globstall_hzrdu)              ,
    .i_riscv_hzrdu_iscsr_e    (iscsr_e_hzrd_datapath)                       ,   
    .i_riscv_hzrdu_iscsr_d    (iscsr_d_hzrd_datapath)                       ,  
    .i_riscv_hzrdu_iscsr_w    (iscsr_w_hzrd_datapath)                       ,   
    .i_riscv_hzrdu_iscsr_m    (iscsr_m_hzrd_datapath)                       ,
    .o_riscv_hzrdu_passwb     (muxcsr_sel_hzrd_datapath)                    ,   
    .i_riscv_hzrdu_rs1addr_m  (riscv_hzrdu_rs1addr_m)
  );

  riscv_data_cache #(
    .DATA_WIDTH   (DATA_WIDTH)  ,
    .CACHE_SIZE   (CACHE_SIZE)  ,
    .MEM_SIZE     (MEM_SIZE)    ,
    .DATAPBLOCK   (DATAPBLOCK)  ,
    .CACHE_DEPTH  (CACHE_DEPTH) ,
    .ADDR         (ADDR)        ,
    .BYTE_OFF     (BYTE_OFF)    ,
    .INDEX        (INDEX)       ,
    .TAG          (TAG)         ,
    .S_ADDR       (S_ADDR)
  ) u_data_cache (
    .i_riscv_dcache_clk             (i_riscv_core_clk)                            ,
    .i_riscv_dcache_rst             (i_riscv_core_rst)                            ,
    .i_riscv_dcache_globstall       (riscv_datapath_globstall_hzrdu)              ,      
    .i_riscv_dcache_cpu_wren        (riscv_datapath_memw_e_dm)                    ,
    .i_riscv_dcache_cpu_rden        (riscv_datapath_memr_e_dm)                    ,
    .i_riscv_dcache_store_src       (riscv_datapath_storesrc_m_dm)                ,
    .i_riscv_dcache_amo             (riscv_datapath_amo_dm)                       ,
    .i_riscv_dcache_amo_op          (riscv_datapath_amo_op_dm)                    ,
    .i_riscv_dcache_phys_addr       (riscv_datapath_memodata_addr_dm[ADDR-1:0])   ,
    .i_riscv_dcache_cpu_data_in     (riscv_datapath_storedata_m_dm)               ,
    .i_riscv_dcache_mem_ready       (i_riscv_core_mem_ready      )                ,
    .i_riscv_dcache_mem_data_out    (i_riscv_core_mem_data_out   )                ,
    .o_riscv_dcache_fsm_mem_wren    (o_riscv_core_fsm_mem_wren   )                ,
    .o_riscv_dcache_fsm_mem_rden    (o_riscv_core_fsm_mem_rden   )                ,
    .o_riscv_dcache_mem_addr        (o_riscv_core_mem_addr       )                ,
    .o_riscv_dcache_cache_data_out  (o_riscv_core_cache_data_out )                ,
    .o_riscv_dcache_cpu_data_out    (riscv_datapath_rdata_dm)                     ,
    .o_riscv_dcache_cpu_stall       (riscv_datapath_stall_m_dm)        
  );

  riscv_instructions_cache #(
    .DATA_WIDTH   (DATA_WIDTH)  ,
    .CACHE_SIZE   (CACHE_SIZE)  ,
    .MEM_SIZE     (MEM_SIZE)    ,
    .DATAPBLOCK   (DATAPBLOCK)  ,
    .CACHE_DEPTH  (CACHE_DEPTH) ,
    .ADDR         (ADDR)        ,
    .BYTE_OFF     (BYTE_OFF)    ,
    .INDEX        (INDEX)       ,
    .TAG          (TAG)         ,
    .S_ADDR       (S_ADDR)
  ) u_inst_cache(
    .i_riscv_icache_clk             (i_riscv_core_clk)                  ,
    .i_riscv_icache_rst             (i_riscv_core_rst)                  ,
    .i_riscv_icache_phys_addr       ((riscv_datapath_pc_im-KERNEL_PC))  ,
    .i_riscv_icache_mem_ready       (i_riscv_core_imem_ready     )      ,
    .i_riscv_icache_mem_data_out    (i_riscv_core_imem_data_out  )      ,
    .o_riscv_icache_mem_addr        (o_riscv_core_imem_addr      )      ,
    .o_riscv_icache_fsm_mem_rden    (o_riscv_core_fsm_imem_rden  )      ,
    .o_riscv_icache_cpu_instr_out   (riscv_im_inst_datapath     )       ,  
    .o_riscv_icache_cpu_stall       (riscv_datapath_stall_m_im  )  
  );

  riscv_timer_irq  u_riscv_timer_irq (
    .i_riscv_timer_clk      (i_riscv_core_clk               ),
    .i_riscv_timer_rst      (i_riscv_core_rst               ),
    .i_riscv_timer_wren     (riscv_datapath_timer_wren      ),
    .i_riscv_timer_rden     (riscv_datapath_timer_rden      ),
    .i_riscv_timer_regsel   (riscv_datapath_timer_regsel    ),
    .i_riscv_timer_wdata    (riscv_datapath_storedata_m_dm  ),
    .o_riscv_timer_rdata    (riscv_timer_datapath_rdata     ),
    .o_riscv_timer_time     (riscv_timer_datapath_time      ),
    .o_riscv_timer_irq      (riscv_core_timer_interrupt     )
  );

endmodule