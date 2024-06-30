/******************************** Internal Signals ********************************/
int   i         ;
logic clk       ;
logic rst       ;
logic regWrite  ;
logic stall     ;

/******************************** Parameters ********************************/
parameter CLK_PERIOD    = 30                    ;
parameter BAUD_DIVISOR     = 6945;
parameter UART_PERIOD   = BAUD_DIVISOR*CLK_PERIOD  ;
parameter HALF_PERIOD   = CLK_PERIOD/2          ;

localparam logic [63:0] ISA_CODE =

    (1  <<   0)   // A - Atomic Instructions extension
  | (1  <<   2)   // C - Compressed extension
  | (1  <<   8)   // I - RV32I/64I/128I base ISA
  | (1  <<  12)   // M - Integer Multiply/Divide extension
  | (1  <<  18)   // S - Supervisor mode implemented
  | (1  <<  20)   // U - User mode implemented
  | (1  <<  63);  // M-XLEN

/******************************** Instruction Struct ********************************/
struct {
  logic         [  6:0] op          ;
  logic         [ 11:7] rd          ;
  logic         [14:12] funct3      ;
  logic         [31:25] funct7      ;
  logic         [19:15] rs1         ;
  logic         [24:20] rs2         ;
  logic         [31:20] csr         ;
  logic         [ 31:0] hexa        ;
  logic         [ 15:0] c           ;
  logic         [ 63:0] rddata      ;
  logic         [ 63:0] pc          ;
  logic         [ 63:0] store       ;
  logic         [ 63:0] csrw        ;
  logic         [ 63:0] load        ;
  logic         [ 63:0] memaddr     ;
  logic         [ 63:0] amo_result  ;
  string                mreg        ;
  logic                 illegal     ;
  string                name        ;
} instr ;

struct {
  logic [63:0] mtval    = 'd0;
  logic [63:0] mtvec    = 'd0;
  logic [63:0] mstatus  = 'd0;
  logic [63:0] misa     = 'd0;
  logic [63:0] medeleg  = 'd0;
  logic [63:0] mie      = 'd0;
  logic [63:0] mscratch = 'd0;
  logic [63:0] mepc     = 'd0;
  logic [63:0] stvec    = 'd0;
  logic [63:0] sstatus  = 'd0;
  logic [63:0] sie      = 'd0;
  logic [2:0]  priv_lvl = 'd3;
} csr ;

/******************************** Instruction Opcodes ********************************/
typedef enum logic [6:0] {
  OPCODE_OP          = 7'b0110011, //  (51)  : R-type Instructions
  OPCODE_OP_IMM      = 7'b0010011, //  (19)  : I-type instructions
  OPCODE_OP_WORD     = 7'b0111011, //  (59)  : R-type Word Instructions
  OPCODE_OP_WORD_IMM = 7'b0011011, //  (27)  : I-type Word Instructions
  OPCODE_LUI         = 7'b0110111, //  (55)  : LUI Instruction
  OPCODE_AUIPC       = 7'b0010111, //  (23)  : AUIPC Instruction
  OPCODE_LOAD        = 7'b0000011, //  (3)   : Load instructions
  OPCODE_BRANCH      = 7'b1100011, //  (99)  : Branch Instructions
  OPCODE_STORE       = 7'b0100011, //  (35)  : Store Instructions
  OPCODE_JALR        = 7'b1100111, //  (103) : JALR Instruction
  OPCODE_JAL         = 7'b1101111, //  (111) : JAL Instruction
  OPCODE_CSR         = 7'b1110011, //  (115) : Privileged / CSR instructions
  OPCODE_ATOMIC      = 7'b0101111  //  (47)  : Atomic instructions
} opcode ;

typedef enum logic [4:0] {
  LR      = 5'b00010,
  SC      = 5'b00011,
  AMOSWAP = 5'b00001,
  AMOADD  = 5'b00000,
  AMOXOR  = 5'b00100,
  AMOAND  = 5'b01100,
  AMOOR   = 5'b01000,
  AMOMIN  = 5'b10000,
  AMOMAX  = 5'b10100,
  AMOMINU = 5'b11000,
  AMOMAXU = 5'b11100
} funct5_atomic_op ;

typedef enum logic [2:0] {
  BYTE       = 3'b000,
  HALFWORD   = 3'b001,
  WORD       = 3'b010,
  DOUBLEWORD = 3'b011
} storesrc ;

typedef enum logic [2:0] {
  ATOMIC_W = 3'b010,
  ATOMIC_D = 3'b011
} funct3_atomic_xlen ;

