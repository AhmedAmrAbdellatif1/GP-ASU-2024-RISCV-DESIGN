module riscv_alu(
  input  wire        [5:0]  i_riscv_alu_ctrl    ,
  input  wire signed [63:0] i_riscv_alu_rs1data ,
  input  wire signed [63:0] i_riscv_alu_rs2data ,
  output reg  signed [63:0] o_riscv_alu_result
  );
  
  logic [31:0] word_buffer;
  logic [63:0] buffer;

  localparam  ADD  = 5'b00000,
              SUB  = 5'b00001,
              SLL  = 5'b00010,
              SLT  = 5'b00011,
              SLTU = 5'b00100,
              XOR  = 5'b00101,
              SRL  = 5'b00110,
              SRA  = 5'b00111,
              OR   = 5'b01000,
              AND  = 5'b01001,
              JALR = 5'b01010,
              ADDW = 5'b10000,
              SUBW = 5'b10001,
              SLLW = 5'b10010,
              SRLW = 5'b10110,
              SRAW = 5'b10111;

always @(*)
  begin
    if(!i_riscv_alu_ctrl[5])  // if ALU is disable: Output zeroes
      o_riscv_alu_result = 'b0;

    else // if ALU is enabled
      begin // Determine the operation
          case(i_riscv_alu_ctrl[4:0])
            ADD:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data + i_riscv_alu_rs2data;
            end

            SUB:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data - i_riscv_alu_rs2data;
            end

            SLL:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data << i_riscv_alu_rs2data[5:0] ;
            end

            SLT:  begin
              o_riscv_alu_result  = (i_riscv_alu_rs1data < i_riscv_alu_rs2data)? 64'b1:64'b0;
            end

            SLTU: begin
              o_riscv_alu_result  = ($unsigned(i_riscv_alu_rs1data) < $unsigned(i_riscv_alu_rs2data))? 64'b1:64'b0; 
            end

            XOR:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data ^ i_riscv_alu_rs2data;
            end

            SRL:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data >> i_riscv_alu_rs2data[5:0] ;
            end

            SRA:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data >>> i_riscv_alu_rs2data[5:0] ;
            end

            OR:   begin
              o_riscv_alu_result  = i_riscv_alu_rs1data|i_riscv_alu_rs2data;
            end

            AND:  begin
              o_riscv_alu_result  = i_riscv_alu_rs1data&i_riscv_alu_rs2data;
            end

            JALR: begin
              buffer              = (i_riscv_alu_rs1data+i_riscv_alu_rs2data) ;
              o_riscv_alu_result  = {buffer[63:1],1'b0};
            end

            ADDW: begin
              word_buffer         = i_riscv_alu_rs1data[31:0] + i_riscv_alu_rs2data[31:0];
              o_riscv_alu_result  = { {32{word_buffer[31]} } , word_buffer};
            end

            SUBW: begin
              word_buffer         = i_riscv_alu_rs1data[31:0] - i_riscv_alu_rs2data[31:0];
              o_riscv_alu_result  = { {32{word_buffer[31]} } , word_buffer};
            end

            SLLW: begin
              word_buffer         = i_riscv_alu_rs1data[31:0] << i_riscv_alu_rs2data[4:0];
              o_riscv_alu_result  = { {32{word_buffer[31]} } , word_buffer};
            end

            SRLW: begin
              word_buffer         = i_riscv_alu_rs1data[31:0] >> i_riscv_alu_rs2data[4:0];
              o_riscv_alu_result  = { {32{word_buffer[31]} } , word_buffer};
            end

            SRAW: begin
              word_buffer         = $signed(i_riscv_alu_rs1data[31:0]) >>> i_riscv_alu_rs2data[4:0];
              o_riscv_alu_result  = { {32 {word_buffer[31]}} , word_buffer};
            end
            default:  o_riscv_alu_result=64'b0;
          endcase
      end
  end
endmodule
