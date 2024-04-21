package my_pkg;
  // core local interruptor (CLINT), which contains the timer.
  parameter CLINT           = 'h2000000;
  parameter CLINT_MTIMECMP  = CLINT + 'h4000;
  parameter CLINT_MTIME     = CLINT + 'hBFF8; // cycles since boot.
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
  parameter IDATA_WIDTH   = 128                     ;
  parameter ICACHE_SIZE   = 4*(2**10)               ; //64 * (2**10)
  parameter IMEM_SIZE     = 256*(ICACHE_SIZE)        ; //128*(2**20)
  parameter IDATAPBLOCK   = 16                      ;
  parameter ICACHE_DEPTH  = ICACHE_SIZE/IDATAPBLOCK   ; //  4096
  parameter IADDR         = $clog2(IMEM_SIZE)        ; //    27 bits
  parameter IBYTE_OFF     = $clog2(IDATAPBLOCK)      ; //     4 bits
  parameter IINDEX        = $clog2(ICACHE_DEPTH)     ; //    12 bits
  parameter ITAG          = IADDR - IBYTE_OFF - IINDEX ; //    11 bits
  parameter KERNEL_PC     = 'h80000000              ;
  parameter IAWIDTH       = 23                      ;
  parameter IDWIDTH       = 128                     ;
  parameter IMEM_DEPTH    = 16*1024*4*(2**10)       ;
endpackage

package csr_pkg;
 
  parameter MXLEN = 64;
  parameter SXLEN = 64;

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
  parameter STI    =  5  ,
            MTI    =  7  ,
            SEI      =  9  ,
            MEI      =  11 ;
 
  //exceptions
  parameter INSTRUCTION_ADDRESS_MISALIGNED = 0  ,
            ILLEGAL_INSTRUCTION            = 2  ,
            LOAD_ADDRESS_MISALIGNED        = 4  ,
            STORE_ADDRESS_MISALIGNED       = 6  ,
            ECALL_U                        = 8  ,
            ECALL_S                        = 9  ,
            ECALL_M                        = 11 ;

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