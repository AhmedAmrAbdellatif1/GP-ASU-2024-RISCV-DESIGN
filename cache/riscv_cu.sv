module riscv_cu (
  input  logic [6:0]  i_riscv_cu_opcode, //7-bit input opcode[6:0]
  input  logic [2:0]  i_riscv_cu_funct3, //3-bit input func_3[14:12]  
  input  logic        i_riscv_cu_funct7_5,//1-bit input func_7[30]
  input  logic        i_riscv_cu_funct7_0,//1-bit input func_7[25]
  output logic        o_riscv_cu_jump, 
  output logic        o_riscv_cu_regw,
  output logic        o_riscv_cu_asel,
  output logic        o_riscv_cu_bsel,
  output logic        o_riscv_cu_memw,    
  output logic        o_riscv_cu_memr,    
  output logic [1:0]  o_riscv_cu_storesrc,
  output logic [1:0]  o_riscv_cu_resultsrc,
  output logic [1:0]  o_riscv_cu_funcsel,
  output logic [3:0]  o_riscv_cu_bcond,//msb for branch enable
  output logic [2:0]  o_riscv_cu_memext,
  output logic [2:0]  o_riscv_cu_immsrc,
  output logic [3:0]  o_riscv_cu_mulctrl,
  output logic [3:0]  o_riscv_cu_divctrl, 
  output logic [5:0]  o_riscv_cu_aluctrl
);

