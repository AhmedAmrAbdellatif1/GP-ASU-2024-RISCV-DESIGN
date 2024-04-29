module riscv_dcache_amo (
    input   wire                 i_riscv_amo_enable   ,
    input   wire                 i_riscv_amo_xlen     , // 1: doubleword -- 0: word 
    input   wire         [4:0]   i_riscv_amo_ctrl     ,
    input   wire signed  [63:0]  i_riscv_amo_rs1data  , // loaded value from mem[rs1]
    input   wire signed  [63:0]  i_riscv_amo_rs2data  ,
    output  reg signed  [63:0]  o_riscv_amo_result
   );

  //****************** internal signals declaration ******************//
  reg [31:0] amo_word_buffer;

  //****************** enum declaration ******************//
  localparam  AMOSWAP = 5'b00001,
              AMOADD  = 5'b00000,
              AMOXOR  = 5'b00100,
              AMOAND  = 5'b01100,
              AMOOR   = 5'b01000,
              AMOMIN  = 5'b10000,
              AMOMAX  = 5'b10100,
              AMOMINU = 5'b11000,
              AMOMAXU = 5'b11100;


  //****************** Procedural Blocks ******************//
  always @(*) 
    begin
    if(i_riscv_amo_enable)
      begin 
        case(i_riscv_amo_ctrl)
        
          AMOSWAP: begin
            if(i_riscv_amo_xlen)
            begin
              amo_word_buffer     = 'b0;
              o_riscv_amo_result  = i_riscv_amo_rs2data;
            end
            else  
            begin
              amo_word_buffer     = i_riscv_amo_rs2data[31:0];
              o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
            end 
          end
            
          AMOADD: begin
            if (i_riscv_amo_xlen)
            begin
              amo_word_buffer     = 'b0;
              o_riscv_amo_result  = i_riscv_amo_rs1data + i_riscv_amo_rs2data;
            end
            else 
            begin
              amo_word_buffer     = i_riscv_amo_rs1data[31:0] + i_riscv_amo_rs2data[31:0];
              o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
            end 
          end

          AMOXOR: begin
            if (i_riscv_amo_xlen)
            begin
              amo_word_buffer     = 'b0;
              o_riscv_amo_result  = i_riscv_amo_rs1data ^ i_riscv_amo_rs2data;
            end
            else 
            begin
              amo_word_buffer     = i_riscv_amo_rs1data[31:0] ^ i_riscv_amo_rs2data[31:0];
              o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
            end 
          end

          AMOAND: begin
            if (i_riscv_amo_xlen)
            begin
              amo_word_buffer     = 'b0;
              o_riscv_amo_result  = i_riscv_amo_rs1data & i_riscv_amo_rs2data;
            end
            else
            begin
              amo_word_buffer     = i_riscv_amo_rs1data[31:0] & i_riscv_amo_rs2data[31:0];
              o_riscv_amo_result  = { {32 {amo_word_buffer[31]}} , amo_word_buffer};
            end 
          end

          AMOOR: begin
            if (i_riscv_amo_xlen)
            begin
              amo_word_buffer     = 'b0;
              o_riscv_amo_result  = i_riscv_amo_rs1data | i_riscv_amo_rs2data;
            end
            else                                   
            begin
              amo_word_buffer     = i_riscv_amo_rs1data[31:0] | i_riscv_amo_rs2data[31:0];
              o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
            end 
          end

          AMOMIN: begin
            if (i_riscv_amo_xlen)
            begin
              amo_word_buffer = 'b0;
              if (i_riscv_amo_rs1data < i_riscv_amo_rs2data)
                o_riscv_amo_result  = i_riscv_amo_rs1data;
              else 
                o_riscv_amo_result  = i_riscv_amo_rs2data;
            end
            else                                
            begin
              if (i_riscv_amo_rs1data[31:0] < i_riscv_amo_rs2data[31:0])
              begin
                amo_word_buffer     = i_riscv_amo_rs1data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
              end
              else
              begin
                amo_word_buffer     = i_riscv_amo_rs2data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer}; 
              end
            end 
          end

          AMOMAX: begin
            if (i_riscv_amo_xlen)             
            begin
              amo_word_buffer = 'b0;
              if (i_riscv_amo_rs1data > i_riscv_amo_rs2data)
                o_riscv_amo_result  = i_riscv_amo_rs1data;
              else 
                o_riscv_amo_result  = i_riscv_amo_rs2data;
            end
            else                                  
            begin
              if (i_riscv_amo_rs1data[31:0] > i_riscv_amo_rs2data[31:0])
              begin
                amo_word_buffer     = i_riscv_amo_rs1data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
              end
              else
              begin
                amo_word_buffer     = i_riscv_amo_rs2data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer}; 
              end
            end 
          end

          AMOMINU: begin
            if (i_riscv_amo_xlen)               
            begin
              amo_word_buffer = 'b0;
              if ($unsigned(i_riscv_amo_rs1data) < $unsigned(i_riscv_amo_rs2data))
                o_riscv_amo_result  = i_riscv_amo_rs1data;
              else 
                o_riscv_amo_result  = i_riscv_amo_rs2data;
            end
            else                                   
            begin
              if ($unsigned(i_riscv_amo_rs1data[31:0]) < $unsigned(i_riscv_amo_rs2data[31:0]))
              begin
                amo_word_buffer     = i_riscv_amo_rs1data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
              end
              else
              begin
                amo_word_buffer     = i_riscv_amo_rs2data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer}; 
              end 
            end
          end 

          AMOMAXU: begin
            if (i_riscv_amo_xlen)             
            begin
              amo_word_buffer = 'b0;
              if ($unsigned(i_riscv_amo_rs1data) > $unsigned(i_riscv_amo_rs2data))
                o_riscv_amo_result  = i_riscv_amo_rs1data;
              else 
                o_riscv_amo_result  = i_riscv_amo_rs2data;
            end
            else                                  
            begin
              if ($unsigned(i_riscv_amo_rs1data[31:0]) > $unsigned(i_riscv_amo_rs2data[31:0]))
              begin
                amo_word_buffer     = i_riscv_amo_rs1data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer};
              end
              else
              begin
                amo_word_buffer     = i_riscv_amo_rs2data[31:0];
                o_riscv_amo_result  = { {32 {amo_word_buffer[31]} } , amo_word_buffer}; 
              end 
            end
          end

          default : o_riscv_amo_result = 64'b0;

        endcase
      end
      else
        o_riscv_amo_result = 64'b0;
    end
endmodule 