module riscv_csrfile #(
  parameter MXLEN              = 64,
  parameter support_supervisor = 1 ,
  parameter support_user       = 1
) (
  input  logic             i_riscv_csr_globstall            ,
  input  logic             i_riscv_csr_flush                ,
  input                    i_riscv_csr_clk                  ,
  input                    i_riscv_csr_rst                  ,
  input        [     11:0] i_riscv_csr_address              ,
  input        [      2:0] i_riscv_csr_op                   ,
  input        [MXLEN-1:0] i_riscv_csr_wdata                ,
  output logic [MXLEN-1:0] o_riscv_csr_rdata                ,
  output logic             o_riscv_csr_sideeffect_flush     ,
                                                              // Interrupts
  input  logic             i_riscv_csr_external_int         , //interrupt from external source
                                                              //input wire i_riscv_csr_software_interrupt, //interrupt from software (inter-processor interrupt)
  input  logic             i_riscv_csr_timer_int            , //interrupt from timer
                                                              /// Exceptions ///
  input  logic             i_riscv_csr_illegal_inst         , //illegal instruction (From decoder) ??check if can come from csr
  input  logic             i_riscv_csr_ecall_u              , //ecall instruction from user mode
  input  logic             i_riscv_csr_ecall_s              , //ecall instruction from s mode
  input  logic             i_riscv_csr_ecall_m              , //ecall instruction from m mode
  input  logic             i_riscv_csr_inst_addr_misaligned ,
  input  logic             i_riscv_csr_load_addr_misaligned ,
  input  logic             i_riscv_csr_store_addr_misaligned,
  input  logic             i_riscv_csr_instret              ,
  output logic [MXLEN-1:0] o_riscv_csr_return_address       , //mepc CSR  (address to retrun after excuting trap) to continue excuting normal instruction
  output logic [MXLEN-1:0] o_riscv_csr_trap_address         , //mtvec CSR
                                                              // Trap-Handler  // Interrupts/Exceptions
  output logic             o_riscv_csr_gotoTrap_cs          , //high before going to trap (if exception/interrupt detected)  // Output the exception PC to PC Gen, the correct CSR (mepc, sepc) is set accordingly
  output logic             o_riscv_csr_returnfromTrap_cs    , //high before returning from trap (via mret)
  input  logic [     63:0] i_riscv_csr_pc                   ,
  input  logic [     63:0] i_riscv_csr_addressALU           , //address  from ALU  used in load/store/jump/branch)
  output logic [      1:0] o_riscv_csr_privlvl              ,
  output logic             o_riscv_csr_flush
  // input wire writeback_change_pc, //high if writeback will issue change_pc (which will override this stage)
);


  //CSR addresses
  //machine info
  localparam CSR_MVENDORID = 12'hF11,
    CSR_MARCHID   = 12'hF12,
    CSR_MIMPID    = 12'hF13,
    CSR_MHARTID   = 12'hF14,
    //machine trap setup
    CSR_MSTATUS   = 12'h300,
    CSR_MISA      = 12'h301,
    CSR_MIE       = 12'h304,
    CSR_MTVEC     = 12'h305,
    //machine trap handling
    CSR_MSCRATCH  = 12'h340,
    CSR_MEPC      = 12'h341,
    CSR_MCAUSE    = 12'h342,
    CSR_MTVAL     = 12'h343,
    CSR_MIP       = 12'h344  ,
    CSR_MEDELEG   = 12'h302,
    CSR_MIDELEG   = 12'h303,
    // CSR_MCOUNTEREN= 12'h306 ;
    CSR_MCONFIGPTR= 12'hF15 ,
    // CSR COUNTERS
    CSR_MINSTRET       = 12'hB02,
    CSR_MCYCLE         = 12'hB00,
    CSR_MCOUNTINHIBIT  = 12'h320;

  //CSR operation type
  localparam CSR_WRITE     = 3'b001 ,
    CSR_SET       = 3'b010 ,
    CSR_CLEAR     = 3'b011 ,
    CSR_READ      = 3'b101 ,
    SRET          = 3'b110 ,
    MRET          = 3'b111 ;



  localparam PRIV_LVL_U = 2'b00;
  localparam PRIV_LVL_S = 2'b01;
  localparam PRIV_LVL_M = 2'b11;

  //interupts
  localparam S_TIMER_I = 5 ;
  localparam M_TIMER_I = 7 ;
  localparam S_EXT_I   = 9 ;
  localparam M_EXT_I   = 11;

  //exceptions
  localparam INSTRUCTION_ADDRESS_MISALIGNED = 0  ,
    ILLEGAL_INSTRUCTION            = 2  ,
    LOAD_ADDRESS_MISALIGNED        = 4  ,
    STORE_ADDRESS_MISALIGNED       = 6  ,
    ECALL_U                        = 8  ,
    ECALL_S                        = 9  ,
    ECALL_M                        = 11 ;

  localparam CSR_MSTATUS_SIE_BIT  = 1;
  localparam CSR_MSTATUS_MIE_BIT  = 3;
  localparam CSR_MSTATUS_SPIE_BIT = 5;
  localparam CSR_MSTATUS_UBE_BIT  = 6;
  localparam CSR_MSTATUS_MPIE_BIT = 7;
  localparam CSR_MSTATUS_SPP      = 8;

  localparam CSR_MSTATUS_MPP_BIT_LOW  = 11;
  localparam CSR_MSTATUS_MPP_BIT_HIGH = 12;
  localparam CSR_MSTATUS_MPRV_BIT     = 17;
  localparam CSR_MSTATUS_SUM_BIT      = 18;
  localparam CSR_MSTATUS_MXR_BIT      = 19;
  localparam CSR_MSTATUS_TVM_BIT      = 20;
  localparam CSR_MSTATUS_TW_BIT       = 21;
  localparam CSR_MSTATUS_TSR_BIT      = 22;

  localparam CSR_MSTATUS_UXL_BIT_LOW  = 32;
  localparam CSR_MSTATUS_UXL_BIT_HIGH = 33;
  localparam CSR_MSTATUS_SXL_BIT_LOW  = 34;

  localparam CSR_MSTATUS_SXL_BIT_HIGH = 35;

  localparam CSR_MSTATUS_SBE_BIT = 36;
  localparam CSR_MSTATUS_MBE_BIT = 37;


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



  logic       riscv_csr_gotoTrap_ns;
  logic       riscv_csr_returnfromTrap_ns;
  logic [1:0] priv_lvl_cs;
  logic [1:0] priv_lvl_ns                ;
  // CSR register bits   //only we dont implement whole register width if there are bits (registers) not useful  >> whole registers are implemnted :
  /*mepc , mscratch, mtval    */

  logic [MXLEN-1:0] mepc_cs;
  logic [MXLEN-1:0] mepc_ns    ; //machine exception i_pc (address of interrupted instruction)
  logic [MXLEN-1:0] mscratch_cs;
  logic [MXLEN-1:0] mscratch_ns; //dedicated for use by machine code
  logic [MXLEN-1:0] mtval_cs;
  logic [MXLEN-1:0] mtval_ns   ; //exception-specific infotmation to assist software in handling trap

  /*----------------  */
  //     mtvec
  /* ---------------- */
  logic [MXLEN-3:0] mtvec_base_cs;
  logic [MXLEN-3:0] mtvec_base_ns; //address of pc taken after returning from Trap (via MRET)
  logic [      1:0] mtvec_mode_cs;
  logic [      1:0] mtvec_mode_ns; //vector mode addressing >> vectored or direct
  // logic          mtvec_mode_cs , mtvec_mode_ns ;        //only one bit as 2 bits if they are reserved and we dont care about it >> also check it

  /*----------------  */
  //     mstatus
  /* ---------------- */
  logic       mstatus_sie_cs;
  logic       mstatus_sie_ns ; //  Supervisor Interrupt Enable
  logic       mstatus_mie_cs;
  logic       mstatus_mie_ns ; //Machine Interrupt Enable
  logic       mstatus_spie_cs;
  logic       mstatus_spie_ns; // Supervisor Previous Interrupt Enable
  logic       mstatus_ube_cs;
  logic       mstatus_ube_ns ;
  logic       mstatus_mpie_cs;
  logic       mstatus_mpie_ns; //Machine Previous Interrupt Enable
  logic       mstatus_spp_cs;
  logic       mstatus_spp_ns ;
  logic [1:0] mstatus_mpp_cs;
  logic [1:0] mstatus_mpp_ns ;
  //both used for FPU and user extensions and we dont support both
  //logic [1:0]    mstatus_vs_cs , mstatus_vs_ns;
  //logic [1:0]     mstatus_fs_cs , mstatus_fs_ns;
  //logic [1:0]     mstatus_xs_cs , mstatus_xs_ns;
  // logic          mstatus_sd_cs , mstatus_sd_ns;
  //for memory
  logic mstatus_mprv_cs;
  logic mstatus_mprv_ns;
  logic mstatus_sum_cs;
  logic mstatus_sum_ns ;
  logic mstatus_mxr_cs;
  logic mstatus_mxr_ns ;
  //virtualization support
  logic mstatus_tvm_cs;
  logic mstatus_tvm_ns;
  logic mstatus_tw_cs;
  logic mstatus_tw_ns ;
  logic mstatus_tsr_cs;
  logic mstatus_tsr_ns;
  //base isa control
  logic [1:0] mstatus_uxl_cs;
  logic [1:0] mstatus_uxl_ns;
  logic [1:0] mstatus_sxl_cs;
  logic [1:0] mstatus_sxl_ns;
  logic       mstatus_sbe_cs;
  logic       mstatus_sbe_ns;
  logic       mstatus_mbe_cs;
  logic       mstatus_mbe_ns;

  /*----------------  */
  //     mie
  /* ---------------- */
  logic mie_meie_cs;
  logic mie_meie_ns; //machine external interrupt enable
  logic mie_mtie_cs;
  logic mie_mtie_ns; //machine timer interrupt enable
  //logic           mie_msie_cs , mie_msie_ns; //machine software interrupt enable
  logic mie_seie_cs;
  logic mie_seie_ns; //supervisor external interrupt enable
  logic mie_stie_cs;
  logic mie_stie_ns; //Supervisor timer interrupt enable
  //logic           mie_ssie_cs, mie_ssie_ns; //Supervisor software interrupt enable

  /*----------------  */
  //     mip
  /* ---------------- */
  logic mip_meip_cs;
  logic mip_meip_ns; //machine external interrupt pending
  logic mip_mtip_cs;
  logic mip_mtip_ns; //machine timer interrupt pending
  //logic           mip_msip_cs , mip_msip_ns; //machine software interrupt pending
  logic mip_seip_cs;
  logic mip_seip_ns; //supervisor external interrupt pending
  logic mip_stip_cs;
  logic mip_stip_ns; //supervisor timer interrupt pending
  // logic           mip_ssip_cs, mip_ssip_ns; //supervisor software interrupt pending


  /*----------------  */
  //      mcause
  /* ---------------- */
  logic       mcause_int_excep_cs;
  logic       mcause_int_excep_ns; //interrupt(1) or exception(0)
  logic [3:0] mcause_code_cs;
  logic [3:0] mcause_code_ns     ; //indicates event that caused the trap  //as max value  =16

  /*----------------  */
  //      medeleg
  /* ---------------- */  // >> need to checked

  logic [15:0] medeleg_cs;
  logic [15:0] medeleg_ns; // as we have exception until number 16 only but each exception has sepefic FF so we need 16 FF

  /*----------------  */
  //      mideleg
  /* ---------------- */    //>>need to be checked
  logic mideleg_mei_cs;
  logic mideleg_mei_ns; //machine external interrupt delegation
  logic mideleg_mti_cs;
  logic mideleg_mti_ns; //machine timer interrupt delegation
  //logic         mideleg_msi_cs , mideleg_msi_ns;  //machine software interrupt delegation
  logic mideleg_sei_cs;
  logic mideleg_sei_ns; //supervisor external interrupt delegation
  logic mideleg_sti_cs;
  logic mideleg_sti_ns; //Supervisor timer interrupt delegation
  //logic         mideleg_ssi_cs , mideleg_ssi_ns; //Supervisor software interrupt delegation

  /*----------------  */
  //      Counters
  /* ---------------- */    //>>need to be checked
  logic [      2:0] mcountinhibit   ;
  logic [MXLEN-1:0] mcounter     [3];
  logic [      2:0] mcounter_we     ;
  logic [      2:0] mcounter_incr   ;
  /*----------------  */
  // Internal Signals
  /* ---------------- */

  logic             external_interrupt_pending_m;
  logic             timer_interrupt_pending_m   ;
  logic             is_interrupt                ;
  logic             is_exception                ;
  logic             is_trap                     ;
  logic             go_to_trap                  ;
  logic             illegal_csr_priv;
  logic             illegal_csr_write           ;
  logic             illegal_csr_address         ;
  logic             illegal_csr;
  logic             csr_we_int                  ;
  logic [MXLEN-1:0] csr_wdata                   ;
  logic [MXLEN-1:0] csr_rdata_int               ;
  logic             mret                        ;
  logic             sret                        ;
  logic             csr_we                      ;
  logic             csr_read                    ;



