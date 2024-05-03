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
      input   logic                   i_riscv_core_clk                , 
      input   logic                   i_riscv_core_rst                ,
      input   logic                   i_riscv_core_external_interrupt ,
      input   logic                   i_riscv_core_mem_ready          ,
      input   logic                   i_riscv_core_imem_ready         ,
      input   logic [DATA_WIDTH-1:0]  i_riscv_core_mem_data_out       ,
      input   logic [DATA_WIDTH-1:0]  i_riscv_core_imem_data_out      , 
      output  logic [DATA_WIDTH-1:0]  o_riscv_core_cache_data_out     ,
      output  logic [S_ADDR-1:0]      o_riscv_core_imem_addr          , 
      output  logic [S_ADDR-1:0]      o_riscv_core_mem_addr           ,
      output  logic                   o_riscv_core_fsm_imem_rden      , 
      output  logic                   o_riscv_core_fsm_mem_wren       ,
      output  logic                   o_riscv_core_fsm_mem_rden       
    ) ;
    

  /************************ Datapath to CU ************************/
    logic         riscv_datapath_stall_m_dm         ;
    logic [63:0]  riscv_datapath_rdata_dm           ;
    logic [6:0]   riscv_datapath_opcode_cu          ;
    logic [2:0]   riscv_datapath_func3_cu           ;
    logic [6:0]   riscv_datapath_func7              ;

  /************************ CU to Datapath ************************/
    logic         riscv_cu_regw_datapath            ;   
    logic         riscv_cu_jump_datapath            ;     
    logic         riscv_cu_asel_datapath            ;    
    logic         riscv_cu_bsel_datapath            ;     
    logic         riscv_cu_memw_datapath            ;   
    logic         riscv_cu_memr_datapath            ;    
    logic [1:0]   riscv_cu_storesrc_datapath        ; 
    logic [2:0]   riscv_cu_resultsrc_datapath       ;
    logic [3:0]   riscv_cu_bcond_datapath           ;   
    logic [2:0]   riscv_cu_memext_datapath          ;  
    logic [5:0]   riscv_cu_aluctrl_datapath         ; 
    logic [3:0]   riscv_cu_mulctrl_datapath         ;
    logic [3:0]   riscv_cu_divctrl_datapath         ;
    logic [1:0]   riscv_cu_funcsel_datapath         ;
    logic [2:0]   riscv_cu_immsrc_datapath          ;
    logic         riscv_cu_instret_datapath         ;
    logic [1:0]   riscv_cu_lr_datapath              ;   
    logic [1:0]   riscv_cu_sc_datapath              ;   
    logic [4:0]   riscv_cu_amo_op_datapath          ; 
    logic         riscv_cu_amo_datapath             ;

  /************************ Datapath & Hazard Unit ************************/
    logic [1:0]   riscv_datapath_fwda_hzrdu         ;        
    logic [1:0]   riscv_datapath_fwdb_hzrdu         ;        
    logic         riscv_datapath_pcsrc_e_hzrdu      ;     
    logic         riscv_datapath_icu_valid_e_hzrdu  ;     
    logic         riscv_datapath_mul_en_e_hzrdu     ;   
    logic         riscv_datapath_div_en_e_hzrdu     ; 
    logic [4:0]   riscv_datapath_rs1addr_e_hzrdu    ;   
    logic [4:0]   riscv_datapath_rs2addr_e_hzrdu    ;  
    logic [4:0]   riscv_datapath_rdaddr_e_hzrdu     ;   
    logic [2:0]   riscv_datapath_resultsrc_e_hzrdu  ;   
    logic [6:0]   riscv_datapath_opcode_hzrdu       ; 
    logic [4:0]   riscv_datapath_rdaddr_m_hzrdu     ;   
    logic         riscv_datapath_regw_m_hzrdu       ;
    logic         riscv_datapath_globstall_hzrdu    ; 
    
  /************************ Writeback Stage Signals ************************/
    logic         riscv_datapath_regw_wb_hzrdu      ; 
    logic [4:0]   riscv_datapath_rdaddr_wb_hzrdu    ;  

  /************************ Hazard Stage Signals ************************/
    logic         riscv_datapath_stall_pc_hzrdu     ; 
    logic         riscv_datapath_flush_fd_hzrdu     ;     
    logic         riscv_datapath_stall_fd_hzrdu     ;
    logic         riscv_datapath_stall_de_hzrdu     ;
    logic         riscv_datapath_stall_em_hzrdu     ;
    logic         riscv_datapath_stall_mw_hzrdu     ;
    logic         riscv_datapath_flush_de_hzrdu     ; 
    logic [4:0]   riscv_datapath_rs1addr_d_hzrdu    ;
    logic [4:0]   riscv_datapath_rs2addr_d_hzrdu    ;

  /************************ Trap Signals ************************/
    // From cu to de
    logic         riscv_cu_ecallu_de                ;
    logic         riscv_cu_ecalls_de                ;
    logic         riscv_cu_ecallm_de                ;
    logic         riscv_cu_illgalinst_de            ;
    logic [2:0]   riscv_cu_csrop_de                 ;
    logic         riscv_cu_iscsr_de                 ;
    logic         riscv_cu_selrsimm_de              ;
    logic [1:0]   riscv_core_privlvl_csr_cu         ; 
    logic [4:0]   riscv_datapath_rs1_fd_cu          ; 
    logic [11:0]  riscv_datapath_constimm12_fd_cu   ;
    logic [11:0]  riscv_datapath_csraddress_em_csr  ;  
    logic [4:0]   riscv_hzrdu_rs1addr_m             ;

  /************************ Data Cache Signals ************************/
    logic         riscv_datapath_memw_e_dm          ;
    logic         riscv_datapath_memr_e_dm          ;   
    logic [1:0]   riscv_datapath_storesrc_m_dm      ;
    logic         riscv_datapath_amo_dm             ;   
    logic [4:0]   riscv_datapath_amo_op_dm          ;
    logic [63:0]  riscv_datapath_memodata_addr_dm   ;
    logic [63:0]  riscv_datapath_storedata_m_dm     ;

  /************************ Instruction Cache Signals ************************/
    logic [63:0]  riscv_datapath_pc_im              ;                
    logic [31:0]  riscv_im_inst_datapath            ;
    logic         riscv_datapath_stall_m_im         ;
                        
  /************************ CSR Signals ************************/
    logic         muxcsr_sel_hzrd_datapath          ;
    logic         iscsr_w_hzrd_datapath             ;
    logic         iscsr_e_hzrd_datapath             ;
    logic         iscsr_m_hzrd_datapath             ;
    logic         iscsr_d_hzrd_datapath             ;

  /************************ Timer Interrupts ************************/
    logic         riscv_datapath_timer_wren         ; 
    logic         riscv_datapath_timer_rden         ;
    logic [1:0]   riscv_datapath_timer_regsel       ; 
    logic [63:0]  riscv_timer_datapath_rdata        ;   
    logic [63:0]  riscv_timer_datapath_time         ; 

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
    .o_riscv_datapath_rs1addr_d         (riscv_datapath_rs1addr_d_hzrdu)  ,
    .o_riscv_datapath_rs2addr_d         (riscv_datapath_rs2addr_d_hzrdu)  , 
  /************************* Decode PP Register Signals *************************/
    .i_riscv_datapath_flush_de          (riscv_datapath_flush_de_hzrdu)   , 
    .i_riscv_datapath_stall_de          (riscv_datapath_stall_de_hzrdu)   ,
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
    .i_riscv_core_timer_interrupt       (riscv_core_timer_interrupt)      ,
    .i_riscv_core_external_interrupt    (i_riscv_core_external_interrupt) ,  
    .i_riscv_datapath_muxcsr_sel        (muxcsr_sel_hzrd_datapath)        ,
    .i_riscv_datapath_globstall         (riscv_datapath_globstall_hzrdu)  ,
    .i_riscv_timer_datapath_rdata       (riscv_timer_datapath_rdata )     ,
    .i_riscv_timer_datapath_time        (riscv_timer_datapath_time  )     ,
    .o_riscv_datapath_iscsr_w_trap      (iscsr_w_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_m_trap      (iscsr_m_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_e_trap      (iscsr_e_hzrd_datapath)           ,
    .o_riscv_datapath_iscsr_d_trap      (iscsr_d_hzrd_datapath)           ,
    .o_riscv_datapath_timer_wren        (riscv_datapath_timer_wren  )     ,
    .o_riscv_datapath_timer_rden        (riscv_datapath_timer_rden  )     ,
    .o_riscv_datapath_timer_regsel      (riscv_datapath_timer_regsel)     
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