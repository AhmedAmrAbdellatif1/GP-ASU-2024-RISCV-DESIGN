package my_pkg;
endpackage

package csr_pkg;

  parameter MXLEN = 64;
  parameter SXLEN = 64;

  //CSR addresses
  //machine info
  parameter CSR_MVENDORID  = 12'hF11,
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
            CSR_SIP        = 12'h144 ,
            CSR_SATP      = 12'h180 ,
            CSR_MENVCFG   = 12'h30A,
            CSR_SENVCFG          = 12'h10A,
         // CSR_MENVCFGH         = 12'h31A,
            CSR_MCOUNTEREN       = 12'h306,
            CSR_MHPM_EVENT_3     = 12'h323,  
            CSR_MHPM_EVENT_4     = 12'h324,  
            CSR_MHPM_EVENT_5     = 12'h325,  
            CSR_MHPM_EVENT_6     = 12'h326,  
            CSR_MHPM_EVENT_7     = 12'h327,  
            CSR_MHPM_EVENT_8     = 12'h328,  
            CSR_MHPM_EVENT_9     = 12'h329,  
            CSR_MHPM_EVENT_10    = 12'h32A,  
            CSR_MHPM_EVENT_11    = 12'h32B,  
            CSR_MHPM_EVENT_12    = 12'h32C,  
            CSR_MHPM_EVENT_13    = 12'h32D,  
            CSR_MHPM_EVENT_14    = 12'h32E,  
            CSR_MHPM_EVENT_15    = 12'h32F,  
            CSR_MHPM_EVENT_16    = 12'h330,  
            CSR_MHPM_EVENT_17    = 12'h331,  
            CSR_MHPM_EVENT_18    = 12'h332,  
            CSR_MHPM_EVENT_19    = 12'h333,  
            CSR_MHPM_EVENT_20    = 12'h334,  
            CSR_MHPM_EVENT_21    = 12'h335,  
            CSR_MHPM_EVENT_22    = 12'h336,  
            CSR_MHPM_EVENT_23    = 12'h337,  
            CSR_MHPM_EVENT_24    = 12'h338,  
            CSR_MHPM_EVENT_25    = 12'h339,  
            CSR_MHPM_EVENT_26    = 12'h33A,  
            CSR_MHPM_EVENT_27    = 12'h33B,  
            CSR_MHPM_EVENT_28    = 12'h33C,  
            CSR_MHPM_EVENT_29    = 12'h33D,  
            CSR_MHPM_EVENT_30    = 12'h33E,  
            CSR_MHPM_EVENT_31    = 12'h33F,  
            CSR_MHPM_COUNTER_3   = 12'hB03,
            CSR_MHPM_COUNTER_4   = 12'hB04,
            CSR_MHPM_COUNTER_5   = 12'hB05,
            CSR_MHPM_COUNTER_6   = 12'hB06,
            CSR_MHPM_COUNTER_7   = 12'hB07,
            CSR_MHPM_COUNTER_8   = 12'hB08,
            CSR_MHPM_COUNTER_9   = 12'hB09,  
            CSR_MHPM_COUNTER_10  = 12'hB0A,  
            CSR_MHPM_COUNTER_11  = 12'hB0B,  
            CSR_MHPM_COUNTER_12  = 12'hB0C,  
            CSR_MHPM_COUNTER_13  = 12'hB0D,  
            CSR_MHPM_COUNTER_14  = 12'hB0E,  
            CSR_MHPM_COUNTER_15  = 12'hB0F,  
            CSR_MHPM_COUNTER_16  = 12'hB10,  
            CSR_MHPM_COUNTER_17  = 12'hB11,  
            CSR_MHPM_COUNTER_18  = 12'hB12,  
            CSR_MHPM_COUNTER_19  = 12'hB13,  
            CSR_MHPM_COUNTER_20  = 12'hB14,  
            CSR_MHPM_COUNTER_21  = 12'hB15,  
            CSR_MHPM_COUNTER_22  = 12'hB16,  
            CSR_MHPM_COUNTER_23  = 12'hB17,  
            CSR_MHPM_COUNTER_24  = 12'hB18,  
            CSR_MHPM_COUNTER_25  = 12'hB19,  
            CSR_MHPM_COUNTER_26  = 12'hB1A,  
            CSR_MHPM_COUNTER_27  = 12'hB1B,  
            CSR_MHPM_COUNTER_28  = 12'hB1C,  
            CSR_MHPM_COUNTER_29  = 12'hB1D,  
            CSR_MHPM_COUNTER_30  = 12'hB1E,  
            CSR_MHPM_COUNTER_31  = 12'hB1F ;

  /*CSR_MCYCLE         = 12'hB00,
  CSR_MCYCLEH          = 12'hB80,
  CSR_MINSTRET   = 12'hB02,
  CSR_MINSTRETH  = 12'hB82, */

  //CSR operation type
  parameter CSR_WRITE      = 3'b001 ,
            CSR_SET        = 3'b010 ,
            CSR_CLEAR      = 3'b011 ,
            CSR_READ       = 3'b101 ,
            SRET           = 3'b110 ,
            MRET           = 3'b111 ;

  parameter PRIV_LVL_U    =  2'b00 ,
            PRIV_LVL_S    =  2'b01 ,
            PRIV_LVL_M    =  2'b11 ;

  //interupts
  //  parameter  S_SOFT_I     =  1  ;
  //  parameter  M_SOFT_I     =  3  ;
  parameter  S_TIMER_I    =  5  ,
            M_TIMER_I    =  7  ,
            S_EXT_I      =  9  ,
            M_EXT_I      =  11 ;

  //exceptions
  parameter INSTRUCTION_ADDRESS_MISALIGNED = 0  ,
            ILLEGAL_INSTRUCTION            = 2  ,
            LOAD_ADDRESS_MISALIGNED        = 4  ,
            STORE_ADDRESS_MISALIGNED       = 6  ,
            ECALL_U                        = 8  ,
            ECALL_S                        = 9  ,
            ECALL_M                        = 11 ;

  parameter   CSR_MSTATUS_SIE_BIT           = 1 ,
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


  parameter logic [MXLEN-1 :0] ISA_CODE =
  (1                 <<  0)  // A - Atomic Instructions extension
  | (1                 <<  2)  // C - Compressed extension
  | (1                 <<  8)  // I - RV32I/64I/128I base ISA
  //9-11 are reserved
  | (1                 << 12)  // M - Integer Multiply/Divide extension
  | (1                 << 18)  // S - Supervisor mode implemented
  | (1                 << 20)  // U - User mode implemented
  | (0                 << 62)  // M-XLEN
  | (1                 << 63); // M-XLEN
endpackage
