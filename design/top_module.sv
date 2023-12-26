module riscv_top
  (
     input logic i_riscv_clk , 
     input logic i_riscv_rst
  ) ;



/////////////Signal From DataPath to CU ////////////////
logic [6:0] riscv_datapath_opcode_cu  ;
logic [2:0] riscv_datapath_func3_cu   ;
logic       riscv_datapath_func7_5_cu       ;


/////////////Signal From CU to datapath ////////////////
logic       riscv_cu_regw_datapath;    /// from control unit
logic       riscv_cu_jump_datapath;     /// from control unit      
logic       riscv_cu_asel_datapath;     /// from control unit
logic       riscv_cu_bsel_datapath;     /// from control unit
logic       riscv_cu_memw_datapath;     /// from control unit
logic [1:0] riscv_cu_storesrc_datapath; /// from control unit [1:0]
logic [1:0] riscv_cu_resultsrc_datapath;/// from control unit  [1:0] 
logic [3:0] riscv_cu_bcond_datapath;    /// from control unit [3:0] 
logic [2:0] riscv_cu_memext_datapath;   /// from control unit [2:0]
logic [4:0] riscv_cu_aluctrl_datapath;  /// from control unit [4:0]
logic [2:0] riscv_cu_immsrc_datapath ; /// from control unit [2:0]
  

 /////////////////////Signals datapath >< haazard unit /////////////
  logic [1:0] riscv_datapath_fwda_hzrdu;        /// from hazard unit  [1:0] 
  logic [1:0] riscv_datapath_fwdb_hzrdu;        /// from hazard unit  [1:0]
  logic       riscv_datapath_pcsrc_e_hzrdu;     /// to hazard unit   
  logic [4:0] riscv_datapath_rs1addr_e_hzrdu;   /// to hazard unit  [4:0] 
  logic [4:0] riscv_datapath_rs2addr_e_hzrdu;   /// to hazard unit [4:0]
  logic [4:0] riscv_datapath_rdaddr_e_hzrdu;   /// to hazard unit [4:0]
  logic [1:0] riscv_datapath_resultsrc_e_hzrdu;  /// to hazard unit [1:0] 

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
  logic       riscv_datapath_flush_de_hzrdu; /// from hazard unit

  logic [4:0] riscv_datapath_rs1addr_d_hzrdu;/// to hazard unit [4:0]
  logic [4:0] riscv_datapath_rs2addr_d_hzrdu;/// to hazard unit [4:0]  


////////////////////////signals from datapath to IM/////////////////////////
logic [63:0] riscv_datapath_pc_im;
////////////////////////signals from im to datapath/////////////////////////
logic [31:0] riscv_im_inst_datapath;

///////////////////////signals from datapath to DM/////////////////////////
logic        riscv_datapath_memw_m_dm;
logic [1:0]  riscv_datapath_storesrc_m_dm;
logic [63:0] riscv_datapath_memodata_addr_dm;
logic [63:0] riscv_datapath_storedata_m_dm;

////////////////////////signals from im to datapath/////////////////////////
logic [63:0] riscv_datapath_rdata_dm;







