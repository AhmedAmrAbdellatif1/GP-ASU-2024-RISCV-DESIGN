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

    (1  <<   0)  // A - Atomic Instructions extension
  | (1  <<   2)  // C - Compressed extension
  | (1  <<   8)  // I - RV32I/64I/128I base ISA
  | (1  <<  12)  // M - Integer Multiply/Divide extension
  | (1  <<  18)  // S - Supervisor mode implemented
  | (1  <<  20)  // U - User mode implemented
  | (1  <<  63);// M-XLEN

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
  logic signed  [63:0]  immediate   ;
  string                rdname      ;
  string                rs1name     ;
  string                rs2name     ;
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
  CSR_MCYCLE        = 12'hB00,
  CSR_SSTATUS       = 12'h100,
  CSR_SIE           = 12'h104,
  CSR_STVEC         = 12'h105
} priv_reg ;



/******************************** ********* ********************************/
/******************************** TESTBENCH ********************************/
/******************************** ********* ********************************/

assign regWrite         = DUT.u_top_core.u_top_datapath.u_riscv_mw_ppreg.o_riscv_mw_regw_wb;
assign stall            = DUT.u_top_core.u_top_hzrdu.glob_stall;
assign instr.hexa       = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_inst;
assign instr.c          = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_cinst;
assign instr.rd         = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rdaddr;
assign instr.rddata     = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;
assign instr.load       = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_rddata;
assign instr.pc         = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_pc;
assign instr.memaddr    = DUT.u_top_core.u_top_datapath.u_riscv_tracer.i_riscv_trc_memaddr;
assign instr.op         = instr.hexa[6:0];
assign instr.funct3     = instr.hexa[14:12];
assign instr.funct7     = instr.hexa[31:25];
assign instr.rs1        = instr.hexa[19:15];
assign instr.csr        = instr.hexa[31:20];
assign instr.immediate  = DUT.u_top_core.u_top_datapath.u_riscv_wbstage.i_riscv_wb_uimm;

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
    instr.illegal   <= 'b0;
    csr.priv_lvl    <= 'b0;
    instr.immediate <= 'b0;
  end
  else if(!stall) begin
    instr.illegal   <= DUT.u_top_core.u_top_datapath.u_riscv_csrfile.illegal_total;
    csr.priv_lvl    <= DUT.u_top_core.u_top_datapath.u_riscv_csrfile.priv_lvl_cs;
  end
end

always_ff @(posedge clk) begin
  if(!stall)
  begin
    instr.amo_result <= DUT.u_data_cache.amo_result;
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
    CSR_SIE           : instr.mreg = "c772_mie";
    CSR_SSTATUS       : instr.mreg = "c768_mstatus";
    CSR_STVEC         : instr.mreg = "c261_stvec";
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
assign sret_flag = ((instr.funct3 == 'b000) && (instr.rd == 'b0) && (instr.rs1 == 'b0) && (instr.csr == 'd258));

// stvec
assign csr.stvec[63:2] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.stvec_base_cs;
assign csr.stvec[1:0]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.stvec_mode_cs;

// sstatus
assign csr.sstatus[1]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sie_cs;
assign csr.sstatus[3]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mie_cs;
assign csr.sstatus[5]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_spie_cs;
assign csr.sstatus[6]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_ube_cs;
assign csr.sstatus[7]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mpie_cs;
assign csr.sstatus[8]     = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_spp_cs;
assign csr.sstatus[12:11] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mpp_cs;
assign csr.sstatus[17]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mprv_cs;
assign csr.sstatus[18]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sum_cs;
assign csr.sstatus[19]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mxr_cs;
assign csr.sstatus[20]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_tvm_cs;
assign csr.sstatus[21]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_tw_cs;
assign csr.sstatus[22]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_tsr_cs;
assign csr.sstatus[33:32] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_uxl_cs;
assign csr.sstatus[35:34] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sxl_cs;
assign csr.sstatus[36]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_sbe_cs;
assign csr.sstatus[37]    = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mstatus_mbe_cs;

// sie    
assign csr.sie[5]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_stie_cs;
assign csr.sie[7]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_mtie_cs;
assign csr.sie[9]  = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_seie_cs;
assign csr.sie[11] = DUT.u_top_core.u_top_datapath.u_riscv_csrfile.mie_meie_cs;

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
    CSR_SIE      : instr.csrw = csr.sie;
    CSR_SSTATUS  : instr.csrw = csr.sstatus;
    CSR_STVEC    : instr.csrw = csr.stvec;
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

