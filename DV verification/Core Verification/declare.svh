/******************************** Internal Signals ********************************/
logic clk     ;
logic rst     ;
logic regWrite;
logic stall   ;
int   i       ;

/******************************** Parameters ********************************/
parameter CLK_PERIOD  = 50          ;
parameter HALF_PERIOD = CLK_PERIOD/2;

localparam logic [63 :0] ISA_CODE =

  (0  <<   0)  // A - Atomic Instructions extension
  | (1  <<   2)  // C - Compressed extension
  | (1  <<   8)  // I - RV32I/64I/128I base ISA
  | (1  <<  12)  // M - Integer Multiply/Divide extension
  | (1  <<  18)  // S - Supervisor mode implemented
  | (1  <<  20)  // U - User mode implemented
  | (1  <<  63);// M-XLEN

/******************************** Instruction Struct ********************************/
struct {
  logic [  6:0] op     ;
  logic [ 11:7] rd     ;
  logic [14:12] funct3 ;
  logic [19:15] rs1    ;
  logic [31:20] csr    ;
  logic [ 31:0] hexa   ;
  logic [ 15:0] c      ;
  logic [ 63:0] rddata ;
  logic [ 63:0] pc     ;
  logic [ 63:0] store  ;
  logic [ 63:0] csrw   ;
  logic [ 63:0] load   ;
  logic [ 63:0] memaddr;
  string        mreg   ;
  logic         illegal;
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
  OPCODE_CSR         = 7'b1110011  //  (115) : Privileged / CSR instructions
} opcode ;

typedef enum logic [2:0] {
  BYTE       = 3'b000,
  HALFWORD   = 3'b001,
  WORD       = 3'b010,
  DOUBLEWORD = 3'b011
} storesrc ;

typedef enum logic [11:0] {
  CSR_MVENDORID     = 12'hF11,
  CSR_MARCHID       = 12'hF12,
  CSR_MIMPID        = 12'hF13,
  CSR_MHARTID       = 12'hF14,
  CSR_MCONFIGPTR    = 12'hF15,
  CSR_MSTATUS       = 12'h300,
  CSR_MEDELEG       = 12'h302,
  CSR_MISA          = 12'h301,
  CSR_MIDELEG       = 12'h303,
  CSR_MIE           = 12'h304,
  CSR_MTVEC         = 12'h305,
  CSR_MCOUNTINHIBIT = 12'h320,
  CSR_MSCRATCH      = 12'h340,
  CSR_MEPC          = 12'h341,
  CSR_MCAUSE        = 12'h342,
  CSR_MTVAL         = 12'h343,
  CSR_MIP           = 12'h344,
  CSR_MINSTRET      = 12'hB02,
  CSR_MCYCLE        = 12'hB00
} mmode_reg ;



/******************************** ********* ********************************/
/******************************** TESTBENCH ********************************/
/******************************** ********* ********************************/

assign regWrite      = DUT.u_top_core.u_top_datapath.u_riscv_mw_ppreg.o_riscv_mw_regw_wb;
assign stall         = DUT.u_top_core.u_top_hzrdu.glob_stall;
assign instr.hexa    = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_inst;
assign instr.c       = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_cinst;
assign instr.rd      = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rdaddr;
assign instr.rddata  = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;
assign instr.load    = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;
assign instr.pc      = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_pc;
assign instr.memaddr = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_memaddr;
assign instr.op      = instr.hexa[6:0];
assign instr.funct3  = instr.hexa[14:12];
assign instr.rs1     = instr.hexa[19:15];
assign instr.csr     = instr.hexa[31:20];


/** Stored Data FF **/
always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    instr.store <= 'b0;
  end
  else if(!stall)begin
    case(DUT.u_data_cache.u_dcache_data.storesrc)
      2'b00 : instr.store <= DUT.u_data_cache.u_dcache_data.data_in[7:0];
      2'b01 : instr.store <= DUT.u_data_cache.u_dcache_data.data_in[15:0];
      2'b10 : instr.store <= DUT.u_data_cache.u_dcache_data.data_in[31:0];
      2'b11 : instr.store <= DUT.u_data_cache.u_dcache_data.data_in[63:0];
    endcase
  end
end

always_ff @(posedge clk or posedge rst) begin
  if(rst) begin
    instr.illegal <= 'b0;
  end
  else if(!stall) begin
    instr.illegal <= DUT.u_top_core.u_top_datapath.u_riscv_csrfile.illegal_total;
  end
