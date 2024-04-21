module riscv_csrfile 
  import csr_pkg::*;
# ( parameter MXLEN              = 64   ,
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
    input   logic [63:0]        i_riscv_csr_timer_timecmp         ,
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
    output  logic [1:0]         o_riscv_csr_returnfromTrap        ,
    output  logic [1:0]         o_riscv_csr_privlvl               ,
    output  logic               o_riscv_csr_reconfig              ,
    output  logic [SXLEN-1:0]   o_riscv_sepc                      ,
    output  logic               o_riscv_csr_tsr
  );
   
  /****************************** CSR Register Implementation ******************************/

  //***  Privilege levels are used to provide protection between different components of the software stack
  logic   [1:0]     current_priv_lvl  ;

  //***  Machine Exception Program Counter ***//
  logic [MXLEN-1:0] mepc              ;

  //***  Machine Scratch Register ***//
  logic [MXLEN-1:0] mscratch          ; //  Dedicated for use by machine code

  //***  Machine Trap Value Register ***//
  logic [MXLEN-1:0] mtval             ; //  Exception-specific infotmation to assist software in handling trap

  //***  Machine Trap-Vector Base-Address Register ***//
  struct packed {
    logic [MXLEN-3:0] base            ; //  Address of pc taken after returning from Trap (via MRET)
    logic   [1:0]     mode            ; //  Vector mode addressing  >>  vectored or direc
  } mtvec ;

  //*** Machine Status Registers ***// :
  //  The mstatus register keeps track of and controls the hart’s current operating state
  struct packed {
    logic       sie   ; //  Supervisor Interrupt Enable
    logic       mie   ; //  Machine Interrupt Enable
    logic       spie  ; //  Supervisor Previous Interrupt Enable
    logic       mpie  ; //  Machine Previous Interrupt Enable
    logic       spp   ;
    logic [1:0] mpp   ;
    logic       mxr   ;
    logic       tvm   ;
    logic       tw    ;
    logic       tsr   ;
  } mstatus ; 

  //***  Machine Interrupt Registers ***//
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
  
  //*** Machine Cause Register ***//
  // When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap
  struct packed {
    logic       int_excep   ; //  Interrupt(1) or exception(0)
    logic [3:0] code        ; //  Indicates event that caused the trap
  } mcause ;

  
  //*** Machine Trap Delegation Registers ***//
  logic [15:0]  medeleg     ;
  logic [15:0]  mideleg     ;

  //************************//

  //*** Supervisor Trap Value Register ***//
  logic [SXLEN-1:0] stval     ;

  //*** Supervisor Scratch Register ***//
  logic [SXLEN-1:0] sscratch  ;
 
  //*** Supervisor Exception Program Counter ***//
  logic [SXLEN-1:0] sepc      ;
  
  //*** Supervisor Cause Register ***//
  struct packed {
    logic         int_excep   ; //  Interrupt(1) or exception(0)
    logic  [3:0]  code        ; //  Indicates event that caused the trap
  } scause ;

  //*** Supervisor Trap Vector Base Address Register ***//
  struct packed {
    logic [SXLEN-3:0] base    ; //  Address of pc taken after returning from Trap (via MRET)
    logic   [1:0]     mode    ; //  Vector mode addressing >> vectored or direct
  } stvec ;
  
  
  /****************************** Internal Flags Declaration ******************************/
  logic             is_exception                  ; //  exception flag
  logic             is_interrupt                  ; //  interrupt flag
                  
  logic             is_trap                       ; //  trap detection
  logic             go_to_trap                    ; //  go to trap handler

  logic             illegal_priv_access           ;
  logic             illegal_write_access          ;
  logic             illegal_read_access           ; 
  logic             illegal_csr_access            ;

  logic             csr_write_en                  ;
  logic [MXLEN-1:0] csr_write_data                ;
  logic             csr_write_access_en           ; 
  
  logic             csr_read_en                   ;
  logic [MXLEN-1:0] csr_read_data                 ;
  logic             ack_external_int ;
  logic             mret                          ;
  logic             sret                          ;

  logic [1:0]       trap_to_priv_lvl              ;
  logic             interrupt_go                  ;

  logic [MXLEN-1:0] trap_base_addr                ;
  
  logic [5:0]       interrupt_cause               ;
  logic [5:0]       exception_cause               ;

  logic             interrupt_global_enable       ;
  logic             interrupt_go_s                ;
  logic             interrupt_go_m                ;
  logic             valid                         ;

  logic             mei_pending                ;
  logic             mti_pending              ;

  logic             sei_pending                ;
  logic             sti_pending              ;
  

  /****************************** Continuous Assignment Statements ******************************/
  // outputs
  assign o_riscv_sepc                 = sepc                  ;
  assign o_riscv_csr_return_address   = mepc                  ;
  assign o_riscv_csr_privlvl          = current_priv_lvl      ;
  assign o_riscv_csr_trap_address     = trap_base_addr        ;
  assign o_riscv_csr_gotoTrap_cs      = go_to_trap            ;

  assign is_csr                       = (i_riscv_csr_op == 3'd0)? 1'b0:1'b1 ;
  assign is_interrupt                 = interrupt_go_m || interrupt_go_s    ;

  assign is_trap                      = (is_interrupt || is_exception)? 1'b1:1'b0                 ;
  assign go_to_trap                   =  is_trap && !i_riscv_csr_flush && !i_riscv_csr_globstall  ;

  assign illegal_priv_access          = ((i_riscv_csr_address[9:8] > current_priv_lvl) && is_csr);    
  assign illegal_write_access         = (i_riscv_csr_address[11:10] == 2'b11) && csr_write_en ;   
  assign illegal_csr_access           = ((illegal_read_access | illegal_write_access | illegal_priv_access ) && is_csr) ;
  assign illegal_total                =   illegal_csr_access  | i_riscv_csr_illegal_inst ;

  assign csr_write_access_en          = csr_write_en  &  ~illegal_csr_access;

  assign o_riscv_csr_tsr              = mstatus.tsr;

  /*** Modes transition conditions ***/
  assign force_s_delegation = ( (support_supervisor)  &&
                                (current_priv_lvl == PRIV_LVL_S) &&
                                (medeleg[exception_cause[3:0]] || mideleg[interrupt_cause[3:0]]));

  assign no_delegation      = ( (support_supervisor)  &&
                                (current_priv_lvl == PRIV_LVL_S) &&
                                (!medeleg[exception_cause[3:0]] && !mideleg[interrupt_cause[3:0]]));

  /****************************** Trap Base Address ******************************/
  always_comb
  begin
    trap_base_addr = {mtvec.base, 2'b0};  // initialize base address

    if (current_priv_lvl == PRIV_LVL_S)
    begin
      trap_base_addr = {stvec.base, 2'b0};
    end

    if ((mtvec.base[0] || stvec.base[0]) && interrupt_go)
    begin
      trap_base_addr[7:2] = interrupt_cause[5:0];
    end
  end

  /************************************* **************** *************************************/
  /*************************************  CSR Read Logic  *************************************/
  /************************************* **************** *************************************/

  always_comb
  begin : csr_read_process

    csr_read_data       = 64'b0 ;
    illegal_read_access = 1'b0  ;

    if (csr_read_en)
    begin 
      case (i_riscv_csr_address)

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

        MTVEC   :
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
        CSR_MIE :
        begin
          csr_read_data[MTI]  = mie.mtie  ;
          csr_read_data[MEI]  = mie.meie  ;
          csr_read_data[STI]  = mie.stie  ;
          csr_read_data[SEI]  = mie.seie  ;
        end

        MIP :
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

  //--> (1) mstatus and sstatus registers
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_mstatus_proc
    if (i_riscv_csr_rst)
    begin
      mstatus <= 'b0;
    end

    else if(go_to_trap)
    begin
      // trap to machine mode
      if ((current_priv_lvl == PRIV_LVL_M) || no_delegation)
      begin
        mstatus.mie   <= 1'b0;
        mstatus.mpie  <= mstatus.mie;
        mstatus.mpp   <= current_priv_lvl;
      end
      // trap to supervisor mode
      else if (force_s_delegation)
      begin
        mstatus.sie   <= 1'b0;
        mstatus.spie  <= mstatus.sie;
        mstatus.spp   <= current_priv_lvl[0];
      end
    end

    else if (mret)
    begin
      mstatus.mie     <= mstatus.mpie;
      mstatus.mpie    <= 1'b1;
      mstatus.mpp     <= (support_user)? PRIV_LVL_U:PRIV_LVL_M;
    end

    else if (sret)
      begin
        mstatus.sie   <= mstatus.spie;
        mstatus.spie  <= 1'b1; 
        mstatus.spp   <= 1'b0;
      end

    // mstatus writing
    else if (csr_write_access_en && (i_riscv_csr_address == MSTATUS))
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
    else if (csr_write_access_en && (i_riscv_csr_address == SSTATUS))
    begin
      mstatus.sie     <= csr_write_data[SIE]        ;
      mstatus.spie    <= csr_write_data[SPIE]       ;
      mstatus.spp     <= csr_write_data[SPP]        ;
      mstatus.mxr     <= csr_write_data[MXR]        ;
    end
  end



  //--> (2) mie and sie registers
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_mie_proc
    if (i_riscv_csr_rst)
    begin
      mie.meie  <=  1'b0 ;
      mie.mtie  <=  1'b0 ;
      mie.seie  <=  1'b0 ;
      mie.stie  <=  1'b0 ;
    end

    /*------ mie register -----*/
    else if (csr_write_access_en && (i_riscv_csr_address == CSR_MIE) )
    begin
      mie.mtie  <= csr_write_data[MTI]  ;    
      mie.meie  <= csr_write_data[MEI]  ;    
      mie.stie  <= csr_write_data[STI]  ;
      mie.seie  <= csr_write_data[SEI]  ;
    end

    /*------ sie register -----*/
    else if (csr_write_access_en && (i_riscv_csr_address == CSR_SIE) )
    begin
      if (support_supervisor)
      begin
        mie.stie  <= (!mideleg[MTI])? mie.stie : csr_write_data[STI];
        mie.seie  <= (!mideleg[MEI])? mie.seie : csr_write_data[SEI];
      end
    end 
  end


  //--> (3) mip and sip registers
  always @(posedge i_riscv_csr_clk or posedge i_riscv_csr_rst)
  begin : write_mip_proc
    if (i_riscv_csr_rst)
    begin
      mip.meip  <=  1'b0 ;
      mip.mtip  <=  1'b0 ;
      mip.seip  <=  1'b0 ;
      mip.stip  <=  1'b0 ;
    end

    else if (csr_write_access_en && (i_riscv_csr_address == MIP))
    begin
      mip.stip  <=  csr_write_data[STI];
      mip.seip  <=  csr_write_data[SEI];
    end

    else if (ack_external_int || i_riscv_csr_timer_int || i_riscv_csr_external_int)
    begin
      case (ack_external_int) 
        1'b1  : mip.meip <= 1'b0 ;
        1'b0  : mip.meip <= i_riscv_csr_external_int ;
      endcase

      mip.mtip <= i_riscv_csr_timer_int;
    end
  end


  //--> (4) mtvec register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_mtvec_proc
    if (i_riscv_csr_rst)
    begin
      mtvec.base  <= 62'b10010;
      mtvec.mode  <=  2'b00   ;
    end

    else if (csr_write_access_en && (i_riscv_csr_address == MTVEC))
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


  //--> (5) stvec register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_stvec_proc
    if (i_riscv_csr_rst)
    begin
      stvec.base  <= 62'b11001; 
      stvec.mode  <=  2'b00   ;
    end

    else if (csr_write_access_en && (i_riscv_csr_address == STVEC))
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

  
  //--> (6) medeleg register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin : write_medeleg_proc
    if (i_riscv_csr_rst)
      medeleg <= 16'b0 ;

    else if (csr_write_access_en && (i_riscv_csr_address == MEDELEG))
      medeleg <=  {csr_write_data[15:11],1'b0,csr_write_data[9:0]};
  end

  
  //--> (7) mideleg register
  always @(posedge i_riscv_csr_clk or posedge i_riscv_csr_rst)
  begin : write_mideleg_proc
    if (i_riscv_csr_rst)
    begin
      mideleg <= 16'b0;
    end
    else if (csr_write_access_en && (i_riscv_csr_address == MIDELEG))
    begin
      if (support_supervisor)
      begin
        mideleg[STI]  <=  csr_write_data[STI] ;
        mideleg[SEI]  <=  csr_write_data[SEI] ;
      end
    end
  end


  //--> (8) mepc register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if(i_riscv_csr_rst)
      mepc <= 64'b0;

    else if(go_to_trap)
    begin
      if((current_priv_lvl == PRIV_LVL_M) || no_delegation)
        mepc <= i_riscv_csr_pc ;
    end

    else if(csr_write_access_en && (i_riscv_csr_address == MEPC) )
      mepc <= {csr_write_data[63:1],1'b0};
  end 

  
  //--> (9) sepc register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      sepc <= 64'b0;

    else if(go_to_trap && force_s_delegation )
    begin
      sepc <= i_riscv_csr_pc ;
    end
      
    else if (csr_write_access_en && (i_riscv_csr_address == SEPC))
      sepc <= {csr_write_data[63:1],1'b0};

  end 


  //--> (10) mscratch register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      mscratch <= 64'b0;

    else if (csr_write_access_en && (i_riscv_csr_address == MSCRATCH))
      mscratch <= csr_write_data;
  end

  //--> (11) sscratch register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if (i_riscv_csr_rst)
      sscratch <= 64'b0;

    else if (csr_write_access_en && (i_riscv_csr_address == SSCRATCH))
      sscratch <= csr_write_data;
  end


  //--> (12) mtval register
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


  //--> (13) stval register
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

  //--> (14) mcause register
  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if(i_riscv_csr_rst)
    begin
      mcause.code       <= 4'b0000;
      mcause.int_excep  <= 1'b0 ;
    end

    //  trap to machine mode
    else if( (is_exception && ((current_priv_lvl == PRIV_LVL_M) || no_delegation)) || interrupt_go_m )
    begin

      ack_external_int    <= 1'b0   ; // initialization

      if(mei_pending)
      begin
        mcause.code       <= MEI   ;
        mcause.int_excep  <= 1'b1  ;
        ack_external_int  <= 1'b1  ;
      end

      else if(mti_pending)
      begin
        mcause.code      <= MTI   ;
        mcause.int_excep <= 'b1   ;
      end

      else if(sei_pending)
      begin
        mcause.code      <= MEI   ;  
        mcause.int_excep <= 1'b1  ;
      end
      
      else if(sti_pending)
      begin
        mcause.code      <= MTI   ;
        mcause.int_excep <= 1'b1  ;
      end

      else if(illegal_total)
      begin
        mcause.code      <= ILLEGAL_INSTRUCTION;
        mcause.int_excep <= 0 ;
      end

      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        mcause.code       <= INSTRUCTION_ADDRESS_MISALIGNED;
        mcause.int_excep  <= 0;
      end

      else if(i_riscv_csr_ecall_m)
      begin
        mcause.code       <= ECALL_M;
        mcause.int_excep <= 0;
        //if (medeleg[11] )
      end

      else if(i_riscv_csr_ecall_s)
      begin
        mcause.code       <= ECALL_S;
        mcause.int_excep <= 0;
        //if (medeleg[9] )
      end

      else if(i_riscv_csr_ecall_u)
      begin
        mcause.code       <= ECALL_U;
        mcause.int_excep <= 0;
        //  if (medeleg[8] ) */
      end
      
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        mcause.code       <= LOAD_ADDRESS_MISALIGNED;
        mcause.int_excep <= 0;
        //if (medeleg[4] )
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        mcause.code      <= STORE_ADDRESS_MISALIGNED;
        mcause.int_excep  <= 0;
        //if (medeleg[6] )
      end
      // else if(software_interrupt_pending)
      // begin
      //  mcause.code       <= MACHINE_SOFTWARE_INTERRUPT;
      //  mcause.int_excep <= 1;
      //  if (mideleg_msi_cs)
      //end

    end   /*---of gototrap---*/
    else if (csr_write_access_en && i_riscv_csr_address == MCAUSE)
    begin

      mcause.int_excep <= csr_write_data[63];
      mcause.code      <= csr_write_data[3:0];
    end
   
   

  end    /*---of always block---*/

  /*------scause register-----
  --- (scause cause of trap(either interrupt or exception)) --- */


  always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst)
  begin
    if     (i_riscv_csr_rst)
    begin

      scause.code                 <= 4'b0000;
      scause.int_excep            <= 1'b0 ;
    end

    else if(( is_exception && force_s_delegation)   // trap to supervisor mode
    || interrupt_go_s )
    begin
      
        //  if (support_supervisor && trap_to_priv_lvl == PRIV_LVL_S) begin
        if(sei_pending)
        begin
          scause.code      <= SEI;
          scause.int_excep <= 1;
          // if (mideleg[MEI] )
        end
        else if(sti_pending)
        begin
          scause.code      <= STI;
          scause.int_excep <= 1;
          // if (mideleg[MTI] )
        end
      else if(illegal_total)
      begin
        scause.code      <= ILLEGAL_INSTRUCTION;
        scause.int_excep <= 0 ;
        // if (medeleg[2] )
      end
      else if(i_riscv_csr_inst_addr_misaligned)
      begin
        scause.code       <= INSTRUCTION_ADDRESS_MISALIGNED;
        scause.int_excep  <= 0;
        // if (medeleg[0] )
      end

      else if(i_riscv_csr_ecall_s)
      begin
        scause.code       <= ECALL_S;
        scause.int_excep <= 0;
        //if (medeleg[9] )
      end
      else if(i_riscv_csr_ecall_u)
      begin
        scause.code       <= ECALL_U;
        scause.int_excep <= 0;
        // if (medeleg[8] ) */
      end
      else if(i_riscv_csr_load_addr_misaligned)
      begin
        scause.code       <= LOAD_ADDRESS_MISALIGNED;
        scause.int_excep <= 0;
        //if (medeleg[4] )
      end
      else if(i_riscv_csr_store_addr_misaligned)
      begin
        scause.code      <= STORE_ADDRESS_MISALIGNED;
        scause.int_excep  <= 0;
        //if (medeleg[6] )
      end
    end   /*---of gototrap---*/
    else if (csr_write_access_en && i_riscv_csr_address == SCAUSE)
    begin

      scause.int_excep <= csr_write_data[63];
      scause.code      <= csr_write_data[3:0];
    end

  end


  /*------ Exception Flag -----*/
  always_comb
  begin
    if(illegal_total | i_riscv_csr_ecall_u |i_riscv_csr_ecall_s | i_riscv_csr_ecall_m  | i_riscv_csr_inst_addr_misaligned  | i_riscv_csr_load_addr_misaligned | i_riscv_csr_store_addr_misaligned)
      is_exception = 1'b1 ;
    else
      is_exception = 1'b0 ;
  end

  /*------ Return from Trap Selector -----*/
  always_comb
  begin
    if(mret)
      o_riscv_csr_returnfromTrap  = 'd1 ;
    else if(sret)
      o_riscv_csr_returnfromTrap  = 'd2 ;
    else
      o_riscv_csr_returnfromTrap  = 'd0 ;
  end



  /*----------------- Current Privilege Level -----------------*/
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
      if   (support_supervisor && is_exception && medeleg[exception_cause[3:0]] ) //~is_interrupt = is_exception
      begin
        if (current_priv_lvl == PRIV_LVL_M)
          trap_to_priv_lvl = PRIV_LVL_M;
        else
          trap_to_priv_lvl = PRIV_LVL_S;
      end
    end
    else if(support_supervisor && is_interrupt)
      begin
      if(interrupt_go_m)
      trap_to_priv_lvl = PRIV_LVL_M;
      else
      trap_to_priv_lvl = PRIV_LVL_S;
      end
    else
      trap_to_priv_lvl = PRIV_LVL_M;
  end

 

  // -----------------
  // execption 
  // -----------------
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
      exception_cause = 10 ; //always medeleg[exception_cause] = zero

  end


/*Interrupts to M-mode take priority over any interrupts to lower privilege modes

now you have interupt >> m-interupt  happens in m-mode only takes in m-mode
                         s-interupt  happens in s-mode  takes in m-mode if mideleg = 0 else if mideleg = 1 takes in s-mode 
                        
Multiple simultaneous interrupts destined for M-mode are handled in the following decreasing
priority order: MEI, MSI, MTI, SEI, SSI, STI

An interrupt i will trap to M-mode (causing the privilege mode to change to M-mode) >>changes m-mode registers if all of
the following are true: (a) bit i is set in both mip and mie 
(b) either the current privilege mode is M and the MIE bit in the mstatus
register is set, or the current privilege mode has less privilege than M-mode;  (c) if register mideleg exists, bit i is not set in mideleg.

An interrupt i will trap to S-mode if both of the following are true  >>changes s-mode registers : 
(a) bit i is set in both sip and sie.
(b) either the current privilege
mode is S and the SIE bit in the sstatus register is set, or the current privilege mode has less
privilege than S-mode;  

When a hart is executing in privilege mode x, interrupts are globally enabled when x IE=1 and
globally disabled when x IE=0. Interrupts for lower-privilege modes, w<x, are always globally
disabled regardless of the setting of any global wIE bit for the lower-privilege mode. Interrupts for
higher-privilege modes, y>x, are always globally enabled regardless of the setting of the global yIE
bit for the higher-privilege mode. Higher-privilege-level code can use separate per-interrupt enable
bits to disable selected higher-privilege-mode interrupts before ceding control to a lower-privilege
mode.*/

    // -----------------
    // Interrupt 
    // -----------------
   
   // Machine Timer Interrupt
    always_comb
    begin
     if (mip.mtip && mie.mtie) //not mean it happens at machine mode  
begin
      interrupt_go_m = 0; 
      interrupt_go_s = 0; 
   case (current_priv_lvl)

        PRIV_LVL_M : begin
         if (mstatus.mie && ~mideleg[MTI]) begin
                          interrupt_go_m = 1 ;
                          mti_pending = 1;
                     end
                      else begin 
                        interrupt_go_m = 0;    
                        mti_pending = 0;
                      end 
                    end         
        PRIV_LVL_S , PRIV_LVL_U : begin
                     if(~mideleg[MTI])begin
                          interrupt_go_m = 1 ;
                        mti_pending = 1;
                    end
                      else 
                          begin 
                            interrupt_go_m = 0 ;
                            mti_pending =0;
                          end
end
                    /*  if (mideleg[MTI] && mstatus.sie) begin
                        interrupt_go_s = 1 ;
                        mti_pending = 1;
                      end
                      else begin 
                        interrupt_go_s = 0 ; 
                        mti_pending = 0;
                      end */
      /*  PRIV_LVL_U : interrupt_global_enable_m = 1 ;
                    interrupt_global_enable_s = 1 ;  */
        default : begin interrupt_go_s = 0 ; // >> check
                        interrupt_go_m = 0 ; // >> check
                 end        
    endcase
end
     // Machine Mode External Interrupt
    else if (mip.meip && mie.meie)
begin
      interrupt_go_m = 0; 
      interrupt_go_s = 0; 
     case (current_priv_lvl)

        PRIV_LVL_M :  begin if (mstatus.mie && ~mideleg[MEI]) begin
                        interrupt_go_m = 1 ;
                        mei_pending =1 ;
                       end 
                        else 
                         begin
                            interrupt_go_m = 0; 
                            mei_pending =0 ;
                        end             
                      end
        PRIV_LVL_S , PRIV_LVL_U : begin
                      if(~mideleg[MEI])
                        begin
                            interrupt_go_m = 1 ;
                            mei_pending = 1;
                        end
                      else 
                          begin 
                            interrupt_go_m = 0 ;
                            mei_pending = 0 ;
                          end
end
                    /*if (mideleg[MEI] && mstatus.sie)
                         begin
                           interrupt_go_s = 1 ;
                           mei_pending =1 ;
                        end 
                     else  begin
                        interrupt_go_s = 0 ; 
                         mei_pending =0 ;
                       end */   
                        
      /*  PRIV_LVL_U : interrupt_global_enable_m = 1 ;
                    interrupt_global_enable_s = 1 ;  */
        default :  begin interrupt_go_s = 0 ;
                        interrupt_go_m = 0 ;
                 end             
    endcase
 end
/*An interrupt i will trap to S-mode if both of the following are true  >>changes s-mode registers : 
(a) bit i is set in both sip and sie.
(b) either the current privilege
mode is S and the SIE bit in the sstatus register is set, or the current privilege mode has less
privilege than S-mode;   */
   // Supervisor External Interrupt
    // The logical-OR of the software-writable bit and the signal from the external interrupt controller is
    // used to generate external interrupts to the supervisor



    
/*When a hart is executing in privilege mode m, inInterrupts for lower-privilege modes, s<m, are always globally
disabled regardless of the setting of any global wIE bit for the lower-privilege mode. */

    else if ( mie.seie && mip.seip )
      begin
              interrupt_go_m = 0; 
        interrupt_go_s = 0; 
      case (current_priv_lvl)
          PRIV_LVL_M :   begin
                           /* interrupt_go_m = 1 ;
                            sei_pending = 1; */
                            interrupt_go_s = 0 ;
                            sei_pending = 0 ;
                       end
          PRIV_LVL_S : begin if (/*mideleg[SEI] &&*/ mstatus.sie) 
                          begin
                              interrupt_go_s = 1 ;
                              sei_pending = 1;
                          end
                        
                        else begin
                            interrupt_go_s = 0 ; 
                            sei_pending = 0;
                        end
                      end
        /*  PRIV_LVL_U : ;  */
          default :  begin 
                        interrupt_go_s = 1 ;
                        sei_pending = 1;
                        interrupt_go_m = 0 ;
                 end              
    endcase
  end
    else if (mie.stie && mip.stip) 
      begin
        interrupt_go_m = 0; 
        interrupt_go_s = 0; 
     case (current_priv_lvl)
      
          PRIV_LVL_M :  begin 
                        // interrupt_go_m = 1 ;
                          interrupt_go_s    = 0 ;
                          sti_pending  = 0 ;
                             end  
          PRIV_LVL_S : begin
           if (/*mideleg[STI] &&*/ mstatus.sie)  begin 
                          interrupt_go_s    = 1 ;
                          sti_pending  = 1 ; 
                     end
                        else begin
                          interrupt_go_s    = 0 ; 
                          sti_pending  = 0; 
                        end
                      end
        /*  PRIV_LVL_U :  ;  */
          default : 
            begin     interrupt_go_s    = 1 ;
                      sti_pending  = 1 ;
                      interrupt_go_m    = 0 ;   
            end        
    endcase
  end
   
    else
    begin
              interrupt_go_s = 0 ;
              interrupt_go_m = 0 ;
     
    end
  end


  /*********************************************** عشوائيات *********************************************************/
  
  // We changing the "tsr" field in mstatus, the change must propagate to the following instructions in the pipeline
  // so, we have to flush the pipeline and re-execute these instructions
  always_comb
  begin : reconfig_csr_ctrl_proc
    if  ( (csr_write_access_en)                 &&
          (i_riscv_csr_address == MSTATUS)  &&
          (mstatus.tsr != csr_write_data[TSR])  )
      o_riscv_csr_reconfig  = 1'b1;
    else
      o_riscv_csr_reconfig  = 1'b0;
  end






      always_comb
  begin
    // -----------------
    // Interrupt 
    // -----------------

    if (mie.stie && mip.stip)

    begin
      interrupt_go = 1;
      interrupt_cause = STI ;

    end
    // Supervisor External Interrupt
    // The logical-OR of the software-writable bit and the signal from the external interrupt controller is
    // used to generate external interrupts to the supervisor
    else if ( mie.seie && mip.seip)
    begin
      interrupt_go = 1;
      interrupt_cause = SEI;
    end

    else if (mip.mtip && mie.mtie)

    begin
      interrupt_go = 1;
      interrupt_cause = MTI;
    end

    // Machine Timer Interrupt

    else if (mip.meip && mie.meie)

    begin
      interrupt_go = 1;
      interrupt_cause = MEI;
    end

    // Machine Mode External Interrupt

    else
    begin
      interrupt_go = 0 ;
      interrupt_cause = 10; // always mideleg[interrupt_cause] = zero 
    end
  end
endmodule
      /*
      logic             external_interrupt_pending_m  ;
      logic             timer_interrupt_pending_m     ;
      assign external_interrupt_pending_m =  (mstatus.mie && mie.meie && (mip.meip))? 1:0; //machine_interrupt_enable + machine_external_interrupt_enable + machine_external_interrupt_pending must all be high
      assign software_interrupt_pending_m = mstatus.mie && mie_msie_cs && mip_msip_cs;  //machine_interrupt_enable + machine_software_interrupt_enable + machine_software_interrupt_pending must all be high
      assign timer_interrupt_pending_m    = (mstatus.mie && mie.mtie && mip.mtip)? 1:0; //machine_interrupt_enable + machine_timer_interrupt_enable + machine_timer_interrupt_pending must all be high
      assign is_interrupt                 = (external_interrupt_pending_m  || timer_interrupt_pending_m) ? 1:0  ;*/ // || software_interrupt_pending_m ;    


  /* 
    logic [MXLEN-1:0] mtinst_cs   ;
    always @(posedge i_riscv_csr_clk  or posedge i_riscv_csr_rst )
    begin
      if (i_riscv_csr_rst)
        mtinst_cs <= 'b0 ;
      else if (csr_write_access_en && i_riscv_csr_address == MTINST)
        //  mtinst <= (is_compressed)? i_riscv_csr_inst ;
        mtinst_cs <=  i_riscv_csr_inst ;
    end
  */


  // An interrupt i will be taken if bit i is set in both mip and mie, and if interrupts are globally enabled.
  // By default, M-mode interrupts are globally enabled if the hart’s current privilege mode  is less
  // than M, or if the current privilege mode is M and the MIE bit in the mstatus register is set.
  // All interrupts are masked in debug mode
 /* assign interrupt_global_enable =  ((mstatus.mie & (current_priv_lvl == PRIV_LVL_M))
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
        if (  (support_supervisor && mstatus.sie && current_priv_lvl == PRIV_LVL_S) ||
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
  end */
