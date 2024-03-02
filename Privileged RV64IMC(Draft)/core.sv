module riscv_core #(parameter MXLEN=64 ,parameter width = 64)
  (
     input  logic [31:0]  i_riscv_core_inst,
     input  logic         i_riscv_core_clk , 
     input  logic         i_riscv_core_rst,
     input  logic [63:0]  i_riscv_core_rdata ,
     input  logic         i_riscv_core_stall_m,
     output logic [63:0]  o_riscv_core_pc,
     output logic         o_riscv_core_memw_e,
     output logic         o_riscv_core_memr_e,
     output logic [1:0]   o_riscv_core_storesrc_m,
     output logic [63:0]  o_riscv_core_memodata_addr,
     output logic [63:0]  o_riscv_core_storedata_m,

     //trap 
     //input from top system 
     input logic          i_riscv_core_timerinterupt  ,
     input logic          i_riscv_core_externalinterupt
  ) ;



/////////////Signal From DataPath to CU ////////////////
logic [6:0] riscv_datapath_opcode_cu  ;
logic [2:0] riscv_datapath_func3_cu   ;
logic       riscv_datapath_func7_5_cu       ;
logic       riscv_datapath_func7_0_cu ;

/////////////Signal From CU to datapath ////////////////
logic       riscv_cu_regw_datapath;    /// from control unit
logic       riscv_cu_jump_datapath;     /// from control unit      
logic       riscv_cu_asel_datapath;     /// from control unit
logic       riscv_cu_bsel_datapath;     /// from control unit
logic       riscv_cu_memw_datapath;     /// from control unit
logic       riscv_cu_memr_datapath;     /// from control unit
logic [1:0] riscv_cu_storesrc_datapath; /// from control unit [1:0]
logic [1:0] riscv_cu_resultsrc_datapath;/// from control unit  [1:0] 
logic [3:0] riscv_cu_bcond_datapath;    /// from control unit [3:0] 
logic [2:0] riscv_cu_memext_datapath;   /// from control unit [2:0]
logic [5:0] riscv_cu_aluctrl_datapath;  /// from control unit [4:0]
logic [3:0] riscv_cu_mulctrl_datapath;
logic [3:0] riscv_cu_divctrl_datapath;
logic [1:0] riscv_cu_funcsel_datapath;
logic [2:0] riscv_cu_immsrc_datapath ; /// from control unit [2:0]
  

 /////////////////////Signals datapath >< haazard unit /////////////
  logic [1:0] riscv_datapath_fwda_hzrdu;        /// from hazard unit  [1:0] 
  logic [1:0] riscv_datapath_fwdb_hzrdu;        /// from hazard unit  [1:0]
  logic       riscv_datapath_pcsrc_e_hzrdu;     /// to hazard unit  
  logic       riscv_datapath_icu_valid_e_hzrdu;     /// to hazard unit  
  logic       riscv_datapath_mul_en_e_hzrdu;     /// to hazard unit  
  logic       riscv_datapath_div_en_e_hzrdu; 
  logic [4:0] riscv_datapath_rs1addr_e_hzrdu;   /// to hazard unit  [4:0] 
  logic [4:0] riscv_datapath_rs2addr_e_hzrdu;   /// to hazard unit [4:0]
  logic [4:0] riscv_datapath_rdaddr_e_hzrdu;   /// to hazard unit [4:0]
  logic [1:0] riscv_datapath_resultsrc_e_hzrdu;  /// to hazard unit [1:0] 
  logic [6:0] riscv_datapath_opcode_hzrdu; 
 // logic       riscv_datapath_memw_m_hzrdu;       /// to dm &&&&&&  to hazard unit  //mem
  logic [4:0] riscv_datapath_rdaddr_m_hzrdu;      /// to hazard unit [4:0]
  logic       riscv_datapath_regw_m_hzrdu;       /// to hazard unit
  
  /////////////////////write back ///////////
  logic       riscv_datapath_regw_wb_hzrdu;     /// to hazard unit   
  logic [4:0] riscv_datapath_rdaddr_wb_hzrdu ;   /// to hazard unit [4:0] 

