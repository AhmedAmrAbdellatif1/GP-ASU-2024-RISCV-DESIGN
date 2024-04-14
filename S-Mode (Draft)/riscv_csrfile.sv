


module riscv_csrfile

  # ( parameter MXLEN              = 64   ,
      parameter SXLEN              = 64   ,
      parameter support_supervisor = 1    ,
      parameter support_user       = 1      )
    (
      //csr_instrcution
      input                     i_riscv_csr_clk ,
      input                     i_riscv_csr_rst ,
      input          [11:0]     i_riscv_csr_address ,
      input          [2:0]      i_riscv_csr_op ,
      input        [MXLEN-1:0]  i_riscv_csr_wdata ,
      // Interrupts
      input logic               i_riscv_csr_external_int, //interrupt from external source
      //input wire i_riscv_csr_software_interrupt, //interrupt from software (inter-processor interrupt)
      input logic               i_riscv_csr_timer_int, //interrupt from timer
      /// Exceptions ///
      input logic  [63:0]        i_riscv_csr_pc ,
      input logic  [63:0]       i_riscv_csr_addressALU, //address  from ALU  used in load/store/jump/branch)

      input logic  [31:0]       i_riscv_csr_inst  ,
      input logic  [15:0]       i_riscv_csr_cinst  ,
      input logic               i_riscv_csr_illegal_inst, //illegal instruction (From decoder) ??check if can come from csr
      input logic               i_riscv_csr_ecall_u ,        //ecall instruction from user mode
      input logic               i_riscv_csr_ecall_s ,        //ecall instruction from s mode
      input logic               i_riscv_csr_ecall_m ,        //ecall instruction from m mode
      input logic               i_riscv_csr_inst_addr_misaligned ,
      input logic               i_riscv_csr_load_addr_misaligned ,
      input logic               i_riscv_csr_store_addr_misaligned ,
      //csr_instrcution
      output logic [MXLEN-1:0]  o_riscv_csr_rdata ,
      output logic              o_riscv_csr_sideeffect_flush ,
      /// Exceptions ///
      output logic [MXLEN-1:0]  o_riscv_csr_return_address, //mepc CSR  (address to retrun after excuting trap) to continue excuting normal instruction
      output logic [MXLEN-1:0]  o_riscv_csr_trap_address,   //mtvec CSR
      // Trap-Handler  // Interrupts/Exceptions
      output logic              o_riscv_csr_gotoTrap_cs, //high before going to trap (if exception/interrupt detected)  // Output the exception PC to PC Gen, the correct CSR (mepc, sepc) is set accordingly
      output logic    [1:0]     o_riscv_csr_returnfromTrap_cs , //high before returning from trap (via mret)

      output logic    [1:0]     o_riscv_csr_privlvl  ,
      output logic              o_riscv_csr_flush  ,

      //addition from m-mode
      input  logic             i_riscv_csr_flush  ,
      input  logic             i_riscv_csr_globstall ,
      input  logic             i_riscv_csr_is_compressed,

      output logic  [SXLEN-1:0] o_riscv_csr_sepc,
      output logic              o_riscv_csr_tsr
      // input wire writeback_change_pc, //high if writeback will issue change_pc (which will override this stage
    );
  //CSR addresses
  //machine info
  localparam CSR_MVENDORID  = 12'hF11,
             CSR_MARCHID    = 12'hF12,
             CSR_MIMPID     = 12'hF13,
             CSR_MHARTID    = 12'hF14,
             //machine trap setup
             CSR_MSTATUS    = 12'h300,
             CSR_MISA       = 12'h301,
             CSR_MIE        = 12'h304,
             CSR_MTVEC      = 12'h305,
             //machine trap handling
             CSR_MSCRATCH   = 12'h340,
             CSR_MEPC       = 12'h341,
             CSR_MCAUSE     = 12'h342,
             CSR_MTVAL      = 12'h343,
             CSR_MIP        = 12'h344  ,
             CSR_MEDELEG    = 12'h302,
             CSR_MIDELEG    = 12'h303,
             // CSR_MCOUNTEREN = 12'h306 ;
             CSR_MCONFIGPTR = 12'hF15 ,
             CSR_MTINST     = 12'h34A     ,
             // Supervisor Mode CSRs
             CSR_SSTATUS    = 12'h100,
             CSR_SIE        = 12'h104,
             CSR_STVEC      = 12'h105,
             CSR_SCOUNTEREN = 12'h106,
             CSR_SSCRATCH   = 12'h140,
             CSR_SEPC       = 12'h141,
             CSR_SCAUSE     = 12'h142,
             CSR_STVAL      = 12'h143,
             CSR_SIP        = 12'h144 ;

  // CSR_SATP     = 12'h180

  /*CSR_MCYCLE         = 12'hB00,
  CSR_MCYCLEH          = 12'hB80,
  CSR_MINSTRET   = 12'hB02,
  CSR_MINSTRETH  = 12'hB82, */

  //CSR operation type
  localparam CSR_WRITE      = 3'b001 ,
             CSR_SET        = 3'b010 ,
             CSR_CLEAR      = 3'b011 ,
             CSR_READ       = 3'b101 ,
             SRET           = 3'b110 ,
             MRET           = 3'b111 ;

  localparam PRIV_LVL_U    =  2'b00 ,
             PRIV_LVL_S    =  2'b01 ,
             PRIV_LVL_M    =  2'b11 ;

  //interupts
  //  localparam  S_SOFT_I     =  1  ;
  //  localparam  M_SOFT_I     =  3  ;
  localparam  S_TIMER_I    =  5  ,
              M_TIMER_I    =  7  ,
              S_EXT_I      =  9  ,
              M_EXT_I      =  11 ;

  //exceptions
  localparam INSTRUCTION_ADDRESS_MISALIGNED = 0  ,
             ILLEGAL_INSTRUCTION            = 2  ,
             LOAD_ADDRESS_MISALIGNED        = 4  ,
             STORE_ADDRESS_MISALIGNED       = 6  ,
             ECALL_U                        = 8  ,
             ECALL_S                        = 9  ,
             ECALL_M                        = 11 ;

  localparam  CSR_MSTATUS_SIE_BIT           = 1 ,
              CSR_MSTATUS_MIE_BIT           = 3 ,
              CSR_MSTATUS_SPIE_BIT          = 5 ,
              CSR_MSTATUS_UBE_BIT           = 6 ,
              CSR_MSTATUS_MPIE_BIT          = 7 ,
              CSR_MSTATUS_SPP               = 8 ,

              CSR_MSTATUS_MPP_BIT_LOW       = 11 ,
              CSR_MSTATUS_MPP_BIT_HIGH      = 12 ,
              CSR_MSTATUS_MPRV_BIT          = 17 ,
              CSR_MSTATUS_SUM_BIT           = 18 ,
              CSR_MSTATUS_MXR_BIT           = 19 ,
              CSR_MSTATUS_TVM_BIT           = 20 ,
              CSR_MSTATUS_TW_BIT            = 21 ,
              CSR_MSTATUS_TSR_BIT           = 22 ,

              CSR_MSTATUS_UXL_BIT_LOW       = 32 ,
              CSR_MSTATUS_UXL_BIT_HIGH      = 33 ,
              CSR_MSTATUS_SXL_BIT_LOW       = 34 ,

              CSR_MSTATUS_SXL_BIT_HIGH      = 35 ,

              CSR_MSTATUS_SBE_BIT           = 36 ,
              CSR_MSTATUS_MBE_BIT           = 37 ;


  localparam logic [MXLEN-1 :0] ISA_CODE =
             (1                 <<  0)  // A - Atomic Instructions extension
             | (1                 <<  2)  // C - Compressed extension
             | (1                 <<  8)  // I - RV32I/64I/128I base ISA
             //9-11 are reserved
             | (1                 << 12)  // M - Integer Multiply/Divide extension
             | (1                 << 18)  // S - Supervisor mode implemented
             | (1                 << 20)  // U - User mode implemented
             | (0                 << 62)  // M-XLEN
             | (1                 << 63); // M-XLEN




  logic   [1:0]     priv_lvl_cs  ;
  // CSR register bits   //only we dont implement whole register width if there are bits (registers) not useful  >> whole registers are implemnted :
  /*mepc , mscratch, mtval    */

  logic [MXLEN-1:0] mepc_cs  ;     //machine exception i_pc (address of interrupted instruction)
  logic [MXLEN-1:0] mscratch_cs  ; //dedicated for use by machine code
  logic [MXLEN-1:0] mtval_cs  ;//exception-specific infotmation to assist software in handling trap

  /*----------------  */
  //     mtvec
  /* ---------------- */
  logic [MXLEN-3:0] mtvec_base_cs   ;//address of pc taken after returning from Trap (via MRET)
  logic   [1:0]     mtvec_mode_cs  ;        //vector mode addressing >> vectored or direct
  // logic          mtvec_mode_cs  ;        //only one bit as 2 bits if they are reserved and we dont care about it >> also check it

  /*----------------  */
  //     mstatus
  /* ---------------- */
  logic             mstatus_sie_cs ;             //  Supervisor Interrupt Enable
  logic             mstatus_mie_cs ;             //Machine Interrupt Enable
  logic             mstatus_spie_cs ;            // Supervisor Previous Interrupt Enable
  logic             mstatus_ube_cs ;
  logic             mstatus_mpie_cs ;            //Machine Previous Interrupt Enable
  logic             mstatus_spp_cs ;
  logic   [1:0]     mstatus_mpp_cs ;
  //both used for FPU and user extensions and we dont support both
  //logic [1:0]    mstatus_vs_cs ;
  //logic [1:0]     mstatus_fs_cs ;
  //logic [1:0]     mstatus_xs_cs ;
  // logic          mstatus_sd_cs ;
  //for memory
  logic             mstatus_mprv_cs ;
  logic             mstatus_sum_cs ;
  logic             mstatus_mxr_cs ;
  //virtualization support
  logic             mstatus_tvm_cs ;
  logic             mstatus_tw_cs ;
  logic             mstatus_tsr_cs;
  //base isa control
  logic   [1:0]     mstatus_uxl_cs ;
  logic   [1:0]     mstatus_sxl_cs ;
  logic             mstatus_sbe_cs ;
  logic             mstatus_mbe_cs ;

  /*----------------  */
  //     mie
  /* ---------------- */
  logic             mie_meie_cs  ; //machine external interrupt enable
  logic             mie_mtie_cs ; //machine timer interrupt enable
  logic             mie_seie_cs ; //supervisor external interrupt enable
  logic             mie_stie_cs ; //Supervisor timer interrupt enable
  //logic           mie_msie_cs ; //machine software interrupt enable
  //logic           mie_ssie_cs ; //Supervisor software interrupt enable

  /*----------------  */
  //     mip
  /* ---------------- */
  logic             mip_meip_cs ; //machine external interrupt pending
  logic             mip_mtip_cs ; //machine timer interrupt pending
  logic             mip_seip_cs ; //supervisor external interrupt pending
  logic             mip_stip_cs ; //supervisor timer interrupt pending
  //logic           mip_msip_cs ; //machine software interrupt pending
  // logic           mip_ssip_cs ; //supervisor software interrupt pending


  /*----------------  */
  //      mcause
  /* ---------------- */
  logic             mcause_int_excep_cs ; //interrupt(1) or exception(0)
  logic  [3:0]      mcause_code_cs ; //indicates event that caused the trap  //as max value  =16

  /*----------------  */
  //      medeleg
  /* ---------------- */  // >> need to checked

  logic  [15:0]     medeleg_cs ;   // as we have exception until number 16 only but each exception has sepefic FF so we need 16 FF

  /*----------------  */
  //      mideleg
  /* ---------------- */    //>>need to be checked
  logic             mideleg_mei_cs ; //machine external interrupt delegation
  logic             mideleg_mti_cs ; //machine timer interrupt delegation
  logic             mideleg_sei_cs ; //supervisor external interrupt delegation
  logic             mideleg_sti_cs ; //Supervisor timer interrupt delegation
  //logic           mideleg_ssi_cs ; //Supervisor software interrupt delegation
  //logic           mideleg_msi_cs ;  //machine software interrupt delegation

  /*-------S-Mode register--------*/

  /*stval register */
  logic [SXLEN-1:0] stval_cs;
  /*sscratch register */
  logic [SXLEN-1:0] sscratch_cs;
  /*sepc register */
  logic [SXLEN-1:0] sepc_cs ;
  /*scause register */
  logic             scause_int_excep_cs  ; //interrupt(1) or exception(0)
  logic  [3:0]      scause_code_cs     ; //indicates event that caused the trap  //as max value  =16
  /*stvec register */
  logic [SXLEN-3:0] stvec_base_cs   ;//address of pc taken after returning from Trap (via MRET)
  logic   [1:0]     stvec_mode_cs ;        //vector mode addressing >> vectored or direct
  // logic          stvec_mode_cs , mtvec_mode_ns ;        //only one bit as 2 bits if they are reserved and we dont care about it >> also check it
  /*----------------  */
  // Internal Signals
  /* ---------------- */

  logic             external_interrupt_pending_m ;
  logic             timer_interrupt_pending_m ;
  logic             is_interrupt ;
  logic             is_exception ;
  logic             is_trap ;
  logic             go_to_trap ;
  logic             illegal_csr_priv ,illegal_csr_write , illegal_read_csr ;
  logic             illegal_csr , csr_we_int;
  logic [MXLEN-1:0] csr_wdata ;
  logic [MXLEN-1:0] csr_rdata_int ;
  logic             mret      ;
  logic             sret      ;
  logic             csr_we    ;
  logic             csr_read  ;

  logic [1:0] trap_to_priv_lvl ;
  logic interrupt_go ;
  logic [MXLEN-1:0] trap_vector_base_o ;
  logic [5:0] interrupt_cause;
  logic [5:0] execption_cause;
  logic [MXLEN-1:0] mtinst_cs ;
  logic interrupt_global_enable ;

  logic valid ;
  logic S_timer_int_pend ,S_ext_int_pend ,M_timer_int_pend , M_ext_int_pend ;
  logic illegal_csr_read ;
  logic [15:0] mideleg_int ;
  assign mideleg_int = {4'b0000,mideleg_mei_cs,1'b0,mideleg_sei_cs,1'b0,mideleg_mti_cs,1'b0, mideleg_sti_cs,1'b0,1'b0,1'b0,1'b0,1'b0} ;
  /*----------- directly output some registers-------------*/
  assign o_riscv_csr_privlvl          = priv_lvl_cs  ;
  assign o_riscv_csr_return_address   = mepc_cs;
  assign o_riscv_csr_trap_address     = trap_vector_base_o ;
  assign o_riscv_csr_sepc             = sepc_cs     ;
  assign is_csr = (i_riscv_csr_op == 3'd0)? 1'b0:1'b1;

  // assign o_riscv_csr_trap_address     = {mtvec_base_cs ,  mtvec_mode_cs };
  // assign o_riscv_csr_trap_address     = {mtvec_base_cs ,  2'b00 };  // if direct mode
  // assign csr_mtval_o = mtval_cs;

  // // output assignments dependent on privilege mode
  always_comb
  begin
    // trap_vector_base_o = {mtvec_q[63:2], 2'b0};
    trap_vector_base_o = {mtvec_base_cs, 2'b0};
    // output user mode stvec
    if ((priv_lvl_cs && go_to_trap) == PRIV_LVL_S)
    begin
      //  trap_vector_base_o = {stvec_q[63:2], 2'b0};
      trap_vector_base_o = {stvec_base_cs, 2'b0};
    end

    // check if we are in vectored mode, if yes then do BASE + 4 * cause
    // we are imposing an additional alignment-constraint of 64 * 4 bytes since
    // we want to spare the costly addition
    if ((mtvec_base_cs[0] || stvec_base_cs[0]) && interrupt_go)
    begin
      trap_vector_base_o[7:2] = interrupt_cause[5:0];
    end
  end

  /* assign external_interrupt_pending_m =  (mstatus_mie_cs && mie_meie_cs && (mip_meip_cs))? 1:0; //machine_interrupt_enable + machine_external_interrupt_enable + machine_external_interrupt_pending must all be high
  //  assign software_interrupt_pending_m = mstatus_mie_cs && mie_msie_cs && mip_msip_cs;  //machine_interrupt_enable + machine_software_interrupt_enable + machine_software_interrupt_pending must all be high
   assign timer_interrupt_pending_m    = (mstatus_mie_cs && mie_mtie_cs && mip_mtip_cs)? 1:0; //machine_interrupt_enable + machine_timer_interrupt_enable + machine_timer_interrupt_pending must all be high
   assign is_interrupt                 = (external_interrupt_pending_m  || timer_interrupt_pending_m) ? 1:0  ;*/ // || software_interrupt_pending_m ;     

  assign is_interrupt                 = interrupt_go && interrupt_global_enable       ;

  // assign is_exception                 = ((illegal_total | i_riscv_csr_ecall_u |i_riscv_csr_ecall_s | i_riscv_csr_ecall_m  | i_riscv_csr_inst_addr_misaligned  | i_riscv_csr_load_addr_misaligned | i_riscv_csr_store_addr_misaligned) )? 1:0 ;
  assign is_trap                      = (is_interrupt || is_exception)? 1:0;
  //means there is previous trap
  assign go_to_trap                   =  is_trap && !i_riscv_csr_flush && !i_riscv_csr_globstall ;
  //a trap is taken, save i_pc, and go to trap address
  assign o_riscv_csr_gotoTrap_cs      =  go_to_trap ;

  /*Attempts to access a non-existent CSR raise an illegal instruction exception.
  >> done by making default case of read always
  Attempts to access a
  CSR without appropriate privilege level or to write a read-only register also raise illegal instruction
  exceptions */
  assign illegal_csr_priv   = ((i_riscv_csr_address[9:8] > priv_lvl_cs) && is_csr);    // ex : 3 >2 gives one why as current priv = s and need to access m register
  //  and that is not applicable
  // 3 > 3 gives zero why as current priv = m and need to access m register
  //  and that is  applicable
  assign illegal_csr_write  = (i_riscv_csr_address[11:10] == 2'b11) && csr_we ;    // csr_addr[11:10] == 2'b11 means it is readonly operation
  //  csr_we = 1 when operation  = CSR_WRITE ,  CSR_SET , CSR_CLEAR
  assign illegal_csr    = ((illegal_csr_read | illegal_csr_write | illegal_csr_priv ) && is_csr) ;
  assign illegal_total  =  illegal_csr | i_riscv_csr_illegal_inst ;
  assign csr_we_int     = csr_we &  ~illegal_csr;


  assign mip_timer_next    = i_riscv_csr_timer_int ;
  assign mip_external_next = i_riscv_csr_external_int ;
  assign o_riscv_csr_tsr   = mstatus_tsr_cs;


  /*** Modes transition conditions ***/
  assign go_from_s_to_s = ( (support_supervisor)  &&
                            (priv_lvl_cs == PRIV_LVL_S) &&
                            (medeleg_cs[execption_cause[3:0]] || mideleg_int[interrupt_cause[3:0]]));

  assign go_from_s_to_m = ( (support_supervisor)  &&
                            (priv_lvl_cs == PRIV_LVL_S) &&
                            (!medeleg_cs[execption_cause[3:0]] || !mideleg_int[interrupt_cause[3:0]]));

  /*----------------  */
  // CSR Read logic
  /* ---------------- */
  always_comb
  begin : csr_read_process

    // a read access exception can only occur if we attempt to read a CSR which does not exist
    //read_access_exception = 1'b0;
    csr_rdata_int = 64'b0;
    illegal_csr_read=1'b0 ;
    //perf_addr_o = csr_addr.address[4:0];;

    if (csr_read)
    begin    //see last always block to know when it is asserted
      //unique case (i_riscv_csr_address)
      case (i_riscv_csr_address)

        // mvendorid: encoding of manufacturer/provider
        CSR_MVENDORID :
          csr_rdata_int = 64'b0 ;  // can indicate it is not implemnted or it is not commercial implementation;

        // misa
        CSR_MISA      :
          csr_rdata_int = ISA_CODE;   //only written ones are read one while default all are read zero

        // marchid: encoding of base microarchitecture
        CSR_MARCHID   :
          csr_rdata_int = 64'b0 ;   //open source archture should have values

        // mimpid: encoding of processor implementation version
        //CSR_MIMPID: csr_rdata_int =  CSR_MIMPID_VALUE;   // we who decide the number that reflect the design of riscv itself
        CSR_MIMPID    :
          csr_rdata_int = 64'b0     ; // not implemented

        // mhartid: unique hardware thread id
        //  CSR_MHARTID   :   csr_rdata_int = hart_id_i;
        CSR_MHARTID   :
          csr_rdata_int = 'b0 ;


        /*----------------  */
        // mstatus  : MXLEN-bit read/write register
        /* ---------------- */
        CSR_MSTATUS   :
        begin


          csr_rdata_int[CSR_MSTATUS_SXL_BIT_HIGH:CSR_MSTATUS_SXL_BIT_LOW] = (support_supervisor) ? 2'b10 : 2'b00 ;
          csr_rdata_int[CSR_MSTATUS_UXL_BIT_HIGH:CSR_MSTATUS_UXL_BIT_LOW] =  (support_user)     ? 2'b10 : 2'b00 ;

          csr_rdata_int[CSR_MSTATUS_MIE_BIT]                              = mstatus_mie_cs;
          csr_rdata_int[CSR_MSTATUS_MPIE_BIT]                             = mstatus_mpie_cs;
          csr_rdata_int[CSR_MSTATUS_SIE_BIT]                              = mstatus_sie_cs;
          csr_rdata_int[CSR_MSTATUS_SPIE_BIT]                             = mstatus_spie_cs;
          csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_mpp_cs;
          csr_rdata_int[CSR_MSTATUS_SPP ]                                 = mstatus_spp_cs;

          //for memory
          csr_rdata_int[CSR_MSTATUS_MPRV_BIT]                             = mstatus_mprv_cs;
          csr_rdata_int[CSR_MSTATUS_MXR_BIT]                              = mstatus_mxr_cs ;
          csr_rdata_int[CSR_MSTATUS_SUM_BIT]                              = mstatus_sum_cs ;

          //for virtulazation supprot
          csr_rdata_int[CSR_MSTATUS_TSR_BIT]                              = mstatus_tsr_cs;
          csr_rdata_int[CSR_MSTATUS_TW_BIT]                               = mstatus_tw_cs ;
          csr_rdata_int[CSR_MSTATUS_TVM_BIT]                              = mstatus_tvm_cs;


          csr_rdata_int[CSR_MSTATUS_SBE_BIT]                              = mstatus_sbe_cs;
          csr_rdata_int[CSR_MSTATUS_MBE_BIT]                              = mstatus_mbe_cs ;
          csr_rdata_int[CSR_MSTATUS_UBE_BIT]                              = mstatus_ube_cs ;

        end

        /*----------------  */
        // mtvec  :  trap-vector base address
        /* ---------------- */
        CSR_MTVEC    :
        begin
          csr_rdata_int [1:0]                               = mtvec_mode_cs ;
          // csr_rdata_int [0]                              = mtvec_mode_cs ;
          csr_rdata_int[MXLEN-1:2]                          = mtvec_base_cs;

        end


        // MEDELEG
        CSR_MEDELEG  :
          csr_rdata_int[15:0]                                = medeleg_cs;

        //  MIDELEG
        CSR_MIDELEG :
        begin
          // csr_rdata_int[M_SOFT_I]                       = mideleg_msi_cs;
          csr_rdata_int[M_TIMER_I]                        = mideleg_mti_cs;
          csr_rdata_int[M_EXT_I]                          = mideleg_mei_cs;
          //csr_rdata_int[S_SOFT_I]                       = mideleg_ssi_cs;
          csr_rdata_int[S_TIMER_I]                        = mideleg_sti_cs;
          csr_rdata_int[S_EXT_I]                          = mideleg_sei_cs ;

        end
        CSR_MIE    :
        begin
          //csr_rdata_int                                     = '0;
          //csr_rdata_int[M_SOFT_I]                       = mie_msie_cs;
          csr_rdata_int[M_TIMER_I]                        = mie_mtie_cs;
          csr_rdata_int[M_EXT_I]                          = mie_meie_cs ;
          //csr_rdata_int[S_SOFT_I]                       = mie_ssie_cs;
          csr_rdata_int[S_TIMER_I]                        = mie_stie_cs;
          csr_rdata_int[S_EXT_I]                          = mie_seie_cs ;
        end

        CSR_MIP    :
        begin
          // csr_rdata_int                                     = '0;
          //csr_rdata_int[M_SOFT_I]                       = mip_msip_cs;
          csr_rdata_int[M_TIMER_I]                        = mip_mtip_cs;
          csr_rdata_int[M_EXT_I]                          = mip_meip_cs;
          //csr_rdata_int[S_SOFT_I]                       = mip_ssip_cs;
          csr_rdata_int[S_TIMER_I]                        = mip_stip_cs;
          csr_rdata_int[S_EXT_I]                          = mip_seip_cs ;
        end
        CSR_MSCRATCH :
          csr_rdata_int                                   = mscratch_cs;
        // mepc: exception program counter
        CSR_MEPC    :
          csr_rdata_int                                   = mepc_cs ;

        // mcause: exception cause
        CSR_MCAUSE  :
        begin
          //csr_rdata_int   = { // mcause_q.irq_ext | mcause_q.irq_int,   we combine them in one bit  // mcause_q.irq_int ? {26{1'b1}} : 26'b0,    //we dont support internal interupts only external interupts

          csr_rdata_int      = { mcause_int_excep_cs ,59'b0 , mcause_code_cs [3:0] };  //[4:0] until now it is wrong >>check it

        end

        CSR_MTVAL   :
          csr_rdata_int     = mtval_cs;

        /*----------------  */
        // mconfigptr : pointer to configuration data structre
        /* ---------------- */

        CSR_MCONFIGPTR :
          csr_rdata_int =        64'b0;  // not implemented >> in spec say that it must be implemnetd ?? i think its means if not implemnted must this address return value

        //CSR_MCONFIGPTR: csr_rdata_int = CSR_MCONFIGPTR_VALUE;
        // if (support_supervisor)
        //read_access_exception = 0 ;

        CSR_SIE            :
        begin
          /*csr_rdata_int[S_TIMER_I]                        = mie_stie_cs;
          csr_rdata_int[S_EXT_I]                          = mie_seie_cs ; */
          csr_rdata_int[S_TIMER_I]                        = mie_stie_cs && mideleg_mti_cs;
          csr_rdata_int[S_EXT_I]                          = mie_seie_cs  && mideleg_mei_cs;

        end
        CSR_SIP            :
        begin
          /*csr_rdata_int[S_TIMER_I]                        = mip_stip_cs;
          csr_rdata_int[S_EXT_I]                          = mip_seip_cs ;  */
          csr_rdata_int[S_TIMER_I]                        = mip_stip_cs && mideleg_mti_cs ;
          csr_rdata_int[S_EXT_I]                          = mip_seip_cs && mideleg_mei_cs ;
        end

        CSR_STVAL            :
          csr_rdata_int =        stval_cs;
        CSR_SSCRATCH         :
          csr_rdata_int =        sscratch_cs;
        CSR_SEPC             :
          csr_rdata_int =        sepc_cs;

        CSR_SCAUSE           :
        begin

          csr_rdata_int =  { scause_int_excep_cs ,59'b0 , scause_code_cs [3:0] };
        end

        CSR_STVEC            :
        begin
          csr_rdata_int [1:0]                               = stvec_mode_cs ;
          // csr_rdata_int [0]                              = stvec_mode_cs ;
          csr_rdata_int[SXLEN-1:2]                          = stvec_base_cs;
        end
        // CSR_SCOUNTEREN       : csr_rdata_int =        64'b0;   //check



        CSR_SSTATUS     :
        begin
          /*
           //for virtulazation supprot
            csr_rdata_int[CSR_MSTATUS_TSR_BIT]                              = mstatus_tsr_cs;
            csr_rdata_int[CSR_MSTATUS_TW_BIT]                               = mstatus_tw_cs ;
            csr_rdata_int[CSR_MSTATUS_TVM_BIT]                              = mstatus_tvm_cs;
            csr_rdata_int[CSR_MSTATUS_UBE_BIT]                              = mstatus_ube_cs ; */

          csr_rdata_int[CSR_MSTATUS_SIE_BIT]                              = mstatus_sie_cs;
          csr_rdata_int[CSR_MSTATUS_SPIE_BIT]                             = mstatus_spie_cs;
          csr_rdata_int[CSR_MSTATUS_SPP ]                                 = mstatus_spp_cs;
          csr_rdata_int[CSR_MSTATUS_UXL_BIT_HIGH:CSR_MSTATUS_UXL_BIT_LOW] =  (support_user)     ? 2'b10 : 2'b00 ;
          // for memory
          csr_rdata_int[CSR_MSTATUS_SUM_BIT]                              = mstatus_sum_cs ;
          csr_rdata_int[CSR_MSTATUS_MXR_BIT]                              = mstatus_mxr_cs ;
        end

        // CSR_SATP             : csr_rdata_int =        64'b0;
        //else read_access_exception = 1 ;


        default :
        begin
          illegal_csr_read   = 1'b1 ;
          csr_rdata_int =        64'b0;
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
      mstatus_mie_cs                 <=1'b0;
      mstatus_mpie_cs                <=1'b0;
      mstatus_sie_cs                 <=1'b0;
      mstatus_spie_cs                <=1'b0;
      mstatus_mpp_cs                 <=1'b0;
      mstatus_spp_cs                 <=1'b0;
      //extra add from m-mode due to spike
      mstatus_sxl_cs  <= 2'b10;
      mstatus_uxl_cs  <= 2'b10;
      //for memory
      mstatus_mprv_cs                <=1'b0;
      mstatus_mxr_cs                 <=1'b0;
      mstatus_sum_cs                 <=1'b0 ;

      //for virtulazation supprot
      mstatus_tsr_cs                 <=1'b0;
      mstatus_tw_cs                  <=1'b0;
      mstatus_tvm_cs                 <=1'b0;


      mstatus_sbe_cs                 <=1'b0;
      mstatus_mbe_cs                 <=1'b0 ;
      mstatus_ube_cs                 <=1'b0;
    end

    else if(go_to_trap)
    begin
      // trap to supervisor mode
      if (go_from_s_to_s)
      begin
        // update sstatus
        mstatus_sie_cs = 1'b0;
        mstatus_spie_cs = mstatus_sie_cs;
        // this can either be user or supervisor mode
        mstatus_spp_cs = priv_lvl_cs[0];  //check

      end

      // trap to machine mode
      else if ((priv_lvl_cs == PRIV_LVL_M) || go_from_s_to_m)
      begin
        // update mstatus
        mstatus_mie_cs   <= 0; //no nested interrupt allowed    // if done in software that will not make problem make it again zero
        // When a trap is taken from privilege mode y into privilege mode x,xPIE is set to the value of x IE; ?? check that
        mstatus_mpie_cs <= mstatus_mie_cs;
        // save the previous privilege mode
        mstatus_mpp_cs = priv_lvl_cs;  // check that statement or it is commented
        // mstatus_mpp_cs <= 2'b11;
      end
    end
    else if (mret )
    begin
      // return to the previous privilege level and restore all enable flags // like global interupt enable
      // get the previous machine interrupt enable flag
      mstatus_mie_cs    <= mstatus_mpie_cs;
      mstatus_mpie_cs   <= 1'b1;
      // and xPP is set to the least-privileged supported mode (U if U-mode is implemented, else M)
      //set mpp to user mode
      if(support_user)
        mstatus_mpp_cs   <= PRIV_LVL_U ;
      else
        mstatus_mpp_cs    <= PRIV_LVL_M ;

      // mstatus_mpp_cs  <= (support_user) ? PRIV_LVL_U : PRIV_LVL_M;
      //xPIE is set to 1 >> set mpie to 1
      // If xPP?=M, xRET also sets MPRV=0.
      /*
              if (mstatus_mpp_cs != PRIV_LVL_M) begin
                mstatus_mprv_cs <= 1'b0;
              end  */
    end

    else if (sret)
    begin
      // return the previous supervisor interrupt enable flag
      mstatus_sie_cs  <= mstatus_spie_cs;
      // set spp to user mode
      mstatus_spp_cs  <= 1'b0;
      // set spie to 1
      mstatus_spie_cs <= 1'b1;
    end

    else if (csr_we_int && i_riscv_csr_address == CSR_MSTATUS)

    begin

      mstatus_mie_cs    <= csr_wdata[CSR_MSTATUS_MIE_BIT]                             ;
      mstatus_mpie_cs   <= csr_wdata[CSR_MSTATUS_MPIE_BIT]                             ;
      mstatus_sie_cs    <= csr_wdata[CSR_MSTATUS_SIE_BIT]                              ;
      mstatus_spie_cs   <= csr_wdata[CSR_MSTATUS_SPIE_BIT]                             ;
      mstatus_mpp_cs    <= csr_wdata[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] ;
      mstatus_spp_cs    <= csr_wdata[CSR_MSTATUS_SPP] ;

      //for memory
      mstatus_mprv_cs   <=  csr_wdata[CSR_MSTATUS_MPRV_BIT]                            ;
      mstatus_mxr_cs    <= csr_wdata[CSR_MSTATUS_MXR_BIT]                             ;
      mstatus_sum_cs    <= csr_wdata[CSR_MSTATUS_SUM_BIT]                                ;

      //for virtulazation supprot
      mstatus_tsr_cs    <= csr_wdata[CSR_MSTATUS_TSR_BIT]                             ;
      mstatus_tw_cs     <= csr_wdata[CSR_MSTATUS_TW_BIT]                                ;
      //mstatus_tvm_cs  <= csr_wdata[CSR_MSTATUS_TVM_BIT]                            ;

      //mstatus_sbe_cs  <= csr_wdata[CSR_MSTATUS_SBE_BIT]                              ;
      //mstatus_mbe_cs  <=csr_wdata[CSR_MSTATUS_MBE_BIT]                               ;
      //mstatus_ube_cs  <= csr_wdata[CSR_MSTATUS_UBE_BIT]                              ;


      // this register has side-effects on other registers, flush the pipeline
      o_riscv_csr_flush  <= 1'b1;  // >> ?? need to be checked
    end


    /*-----SSTATUS-----*/
    else if (csr_we_int && i_riscv_csr_address == CSR_SSTATUS)

    begin

      mstatus_sie_cs    <= csr_wdata[CSR_MSTATUS_SIE_BIT]                              ;
      mstatus_spie_cs   <= csr_wdata[CSR_MSTATUS_SPIE_BIT]                             ;
      mstatus_spp_cs    <= csr_wdata[CSR_MSTATUS_SPP] ;
      //for memory
      mstatus_mxr_cs    <= csr_wdata[CSR_MSTATUS_MXR_BIT]                             ;
      mstatus_sum_cs    <= csr_wdata[CSR_MSTATUS_SUM_BIT]                                ;

    end

  end



  /*------mie register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      //mie
      mie_meie_cs                    <=1'b0 ;
      mie_mtie_cs                    <=1'b0 ;
      // mie_msie_cs                 <=1'b0 ;
      mie_seie_cs                    <=1'b0 ;
      mie_stie_cs                    <=1'b0 ;
      // mie_ssie_cs                 <=1'b0 ;
    end
    else if (csr_we_int && i_riscv_csr_address == CSR_MIE )

    begin

      // mie_msie_cs          <= csr_wdata[M_SOFT_I];             //3
      mie_mtie_cs           <= csr_wdata[M_TIMER_I];    //7
      mie_meie_cs           <= csr_wdata[M_EXT_I];      //11
      // mie_ssie_cs         <= csr_wdata[S_SOFT_I];
      mie_stie_cs           <= csr_wdata[S_TIMER_I];
      mie_seie_cs           <= csr_wdata[S_EXT_I];
    end
    /*------sie register-----*/
    else if (csr_we_int && i_riscv_csr_address == CSR_SIE )
    begin
      // the mideleg makes sure only delegate-able register (and therefore also only implemented registers) are written
      if (support_supervisor)
      begin
        // mie_msie_cs           <= csr_wdata[M_SOFT_I];             //3
        // mie_mtie_cs           <= csr_wdata[M_TIMER_I];    //7
        //mie_mtie_cs            <= 0 ;
        // mie_meie_cs           <= csr_wdata[M_EXT_I];      //11
        //  mie_meie_cs           <= 0 ;      //11
        // mie_ssie_cs           <= csr_wdata[S_SOFT_I];
        mie_stie_cs             <= (!mideleg_mti_cs)? mie_stie_cs : csr_wdata[S_TIMER_I];
        mie_seie_cs             <= (!mideleg_mei_cs)? mie_seie_cs : csr_wdata[S_EXT_I];
      end
    end   // end of always block
  end


  /*------mip register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin

      //mip
      mip_meip_cs                    <=1'b0 ;
      mip_mtip_cs                    <=1'b0 ;
      // mip_msip_cs                 <=1'b0 ;
      mip_seip_cs                    <=1'b0 ;
      mip_stip_cs                    <=1'b0 ;
      //  mip_ssip_cs                 <=1'b0 ;
    end

    else if (csr_we_int && i_riscv_csr_address == CSR_MIP )

    begin

      /* mip_mtip_cs         <= csr_wdata[M_TIMER_I];     //7
       mip_meip_cs         <= csr_wdata[M_EXT_I];  */     //11

      mip_mtip_cs         <=  mip_mtip_cs;     //7
      mip_meip_cs         <=  mip_meip_cs ;

      mip_stip_cs         <= csr_wdata[S_TIMER_I];
      mip_seip_cs         <= csr_wdata[S_EXT_I];
    end

    /*---sip---*/
    /*   else if (csr_we_int && i_riscv_csr_address == CSR_SIP )

         // only the supervisor software interrupt is write-able, iff delegated

             begin
                        // mip_msip_cs <= csr_wdata[M_SOFT_I];           //3
                        // mip_mtip_cs         <= csr_wdata[M_TIMER_I];     //7
                        // mip_mtip_cs         <= 0; 
                       // mip_meip_cs         <= csr_wdata[M_EXT_I];         //11
                       //  mip_meip_cs         <=0 ;  
                       // mip_ssip_cs      <= csr_wdata[S_SOFT_I]; 
                         mip_stip_cs         <= csr_wdata[S_TIMER_I]; 
                         mip_seip_cs         <= csr_wdata[S_EXT_I]; 
             end    */

    /*---check---*/  //trap is taken in m mode
    else
    begin
      mip_meip_cs                    <= mip_external_next ;
      mip_mtip_cs                    <= mip_timer_next;
    end
  end   /* end of always block


   /*------mtvec register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      //mtvec
      mtvec_base_cs                  <= 'b10010;  // it is 62 bits
      mtvec_mode_cs                  <= 2'b00 ;
      // set to boot address + direct mode + 4 byte offset which is the initial trap
      // mtvec_rst_load_q         <= 1'b1;
      // mtvec_cs                 <= '0;
    end
    else if (csr_we_int && i_riscv_csr_address == CSR_MTVEC)

    begin
      mtvec_base_cs    <= csr_wdata[63:2];
      // mtvec_mode_cs <= i_riscv_csr_wdata[1:0];
      mtvec_mode_cs  <= csr_wdata[0] ;

      if (csr_wdata[0])  //we are in vector mode, as LSB <=1
      begin
        mtvec_base_cs   <= {csr_wdata[63:8] , 6'b0 };
        mtvec_mode_cs   <=  csr_wdata[0] ;
      end

    end

  end   /*---of always block*/


  /*------stvec register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin
      //mtvec
      stvec_base_cs                  <= 'b11001;  // it is 62 bits
      stvec_mode_cs                  <= 2'b00 ;
      // set to boot address + direct mode + 4 byte offset which is the initial trap
      // mtvec_rst_load_q         <= 1'b1;
      // mtvec_cs                 <= '0;
    end
    else if (csr_we_int && i_riscv_csr_address == CSR_STVEC)

    begin
      stvec_base_cs    <= csr_wdata[63:2];
      // mtvec_mode_cs <= i_riscv_csr_wdata[1:0];
      stvec_mode_cs  <= csr_wdata[0] ;  //assign one bit to 2 bits >> check that

      if (csr_wdata[0])  //we are in vector mode, as LSB <=1
      begin
        stvec_base_cs   <= {csr_wdata[63:8] , 6'b0 };
        stvec_mode_cs   <=  csr_wdata[0] ;
      end

    end
  end   /*---of always block*/


  /*------medeleg register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      medeleg_cs                     <= 'b0 ;  // it is 16 bit

    //For exceptions that cannot occur in less privileged modes, the corresponding medeleg bits should
    // be read-only zero. In particular, medeleg[11] is read-only zero.
    else if (csr_we_int && i_riscv_csr_address == CSR_MEDELEG)
      medeleg_cs <=  {csr_wdata[15:11],1'b0,csr_wdata[9:0]};

  end  /*---of always block*/


  /*------mideleg register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
    begin

      mideleg_mei_cs                 <=1'b0 ;
      mideleg_mti_cs                 <=1'b0 ;
      // mideleg_msi_cs                  <=1'b0 ;
      mideleg_sei_cs                 <=1'b0 ;
      mideleg_sti_cs                 <=1'b0 ;
      // mideleg_ssi_cs                  <=1'b0 ;
    end
    else if (csr_we_int && i_riscv_csr_address == CSR_MIDELEG)
    begin

      // machine interrupt delegation register
      // we do not support user interrupt delegation
      if (support_supervisor)
      begin

        // mideleg_msi_cs   <=  csr_wdata[M_SOFT_I]     ;
        //  mideleg_mti_cs   <=  csr_wdata[M_TIMER_I]      ;
        //  mideleg_mei_cs   <=  csr_wdata[M_EXT_I]        ;
        //  mideleg_ssi_cs   <=  csr_wdata[S_SOFT_I]      ;
        mideleg_sti_cs   <=  csr_wdata[S_TIMER_I]       ;
        mideleg_sei_cs   <=  csr_wdata[S_EXT_I]        ;
      end
    end

  end   /*---of always block*/


  /*------mepc register-----
  --- (address of interrupted instruction)*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      mepc_cs <= 64'b0;
    else if(go_to_trap)
      begin
        if(priv_lvl_cs == PRIV_LVL_M)
          mepc_cs <= i_riscv_csr_pc ;
          
        else if ( (support_supervisor)  &&
                  (priv_lvl_cs == PRIV_LVL_S) &&
                  (!medeleg_cs[execption_cause[3:0]] || !mideleg_int[interrupt_cause[3:0]]))

          mepc_cs <= i_riscv_csr_pc ;
      end

    else if (csr_we_int && (i_riscv_csr_address == CSR_MEPC) )

      mepc_cs <= {csr_wdata[63:1],1'b0};
    //mepc_cs <= {csr_wdata[63:2],2'b00};    check is it 2'b00 or 1'b0 accordng to ialign

  end   /*---of always block*/


  /*------spec register-----
  --- (address of interrupted instruction)*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      sepc_cs                        <= 64'b0;

    else if(go_to_trap && support_supervisor && priv_lvl_cs == PRIV_LVL_S )
      sepc_cs         <= i_riscv_csr_pc ;

    else if (csr_we_int && i_riscv_csr_address == CSR_SEPC )

      sepc_cs <= {csr_wdata[63:1],1'b0};
    //sepc_cs <= {csr_wdata[63:2],2'b00};    check is it 2'b00 or 1'b0 accordng to ialign

  end   /*---of always block*/


  /*------mscratch register-----
  (dedicated for use by machine code) */
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      mscratch_cs                    <= 64'b0;

    else if (csr_we_int && i_riscv_csr_address == CSR_MSCRATCH)

      mscratch_cs <= csr_wdata;


  end   /*---of always block*/

  /*------sscratch register-----
  (dedicated for use by machine code) */
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      sscratch_cs                    <= 64'b0;

    else if (csr_we_int && i_riscv_csr_address == CSR_SSCRATCH)

      sscratch_cs <= csr_wdata;


  end   /*---of always block*/


  /*------mtval register-----
  (exception-specific information to assist software in handling trap)*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      mtval_cs  <= 64'b0;

    else if( (i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned) && (priv_lvl_cs == PRIV_LVL_M)  )
      mtval_cs <= i_riscv_csr_addressALU  ;
    else if( illegal_total && (priv_lvl_cs == PRIV_LVL_M)  )
      mtval_cs <= (i_riscv_csr_is_compressed)? { {48{1'b0}}, i_riscv_csr_cinst }:{ {32{1'b0}}, i_riscv_csr_inst }  ;
    else if (csr_we_int && i_riscv_csr_address == CSR_MTVAL)
      mtval_cs    <= csr_wdata;

  end   /*---of always block*/


  /*------stval register-----
  (exception-specific information to assist software in handling trap)*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)

      stval_cs <= 64'b0;
    // trap to supervisor mode
    else if(i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned && support_supervisor && priv_lvl_cs == PRIV_LVL_S)
      stval_cs <= i_riscv_csr_addressALU;

    else if(illegal_total  && support_supervisor && priv_lvl_cs == PRIV_LVL_S)
      stval_cs <= (i_riscv_csr_is_compressed)? { {48{1'b0}}, i_riscv_csr_cinst }:{ {32{1'b0}}, i_riscv_csr_inst }  ;

    else if (csr_we_int && i_riscv_csr_address == CSR_STVAL)
      stval_cs    <= csr_wdata;

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
      priv_lvl_cs <= PRIV_LVL_M;
    else if(go_to_trap)
    begin
      priv_lvl_cs <= trap_to_priv_lvl;
    end
    else if (mret)
      // restore the previous privilege level
      priv_lvl_cs       <= mstatus_mpp_cs;
    else if (sret)
      // restore the previous privilege level
      priv_lvl_cs    <= {1'b0, mstatus_spp_cs};  //check

  end   /*---of always block---*/


  /*------mcause register-----
  --- (indicates cause of trap(either interrupt or exception)) --- */

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if     (i_riscv_csr_rst)
    begin
      mcause_code_cs                 <= 4'b0000;
      mcause_int_excep_cs            <= 1'b0 ;
    end

    else if( go_to_trap && ((priv_lvl_cs == PRIV_LVL_M) || go_from_s_to_m))      //  trap to machine mode
    begin

      if(valid)
      begin
        if(M_ext_int_pend)
        begin
          mcause_code_cs      <= M_EXT_I;
          mcause_int_excep_cs <= 'b1;
        end
        else if(M_timer_int_pend)
        begin
          mcause_code_cs      <= M_TIMER_I;
          mcause_int_excep_cs <= 'b1;
        end
      end

      else if(illegal_total)
      begin
        mcause_code_cs      <= ILLEGAL_INSTRUCTION;
        mcause_int_excep_cs <= 0 ;
        // if (medeleg_cs[2] )
      end
      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        mcause_code_cs       <= INSTRUCTION_ADDRESS_MISALIGNED;
        mcause_int_excep_cs  <= 0;
        // if (medeleg_cs[0] )
      end
      else if(i_riscv_csr_ecall_m)
      begin
        mcause_code_cs       <= ECALL_M;
        mcause_int_excep_cs <= 0;
        //if (medeleg_cs[11] )
      end
      else if(i_riscv_csr_ecall_s)
      begin
        mcause_code_cs       <= ECALL_S;
        mcause_int_excep_cs <= 0;
        //if (medeleg_cs[9] )
      end
      else if(i_riscv_csr_ecall_u)
      begin
        mcause_code_cs       <= ECALL_U;
        mcause_int_excep_cs <= 0;
        //  if (medeleg_cs[8] ) */
      end
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        mcause_code_cs       <= LOAD_ADDRESS_MISALIGNED;
        mcause_int_excep_cs <= 0;
        //if (medeleg_cs[4] )
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        mcause_code_cs      <= STORE_ADDRESS_MISALIGNED;
        mcause_int_excep_cs  <= 0;
        //if (medeleg_cs[6] )
      end
      // else if(software_interrupt_pending)
      // begin
      //  mcause_code_cs       <= MACHINE_SOFTWARE_INTERRUPT;
      //  mcause_int_excep_cs <= 1;
      //  if (mideleg_msi_cs)
      //end

    end   /*---of gototrap---*/
    else if (csr_we_int && i_riscv_csr_address == CSR_MCAUSE)
    begin

      mcause_int_excep_cs <= csr_wdata[63];
      mcause_code_cs      <= csr_wdata[3:0];
    end


  end    /*---of always block---*/

  /*------scause register-----
  --- (scause cause of trap(either interrupt or exception)) --- */


  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if     (i_riscv_csr_rst)
    begin

      scause_code_cs                 <= 4'b0000;
      scause_int_excep_cs            <= 1'b0 ;
    end
  
    else if( go_to_trap && support_supervisor && priv_lvl_cs == PRIV_LVL_S && (medeleg_cs[execption_cause[3:0]] || mideleg_int[interrupt_cause[3:0]]))   // trap to supervisor mode
    begin
      if (valid)
      begin
        //  if (support_supervisor && trap_to_priv_lvl == PRIV_LVL_S) begin
        if(S_ext_int_pend)
        begin
          scause_code_cs      <= S_EXT_I;
          scause_int_excep_cs <= 1;
          // if (mideleg_mei_cs )
        end
        else if(S_timer_int_pend)
        begin
          scause_code_cs      <= S_TIMER_I;
          scause_int_excep_cs <= 1;
          // if (mideleg_mti_cs )
        end
      end
      else if(illegal_total)
      begin
        scause_code_cs      <= ILLEGAL_INSTRUCTION;
        scause_int_excep_cs <= 0 ;
        // if (medeleg_cs[2] )
      end
      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        scause_code_cs       <= INSTRUCTION_ADDRESS_MISALIGNED;
        scause_int_excep_cs  <= 0;
        // if (medeleg_cs[0] )
      end

      else if(i_riscv_csr_ecall_s)
      begin
        scause_code_cs       <= ECALL_S;
        scause_int_excep_cs <= 0;
        //if (medeleg_cs[9] )
      end
      else if(i_riscv_csr_ecall_u)
      begin
        scause_code_cs       <= ECALL_U;
        scause_int_excep_cs <= 0;
        // if (medeleg_cs[8] ) */
      end
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        scause_code_cs       <= LOAD_ADDRESS_MISALIGNED;
        scause_int_excep_cs <= 0;
        //if (medeleg_cs[4] )
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        scause_code_cs      <= STORE_ADDRESS_MISALIGNED;
        scause_int_excep_cs  <= 0;
        //if (medeleg_cs[6] )
      end
    end   /*---of gototrap---*/
    else if (csr_we_int && i_riscv_csr_address == CSR_SCAUSE)
    begin

      scause_int_excep_cs <= csr_wdata[63];
      scause_code_cs      <= csr_wdata[3:0];
    end


  end    /*---of always block---*/


  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst )
  begin
    if (i_riscv_csr_rst)
      mtinst_cs <= 'b0 ;
    else if (csr_we_int && i_riscv_csr_address == CSR_MTINST)
      //  mtinst <= (is_compressed)? i_riscv_csr_inst ;
      mtinst_cs <=  i_riscv_csr_inst ;
  end
  /* missing FF
  always @() begin
     satp, scoubteren ;
  end*/


  /*----------------  */
  // CSR OP Select Logic
  /* ---------------- */

  always_comb
  begin : csr_op_logic

    csr_wdata = i_riscv_csr_wdata;
    //added from m-mode code
    csr_we    = (!i_riscv_csr_globstall)? 1'b1:1'b0;
    csr_read  = 1'b1;
    mret      = 1'b0;
    sret      = 1'b0;

    case (i_riscv_csr_op)
      CSR_WRITE :
        csr_wdata = i_riscv_csr_wdata;
      CSR_SET :
        csr_wdata = i_riscv_csr_wdata | csr_rdata_int;
      CSR_CLEAR :
        csr_wdata = (~i_riscv_csr_wdata) & csr_rdata_int;
      CSR_READ :
        csr_we    = 1'b0 ;
      SRET:
      begin
        // the return should not have any write or read side-effects
        csr_we   = 1'b0;
        csr_read = 1'b0;
        sret     = 1'b1; // signal a return from supervisor mode
      end
      MRET:
      begin
        // the return should not have any write or read side-effects
        csr_we   = 1'b0;
        csr_read = 1'b0;
        mret     = 1'b1; // signal a return from machine mode
      end

      default:
      begin
        csr_we   = 1'b0;
        csr_read = 1'b0;
      end
    endcase
    // if we are retiring an exception do not return from exception
    /*    if (ex_i.valid) begin
            mret = 1'b0;
            sret = 1'b0;
        end
    */

  end




  /*----------------  */
  // output mux
  /* ---------------- */
  always_comb
  begin : csr_read_out_process  //reading is done comb


    o_riscv_csr_rdata = csr_rdata_int;

    // performance counters
    // if (is_pccr || is_pcer || is_pcmr)
    // o_riscv_csr_rdata = perf_rdata;
  end



  // update priv level
  always_comb
  begin
    if (go_to_trap)
    begin
      if  ( (support_supervisor && is_interrupt && mideleg_int[interrupt_cause[3:0]]) ||
            ( (is_exception && medeleg_cs[execption_cause[3:0]] ) ) )  //~is_interrupt = is_exception
      begin
        if (priv_lvl_cs == PRIV_LVL_M)
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

    if (mie_stie_cs && mip_stip_cs)

    begin
      interrupt_go = 1;
      S_timer_int_pend = 1 ;
      interrupt_cause = S_TIMER_I ;

    end
    // Supervisor External Interrupt
    // The logical-OR of the software-writable bit and the signal from the external interrupt controller is
    // used to generate external interrupts to the supervisor
    else if ( mie_seie_cs && mip_seip_cs)
    begin
      interrupt_go = 1;
      S_ext_int_pend = 1 ;
      interrupt_cause = S_EXT_I;
    end

    else if (mip_mtip_cs && mie_mtie_cs)

    begin
      interrupt_go = 1;
      M_timer_int_pend = 1 ;
      interrupt_cause = M_TIMER_I;
    end

    // Machine Timer Interrupt

    else if (mip_meip_cs && mie_meie_cs)

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
  assign interrupt_global_enable =  ((mstatus_mie_cs & (priv_lvl_cs == PRIV_LVL_M))
                                     || (priv_lvl_cs != PRIV_LVL_M));


  always_comb
  begin
    if (interrupt_go && interrupt_global_enable )   // =1 menas it is an interuopt
    begin
      // However, if bit i in mideleg is set, interrupts are considered to be globally enabled
      //if the hart’s current privilege mode equals the delegated privilege mode (S or U)
      //  and that mode’s interrupt enable bit (SIE or UIE in mstatus) is set ,
      //or if the current privilege mode is less than the delegated privilege mode.
      if (mideleg_int[interrupt_cause[3:0]]) //if delegated so cant take action of trap if below conditions are satified
        // but if not delegated so action of trap take directly without that check
      begin
        if (  (support_supervisor && mstatus_sie_cs && priv_lvl_cs == PRIV_LVL_S) ||
              (support_user && priv_lvl_cs == PRIV_LVL_U) )
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

  logic sel ;

  always_comb
  begin
    if (o_riscv_csr_flush)
      sel = 1 ;   // for mux input to it pc+4 from mem stage
    else
      sel = 0 ;  // for mux input to it output from previos mux
  end

endmodule