always_comb
  begin:ctrl_sig_proc
    case(i_riscv_cu_opcode)
        7'b0110011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin
                                if(!i_riscv_cu_funct7_5 && !i_riscv_cu_funct7_0)
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
                                    o_riscv_cu_aluctrl   = 6'b100000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
                                  end
                                else if (i_riscv_cu_funct7_0) // mul 
                                  begin
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
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
                                else  
                                  begin //sub instruction signals
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
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
                              end
                       3'b001:begin
                       if (!i_riscv_cu_funct7_0)// sll instruction signals
                         begin
                                o_riscv_cu_jump       = 1'b0;
                                o_riscv_cu_regw       = 1'b1;
                                o_riscv_cu_asel       = 1'b1;
                                o_riscv_cu_bsel       = 1'b0;
                                o_riscv_cu_memw       = 1'b0;
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
                            else
                              begin // mulh
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
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
                            end
                       3'b010:begin
                       if(!i_riscv_cu_funct7_0) // slt instruction signals
                         begin
                                o_riscv_cu_jump       = 1'b0;
                                o_riscv_cu_regw       = 1'b1;
                                o_riscv_cu_asel       = 1'b1;
                                o_riscv_cu_bsel       = 1'b0;
                                o_riscv_cu_memw       = 1'b0;
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
                          else begin //mulhsu
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
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
                       3'b011:begin // sltu instruction signals
                         if(!i_riscv_cu_funct7_0)
                           begin
                                o_riscv_cu_jump       = 1'b0;
                                o_riscv_cu_regw       = 1'b1;
                                o_riscv_cu_asel       = 1'b1;
                                o_riscv_cu_bsel       = 1'b0;
                                o_riscv_cu_memw       = 1'b0;
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
                            else // mulhu
                              begin
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
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
                              end
                       3'b100:begin // xor instruction signals
                         if(!i_riscv_cu_funct7_0)
                            begin
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
                                o_riscv_cu_aluctrl   = 6'b100101;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b000;
                                o_riscv_cu_funcsel   = 2'b10;
                              end
                            else //div
                              begin
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1100;
                                    o_riscv_cu_funcsel   = 2'b01;           
                                  end
                                end
                                
                       3'b101:begin
                                if(!i_riscv_cu_funct7_5 && !i_riscv_cu_funct7_0)
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
                                    o_riscv_cu_aluctrl   = 6'b100110;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
                                  end
                                else if(i_riscv_cu_funct7_0) //divu
                                  begin
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1101;
                                    o_riscv_cu_funcsel   = 2'b01;    
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
                                    o_riscv_cu_aluctrl   = 6'b100111;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                  end
                              end    
                       3'b110:begin // or instruction signals
                         if (!i_riscv_cu_funct7_0)
                           begin
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
                                o_riscv_cu_aluctrl   = 6'b101000;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
                              end 
                            else   //rem
                              begin
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1110;
                                    o_riscv_cu_funcsel   = 2'b01;   
                              end
                            end
                       3'b111:begin // and instruction signals
                         if(!i_riscv_cu_funct7_0)
                           begin
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
                                o_riscv_cu_aluctrl   = 6'b101001;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                 o_riscv_cu_divctrl  = 4'b0000;
                                 o_riscv_cu_funcsel  = 2'b10;
                              end
                            else //remu
                              begin
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1111;
                                    o_riscv_cu_funcsel   = 2'b01;   
                               end
                            end
                     endcase            
                   end      
        7'b0111011:begin
                     case(i_riscv_cu_funct3) 
                       3'b000:begin
                                if(!i_riscv_cu_funct7_5 && !i_riscv_cu_funct7_0)
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
                                    o_riscv_cu_aluctrl   = 6'b110000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                   o_riscv_cu_divctrl    = 4'b0000;
                                   o_riscv_cu_funcsel    = 2'b10;
                                  end
                                  else if (i_riscv_cu_funct7_0) // mulw
                                  begin
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
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
                                    o_riscv_cu_aluctrl   = 6'b110001;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                   o_riscv_cu_divctrl    = 4'b0000;
                                   o_riscv_cu_funcsel    = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b110010;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
                              end     

                       3'b100:begin //divw
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1000;
                                    o_riscv_cu_funcsel   = 2'b01;
                              end                                
                       3'b101:begin
                                if(!i_riscv_cu_funct7_5 && !i_riscv_cu_funct7_0)
                                  begin //srlw instruction signals
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
                                    o_riscv_cu_storesrc   = 2'b00;
                                    o_riscv_cu_resultsrc  = 2'b01;
                                    o_riscv_cu_bcond      = 4'b0000;
                                    o_riscv_cu_memext     = 3'b000;
                                    o_riscv_cu_immsrc     = 3'b000;
                                    o_riscv_cu_aluctrl    = 6'b110110;
                                    o_riscv_cu_mulctrl    = 4'b000;
                                   o_riscv_cu_divctrl     = 4'b0000;
                                   o_riscv_cu_funcsel     = 2'b10;
                                  end
                                  else if (i_riscv_cu_funct7_0) //divuw
                                  begin
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1001;
                                    o_riscv_cu_funcsel   = 2'b01;
                                  end
                                else  
                                  begin //sraw instruction signals
                                    o_riscv_cu_jump       = 1'b0;
                                    o_riscv_cu_regw       = 1'b1;
                                    o_riscv_cu_asel       = 1'b1;
                                    o_riscv_cu_bsel       = 1'b0;
                                    o_riscv_cu_memw       = 1'b0;
                                    o_riscv_cu_storesrc   = 2'b00;
                                    o_riscv_cu_resultsrc  = 2'b01;
                                    o_riscv_cu_bcond      = 4'b0000;
                                    o_riscv_cu_memext     = 3'b000;
                                    o_riscv_cu_immsrc     = 3'b000;
                                    o_riscv_cu_aluctrl    = 6'b110111;
                                    o_riscv_cu_mulctrl    = 4'b000;
                                   o_riscv_cu_divctrl     = 4'b0000;
                                   o_riscv_cu_funcsel     = 2'b10;
                                  end
                               end 
                       3'b110: begin //remw
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1010;
                                    o_riscv_cu_funcsel   = 2'b01;      
                               end 
                        3'b111: begin //remuw
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
                                    o_riscv_cu_aluctrl   = 6'b000000;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b1011;
                                    o_riscv_cu_funcsel   = 2'b01;        
                               end        
                       default:begin 
                                 o_riscv_cu_jump        = 1'b0;
                                 o_riscv_cu_regw        = 1'b1;
                                 o_riscv_cu_asel        = 1'b1;
                                 o_riscv_cu_bsel        = 1'b0;
                                 o_riscv_cu_memw        = 1'b0;
                                 o_riscv_cu_storesrc    = 2'b00;
                                 o_riscv_cu_resultsrc   = 2'b01;
                                 o_riscv_cu_bcond       = 4'b0000;
                                 o_riscv_cu_memext      = 3'b000;
                                 o_riscv_cu_immsrc      = 3'b000;
                                 o_riscv_cu_aluctrl     = 6'b100000;  
                                    o_riscv_cu_mulctrl  = 4'b000;
                                   o_riscv_cu_divctrl   = 4'b000;
                                   o_riscv_cu_funcsel   = 2'b10;
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
                               o_riscv_cu_aluctrl   = 6'b100000;   
                               o_riscv_cu_mulctrl   = 4'b0000;
                               o_riscv_cu_divctrl   = 4'b0000;
                               o_riscv_cu_funcsel   = 2'b10;                        
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
                                o_riscv_cu_aluctrl   = 6'b100010;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                 o_riscv_cu_divctrl  = 4'b0000;
                                 o_riscv_cu_funcsel  = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b100011;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b100100;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b100101;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                    o_riscv_cu_aluctrl   = 6'b100110;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
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
                                    o_riscv_cu_aluctrl   = 6'b100111;  
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b101000;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b101001;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b110000;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                o_riscv_cu_aluctrl   = 6'b110010;
                                o_riscv_cu_mulctrl   = 4'b0000;
                                o_riscv_cu_divctrl   = 4'b0000;
                                o_riscv_cu_funcsel   = 2'b10;
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
                                    o_riscv_cu_aluctrl   = 6'b110110;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
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
                                    o_riscv_cu_aluctrl   = 6'b110111;
                                    o_riscv_cu_mulctrl   = 4'b0000;
                                    o_riscv_cu_divctrl   = 4'b0000;
                                    o_riscv_cu_funcsel   = 2'b10;
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
                                 o_riscv_cu_aluctrl   = 6'b100000;  
                                 o_riscv_cu_mulctrl   = 4'b0000;
                                 o_riscv_cu_divctrl   = 4'b0000;
                                 o_riscv_cu_funcsel   = 2'b10;
                              end                                                   
                     endcase
                   end            
        7'b0000011:begin//all load instructions instruction signals
                     o_riscv_cu_jump      = 1'b0;
                     o_riscv_cu_regw      = 1'b1;
                     o_riscv_cu_asel      = 1'b1;
                     o_riscv_cu_bsel      = 1'b1;
                     o_riscv_cu_memw      = 1'b0;
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
                     o_riscv_cu_aluctrl   = 6'b101010;
                     o_riscv_cu_mulctrl   = 4'b0000;
                     o_riscv_cu_divctrl   = 4'b0000;
                     o_riscv_cu_funcsel   = 2'b10;
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
                     o_riscv_cu_aluctrl   = 6'b000000;//xx 
                     o_riscv_cu_mulctrl   = 4'b0000;
                     o_riscv_cu_divctrl   = 4'b0000;
                     o_riscv_cu_funcsel   = 2'b10;
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
                     o_riscv_cu_aluctrl   = 6'b100000;
                     o_riscv_cu_mulctrl   = 4'b0000;
                     o_riscv_cu_divctrl   = 4'b0000;
                     o_riscv_cu_funcsel   = 2'b10;
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
                     o_riscv_cu_aluctrl   = 6'b100000;//xx 
                     o_riscv_cu_mulctrl   = 4'b0000;
                     o_riscv_cu_divctrl   = 4'b0000;
                     o_riscv_cu_funcsel   = 2'b10;
                  end 

        7'b0100011:begin//all store instruction signals  		
                     o_riscv_cu_jump      = 1'b0;
                     o_riscv_cu_regw      = 1'b0;
                     o_riscv_cu_asel      = 1'b1;
                     o_riscv_cu_bsel      = 1'b1;
                     o_riscv_cu_memw      = 1'b1;
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
        7'b1100011:begin//all branch instruction signals  	
                     o_riscv_cu_jump       = 1'b0;
                     o_riscv_cu_regw       = 1'b0;
                     o_riscv_cu_asel       = 1'b0;
                     o_riscv_cu_bsel       = 1'b1;
                     o_riscv_cu_memw       = 1'b0;
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
        default:begin 	
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
                end
                   
	  endcase
  end
endmodule  	   	  		  		  