end


/** CSR Name **/
always_comb begin
  case(instr.csr)
    CSR_MVENDORID     : instr.mreg = "c3857_mvendorid";
    CSR_MISA          : instr.mreg = "c769_misa";
    CSR_MARCHID       : instr.mreg = "c3858_marchid";
    CSR_MIMPID        : instr.mreg = "c3859_mimpid";
    CSR_MHARTID       : instr.mreg = "c3860_mhartid";
    CSR_MSTATUS       : instr.mreg = "c768_mstatus";
    CSR_MTVEC         : instr.mreg = "c773_mtvec";
    CSR_MEDELEG       : instr.mreg = "c768_mstatus";
    CSR_MIE           : instr.mreg = "c772_mie";
    CSR_MIP           : instr.mreg = "c773_mip";
    CSR_MSCRATCH      : instr.mreg = "c832_mscratch";
    CSR_MEPC          : instr.mreg = "c833_mepc";
    CSR_MCAUSE        : instr.mreg = "c834_mcause";
    CSR_MTVAL         : instr.mreg = "c835_mtval";
    CSR_MCONFIGPTR    : instr.mreg = "c3861_mconfigptr";
    CSR_MCOUNTINHIBIT : instr.mreg = "c3862_mcountinhibit";
    CSR_MCYCLE        : instr.mreg = "c2816_mcycle";
    CSR_MINSTRET      : instr.mreg = "c2818_minstret";
  endcase
end

// mtvec register
assign csr.mtvec[63:2] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mtvec_base_cs;
assign csr.mtvec[1:0]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mtvec_mode_cs;

// mtval
assign csr.mtval = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mtval_cs;

// mscratch
assign csr.mscratch = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mscratch_cs;

// mepc
assign csr.mepc = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mepc_cs;

// mstatus
assign csr.mstatus[1]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sie_cs;
assign csr.mstatus[3]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mie_cs;
assign csr.mstatus[5]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_spie_cs;
assign csr.mstatus[6]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_ube_cs;
assign csr.mstatus[7]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mpie_cs;
assign csr.mstatus[8]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_spp_cs;
assign csr.mstatus[12:11] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mpp_cs;
assign csr.mstatus[17]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mprv_cs;
assign csr.mstatus[18]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sum_cs;
assign csr.mstatus[19]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mxr_cs;
assign csr.mstatus[20]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_tvm_cs;
assign csr.mstatus[21]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_tw_cs;
assign csr.mstatus[22]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_tsr_cs;
assign csr.mstatus[33:32] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_uxl_cs;
assign csr.mstatus[35:34] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sxl_cs;
assign csr.mstatus[36]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sbe_cs;
assign csr.mstatus[37]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mbe_cs;

// medeleg
assign csr.medeleg[15:0]      = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.medeleg_cs;

// mie
assign csr.mie[5]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_stie_cs;
assign csr.mie[7]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_mtie_cs;
assign csr.mie[9]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_seie_cs;
assign csr.mie[11] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_meie_cs;

assign mret_flag = ((instr.funct3 == 'b000) && (instr.rd == 'b0) && (instr.rs1 == 'b0) && (instr.csr == 'd770));

/** CSR STORED DATA **/
always_comb begin
  case(instr.csr)
    CSR_MSTATUS  : instr.csrw = csr.mstatus;
    CSR_MISA     : instr.csrw = ISA_CODE;
    CSR_MEDELEG  : instr.csrw = (mret_flag)? csr.mstatus:csr.medeleg;
    CSR_MIE      : instr.csrw = csr.mie;
    CSR_MTVEC    : instr.csrw = csr.mtvec;
    CSR_MSCRATCH : instr.csrw = csr.mscratch;
    CSR_MEPC     : instr.csrw = csr.mepc;
  endcase
end

/******************************** ********* ********************************/
/******************************** ********* ********************************/
/******************************** ********* ********************************/

/******************************** Reseting Block ********************************/
initial begin : proc_reseting
  rst = 1'b1;
  #1step;
  rst = 1'b0;
end

/******************************** Clock Generation Block ********************************/
initial begin : proc_clock
  clk = 1'b0;
  forever begin
    #HALF_PERIOD clk = ~clk;
  end
end

/******************************** DUT Instantiation ********************************/
riscv_top DUT (
  .i_riscv_clk(clk),
  .i_riscv_rst(rst)
);