/*----------- directly output some registers-------------*/
  assign o_riscv_csr_privlvl        = priv_lvl_cs  ;
  assign o_riscv_csr_return_address = mepc_cs;
  assign o_riscv_csr_trap_address   = {mtvec_base_cs , mtvec_mode_cs };
  // assign csr_mtval_o = mtval_cs;

  assign external_interrupt_pending_m = (mstatus_mie_cs && mie_meie_cs && (mip_meip_cs))? 1:0; //machine_interrupt_enable + machine_external_interrupt_enable + machine_external_interrupt_pending must all be high
  //  assign software_interrupt_pending_m = mstatus_mie_cs && mie_msie_cs && mip_msip_cs;  //machine_interrupt_enable + machine_software_interrupt_enable + machine_software_interrupt_pending must all be high
  assign timer_interrupt_pending_m = (mstatus_mie_cs && mie_mtie_cs && mip_mtip_cs)? 1:0; //machine_interrupt_enable + machine_timer_interrupt_enable + machine_timer_interrupt_pending must all be high

  assign is_interrupt = (external_interrupt_pending_m  || timer_interrupt_pending_m) ? 1:0  ; // || software_interrupt_pending_m ;
  // assign is_exception                 = ((i_riscv_csr_illegal_inst | i_riscv_csr_ecall_u |i_riscv_csr_ecall_s | i_riscv_csr_ecall_m  | i_riscv_csr_inst_addr_misaligned  | i_riscv_csr_load_addr_misaligned | i_riscv_csr_store_addr_misaligned) )? 1:0 ;
  assign is_trap                 = (is_interrupt || is_exception)? 1:0;
  assign go_to_trap              = is_trap && !i_riscv_csr_flush ; //a trap is taken, save i_pc, and go to trap address
  assign o_riscv_csr_gotoTrap_cs = go_to_trap ;
  assign illegal_total           = illegal_csr | i_riscv_csr_illegal_inst ;
  /*Attempts to access a non-existent CSR raise an illegal instruction exception.
  >> done by making default case of read always
  Attempts to access a
  CSR without appropriate privilege level or to write a read-only register also raise illegal instruction
  exceptions */
  assign illegal_csr_priv = (i_riscv_csr_address[9:8] > priv_lvl_cs);    // ex : 3 >2 gives one why as current priv = s and need to access m register
  //  and that is not applicable
  // 3 > 3 gives zero why as current priv = m and need to access m register
  //  and that is  applicable
  assign illegal_csr_write = (i_riscv_csr_address[11:10] == 2'b11) && csr_we ;    // csr_addr[11:10] == 2'b11 means it is readonly operation
  //  csr_we = 1 when operation  = CSR_WRITE ,  CSR_SET , CSR_CLEAR
  assign illegal_csr = (illegal_csr_write | illegal_csr_priv | illegal_csr_address) ;
  assign csr_we_int  = csr_we &  ~illegal_csr;
  // assign return_from_trap = i_is_mret; // return from trap, go back to saved i_pc

  //assign illegal_csr_priv   = (csr_addr[9:8] > {priv_lvl_cs});

  assign mcounter_incr[0] = 1'b1; //MCYCLE
  assign mcounter_incr[1] = 1'b0; // reserved
  assign mcounter_incr[2] = i_riscv_csr_instret; //MINSTRET

  /*----------------  */
  // CSR Read logic
  /* ---------------- */
  always_comb begin : csr_read_process

    // a read access exception can only occur if we attempt to read a CSR which does not exist
    //read_access_exception = 1'b0;
    csr_rdata_int       = 64'b0;
    illegal_csr_address = 1'b0;
    //perf_addr_o = csr_addr.address[4:0];;



    if (csr_read) begin    //see last always block to know when it is asserted
      case (i_riscv_csr_address)
        // case (i_riscv_csr_address)

        // mvendorid: encoding of manufacturer/provider
        CSR_MVENDORID : csr_rdata_int = 64'b0 ;  // can indicate it is not implemnted or it is not commercial implementation;

        // misa
        CSR_MISA : csr_rdata_int = ISA_CODE;   //only written ones are read one while default all are read zero

        // marchid: encoding of base microarchitecture
        CSR_MARCHID : csr_rdata_int = 64'b0 ;   //open source archture should have values

        // mimpid: encoding of processor implementation version
        //CSR_MIMPID: csr_rdata_int =  CSR_MIMPID_VALUE;   // we who decide the number that reflect the design of riscv itself
        CSR_MIMPID : csr_rdata_int = 64'b0     ; // not implemented

        // mhartid: unique hardware thread id
        CSR_MHARTID : csr_rdata_int = 'b0;



        /*----------------  */
        // mstatus  : MXLEN-bit read/write register
        /* ---------------- */
        CSR_MSTATUS :
          begin


            csr_rdata_int[CSR_MSTATUS_SXL_BIT_HIGH:CSR_MSTATUS_SXL_BIT_LOW] = (support_supervisor) ? 2'b10 : 2'b00 ;
            csr_rdata_int[CSR_MSTATUS_UXL_BIT_HIGH:CSR_MSTATUS_UXL_BIT_LOW] = (support_user)     ? 2'b10 : 2'b00 ;

            csr_rdata_int[CSR_MSTATUS_MIE_BIT]                              = mstatus_mie_cs;
            csr_rdata_int[CSR_MSTATUS_MPIE_BIT]                             = mstatus_mpie_cs;
            csr_rdata_int[CSR_MSTATUS_SIE_BIT]                              = mstatus_sie_cs;
            csr_rdata_int[CSR_MSTATUS_SPIE_BIT]                             = mstatus_spie_cs;
            csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_mpp_cs;
            csr_rdata_int[CSR_MSTATUS_SPP]                                  = mstatus_spp_cs;

            //for memory
            csr_rdata_int[CSR_MSTATUS_MPRV_BIT] = mstatus_mprv_cs;
            csr_rdata_int[CSR_MSTATUS_MXR_BIT]  = mstatus_mxr_cs ;
            csr_rdata_int[CSR_MSTATUS_SUM_BIT]  = mstatus_sum_cs ;

            //for virtulazation supprot
            csr_rdata_int[CSR_MSTATUS_TSR_BIT] = mstatus_tsr_cs;
            csr_rdata_int[CSR_MSTATUS_TW_BIT]  = mstatus_tw_cs ;
            csr_rdata_int[CSR_MSTATUS_TVM_BIT] = mstatus_tvm_cs;


            csr_rdata_int[CSR_MSTATUS_SBE_BIT] = mstatus_sbe_cs;
            csr_rdata_int[CSR_MSTATUS_MBE_BIT] = mstatus_mbe_cs ;
            csr_rdata_int[CSR_MSTATUS_UBE_BIT] = mstatus_ube_cs ;

          end

        /*----------------  */
        // mtvec  :  trap-vector base address
        /* ---------------- */
        CSR_MTVEC :
          begin
            csr_rdata_int[1:0]       = mtvec_mode_cs ;
            csr_rdata_int[MXLEN-1:2] = mtvec_base_cs;

          end


        // MEDELEG
        CSR_MEDELEG : csr_rdata_int[15:0]                                = medeleg_cs;

        //  MIDELEG
        CSR_MIDELEG :
          begin
            csr_rdata_int[M_TIMER_I] = mideleg_mti_cs;
            csr_rdata_int[M_EXT_I]   = mideleg_mei_cs;
            csr_rdata_int[S_TIMER_I] = mideleg_sti_cs;
            csr_rdata_int[S_EXT_I]   = mideleg_sei_cs ;

          end
        CSR_MIE :
          begin
            csr_rdata_int[M_TIMER_I] = mie_mtie_cs;
            csr_rdata_int[M_EXT_I]   = mie_meie_cs ;
            csr_rdata_int[S_TIMER_I] = mie_stie_cs;
            csr_rdata_int[S_EXT_I]   = mie_seie_cs ;
          end

        CSR_MIP :
          begin
            csr_rdata_int[M_TIMER_I] = mip_mtip_cs;
            csr_rdata_int[M_EXT_I]   = mip_meip_cs;
            csr_rdata_int[S_TIMER_I] = mip_stip_cs;
            csr_rdata_int[S_EXT_I]   = mip_seip_cs ;
          end


        CSR_MSCRATCH : csr_rdata_int                                   = mscratch_cs;


        // mepc: exception program counter
        CSR_MEPC : csr_rdata_int                                   = mepc_cs ;

        // mcause: exception cause

        CSR_MCAUSE :
          begin

            csr_rdata_int = { mcause_int_excep_cs ,59'b0 , mcause_code_cs [3:0] }; 

          end

        CSR_MTVAL : csr_rdata_int     = mtval_cs;

        /*----------------  */
        // mconfigptr : pointer to configuration data structre
        /* ---------------- */

        CSR_MCONFIGPTR : csr_rdata_int =        64'b0; 

        CSR_MCOUNTINHIBIT : csr_rdata_int [2:0] =   mcountinhibit ;
        CSR_MCYCLE        : csr_rdata_int       =   mcounter[0];
        CSR_MINSTRET      : csr_rdata_int       =   mcounter[2];

        default : begin
          illegal_csr_address = 1'b1;
          csr_rdata_int       = 64'b0;

        end
      endcase


    end 


  end  

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)
        begin
          mstatus_mie_cs  <= 1'b0;
          mstatus_mpie_cs <= 1'b0;
          mstatus_sie_cs  <= 1'b0;
          mstatus_spie_cs <= 1'b0;
          mstatus_mpp_cs  <= 1'b0;
          mstatus_spp_cs  <= 1'b0;
          mstatus_sxl_cs  <= 2'b10;
          mstatus_uxl_cs  <= 2'b10;
          //for memory
          mstatus_mprv_cs <= 1'b0;
          mstatus_mxr_cs  <= 1'b0;
          mstatus_sum_cs  <= 1'b0 ;

          //for virtulazation supprot
          mstatus_tsr_cs <= 1'b0;
          mstatus_tw_cs  <= 1'b0;
          mstatus_tvm_cs <= 1'b0;


          mstatus_sbe_cs <= 1'b0;
          mstatus_mbe_cs <= 1'b0 ;
          mstatus_ube_cs <= 1'b0;
        end

      else if(go_to_trap )
        begin

          mstatus_mpie_cs <= mstatus_mie_cs;
          mstatus_mie_cs  <= 0;

          mstatus_mpp_cs <= 2'b11; 
        end
      else if (mret)
        begin
          mstatus_mie_cs  <= mstatus_mpie_cs;
          mstatus_mpie_cs <= 1'b1;
          if(support_user)
            mstatus_mpp_cs <= PRIV_LVL_U ;
          else
            mstatus_mpp_cs <= PRIV_LVL_M ;
        end

      else if (csr_we && i_riscv_csr_address == CSR_MSTATUS)

        begin

          mstatus_mie_cs  <= csr_wdata[CSR_MSTATUS_MIE_BIT]                             ;
          mstatus_mpie_cs <= csr_wdata[CSR_MSTATUS_MPIE_BIT]                             ;
          mstatus_sie_cs  <= csr_wdata[CSR_MSTATUS_SIE_BIT]                              ;
          mstatus_spie_cs <= csr_wdata[CSR_MSTATUS_SPIE_BIT]                             ;
          mstatus_mpp_cs  <= csr_wdata[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] ;
          mstatus_spp_cs  <= csr_wdata[CSR_MSTATUS_SPP] ;

          mstatus_mprv_cs <= csr_wdata[CSR_MSTATUS_MPRV_BIT]                            ;
          mstatus_mxr_cs  <= csr_wdata[CSR_MSTATUS_MXR_BIT]                             ;
          mstatus_sum_cs  <= csr_wdata[CSR_MSTATUS_SUM_BIT]                                ;

          mstatus_tsr_cs <= csr_wdata[CSR_MSTATUS_TSR_BIT]                             ;
          mstatus_tw_cs  <= csr_wdata[CSR_MSTATUS_TW_BIT]                                ;
        end





    end


/*------mie register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst) begin
        mie_meie_cs <= 1'b0 ;
        mie_mtie_cs <= 1'b0 ;
        mie_seie_cs <= 1'b0 ;
        mie_stie_cs <= 1'b0 ;
      end
      else if (csr_we && i_riscv_csr_address == CSR_MIE )

        begin

          mie_mtie_cs <= csr_wdata[M_TIMER_I];  
          mie_meie_cs <= csr_wdata[M_EXT_I];     
          mie_stie_cs <= csr_wdata[S_TIMER_I];
          mie_seie_cs <= csr_wdata[S_EXT_I];
        end

    end 



/*------mip register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)
        begin

          //mip
          mip_meip_cs <= 1'b0 ;
          mip_mtip_cs <= 1'b0 ;
          mip_seip_cs <= 1'b0 ;
          mip_stip_cs <= 1'b0 ;
        end

      else if (csr_we && i_riscv_csr_address == CSR_MIP )

        begin

          mip_mtip_cs <= csr_wdata[M_TIMER_I];     
          mip_meip_cs <= csr_wdata[M_EXT_I];     
          mip_stip_cs <= csr_wdata[S_TIMER_I];
          mip_seip_cs <= csr_wdata[S_EXT_I];
        end

    end 


/*------mtvec register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)
        begin


          //mtvec
          mtvec_base_cs <= 'hFFFFF;
          mtvec_mode_cs <= 2'b00 ;
        end
      else if (csr_we && i_riscv_csr_address == CSR_MTVEC)

        begin
          mtvec_base_cs <= csr_wdata[63:2];
          mtvec_mode_cs <= csr_wdata[0] ;

          if (csr_wdata[0]) 
            begin
              mtvec_base_cs <= {csr_wdata[63:8] , 6'b0 };
              mtvec_mode_cs <= csr_wdata[0] ;
            end

        end




    end   /*---of always block*/

/*------medeleg register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)

        medeleg_cs <= 'b0 ;
      else if (csr_we && i_riscv_csr_address == CSR_MEDELEG)
        medeleg_cs <= csr_wdata[15:0] ;


    end  /*---of always block*/




/*------mideleg register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)
        begin

          mideleg_mei_cs <= 1'b0 ;
          mideleg_mti_cs <= 1'b0 ;
          mideleg_sei_cs <= 1'b0 ;
          mideleg_sti_cs <= 1'b0 ;
        end
      else if (csr_we && i_riscv_csr_address == CSR_MIDELEG)
        begin
          mideleg_mti_cs <= csr_wdata[M_TIMER_I]      ;
          mideleg_mei_cs <= csr_wdata[M_EXT_I]        ;
          mideleg_sti_cs <= csr_wdata[S_TIMER_I]       ;
          mideleg_sei_cs <= csr_wdata[S_EXT_I]        ;

        end

    end   /*---of always block*/


/*------mepc register-----
--- (address of interrupted instruction)*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)

        mepc_cs <= 64'b0;

      else if(go_to_trap && !i_riscv_csr_globstall)
        mepc_cs <= i_riscv_csr_pc ;

      else if (csr_we && i_riscv_csr_address == CSR_MEPC && !i_riscv_csr_globstall)

        mepc_cs <= {csr_wdata[63:1],1'b0};

    end

/*------mscratch register-----
(dedicated for use by machine code) */
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)

        mscratch_cs <= 64'b0;

      else if (csr_we && i_riscv_csr_address == CSR_MSCRATCH)

        mscratch_cs <= csr_wdata;


    end 