//Different locations to/from hzrd unit
  logic       riscv_datapath_stallpc_hzrdu;  /// from hazard unit
  logic       riscv_datapath_flush_fd_hzrdu; /// from hazard unit
  logic       riscv_datapath_stall_fd_hzrdu; /// from hazard unit
  logic       riscv_datapath_stall_de_hzrdu;
  logic       riscv_datapath_stall_em_hzrdu;
  logic       riscv_datapath_stall_mw_hzrdu;
  logic       riscv_datapath_flush_de_hzrdu; /// from hazard unit
  

  logic [4:0] riscv_datapath_rs1addr_d_hzrdu;/// to hazard unit [4:0]
  logic [4:0] riscv_datapath_rs2addr_d_hzrdu;/// to hazard unit [4:0]  



  //trap  
  // From cu to de
  logic riscv_cu_ecallu_de       ;
  logic riscv_cu_ecalls_de        ;
  logic riscv_cu_ecallm_de        ;
  logic riscv_cu_illgalinst_de     ;
  logic [2:0] riscv_cu_csrop_de   ;
  logic riscv_cu_iscsr_de       ;
  logic riscv_cu_selrsimm_de ;

// From csr to cu
  logic [1:0] riscv_core_privlvl_csr_cu ;
//From fd to cu
   logic [4:0] riscv_datapath_rs1_fd_cu  ;
 logic [11:0] riscv_datapath_constimm12_fd_cu ;


    //traps corrected
  logic             riscv_datapath_ecall_u_em_csr ;
  logic             riscv_datapath_ecall_s_em_csr ;
  logic             riscv_datapath_ecall_m_em_csr ;
  logic             riscv_datapath_illegal_inst_em_csr ;
  logic             riscv_datapath_inst_addr_misaligned_em_csr  ;
  logic             riscv_datapath_load_addr_misaligned_em_csr  ;
   logic             riscv_datapath_store_addr_misaligned_em_csr  ;
  logic [11:0]      riscv_datapath_csraddress_em_csr ;  
  logic [2:0]       riscv_datapath_csrop_em_csr  ;

  logic [width-1:0] riscv_datapath_addressalu_em_csr  ;
  logic [width-1:0] riscv_datapath_csrwdata_em_csr   ;
  //logic             riscv_datapath_iscsr_em_csr   ;
  


 logic muxcsr_sel_hzrd_datapath ;
logic iscsr_w_hzrd_datapath ;
logic iscsr_e_hzrd_datapath ;
logic iscsr_m_hzrd_datapath ;
logic iscsr_d_hzrd_datapath ;


