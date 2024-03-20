module riscv_cu (
    input  logic [6:0]  i_riscv_cu_opcode       ,
    input  logic [2:0]  i_riscv_cu_funct3       ,
    input  logic [6:0]  i_riscv_cu_funct7       ,
    input  logic [1:0]  i_riscv_cu_privlvl      , //<--- Privilege
    input  logic [4:0]  i_riscv_cu_rs1          , //<--- Privilege
    input  logic [11:0] i_riscv_cu_cosntimm12   , //<--- Privilege
    output logic        o_riscv_cu_jump         ,
    output logic        o_riscv_cu_regw         ,
    output logic        o_riscv_cu_asel         ,
    output logic        o_riscv_cu_bsel         ,
    output logic        o_riscv_cu_memw         ,
    output logic        o_riscv_cu_memr         ,
    output logic [1:0]  o_riscv_cu_storesrc     ,
    output logic [1:0]  o_riscv_cu_resultsrc    ,
    output logic [1:0]  o_riscv_cu_funcsel      ,
    output logic [3:0]  o_riscv_cu_bcond        ,
    output logic [2:0]  o_riscv_cu_memext       ,
    output logic [2:0]  o_riscv_cu_immsrc       ,
    output logic [3:0]  o_riscv_cu_mulctrl      ,
    output logic [3:0]  o_riscv_cu_divctrl      ,
    output logic [5:0]  o_riscv_cu_aluctrl      ,
    output logic [2:0]  o_riscv_cu_csrop        , //<--- Privilege
    output logic        o_riscv_cu_sel_rs_imm   , //<--- Privilege
    output logic        o_riscv_cu_illgalinst   , //<--- Privilege
    output logic        o_riscv_cu_iscsr        , //<--- Privilege
    output logic        o_riscv_cu_ecall_u      , //<--- Privilege
    output logic        o_riscv_cu_ecall_s      , //<--- Privilege
    output logic        o_riscv_cu_ecall_m      , //<--- Privilege
    output logic        o_riscv_cu_instret      , //<--- Privilege
    output logic        o_riscv_cu_is_atomic    ,
    output logic [1:0]  o_riscv_cu_lr           ,
    output logic [1:0]  o_riscv_cu_sc

  );

  localparam  ENV_CALL_UMODE  = 8     ,
              ENV_CALL_SMODE  = 9     ,
              ENV_CALL_MMODE  = 11    ,
              ILLEGAL_INSTR   = 2     ,
              PRIV_LVL_U      = 2'b00 ,
              PRIV_LVL_S      = 2'b01 ,
              PRIV_LVL_M      = 2'b11 ;

  parameter   SUPPORT_U = 0,
              SUPPORT_S = 0;

  logic riscv_cu_detect_ecall  ;


  //CSR operation type
  localparam  CSR_WRITE = 3'b001,
              CSR_SET   = 3'b010,
              CSR_CLEAR = 3'b011,
              CSR_READ  = 3'b101,
              SRET      = 3'b110,
              MRET      = 3'b111;

  assign funct7_illegal_zeroes = |i_riscv_cu_funct7;
  assign funct7_illegal_bit0   = |i_riscv_cu_funct7[6:1];
  assign funct7_illegal_bit5   = (i_riscv_cu_funct7[6] || (|i_riscv_cu_funct7[4:0]));
  assign riscv_funct7_0        = i_riscv_cu_funct7[0];
  assign riscv_funct7_5        = i_riscv_cu_funct7[5];
  assign o_riscv_cu_is_atomic  = (i_riscv_cu_opcode == 7'b0101111);

  always_comb
    begin:ctrl_sig_proc
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
      //atomic intialize
      o_riscv_cu_lr         = 'b0;
      o_riscv_cu_sc         = 'b0;
      ////////////////////////////////
      case(i_riscv_cu_opcode)
        7'b0110011:
          begin
            case(i_riscv_cu_funct3)
              3'b000:
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
                    end
                  else if (!funct7_illegal_bit0 && riscv_funct7_0) // mul
                    begin
                      o_riscv_cu_jump       = 1'b0 ;
                      o_riscv_cu_regw       = 1'b1 ;
                      o_riscv_cu_asel       = 1'b1 ;
                      o_riscv_cu_bsel       = 1'b0 ;
                      o_riscv_cu_memw       = 1'b0 ;
                      o_riscv_cu_memr       = 1'b0 ;
                      o_riscv_cu_storesrc   = 2'b00;
                      o_riscv_cu_resultsrc  = 2'b01;
                      o_riscv_cu_bcond      = 4'b0000;
                      o_riscv_cu_memext     = 3'b000;
                      o_riscv_cu_immsrc     = 3'b000;
                      o_riscv_cu_aluctrl    = 6'b000000;
                      o_riscv_cu_mulctrl    = 4'b1100;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b00;
                    end
                  else if (!funct7_illegal_bit5 && riscv_funct7_5)
                    begin //sub instruction signals
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
                      o_riscv_cu_aluctrl    = 6'b100001;
                      o_riscv_cu_mulctrl    = 4'b0000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b10;
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b001:
                begin
                  if (!funct7_illegal_zeroes)// sll instruction signals
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
                      o_riscv_cu_aluctrl    = 6'b100010;
                      o_riscv_cu_mulctrl    = 4'b000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b10;
                    end
                  else if(!funct7_illegal_bit0 && riscv_funct7_0)
                    begin // mulh
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
                      o_riscv_cu_aluctrl    = 6'b000000;
                      o_riscv_cu_mulctrl    = 4'b1101;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b00;
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b010:
                begin
                  if(!funct7_illegal_zeroes) // slt instruction signals
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
                      o_riscv_cu_aluctrl    = 6'b100011;
                      o_riscv_cu_mulctrl    = 4'b000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b10;
                    end
                  else if(!funct7_illegal_bit0 && riscv_funct7_0 )
                    begin //mulhsu
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
                      o_riscv_cu_aluctrl    = 6'b000000;
                      o_riscv_cu_mulctrl    = 4'b1111;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b00;
                    end
                end
              3'b011:
                begin // sltu instruction signals
                  if(!funct7_illegal_zeroes)
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
                      o_riscv_cu_aluctrl    = 6'b100100;
                      o_riscv_cu_mulctrl    = 4'b000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b10;
                    end
                  else if (!funct7_illegal_bit0 && riscv_funct7_0 ) // mulhu
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
                      o_riscv_cu_aluctrl    = 6'b000000;
                      o_riscv_cu_mulctrl    = 4'b1110;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b00;
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b100:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end

              3'b101:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b110:
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
                    end
                  else if(!funct7_illegal_bit0 && riscv_funct7_0)   //rem
                    begin
                      o_riscv_cu_jump       = 1'b0;
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b111:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end

            endcase
          end
        7'b0111011:
          begin
            case(i_riscv_cu_funct3)
              3'b000:
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
                    end
                  else if (!funct7_illegal_bit0 && riscv_funct7_0) // mulw
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
                      o_riscv_cu_aluctrl    = 6'b000000;
                      o_riscv_cu_mulctrl    = 4'b1000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b00;
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end

              3'b001:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end

              3'b100:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b101:
                begin
                  if(!funct7_illegal_zeroes)
                    begin //srlw instruction signals
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
                      o_riscv_cu_aluctrl    = 6'b110110;
                      o_riscv_cu_mulctrl    = 4'b000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b10;
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
                    end
                  else if(!funct7_illegal_bit5 && riscv_funct7_5)
                    begin //sraw instruction signals
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
                      o_riscv_cu_aluctrl    = 6'b110111;
                      o_riscv_cu_mulctrl    = 4'b000;
                      o_riscv_cu_divctrl    = 4'b0000;
                      o_riscv_cu_funcsel    = 2'b10;
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b110:
                begin //remw
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
                    end
                end
              3'b111:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end

                end
              default:
                begin
                  o_riscv_cu_jump        = 1'b0;
                  o_riscv_cu_regw        = 1'b1;
                  o_riscv_cu_asel        = 1'b1;
                  o_riscv_cu_bsel        = 1'b0;
                  o_riscv_cu_memw        = 1'b0;
                  o_riscv_cu_memr        = 1'b0;
                  o_riscv_cu_storesrc    = 2'b00;
                  o_riscv_cu_resultsrc   = 2'b01;
                  o_riscv_cu_bcond       = 4'b0000;
                  o_riscv_cu_memext      = 3'b000;
                  o_riscv_cu_immsrc      = 3'b000;
                  o_riscv_cu_aluctrl     = 6'b100000;
                  o_riscv_cu_mulctrl     = 4'b000;
                  o_riscv_cu_divctrl     = 4'b000;
                  o_riscv_cu_funcsel     = 2'b10;
                  o_riscv_cu_illgalinst  = 1'b1 ;
                  o_riscv_cu_instret     = 1'b0;
                end
            endcase
          end
        7'b0010011:
          begin
            case(i_riscv_cu_funct3)
              3'b000:
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
                end
              3'b001:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end

                end
              3'b010:
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
                end
              3'b011:
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
                end
              3'b100:
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
                end
              3'b101:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              3'b110:
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
                end
              3'b111:
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
                end
            endcase
          end
        7'b0011011:
          begin
            case(i_riscv_cu_funct3)
              3'b000:
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
                end
              3'b001:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end

                end
              3'b101:
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
                    end
                  else
                    begin
                      o_riscv_cu_jump       = 1'b0;
                      o_riscv_cu_regw       = 1'b0;
                      o_riscv_cu_asel       = 1'b1;
                      o_riscv_cu_bsel       = 1'b1;
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
                    end
                end
              default:
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
                  o_riscv_cu_aluctrl   = 6'b100000;
                  o_riscv_cu_mulctrl   = 4'b0000;
                  o_riscv_cu_divctrl   = 4'b0000;
                  o_riscv_cu_funcsel   = 2'b10;
                  o_riscv_cu_illgalinst = 1'b1;
                  o_riscv_cu_instret     = 1'b0;
                end
            endcase
          end
        7'b0000011:
          begin//all load instructions instruction signals
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
          end
        7'b1100111:
          begin//jalr instruction signals
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
          end
        7'b0110111:
          begin//lui instruction signals
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
          end
        7'b0010111:
          begin//auipc instruction signals
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
          end
        7'b1101111:
          begin//jal instruction signals
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
          end

        7'b0100011:
          begin//all store instruction signals
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
          end
        7'b1100011:
          begin//all branch instruction signals
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b0;
            o_riscv_cu_bsel       = 1'b1;
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_memr       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;//xx
            o_riscv_cu_resultsrc  = 2'b00;//xx
            o_riscv_cu_bcond[2:0] = i_riscv_cu_funct3;
            o_riscv_cu_bcond[3]   = 1'b1;
            o_riscv_cu_memext     = 3'b000;//xx
            o_riscv_cu_immsrc     = 3'b100;
            o_riscv_cu_aluctrl    = 6'b100000;
            o_riscv_cu_mulctrl    = 4'b0000;
            o_riscv_cu_divctrl    = 4'b0000;
            o_riscv_cu_funcsel    = 2'b10;
          end
        7'b0101111:
          begin // atomic operations
            case(i_riscv_cu_funct7[6:2])
             //LR
              5'b00010:
              begin
              o_riscv_cu_jump      = 1'b0;
              o_riscv_cu_regw      = 1'b1;
              o_riscv_cu_asel      = 1'b1;
              o_riscv_cu_bsel      = 1'b0;
              o_riscv_cu_memw      = 1'b0;
              o_riscv_cu_memr      = 1'b1;
              o_riscv_cu_storesrc  = 2'b00;
              o_riscv_cu_resultsrc = 2'b10;
              o_riscv_cu_bcond     = 4'b0000;
              o_riscv_cu_memext    = i_riscv_cu_funct3;
              o_riscv_cu_immsrc    = 3'b000;
              o_riscv_cu_aluctrl   = 6'b000000;
              o_riscv_cu_mulctrl   = 4'b0000;
              o_riscv_cu_divctrl   = 4'b0000;
              o_riscv_cu_funcsel   = 2'b10;

                if(i_riscv_cu_funct3 == 3'b010)
                  begin
                    o_riscv_cu_lr        = 2'b11; //LR.W
                  end
                else if(i_riscv_cu_funct3 == 3'b011)
                  begin
                    o_riscv_cu_lr        = 2'b10; //LR.D
                  end
                else
                  begin
                    o_riscv_cu_lr         = 2'b00;
                    o_riscv_cu_illgalinst = 1'b1;
                    o_riscv_cu_regw       = 1'b0;
                  end
              end

              5'b00011:
                begin //SC
                  o_riscv_cu_jump      = 1'b0;
                  o_riscv_cu_regw      = 1'b1;
                  o_riscv_cu_asel      = 1'b1;
                  o_riscv_cu_bsel      = 1'b1;
                  o_riscv_cu_memw      = 1'b1;
                  o_riscv_cu_memr      = 1'b0;
                  o_riscv_cu_storesrc  = i_riscv_cu_funct3[1:0];
                  o_riscv_cu_resultsrc = 2'b00;//xx
                  o_riscv_cu_bcond     = 4'b0000;
                  o_riscv_cu_memext    = 3'b000;//xx
                  o_riscv_cu_immsrc    = 3'b000;
                  o_riscv_cu_aluctrl   = 6'b000000;
                  o_riscv_cu_mulctrl   = 4'b0000;
                  o_riscv_cu_divctrl   = 4'b0000;
                  o_riscv_cu_funcsel   = 2'b10;
                  o_riscv_cu_illgalinst = 1'b0;

                  if(i_riscv_cu_funct3 == 3'b010)
                    begin
                      o_riscv_cu_sc        = 2'b11; //SC.W
                    end
                  else if(i_riscv_cu_funct3 == 3'b011)
                    begin
                      o_riscv_cu_sc        = 2'b10; //SC.D
                    end
                  else
                    begin
                      o_riscv_cu_illgalinst = 1'b1;
                      o_riscv_cu_sc         = 2'b00;
                      o_riscv_cu_regw       = 1'b0;
                    end
                end

            endcase
          end

        7'b0000000:
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
            o_riscv_cu_illgalinst = 1'b0 ;
            o_riscv_cu_instret    = 1'b0;

          end
        7'b1110011:
          begin

            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b0;  //x
            o_riscv_cu_bsel       = 1'b0;  //x
            o_riscv_cu_memw       = 1'b0;
            o_riscv_cu_storesrc   = 2'b00;  //xx
            o_riscv_cu_resultsrc  = 2'b00;  //xx
            o_riscv_cu_bcond      = 4'b0000;
            o_riscv_cu_memext     = 3'b000;//xx
            o_riscv_cu_immsrc     = 3'b000;
            o_riscv_cu_aluctrl    = 6'b000000; //0xxxxx
            o_riscv_cu_mulctrl    = 4'b0000;  //0xxxx
            o_riscv_cu_divctrl    = 4'b0000;  //0xxxx
            o_riscv_cu_funcsel    = 2'b00;    //xx




            case(i_riscv_cu_funct3) // differentiate between ecall,mret,sret(000) and CSR instructions otherthan 000
              3'b000:
                begin
                  riscv_cu_detect_ecall = 1'b0;
                  // decode the immiediate field
                  case (i_riscv_cu_cosntimm12)
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
                        if ( ( i_riscv_cu_privlvl == PRIV_LVL_S) || (i_riscv_cu_privlvl == PRIV_LVL_U) )
                          o_riscv_cu_illgalinst = 1'b1;
                      end
                    default
                    begin
                      riscv_cu_detect_ecall = 1'b0;
                      o_riscv_cu_instret     = 1'b0;
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
            endcase
          end
        default:
          begin
            o_riscv_cu_jump       = 1'b0;
            o_riscv_cu_regw       = 1'b0;
            o_riscv_cu_asel       = 1'b1;
            o_riscv_cu_bsel       = 1'b1;
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
            o_riscv_cu_instret     = 1'b0;
          end
      endcase
      /* --------------------- */
      // Exception handling From decode stage
      /* ---------------------  */
      //if (illegal_instr || is_illegal_i)
      /*if (illegal_instr )    // is_illegal_i if csr access fault ?? make may cahnged
             o_riscv_cu_illgalinst = 1;
              // o_riscv_cu_ex_cause = ILLEGAL_INSTR;
       else
              o_riscv_cu_illgalinst = 0;
           */
      if (riscv_cu_detect_ecall)
        begin
          case (i_riscv_cu_privlvl)

            PRIV_LVL_U :
              begin
                if (SUPPORT_U)                        //if support u-mode
                  o_riscv_cu_ecall_u = 1;
                // o_riscv_cu_ex_cause = ENV_CALL_UMODE;
                else
                  o_riscv_cu_ecall_u = 0;
              end
            PRIV_LVL_S :
              begin
                if (SUPPORT_S)                            //if support s-mode
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