/*------mtval register-----
(exception-specific information to assist software in handling trap)*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)

        mtval_cs <= 64'b0;

      else if(i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned)
        mtval_cs <= i_riscv_csr_addressALU;

      else if (csr_we && i_riscv_csr_address == CSR_MTVAL)
        mtval_cs <= csr_wdata;
    end

  always_comb begin
    if(illegal_total | i_riscv_csr_ecall_u |i_riscv_csr_ecall_s | i_riscv_csr_ecall_m  | i_riscv_csr_inst_addr_misaligned  | i_riscv_csr_load_addr_misaligned | i_riscv_csr_store_addr_misaligned)
      is_exception = 1'b1 ;
    else
      is_exception = 1'b0 ;
  end

/*------returnfromTrap register-----*/
  always_comb
    begin
      if (mret)

        o_riscv_csr_returnfromTrap_cs = 1 ;


      else   o_riscv_csr_returnfromTrap_cs =0 ;

    end   /*---of always block*/


/*------priv_lvl register-----*/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)

        priv_lvl_cs <= PRIV_LVL_M;

      else  if(go_to_trap )

        priv_lvl_cs <= PRIV_LVL_M      ;
      else if (mret)

        // restore the previous privilege level
        priv_lvl_cs <= mstatus_mpp_cs;

    end   /*---of always block---*/


