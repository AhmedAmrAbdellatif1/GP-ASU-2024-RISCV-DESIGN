  module riscv_em_ppreg  #(parameter width =64)

    (
    //---------------------------------------------->
    `ifdef TEST
    input   logic   [31:0]  i_riscv_em_inst         ,
    input   logic   [15:0]  i_riscv_em_cinst        ,
    input   logic   [63:0]  i_riscv_em_pc           ,
    output  logic   [31:0]  o_riscv_em_inst         ,
    output  logic   [15:0]  o_riscv_em_cinst        ,
    output  logic   [63:0]  o_riscv_em_pc           ,
    `endif
    //<----------------------------------------------
    input   logic           i_riscv_em_clk          ,
    input   logic           i_riscv_em_rst          ,
    input   logic           i_riscv_em_en           ,
    //input   logic           i_riscv_em_memw_e       ,
    input   logic           i_riscv_em_regw_e       ,
    input   logic   [1:0]   i_riscv_em_resultsrc_e  ,
    input   logic   [1:0]   i_riscv_em_storesrc_e   ,
    input   logic   [2:0]   i_riscv_em_memext_e     ,
    input   logic   [63:0]  i_riscv_em_pcplus4_e    ,
    input   logic   [63:0]  i_riscv_em_result_e     ,
    input   logic   [63:0]  i_riscv_em_storedata_e  ,
    input   logic   [4:0]   i_riscv_em_rdaddr_e     ,
    input   logic   [63:0]  i_riscv_em_imm_e        ,
    input   logic   [6:0]   i_riscv_de_opcode_e     ,
    //output  logic           o_riscv_em_memw_m       ,
    output  logic           o_riscv_em_regw_m       ,
    output  logic   [1:0]   o_riscv_em_resultsrc_m  ,
    output  logic   [1:0]   o_riscv_em_storesrc_m   ,
    output  logic   [2:0]   o_riscv_em_memext_m     ,
    output  logic   [63:0]  o_riscv_em_pcplus4_m    ,
    output  logic   [63:0]  o_riscv_em_result_m     ,
    output  logic   [63:0]  o_riscv_em_storedata_m  ,
    output  logic   [4:0]   o_riscv_em_rdaddr_m     ,
    output  logic   [63:0]  o_riscv_em_imm_m        ,
    output  logic   [6:0]   o_riscv_de_opcode_m     ,

    //trap
    input logic             i_riscv_em_flush   ,
    //input  i_riscv_em_ecall_u_e  ,
    //input  i_riscv_em_ecall_s_e  , 
    input   logic           i_riscv_em_ecall_m_e    , 
    input   logic  [11:0]   i_riscv_em_csraddress_e ,
    input   logic          i_riscv_em_illegal_inst_e ,
    //Control Signals 
    input   logic           i_riscv_em_iscsr_e ,
    input   logic   [2:0]   i_riscv_em_csrop_e ,
    //input   logic          i_riscv_em_immreg_e ,
    input   logic   [63:0]       i_riscv_em_addressalu_e ,  // ?? check
    input   logic              i_riscv_em_inst_addr_misaligned_e   ,
    input   logic             i_riscv_em_load_addr_misaligned_e    ,
    input   logic             i_riscv_em_store_addr_misaligned_e   ,
     input logic [width-1:0]  i_riscv_em_csrwritedata_e    ,

    
     
    //output                  o_riscv_em_ecall_u_m  ,
    //output                  o_riscv_em_ecall_s_m  , 
    output   logic            o_riscv_em_ecall_m_m    , 
    output   logic [11:0]     o_riscv_em_csraddress_m ,
    output   logic            o_riscv_em_illegal_inst_m ,
    //Control Signals 
    output   logic              o_riscv_em_iscsr_m ,
    output   logic [2:0]        o_riscv_em_csrop_m ,
    //output   logic            o_riscv_em_immreg_m ,
    output   logic  [63:0]      o_riscv_em_addressalu_m ,
     output   logic             o_riscv_em_inst_addr_misaligned_m   ,
    output   logic              o_riscv_em_load_addr_misaligned_m    ,
    output   logic              o_riscv_em_store_addr_misaligned_m   ,
    output   logic [width-1:0]  o_riscv_em_csrwritedata_m    ,
    // for CSR HAZARD
    input    logic [4:0]  i_riscv_em_rs1addr_e,
    output   logic [4:0]  o_riscv_em_rs1addr_m


  );


  always_ff @ (posedge i_riscv_em_clk or posedge i_riscv_em_rst)
    begin :em_pff_write_proc
        if (i_riscv_em_rst)
          begin:em_pff_write_proc
          //  o_riscv_em_memw_m       <= 'b0;
            o_riscv_em_regw_m       <= 'b0;
            o_riscv_em_resultsrc_m  <= 'b0;
            o_riscv_em_storesrc_m   <= 'b0;
            o_riscv_em_memext_m     <= 'b0;
            o_riscv_em_pcplus4_m    <= 'b0;
            o_riscv_em_result_m     <= 'b0;
            o_riscv_em_storedata_m  <= 'b0;
            o_riscv_em_rdaddr_m     <= 'b0;
            o_riscv_em_imm_m        <= 'b0;            
            o_riscv_de_opcode_m     <= 'b0;

            // Trap 
           //o_riscv_em_ecall_u_m   <= 'b0; 
           //o_riscv_em_ecall_s_m   <= 'b0;  
            o_riscv_em_ecall_m_m    <= 'b0; 
            o_riscv_em_csraddress_m <= 'b0; 
            o_riscv_em_illegal_inst_m  <= 'b0;
            //Control Signals 
            o_riscv_em_iscsr_m      <= 'b0; 
            o_riscv_em_csrop_m      <= 'b0; 
            //o_riscv_em_immreg_m     <= 'b0;
              
            o_riscv_em_addressalu_m <= 'b0;
            o_riscv_em_inst_addr_misaligned_m   <= 'b0;
            o_riscv_em_load_addr_misaligned_m    <= 'b0;
            o_riscv_em_store_addr_misaligned_m  <= 'b0;  
            o_riscv_em_csrwritedata_m           <= 'b0;  

            o_riscv_em_rs1addr_m <= 'b0;


            //---------------------------->
            `ifdef TEST
            o_riscv_em_inst         <= 'b0;
            o_riscv_em_cinst        <= 'b0;
            o_riscv_em_pc           <= 'b0;
            `endif
            //<----------------------------
          end
        else
          begin
          

        if  (i_riscv_em_flush)  begin
            //o_riscv_em_memw_m       <= 'b0;
            o_riscv_em_regw_m       <= 'b0;
            o_riscv_em_resultsrc_m  <= 'b0;
            o_riscv_em_storesrc_m   <= 'b0;
            o_riscv_em_memext_m     <= 'b0;
            o_riscv_em_pcplus4_m    <= 'b0;
            o_riscv_em_result_m     <= 'b0;
            o_riscv_em_storedata_m  <= 'b0;
            o_riscv_em_rdaddr_m     <= 'b0;
            o_riscv_em_imm_m        <= 'b0;
            o_riscv_de_opcode_m     <= 'b0;
             o_riscv_em_csrwritedata_m           <= 'b0; 
        
           // Trap 
           //o_riscv_em_ecall_u_m   <= 'b0 ; 
           //o_riscv_em_ecall_s_m   <= 'b0;  
            o_riscv_em_ecall_m_m    <= 'b0; 
            o_riscv_em_csraddress_m <= 'b0; 
            o_riscv_em_illegal_inst_m  <= 'b0;
            //Control Signals 
            o_riscv_em_iscsr_m      <= 'b0 ; 
            o_riscv_em_csrop_m      <= 'b0 ; 
            //o_riscv_em_immreg_m     <= 'b0 ;

            o_riscv_em_addressalu_m <= 'b0;
            o_riscv_em_inst_addr_misaligned_m   <= 'b0;
            o_riscv_em_load_addr_misaligned_m    <= 'b0;
            o_riscv_em_store_addr_misaligned_m  <= 'b0;  

            o_riscv_em_rs1addr_m <= 'b0;
        //---------------------------------------->
            `ifdef TEST
            o_riscv_em_inst         <= 'b0;
            o_riscv_em_cinst        <= 'b0;
            o_riscv_em_pc           <= 'b0 ;
            `endif
            //<----------------------------------------
       end




       else if (i_riscv_em_en)
        begin
      //  o_riscv_em_memw_m       <= o_riscv_em_memw_m;
        o_riscv_em_regw_m       <= o_riscv_em_regw_m;
        o_riscv_em_resultsrc_m  <= o_riscv_em_resultsrc_m;
        o_riscv_em_storesrc_m   <= o_riscv_em_storesrc_m;
        o_riscv_em_memext_m     <= o_riscv_em_memext_m;
        o_riscv_em_pcplus4_m    <= o_riscv_em_pcplus4_m;
        o_riscv_em_result_m     <= o_riscv_em_result_m;
        o_riscv_em_storedata_m  <= o_riscv_em_storedata_m;
        o_riscv_em_rdaddr_m     <= o_riscv_em_rdaddr_m;
        o_riscv_em_imm_m        <= o_riscv_em_imm_m;
        o_riscv_de_opcode_m     <= o_riscv_de_opcode_m;
        
           // Trap 
           //o_riscv_em_ecall_u_m   <= o_riscv_em_ecall_u_m ; 
           //o_riscv_em_ecall_s_m   <= o_riscv_em_ecall_s_m;  
            o_riscv_em_ecall_m_m    <= o_riscv_em_ecall_m_m; 
            o_riscv_em_csraddress_m <= o_riscv_em_csraddress_m; 
            o_riscv_em_illegal_inst_m  <= o_riscv_em_illegal_inst_m;
            //Control Signals 
            o_riscv_em_iscsr_m      <= o_riscv_em_iscsr_m ; 
            o_riscv_em_csrop_m      <= o_riscv_em_csrop_m ; 
           // o_riscv_em_immreg_m     <= o_riscv_em_immreg_m ;


              o_riscv_em_addressalu_m <= o_riscv_em_addressalu_m;
            o_riscv_em_inst_addr_misaligned_m   <= o_riscv_em_inst_addr_misaligned_m;
            o_riscv_em_load_addr_misaligned_m    <= o_riscv_em_load_addr_misaligned_m;
            o_riscv_em_store_addr_misaligned_m  <= o_riscv_em_store_addr_misaligned_m;  
             o_riscv_em_csrwritedata_m           <= o_riscv_em_csrwritedata_m; 

             o_riscv_em_rs1addr_m <= o_riscv_em_rs1addr_m;
        //---------------------------------------->
        `ifdef TEST
        o_riscv_em_inst         <= o_riscv_em_inst;
        o_riscv_em_cinst        <= o_riscv_em_cinst;
        o_riscv_em_pc           <= o_riscv_em_pc;
        `endif
        //<----------------------------------------