riscv_datapath u_top_datapath(               //#(parameter width=64) (
    .i_riscv_datapath_clk(i_riscv_clk),
    .i_riscv_datapath_rst(i_riscv_rst),
  
  ///////////////////fetch//////////////////
  .i_riscv_datapath_stallpc(riscv_datapath_stallpc_hzrdu),  /// from hazard unit
  .o_riscv_datapath_pc(riscv_datapath_pc_im) ,                                    /// to im   [width-1:0]
  ///////////////////fd_pff//////////////////
  .i_riscv_datapath_inst(riscv_im_inst_datapath),                                 /// from im  [31:0]
  .i_riscv_datapath_flush_fd(riscv_datapath_flush_fd_hzrdu), /// from hazard unit
  .i_riscv_datapath_stall_fd(riscv_datapath_stall_fd_hzrdu), /// from hazard unit
  /////////////////////decode///////////// 
  .i_riscv_datapath_immsrc(riscv_cu_immsrc_datapath),       /// from control   [2:0]
  .o_riscv_datapath_opcode(riscv_datapath_opcode_cu),      /// to control unit [6:0]
  .o_riscv_datapath_func3(riscv_datapath_func3_cu),        /// to control unit [2:0] 
  .o_riscv_datapath_func7_5(riscv_datapath_func7_5_cu),    /// to control unit
  
  .o_riscv_datapath_rs1addr_d(riscv_datapath_rs1addr_d_hzrdu),/// to hazard unit [4:0]
  .o_riscv_datapath_rs2addr_d(riscv_datapath_rs2addr_d_hzrdu),/// to hazard unit [4:0]  
  ///////////////////de_pff//////////////////
  .i_riscv_datapath_regw(riscv_cu_regw_datapath),         /// from control unit
  .i_riscv_datapath_jump(riscv_cu_jump_datapath),         /// from control unit      
  .i_riscv_datapath_asel(riscv_cu_asel_datapath),        /// from control unit
  .i_riscv_datapath_bsel(riscv_cu_bsel_datapath),        /// from control unit
  .i_riscv_datapath_memw(riscv_cu_memw_datapath),         /// from control unit
  .i_riscv_datapath_storesrc(riscv_cu_storesrc_datapath), /// from control unit [1:0]
  .i_riscv_datapath_resultsrc(riscv_cu_resultsrc_datapath),/// from control unit  [1:0] 
  .i_riscv_datapath_bcond(riscv_cu_bcond_datapath),       /// from control unit [3:0] 
  .i_riscv_datapath_memext(riscv_cu_memext_datapath),     /// from control unit [2:0]
  .i_riscv_datapath_aluctrl(riscv_cu_aluctrl_datapath),    /// from control unit [4:0]



  .i_riscv_datapath_flush_de(riscv_datapath_flush_de_hzrdu), /// from hazard unit
  /////////////////////execute/////////////
  .i_riscv_datapath_fwda(riscv_datapath_fwda_hzrdu),        /// from hazard unit  [1:0] 
  .i_riscv_datapath_fwdb(riscv_datapath_fwdb_hzrdu),        /// from hazard unit  [1:0]
  .o_riscv_datapath_pcsrc_e(riscv_datapath_pcsrc_e_hzrdu),     /// to hazard unit   
  .o_riscv_datapath_rs1addr_e(riscv_datapath_rs1addr_e_hzrdu),   /// to hazard unit  [4:0] 
  .o_riscv_datapath_rs2addr_e(riscv_datapath_rs2addr_e_hzrdu),   /// to hazard unit [4:0]
  .o_riscv_datapath_rdaddr_e(riscv_datapath_rdaddr_e_hzrdu),   /// to hazard unit [4:0]
  .o_riscv_datapath_resultsrc_e(riscv_datapath_resultsrc_e_hzrdu),  /// to hazard unit [1:0]  
  /////////////////////memory/////////////
  .i_riscv_datapath_dm_rdata(riscv_datapath_rdata_dm),      /// from dm [width-1:0]
  .o_riscv_datapath_storesrc_m(riscv_datapath_storesrc_m_dm),   /// to dm [1:0]
  .o_riscv_datapath_memodata_addr(riscv_datapath_memodata_addr_dm),/// to dm [width-1:0]
  .o_riscv_datapath_storedata_m(riscv_datapath_storedata_m_dm),  /// to dm [width-1:0]
  .o_riscv_datapath_memw_m(riscv_datapath_memw_m_dm),       /// to dm &&&&&&  to hazard unit

  .o_riscv_datapath_rdaddr_m(riscv_datapath_rdaddr_m_hzrdu),      /// to hazard unit [4:0]
  .o_riscv_datapath_regw_m(riscv_datapath_regw_m_hzrdu),       /// to hazard unit
  
  /////////////////////write back ///////////
  .o_riscv_datapath_regw_wb(riscv_datapath_regw_wb_hzrdu),     /// to hazard unit   
  .o_riscv_datapath_rdaddr_wb(riscv_datapath_rdaddr_wb_hzrdu)    /// to hazard unit [4:0] 
  
 );



