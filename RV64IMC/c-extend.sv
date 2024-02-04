module C_extend (inst, immsrc, ext_imm);

  typedef enum {CB, CB_CI, CJ, CIW, CADDI16SP, LSW, LSDW, SPLW, SPSW, SPLD, SPSD, LU} imm_type;

  input   logic   [12:2]  inst;
  output  logic   [63:0]  ext_imm;
  input imm_type  immsrc;
  


  always_comb begin
    case(immsrc)
      CB:         ext_imm = { {56{inst[12]}}, inst[6:5], inst[2], inst[11:10], inst[4:3], 1'b0};
      CB_CI:      ext_imm = { {59{inst[12]}}, inst[4:0]};
      CJ:         ext_imm = { {53{inst[12]}}, inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3], 1'b0};
      CIW:        ext_imm = { {54{1'b0}}, inst[10:7], inst[12:11], inst[5], inst[6], 2'b00};
      CADDI16SP:  ext_imm = { {55{inst[12]}}, inst[4:3], inst[5], inst[2], inst[6], 4'b0000};
      LSW:        ext_imm = { {57{1'b0}}, inst[5], inst[12:10], inst[6], 2'b00};
      LSDW:       ext_imm = { {56{1'b0}}, inst[6:5], inst[12:10], 3'b000};
      SPLW:       ext_imm = { {56{1'b0}}, inst[3:2], inst[12], inst[6:4], 2'b00};
      SPSW:       ext_imm = { {56{1'b0}}, inst[8:7], inst[12:9], 2'b00};
      SPLD:       ext_imm = { {55{1'b0}}, inst[4:2], inst[12], inst[6:5], 3'b000};
      SPSD:       ext_imm = { {55{1'b0}}, inst[9:7], inst[12:10], 3'b000};
      LU:         ext_imm = { {47{inst[12]}}, inst[6:2], {12{1'b0}}};

      default: ext_imm = 'bx;
    endcase
  end

endmodule : C_extend 