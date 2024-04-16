`include "packages.sv"
module riscv_csrfile  # ( parameter MXLEN              = 64   ,
                          parameter SXLEN              = 64   ,
                          parameter support_supervisor = 1    ,
                          parameter support_user       = 1    )
  (
    input   logic               i_riscv_csr_clk                   ,
    input   logic               i_riscv_csr_rst                   ,
    input   logic [11:0]        i_riscv_csr_address               ,
    input   logic [2:0]         i_riscv_csr_op                    ,
    input   logic [MXLEN-1:0]   i_riscv_csr_wdata                 ,
    input   logic               i_riscv_csr_external_int          , 
    input   logic               i_riscv_csr_timer_int             , 
    input   logic [63:0]        i_riscv_csr_pc                    ,
    input   logic [63:0]        i_riscv_csr_addressALU            , 
    input   logic [31:0]        i_riscv_csr_inst                  ,
    input   logic [15:0]        i_riscv_csr_cinst                 ,
    input   logic               i_riscv_csr_illegal_inst          , 
    input   logic               i_riscv_csr_ecall_u               ,        
    input   logic               i_riscv_csr_ecall_s               ,        
    input   logic               i_riscv_csr_ecall_m               ,       
    input   logic               i_riscv_csr_inst_addr_misaligned  ,
    input   logic               i_riscv_csr_load_addr_misaligned  ,
    input   logic               i_riscv_csr_store_addr_misaligned ,
    input   logic               i_riscv_csr_flush                 ,
    input   logic               i_riscv_csr_globstall             ,
    input   logic               i_riscv_csr_is_compressed         ,
    output  logic [MXLEN-1:0]   o_riscv_csr_rdata                 ,
    output  logic               o_riscv_csr_sideeffect_flush      ,
    output  logic [MXLEN-1:0]   o_riscv_csr_return_address        , 
    output  logic [MXLEN-1:0]   o_riscv_csr_trap_address          ,   
    output  logic               o_riscv_csr_gotoTrap_cs           , 
    output  logic [1:0]         o_riscv_csr_returnfromTrap_cs     ,
    output  logic [1:0]         o_riscv_csr_privlvl               ,
    output  logic               o_riscv_csr_flush                 ,
    output  logic [SXLEN-1:0]   o_riscv_csr_sepc                  ,
    output  logic               o_riscv_csr_tsr
  );
   
  /****************************** Packages ******************************/
  import csr_pkg::*;
  
  /****************************** CSR Register Implementation ******************************/

  //***  Privilege levels are used to provide protection between different components of the software stack
  logic   [1:0]     current_priv_lvl  ;

  //***  Machine Exception Program Counter ***//
  logic [MXLEN-1:0] mepc              ;

  //***  Machine Scratch Register ***//
  logic [MXLEN-1:0] mscratch          ;     //  Dedicated for use by machine code

  //***  Machine Trap Value Register ***//
  logic [MXLEN-1:0] mtval             ;     //  Exception-specific infotmation to assist software in handling trap

  //***  Machine Trap-Vector Base-Address Register ***//
  logic [MXLEN-3:0] mtvec_base        ;        //  Address of pc taken after returning from Trap (via MRET)
  logic   [1:0]     mtvec_mode        ;        //  Vector mode addressing  >>  vectored or direct

  //*** Machine Status Registers ***// : 
  logic             mstatus_sie       ;           //  Supervisor Interrupt Enable
  logic             mstatus_mie       ;           //  Machine Interrupt Enable
  logic             mstatus_spie      ;           //  Supervisor Previous Interrupt Enable
  logic             mstatus_ube       ;         
  logic             mstatus_mpie      ;           //  Machine Previous Interrupt Enable
  logic             mstatus_spp       ;
  logic [1:0]       mstatus_mpp       ;
  logic             mstatus_mprv      ;
  logic             mstatus_sum       ;
  logic             mstatus_mxr       ;
  logic             mstatus_tvm       ;
  logic             mstatus_tw        ;
  logic             mstatus_tsr       ;
  logic [1:0]       mstatus_uxl       ;
  logic [1:0]       mstatus_sxl       ;
  logic             mstatus_sbe       ;
  logic             mstatus_mbe       ;
  //  The mstatus register keeps track of and controls the hart’s current operating state.


  //***  Machine Interrupt Registers ***//
  logic             mie_stie          ; //  Supervisor timer interrupt enable
  logic             mie_mtie          ; //  Machine timer interrupt enable
  logic             mie_seie          ; //  Supervisor external exception enable
  logic             mie_meie          ; //  Machine external exception enable
          
  logic             mip_stip          ; //  Supervisor timer interrupt pending
  logic             mip_mtip          ; //  Machine timer interrupt pending
  logic             mip_seip          ; //  Supervisor external exception pending
  logic             mip_meip          ; //  Machine external exception pending
  
  //*** Machine Cause Register ***//
  // When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap.
  logic             mcause_int_excep  ; //  Interrupt(1) or exception(0)
  logic [3:0]       mcause_code       ; //  Indicates event that caused the trap
  
  //*** Machine Trap Delegation Registers ***//
  logic [15:0]      medeleg           ;
  
  logic [15:0]      mideleg           ;
  logic             mideleg_mei       ; //  Machine external interrupt delegation
  logic             mideleg_mti       ; //  Machine timer interrupt delegation
  logic             mideleg_sei       ; //  Supervisor external interrupt delegation
  logic             mideleg_sti       ; //  Supervisor timer interrupt delegation

  assign mideleg  = { 4'b0000       ,
                      mideleg_mei   ,
                      1'b0          ,
                      mideleg_sei   ,
                      1'b0          ,
                      mideleg_mti   ,
                      1'b0          ,
                      mideleg_sti   ,
                      5'b00000     };

  //************************//

  //*** Supervisor Trap Value Register ***//
  logic [SXLEN-1:0] stval     ;

  //*** Supervisor Scratch Register ***//
  logic [SXLEN-1:0] sscratch  ;
 
  //*** Supervisor Exception Program Counter ***//
  logic [SXLEN-1:0] sepc      ;
  
  //*** Supervisor Cause Register ***//
  logic             scause_int_excep  ; //  Interrupt(1) or exception(0)
  logic  [3:0]      scause_code       ; //  Indicates event that caused the trap
  
  //*** Supervisor Trap Vector Base Address Register ***//
  logic [SXLEN-3:0] stvec_base        ; //  Address of pc taken after returning from Trap (via MRET)
  logic   [1:0]     stvec_mode        ; //  Vector mode addressing >> vectored or direct

   
  
  /****************************** Internal Flags Declaration ******************************/
  logic             is_exception                  ;  //  exception flag
  logic             is_interrupt                  ;  //  interrupt flag
                  
  logic             is_trap                       ;   //  trap detection
  logic             go_to_trap                    ;   //  go to trap handler

  logic             illegal_priv_access           ;
  logic             illegal_write_access          ;
  logic             illegal_read_access           ; 
  logic             illegal_csr_access            ;

  logic             csr_write_en                  ;
  logic [MXLEN-1:0] csr_write_data                ;
  logic             csr_write_access_en           ; 
  
  logic             csr_read_en                   ;
  logic [MXLEN-1:0] csr_read_data                 ;

  logic             mret                          ;
  logic             sret                          ;

  logic [1:0]       trap_to_priv_lvl              ;
  logic             interrupt_go                  ;

  logic [MXLEN-1:0] trap_base_addr                ;
  
  logic [5:0]       interrupt_cause               ;
  logic [5:0]       execption_cause               ;

  logic             interrupt_global_enable       ;

  logic             valid                         ;

  logic             M_ext_int_pend                ;
  logic             M_timer_int_pend              ;

  logic             S_ext_int_pend                ;
  logic             S_timer_int_pend              ;
  

  /****************************** Continuous Assignment Statements ******************************/
  // outputs
  assign o_riscv_csr_sepc             = sepc                  ;
  assign o_riscv_csr_return_address   = mepc                  ;
  assign o_riscv_csr_privlvl          = current_priv_lvl      ;
  assign o_riscv_csr_trap_address     = trap_base_addr        ;
  assign o_riscv_csr_gotoTrap_cs      = go_to_trap            ;

  assign is_csr                       = (i_riscv_csr_op == 3'd0)? 1'b0:1'b1;
  assign is_interrupt                 = interrupt_go && interrupt_global_enable       ;

  assign is_trap                      = (is_interrupt || is_exception)? 1'b1:1'b0;
  assign go_to_trap                   =  is_trap && !i_riscv_csr_flush && !i_riscv_csr_globstall ;


  assign illegal_priv_access          = ((i_riscv_csr_address[9:8] > current_priv_lvl) && is_csr);    
  assign illegal_write_access         = (i_riscv_csr_address[11:10] == 2'b11) && csr_write_en ;   
  assign illegal_csr_access           = ((illegal_read_access | illegal_write_access | illegal_priv_access ) && is_csr) ;
  assign illegal_total                =  illegal_csr_access | i_riscv_csr_illegal_inst ;

  assign csr_write_access_en          = csr_write_en &  ~illegal_csr_access;

  assign mip_timer_next               = i_riscv_csr_timer_int ;
  assign mip_external_next            = i_riscv_csr_external_int ;
  assign o_riscv_csr_tsr              = mstatus_tsr;

  /*** Modes transition conditions ***/
  assign force_s_delegation = ( (support_supervisor)  &&
                                (current_priv_lvl == PRIV_LVL_S) &&
                                (medeleg[execption_cause[3:0]] || mideleg[interrupt_cause[3:0]]));

  assign no_delegation      = ( (support_supervisor)  &&
                                (current_priv_lvl == PRIV_LVL_S) &&
                                (!medeleg[execption_cause[3:0]] && !mideleg[interrupt_cause[3:0]]));

  /****************************** Trap Base Address ******************************/
  always_comb
  begin

    trap_base_addr = {mtvec_base, 2'b0};  // initialize base address

    if (current_priv_lvl == PRIV_LVL_S)
    begin
      trap_base_addr = {stvec_base, 2'b0};
    end

    if ((mtvec_base[0] || stvec_base[0]) && interrupt_go)
    begin
      trap_base_addr[7:2] = interrupt_cause[5:0];
    end
  end

  /*----------------  */
  // CSR Read logic
  /* ---------------- */
  always_comb
  begin : csr_read_process

    // a read access exception can only occur if we attempt to read a CSR which does not exist
    //read_access_exception = 1'b0;
    csr_read_data = 64'b0;
    illegal_read_access=1'b0 ;
    //perf_addr_o = csr_addr.address[4:0];;

    if (csr_read_en)
    begin    //see last always block to know when it is asserted
      //unique case (i_riscv_csr_address)
      case (i_riscv_csr_address)

        // mvendorid: encoding of manufacturer/provider
        CSR_MVENDORID :
          csr_read_data = 64'b0 ;  // can indicate it is not implemnted or it is not commercial implementation;

        // misa
        CSR_MISA      :
          csr_read_data = ISA_CODE;   //only written ones are read one while default all are read zero

        // marchid: encoding of base microarchitecture
        CSR_MARCHID   :
          csr_read_data = 64'b0 ;   //open source archture should have values

        // mimpid: encoding of processor implementation version
        //CSR_MIMPID: csr_read_data =  CSR_MIMPID_VALUE;   // we who decide the number that reflect the design of riscv itself
        CSR_MIMPID    :
          csr_read_data = 64'b0     ; // not implemented

        // mhartid: unique hardware thread id
        //  CSR_MHARTID   :   csr_read_data = hart_id_i;
        CSR_MHARTID   :
          csr_read_data = 'b0 ;


        /*----------------  */
        // mstatus  : MXLEN-bit read/write register
        /* ---------------- */
        CSR_MSTATUS   :
        begin


          csr_read_data[CSR_MSTATUS_SXL_BIT_HIGH:CSR_MSTATUS_SXL_BIT_LOW] = (support_supervisor) ? 2'b10 : 2'b00 ;
          csr_read_data[CSR_MSTATUS_UXL_BIT_HIGH:CSR_MSTATUS_UXL_BIT_LOW] =  (support_user)     ? 2'b10 : 2'b00 ;

          csr_read_data[CSR_MSTATUS_MIE_BIT]                              = mstatus_mie;
          csr_read_data[CSR_MSTATUS_MPIE_BIT]                             = mstatus_mpie;
          csr_read_data[CSR_MSTATUS_SIE_BIT]                              = mstatus_sie;
          csr_read_data[CSR_MSTATUS_SPIE_BIT]                             = mstatus_spie;
          csr_read_data[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_mpp;
          csr_read_data[CSR_MSTATUS_SPP ]                                 = mstatus_spp;

          //for memory
          csr_read_data[CSR_MSTATUS_MPRV_BIT]                             = mstatus_mprv;
          csr_read_data[CSR_MSTATUS_MXR_BIT]                              = mstatus_mxr ;
          csr_read_data[CSR_MSTATUS_SUM_BIT]                              = mstatus_sum ;

          //for virtulazation supprot
          csr_read_data[CSR_MSTATUS_TSR_BIT]                              = mstatus_tsr;
          csr_read_data[CSR_MSTATUS_TW_BIT]                               = mstatus_tw ;
          csr_read_data[CSR_MSTATUS_TVM_BIT]                              = mstatus_tvm;


          csr_read_data[CSR_MSTATUS_SBE_BIT]                              = mstatus_sbe;
          csr_read_data[CSR_MSTATUS_MBE_BIT]                              = mstatus_mbe ;
          csr_read_data[CSR_MSTATUS_UBE_BIT]                              = mstatus_ube ;

        end

        /*----------------  */
        // mtvec  :  trap-vector base address
        /* ---------------- */
        CSR_MTVEC    :
        begin
          csr_read_data [1:0]                               = mtvec_mode ;
          // csr_read_data [0]                              = mtvec_mode ;
          csr_read_data[MXLEN-1:2]                          = mtvec_base;

        end


        // MEDELEG
        CSR_MEDELEG  :
          csr_read_data[15:0]                                = medeleg;

        //  MIDELEG
        CSR_MIDELEG :
        begin
          // csr_read_data[M_SOFT_I]                       = mideleg_msi_cs;
          csr_read_data[M_TIMER_I]                        = mideleg_mti;
          csr_read_data[M_EXT_I]                          = mideleg_mei;
          //csr_read_data[S_SOFT_I]                       = mideleg_ssi_cs;
          csr_read_data[S_TIMER_I]                        = mideleg_sti;
          csr_read_data[S_EXT_I]                          = mideleg_sei ;

        end
        CSR_MIE    :
        begin
          //csr_read_data                                     = '0;
          //csr_read_data[M_SOFT_I]                       = mie_msie_cs;
          csr_read_data[M_TIMER_I]                        = mie_mtie;
          csr_read_data[M_EXT_I]                          = mie_meie ;
          //csr_read_data[S_SOFT_I]                       = mie_ssie_cs;
          csr_read_data[S_TIMER_I]                        = mie_stie;
          csr_read_data[S_EXT_I]                          = mie_seie ;
        end

        CSR_MIP    :
        begin
          // csr_read_data                                     = '0;
          //csr_read_data[M_SOFT_I]                       = mip_msip_cs;
          csr_read_data[M_TIMER_I]                        = mip_mtip;
          csr_read_data[M_EXT_I]                          = mip_meip;
          //csr_read_data[S_SOFT_I]                       = mip_ssip_cs;
          csr_read_data[S_TIMER_I]                        = mip_stip;
          csr_read_data[S_EXT_I]                          = mip_seip ;
        end
        CSR_MSCRATCH :
          csr_read_data                                   = mscratch;
        // mepc: exception program counter
        CSR_MEPC    :
          csr_read_data                                   = mepc ;

        // mcause: exception cause
        CSR_MCAUSE  :
        begin
             //we dont support internal interupts only external interupts

          csr_read_data      = { mcause_int_excep ,59'b0 , mcause_code [3:0] };  //[4:0] until now it is wrong >>check it

        end

        CSR_MTVAL   :
          csr_read_data     = mtval;

        CSR_SIE            :
        begin
          /*csr_read_data[S_TIMER_I]                        = mie_stie;
          csr_read_data[S_EXT_I]                          = mie_seie ; */
          csr_read_data[S_TIMER_I]                        = mie_stie && mideleg_mti;
          csr_read_data[S_EXT_I]                          = mie_seie  && mideleg_mei;

        end
        CSR_SIP            :
        begin
          /*csr_read_data[S_TIMER_I]                        = mip_stip;
          csr_read_data[S_EXT_I]                          = mip_seip ;  */
          csr_read_data[S_TIMER_I]                        = mip_stip && mideleg_mti ;
          csr_read_data[S_EXT_I]                          = mip_seip && mideleg_mei ;
        end

        CSR_STVAL            :
          csr_read_data =        stval;
        CSR_SSCRATCH         :
          csr_read_data =        sscratch;
        CSR_SEPC             :
          csr_read_data =        sepc;

        CSR_SCAUSE           :
        begin

          csr_read_data =  { scause_int_excep ,59'b0 , scause_code [3:0] };
        end

        CSR_STVEC            :
        begin
          csr_read_data [1:0]                               = stvec_mode ;
          // csr_read_data [0]                              = stvec_mode ;
          csr_read_data[SXLEN-1:2]                          = stvec_base;
        end
      
        CSR_SSTATUS     :
        begin
          /*
           //for virtulazation supprot
            csr_read_data[CSR_MSTATUS_TSR_BIT]                              = mstatus_tsr;
            csr_read_data[CSR_MSTATUS_TW_BIT]                               = mstatus_tw ;
            csr_read_data[CSR_MSTATUS_TVM_BIT]                              = mstatus_tvm;
            csr_read_data[CSR_MSTATUS_UBE_BIT]                              = mstatus_ube ; */

          csr_read_data[CSR_MSTATUS_SIE_BIT]                              = mstatus_sie;
          csr_read_data[CSR_MSTATUS_SPIE_BIT]                             = mstatus_spie;
          csr_read_data[CSR_MSTATUS_SPP ]                                 = mstatus_spp;
          csr_read_data[CSR_MSTATUS_UXL_BIT_HIGH:CSR_MSTATUS_UXL_BIT_LOW] =  (support_user)     ? 2'b10 : 2'b00 ;
          // for memory
          csr_read_data[CSR_MSTATUS_SUM_BIT]                              = mstatus_sum ;
          csr_read_data[CSR_MSTATUS_MXR_BIT]                              = mstatus_mxr ;
        end

    
        // mconfigptr : pointer to configuration data structre
      
        CSR_SATP ,CSR_MCONFIGPTR ,CSR_MENVCFG ,CSR_SENVCFG  , CSR_MCOUNTEREN ,  CSR_SCOUNTEREN    : csr_read_data =        64'b0; //In systems without U-mode, the mcounteren register should not exist.
        //  ” All counters should be implemented, but a legal implementation is to make both the counter and its corresponding event selector be read-only 0.

         CSR_MHPM_EVENT_3 ,  CSR_MHPM_EVENT_4     ,  
    CSR_MHPM_EVENT_5    ,   CSR_MHPM_EVENT_6    ,  
    CSR_MHPM_EVENT_7    ,   CSR_MHPM_EVENT_8   ,  
    CSR_MHPM_EVENT_9   ,   CSR_MHPM_EVENT_10   ,  
     CSR_MHPM_EVENT_11   ,  CSR_MHPM_EVENT_12    ,  
      CSR_MHPM_EVENT_13   ,   CSR_MHPM_EVENT_14   ,  
    CSR_MHPM_EVENT_15  ,  CSR_MHPM_EVENT_16    ,  
    CSR_MHPM_EVENT_17 ,   CSR_MHPM_EVENT_18    ,  
    CSR_MHPM_EVENT_19    ,   CSR_MHPM_EVENT_20    ,  
    CSR_MHPM_EVENT_21    ,   CSR_MHPM_EVENT_22   ,  
    CSR_MHPM_EVENT_23   ,  CSR_MHPM_EVENT_24    ,  
    CSR_MHPM_EVENT_25   ,   CSR_MHPM_EVENT_26   ,  
    CSR_MHPM_EVENT_27   ,   CSR_MHPM_EVENT_28    ,  
    CSR_MHPM_EVENT_29    ,   CSR_MHPM_EVENT_30    ,  
    CSR_MHPM_EVENT_31    ,  
    CSR_MHPM_COUNTER_3   , CSR_MHPM_COUNTER_4   ,
    CSR_MHPM_COUNTER_5   , CSR_MHPM_COUNTER_6   ,
    CSR_MHPM_COUNTER_7   , CSR_MHPM_COUNTER_8   ,
    CSR_MHPM_COUNTER_9   ,  CSR_MHPM_COUNTER_10  ,  
    CSR_MHPM_COUNTER_11  ,  CSR_MHPM_COUNTER_12  ,  
    CSR_MHPM_COUNTER_13  ,  CSR_MHPM_COUNTER_14 ,  
    CSR_MHPM_COUNTER_15  ,   CSR_MHPM_COUNTER_16  ,  
    CSR_MHPM_COUNTER_17  ,  CSR_MHPM_COUNTER_18  ,  
    CSR_MHPM_COUNTER_19  ,  CSR_MHPM_COUNTER_20  ,  
    CSR_MHPM_COUNTER_21  ,   CSR_MHPM_COUNTER_22  ,  
    CSR_MHPM_COUNTER_23  ,  CSR_MHPM_COUNTER_24  ,   
    CSR_MHPM_COUNTER_25  ,  CSR_MHPM_COUNTER_26  ,  
    CSR_MHPM_COUNTER_27  ,  CSR_MHPM_COUNTER_28  ,  
    CSR_MHPM_COUNTER_29  ,  
CSR_MHPM_COUNTER_30  ,  
    CSR_MHPM_COUNTER_31  : csr_read_data = 'b0 ;  


            // mseccfg optional so no need for it 


        default :
        begin
          illegal_read_access   = 1'b1 ;
          csr_read_data =        64'b0;
        end
      endcase
    end  /*----of if condition----*/

  end   /*----of always blocks----*/


  /*----------------  */
  // Sequential process
  //  CSR Write logic
  //csr_enable  :see last always block to know when it is asserted

  /*registers not to be put in write logic */
  /* ------mvendorid ,marchid ,  mimpid  ,mhartid , mconfigptr------ */


  /*------mstatus register-----
  controls hart's current operating state (mie and mpie are the only configurable bits))
   
  sxl , uxl are warl so i think not need to have a regitser as they can written by any vlaue
  mbe,sbe,ube are warl so i think not need to have a regitser as they can written by any vlaue
  tvm are warl so i think not need to have a regitser as they can written by any vlaue*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      mstatus_mie                 <=1'b0;
      mstatus_mpie                <=1'b0;
      mstatus_sie                 <=1'b0;
      mstatus_spie                <=1'b0;
      mstatus_mpp                 <=1'b0;
      mstatus_spp                 <=1'b0;
      //extra add from m-mode due to spike
      mstatus_sxl  <= 2'b10;
      mstatus_uxl  <= 2'b10;
      //for memory
      mstatus_mprv                <=1'b0;
      mstatus_mxr                 <=1'b0;
      mstatus_sum                 <=1'b0 ;

      //for virtulazation supprot
      mstatus_tsr                 <=1'b0;
      mstatus_tw                  <=1'b0;
      mstatus_tvm                 <=1'b0;


      mstatus_sbe                 <=1'b0;
      mstatus_mbe                 <=1'b0 ;
      mstatus_ube                 <=1'b0;
    end

    else if(go_to_trap)
    begin
      // trap to supervisor mode
      if (force_s_delegation)
      begin
        // update sstatus
        mstatus_sie = 1'b0;
        mstatus_spie = mstatus_sie;
        // this can either be user or supervisor mode
        mstatus_spp = current_priv_lvl[0];  //check

      end

      // trap to machine mode
      else if ((current_priv_lvl == PRIV_LVL_M) || no_delegation)
      begin
        // update mstatus
        mstatus_mie   <= 0; //no nested interrupt allowed    // if done in software that will not make problem make it again zero
        // When a trap is taken from privilege mode y into privilege mode x,xPIE is set to the value of x IE; ?? check that
        mstatus_mpie <= mstatus_mie;
        // save the previous privilege mode
        mstatus_mpp = current_priv_lvl;  // check that statement or it is commented
        // mstatus_mpp <= 2'b11;
      end
    end
    else if (mret )
    begin
      // return to the previous privilege level and restore all enable flags // like global interupt enable
      // get the previous machine interrupt enable flag
      mstatus_mie    <= mstatus_mpie;
      mstatus_mpie   <= 1'b1;
      // and xPP is set to the least-privileged supported mode (U if U-mode is implemented, else M)
      //set mpp to user mode
      if(support_user)
        mstatus_mpp   <= PRIV_LVL_U ;
      else
        mstatus_mpp    <= PRIV_LVL_M ;

      // mstatus_mpp  <= (support_user) ? PRIV_LVL_U : PRIV_LVL_M;
      //xPIE is set to 1 >> set mpie to 1
      // If xPP?=M, xRET also sets MPRV=0.
      /*
              if (mstatus_mpp != PRIV_LVL_M) begin
                mstatus_mprv <= 1'b0;
              end  */
    end

    else if (sret)
    begin
      // return the previous supervisor interrupt enable flag
      mstatus_sie  <= mstatus_spie;
      // set spp to user mode
      mstatus_spp  <= 1'b0;
      // set spie to 1
      mstatus_spie <= 1'b1;
    end

    else if (csr_write_access_en && i_riscv_csr_address == CSR_MSTATUS)

    begin

      mstatus_mie    <= csr_write_data[CSR_MSTATUS_MIE_BIT]                             ;
      mstatus_mpie   <= csr_write_data[CSR_MSTATUS_MPIE_BIT]                             ;
      mstatus_sie    <= csr_write_data[CSR_MSTATUS_SIE_BIT]                              ;
      mstatus_spie   <= csr_write_data[CSR_MSTATUS_SPIE_BIT]                             ;
      mstatus_mpp    <= csr_write_data[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] ;
      mstatus_spp    <= csr_write_data[CSR_MSTATUS_SPP] ;

      //for memory
      mstatus_mprv   <=  csr_write_data[CSR_MSTATUS_MPRV_BIT]                            ;
      mstatus_mxr    <= csr_write_data[CSR_MSTATUS_MXR_BIT]                             ;
      mstatus_sum    <= csr_write_data[CSR_MSTATUS_SUM_BIT]                                ;

      //for virtulazation supprot
      mstatus_tsr    <= csr_write_data[CSR_MSTATUS_TSR_BIT]                             ;
      mstatus_tw     <= csr_write_data[CSR_MSTATUS_TW_BIT]                                ;
      //mstatus_tvm  <= csr_write_data[CSR_MSTATUS_TVM_BIT]                            ;

      //mstatus_sbe  <= csr_write_data[CSR_MSTATUS_SBE_BIT]                              ;
      //mstatus_mbe  <=csr_write_data[CSR_MSTATUS_MBE_BIT]                               ;
      //mstatus_ube  <= csr_write_data[CSR_MSTATUS_UBE_BIT]                              ;


      // this register has side-effects on other registers, flush the pipeline
      o_riscv_csr_flush  <= 1'b1;  // >> ?? need to be checked
    end


    /*-----SSTATUS-----*/
    else if (csr_write_access_en && i_riscv_csr_address == CSR_SSTATUS)

    begin

      mstatus_sie    <= csr_write_data[CSR_MSTATUS_SIE_BIT]                              ;
      mstatus_spie   <= csr_write_data[CSR_MSTATUS_SPIE_BIT]                             ;
      mstatus_spp    <= csr_write_data[CSR_MSTATUS_SPP] ;
      //for memory
      mstatus_mxr    <= csr_write_data[CSR_MSTATUS_MXR_BIT]                             ;
      mstatus_sum    <= csr_write_data[CSR_MSTATUS_SUM_BIT]                                ;

    end

  end



  /*------mie register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      //mie
      mie_meie                    <=1'b0 ;
      mie_mtie                    <=1'b0 ;
      // mie_msie_cs                 <=1'b0 ;
      mie_seie                    <=1'b0 ;
      mie_stie                    <=1'b0 ;
      // mie_ssie_cs                 <=1'b0 ;
    end
    else if (csr_write_access_en && i_riscv_csr_address == CSR_MIE )

    begin

      // mie_msie_cs          <= csr_write_data[M_SOFT_I];             //3
      mie_mtie           <= csr_write_data[M_TIMER_I];    //7
      mie_meie           <= csr_write_data[M_EXT_I];      //11
      // mie_ssie_cs         <= csr_write_data[S_SOFT_I];
      mie_stie           <= csr_write_data[S_TIMER_I];
      mie_seie           <= csr_write_data[S_EXT_I];
    end
    /*------sie register-----*/
    else if (csr_write_access_en && i_riscv_csr_address == CSR_SIE )
    begin
      // the mideleg makes sure only delegate-able register (and therefore also only implemented registers) are written
      if (support_supervisor)
      begin
        // mie_msie_cs           <= csr_write_data[M_SOFT_I];             //3
        // mie_mtie           <= csr_write_data[M_TIMER_I];    //7
        //mie_mtie            <= 0 ;
        // mie_meie           <= csr_write_data[M_EXT_I];      //11
        //  mie_meie           <= 0 ;      //11
        // mie_ssie_cs           <= csr_write_data[S_SOFT_I];
        mie_stie             <= (!mideleg_mti)? mie_stie : csr_write_data[S_TIMER_I];
        mie_seie             <= (!mideleg_mei)? mie_seie : csr_write_data[S_EXT_I];
      end
    end   // end of always block
  end


  /*------mip register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin

      //mip
      mip_meip                    <=1'b0 ;
      mip_mtip                    <=1'b0 ;
      // mip_msip_cs                 <=1'b0 ;
      mip_seip                    <=1'b0 ;
      mip_stip                    <=1'b0 ;
      //  mip_ssip_cs                 <=1'b0 ;
    end

    else if (csr_write_access_en && i_riscv_csr_address == CSR_MIP )

    begin

      /* mip_mtip         <= csr_write_data[M_TIMER_I];     //7
       mip_meip         <= csr_write_data[M_EXT_I];  */     //11

      mip_mtip         <=  mip_mtip;     //7
      mip_meip         <=  mip_meip ;

      mip_stip         <= csr_write_data[S_TIMER_I];
      mip_seip         <= csr_write_data[S_EXT_I];
    end

    /*---sip---*/
    /*   else if (csr_write_access_en && i_riscv_csr_address == CSR_SIP )

         // only the supervisor software interrupt is write-able, iff delegated

             begin
                        // mip_msip_cs <= csr_write_data[M_SOFT_I];           //3
                        // mip_mtip         <= csr_write_data[M_TIMER_I];     //7
                        // mip_mtip         <= 0; 
                       // mip_meip         <= csr_write_data[M_EXT_I];         //11
                       //  mip_meip         <=0 ;  
                       // mip_ssip_cs      <= csr_write_data[S_SOFT_I]; 
                         mip_stip         <= csr_write_data[S_TIMER_I]; 
                         mip_seip         <= csr_write_data[S_EXT_I]; 
             end    */

    /*---check---*/  //trap is taken in m mode
    else
    begin
      mip_meip                    <= mip_external_next ;
      mip_mtip                    <= mip_timer_next;
    end
  end   /* end of always block


    /*------mtvec register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      //mtvec
      mtvec_base                  <= 'b10010;  // it is 62 bits
      mtvec_mode                  <= 2'b00 ;
      // set to boot address + direct mode + 4 byte offset which is the initial trap
      // mtvec_rst_load_q         <= 1'b1;
      // mtvec_cs                 <= '0;
    end
    else if (csr_write_access_en && i_riscv_csr_address == CSR_MTVEC)

    begin
      mtvec_base    <= csr_write_data[63:2];
      // mtvec_mode <= i_riscv_csr_wdata[1:0];
      mtvec_mode  <= csr_write_data[0] ;

      if (csr_write_data[0])  //we are in vector mode, as LSB <=1
      begin
        mtvec_base   <= {csr_write_data[63:8] , 6'b0 };
        mtvec_mode   <=  csr_write_data[0] ;
      end

    end

  end   /*---of always block*/


  /*------stvec register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      //mtvec
      stvec_base                  <= 'b11001;  // it is 62 bits
      stvec_mode                  <= 2'b00 ;
      // set to boot address + direct mode + 4 byte offset which is the initial trap
      // mtvec_rst_load_q         <= 1'b1;
      // mtvec_cs                 <= '0;
    end
    else if (csr_write_access_en && i_riscv_csr_address == CSR_STVEC)

    begin
      stvec_base    <= csr_write_data[63:2];
      // mtvec_mode <= i_riscv_csr_wdata[1:0];
      stvec_mode  <= csr_write_data[0] ;  //assign one bit to 2 bits >> check that

      if (csr_write_data[0])  //we are in vector mode, as LSB <=1
      begin
        stvec_base   <= {csr_write_data[63:8] , 6'b0 };
        stvec_mode   <=  csr_write_data[0] ;
      end

    end
  end   /*---of always block*/


  /*------medeleg register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      medeleg                     <= 'b0 ;  // it is 16 bit

    //For exceptions that cannot occur in less privileged modes, the corresponding medeleg bits should
    // be read-only zero. In particular, medeleg[11] is read-only zero.
    else if (csr_write_access_en && i_riscv_csr_address == CSR_MEDELEG)
      medeleg <=  {csr_write_data[15:11],1'b0,csr_write_data[9:0]};

  end  /*---of always block*/


  /*------mideleg register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin

      mideleg_mei                 <=1'b0 ;
      mideleg_mti                 <=1'b0 ;
      // mideleg_msi_cs                  <=1'b0 ;
      mideleg_sei                 <=1'b0 ;
      mideleg_sti                 <=1'b0 ;
      // mideleg_ssi_cs                  <=1'b0 ;
    end
    else if (csr_write_access_en && i_riscv_csr_address == CSR_MIDELEG)
    begin

      // machine interrupt delegation register
      // we do not support user interrupt delegation
      if (support_supervisor)
      begin

        // mideleg_msi_cs   <=  csr_write_data[M_SOFT_I]     ;
        //  mideleg_mti   <=  csr_write_data[M_TIMER_I]      ;
        //  mideleg_mei   <=  csr_write_data[M_EXT_I]        ;
        //  mideleg_ssi_cs   <=  csr_write_data[S_SOFT_I]      ;
        mideleg_sti   <=  csr_write_data[S_TIMER_I]       ;
        mideleg_sei   <=  csr_write_data[S_EXT_I]        ;
      end
    end

  end   /*---of always block*/


  /*------mepc register-----
  --- (address of interrupted instruction)*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      mepc <= 64'b0;
    else if(go_to_trap)
    begin
      if(current_priv_lvl == PRIV_LVL_M)
        mepc <= i_riscv_csr_pc ;

      else if ( (support_supervisor)  &&
                (current_priv_lvl == PRIV_LVL_S) &&
                (!medeleg[execption_cause[3:0]] || !mideleg[interrupt_cause[3:0]]))

        mepc <= i_riscv_csr_pc ;
    end

    else if (csr_write_access_en && (i_riscv_csr_address == CSR_MEPC) )

      mepc <= {csr_write_data[63:1],1'b0};
    //mepc <= {csr_write_data[63:2],2'b00};    check is it 2'b00 or 1'b0 accordng to ialign

  end   /*---of always block*/


  /*------spec register-----
  --- (address of interrupted instruction)*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      sepc                        <= 64'b0;

    else if(go_to_trap && support_supervisor && current_priv_lvl == PRIV_LVL_S )
      sepc         <= i_riscv_csr_pc ;

    else if (csr_write_access_en && i_riscv_csr_address == CSR_SEPC )

      sepc <= {csr_write_data[63:1],1'b0};
    //sepc <= {csr_write_data[63:2],2'b00};    check is it 2'b00 or 1'b0 accordng to ialign

  end   /*---of always block*/


  /*------mscratch register-----
  (dedicated for use by machine code) */
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      mscratch                    <= 64'b0;

    else if (csr_write_access_en && i_riscv_csr_address == CSR_MSCRATCH)

      mscratch <= csr_write_data;


  end   /*---of always block*/

  /*------sscratch register-----
  (dedicated for use by machine code) */
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      sscratch                    <= 64'b0;

    else if (csr_write_access_en && i_riscv_csr_address == CSR_SSCRATCH)

      sscratch <= csr_write_data;


  end   /*---of always block*/


  /*------mtval register-----
  (exception-specific information to assist software in handling trap)*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      mtval  <= 64'b0;

    else if( (i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned) && (current_priv_lvl == PRIV_LVL_M)  )
      mtval <= i_riscv_csr_addressALU  ;
    else if( illegal_total && (current_priv_lvl == PRIV_LVL_M)  )
      mtval <= (i_riscv_csr_is_compressed)? { {48{1'b0}}, i_riscv_csr_cinst }:{ {32{1'b0}}, i_riscv_csr_inst }  ;
    else if (csr_write_access_en && i_riscv_csr_address == CSR_MTVAL)
      mtval    <= csr_write_data;

  end   /*---of always block*/


  /*------stval register-----
  (exception-specific information to assist software in handling trap)*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      stval <= 64'b0;
    // trap to supervisor mode
    else if(i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned && support_supervisor && current_priv_lvl == PRIV_LVL_S)
      stval <= i_riscv_csr_addressALU;

    else if(illegal_total  && support_supervisor && current_priv_lvl == PRIV_LVL_S)
      stval <= (i_riscv_csr_is_compressed)? { {48{1'b0}}, i_riscv_csr_cinst }:{ {32{1'b0}}, i_riscv_csr_inst }  ;

    else if (csr_write_access_en && i_riscv_csr_address == CSR_STVAL)
      stval    <= csr_write_data;

  end   /*---of always block*/

  /*
   
  //------gotoTrap register-----        
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst) 
     begin    
        if (i_riscv_csr_rst)  
                  o_riscv_csr_gotoTrap_cs        <= 0   ;
      else if(go_to_trap ) 
                 o_riscv_csr_gotoTrap_cs <=1 ;
              
      else    o_riscv_csr_gotoTrap_cs <= 0 ;                 
                 
   
     end   
   
  */
  always_comb
  begin
    if(illegal_total | i_riscv_csr_ecall_u |i_riscv_csr_ecall_s | i_riscv_csr_ecall_m  | i_riscv_csr_inst_addr_misaligned  | i_riscv_csr_load_addr_misaligned | i_riscv_csr_store_addr_misaligned)
      is_exception = 1'b1 ;
    else
      is_exception = 1'b0 ;
  end

  /*------returnfromTrap register-----*/
  always_comb
  begin
    if (mret )

      o_riscv_csr_returnfromTrap_cs  = 1 ;
    else if (sret)
      o_riscv_csr_returnfromTrap_cs = 2 ;
    else
      o_riscv_csr_returnfromTrap_cs =0 ;  //to go low not to save its previous value when asserted make problem

  end   /*---of always block*/



  /*------priv_lvl register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      current_priv_lvl <= PRIV_LVL_M;
    else if(go_to_trap)
    begin
      current_priv_lvl <= trap_to_priv_lvl;
    end
    else if (mret)
      // restore the previous privilege level
      current_priv_lvl       <= mstatus_mpp;
    else if (sret)
      // restore the previous privilege level
      current_priv_lvl    <= {1'b0, mstatus_spp};  //check

  end   /*---of always block---*/


  /*------mcause register-----
  --- (indicates cause of trap(either interrupt or exception)) --- */

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if     (i_riscv_csr_rst)
    begin
      mcause_code                 <= 4'b0000;
      mcause_int_excep            <= 1'b0 ;
    end

    else if( go_to_trap && ((current_priv_lvl == PRIV_LVL_M) || no_delegation))      //  trap to machine mode
    begin

      if(valid)
      begin
        if(M_ext_int_pend)
        begin
          mcause_code      <= M_EXT_I;
          mcause_int_excep <= 'b1;
        end
        else if(M_timer_int_pend)
        begin
          mcause_code      <= M_TIMER_I;
          mcause_int_excep <= 'b1;
        end
      end

      else if(illegal_total)
      begin
        mcause_code      <= ILLEGAL_INSTRUCTION;
        mcause_int_excep <= 0 ;
        // if (medeleg[2] )
      end
      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        mcause_code       <= INSTRUCTION_ADDRESS_MISALIGNED;
        mcause_int_excep  <= 0;
        // if (medeleg[0] )
      end
      else if(i_riscv_csr_ecall_m)
      begin
        mcause_code       <= ECALL_M;
        mcause_int_excep <= 0;
        //if (medeleg[11] )
      end
      else if(i_riscv_csr_ecall_s)
      begin
        mcause_code       <= ECALL_S;
        mcause_int_excep <= 0;
        //if (medeleg[9] )
      end
      else if(i_riscv_csr_ecall_u)
      begin
        mcause_code       <= ECALL_U;
        mcause_int_excep <= 0;
        //  if (medeleg[8] ) */
      end
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        mcause_code       <= LOAD_ADDRESS_MISALIGNED;
        mcause_int_excep <= 0;
        //if (medeleg[4] )
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        mcause_code      <= STORE_ADDRESS_MISALIGNED;
        mcause_int_excep  <= 0;
        //if (medeleg[6] )
      end
      // else if(software_interrupt_pending)
      // begin
      //  mcause_code       <= MACHINE_SOFTWARE_INTERRUPT;
      //  mcause_int_excep <= 1;
      //  if (mideleg_msi_cs)
      //end

    end   /*---of gototrap---*/
    else if (csr_write_access_en && i_riscv_csr_address == CSR_MCAUSE)
    begin

      mcause_int_excep <= csr_write_data[63];
      mcause_code      <= csr_write_data[3:0];
    end


  end    /*---of always block---*/

  /*------scause register-----
  --- (scause cause of trap(either interrupt or exception)) --- */


  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if     (i_riscv_csr_rst)
    begin

      scause_code                 <= 4'b0000;
      scause_int_excep            <= 1'b0 ;
    end

    else if( go_to_trap && support_supervisor && current_priv_lvl == PRIV_LVL_S && (medeleg[execption_cause[3:0]] || mideleg[interrupt_cause[3:0]]))   // trap to supervisor mode
    begin
      if (valid)
      begin
        //  if (support_supervisor && trap_to_priv_lvl == PRIV_LVL_S) begin
        if(S_ext_int_pend)
        begin
          scause_code      <= S_EXT_I;
          scause_int_excep <= 1;
          // if (mideleg_mei )
        end
        else if(S_timer_int_pend)
        begin
          scause_code      <= S_TIMER_I;
          scause_int_excep <= 1;
          // if (mideleg_mti )
        end
      end
      else if(illegal_total)
      begin
        scause_code      <= ILLEGAL_INSTRUCTION;
        scause_int_excep <= 0 ;
        // if (medeleg[2] )
      end
      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        scause_code       <= INSTRUCTION_ADDRESS_MISALIGNED;
        scause_int_excep  <= 0;
        // if (medeleg[0] )
      end

      else if(i_riscv_csr_ecall_s)
      begin
        scause_code       <= ECALL_S;
        scause_int_excep <= 0;
        //if (medeleg[9] )
      end
      else if(i_riscv_csr_ecall_u)
      begin
        scause_code       <= ECALL_U;
        scause_int_excep <= 0;
        // if (medeleg[8] ) */
      end
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        scause_code       <= LOAD_ADDRESS_MISALIGNED;
        scause_int_excep <= 0;
        //if (medeleg[4] )
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        scause_code      <= STORE_ADDRESS_MISALIGNED;
        scause_int_excep  <= 0;
        //if (medeleg[6] )
      end
    end   /*---of gototrap---*/
    else if (csr_write_access_en && i_riscv_csr_address == CSR_SCAUSE)
    begin

      scause_int_excep <= csr_write_data[63];
      scause_code      <= csr_write_data[3:0];
    end


  end    /*---of always block---*/



  /* missing FF
  always @() begin
     satp, scoubteren ;
  end*/


  /*----------------  */
  // CSR OP Select Logic
  /* ---------------- */

  always_comb
  begin : csr_op_logic

    csr_write_data = i_riscv_csr_wdata;
    //added from m-mode code
    csr_write_en    = (!i_riscv_csr_globstall)? 1'b1:1'b0;
    csr_read_en  = 1'b1;
    mret      = 1'b0;
    sret      = 1'b0;

    case (i_riscv_csr_op)
      CSR_WRITE :
        csr_write_data = i_riscv_csr_wdata;
      CSR_SET :
        csr_write_data = i_riscv_csr_wdata | csr_read_data;
      CSR_CLEAR :
        csr_write_data = (~i_riscv_csr_wdata) & csr_read_data;
      CSR_READ :
        csr_write_en    = 1'b0 ;
      SRET:
      begin
        // the return should not have any write or read side-effects
        csr_write_en   = 1'b0;
        csr_read_en = 1'b0;
        sret     = 1'b1; // signal a return from supervisor mode
      end
      MRET:
      begin
        // the return should not have any write or read side-effects
        csr_write_en   = 1'b0;
        csr_read_en = 1'b0;
        mret     = 1'b1; // signal a return from machine mode
      end

      default:
      begin
        csr_write_en   = 1'b0;
        csr_read_en = 1'b0;
      end
    endcase
    

  end




  /*----------------  */
  // output mux
  /* ---------------- */
  always_comb
  begin : csr_read_out_process  //reading is done comb


    o_riscv_csr_rdata = csr_read_data;

  end



  // update priv level
  always_comb
  begin
    if (go_to_trap)
    begin
      if  ( (support_supervisor && is_interrupt && mideleg[interrupt_cause[3:0]]) ||
            ( (is_exception && medeleg[execption_cause[3:0]] ) ) )  //~is_interrupt = is_exception
      begin
        if (current_priv_lvl == PRIV_LVL_M)
          trap_to_priv_lvl = PRIV_LVL_M;
        else
          trap_to_priv_lvl = PRIV_LVL_S;
      end
    end
    else
      trap_to_priv_lvl = PRIV_LVL_M;
  end

  always_comb
  begin
    // -----------------
    // Interrupt Control
    // -----------------

    if (mie_stie && mip_stip)

    begin
      interrupt_go = 1;
      S_timer_int_pend = 1 ;
      interrupt_cause = S_TIMER_I ;

    end
    // Supervisor External Interrupt
    // The logical-OR of the software-writable bit and the signal from the external interrupt controller is
    // used to generate external interrupts to the supervisor
    else if ( mie_seie && mip_seip)
    begin
      interrupt_go = 1;
      S_ext_int_pend = 1 ;
      interrupt_cause = S_EXT_I;
    end

    else if (mip_mtip && mie_mtie)

    begin
      interrupt_go = 1;
      M_timer_int_pend = 1 ;
      interrupt_cause = M_TIMER_I;
    end

    // Machine Timer Interrupt

    else if (mip_meip && mie_meie)

    begin
      interrupt_go = 1;
      M_ext_int_pend = 1 ;
      interrupt_cause = M_EXT_I;
    end

    // Machine Mode External Interrupt

    else
    begin
      interrupt_go = 0 ;
      M_ext_int_pend = 0 ;
      interrupt_cause = M_EXT_I;
    end
  end

  // -----------------
  // execption Control
  // -----------------
  always_comb
  begin

    if(illegal_total)
      execption_cause = ILLEGAL_INSTRUCTION ;

    else if(i_riscv_csr_inst_addr_misaligned)
      execption_cause = INSTRUCTION_ADDRESS_MISALIGNED;

    else if(i_riscv_csr_ecall_m)
      execption_cause = ECALL_M;

    else if (i_riscv_csr_ecall_s)
      execption_cause = ECALL_S;

    else if (i_riscv_csr_ecall_u)
      execption_cause = ECALL_U;

    else if (i_riscv_csr_load_addr_misaligned)
      execption_cause = LOAD_ADDRESS_MISALIGNED;

    else if (i_riscv_csr_store_addr_misaligned)
      execption_cause = STORE_ADDRESS_MISALIGNED;

  end



  // An interrupt i will be taken if bit i is set in both mip and mie, and if interrupts are globally enabled.
  // By default, M-mode interrupts are globally enabled if the hart’s current privilege mode  is less
  // than M, or if the current privilege mode is M and the MIE bit in the mstatus register is set.
  // All interrupts are masked in debug mode
  assign interrupt_global_enable =  ((mstatus_mie & (current_priv_lvl == PRIV_LVL_M))
                                     || (current_priv_lvl != PRIV_LVL_M));


  always_comb
  begin
    if (interrupt_go && interrupt_global_enable )   // =1 menas it is an interuopt
    begin
      // However, if bit i in mideleg is set, interrupts are considered to be globally enabled
      //if the hart’s current privilege mode equals the delegated privilege mode (S or U)
      //  and that mode’s interrupt enable bit (SIE or UIE in mstatus) is set ,
      //or if the current privilege mode is less than the delegated privilege mode.
      if (mideleg[interrupt_cause[3:0]]) //if delegated so cant take action of trap if below conditions are satified
        // but if not delegated so action of trap take directly without that check
      begin
        if (  (support_supervisor && mstatus_sie && current_priv_lvl == PRIV_LVL_S) ||
              (support_user && current_priv_lvl == PRIV_LVL_U) )
          valid = 1'b1;
        else
          valid = 1'b0;
      end
      else
      begin
        valid = 1'b1;
      end
    end
    else
      valid = 1'b0;
  end


  /*********************************************** عشوائيات *********************************************************/
  logic sel ;

  always_comb
  begin
    if (o_riscv_csr_flush)
      sel = 1 ;   // for mux input to it pc+4 from mem stage
    else
      sel = 0 ;  // for mux input to it output from previos mux
  end

endmodule


  /*  
      logic             external_interrupt_pending_m  ;
      logic             timer_interrupt_pending_m     ;
      assign external_interrupt_pending_m =  (mstatus_mie && mie_meie && (mip_meip))? 1:0; //machine_interrupt_enable + machine_external_interrupt_enable + machine_external_interrupt_pending must all be high
      assign software_interrupt_pending_m = mstatus_mie && mie_msie_cs && mip_msip_cs;  //machine_interrupt_enable + machine_software_interrupt_enable + machine_software_interrupt_pending must all be high
      assign timer_interrupt_pending_m    = (mstatus_mie && mie_mtie && mip_mtip)? 1:0; //machine_interrupt_enable + machine_timer_interrupt_enable + machine_timer_interrupt_pending must all be high
      assign is_interrupt                 = (external_interrupt_pending_m  || timer_interrupt_pending_m) ? 1:0  ;*/ // || software_interrupt_pending_m ;    


  /* 
    logic [MXLEN-1:0] mtinst_cs   ;
    always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst )
    begin
      if (i_riscv_csr_rst)
        mtinst_cs <= 'b0 ;
      else if (csr_write_access_en && i_riscv_csr_address == CSR_MTINST)
        //  mtinst <= (is_compressed)? i_riscv_csr_inst ;
        mtinst_cs <=  i_riscv_csr_inst ;
    end
  */