riscv_cu u_top_cu (

  /////////////Signal From DataPath to CU ////////////////
  .i_riscv_cu_opcode(riscv_datapath_opcode_cu), //7-bit  opcode[6:0]             [6:0] 
  .i_riscv_cu_funct3(riscv_datapath_func3_cu), //3-bit  func_3[14:12]          [2:0]
  .i_riscv_cu_funct7_5(riscv_datapath_func7_5_cu),//1-bit  func_7[30]
  // Siganls from cu to datapath
  .o_riscv_cu_jump(riscv_cu_jump_datapath), 
  .o_riscv_cu_regw(riscv_cu_regw_datapath),
  .o_riscv_cu_asel(riscv_cu_asel_datapath),
  .o_riscv_cu_bsel(riscv_cu_bsel_datapath),
  .o_riscv_cu_memw(riscv_cu_memw_datapath),  
  .o_riscv_cu_storesrc(riscv_cu_storesrc_datapath),                                   //  [1:0]
  .o_riscv_cu_resultsrc(riscv_cu_resultsrc_datapath),                                     // [1:0] 
  .o_riscv_cu_bcond(riscv_cu_bcond_datapath),//msb for branch enable  [3:0]
  .o_riscv_cu_memext(riscv_cu_memext_datapath), //[2:0]

  .o_riscv_cu_immsrc(riscv_cu_immsrc_datapath),  //[2:0] 
  .o_riscv_cu_aluctrl(riscv_cu_aluctrl_datapath) //[4:0]
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
  //Excute
   .o_riscv_hzrdu_fwda(riscv_datapath_fwda_hzrdu)  ,   //[1:0]  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>define their postion in excute >>_e
   .o_riscv_hzrdu_fwdb(riscv_datapath_fwdb_hzrdu) , // [1:0]

  .i_riscv_hzrdu_rdaddr_m(riscv_datapath_rdaddr_m_hzrdu) , // [4:0]
   // .i_riscv_hzrdu_memw_m(riscv_datapath_memw_m_hzrdu) ,    //>>>>>>>>>>>> added when support load sw forwadding
  .i_riscv_hzrdu_regw_m(riscv_datapath_regw_m_hzrdu)   ,
  
      
   .i_riscv_hzrdu_pcsrc(riscv_datapath_pcsrc_e_hzrdu) ,   //>>>>>>>>>>>>>>>>>??excute >>_e : is missed

  .i_riscv_hzrdu_rdaddr_w(riscv_datapath_rdaddr_wb_hzrdu) ,  // [4:0]
  .i_riscv_hzrdu_regw_w(riscv_datapath_regw_wb_hzrdu)  ,

 
  
  //>>>>>> name check to define their location in stages or not _e ,_d , ..
  .o_riscv_hzrdu_stallpc(riscv_datapath_stallpc_hzrdu)  , 
  .o_riscv_hzrdu_stallfd(riscv_datapath_stall_fd_hzrdu)  , 
  .o_riscv_hzrdu_flushfd(riscv_datapath_flush_fd_hzrdu) ,  
  .o_riscv_hzrdu_flushde(riscv_datapath_flush_de_hzrdu) 

  );

riscv_im u_top_im(
  .i_riscv_im_pc(riscv_datapath_pc_im),
  .o_riscv_im_inst(riscv_im_inst_datapath)
);

riscv_dm u_top_dm(
  .i_riscv_dm_clk_n(!i_riscv_clk),
  .i_riscv_dm_rst(i_riscv_rst),
  .i_riscv_dm_wen(riscv_datapath_memw_m_dm),
  .i_riscv_dm_sel(riscv_datapath_storesrc_m_dm),
  .i_riscv_dm_wdata(riscv_datapath_storedata_m_dm),
  .i_riscv_dm_waddr(riscv_datapath_memodata_addr_dm),
  .o_riscv_dm_rdata(riscv_datapath_rdata_dm)
);

endmodule