typedef enum logic [11:0] {
  MVENDORID     = 12'hF11,
  MARCHID       = 12'hF12,
  MIMPID        = 12'hF13,
  MHARTID       = 12'hF14,
  MCONFIGPTR    = 12'hF15,
  MSTATUS       = 12'h300,
  MEDELEG       = 12'h302,
  MISA          = 12'h301,
  MIDELEG       = 12'h303,
  CSR_MIE           = 12'h304,
  MTVEC         = 12'h305,
  CSR_MCOUNTINHIBIT = 12'h320,
  MSCRATCH      = 12'h340,
  MEPC          = 12'h341,
  MCAUSE        = 12'h342,
  MTVAL         = 12'h343,
  MIP           = 12'h344,
  CSR_MINSTRET      = 12'hB02,
  CSR_MCYCLE        = 12'hB00,
  SSTATUS       = 12'h100,
  CSR_SIE           = 12'h104,
  STVEC         = 12'h105
} priv_reg ;



/******************************** ********* ********************************/
/******************************** TESTBENCH ********************************/
/******************************** ********* ********************************/

assign regWrite         = DUT.u_top_core.u_riscv_datapath.u_riscv_mw_ppreg.o_riscv_mw_regw_wb;
assign stall            = DUT.u_top_core.u_riscv_datapath.u_riscv_hazard_unit.glob_stall;
assign instr.hexa       = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_inst;
assign instr.c          = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_cinst;
assign instr.rd         = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_rdaddr;
assign instr.rddata     = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_rddata;
assign instr.load       = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_rddata;
assign instr.pc         = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_pc;
assign instr.memaddr    = DUT.u_top_core.u_riscv_datapath.u_riscv_tracer.i_riscv_trc_memaddr;
assign instr.op         = instr.hexa[6:0];
assign instr.funct3     = instr.hexa[14:12];
assign instr.funct7     = instr.hexa[31:25];
assign instr.rs1        = instr.hexa[19:15];
assign instr.csr        = instr.hexa[31:20];

/** Flags **/
assign amo_op_flag =  (((instr.funct7[31:27]  == AMOSWAP)   ||
                        (instr.funct7[31:27]  == AMOADD)    ||
                        (instr.funct7[31:27]  == AMOXOR)    ||
                        (instr.funct7[31:27]  == AMOAND)    ||
                        (instr.funct7[31:27]  == AMOOR)     ||
                        (instr.funct7[31:27]  == AMOMIN)    ||
                        (instr.funct7[31:27]  == AMOMAX)    ||
                        (instr.funct7[31:27]  == AMOMINU)   ||
                        (instr.funct7[31:27]  == AMOMAXU) ) && (instr.op == OPCODE_ATOMIC));


/** Stored Data FF **/
always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    instr.store <= 'b0;
  end
  else if(!stall)begin
    case(DUT.u_top_core.u_data_cache.u_dcache_data.storesrc)
      2'b00 : instr.store <= DUT.u_top_core.u_data_cache.u_dcache_data.data_in[7:0];
      2'b01 : instr.store <= DUT.u_top_core.u_data_cache.u_dcache_data.data_in[15:0];
      2'b10 : instr.store <= DUT.u_top_core.u_data_cache.u_dcache_data.data_in[31:0];
      2'b11 : instr.store <= DUT.u_top_core.u_data_cache.u_dcache_data.data_in[63:0];
    endcase
  end
end

always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    instr.illegal   <= 'b0;
    csr.priv_lvl    <= 'b0;
    end
  else if(!stall) begin
    instr.illegal   <= DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.illegal_total;
    csr.priv_lvl    <= DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.current_priv_lvl;
  end
end

always_ff @(posedge clk) begin
  if(!stall)
  begin
    instr.amo_result <= DUT.u_top_core.u_data_cache.amo_result;
  end
end


/** CSR Name **/
always_comb begin
  case(instr.csr)
    MVENDORID         : instr.mreg = "c3857_mvendorid";
    MISA              : instr.mreg = "c769_misa";
    MARCHID           : instr.mreg = "c3858_marchid";
    MIMPID            : instr.mreg = "c3859_mimpid";
    MHARTID           : instr.mreg = "c3860_mhartid";
    MSTATUS           : instr.mreg = "c768_mstatus";
    MTVEC             : instr.mreg = "c773_mtvec";
    MEDELEG           : instr.mreg = "c768_mstatus";
    CSR_MIE           : instr.mreg = "c772_mie";
    MIP               : instr.mreg = "c773_mip";
    MSCRATCH          : instr.mreg = "c832_mscratch";
    MEPC              : instr.mreg = "c833_mepc";
    MCAUSE            : instr.mreg = "c834_mcause";
    MTVAL             : instr.mreg = "c835_mtval";
    MCONFIGPTR        : instr.mreg = "c3861_mconfigptr";
    CSR_MCOUNTINHIBIT : instr.mreg = "c3862_mcountinhibit";
    CSR_MCYCLE        : instr.mreg = "c2816_mcycle";
    CSR_MINSTRET      : instr.mreg = "c2818_minstret";
    CSR_SIE           : instr.mreg = "c772_mie";
    SSTATUS           : instr.mreg = "c768_mstatus";
    STVEC             : instr.mreg = "c261_stvec";
  endcase
