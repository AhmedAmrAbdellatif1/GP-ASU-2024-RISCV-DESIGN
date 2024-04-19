package my_pkg;

endpackage

package dcache_pkg;
  parameter DATA_WIDTH  = 128                     ;
  parameter CACHE_SIZE  = 4*(2**10)               ;   //64 * (2**10)   
  parameter MEM_SIZE    = 128*CACHE_SIZE          ;   //128*(2**20) 
  parameter MEM_DEPTH   = 128*CACHE_SIZE          ;     
  parameter DATAPBLOCK  = 16                      ;
  parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK   ;   //  4096
  parameter ADDR        = $clog2(MEM_SIZE)        ;   //    27 bits
  parameter BYTE_OFF    = $clog2(DATAPBLOCK)      ;   //     4 bits
  parameter INDEX       = $clog2(CACHE_DEPTH)     ;   //    12 bits
  parameter TAG         = ADDR - BYTE_OFF - INDEX ;   //    11 bits
endpackage

package icache_pkg;
  parameter IDATA_WIDTH  = 128                     ;
  parameter ICACHE_SIZE  = 4*(2**10)               ; //64 * (2**10)
  parameter IMEM_SIZE    = 256*(ICACHE_SIZE)        ; //128*(2**20)
  parameter IDATAPBLOCK  = 16                      ;
  parameter ICACHE_DEPTH = ICACHE_SIZE/IDATAPBLOCK   ; //  4096
  parameter IADDR        = $clog2(IMEM_SIZE)        ; //    27 bits
  parameter IBYTE_OFF    = $clog2(IDATAPBLOCK)      ; //     4 bits
  parameter IINDEX       = $clog2(ICACHE_DEPTH)     ; //    12 bits
  parameter ITAG         = IADDR - IBYTE_OFF - IINDEX ; //    11 bits
  parameter KERNEL_PC   = 'h80000000              ;
  parameter IAWIDTH      = 23                      ;
  parameter IDWIDTH      = 128                     ;
  parameter IMEM_DEPTH   = 16*1024*4*(2**10)       ;
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
            CSR_SIP        = 12'h144 ;

  // CSR_SATP     = 12'h180

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