/*------mcause register-----
--- (indicates cause of trap(either interrupt or exception)) --- */

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if     (i_riscv_csr_rst)
        begin

          mcause_code_cs      <= 4'b0000;
          mcause_int_excep_cs <= 1'b0 ;
        end
      else if( go_to_trap )
        begin

          if(external_interrupt_pending_m)
            begin
              mcause_code_cs      <= M_EXT_I;
              mcause_int_excep_cs <= 1;
            end
          else if(timer_interrupt_pending_m)
            begin
              mcause_code_cs      <= M_TIMER_I;
              mcause_int_excep_cs <= 1;
            end
          else if(i_riscv_csr_illegal_inst)
            begin
              mcause_code_cs      <= ILLEGAL_INSTRUCTION;
              mcause_int_excep_cs <= 0 ;
            end
          else if(i_riscv_csr_inst_addr_misaligned)
            begin
              mcause_code_cs      <= INSTRUCTION_ADDRESS_MISALIGNED;
              mcause_int_excep_cs <= 0;
            end
          else if(i_riscv_csr_ecall_m)
            begin
              mcause_code_cs      <= ECALL_M;
              mcause_int_excep_cs <= 0;
            end
          else if(i_riscv_csr_load_addr_misaligned)
            begin
              mcause_code_cs      <= LOAD_ADDRESS_MISALIGNED;
              mcause_int_excep_cs <= 0;
            end
          else if(i_riscv_csr_store_addr_misaligned)
            begin
              mcause_code_cs      <= STORE_ADDRESS_MISALIGNED;
              mcause_int_excep_cs <= 0;
            end
        end   /*---of gototrap---*/
      else if (csr_we && i_riscv_csr_address == CSR_MCAUSE)
        begin

          mcause_int_excep_cs <= csr_wdata[63];
          mcause_code_cs      <= csr_wdata[3:0];
        end


    end    /*---of always block---*/


  /*------mcountinhibit register-----*/

  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
    begin
      if (i_riscv_csr_rst)

        mcountinhibit <= 3'b0;

      else if (csr_we && i_riscv_csr_address == CSR_MCOUNTINHIBIT)
        mcountinhibit <= csr_wdata[2:0];

    end 

  /*------MCYCLE-----*/
  always @(*)
    begin
      mcounter_we[0] <= 1'b0;
      if (csr_we && i_riscv_csr_address == CSR_MCYCLE)
        mcounter_we[0] <= 1'b1;
    end
  /*------MINSTRET-----*/
  always @(*)
    begin
      mcounter_we[2] <= 1'b0;
      if (csr_we && i_riscv_csr_address == CSR_MINSTRET)
        mcounter_we[2] <= 1'b1;
    end

  /*----------------  */
  // CSR OP Select Logic
  /* ---------------- */

  always_comb begin : csr_op_logic

    csr_wdata = i_riscv_csr_wdata;
    csr_we    = (!i_riscv_csr_globstall)? 1'b1:1'b0;
    csr_read  = 1'b1;
    mret      = 1'b0;
    sret      = 1'b0;

    case (i_riscv_csr_op)
      CSR_WRITE : csr_wdata = i_riscv_csr_wdata;
      CSR_SET   : csr_wdata = i_riscv_csr_wdata | csr_rdata_int;
      CSR_CLEAR : csr_wdata = (~i_riscv_csr_wdata) & csr_rdata_int;
      CSR_READ  : csr_we    = 1'b0 ;
      SRET      : begin
        csr_we   = 1'b0;
        csr_read = 1'b0;
        sret     = 1'b1; 
      end
      MRET : begin
        csr_we   = 1'b0;
        csr_read = 1'b0;
        mret     = 1'b1; 
      end

      default : begin
        csr_we   = 1'b0;
        csr_read = 1'b0;
      end
    endcase
  end
// mcycle counter
  riscv_counter mcycle_counter (
    .clk     (i_riscv_csr_clk                      ),
    .rst     (i_riscv_csr_rst                      ),
    .write_en(mcounter_we[0]                       ),
    .incr_en (mcounter_incr[0] && !mcountinhibit[0]),
    .i_value (csr_wdata                            ),
    .o_value (mcounter[0]                          )
  );

//minstret counter
  riscv_counter minstret_counter (
    .clk     (i_riscv_csr_clk                      ),
    .rst     (i_riscv_csr_rst                      ),
    .write_en(mcounter_we[2]                       ),
    .incr_en (mcounter_incr[2] && !mcountinhibit[2]),
    .i_value (csr_wdata                            ),
    .o_value (mcounter[2]                          )
  );

  /*-----------------*/
  //    output mux   //
  /* ----------------*/
  always_comb begin : csr_read_out_process
    o_riscv_csr_rdata = csr_rdata_int;
  end
  
endmodule