/******************************** Instruction Text ********************************/
always_comb begin
  case(instr.op)
    OPCODE_OP:
    begin
      case({instr.funct3,instr.funct7})
       {3'b000,7'0000000}: instr.name = "add";
       {3'b000,7'0100000}: instr.name = "sub";
       {3'b001,7'0000000}: instr.name = "sll";
       {3'b010,7'0000000}: instr.name = "slt";
       {3'b011,7'0000000}: instr.name = "sltu";
       {3'b100,7'0000000}: instr.name = "xor";
       {3'b101,7'0000000}: instr.name = "srl";
       {3'b101,7'0100000}: instr.name = "sra";
       {3'b110,7'0000000}: instr.name = "or";
       {3'b111,7'0000000}: instr.name = "and";
       {3'b000,7'0000001}: instr.name = "mul";
       {3'b001,7'0000001}: instr.name = "mulh";
       {3'b010,7'0000001}: instr.name = "mulhsu";
       {3'b011,7'0000001}: instr.name = "mulhu";
       {3'b100,7'0000001}: instr.name = "div";
       {3'b101,7'0000001}: instr.name = "divu";
       {3'b110,7'0000001}: instr.name = "rem";
       {3'b111,7'0000001}: instr.name = "remu";
      endcase
    end         
    OPCODE_OP_IMM:
    begin
      case(instr.funct3)
        3'b000: instr.name = "addi";
        3'b001:
        begin
          if(instr.funct7 == 7'b0000000)
            instr.name = "slli";
        end
        3'b010: instr.name = "slti";
        3'b011: instr.name = "sltiu";
        3'b100: instr.name = "xori";
        3'b101: 
        begin
          if(instr.funct7 == 7'b0000000)
            instr.name = "srli";
          else if(instr.funct7 == 7'b0100000)
            instr.name = "srai";
        end
        3'b110: instr.name = "ori";
        3'b111: instr.name = "andi";
      endcase
    end  
    OPCODE_OP_WORD:
    begin
      case({instr.funct3,instr.funct7})
       {3'b000,7'0000000}: instr.name = "addw";
       {3'b000,7'0100000}: instr.name = "subw";
       {3'b001,7'0000000}: instr.name = "sllw";
       {3'b101,7'0000000}: instr.name = "srlw";
       {3'b101,7'0100000}: instr.name = "sraw";
      endcase
    end      
    OPCODE_OP_WORD_IMM:
    begin
      case(instr.funct3)
        3'b000: instr.name = "addiw";
        3'b001:
        begin
          if(instr.funct7 == 7'b0000000)
            instr.name = "slliw";
        end
        3'b101:
        begin
          if(instr.funct7 == 7'b0000000)
            instr.name = "srliw";
          else if(instr.funct7 == 7'b0100000)
            instr.name = "sraiw";
        end
      endcase
    end  
    OPCODE_LUI:
    begin
      instr.name = "lui";
    end          
    OPCODE_AUIPC:
    begin
      instr.name = "auipc";
    end        
    OPCODE_LOAD:
    begin
      case(instr.funct3)
        3'b000: instr.name = "lb";
        3'b001: instr.name = "lh";
        3'b010: instr.name = "lw";
        3'b011: instr.name = "ld";
        3'b100: instr.name = "lbu";
        3'b101: instr.name = "lhu";
        3'b110: instr.name = "lwu";
      endcase
    end         
    OPCODE_BRANCH:
    begin
      case(instr.funct3)
        3'b000: instr.name = "beq";
        3'b001: instr.name = "bne";
        3'b100: instr.name = "blt";
        3'b101: instr.name = "bge";
        3'b110: instr.name = "bltu";
        3'b111: instr.name = "bgeu";
      endcase
    end       
    OPCODE_STORE:
    begin
      case(instr.funct3)
        3'b000: instr.name = "sb";
        3'b001: instr.name = "sh";
        3'b010: instr.name = "sw";
        3'b011: instr.name = "sd";
      endcase
    end        
    OPCODE_JALR:
    begin
      instr.name = "jalr";
    end         
    OPCODE_JAL:
    begin
      instr.name = "jal";
    end          
    OPCODE_CSR:
    begin
      case(instr.funct3)
        3'b000:
        begin
          if (instr.csr == 'b0)
            instr.name = "ecall";
          else if(mret_flag)
            instr.name = "mret";
          else if(sret_flag)
            instr.name = "sret";
        end
        3'b001:
        begin
          if(!instr.rd)
            instr.name = "csrw";
          else
            instr.name = "csrrw";
        end
        3'b010:
        begin
          if(!instr.rs1)
            instr.name = "csrr";
          else
            instr.name = "csrrs";
        end
        3'b011: instr.name = "csrrc";
        3'b101: instr.name = "csrrwi";
        3'b110: instr.name = "csrrsi";
        3'b111: instr.name = "csrrci";
      endcase
    end          
    OPCODE_ATOMIC:
    begin
      case(instr.funct7)
        LR:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = lr.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = lr.w;
        end      
        SC:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = sc.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = sc.w;
        end      
        AMOSWAP:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amoswap.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amoswap.w;
        end 
        AMOADD:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amoadd.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amoadd.w;
        end  
        AMOXOR:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amoxor.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amoxor.w;
        end   
        AMOAND:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amoand.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amoand.w;
        end  
        AMOOR:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amoor.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amoor.w;
        end    
        AMOMIN:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amomin.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amomin.w;
        end   
        AMOMAX:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amomax.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amomax.w;
        end   
        AMOMINU:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amominu.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amominu.w;
        end  
        AMOMAXU:
        begin
          if(instr.funct3 == ATOMIC_D)
            instr.name = amomaxu.d;
          else if(instr.funct3 == ATOMIC_W)
            instr.name = amomaxu.w;
        end 
      endcase
    end       
  endcase
end

always_comb begin
  case(instr.rd)
    'd0:  instr.rdname = "x0";  
    'd1:  instr.rdname = "ra";
    'd2:  instr.rdname = "sp";
    'd3:  instr.rdname = "gp";
    'd4:  instr.rdname = "tp";
    'd5:  instr.rdname = "t0";
    'd6:  instr.rdname = "t1";
    'd7:  instr.rdname = "t2";
    'd8:  instr.rdname = "s0";
    'd9:  instr.rdname = "s1";
    'd10: instr.rdname = "a0";
    'd11: instr.rdname = "a1";
    'd12: instr.rdname = "a2";
    'd13: instr.rdname = "a3";
    'd14: instr.rdname = "a4";
    'd15: instr.rdname = "a5";
    'd16: instr.rdname = "a6";
    'd17: instr.rdname = "a7";
    'd18: instr.rdname = "s2";
    'd19: instr.rdname = "s3";
    'd20: instr.rdname = "s4";
    'd21: instr.rdname = "s5";
    'd22: instr.rdname = "s6";
    'd23: instr.rdname = "s7";
    'd24: instr.rdname = "s8";
    'd25: instr.rdname = "s9";
    'd26: instr.rdname = "s10";
    'd27: instr.rdname = "s11";
    'd28: instr.rdname = "t3";
    'd29: instr.rdname = "t4";
    'd30: instr.rdname = "t5";
    'd31: instr.rdname = "t6";
  endcase
end

always_comb begin
  case(instr.rs1)
    'd0:  instr.rs1name = "x0";  
    'd1:  instr.rs1name = "ra";
    'd2:  instr.rs1name = "sp";
    'd3:  instr.rs1name = "gp";
    'd4:  instr.rs1name = "tp";
    'd5:  instr.rs1name = "t0";
    'd6:  instr.rs1name = "t1";
    'd7:  instr.rs1name = "t2";
    'd8:  instr.rs1name = "s0";
    'd9:  instr.rs1name = "s1";
    'd10: instr.rs1name = "a0";
    'd11: instr.rs1name = "a1";
    'd12: instr.rs1name = "a2";
    'd13: instr.rs1name = "a3";
    'd14: instr.rs1name = "a4";
    'd15: instr.rs1name = "a5";
    'd16: instr.rs1name = "a6";
    'd17: instr.rs1name = "a7";
    'd18: instr.rs1name = "s2";
    'd19: instr.rs1name = "s3";
    'd20: instr.rs1name = "s4";
    'd21: instr.rs1name = "s5";
    'd22: instr.rs1name = "s6";
    'd23: instr.rs1name = "s7";
    'd24: instr.rs1name = "s8";
    'd25: instr.rs1name = "s9";
    'd26: instr.rs1name = "s10";
    'd27: instr.rs1name = "s11";
    'd28: instr.rs1name = "t3";
    'd29: instr.rs1name = "t4";
    'd30: instr.rs1name = "t5";
    'd31: instr.rs1name = "t6";
  endcase
end

always_comb begin
  case(instr.rs2)
    'd0:  instr.rs2name = "x0";  
    'd1:  instr.rs2name = "ra";
    'd2:  instr.rs2name = "sp";
    'd3:  instr.rs2name = "gp";
    'd4:  instr.rs2name = "tp";
    'd5:  instr.rs2name = "t0";
    'd6:  instr.rs2name = "t1";
    'd7:  instr.rs2name = "t2";
    'd8:  instr.rs2name = "s0";
    'd9:  instr.rs2name = "s1";
    'd10: instr.rs2name = "a0";
    'd11: instr.rs2name = "a1";
    'd12: instr.rs2name = "a2";
    'd13: instr.rs2name = "a3";
    'd14: instr.rs2name = "a4";
    'd15: instr.rs2name = "a5";
    'd16: instr.rs2name = "a6";
    'd17: instr.rs2name = "a7";
    'd18: instr.rs2name = "s2";
    'd19: instr.rs2name = "s3";
    'd20: instr.rs2name = "s4";
    'd21: instr.rs2name = "s5";
    'd22: instr.rs2name = "s6";
    'd23: instr.rs2name = "s7";
    'd24: instr.rs2name = "s8";
    'd25: instr.rs2name = "s9";
    'd26: instr.rs2name = "s10";
    'd27: instr.rs2name = "s11";
    'd28: instr.rs2name = "t3";
    'd29: instr.rs2name = "t4";
    'd30: instr.rs2name = "t5";
    'd31: instr.rs2name = "t6";
  endcase
end

/******************************** DUT Instantiation ********************************/
riscv_top DUT (
  .i_riscv_clk(clk),
  .i_riscv_rst(rst)
);