riscv_datapath u_top_datapath(               //#(parameter width=64) (
    .i_riscv_datapath_clk(i_riscv_core_clk),
    .i_riscv_datapath_rst(i_riscv_core_rst),
  
  ///////////////////fetch//////////////////
  .i_riscv_datapath_stallpc(riscv_datapath_stallpc_hzrdu),  /// from hazard unit
  .o_riscv_datapath_pc(o_riscv_core_pc) ,                                    /// to im   [width-1:0]
  ///////////////////fd_pff//////////////////
  .i_riscv_datapath_inst(i_riscv_core_inst),                                 /// from im  [31:0] -now to fetch first
  .i_riscv_datapath_flush_fd(riscv_datapath_flush_fd_hzrdu), /// from hazard unit
  .i_riscv_datapath_stall_fd(riscv_datapath_stall_fd_hzrdu), /// from hazard unit
  /////////////////////decode///////////// 
  .i_riscv_datapath_immsrc(riscv_cu_immsrc_datapath),       /// from control   [2:0]
  .o_riscv_datapath_opcode(riscv_datapath_opcode_cu),      /// to control unit [6:0]
  .o_riscv_datapath_func3(riscv_datapath_func3_cu),        /// to control unit [2:0] 
  .o_riscv_datapath_func7_5(riscv_datapath_func7_5_cu),    /// to control unit
  .o_riscv_datapath_func7_0(riscv_datapath_func7_0_cu),   
  .o_riscv_datapath_rs1addr_d(riscv_datapath_rs1addr_d_hzrdu),/// to hazard unit [4:0]
  .o_riscv_datapath_rs2addr_d(riscv_datapath_rs2addr_d_hzrdu),/// to hazard unit [4:0]  
  ///////////////////de_pff//////////////////
  .i_riscv_datapath_regw(riscv_cu_regw_datapath),         /// from control unit
  .i_riscv_datapath_jump(riscv_cu_jump_datapath),         /// from control unit      
  .i_riscv_datapath_asel(riscv_cu_asel_datapath),        /// from control unit
  .i_riscv_datapath_bsel(riscv_cu_bsel_datapath),        /// from control unit
  .i_riscv_datapath_memw(riscv_cu_memw_datapath),         /// from control unit
  .i_riscv_datapath_memr(riscv_cu_memr_datapath),
  .i_riscv_datapath_storesrc(riscv_cu_storesrc_datapath), /// from control unit [1:0]
  .i_riscv_datapath_resultsrc(riscv_cu_resultsrc_datapath),/// from control unit  [1:0] 
  .i_riscv_datapath_bcond(riscv_cu_bcond_datapath),       /// from control unit [3:0] 
  .i_riscv_datapath_memext(riscv_cu_memext_datapath),     /// from control unit [2:0]
  .i_riscv_datapath_aluctrl(riscv_cu_aluctrl_datapath),    /// from control unit [4:0]
  .i_riscv_datapath_mulctrl(riscv_cu_mulctrl_datapath), 
  .i_riscv_datapath_divctrl(riscv_cu_divctrl_datapath), 
  .i_riscv_datapath_funcsel(riscv_cu_funcsel_datapath), 
  .i_riscv_datapath_flush_de(riscv_datapath_flush_de_hzrdu), /// from hazard unit
   .i_riscv_datapath_stall_de(riscv_datapath_stall_de_hzrdu),
  /////////////////////execute/////////////
  .i_riscv_datapath_fwda(riscv_datapath_fwda_hzrdu),        /// from hazard unit  [1:0] 
  .i_riscv_datapath_fwdb(riscv_datapath_fwdb_hzrdu),        /// from hazard unit  [1:0]
  .o_riscv_datapath_pcsrc_e(riscv_datapath_pcsrc_e_hzrdu),     /// to hazard unit   
  .o_riscv_datapath_rs1addr_e(riscv_datapath_rs1addr_e_hzrdu),   /// to hazard unit  [4:0] 
  .o_riscv_datapath_rs2addr_e(riscv_datapath_rs2addr_e_hzrdu),   /// to hazard unit [4:0]
  .o_riscv_datapath_rdaddr_e(riscv_datapath_rdaddr_e_hzrdu),   /// to hazard unit [4:0]
  .o_riscv_datapath_resultsrc_e(riscv_datapath_resultsrc_e_hzrdu),  /// to hazard unit [1:0]  
  .o_riscv_datapath_opcode_m(riscv_datapath_opcode_hzrdu),
  .o_riscv_datapath_icu_valid_e(riscv_datapath_icu_valid_e_hzrdu),
  .o_datapath_div_en(riscv_datapath_div_en_e_hzrdu),
  .o_datapath_mul_en(riscv_datapath_mul_en_e_hzrdu),
  /////////////////////memory/////////////
  .i_riscv_datapath_dm_rdata(i_riscv_core_rdata),      /// from dm [width-1:0]
  .o_riscv_datapath_storesrc_m(o_riscv_core_storesrc_m),   /// to dm [1:0]
  .o_riscv_datapath_memodata_addr(o_riscv_core_memodata_addr),/// to dm [width-1:0]
  .o_riscv_datapath_storedata_m(o_riscv_core_storedata_m),  /// to dm [width-1:0]
  .o_riscv_datapath_memw_e(o_riscv_core_memw_e),       /// to dm &&&&&&  to hazard unit
  .o_riscv_datapath_memr_e(o_riscv_core_memr_e),
  .o_riscv_datapath_rdaddr_m(riscv_datapath_rdaddr_m_hzrdu),      /// to hazard unit [4:0]
  .o_riscv_datapath_regw_m(riscv_datapath_regw_m_hzrdu),       /// to hazard unit
  
  /////////////////////write back ///////////
  .o_riscv_datapath_regw_wb(riscv_datapath_regw_wb_hzrdu),     /// to hazard unit   
  .o_riscv_datapath_rdaddr_wb(riscv_datapath_rdaddr_wb_hzrdu) ,   /// to hazard unit [4:0] 
  
  
   .i_riscv_datapath_stall_em(riscv_datapath_stall_em_hzrdu),
   .i_riscv_datapath_stall_mw(riscv_datapath_stall_mw_hzrdu) ,


  /*  //traps corrected
  .o_riscv_datapath_ecall_u_em_csr(riscv_datapath_ecall_u_em_csr) ,
  .o_riscv_datapath_ecall_s_em_csr(riscv_datapath_ecall_s_em_csr) ,
  .o_riscv_datapath_ecall_m_em_csr(riscv_datapath_ecall_m_em_csr) ,
 
  .o_riscv_datapath_csraddress_em_csr(riscv_datapath_csraddress_em_csr)  ,       //[11:0] 
  .o_riscv_datapath_illegal_inst_em_csr(riscv_datapath_illegal_inst_em_csr) ,
  //.o_riscv_datapath_iscsr_em_csr(riscv_datapath_iscsr_em_csr)   ,
  .o_riscv_datapath_csrop_em_csr(riscv_datapath_csrop_em_csr)  ,  //[2:0]

  .o_riscv_datapath_addressalu_em_csr(riscv_datapath_addressalu_em_csr)  , //[width-1:0]
  .o_riscv_datapath_inst_addr_misaligned_em_csr(riscv_datapath_inst_addr_misaligned_em_csr)  ,
  .o_riscv_datapath_load_addr_misaligned_em_csr(riscv_datapath_load_addr_misaligned_em_csr)  ,
  .o_riscv_datapath_store_addr_misaligned_em_csr(riscv_datapath_store_addr_misaligned_em_csr)  ,
  .o_riscv_datapath_csrwdata_em_csr(riscv_datapath_csrwdata_em_csr)   // [width-1:0] 

  .o_riscv_datapath_rs1_fd_cu(riscv_datapath_rs1_fd_cu) ,    //[4:0] 
  .o_riscv_datapath_constimm12_fd_cu(riscv_datapath_constimm12_fd_cu) ,  //[11:0] */




  //trap  
  // From cu to de
  .i_riscv_datapath_illgalinst_cu_de(riscv_cu_illgalinst_de)     ,
 .i_riscv_datapath_csrop_cu_de(riscv_cu_csrop_de)    ,   //[2:0]
  .i_riscv_datapath_iscsr_cu_de(riscv_cu_iscsr_de)        ,
 .i_riscv_datapath_ecallu_cu_de(riscv_cu_ecallu_de)        ,
  .i_riscv_datapath_ecalls_cu_de(riscv_cu_ecalls_de)         ,
  .i_riscv_datapath_ecallm_cu_de(riscv_cu_ecallm_de)         ,
  .i_riscv_datapath_immreg_cu_de(riscv_cu_selrsimm_de)   , 
    .i_riscv_core_timerinterupt(i_riscv_core_timerinterupt)  ,
    .i_riscv_core_externalinterupt(i_riscv_core_externalinterupt)   ,  
   .o_riscv_datapath_rs1_fd_cu(riscv_datapath_rs1_fd_cu) ,    //[4:0] 
  .o_riscv_datapath_constimm12_fd_cu(riscv_datapath_constimm12_fd_cu) ,  //[11:0] 
  .o_riscv_core_privlvl_csr_cu(riscv_core_privlvl_csr_cu) ,

   .i_riscv_datapath_muxcsr_sel(muxcsr_sel_hzrd_datapath) ,

   .o_riscv_datapath_iscsr_w_trap(iscsr_w_hzrd_datapath) ,
    .o_riscv_datapath_iscsr_m_trap(iscsr_m_hzrd_datapath),
   .o_riscv_datapath_iscsr_e_trap(iscsr_e_hzrd_datapath),
   .o_riscv_datapath_iscsr_d_trap(iscsr_d_hzrd_datapath)

);




