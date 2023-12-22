module riscv_cu (
  input  logic [6:0]  i_riscv_cu_opcode, //7-bit input opcode[6:0]
  input  logic [2:0]  i_riscv_cu_funct3, //3-bit input  
  input  logic        i_riscv_cu_funct7_5,
  output logic        o_riscv_cu_jump, 
  output logic        o_riscv_cu_regw,
  output logic        o_riscv_cu_asel,
  output logic        o_riscv_cu_bsel,
  output logic        o_riscv_cu_memw,  
  output logic [1:0]  o_riscv_cu_storesrc,
  output logic [1:0]  o_riscv_cu_resultsrc,
  output logic [3:0]  o_riscv_cu_bcond,//msb for branch enable
  output logic [2:0]  o_riscv_cu_memext,
  output logic [2:0]  o_riscv_cu_immsrc,
  output logic [4:0]  o_riscv_cu_aluctrl
);

always_comb
  begin:ctrl_sig_proc
    case(i_riscv_cu_opcode)
        7'b0110011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin
                                if(!i_riscv_cu_funct7_5)
                                  begin //add instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b00000;
                                  end
                                else  
                                  begin //sub instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b00001;
                                  end
                              end
                       3'b001:begin// sll instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00010;
                              end  
                       3'b010:begin// slt instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00011;
                              end 
                       3'b011:begin // sltu instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00100;
                              end
                       3'b100:begin // xor instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00101;
                              end
                       3'b101:begin
                                if(!i_riscv_cu_funct7_5)
                                  begin //srl instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b00110;
                                  end
                                else  
                                  begin //sra instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b00111;
                                  end
                              end    
                       3'b110:begin // or instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b01000;
                              end 
                       3'b111:begin // and instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b01001;
                              end
                     endcase            
                   end      
        7'b0111011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin
                                if(!i_riscv_cu_funct7_5)
                                  begin //addw instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b10000;
                                  end
                                else  
                                  begin //subw instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b10001;
                                  end               
                                end                                           
                       3'b001:begin// sllw instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b0;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b10010;
                              end                                     
                       3'b101:begin
                                if(!i_riscv_cu_funct7_5)
                                  begin //srlw instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b10110;
                                  end
                                else  
                                  begin //sraw instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b0;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b10111;
                                  end
                               end 
                       default:begin 
                                 o_riscv_cu_jump      = 1'b0;
                                 o_riscv_cu_regw      = 1'b1;
                                 o_riscv_cu_asel      = 1'b1;
                                 o_riscv_cu_bsel      = 1'b0;
                                 o_riscv_cu_memw      = 1'b0;
                                 o_riscv_cu_storesrc  = 2'b00;
                                 o_riscv_cu_resultsrc = 2'b01;
                                 o_riscv_cu_bcond     = 4'b0000;
                                 o_riscv_cu_memext    = 3'b000;
                                 o_riscv_cu_immsrc    = 3'b000;
                                 o_riscv_cu_aluctrl   = 5'b00000;  
                              end                                                                  
                     endcase
                   end        
        7'b0010011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin// addi instruction signals
                               o_riscv_cu_jump      = 1'b0;
                               o_riscv_cu_regw      = 1'b1;
                               o_riscv_cu_asel      = 1'b1;
                               o_riscv_cu_bsel      = 1'b1;
                               o_riscv_cu_memw      = 1'b0;
                               o_riscv_cu_storesrc  = 2'b00;
                               o_riscv_cu_resultsrc = 2'b01;
                               o_riscv_cu_bcond     = 4'b0000;
                               o_riscv_cu_memext    = 3'b000;
                               o_riscv_cu_immsrc    = 3'b000;
                               o_riscv_cu_aluctrl   = 5'b00000;                           
                              end
                       3'b001:begin// slli instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00010;
                              end  
                       3'b010:begin// slti instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00011;
                              end 
                       3'b011:begin // sltui instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00100;
                              end
                       3'b100:begin // xori instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00101;
                              end
                       3'b101:begin
                                if(!i_riscv_cu_funct7_5)
                                  begin //srli instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b1;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b00110;
                                  end
                                else  
                                  begin //srai instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b1;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b00111;
                                  end
                              end    
                       3'b110:begin // ori instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b01000;
                              end 
                       3'b111:begin // andi instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b01001;
                              end
                     endcase            
                   end                            
        7'b0011011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin //addiw instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b10000;
                              end
                       3'b001:begin// slliw instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b01;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b10010;
                              end                                     
                       3'b101:begin
                                if(!i_riscv_cu_funct7_5)
                                  begin //srliw instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b1;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b10110;
                                  end
                                else  
                                  begin //sraiw instruction signals
                                    o_riscv_cu_jump      = 1'b0;
                                    o_riscv_cu_regw      = 1'b1;
                                    o_riscv_cu_asel      = 1'b1;
                                    o_riscv_cu_bsel      = 1'b1;
                                    o_riscv_cu_memw      = 1'b0;
                                    o_riscv_cu_storesrc  = 2'b00;
                                    o_riscv_cu_resultsrc = 2'b01;
                                    o_riscv_cu_bcond     = 4'b0000;
                                    o_riscv_cu_memext    = 3'b000;
                                    o_riscv_cu_immsrc    = 3'b000;
                                    o_riscv_cu_aluctrl   = 5'b10111;
                                  end
                              end 
                       default:begin 
                                 o_riscv_cu_jump      = 1'b0;
                                 o_riscv_cu_regw      = 1'b1;
                                 o_riscv_cu_asel      = 1'b1;
                                 o_riscv_cu_bsel      = 1'b0;
                                 o_riscv_cu_memw      = 1'b0;
                                 o_riscv_cu_storesrc  = 2'b00;
                                 o_riscv_cu_resultsrc = 2'b01;
                                 o_riscv_cu_bcond     = 4'b0000;
                                 o_riscv_cu_memext    = 3'b000;
                                 o_riscv_cu_immsrc    = 3'b000;
                                 o_riscv_cu_aluctrl   = 5'b00000;  
                              end                                                   
                     endcase
                   end            
        7'b0000011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin //lb instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b000;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end                   
                       3'b001:begin //lh instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b001;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end 
                       3'b010:begin //lw instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b010;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end  
                       3'b011:begin //ld instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b011;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end                                                                                                             
                       3'b100:begin //lbu instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b100;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end                    
                       3'b101:begin //lhu instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b101;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end                   
                       3'b110:begin //lwu instruction signals
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b1;
                                o_riscv_cu_asel      = 1'b1;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;
                                o_riscv_cu_resultsrc = 2'b10;
                                o_riscv_cu_bcond     = 4'b0000;
                                o_riscv_cu_memext    = 3'b110;
                                o_riscv_cu_immsrc    = 3'b000;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end                   
                       default:begin 
                                 o_riscv_cu_jump      = 1'b0;
                                 o_riscv_cu_regw      = 1'b1;
                                 o_riscv_cu_asel      = 1'b1;
                                 o_riscv_cu_bsel      = 1'b0;
                                 o_riscv_cu_memw      = 1'b0;
                                 o_riscv_cu_storesrc  = 2'b00;
                                 o_riscv_cu_resultsrc = 2'b01;
                                 o_riscv_cu_bcond     = 4'b0000;
                                 o_riscv_cu_memext    = 3'b000;
                                 o_riscv_cu_immsrc    = 3'b000;
                                 o_riscv_cu_aluctrl   = 5'b00000;  
                               end                                   
                     endcase
                   end 
        7'b1100111:begin//jalr instruction signals
                     o_riscv_cu_jump      = 1'b1;
                     o_riscv_cu_regw      = 1'b1;
                     o_riscv_cu_asel      = 1'b1;
                     o_riscv_cu_bsel      = 1'b1;
                     o_riscv_cu_memw      = 1'b0;
                     o_riscv_cu_storesrc  = 2'b00;
                     o_riscv_cu_resultsrc = 2'b00;
                     o_riscv_cu_bcond     = 4'b0000;
                     o_riscv_cu_memext    = 3'b000;
                     o_riscv_cu_immsrc    = 3'b000;
                     o_riscv_cu_aluctrl   = 5'b01010; 
                  end
        7'b0110111:begin//lui instruction signals
                     o_riscv_cu_jump      = 1'b0;
                     o_riscv_cu_regw      = 1'b1;
                     o_riscv_cu_asel      = 1'b1;//xx
                     o_riscv_cu_bsel      = 1'b1;//xx
                     o_riscv_cu_memw      = 1'b0;
                     o_riscv_cu_storesrc  = 2'b00;//xx
                     o_riscv_cu_resultsrc = 2'b11;
                     o_riscv_cu_bcond     = 4'b0000;
                     o_riscv_cu_memext    = 3'b000;//xx
                     o_riscv_cu_immsrc    = 3'b001;
                     o_riscv_cu_aluctrl   = 5'b00000;//xx 
                  end
        7'b0010111:begin//auipc instruction signals
                     o_riscv_cu_jump      = 1'b0;
                     o_riscv_cu_regw      = 1'b1;
                     o_riscv_cu_asel      = 1'b0;
                     o_riscv_cu_bsel      = 1'b1;
                     o_riscv_cu_memw      = 1'b0;
                     o_riscv_cu_storesrc  = 2'b00;//xx
                     o_riscv_cu_resultsrc = 2'b01;
                     o_riscv_cu_bcond     = 4'b0000;
                     o_riscv_cu_memext    = 3'b000;//xx
                     o_riscv_cu_immsrc    = 3'b001;
                     o_riscv_cu_aluctrl   = 5'b00000;
                  end
        7'b1101111:begin//jal instruction signals
                     o_riscv_cu_jump      = 1'b1;
                     o_riscv_cu_regw      = 1'b1;
                     o_riscv_cu_asel      = 1'b0;
                     o_riscv_cu_bsel      = 1'b1;
                     o_riscv_cu_memw      = 1'b0;
                     o_riscv_cu_storesrc  = 2'b00;//xx
                     o_riscv_cu_resultsrc = 2'b00;
                     o_riscv_cu_bcond     = 4'b0000;
                     o_riscv_cu_memext    = 3'b000;//xx
                     o_riscv_cu_immsrc    = 3'b010;
                     o_riscv_cu_aluctrl   = 5'b00000;//xx 
                  end 

        7'b0100011:begin
				     case(i_riscv_cu_funct3[1:0])
					   2'b00:begin//sb instruction signals  		
                               o_riscv_cu_jump      = 1'b0;
                               o_riscv_cu_regw      = 1'b0;
                               o_riscv_cu_asel      = 1'b1;
                               o_riscv_cu_bsel      = 1'b1;
                               o_riscv_cu_memw      = 1'b1;
                               o_riscv_cu_storesrc  = 2'b11;
                               o_riscv_cu_resultsrc = 2'b00;//xx
                               o_riscv_cu_bcond     = 4'b0000;
                               o_riscv_cu_memext    = 3'b000;//xx
                               o_riscv_cu_immsrc    = 3'b011;
                               o_riscv_cu_aluctrl   = 5'b00000;
                             end
					   2'b01:begin//sh instruction signals  		
							   o_riscv_cu_jump      = 1'b0;
							   o_riscv_cu_regw      = 1'b0;
							   o_riscv_cu_asel      = 1'b1;
							   o_riscv_cu_bsel      = 1'b1;
							   o_riscv_cu_memw      = 1'b1;
							   o_riscv_cu_storesrc  = 2'b10;
							   o_riscv_cu_resultsrc = 2'b00;//xx
							   o_riscv_cu_bcond     = 4'b0000;
							   o_riscv_cu_memext    = 3'b000;//xx
							   o_riscv_cu_immsrc    = 3'b011;
							   o_riscv_cu_aluctrl   = 5'b00000;
					   		 end
					   2'b10:begin//sw instruction signals  		
							   o_riscv_cu_jump      = 1'b0;
							   o_riscv_cu_regw      = 1'b0;
							   o_riscv_cu_asel      = 1'b1;
							   o_riscv_cu_bsel      = 1'b1;
							   o_riscv_cu_memw      = 1'b1;
							   o_riscv_cu_storesrc  = 2'b01;
							   o_riscv_cu_resultsrc = 2'b00;//xx
							   o_riscv_cu_bcond     = 4'b0000;
							   o_riscv_cu_memext    = 3'b000;//xx
							   o_riscv_cu_immsrc    = 3'b011;
							   o_riscv_cu_aluctrl   = 5'b00000;
					   		 end							                                  										          
					   2'b11:begin//sd instruction signals  		
							   o_riscv_cu_jump      = 1'b0;
							   o_riscv_cu_regw      = 1'b0;
							   o_riscv_cu_asel      = 1'b1;
							   o_riscv_cu_bsel      = 1'b1;
							   o_riscv_cu_memw      = 1'b1;
							   o_riscv_cu_storesrc  = 2'b00;
							   o_riscv_cu_resultsrc = 2'b00;//xx
							   o_riscv_cu_bcond     = 4'b0000;
							   o_riscv_cu_memext    = 3'b000;//xx
							   o_riscv_cu_immsrc    = 3'b011;
							   o_riscv_cu_aluctrl   = 5'b00000;
					   		 end							
					 endcase
			      end
        7'b1100011:begin
				     case(i_riscv_cu_funct3)
					   3'b000:begin//beq instruction signals  	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1000;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end
					   3'b001:begin//bne instruction signals  	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1001;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end
					   3'b010:begin//blt instruction signals  	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1010;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end
					   3'b011:begin//bge instruction signals  	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1011;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end
					   3'b100:begin//bltu instruction signals  	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1110;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end
					   3'b101:begin//beq instruction signals  	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1111;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end							  
					  default:begin   // ? 	
                                o_riscv_cu_jump      = 1'b0;
                                o_riscv_cu_regw      = 1'b0;
                                o_riscv_cu_asel      = 1'b0;
                                o_riscv_cu_bsel      = 1'b1;
                                o_riscv_cu_memw      = 1'b0;
                                o_riscv_cu_storesrc  = 2'b00;//xx
                                o_riscv_cu_resultsrc = 2'b00;//xx
                                o_riscv_cu_bcond     = 4'b1000;
                                o_riscv_cu_memext    = 3'b000;//xx
                                o_riscv_cu_immsrc    = 3'b100;
                                o_riscv_cu_aluctrl   = 5'b00000;
                              end	
					 endcase
		           end
	endcase
  end
endmodule  	   	  		  		  

