module riscv_cu #( parameter support_supervisor = 1,
                   parameter support_user        = 1) 
(
    input  logic [ 6:0] i_riscv_cu_opcode    ,
    input  logic [ 2:0] i_riscv_cu_funct3    ,
    input  logic [ 6:0] i_riscv_cu_funct7    ,
    input  logic [ 1:0] i_riscv_cu_privlvl   ,
    input  logic [ 4:0] i_riscv_cu_rs1       ,
    input  logic [11:0] i_riscv_cu_constimm12,
    input  logic        i_riscv_cu_tsr       ,
    output logic        o_riscv_cu_jump      ,
    output logic        o_riscv_cu_regw      ,
    output logic        o_riscv_cu_asel      ,
    output logic        o_riscv_cu_bsel      ,
    output logic        o_riscv_cu_memw      ,
    output logic        o_riscv_cu_memr      ,
    output logic [ 1:0] o_riscv_cu_storesrc  ,
    output logic [ 2:0] o_riscv_cu_resultsrc ,
    output logic [ 1:0] o_riscv_cu_funcsel   ,
    output logic [ 3:0] o_riscv_cu_bcond     ,
    output logic [ 2:0] o_riscv_cu_memext    ,
    output logic [ 2:0] o_riscv_cu_immsrc    ,
    output logic [ 3:0] o_riscv_cu_mulctrl   ,
    output logic [ 3:0] o_riscv_cu_divctrl   ,
    output logic [ 5:0] o_riscv_cu_aluctrl   ,
    output logic [ 2:0] o_riscv_cu_csrop     ,
    output logic        o_riscv_cu_sel_rs_imm,
    output logic        o_riscv_cu_illgalinst,
    output logic        o_riscv_cu_iscsr     ,
    output logic        o_riscv_cu_ecall_u   ,
    output logic        o_riscv_cu_ecall_s   ,
    output logic        o_riscv_cu_ecall_m   ,
    output logic        o_riscv_cu_instret   ,
    output logic [1:0]  o_riscv_cu_lr        ,
    output logic [1:0]  o_riscv_cu_sc        ,
    output logic [4:0]  o_riscv_cu_amo_op    ,
    output logic        o_riscv_cu_amo
  );

  /******************************** Internal Signals ********************************/
  logic riscv_cu_detect_ecall;

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

  typedef enum logic [2:0] {
    ADD_SUB = 3'b000,
    SLL     = 3'b001,
    SLT     = 3'b010,
    SLTU    = 3'b011,
    XOR     = 3'b100,
    SRL_SRA = 3'b101,
    OR      = 3'b110,
    AND     = 3'b111
  } funct3_op ;

  typedef enum logic [2:0] {
    ADDI      = 3'b000,
    SLLI      = 3'b001,
    SLTI      = 3'b010,
    SLTIU     = 3'b011,
    XORI      = 3'b100,
    SRLI_SRAI = 3'b101,
    ORI       = 3'b110,
    ANDI      = 3'b111
  } funct3_imm ;

  typedef enum logic [2:0] {
    ADDW_SUBW = 3'b000,
    SLLW      = 3'b001,
    SRLW_SRAW = 3'b101
  } funct3_opw ;

  typedef enum logic [2:0] {
    ADDIW       = 3'b000,
    SLLIW       = 3'b001,
    SRLIW_SRAIW = 3'b101
  } funct3_immw ;

  typedef enum logic [2:0] {
    SB = 3'b000,
    SH = 3'b001,
    SW = 3'b010,
    SD = 3'b011
  } funct3_store ;

  typedef enum logic [2:0] {
    LB  = 3'b000,
    LH  = 3'b001,
    LW  = 3'b010,
    LBU = 3'b100,
    LHU = 3'b101,
    LWU = 3'b110,
    LD  = 3'b011
  } funct3_load ;

  typedef enum logic [2:0] {
    BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
  } funct3_branch ;

  typedef enum logic [2:0] {
    JALR = 3'b000
  } funct3_jump ;

  typedef enum logic [2:0] {
    DIVW  = 3'b100,
    REMW  = 3'b110,
    REMUW = 3'b111
  } funct3_muldiv ;

  typedef enum logic [2:0] {
    CSRRW  = 3'b001,
    CSRRS  = 3'b010,
    CSRRC  = 3'b011,
    CSRRWI = 3'b100,
    CSRRSI = 3'b110,
    CSRRCI = 3'b111
  } funct3_csr ;

  typedef enum logic [2:0] {
    ECALL_MRET = 3'b000
  } funct3_ecall ;

  typedef enum logic [2:0] {
    ATOMIC_W = 3'b010,
    ATOMIC_D = 3'b011
  } funct3_atomic_xlen ;

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

  /******************************** Parameters ********************************/
  // Privilege Useful Parameters
  localparam  ENV_CALL_UMODE  = 8     ,
              ENV_CALL_SMODE  = 9     ,
              ENV_CALL_MMODE  = 11    ,
              ILLEGAL_INSTR   = 2     ,
              PRIV_LVL_U      = 2'b00 ,
              PRIV_LVL_S      = 2'b01 ,
              PRIV_LVL_M      = 2'b11 ;

  // Support Modes
  localparam  SUPPORT_U = 0,
              SUPPORT_S = 0;

  // CSR operation type
  localparam  CSR_WRITE = 3'b001,
              CSR_SET   = 3'b010,
              CSR_CLEAR = 3'b011,
              CSR_READ  = 3'b101,
              SRET      = 3'b110,
              MRET      = 3'b111;

  /******************************** Connecting Wires ********************************/
  assign funct7_illegal_zeroes = |(i_riscv_cu_funct7);
  assign funct7_illegal_bit0   = |(i_riscv_cu_funct7[6:1]);
  assign funct7_illegal_bit5   = (i_riscv_cu_funct7[6] || (|i_riscv_cu_funct7[4:0]));
  assign riscv_funct7_0        = i_riscv_cu_funct7[0];
  assign riscv_funct7_5        = i_riscv_cu_funct7[5];

  always_comb
  begin : ctrl_sig_proc
    //CSR intialize
    o_riscv_cu_illgalinst = 'b0;
    o_riscv_cu_iscsr      = 'b0;
    o_riscv_cu_ecall_m    = 'b0;
    o_riscv_cu_ecall_s    = 'b0;
    o_riscv_cu_ecall_u    = 'b0;
    o_riscv_cu_csrop      = 'b0;
    o_riscv_cu_sel_rs_imm = 'b0;
    riscv_cu_detect_ecall = 'b0;
    o_riscv_cu_instret    = 'b1;
    o_riscv_cu_amo_op     = 5'b0;
    ////////////////////////////////
    case(i_riscv_cu_opcode)
      OPCODE_OP :
      begin
        case(i_riscv_cu_funct3)
          ADD_SUB :
          begin
            if(!funct7_illegal_zeroes)
            begin //add instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit0 && riscv_funct7_0) // mul
            begin
              o_riscv_cu_jump      = 1'b0 ;
              o_riscv_cu_regw      = 1'b1 ;
              o_riscv_cu_asel      = 1'b1 ;
              o_riscv_cu_bsel      = 1'b0 ;
              o_riscv_cu_memw      = 1'b0 ;
              o_riscv_cu_memr      = 1'b0 ;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b1100;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b00;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit5 && riscv_funct7_5)
            begin //sub instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100001;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          SLL :
          begin
            if (!funct7_illegal_zeroes)// sll instruction signals
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100010;
              o_riscv_cu_mulctrl   = 4'b000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit0 && riscv_funct7_0)
            begin // mulh
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b1101;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b00;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          SLT :
          begin
            if(!funct7_illegal_zeroes) // slt instruction signals
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100011;
              o_riscv_cu_mulctrl   = 4'b000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit0 && riscv_funct7_0 )
            begin //mulhsu
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b1111;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b00;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          SLTU :
          begin // sltu instruction signals
            if(!funct7_illegal_zeroes)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100100;
              o_riscv_cu_mulctrl   = 4'b000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit0 && riscv_funct7_0 ) // mulhu
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b1110;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b00;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          XOR :
          begin // xor instruction signals
            if(!funct7_illegal_zeroes)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100101;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit0 && riscv_funct7_0) //div
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1100;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end

          SRL_SRA :
          begin
            if(!funct7_illegal_zeroes)
            begin //srl instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100110;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit0 && riscv_funct7_0) //divu
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1101;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit5 && riscv_funct7_5)
            begin //sra instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100111;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          OR :
          begin // or instruction signals
            if (!funct7_illegal_zeroes)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b101000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit0 && riscv_funct7_0)   //rem
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1110;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          AND :
          begin // and instruction signals
            if(!funct7_illegal_zeroes)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b101001;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit0 && riscv_funct7_0) //remu
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1111;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end

        endcase
      end

      OPCODE_OP_WORD :
      begin
        case(i_riscv_cu_funct3)
          ADDW_SUBW :
          begin
            if(!funct7_illegal_zeroes)
            begin //addw instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit0 && riscv_funct7_0) // mulw
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b1000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b00;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit5 && riscv_funct7_5)
            begin //subw instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110001;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end

          SLLW :
          begin// sllw instruction signals
            if(!funct7_illegal_zeroes)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110010;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end

          DIVW :
          begin //divw
            if(!funct7_illegal_bit0 && riscv_funct7_0)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1000;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          SRLW_SRAW :
          begin
            if(!funct7_illegal_zeroes)
            begin //srlw instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110110;
              o_riscv_cu_mulctrl   = 4'b000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if (!funct7_illegal_bit0 && riscv_funct7_0) //divuw
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1001;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit5 && riscv_funct7_5)
            begin //sraw instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110111;
              o_riscv_cu_mulctrl   = 4'b000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          REMW :
          begin
            if(!funct7_illegal_bit0 && riscv_funct7_0)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1010;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end

          REMUW :
          begin //remuw
            if(!funct7_illegal_bit0 && riscv_funct7_0)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b1011;
              o_riscv_cu_funcsel   = 2'b01;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end

          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b1;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b000;
            o_riscv_cu_divctrl    = 4'b000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_illgalinst = 1'b1 ;
            o_riscv_cu_instret    = 1'b0;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
        endcase
      end

      OPCODE_OP_IMM :
      begin
        case(i_riscv_cu_funct3)
          ADDI :
          begin// addi instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b100000;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          SLLI :
          begin// slli instruction signals
            if(!(|i_riscv_cu_funct7[6:1]))
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b1;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100010;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end

          end
          SLTI :
          begin// slti instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b100011;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          SLTIU :
          begin // sltui instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b100100;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          XORI :
          begin // xori instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b100101;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          SRLI_SRAI :
          begin
            if(!(|i_riscv_cu_funct7[6:1]))
            begin //srli instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b1;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100110;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!i_riscv_cu_funct7[6] && !(|i_riscv_cu_funct7[4:1]) && riscv_funct7_5)
            begin //srai instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b1;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b100111;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
          end
          ORI :
          begin // ori instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b101000;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          ANDI :
          begin // andi instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b101001;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b1;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b000;
            o_riscv_cu_divctrl    = 4'b000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_illgalinst = 1'b1 ;
            o_riscv_cu_instret    = 1'b0;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
        endcase
      end

      OPCODE_OP_WORD_IMM :
      begin
        case(i_riscv_cu_funct3)
          ADDIW :
          begin //addiw instruction signals
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b01;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b110000;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          SLLIW :
          begin// slliw instruction signals
            if(!funct7_illegal_zeroes)
            begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b1;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110010;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
            end

          end
          SRLIW_SRAIW :
          begin
            if(!funct7_illegal_zeroes)
            begin //srliw instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b1;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110110;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else if(!funct7_illegal_bit5 && riscv_funct7_5)
            begin //sraiw instruction signals
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b1;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b0;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b01;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = 3'b000;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b110111;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
            end
            else
            begin
              o_riscv_cu_jump       = 1'b0;
              o_riscv_cu_regw       = 1'b0;
              o_riscv_cu_asel       = 1'b1;
              o_riscv_cu_bsel       = 1'b1;
              o_riscv_cu_memw       = 1'b0;
              o_riscv_cu_memr       = 1'b0;
              o_riscv_cu_storesrc   = 2'b00;//xx
              o_riscv_cu_resultsrc  = 2'b00;//xx
              o_riscv_cu_bcond      = 4'b0000;
              o_riscv_cu_memext     = 3'b000;//xx
              o_riscv_cu_immsrc     = 3'b000;
              o_riscv_cu_aluctrl    = 6'b100000;
              o_riscv_cu_mulctrl    = 4'b0000;
              o_riscv_cu_divctrl    = 4'b0000;
              o_riscv_cu_funcsel    = 2'b10;
              o_riscv_cu_amo       = 1'b0;
              o_riscv_cu_lr        = 1'b0;
              o_riscv_cu_sc        = 1'b0;
              o_riscv_cu_amo_op    = 5'b0;
              o_riscv_cu_illgalinst = 1'b1 ;
              o_riscv_cu_instret    = 1'b0;
            end
          end
          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo        = 1'b0;
            o_riscv_cu_amo_op     = 5'b0;
            o_riscv_cu_lr         = 1'b0;
            o_riscv_cu_sc         = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
            o_riscv_cu_instret    = 1'b0;
          end
        endcase
      end

      OPCODE_LOAD :
      begin
        case(i_riscv_cu_funct3)
          LB, LH, LW, LBU, LHU, LWU, LD:
          begin
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b1;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b10;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = i_riscv_cu_funct3;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b100000;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo        = 1'b0;
            o_riscv_cu_amo_op     = 5'b0;
            o_riscv_cu_lr         = 1'b0;
            o_riscv_cu_sc         = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
            o_riscv_cu_instret    = 1'b0;
          end
        endcase
      end

      OPCODE_JALR :
      begin
        case(i_riscv_cu_funct3)
          JALR :
          begin
            o_riscv_cu_jump      = 1'b1;
            o_riscv_cu_regw      = 1'b1;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b0;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = 2'b00;
            o_riscv_cu_resultsrc = 2'b00;
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;
            o_riscv_cu_immsrc    = 3'b000;
            o_riscv_cu_aluctrl   = 6'b101010;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo        = 1'b0;
            o_riscv_cu_amo_op     = 5'b0;
            o_riscv_cu_lr         = 1'b0;
            o_riscv_cu_sc         = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
            o_riscv_cu_instret    = 1'b0;
          end
        endcase
      end
      OPCODE_LUI :
      begin
        o_riscv_cu_jump      = 1'b0;
        o_riscv_cu_regw      = 1'b1;
        o_riscv_cu_asel      = 1'b1;//xx
        o_riscv_cu_bsel      = 1'b1;//xx
        o_riscv_cu_memw      = 1'b0;
        o_riscv_cu_memr      = 1'b0;
        o_riscv_cu_storesrc  = 2'b00;//xx
        o_riscv_cu_resultsrc = 2'b11;
        o_riscv_cu_bcond     = 4'b0000;
        o_riscv_cu_memext    = 3'b000;//xx
        o_riscv_cu_immsrc    = 3'b001;
        o_riscv_cu_aluctrl   = 6'b000000;//xx
        o_riscv_cu_mulctrl   = 4'b0000;
        o_riscv_cu_divctrl   = 4'b0000;
        o_riscv_cu_funcsel   = 2'b10;
        o_riscv_cu_amo       = 1'b0;
        o_riscv_cu_amo_op     = 5'b0;
        o_riscv_cu_lr        = 1'b0;
        o_riscv_cu_sc        = 1'b0;
      end

      OPCODE_AUIPC :
      begin
        o_riscv_cu_jump      = 1'b0;
        o_riscv_cu_regw      = 1'b1;
        o_riscv_cu_asel      = 1'b0;
        o_riscv_cu_bsel      = 1'b1;
        o_riscv_cu_memw      = 1'b0;
        o_riscv_cu_memr      = 1'b0;
        o_riscv_cu_storesrc  = 2'b00;//xx
        o_riscv_cu_resultsrc = 2'b01;
        o_riscv_cu_bcond     = 4'b0000;
        o_riscv_cu_memext    = 3'b000;//xx
        o_riscv_cu_immsrc    = 3'b001;
        o_riscv_cu_aluctrl   = 6'b100000;
        o_riscv_cu_mulctrl   = 4'b0000;
        o_riscv_cu_divctrl   = 4'b0000;
        o_riscv_cu_funcsel   = 2'b10;
        o_riscv_cu_amo       = 1'b0;
        o_riscv_cu_amo_op     = 5'b0;
        o_riscv_cu_lr        = 1'b0;
        o_riscv_cu_sc        = 1'b0;
      end

      OPCODE_JAL :
      begin
        o_riscv_cu_jump      = 1'b1;
        o_riscv_cu_regw      = 1'b1;
        o_riscv_cu_asel      = 1'b0;
        o_riscv_cu_bsel      = 1'b1;
        o_riscv_cu_memw      = 1'b0;
        o_riscv_cu_memr      = 1'b0;
        o_riscv_cu_storesrc  = 2'b00;//xx
        o_riscv_cu_resultsrc = 2'b00;
        o_riscv_cu_bcond     = 4'b0000;
        o_riscv_cu_memext    = 3'b000;//xx
        o_riscv_cu_immsrc    = 3'b010;
        o_riscv_cu_aluctrl   = 6'b100000;//xx
        o_riscv_cu_mulctrl   = 4'b0000;
        o_riscv_cu_divctrl   = 4'b0000;
        o_riscv_cu_funcsel   = 2'b10;
        o_riscv_cu_amo       = 1'b0;
        o_riscv_cu_amo_op     = 5'b0;
        o_riscv_cu_lr        = 1'b0;
        o_riscv_cu_sc        = 1'b0;
      end

      OPCODE_STORE :
      begin//all store instruction signals
        case(i_riscv_cu_funct3)
          SB, SH, SW, SD:
          begin
            o_riscv_cu_jump      = 1'b0;
            o_riscv_cu_regw      = 1'b0;
            o_riscv_cu_asel      = 1'b1;
            o_riscv_cu_bsel      = 1'b1;
            o_riscv_cu_memw      = 1'b1;
            o_riscv_cu_memr      = 1'b0;
            o_riscv_cu_storesrc  = i_riscv_cu_funct3[1:0];
            o_riscv_cu_resultsrc = 2'b00;//xx
            o_riscv_cu_bcond     = 4'b0000;
            o_riscv_cu_memext    = 3'b000;//xx
            o_riscv_cu_immsrc    = 3'b011;
            o_riscv_cu_aluctrl   = 6'b100000;
            o_riscv_cu_mulctrl   = 4'b0000;
            o_riscv_cu_divctrl   = 4'b0000;
            o_riscv_cu_funcsel   = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
          end
          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo        = 1'b0;
            o_riscv_cu_amo_op     = 5'b0;
            o_riscv_cu_lr         = 1'b0;
            o_riscv_cu_sc         = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
            o_riscv_cu_instret    = 1'b0;
          end
        endcase
      end

      OPCODE_BRANCH :
      begin//all branch instruction signals
        case(i_riscv_cu_funct3)
          BEQ, BNE, BLT, BGE, BLTU, BGEU:
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b0;
            o_riscv_cu_bsel       = 1'b1;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b00;
            o_riscv_cu_bcond[2:0] = i_riscv_cu_funct3;
            o_riscv_cu_bcond[3]   = 1'b1;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b100;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo       = 1'b0;
            o_riscv_cu_amo_op    = 5'b0;
            o_riscv_cu_lr        = 1'b0;
            o_riscv_cu_sc        = 1'b0;
            o_riscv_cu_illgalinst = 1'b0 ;
          end
          default :
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo        = 1'b0;
            o_riscv_cu_amo_op     = 5'b0;
            o_riscv_cu_lr         = 1'b0;
            o_riscv_cu_sc         = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
            o_riscv_cu_instret    = 1'b0;
          end
        endcase
      end

      7'b0000000 :
      begin
        o_riscv_cu_jump       = 1'b0;
        o_riscv_cu_regw       = 1'b0;
        o_riscv_cu_asel       = 1'b0;
        o_riscv_cu_bsel       = 1'b0;
        o_riscv_cu_memw       = 1'b0;
        o_riscv_cu_memr       = 1'b0;
        o_riscv_cu_storesrc   = 2'b00;//xx
        o_riscv_cu_resultsrc  = 2'b00;//xx
        o_riscv_cu_bcond      = 4'b0000;
        o_riscv_cu_memext     = 3'b000;//xx
        o_riscv_cu_immsrc     = 3'b000;
        o_riscv_cu_aluctrl    = 6'b000000;
        o_riscv_cu_mulctrl    = 4'b0000;
        o_riscv_cu_divctrl    = 4'b0000;
        o_riscv_cu_funcsel    = 2'b10;
        o_riscv_cu_amo       = 1'b0;
        o_riscv_cu_amo_op    = 5'b0;
        o_riscv_cu_lr        = 1'b0;
        o_riscv_cu_sc        = 1'b0;
        o_riscv_cu_illgalinst = 1'b0 ;
        o_riscv_cu_instret    = 1'b0;
      end
      
      OPCODE_ATOMIC:
      begin
        case(i_riscv_cu_funct3)
          ATOMIC_D:
          begin
            case(i_riscv_cu_funct7[6:2])
              LR:
              begin
                o_riscv_cu_jump      = 1'b0;
                o_riscv_cu_regw      = 1'b1;
                o_riscv_cu_asel      = 1'b1;
                o_riscv_cu_bsel      = 1'b0;
                o_riscv_cu_memw      = 1'b0;
                o_riscv_cu_memr      = 1'b0;
                o_riscv_cu_storesrc  = 2'b00;
                o_riscv_cu_resultsrc = 3'b010;
                o_riscv_cu_bcond     = 4'b0000;
                o_riscv_cu_memext    = 3'b011;
                o_riscv_cu_immsrc    = 3'b000;
                o_riscv_cu_aluctrl   = 6'b000000;
                o_riscv_cu_mulctrl   = 4'b000;
                o_riscv_cu_divctrl   = 4'b0000;
                o_riscv_cu_funcsel   = 2'b00;
                o_riscv_cu_amo       = 1'b0;
                o_riscv_cu_lr        = 2'b10;
                o_riscv_cu_sc        = 2'b00;
                o_riscv_cu_amo_op    = 5'b0;
              end
              SC:
              begin
                o_riscv_cu_jump      = 1'b0;
                o_riscv_cu_regw      = 1'b1;
                o_riscv_cu_asel      = 1'b1;
                o_riscv_cu_bsel      = 1'b0;
                o_riscv_cu_memw      = 1'b0;
                o_riscv_cu_memr      = 1'b0;
                o_riscv_cu_storesrc  = 2'b11;
                o_riscv_cu_resultsrc = 3'b100;
                o_riscv_cu_bcond     = 4'b0000;
                o_riscv_cu_memext    = 3'b011;
                o_riscv_cu_immsrc    = 3'b000;
                o_riscv_cu_aluctrl   = 6'b000000;
                o_riscv_cu_mulctrl   = 4'b000;
                o_riscv_cu_divctrl   = 4'b0000;
                o_riscv_cu_funcsel   = 2'b00;
                o_riscv_cu_amo       = 1'b0;
                o_riscv_cu_lr        = 2'b00;
                o_riscv_cu_sc        = 2'b10;
                o_riscv_cu_amo_op    = 5'b0;
              end
              AMOSWAP, AMOADD, AMOXOR, AMOAND, AMOOR, AMOMIN, AMOMAX, AMOMINU, AMOMAXU:
              begin
                o_riscv_cu_jump      = 1'b0;
                o_riscv_cu_regw      = 1'b1;
                o_riscv_cu_asel      = 1'b1;
                o_riscv_cu_bsel      = 1'b0;
                o_riscv_cu_memw      = 1'b0;
                o_riscv_cu_memr      = 1'b0;
                o_riscv_cu_storesrc  = 2'b11;
                o_riscv_cu_resultsrc = 3'b010;
                o_riscv_cu_bcond     = 4'b0000;
                o_riscv_cu_memext    = 3'b011;
                o_riscv_cu_immsrc    = 3'b000;
                o_riscv_cu_aluctrl   = 6'b000000;
                o_riscv_cu_mulctrl   = 4'b000;
                o_riscv_cu_divctrl   = 4'b0000;
                o_riscv_cu_funcsel   = 2'b00;
                o_riscv_cu_amo       = 1'b1;
                o_riscv_cu_lr        = 2'b00;
                o_riscv_cu_sc        = 2'b00;
                o_riscv_cu_amo_op    = i_riscv_cu_funct7[6:2];
              end
              default:
              begin
                o_riscv_cu_jump       = 1'b0;
                o_riscv_cu_regw       = 1'b0;
                o_riscv_cu_asel       = 1'b1;
                o_riscv_cu_bsel       = 1'b0;
                o_riscv_cu_memw       = 1'b0;
                o_riscv_cu_memr       = 1'b0;
                o_riscv_cu_storesrc   = 2'b00;
                o_riscv_cu_resultsrc  = 2'b01;
                o_riscv_cu_bcond      = 4'b0000;
                o_riscv_cu_memext     = 3'b000;
                o_riscv_cu_immsrc     = 3'b000;
                o_riscv_cu_aluctrl    = 6'b100000;
                o_riscv_cu_mulctrl    = 4'b0000;
                o_riscv_cu_divctrl    = 4'b0000;
                o_riscv_cu_funcsel    = 2'b10;
                o_riscv_cu_amo        = 1'b0;
                o_riscv_cu_amo_op     = 5'b0;
                o_riscv_cu_lr         = 1'b0;
                o_riscv_cu_sc         = 1'b0;
                o_riscv_cu_illgalinst = 1'b1;
                o_riscv_cu_instret    = 1'b0;
              end
            endcase
          end
          ATOMIC_W:
          begin
            case(i_riscv_cu_funct7[6:2])
              LR:
              begin
                o_riscv_cu_jump      = 1'b0;
                o_riscv_cu_regw      = 1'b1;
                o_riscv_cu_asel      = 1'b1;
                o_riscv_cu_bsel      = 1'b0;
                o_riscv_cu_memw      = 1'b0;
                o_riscv_cu_memr      = 1'b0;
                o_riscv_cu_storesrc  = 2'b00;
                o_riscv_cu_resultsrc = 3'b010;
                o_riscv_cu_bcond     = 4'b0000;
                o_riscv_cu_memext    = 3'b010;
                o_riscv_cu_immsrc    = 3'b000;
                o_riscv_cu_aluctrl   = 6'b000000;
                o_riscv_cu_mulctrl   = 4'b000;
                o_riscv_cu_divctrl   = 4'b0000;
                o_riscv_cu_funcsel   = 2'b00;
                o_riscv_cu_amo       = 1'b0;
                o_riscv_cu_amo_op     = 5'b0;
                o_riscv_cu_lr        = 2'b11;
                o_riscv_cu_sc        = 2'b00;
              end
              SC:
              begin
                o_riscv_cu_jump      = 1'b0;
                o_riscv_cu_regw      = 1'b1;
                o_riscv_cu_asel      = 1'b1;
                o_riscv_cu_bsel      = 1'b0;
                o_riscv_cu_memw      = 1'b0;
                o_riscv_cu_memr      = 1'b0;
                o_riscv_cu_storesrc  = 2'b10;
                o_riscv_cu_resultsrc = 3'b100;
                o_riscv_cu_bcond     = 4'b0000;
                o_riscv_cu_memext    = 3'b011;
                o_riscv_cu_immsrc    = 3'b000;
                o_riscv_cu_aluctrl   = 6'b000000;
                o_riscv_cu_mulctrl   = 4'b000;
                o_riscv_cu_divctrl   = 4'b0000;
                o_riscv_cu_funcsel   = 2'b00;
                o_riscv_cu_amo       = 1'b0;
                o_riscv_cu_amo_op    = 5'b0;
                o_riscv_cu_lr        = 2'b00;
                o_riscv_cu_sc        = 2'b11;
              end
              AMOSWAP, AMOADD, AMOXOR, AMOAND, AMOOR, AMOMIN, AMOMAX, AMOMINU, AMOMAXU:
              begin
                o_riscv_cu_jump      = 1'b0;
                o_riscv_cu_regw      = 1'b1;
                o_riscv_cu_asel      = 1'b1;
                o_riscv_cu_bsel      = 1'b0;
                o_riscv_cu_memw      = 1'b0;
                o_riscv_cu_memr      = 1'b0;
                o_riscv_cu_storesrc  = 2'b10;
                o_riscv_cu_resultsrc = 3'b010;
                o_riscv_cu_bcond     = 4'b0000;
                o_riscv_cu_memext    = 3'b010;
                o_riscv_cu_immsrc    = 3'b000;
                o_riscv_cu_aluctrl   = 6'b000000;
                o_riscv_cu_mulctrl   = 4'b000;
                o_riscv_cu_divctrl   = 4'b0000;
                o_riscv_cu_funcsel   = 2'b00;
                o_riscv_cu_amo       = 1'b1;
                o_riscv_cu_lr        = 2'b00;
                o_riscv_cu_sc        = 2'b00;
                o_riscv_cu_amo_op    = i_riscv_cu_funct7[6:2];
              end
              default:
              begin
                o_riscv_cu_jump       = 1'b0;
                o_riscv_cu_regw       = 1'b0;
                o_riscv_cu_asel       = 1'b1;
                o_riscv_cu_bsel       = 1'b0;
                o_riscv_cu_memw       = 1'b0;
                o_riscv_cu_memr       = 1'b0;
                o_riscv_cu_storesrc   = 2'b00;
                o_riscv_cu_resultsrc  = 2'b01;
                o_riscv_cu_bcond      = 4'b0000;
                o_riscv_cu_memext     = 3'b000;
                o_riscv_cu_immsrc     = 3'b000;
                o_riscv_cu_aluctrl    = 6'b100000;
                o_riscv_cu_mulctrl    = 4'b0000;
                o_riscv_cu_divctrl    = 4'b0000;
                o_riscv_cu_funcsel    = 2'b10;
                o_riscv_cu_amo        = 1'b0;
                o_riscv_cu_amo_op     = 5'b0;
                o_riscv_cu_lr         = 1'b0;
                o_riscv_cu_sc         = 1'b0;
                o_riscv_cu_illgalinst = 1'b1;
                o_riscv_cu_instret    = 1'b0;
              end
            endcase
          end
          default:
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b0;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;
            o_riscv_cu_resultsrc  = 2'b01;
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
            o_riscv_cu_amo        = 1'b0;
            o_riscv_cu_amo_op     = 5'b0;
            o_riscv_cu_lr         = 1'b0;
            o_riscv_cu_sc         = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
            o_riscv_cu_instret    = 1'b0;
          end
        endcase
      end
      
      OPCODE_CSR:
      begin
        o_riscv_cu_jump       = 1'b0;
        o_riscv_cu_regw       = 1'b0;
        o_riscv_cu_asel       = 1'b0;  //x
        o_riscv_cu_bsel       = 1'b0;  //x
        o_riscv_cu_memw       = 1'b0;
        o_riscv_cu_memr       = 1'b0;
        o_riscv_cu_storesrc   = 2'b00;  //xx
        o_riscv_cu_resultsrc  = 2'b00;  //xx
        o_riscv_cu_bcond      = 4'b0000;
        o_riscv_cu_memext     = 3'b000;//xx
        o_riscv_cu_immsrc     = 3'b000;
        o_riscv_cu_aluctrl    = 6'b000000; //0xxxxx
        o_riscv_cu_mulctrl    = 4'b0000;  //0xxxx
        o_riscv_cu_divctrl    = 4'b0000;  //0xxxx
        o_riscv_cu_funcsel    = 2'b00;    //xx
        o_riscv_cu_amo        = 1'b0;
        o_riscv_cu_amo_op     = 5'b0;
        o_riscv_cu_lr         = 1'b0;
        o_riscv_cu_sc         = 1'b0;

        case(i_riscv_cu_funct3) // differentiate between ecall,mret,sret(000) and CSR instructions otherthan 000
          3'b000:
          begin
            riscv_cu_detect_ecall = 1'b0;
            // decode the immiediate field
            case (i_riscv_cu_constimm12)
              // ECALL -> inject exception
              12'b0:
              begin
                riscv_cu_detect_ecall = 1'b1;
                o_riscv_cu_illgalinst = 1'b0;
                o_riscv_cu_csrop = 'b000;
                o_riscv_cu_instret     = 1'b0;
                /*   case (i_riscv_cu_privlvl)
                PRIV_LVL_S :  o_riscv_cu_cause = ENV_CALL_SMODE;

                PRIV_LVL_U : o_riscv_cu_cause = ENV_CALL_UMODE;

                PRIV_LVL_M  :  o_riscv_cu_cause = ENV_CALL_MMODE; */
              end

              // MRET
              12'b11_0000_0010:
              begin
                o_riscv_cu_csrop = MRET;
                riscv_cu_detect_ecall = 1'b0;
                //o_riscv_cu_mret = 1'b1;
                // check privilege level, MRET can only be executed in M mode
                // otherwise  raise an illegal instruction
                if ( (support_supervisor && i_riscv_cu_privlvl == PRIV_LVL_S) || (support_user &&i_riscv_cu_privlvl == PRIV_LVL_U) )begin
                  o_riscv_cu_illgalinst = 1'b1;
                  o_riscv_cu_csrop = 'b0;
                end
              end



             12'b1_0000_0010: //SRET 
               //  do not change privilege level if this is an illegal instruction
                      //o_riscv_cu_csrop = 'b0;
               begin

                  if (support_supervisor) 
                    begin
                        o_riscv_cu_csrop = SRET;
                        riscv_cu_detect_ecall = 1'b0;
                    // raise an illegal instruction if we are in the wrong privilege level
                    // so check privilege level, as SRET can only be executed in S and M mode
                        if ( (support_user && (i_riscv_cu_privlvl == PRIV_LVL_U)) || ((i_riscv_cu_privlvl == PRIV_LVL_S) && i_riscv_cu_tsr) ) begin
                        // if we are in S-Mode and Trap SRET (tsr) is set -> trap on illegal instruction
                            o_riscv_cu_illgalinst = 1'b1;
                            o_riscv_cu_csrop = 'b0;
                        end   
                        else
                          o_riscv_cu_illgalinst = 1'b0;
                          o_riscv_cu_csrop = SRET;                        
                    end
                  else 
                    begin
                        o_riscv_cu_illgalinst = 1'b1;
                        o_riscv_cu_csrop = 'b0;
                
                    end

              end
             
              default :
              begin
                riscv_cu_detect_ecall = 1'b0;
                o_riscv_cu_instret    = 1'b0;
                o_riscv_cu_illgalinst = 1'b1;
              end
            endcase
          end
          //RS/C instruction  always read
          // RS/C instruction  write when RS1 ~= X0 (zero value register) In case non immdeaite CSR inst
          // when uimm  ~=  0  In case immdeaite CSR inst
          3'b001:
          begin  // CSRRW
            o_riscv_cu_sel_rs_imm  = 'b0 ;
            o_riscv_cu_csrop       = CSR_WRITE;
            o_riscv_cu_immsrc      = 3'b000;  //xxx
            o_riscv_cu_iscsr       = 'b1 ;
            o_riscv_cu_regw        = 'b1 ;
          end


          3'b101:
          begin  // CSRRWI
            o_riscv_cu_sel_rs_imm  = 'b1;
            o_riscv_cu_immsrc      = 3'b000;  //xxx
            o_riscv_cu_csrop       = CSR_WRITE;
            o_riscv_cu_iscsr       = 'b1 ;
            o_riscv_cu_regw        = 'b1 ;
          end

          3'b010:
          begin  // CSRRS
            o_riscv_cu_sel_rs_imm  = 'b0 ;
            o_riscv_cu_immsrc      = 3'b000;  //xxx
            o_riscv_cu_iscsr       = 'b1 ;
            o_riscv_cu_regw        = 'b1 ;
            //check added notes
            if (i_riscv_cu_rs1 == 5'b0)
              o_riscv_cu_csrop = CSR_READ;
            else
              o_riscv_cu_csrop = CSR_SET;

          end

          3'b011:
          begin  // CSRRC
            o_riscv_cu_sel_rs_imm  = 'b0 ;
            o_riscv_cu_immsrc      = 3'b111;
            o_riscv_cu_iscsr       = 'b1 ;
            o_riscv_cu_regw        = 'b1 ;

            if (i_riscv_cu_rs1 == 5'b0)
              o_riscv_cu_csrop = CSR_READ;
            else
              o_riscv_cu_csrop = CSR_CLEAR;
          end


          3'b110:
          begin  // CSRRSI
            o_riscv_cu_sel_rs_imm = 'b1;
            o_riscv_cu_immsrc     = 3'b111 ;
            o_riscv_cu_iscsr      = 'b1 ;
            o_riscv_cu_regw       = 'b1 ;
            //check added note
            if (i_riscv_cu_rs1 == 5'b0)
              o_riscv_cu_csrop = CSR_READ;
            else
              o_riscv_cu_csrop = CSR_SET;
          end

          3'b111:
          begin  // CSRRCI
            o_riscv_cu_sel_rs_imm = 'b1;
            o_riscv_cu_immsrc     = 3'b111 ;
            o_riscv_cu_iscsr      = 'b1 ;
            o_riscv_cu_regw       = 'b1 ;
            //check added note
            if (i_riscv_cu_rs1 == 5'b0)
              o_riscv_cu_csrop = CSR_READ;
            else
              o_riscv_cu_csrop = CSR_CLEAR;
          end

          default :
          begin
            riscv_cu_detect_ecall = 1'b0;
            o_riscv_cu_instret    = 1'b0;
            o_riscv_cu_illgalinst = 1'b1;
          end
        endcase
      end
      default :
      begin
        o_riscv_cu_jump       = 1'b0;
        o_riscv_cu_regw       = 1'b0;
        o_riscv_cu_asel       = 1'b1;
        o_riscv_cu_bsel       = 1'b1;
        o_riscv_cu_memw       = 1'b0;
        o_riscv_cu_memr       = 1'b0;
        o_riscv_cu_storesrc   = 2'b00;//xx
        o_riscv_cu_resultsrc  = 2'b00;//xx
        o_riscv_cu_bcond      = 4'b0000;
        o_riscv_cu_memext     = 3'b000;//xx
        o_riscv_cu_immsrc     = 3'b000;
        o_riscv_cu_aluctrl    = 6'b100000;
        o_riscv_cu_mulctrl    = 4'b0000;
        o_riscv_cu_divctrl    = 4'b0000;
        o_riscv_cu_funcsel    = 2'b10;
        o_riscv_cu_amo        = 1'b0;
        o_riscv_cu_lr         = 1'b0;
        o_riscv_cu_sc         = 1'b0;
        o_riscv_cu_illgalinst = 1'b1 ;
        o_riscv_cu_instret    = 1'b0;
      end
    endcase

    if (riscv_cu_detect_ecall)
    begin
      case (i_riscv_cu_privlvl)

        PRIV_LVL_U :
        begin
          if (support_user)                        //if support u-mode
            o_riscv_cu_ecall_u = 1;
          // o_riscv_cu_ex_cause = ENV_CALL_UMODE;
          else
            o_riscv_cu_ecall_u = 0;
        end
        PRIV_LVL_S :
        begin
          if (support_supervisor)                            //if support s-mode
            o_riscv_cu_ecall_s = 1;
          //o_riscv_cu_ex_cause = ENV_CALL_SMODE;
          else
            o_riscv_cu_ecall_s = 0;
        end
        PRIV_LVL_M  :
        begin
          o_riscv_cu_ecall_m = 1;
          // o_riscv_cu_ex_cause = ENV_CALL_MMODE;   // always supported
        end

        default:
        begin
          o_riscv_cu_ecall_u = 0;
          o_riscv_cu_ecall_s = 0;
          o_riscv_cu_ecall_m = 0;
        end

      endcase
    end
    else
    begin
      o_riscv_cu_ecall_u = 0;
      o_riscv_cu_ecall_s = 0;
      o_riscv_cu_ecall_m = 0;
    end
  end
endmodule