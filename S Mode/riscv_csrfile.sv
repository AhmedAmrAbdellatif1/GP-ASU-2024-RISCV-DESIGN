module riscv_csrfile 

 #( parameter MXLEN              = 64   ,
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
    input   logic [63:0]        i_riscv_csr_timer_time            ,
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
    input   logic               i_riscv_csr_instret               ,
    output  logic [MXLEN-1:0]   o_riscv_csr_rdata                 ,
    output  logic [MXLEN-1:0]   o_riscv_csr_return_address        , 
    output  logic [MXLEN-1:0]   o_riscv_csr_trap_address          ,   
    output  logic               o_riscv_csr_gotoTrap_cs           , 
    output  logic [1:0]         o_riscv_csr_returnfromTrap        ,
    output  logic [1:0]         o_riscv_csr_privlvl               ,
    output  logic [SXLEN-1:0]   o_riscv_sepc                      ,
    output  logic               o_riscv_csr_tsr
  );

  /****************************** localparams Declaration ******************************/
  enum  {
    SIE   = 'd1  ,
    MIE   = 'd3  ,
    SPIE  = 'd5  ,
    UBE   = 'd6  ,
    MPIE  = 'd7  ,
    SPP   = 'd8  ,
    MPP0  = 'd11 ,
    MPP1  = 'd12 ,
    MPRV  = 'd17 ,
    SUM   = 'd18 ,
    MXR   = 'd19 ,
    TVM   = 'd20 ,
    TW    = 'd21 ,
    TSR   = 'd22 ,
    UXL0  = 'd32 ,
    UXL1  = 'd33 ,
    SXL0  = 'd34 ,
    SXL1  = 'd35 ,
    SBE   = 'd36 ,
    MBE   = 'd37 
  } mstatus_bits ;
 
  //CSR addresses
  //machine info
  enum logic [11:0] {
    MVENDORID             = 12'hF11,
    MARCHID               = 12'hF12,
    MIMPID                = 12'hF13,
    MHARTID               = 12'hF14,
    MSTATUS               = 12'h300,
    MISA                  = 12'h301,
    CSR_MIE               = 12'h304,
    MTVEC                 = 12'h305,
    MSCRATCH              = 12'h340,
    MEPC                  = 12'h341,
    MCAUSE                = 12'h342,
    MTVAL                 = 12'h343,
    MIP                   = 12'h344,
    MEDELEG               = 12'h302,
    MIDELEG               = 12'h303,
    MCONFIGPTR            = 12'hF15,
    MTINST                = 12'h34A,
    SSTATUS               = 12'h100,
    CSR_SIE               = 12'h104,
    STVEC                 = 12'h105,
    SCOUNTEREN            = 12'h106,
    SSCRATCH              = 12'h140,
    SEPC                  = 12'h141,
    SCAUSE                = 12'h142,
    STVAL                 = 12'h143,
    SIP                   = 12'h144,
    SATP                  = 12'h180,
    MENVCFG               = 12'h30A,
    SENVCFG               = 12'h10A,
    MCOUNTEREN            = 12'h306,
    TIME                  = 12'hC01,
    MINSTRET              = 12'hB02,
    MCYCLE                = 12'hB00,
    MCOUNTINHIBIT         = 12'h320,
    CSR_MHPM_EVENT_3      = 12'h323,  
    CSR_MHPM_EVENT_4      = 12'h324,  
    CSR_MHPM_EVENT_5      = 12'h325,  
    CSR_MHPM_EVENT_6      = 12'h326,  
    CSR_MHPM_EVENT_7      = 12'h327,  
    CSR_MHPM_EVENT_8      = 12'h328,  
    CSR_MHPM_EVENT_9      = 12'h329,  
    CSR_MHPM_EVENT_10     = 12'h32A,  
    CSR_MHPM_EVENT_11     = 12'h32B,  
    CSR_MHPM_EVENT_12     = 12'h32C,  
    CSR_MHPM_EVENT_13     = 12'h32D,  
    CSR_MHPM_EVENT_14     = 12'h32E,  
    CSR_MHPM_EVENT_15     = 12'h32F,  
    CSR_MHPM_EVENT_16     = 12'h330,  
    CSR_MHPM_EVENT_17     = 12'h331,  
    CSR_MHPM_EVENT_18     = 12'h332,  
    CSR_MHPM_EVENT_19     = 12'h333,  
    CSR_MHPM_EVENT_20     = 12'h334,  
    CSR_MHPM_EVENT_21     = 12'h335,  
    CSR_MHPM_EVENT_22     = 12'h336,  
    CSR_MHPM_EVENT_23     = 12'h337,  
    CSR_MHPM_EVENT_24     = 12'h338,  
    CSR_MHPM_EVENT_25     = 12'h339,  
    CSR_MHPM_EVENT_26     = 12'h33A,  
    CSR_MHPM_EVENT_27     = 12'h33B,  
    CSR_MHPM_EVENT_28     = 12'h33C,  
    CSR_MHPM_EVENT_29     = 12'h33D,  
    CSR_MHPM_EVENT_30     = 12'h33E,  
    CSR_MHPM_EVENT_31     = 12'h33F,  
    CSR_MHPM_COUNTER_3    = 12'hB03,
    CSR_MHPM_COUNTER_4    = 12'hB04,
    CSR_MHPM_COUNTER_5    = 12'hB05,
    CSR_MHPM_COUNTER_6    = 12'hB06,
    CSR_MHPM_COUNTER_7    = 12'hB07,
    CSR_MHPM_COUNTER_8    = 12'hB08,
    CSR_MHPM_COUNTER_9    = 12'hB09,  
    CSR_MHPM_COUNTER_10   = 12'hB0A,  
    CSR_MHPM_COUNTER_11   = 12'hB0B,  
    CSR_MHPM_COUNTER_12   = 12'hB0C,  
    CSR_MHPM_COUNTER_13   = 12'hB0D,  
    CSR_MHPM_COUNTER_14   = 12'hB0E,  
    CSR_MHPM_COUNTER_15   = 12'hB0F,  
    CSR_MHPM_COUNTER_16   = 12'hB10,  
    CSR_MHPM_COUNTER_17   = 12'hB11,  
    CSR_MHPM_COUNTER_18   = 12'hB12,  
    CSR_MHPM_COUNTER_19   = 12'hB13,  
    CSR_MHPM_COUNTER_20   = 12'hB14,  
    CSR_MHPM_COUNTER_21   = 12'hB15,  
    CSR_MHPM_COUNTER_22   = 12'hB16,  
    CSR_MHPM_COUNTER_23   = 12'hB17,  
    CSR_MHPM_COUNTER_24   = 12'hB18,  
    CSR_MHPM_COUNTER_25   = 12'hB19,  
    CSR_MHPM_COUNTER_26   = 12'hB1A,  
    CSR_MHPM_COUNTER_27   = 12'hB1B,  
    CSR_MHPM_COUNTER_28   = 12'hB1C,  
    CSR_MHPM_COUNTER_29   = 12'hB1D,  
    CSR_MHPM_COUNTER_30   = 12'hB1E,  
    CSR_MHPM_COUNTER_31   = 12'hB1F
  } csr_registers ; 
 
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
  localparam STI    =  5  ,
            MTI    =  7  ,
            SEI      =  9  ,
            MEI      =  11 ;
 
  //exceptions
  localparam INSTRUCTION_ADDRESS_MISALIGNED = 0  ,
            ILLEGAL_INSTRUCTION            = 2  ,
            LOAD_ADDRESS_MISALIGNED        = 4  ,
            STORE_ADDRESS_MISALIGNED       = 6  ,
            ECALL_U                        = 8  ,
            ECALL_S                        = 9  ,
            ECALL_M                        = 11 ;

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
   
  /****************************** CSR Registers Implementation ******************************/

  logic   [1:0]     current_priv_lvl  ; //  Privilege levels are used to provide protection between different components of the software stack
  logic [MXLEN-1:0] mepc              ;
  logic [MXLEN-1:0] mscratch          ; //  Dedicated for use by machine code
  logic [MXLEN-1:0] mtval             ; //  Exception-specific infotmation to assist software in handling trap
  logic [15:0]      medeleg           ;
  logic [15:0]      mideleg           ;

  struct packed {
    logic [MXLEN-3:0] base            ; //  Address of pc taken after returning from Trap (via MRET)
    logic   [1:0]     mode            ; //  Vector mode addressing  >>  vectored or direc
  } mtvec ;

  struct packed {
    logic       sie   ;
    logic       mie   ; 
    logic       spie  ;
    logic       mpie  ; 
    logic       spp   ;
    logic [1:0] mpp   ;
    logic       mxr   ;
    logic       tvm   ;
    logic       tw    ;
    logic       tsr   ;
  } mstatus ; 

  struct packed {
    logic       stie  ; //  Supervisor timer interrupt enable
    logic       mtie  ; //  Machine timer interrupt enable
    logic       seie  ; //  Supervisor external exception enable 
    logic       meie  ; //  Machine external exception enable
  } mie ;
        
  struct packed {
    logic       stip  ; //  Supervisor timer interrupt pending    
    logic       mtip  ; //  Machine timer interrupt pending       
    logic       seip  ; //  Supervisor external exception pending 
    logic       meip  ; //  Machine external exception pending    
  } mip ;
  
  struct packed {
    logic       int_excep   ; //  Interrupt(1) or exception(0)
    logic [3:0] code        ; //  Indicates event that caused the trap
  } mcause ;


  //************************//

  logic [SXLEN-1:0] stval     ;
  logic [SXLEN-1:0] sscratch  ;
  logic [SXLEN-1:0] sepc      ;
  
  struct packed {
    logic         int_excep   ; //  Interrupt(1) or exception(0)
    logic  [3:0]  code        ; //  Indicates event that caused the trap
  } scause ;

  struct packed {
    logic [SXLEN-3:0] base    ; //  Address of pc taken after returning from Trap (via MRET)
    logic   [1:0]     mode    ; //  Vector mode addressing >> vectored or direct
  } stvec ;
  
  
  /****************************** Internal Flags Declaration ******************************/
  logic             is_exception                  ; 
  logic             is_interrupt                  ; 
                  
  logic             is_trap                       ;
  logic             go_to_trap                    ;

  logic             illegal_total                 ;
  logic             illegal_priv_access           ;
  logic             illegal_write_access          ;
  logic             illegal_read_access           ; 
  logic             illegal_csr_access            ;

  logic             csr_write_en                  ;
  logic [MXLEN-1:0] csr_write_data                ;
  logic             csr_write_access_en           ; 
  
  logic             csr_read_en                   ;
  logic [MXLEN-1:0] csr_read_data                 ;
  logic             m_external_ack                ; 
  logic             s_external_ack                ; 
  logic             mret                          ;
  logic             sret                          ;

  logic [1:0]       trap_to_priv_lvl              ;

  logic [MXLEN-1:0] trap_base_addr                ;
  
  logic [5:0]       interrupt_cause               ;
  logic [5:0]       exception_cause               ;

  logic             interrupt_global_enable       ;
  logic             interrupt_go_s                ;
  logic             interrupt_go_m                ;
  logic             valid                         ;

  logic             mei_pending                   ;
  logic             mti_pending                   ;  

  logic             sei_pending                   ;
  logic             sti_pending                   ;

  logic             no_delegation                 ;
  logic             force_s_delegation            ;

  logic [1:0]       xtvec_base                    ;
  logic             ack_external_int              ;
  
  logic [1:0]       mcountinhibit                 ;
  logic [MXLEN-1:0] mcounter [2]                  ;
  logic [1:0]       mcounter_we                   ;
  logic [1:0]       mcounter_incr                 ;
  
  
  /************************************* ********************** *************************************/
  /*************************************     CSR Read Logic     *************************************/
  /************************************* ********************** *************************************/

  always_comb
  begin : csr_read_process

    csr_read_data       = 64'b0 ;
    illegal_read_access = 1'b0  ;

    if(csr_read_en)
    begin 
      case(i_riscv_csr_address)

        /********* Machine-Mode Registers *********/
        MVENDORID : csr_read_data = 64'b0     ; // not implemented
           
        MISA      : csr_read_data = ISA_CODE  ;
             
        MARCHID   : csr_read_data = 64'b0     ; 
      
        MIMPID    : csr_read_data = 64'b0     ; // not implemented
          
        MHARTID   : csr_read_data = 64'b0     ;
          
        MSTATUS   :
        begin
          csr_read_data[SXL1:SXL0]  = (support_supervisor) ? 2'b10 : 2'b00 ;
          csr_read_data[UXL1:UXL0]  =  (support_user)      ? 2'b10 : 2'b00 ;
          csr_read_data[SIE]        = mstatus.sie   ;
          csr_read_data[MIE]        = mstatus.mie   ;
          csr_read_data[SPIE]       = mstatus.spie  ;
          csr_read_data[MPIE]       = mstatus.mpie  ;
          csr_read_data[SPP ]       = mstatus.spp   ;
          csr_read_data[MPP1:MPP0]  = mstatus.mpp   ;
          csr_read_data[MXR]        = mstatus.mxr   ;
          csr_read_data[TVM]        = mstatus.tvm   ;
          csr_read_data[TW]         = mstatus.tw    ;
          csr_read_data[TSR]        = mstatus.tsr   ;
        end

        MTVEC     :
        begin
          csr_read_data [1:0]       = mtvec.mode  ;
          csr_read_data [MXLEN-1:2] = mtvec.base  ; 
        end

        MEDELEG   :  csr_read_data[15:0] = medeleg ;

        MIDELEG   :
        begin
          csr_read_data[MTI]  = mideleg[MTI] ;
          csr_read_data[MEI]  = mideleg[MEI] ;
          csr_read_data[STI]  = mideleg[STI] ;
          csr_read_data[SEI]  = mideleg[SEI] ;

        end
        CSR_MIE   :
        begin
          csr_read_data[MTI]  = mie.mtie  ;
          csr_read_data[MEI]  = mie.meie  ;
          csr_read_data[STI]  = mie.stie  ;
          csr_read_data[SEI]  = mie.seie  ;
        end

        MIP       :
        begin
          csr_read_data[MTI]  = mip.mtip  ;
          csr_read_data[MEI]  = mip.meip  ;
          csr_read_data[STI]  = mip.stip  ;
          csr_read_data[SEI]  = mip.seip  ;
        end
        
        MSCRATCH  : csr_read_data = mscratch ;

        MEPC      : csr_read_data = mepc ;

        MCAUSE    : csr_read_data = { mcause.int_excep, 59'b0, mcause.code };

        MTVAL     : csr_read_data = mtval;
        
        
        /********* Supervisor-Mode Registers *********/
        CSR_SIE   :
        begin
          csr_read_data[STI]  = mie.stie && mideleg[MTI];
          csr_read_data[SEI]  = mie.seie && mideleg[MEI];

        end
        SIP       :
        begin
          csr_read_data[STI]  = mip.stip && mideleg[MTI];
          csr_read_data[SEI]  = mip.seip && mideleg[MEI];
        end

        STVAL     : csr_read_data = stval;
          
        SSCRATCH  : csr_read_data = sscratch;
          
        SEPC      : csr_read_data = sepc;
          
        SCAUSE    : csr_read_data =  { scause.int_excep, 59'b0, scause.code };

        STVEC     :
        begin
          csr_read_data [1:0]       = stvec.mode;
          csr_read_data [SXLEN-1:2] = stvec.base;
        end
      
        SSTATUS   :
        begin
          csr_read_data[SIE ]       = mstatus.sie     ;
          csr_read_data[SPIE]       = mstatus.spie    ;
          csr_read_data[SPP ]       = mstatus.spp     ;
          csr_read_data[MXR ]       = mstatus.mxr     ;
          csr_read_data[UXL1:UXL0]  = (support_user)  ? 2'b10 : 2'b00 ;
        end

        TIME         : csr_read_data       =    i_riscv_csr_timer_time               ;
        MCOUNTINHIBIT: 
        begin
           csr_read_data [0] =   mcountinhibit[0];
           csr_read_data [2] =   mcountinhibit[1]; 
        end
        MCYCLE       : csr_read_data       =   mcounter[0]                           ;
        MINSTRET     : csr_read_data       =   mcounter[1]                           ;
      
        SATP        ,
        MCONFIGPTR  ,
        MENVCFG     ,
        SENVCFG     ,
        MCOUNTEREN  ,
        SCOUNTEREN  :   csr_read_data = 64'b0;

        CSR_MHPM_EVENT_3    , CSR_MHPM_EVENT_4      ,  
        CSR_MHPM_EVENT_5    , CSR_MHPM_EVENT_6      ,  
        CSR_MHPM_EVENT_7    , CSR_MHPM_EVENT_8      ,  
        CSR_MHPM_EVENT_9    , CSR_MHPM_EVENT_10     ,  
        CSR_MHPM_EVENT_11   , CSR_MHPM_EVENT_12     ,  
        CSR_MHPM_EVENT_13   , CSR_MHPM_EVENT_14     ,  
        CSR_MHPM_EVENT_15   , CSR_MHPM_EVENT_16     ,  
        CSR_MHPM_EVENT_17   , CSR_MHPM_EVENT_18     ,  
        CSR_MHPM_EVENT_19   , CSR_MHPM_EVENT_20     ,  
        CSR_MHPM_EVENT_21   , CSR_MHPM_EVENT_22     ,  
        CSR_MHPM_EVENT_23   , CSR_MHPM_EVENT_24     ,  
        CSR_MHPM_EVENT_25   , CSR_MHPM_EVENT_26     ,  
        CSR_MHPM_EVENT_27   , CSR_MHPM_EVENT_28     ,  
        CSR_MHPM_EVENT_29   , CSR_MHPM_EVENT_30     ,  
        CSR_MHPM_EVENT_31   ,  
        CSR_MHPM_COUNTER_3  , CSR_MHPM_COUNTER_4    ,
        CSR_MHPM_COUNTER_5  , CSR_MHPM_COUNTER_6    ,
        CSR_MHPM_COUNTER_7  , CSR_MHPM_COUNTER_8    ,
        CSR_MHPM_COUNTER_9  , CSR_MHPM_COUNTER_10   ,  
        CSR_MHPM_COUNTER_11 , CSR_MHPM_COUNTER_12   ,  
        CSR_MHPM_COUNTER_13 , CSR_MHPM_COUNTER_14   ,  
        CSR_MHPM_COUNTER_15 , CSR_MHPM_COUNTER_16   ,  
        CSR_MHPM_COUNTER_17 , CSR_MHPM_COUNTER_18   ,  
        CSR_MHPM_COUNTER_19 , CSR_MHPM_COUNTER_20   ,  
        CSR_MHPM_COUNTER_21 , CSR_MHPM_COUNTER_22   ,  
        CSR_MHPM_COUNTER_23 , CSR_MHPM_COUNTER_24   ,   
        CSR_MHPM_COUNTER_25 , CSR_MHPM_COUNTER_26   ,  
        CSR_MHPM_COUNTER_27 , CSR_MHPM_COUNTER_28   ,  
        CSR_MHPM_COUNTER_29 , CSR_MHPM_COUNTER_30   ,  
        CSR_MHPM_COUNTER_31                         : csr_read_data = 'b0 ;  

        default :
        begin
          illegal_read_access = 1'b1 ;
          csr_read_data       = 64'b0;
        end
      endcase
    end 
  end

  /************************************* ******************  *************************************/
  /*************************************   CSR Write Logic   *************************************/
  /************************************* ******************  *************************************/

  /******************************     MSTATUS & SSTATUS      ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_mstatus_proc
    
    if(i_riscv_csr_rst)
    begin
      mstatus <= 'b0;
    end

    else if(go_to_trap)
    begin
      // trap to machine mode
      if((((current_priv_lvl == PRIV_LVL_M) || no_delegation) && is_exception)|| interrupt_go_m )
      begin
        mstatus.mie   <= 1'b0;
        mstatus.mpie  <= mstatus.mie;
        mstatus.mpp   <= current_priv_lvl;
      end
      // trap to supervisor mode
      else if((force_s_delegation && is_exception) || interrupt_go_s )
      begin
        mstatus.sie   <= 1'b0;
        mstatus.spie  <= mstatus.sie;
        mstatus.spp   <= current_priv_lvl[0];
      end
    end

    else if(mret)
    begin
      mstatus.mie     <= mstatus.mpie;
      mstatus.mpie    <= 1'b1;
      mstatus.mpp     <= (support_user)? PRIV_LVL_U:PRIV_LVL_M;
    end

    else if(sret)
      begin
        mstatus.sie   <= mstatus.spie;
        mstatus.spie  <= 1'b1; 
        mstatus.spp   <= 1'b0;
      end

    // mstatus writing
    else if(csr_write_access_en && (i_riscv_csr_address == MSTATUS))
    begin
      mstatus.sie     <= csr_write_data[SIE]        ;
      mstatus.mie     <= csr_write_data[MIE]        ;
      mstatus.spie    <= csr_write_data[SPIE]       ;
      mstatus.mpie    <= csr_write_data[MPIE]       ;
      mstatus.spp     <= csr_write_data[SPP]        ;
      mstatus.mpp     <= csr_write_data[MPP1:MPP0]  ;
      mstatus.mxr     <= csr_write_data[MXR]        ;
      mstatus.tvm     <= csr_write_data[TVM]        ;
      mstatus.tw      <= csr_write_data[TW]         ;
      mstatus.tsr     <= csr_write_data[TSR]        ;  
    end

    // sstatus writing
    else if(csr_write_access_en && (i_riscv_csr_address == SSTATUS))
    begin
      mstatus.sie     <= csr_write_data[SIE]        ;
      mstatus.spie    <= csr_write_data[SPIE]       ;
      mstatus.spp     <= csr_write_data[SPP]        ;
      mstatus.mxr     <= csr_write_data[MXR]        ;
    end

  end

  /******************************         MIE AND SIE        ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_mie_proc
    if(i_riscv_csr_rst)
    begin
      mie.meie  <=  1'b0 ;
      mie.mtie  <=  1'b0 ;
      mie.seie  <=  1'b0 ;
      mie.stie  <=  1'b0 ;
    end

    /*------ mie register -----*/
    else if(csr_write_access_en && (i_riscv_csr_address == CSR_MIE) )
    begin
      mie.mtie  <= csr_write_data[MTI]  ;    
      mie.meie  <= csr_write_data[MEI]  ;    
      mie.stie  <= csr_write_data[STI]  ;
      mie.seie  <= csr_write_data[SEI]  ;
    end

    /*------ sie register -----*/
    else if(csr_write_access_en && (i_riscv_csr_address == CSR_SIE) )
    begin
      if(support_supervisor)
      begin
        mie.stie  <= (!mideleg[MTI])? mie.stie : csr_write_data[STI];
        mie.seie  <= (!mideleg[MEI])? mie.seie : csr_write_data[SEI];
      end
    end 
  end

  /******************************         MIE AND SIE        ******************************/
  always @(posedge i_riscv_csr_clk or posedge i_riscv_csr_rst)
  begin : write_mip_proc
    if(i_riscv_csr_rst)
    begin
      mip.meip  <=  1'b0 ;
      mip.mtip  <=  1'b0 ;
      mip.seip  <=  1'b0 ;
      mip.stip  <=  1'b0 ;
    end

    else if(csr_write_access_en && (i_riscv_csr_address == MIP))
    begin
      mip.seip  <=  csr_write_data[SEI];
      mip.stip  <=  csr_write_data[STI];
    end
    
    else if(ack_external_int || i_riscv_csr_timer_int || i_riscv_csr_external_int)
    begin
      case (ack_external_int)
        1'b1  : 
        begin
          if (m_external_ack)
            mip.meip <= 1'b0 ;
          else if (s_external_ack)
            mip.seip <= 1'b0 ;
        end
        1'b0  :
        begin
          mip.meip <= i_riscv_csr_external_int ;
        end
      endcase
      mip.mtip <= i_riscv_csr_timer_int;
    end
  end

  /******************************            MTVEC           ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_mtvec_proc
    if(i_riscv_csr_rst)
    begin
      mtvec.base  <= 62'b10010;
      mtvec.mode  <=  2'b00   ;
    end

    else if(csr_write_access_en && (i_riscv_csr_address == MTVEC))
    begin
      if (csr_write_data[0])  //we are in vector mode, as LSB=1
      begin
        mtvec.base   <= {csr_write_data[63:8], 6'b0};
        mtvec.mode   <=  csr_write_data[0]          ;
      end
      else
      begin
        mtvec.base   <= csr_write_data[63:2];
        mtvec.mode   <= csr_write_data[0]   ;
      end
    end
  end

  /******************************            STVEC           ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_stvec_proc
    if(i_riscv_csr_rst)
    begin
      stvec.base    <= 62'b11001; 
      stvec.mode    <=  2'b00   ;
    end

    else if(csr_write_access_en && (i_riscv_csr_address == STVEC))
    begin
      if (csr_write_data[0])  //we are in vector mode, as LSB =1
      begin
        stvec.base  <= {csr_write_data[63:8], 6'b0  };
        stvec.mode  <=  csr_write_data[0]            ;
      end
      else
      begin
        stvec.base  <= csr_write_data[63:2] ;
        stvec.mode  <= csr_write_data[0]    ;  
      end
    end
  end

  /******************************          MEDELEG           ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_medeleg_proc

    if(i_riscv_csr_rst)
      medeleg <= 16'b0 ;

    else if(csr_write_access_en && (i_riscv_csr_address == MEDELEG))
      medeleg <=  {csr_write_data[15:11],1'b0,csr_write_data[9:0]};

  end

  /******************************          MIDELEG           ******************************/
  always @(posedge i_riscv_csr_clk or posedge i_riscv_csr_rst)
  begin : write_mideleg_proc

    if(i_riscv_csr_rst)
    begin
      mideleg <= 16'b0;
    end

    else if(csr_write_access_en && (i_riscv_csr_address == MIDELEG))
    begin
      if(support_supervisor)
      begin
        mideleg[MTI]  <=  csr_write_data[MTI] ;
        mideleg[MEI]  <=  csr_write_data[MEI] ;
        mideleg[STI]  <=  csr_write_data[STI] ;
        mideleg[SEI]  <=  csr_write_data[SEI] ;
      end
    end

  end

  /******************************            MEPC            ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin

    if(i_riscv_csr_rst)
      mepc <= 64'b0;


    else if((((current_priv_lvl == PRIV_LVL_M) || no_delegation) && is_exception)|| interrupt_go_m )
       mepc <= i_riscv_csr_pc ;


    else if(csr_write_access_en && (i_riscv_csr_address == MEPC) )
      mepc <= {csr_write_data[63:1],1'b0};

  end 

  /******************************            SEPC            ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin

    if(i_riscv_csr_rst)
      sepc <= 64'b0;

    else if(((force_s_delegation && is_exception) || interrupt_go_s))
    begin
      sepc <= i_riscv_csr_pc ;
    end
      
    else if(csr_write_access_en && (i_riscv_csr_address == SEPC))
      sepc <= {csr_write_data[63:1],1'b0};
  end 


  /******************************          MSCRATCH          ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      mscratch <= 64'b0;

    else if (csr_write_access_en && (i_riscv_csr_address == MSCRATCH))
      mscratch <= csr_write_data;
  end

  /******************************          SSCRATCH          ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      sscratch <= 64'b0;

    else if (csr_write_access_en && (i_riscv_csr_address == SSCRATCH))
      sscratch <= csr_write_data;
  end
 
  /******************************           MTVAL            ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      mtval <= 64'b0  ;

    else if( (i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned) && ((current_priv_lvl == PRIV_LVL_M) || no_delegation))
      mtval <= i_riscv_csr_addressALU ;

    else if(illegal_total && ((current_priv_lvl == PRIV_LVL_M) || no_delegation) )
      mtval <= (i_riscv_csr_is_compressed)? { {48{1'b0}}, i_riscv_csr_cinst } : { {32{1'b0}}, i_riscv_csr_inst } ;

    else if (csr_write_access_en && (i_riscv_csr_address == MTVAL))
      mtval <= csr_write_data ;
  end


  /******************************           STVAL            ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      stval <= 64'b0;
    
    else if((i_riscv_csr_load_addr_misaligned || i_riscv_csr_store_addr_misaligned) && force_s_delegation)
      stval <= i_riscv_csr_addressALU;

    else if(illegal_total && force_s_delegation)
      stval <= (i_riscv_csr_is_compressed)? { {48{1'b0}}, i_riscv_csr_cinst } : { {32{1'b0}}, i_riscv_csr_inst } ;

    else if (csr_write_access_en && i_riscv_csr_address == STVAL)
      stval <= csr_write_data;
  end

  /******************************           MCAUSE           ******************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if(i_riscv_csr_rst)
    begin
      mcause.code       <= 4'b0000  ;
      mcause.int_excep  <= 1'b0     ;
      m_external_ack    <= 1'b0     ;
    end

    //  trap to machine mode
    else if( (is_exception && ((current_priv_lvl == PRIV_LVL_M) || no_delegation)) || interrupt_go_m)
    begin
      if(mei_pending)
      begin
        mcause.code       <= MEI    ;
        mcause.int_excep  <= 1'b1   ;
        m_external_ack    <= 1'b1   ;
      end

      else if(mti_pending)
      begin
        mcause.code       <= MTI     ;
        mcause.int_excep  <= 1'b1    ;
        m_external_ack    <= 1'b0    ;
      end

      else if(sei_pending)
      begin
        mcause.code       <= MEI     ;  
        mcause.int_excep  <= 1'b1    ;
        m_external_ack    <= 1'b0    ;
      end
      
      else if(sti_pending)
      begin
        mcause.code       <= MTI     ;
        mcause.int_excep  <= 1'b1    ;
        m_external_ack    <= 1'b0    ;
      end

      else if(illegal_total)
      begin
        mcause.code       <= ILLEGAL_INSTRUCTION ;
        mcause.int_excep  <= 1'b0                ;
        m_external_ack    <= 1'b0                ;
      end

      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        mcause.code       <= INSTRUCTION_ADDRESS_MISALIGNED ;  
        mcause.int_excep  <= 1'b0                           ;
        m_external_ack    <= 1'b0                           ;
      end

      else if(i_riscv_csr_ecall_m)
      begin
        mcause.code       <= ECALL_M  ;
        mcause.int_excep  <= 1'b0     ;
        m_external_ack    <= 1'b0     ;
      end

      else if(i_riscv_csr_ecall_s)
      begin
        mcause.code       <= ECALL_S  ;
        mcause.int_excep  <= 1'b0     ;
        m_external_ack    <= 1'b0     ;
      end

      else if(i_riscv_csr_ecall_u)
      begin
        mcause.code       <= ECALL_U  ;
        mcause.int_excep  <= 1'b0     ;
        m_external_ack    <= 1'b0     ;
      end
      
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        mcause.code       <= LOAD_ADDRESS_MISALIGNED  ;
        mcause.int_excep  <= 1'b0                     ;
        m_external_ack    <= 1'b0                     ;
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        mcause.code       <= STORE_ADDRESS_MISALIGNED ;
        mcause.int_excep  <= 1'b0                     ;
        m_external_ack    <= 1'b0                     ;
      end
    end

    else if (csr_write_access_en && (i_riscv_csr_address == MCAUSE))
    begin
      mcause.int_excep  <= csr_write_data[63]         ;
      mcause.code       <= csr_write_data[3:0]        ;
      m_external_ack    <= 1'b0                       ;
    end

  end

  /******************************           SCAUSE           ******************************/
  always @(posedge i_riscv_csr_clk or posedge i_riscv_csr_rst)
  begin
    if(i_riscv_csr_rst)
    begin
      scause.code       <= 4'b0000;
      scause.int_excep  <= 1'b0   ;
      s_external_ack    <= 1'b0   ;
    end

    else if(( is_exception && force_s_delegation) || interrupt_go_s)
    begin

      if(sei_pending)
      begin
        scause.code       <= SEI  ; 
        scause.int_excep  <= 1'b1 ;
        s_external_ack    <= 1'b1 ;
      end

      else if(sti_pending)
      begin
        scause.code       <= STI  ;
        scause.int_excep  <= 1'b1 ;
        s_external_ack    <= 1'b0  ;
      end

      else if(illegal_total)
      begin
        scause.code       <= ILLEGAL_INSTRUCTION;
        scause.int_excep  <= 1'b0 ;
        s_external_ack    <= 1'b0 ;
      end

      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        scause.code       <= INSTRUCTION_ADDRESS_MISALIGNED;
        scause.int_excep  <= 1'b0 ;
        s_external_ack    <= 1'b0 ;
      end

      else if(i_riscv_csr_ecall_s)
      begin
        scause.code       <= ECALL_S  ;
        scause.int_excep  <= 1'b0     ;
        s_external_ack    <= 1'b0     ;
      end

      else if(i_riscv_csr_ecall_u)
      begin
        scause.code       <= ECALL_U  ;
        scause.int_excep  <= 1'b0     ;
        s_external_ack    <= 1'b0     ;
      end

      else if(i_riscv_csr_load_addr_misaligned)
      begin
        scause.code       <= LOAD_ADDRESS_MISALIGNED;
        scause.int_excep  <= 1'b0 ;
        s_external_ack    <= 1'b0 ;
      end

      else if(i_riscv_csr_store_addr_misaligned)
      begin
        scause.code       <= STORE_ADDRESS_MISALIGNED;
        scause.int_excep  <= 1'b0 ;
        s_external_ack    <= 1'b0 ;
      end
  
    end

    else if (csr_write_access_en && (i_riscv_csr_address == SCAUSE))
    begin
      scause.int_excep    <= csr_write_data[63];
      scause.code         <= csr_write_data[3:0];
      s_external_ack      <= 1'b0 ;
    end
  end

/******************************           Mcountinhibit           ******************************/

always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst) 
begin    
   if (i_riscv_csr_rst) 
   
            mcountinhibit  <= 2'b0;     

   else if (csr_write_access_en && i_riscv_csr_address == MCOUNTINHIBIT) 
    begin             
            mcountinhibit[0]    <= csr_write_data[0];   
            mcountinhibit[1]    <= csr_write_data[2];   
    end
end 

  /************************************* ********************** *************************************/
  /*************************************   Sequential Always    *************************************/
  /************************************* ********************** *************************************/

  /**********************************   Current Privilege Level    **********************************/
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      current_priv_lvl  <= PRIV_LVL_M;

    else if(go_to_trap)
      current_priv_lvl  <= trap_to_priv_lvl;

    else if(mret)
      current_priv_lvl  <= mstatus.mpp;

    else if(sret)
      current_priv_lvl  <= {1'b0, mstatus.spp};
  end

  
  /************************************* ********************** *************************************/
  /*************************************  Combinational Always  *************************************/
  /************************************* ********************** *************************************/

  /*************************************   CSR Operation Logic  *************************************/
  always_comb
  begin : csr_op_logic
    csr_write_data  = i_riscv_csr_wdata;
    csr_write_en    = (!i_riscv_csr_globstall)? 1'b1:1'b0;
    csr_read_en     = 1'b1;
    mret            = 1'b0;
    sret            = 1'b0;
    case (i_riscv_csr_op)
      CSR_WRITE : csr_write_data  = i_riscv_csr_wdata;
      CSR_SET   : csr_write_data  = i_riscv_csr_wdata | csr_read_data;
      CSR_CLEAR : csr_write_data  = (~i_riscv_csr_wdata) & csr_read_data;
      CSR_READ  : csr_write_en    = 1'b0 ;
      SRET: // signal return from supervisor mode
      begin
        csr_write_en  = 1'b0  ;
        csr_read_en   = 1'b0  ;
        sret          = 1'b1  ;
      end
      MRET: // signal return from machine mode
      begin
        csr_write_en  = 1'b0  ;
        csr_read_en   = 1'b0  ;
        mret          = 1'b1  ;
      end
      default:
      begin
        csr_write_en  = 1'b0  ;
        csr_read_en   = 1'b0  ;
      end
    endcase
  end

  /************************************  Trap's Privilege Level  ************************************/
  always_comb
  begin
    if(go_to_trap)
    begin
      if(support_supervisor && is_interrupt)
      begin
        if(interrupt_go_s)
          trap_to_priv_lvl = PRIV_LVL_S;
        else
          trap_to_priv_lvl = PRIV_LVL_M;
      end

      else if(support_supervisor && is_exception && medeleg[exception_cause[3:0]])
      begin
        if(current_priv_lvl == PRIV_LVL_M)
          trap_to_priv_lvl = PRIV_LVL_M;
        else
          trap_to_priv_lvl = PRIV_LVL_S;
      end

      else
      begin
        trap_to_priv_lvl = PRIV_LVL_M;
      end
    end

    else
      trap_to_priv_lvl = PRIV_LVL_M;
  end

  /*************************************   Trap Base Address    *************************************/
  always_comb
  begin
    case (xtvec_base)
      2'b00 : 
      begin
        if (current_priv_lvl == PRIV_LVL_S)
          trap_base_addr = {stvec.base, 2'b0};
        else if  (current_priv_lvl == PRIV_LVL_M )
          trap_base_addr = {mtvec.base, 2'b0} ;
        else
          trap_base_addr = {mtvec.base, 2'b0} ;
      end
      2'b01 :    
      begin
        if (current_priv_lvl == PRIV_LVL_M && is_interrupt)
          trap_base_addr = {mtvec.base[MXLEN-3:6], interrupt_cause[5:0], 2'b0};
        else if  (current_priv_lvl == PRIV_LVL_S )
          trap_base_addr = {stvec.base, 2'b0} ;
        else
          trap_base_addr = {mtvec.base, 2'b0} ;
      end
      2'b10 : 
      begin 
        if (current_priv_lvl == PRIV_LVL_S && is_interrupt)
          trap_base_addr = {stvec.base[SXLEN-3:6], interrupt_cause[5:0], 2'b0};
  
        else if  (current_priv_lvl == PRIV_LVL_M )
          trap_base_addr = {mtvec.base, 2'b0} ;
  
        else
          trap_base_addr = {mtvec.base, 2'b0} ;   //will never execute it as we dont trap in u-mode >> trap base address will not be assigned to pc  in that case
      end
      2'b11: 
      begin
        if (current_priv_lvl == PRIV_LVL_M && is_interrupt)
              trap_base_addr = {mtvec.base[MXLEN-3:6], interrupt_cause[5:0], 2'b0};
        else if  (current_priv_lvl == PRIV_LVL_S && is_interrupt )
          trap_base_addr = {stvec.base[SXLEN-3:6], interrupt_cause[5:0], 2'b0};
        else
          trap_base_addr = {mtvec.base, 2'b0} ;
      end
    endcase
  end

  /*************************************     Exception Flag     *************************************/
  always_comb
  begin
    if( illegal_total                     |
        i_riscv_csr_ecall_u               |
        i_riscv_csr_ecall_s               |      
        i_riscv_csr_ecall_m               | 
        i_riscv_csr_inst_addr_misaligned  | 
        i_riscv_csr_load_addr_misaligned  | 
        i_riscv_csr_store_addr_misaligned )
      is_exception = 1'b1 ;
    else
      is_exception = 1'b0 ;
  end

  /************************************   Exception Cause Flag   ************************************/
  always_comb
  begin
    if(illegal_total)
      exception_cause = ILLEGAL_INSTRUCTION ;

    else if(i_riscv_csr_inst_addr_misaligned)
      exception_cause = INSTRUCTION_ADDRESS_MISALIGNED;

    else if(i_riscv_csr_ecall_m)
      exception_cause = ECALL_M;

    else if (i_riscv_csr_ecall_s)
      exception_cause = ECALL_S;

    else if (i_riscv_csr_ecall_u)
      exception_cause = ECALL_U;

    else if (i_riscv_csr_load_addr_misaligned)
      exception_cause = LOAD_ADDRESS_MISALIGNED;

    else if (i_riscv_csr_store_addr_misaligned)
      exception_cause = STORE_ADDRESS_MISALIGNED;
    else 
      exception_cause = 'd10 ;
  end

  /************************************   Interrupt Cause Flag   ************************************/
  always_comb
  begin
    if(mie.stie && mip.stip)
    begin
      interrupt_cause = STI   ;
    end

    else if(mie.seie && mip.seip)
    begin
      interrupt_cause = SEI   ;
    end

    else if(mip.mtip && mie.mtie)
    begin

      interrupt_cause = MTI   ;
    end

    else if (mip.meip && mie.meie) // Machine Timer Interrupt
    begin
      interrupt_cause = MEI   ;
    end

    else  // Machine Mode External Interrupt
    begin
      interrupt_cause = 'd10  ;
    end
  end

  /*************************************    Interrupt Flags    **************************************/
  always_comb
  begin
    interrupt_go_m  = 1'b0  ;  
    interrupt_go_s  = 1'b0  ; 
    mei_pending     = 1'b0  ;
    mti_pending     = 1'b0  ;
    sei_pending     = 1'b0  ;
    sti_pending     = 1'b0  ;

    if (mip.meip && mie.meie)  // Machine Mode External Interrupt
    begin
      case (current_priv_lvl)
        PRIV_LVL_M :  
        begin 
          if (mstatus.mie && ~mideleg[MEI]) 
          begin
            interrupt_go_m  = 1'b1  ;
            mei_pending     = 1'b1  ;
          end 
          else 
          begin
            interrupt_go_m  = 1'b0  ; 
            mei_pending     = 1'b0  ;
          end             
        end
        PRIV_LVL_S  ,
        PRIV_LVL_U  : 
        begin
          if(~mideleg[MEI])
          begin
            interrupt_go_m  = 1'b1  ;
            mei_pending     = 1'b1  ;
          end
          else 
          begin 
            interrupt_go_m  = 1'b0  ;
            mei_pending     = 1'b0  ;
          end
        end

        default :  
        begin 
          interrupt_go_m = 1'b0 ;
          interrupt_go_s = 1'b0 ;
        end             
      endcase
    end

    else if (mip.mtip && mie.mtie) // Machine Timer Interrupt
    begin
      case (current_priv_lvl)
        PRIV_LVL_M  :
        begin
          if (mstatus.mie && ~mideleg[MTI])
          begin
            interrupt_go_m  = 1'b1 ;
            mti_pending     = 1'b1 ;
          end
          else
          begin 
            interrupt_go_m  = 1'b0  ;    
            mti_pending     = 1'b0  ;
          end 
        end

        PRIV_LVL_S  ,
        PRIV_LVL_U  : 
        begin
          if(~mideleg[MTI])
          begin
            interrupt_go_m  = 1'b1  ;
            mti_pending     = 1'b1  ;
          end
          else 
          begin 
            interrupt_go_m  = 1'b0  ;
            mti_pending     = 1'b0  ;
          end
        end
        default :
        begin 
          interrupt_go_s = 1'b0 ; 
          interrupt_go_m = 1'b0 ; 
        end        
      endcase
    end

    else if(mie.seie && mip.seip)
    begin
      case(current_priv_lvl)
        PRIV_LVL_M :
        begin
          interrupt_go_s  = 1'b0  ;
          sei_pending     = 1'b0  ;
        end
        PRIV_LVL_S : 
        begin 
          if (/*mideleg[SEI] &&*/ mstatus.sie) 
          begin
            interrupt_go_s  = 1'b1  ;
            sei_pending     = 1'b1  ;
          end   
          else 
          begin
            interrupt_go_s  = 1'b0  ; 
            sei_pending     = 1'b0  ;
          end
        end
        default :  
        begin 
          interrupt_go_m    = 1'b0  ;
          interrupt_go_s    = 1'b1  ;
          sei_pending       = 1'b1  ;
        end              
      endcase
    end

    else if (mie.stie && mip.stip) 
    begin
      case(current_priv_lvl)
        PRIV_LVL_M :  
        begin 
          // interrupt_go_m = 1 ;
          interrupt_go_s    = 1'b0  ;
          sti_pending       = 1'b0  ;
        end  
        PRIV_LVL_S :
        begin
          if (/*mideleg[STI] &&*/ mstatus.sie)
          begin 
            interrupt_go_s  = 1'b1  ;
            sti_pending     = 1'b1  ; 
          end
          else
          begin
            interrupt_go_s  = 1'b0  ; 
            sti_pending     = 1'b0  ; 
          end
        end
        default : 
        begin     
          interrupt_go_s    = 1'b1  ;
          sti_pending       = 1'b1  ;
          interrupt_go_m    = 1'b0  ;   
        end        
      endcase
    end
    
    else
    begin
      interrupt_go_s  = 1'b0  ;
      interrupt_go_m  = 1'b0  ;
    end
  end

  /*************************************    Return From Trap    *************************************/
  always_comb
  begin
    if(mret)
      o_riscv_csr_returnfromTrap  = 'd1 ;
    else if(sret)
      o_riscv_csr_returnfromTrap  = 'd2 ;
    else
      o_riscv_csr_returnfromTrap  = 'd0 ;
  end
  

/*************************************    Mcycle Counter    *************************************/
  always @(*) 
   begin    
      mcounter_we[0] <= 1'b0;     
   if (csr_write_access_en && i_riscv_csr_address == MCYCLE)                    
      mcounter_we[0] <= 1'b1;   
   end

  riscv_counter mcycle_counter(
  .clk(i_riscv_csr_clk),
  .rst(i_riscv_csr_rst),
  .write_en(mcounter_we[0]),
  .incr_en(mcounter_incr[0] && !mcountinhibit[0]),
  .i_value(csr_write_data),
  .o_value(mcounter[0])
 );


/*************************************    Minstret Counter    *************************************/
  always @(*) 
  begin    
     mcounter_we[1] <= 1'b0;    
  if (csr_write_access_en && i_riscv_csr_address == MINSTRET)                    
     mcounter_we[1] <= 1'b1;   
  end
 
  riscv_counter minstret_counter(
   .clk(i_riscv_csr_clk),
   .rst(i_riscv_csr_rst),
   .write_en(mcounter_we[1]),
   .incr_en(mcounter_incr[1] && !mcountinhibit[1]),
   .i_value(csr_write_data),
   .o_value(mcounter[1])
  );
  

  /************************************* *********************** *************************************/
  /*************************************  Continuous Assignment  *************************************/
  /************************************* *********************** *************************************/

  /************************************    Outputs Assignments    ************************************/
  assign o_riscv_sepc                 = sepc                  ;
  assign o_riscv_csr_return_address   = mepc                  ;
  assign o_riscv_csr_privlvl          = current_priv_lvl      ;
  assign o_riscv_csr_trap_address     = trap_base_addr        ;
  assign o_riscv_csr_gotoTrap_cs      = go_to_trap            ;
  assign o_riscv_csr_tsr              = mstatus.tsr           ;
  assign o_riscv_csr_rdata            = csr_read_data         ;
  
  /************************************           Flags           ************************************/
  assign is_csr                       = (i_riscv_csr_op == 3'd0)? 1'b0:1'b1 ;
  assign is_interrupt                 = interrupt_go_m || interrupt_go_s    ;
  assign is_trap                      = (is_interrupt || is_exception)? 1'b1:1'b0                 ;
  assign go_to_trap                   =  is_trap && !i_riscv_csr_flush && !i_riscv_csr_globstall  ;
  
  /************************************       Illegal Flags       ************************************/
  assign illegal_priv_access          = ((i_riscv_csr_address[9:8] > current_priv_lvl) && is_csr);    
  assign illegal_write_access         = (i_riscv_csr_address[11:10] == 2'b11) && csr_write_en ;   
  assign illegal_csr_access           = ((illegal_read_access | illegal_write_access | illegal_priv_access ) && is_csr) ;
  assign illegal_total                =   illegal_csr_access  | i_riscv_csr_illegal_inst ;

  /************************************      CSR Write Enable     ************************************/
  assign csr_write_access_en          = csr_write_en  &  ~illegal_csr_access;

  /*********************************   Modes transition conditions    ********************************/
  assign force_s_delegation           = ( (support_supervisor)              &&
                                          (current_priv_lvl == PRIV_LVL_S)  && 
                                          (medeleg[exception_cause[3:0]]    ));

  assign no_delegation                = ( (support_supervisor)              &&
                                          (current_priv_lvl == PRIV_LVL_S)  &&
                                          (!medeleg[exception_cause[3:0]]   ));


  /*************************************   Trap Base Address    *************************************/
  assign xtvec_base                   = {stvec.base[0] ,mtvec.base[0]} ;

  /*********************************   Interrupt Acknowledgement    *********************************/
  assign ack_external_int             = m_external_ack | s_external_ack;
  /*********************************           Counters    ***************************************/
  assign mcounter_incr[0] = 1'b1; //MCYCLE
  assign mcounter_incr[1] = i_riscv_csr_instret; //MINSTRET

endmodule