end
     else
       begin
            //o_riscv_em_memw_m       <= i_riscv_em_memw_e ; 
            o_riscv_em_regw_m       <= i_riscv_em_regw_e ;
            o_riscv_em_resultsrc_m  <= i_riscv_em_resultsrc_e;
            o_riscv_em_storesrc_m   <= i_riscv_em_storesrc_e;
            o_riscv_em_memext_m     <= i_riscv_em_memext_e;
            o_riscv_em_pcplus4_m    <= i_riscv_em_pcplus4_e;
            o_riscv_em_result_m     <= i_riscv_em_result_e;
            o_riscv_em_storedata_m  <= i_riscv_em_storedata_e;
            o_riscv_em_rdaddr_m     <= i_riscv_em_rdaddr_e;
            o_riscv_em_imm_m        <= i_riscv_em_imm_e;
            o_riscv_de_opcode_m     <= i_riscv_de_opcode_e;

            //Trap

            
           //o_riscv_em_ecall_u_m   <= o_riscv_em_ecall_u_e ; 
           //o_riscv_em_ecall_s_m   <= o_riscv_em_ecall_s_e;  
            o_riscv_em_ecall_m_m    <= i_riscv_em_ecall_m_e; 
            o_riscv_em_csraddress_m <= i_riscv_em_csraddress_e; 
            o_riscv_em_illegal_inst_m  <= i_riscv_em_illegal_inst_e;
            //Control Signals 
            o_riscv_em_iscsr_m      <= i_riscv_em_iscsr_e ; 
            o_riscv_em_csrop_m      <= i_riscv_em_csrop_e ; 
            //o_riscv_em_immreg_m     <= i_riscv_em_immreg_e ;

              o_riscv_em_addressalu_m <= i_riscv_em_addressalu_e;
            o_riscv_em_inst_addr_misaligned_m   <= i_riscv_em_inst_addr_misaligned_e;
            o_riscv_em_load_addr_misaligned_m    <= i_riscv_em_load_addr_misaligned_e;
            o_riscv_em_store_addr_misaligned_m  <= i_riscv_em_store_addr_misaligned_e ; 
            o_riscv_em_csrwritedata_m     <=   i_riscv_em_csrwritedata_e ;
            o_riscv_em_rs1addr_m          <=   i_riscv_em_rs1addr_e;
            //----------------------------------------->
            `ifdef TEST
            o_riscv_em_inst         <= i_riscv_em_inst;
            o_riscv_em_cinst        <= i_riscv_em_cinst;
            o_riscv_em_pc           <= i_riscv_em_pc;
            `endif
            //<-----------------------------------------
       end
    end
end
endmodule