riscv_cu u_top_cu (

  /////////////Signal From DataPath to CU ////////////////
  .i_riscv_cu_opcode(riscv_datapath_opcode_cu), //7-bit  opcode[6:0]             [6:0] 
  .i_riscv_cu_funct3(riscv_datapath_func3_cu), //3-bit  func_3[14:12]          [2:0]
  .i_riscv_cu_funct7_5(riscv_datapath_func7_5_cu),//1-bit  func_7[30]
  .i_riscv_cu_funct7_0(riscv_datapath_func7_0_cu), //1-bit input func_7[25]
  // Siganls from cu to datapath
  .o_riscv_cu_jump(riscv_cu_jump_datapath), 
  .o_riscv_cu_regw(riscv_cu_regw_datapath),
  .o_riscv_cu_asel(riscv_cu_asel_datapath),
  .o_riscv_cu_bsel(riscv_cu_bsel_datapath),
  .o_riscv_cu_memw(riscv_cu_memw_datapath),
  .o_riscv_cu_memr(riscv_cu_memr_datapath),  
  .o_riscv_cu_storesrc(riscv_cu_storesrc_datapath),                                   //  [1:0]
  .o_riscv_cu_resultsrc(riscv_cu_resultsrc_datapath),                                     // [1:0] 
  .o_riscv_cu_bcond(riscv_cu_bcond_datapath),//msb for branch enable  [3:0]
  .o_riscv_cu_memext(riscv_cu_memext_datapath), //[2:0]

  .o_riscv_cu_immsrc(riscv_cu_immsrc_datapath),  //[2:0] 
  .o_riscv_cu_aluctrl(riscv_cu_aluctrl_datapath), //[4:0]
  .o_riscv_cu_funcsel(riscv_cu_funcsel_datapath),
  .o_riscv_cu_mulctrl(riscv_cu_mulctrl_datapath),
  .o_riscv_cu_divctrl(riscv_cu_divctrl_datapath) ,

  
  //i_riscv_cu_tsr ,          //come From CSR
  //o_riscv_cu_mtval ,
  //.o_riscv_cu_ex_cause() ,  //[3:0] we encode for interupt , exception from value 0 >15 so need 4 bits
  //.o_riscv_cu_int_cause() ,  //[3:0]

  .i_riscv_cu_privlvl(riscv_core_privlvl_csr_cu) ,     //[1:0] come From CSR 
  .o_riscv_cu_csrop(riscv_cu_csrop_de) ,     //[2:0] To CSR  //[?] 
  .o_riscv_cu_sel_rs_imm(riscv_cu_selrsimm_de) ,   // to d/e to have two signals to mux stable
  //check the below 2 signals
  //.i_riscv_cu_is_illegal() ,    //check it comes from csr
  .o_riscv_cu_illgalinst(riscv_cu_illgalinst_de) ,    //[?] 
  .i_riscv_cu_rs1(riscv_datapath_rs1_fd_cu) ,      // [4:0] come From F/D register
  .i_riscv_cu_cosntimm12(riscv_datapath_constimm12_fd_cu)  ,// [11:0] 12-bit input cosntimm12[31:20] ////come From F/D register
  .o_riscv_cu_iscsr(riscv_cu_iscsr_de)     ,
  //.o_riscv_cu_mret()      ,
  .o_riscv_cu_ecall_u(riscv_cu_ecallu_de)  ,
  .o_riscv_cu_ecall_s(riscv_cu_ecalls_de)  ,
  .o_riscv_cu_ecall_m(riscv_cu_ecallm_de)  
);