end

// mtvec register
assign csr.mtvec[63:2] = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mtvec.base;
assign csr.mtvec[1:0]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mtvec.mode;

// mtval
assign csr.mtval = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mtval;

// mscratch
assign csr.mscratch = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mscratch;

// mepc
assign csr.mepc = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mepc;

// mstatus
assign csr.mstatus[1]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.sie;
assign csr.mstatus[3]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mie;
assign csr.mstatus[5]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.spie;
assign csr.mstatus[7]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mpie;
assign csr.mstatus[8]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.spp;
assign csr.mstatus[12:11] = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mpp;
assign csr.mstatus[19]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mxr;
assign csr.mstatus[20]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.tvm;
assign csr.mstatus[21]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.tw;
assign csr.mstatus[22]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.tsr;
assign csr.mstatus[33:32] = 2'b10;
assign csr.mstatus[35:34] = 2'b10;

// medeleg
assign csr.medeleg[15:0]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.medeleg;

// mie
assign csr.mie[5]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.stie;
assign csr.mie[7]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.mtie;
assign csr.mie[9]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.seie;
assign csr.mie[11] = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.meie;

assign mret_flag = ((instr.funct3 == 'b000) && (instr.rd == 'b0) && (instr.rs1 == 'b0) && (instr.csr == 'd770));
assign sret_flag = ((instr.funct3 == 'b000) && (instr.rd == 'b0) && (instr.rs1 == 'b0) && (instr.csr == 'd258));

// stvec
assign csr.stvec[63:2] = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.stvec.base;
assign csr.stvec[1:0]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.stvec.mode;

// sstatus
assign csr.sstatus[1]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.sie;
assign csr.sstatus[3]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mie;
assign csr.sstatus[5]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.spie;
assign csr.sstatus[7]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mpie;
assign csr.sstatus[8]     = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.spp;
assign csr.sstatus[12:11] = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mpp;
assign csr.sstatus[19]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.mxr;
assign csr.sstatus[20]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.tvm;
assign csr.sstatus[21]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.tw;
assign csr.sstatus[22]    = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mstatus.tsr;
assign csr.sstatus[33:32] = 2'b10;
assign csr.sstatus[35:34] = 2'b10;

// sie    
assign csr.sie[5]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.stie;
assign csr.sie[7]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.mtie;
assign csr.sie[9]  = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.seie;
assign csr.sie[11] = DUT.u_top_core.u_riscv_datapath.u_riscv_csrfile.mie.meie;

/** CSR STORED DATA **/
always_comb begin
  case(instr.csr)
    MSTATUS  : instr.csrw = csr.mstatus;
    MISA     : instr.csrw = ISA_CODE;
    MEDELEG  : instr.csrw = (mret_flag)? csr.mstatus:csr.medeleg;
    CSR_MIE  : instr.csrw = csr.mie;
    MTVEC    : instr.csrw = csr.mtvec;
    MSCRATCH : instr.csrw = csr.mscratch;
    MEPC     : instr.csrw = csr.mepc;
    CSR_SIE  : instr.csrw = csr.sie;
    SSTATUS  : instr.csrw = csr.sstatus;
    STVEC    : instr.csrw = csr.stvec;
  endcase
end

/******************************** ********* ********************************/
/******************************** ********* ********************************/
/******************************** ********* ********************************/

/******************************** Reseting Block ********************************/
initial begin : proc_reseting
  rst = 1'b1;
  #(3*CLK_PERIOD);
  rst = 1'b0;
end

/******************************** Clock Generation Block ********************************/
initial begin : proc_clock
  clk = 1'b0;
  forever begin
    #HALF_PERIOD clk = ~clk;
  end
end

/************************************ ------------ Struct and Queue ------------ ************************************/
logic [10:0] output_data;
int         y          ;

typedef struct packed {
  logic       start ;
  logic       stop  ;
  logic       parity;
  logic [7:0] data  ;
} struct_t ;

struct_t tx_out;
logic    serial_data  ;
/******************************** DUT Instantiation ********************************/

bit [7:0] switches_upper;
bit [7:0] switches_lower;
bit [6:0] segment;
bit leds;
bit button1;
bit button2;
bit button3;

riscv_top  DUT (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst),
    .i_riscv_top_external_interrupt(1'b0),
    .i_riscv_top_switches_upper(switches_upper),
    .i_riscv_top_switches_lower(switches_lower),
    .i_riscv_top_button1(button1),
    .i_riscv_top_button2(button2),
    .i_riscv_top_button3(button3),
    .o_riscv_top_anode( ),
    .o_riscv_top_segment(segment),
    .o_riscv_top_leds(leds),
    .o_riscv_top_tx_data(serial_data)
  );