riscv_hazardunit u_top_hzrdu

 (  
  .i_riscv_hzrdu_rs1addr_d(riscv_datapath_rs1addr_d_hzrdu) ,  //// [4:0]
  .i_riscv_hzrdu_rs2addr_d(riscv_datapath_rs2addr_d_hzrdu) , // [4:0]
 // .i_riscv_hzrdu_memw_d()   //  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  .i_riscv_hzrdu_rs1addr_e(riscv_datapath_rs1addr_e_hzrdu), // [4:0]
  .i_riscv_hzrdu_rs2addr_e(riscv_datapath_rs2addr_e_hzrdu) , // [4:0]
  .i_riscv_hzrdu_resultsrc_e(riscv_datapath_resultsrc_e_hzrdu)   ,  //[1:0]
  .i_riscv_hzrdu_rdaddr_e(riscv_datapath_rdaddr_e_hzrdu) ,  //[4:0]
  .i_riscv_hzrdu_valid(riscv_datapath_icu_valid_e_hzrdu),
  //Excute
   .o_riscv_hzrdu_fwda(riscv_datapath_fwda_hzrdu)  ,   //[1:0]  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>define their postion in excute >>_e
   .o_riscv_hzrdu_fwdb(riscv_datapath_fwdb_hzrdu) , // [1:0]
   
  .i_riscv_hzrdu_rdaddr_m(riscv_datapath_rdaddr_m_hzrdu) , // [4:0]
   // .i_riscv_hzrdu_memw_m(riscv_datapath_memw_m_hzrdu) ,    //>>>>>>>>>>>> added when support load sw forwadding
  .i_riscv_hzrdu_regw_m (riscv_datapath_regw_m_hzrdu)   ,
  .i_riscv_dcahe_stall_m(i_riscv_core_stall_m),
      
   .i_riscv_hzrdu_pcsrc(riscv_datapath_pcsrc_e_hzrdu) ,   //>>>>>>>>>>>>>>>>>??excute >>_e : is missed

  .i_riscv_hzrdu_rdaddr_w(riscv_datapath_rdaddr_wb_hzrdu) ,  // [4:0]
  .i_riscv_hzrdu_regw_w(riscv_datapath_regw_wb_hzrdu)  ,

 .i_riscv_hzrdu_opcode_m(riscv_datapath_opcode_hzrdu),
 .i_riscv_hzrdu_mul_en(riscv_datapath_mul_en_e_hzrdu),
 .i_riscv_hzrdu_div_en(riscv_datapath_div_en_e_hzrdu),

  //>>>>>> name check to define their location in stages or not _e ,_d , ..
  .o_riscv_hzrdu_stallpc(riscv_datapath_stallpc_hzrdu)  , 
  .o_riscv_hzrdu_stallfd(riscv_datapath_stall_fd_hzrdu)  , 
  .o_riscv_hzrdu_flushfd(riscv_datapath_flush_fd_hzrdu) ,  
  .o_riscv_hzrdu_flushde(riscv_datapath_flush_de_hzrdu), 
  .o_riscv_hzrdu_stallmw(riscv_datapath_stall_mw_hzrdu),
  .o_riscv_hzrdu_stallem(riscv_datapath_stall_em_hzrdu),
  .o_riscv_hzrdu_stallde(riscv_datapath_stall_de_hzrdu),


   .i_riscv_hzrdu_iscsr_e(muxcsr_sel_hzrd_datapath)        ,   // for csr
   .i_riscv_hzrdu_iscsr_d(iscsr_d_hzrd_datapath)       ,   // for csr
   .i_riscv_hzrdu_iscsr_w(iscsr_w_hzrd_datapath)        ,   // for csr
   .i_riscv_hzrdu_iscsr_m(iscsr_m_hzrd_datapath)       ,
   .o_riscv_hzrdu_passwb(muxcsr_sel_hzrd_datapath)        

  
  );








  

endmodule
