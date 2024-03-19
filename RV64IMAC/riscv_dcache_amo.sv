module riscv_amo_unit (
   input  logic        [5:0]      i_riscv_amo_ctrl,        //amo_ctrl = {funt3[0],funct5} = {instr[12],instr[31:27]}
   input  logic signed [63:0]     i_riscv_amo_rs1data,     //loaded value from mem[rs1]
   input  logic signed [63:0]     i_riscv_amo_rs2data,
   input  logic                   i_riscv_amo_enable,
   output logic signed [63:0]     o_riscv_amo_result
   );

logic [31:0] word_reg;

always_comb 
begin
 if(i_riscv_amo_enable)
  begin 

  case(i_riscv_amo_ctrl[4:0])

   // SWAP operation
   5'b00001: begin
    if (!i_riscv_amo_ctrl[5])               //swap.d 
     o_riscv_amo_result= i_riscv_amo_rs2data;
    else                                    //swap.w
    begin
     word_reg= i_riscv_amo_rs2data[31:0];
     o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg};
    end 
   end
    
   // ADD operation
   5'b00000: begin
    if (!i_riscv_amo_ctrl[5])               //add.d 
     o_riscv_amo_result=i_riscv_amo_rs1data + i_riscv_amo_rs2data;
    else                                    //add.w
    begin
     word_reg=i_riscv_amo_rs1data[31:0] + i_riscv_amo_rs2data[31:0];
     o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg};
    end 
   end

   //XOR operation
   5'b00100: begin
    if (!i_riscv_amo_ctrl[5])               //sub.d  
     o_riscv_amo_result=i_riscv_amo_rs1data ^ i_riscv_amo_rs2data;
    else                                    //sub.w 
    begin
     word_reg=i_riscv_amo_rs1data[31:0] ^ i_riscv_amo_rs2data[31:0];
     o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg};
    end 
   end

   //AND operation
   5'b01100: begin
    if (!i_riscv_amo_ctrl[5])               //and.d 
     o_riscv_amo_result=i_riscv_amo_rs1data & i_riscv_amo_rs2data;
    else                                    //and.w
    begin
     word_reg=i_riscv_amo_rs1data[31:0] & i_riscv_amo_rs2data[31:0];
     o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg};
    end 
   end

   //OR operation
   5'b01000: begin
    if (!i_riscv_amo_ctrl[5])               //or.d
     o_riscv_amo_result=i_riscv_amo_rs1data | i_riscv_amo_rs2data;
    else                                    //or.w
    begin
     word_reg=i_riscv_amo_rs1data[31:0] | i_riscv_amo_rs2data[31:0];
     o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg};
    end 
   end

   //MIN operation
   5'b10000: begin
    if (!i_riscv_amo_ctrl[5])               //amomin.d 
    begin 
     if (i_riscv_amo_rs1data < i_riscv_amo_rs2data)
      o_riscv_amo_result= i_riscv_amo_rs1data;
     else 
      o_riscv_amo_result= i_riscv_amo_rs2data;
    end
    else                                    //amomin.w
    begin
     if (i_riscv_amo_rs1data[31:0] < i_riscv_amo_rs2data[31:0])
     begin
      word_reg = i_riscv_amo_rs1data[31:0];
      o_riscv_amo_result = { {32 {word_reg[31]}} , word_reg};
     end
     else
     begin
      word_reg = i_riscv_amo_rs2data[31:0];
      o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg}; 
     end
   end 
  end

   //MAX operation
   5'b10100: begin
    if (!i_riscv_amo_ctrl[5])               //amomax.d 
    begin
     if (i_riscv_amo_rs1data > i_riscv_amo_rs2data)
      o_riscv_amo_result= i_riscv_amo_rs1data;
     else 
      o_riscv_amo_result= i_riscv_amo_rs2data;
    end
    else                                    //amomax.w
    begin
     if (i_riscv_amo_rs1data[31:0] > i_riscv_amo_rs2data[31:0])
     begin
      word_reg = i_riscv_amo_rs1data[31:0];
      o_riscv_amo_result = { {32 {word_reg[31]}} , word_reg};
     end
     else
     begin
      word_reg = i_riscv_amo_rs2data[31:0];
      o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg}; 
     end
    end 
  end

   //MINU operation
   5'b11000: begin
    if (!i_riscv_amo_ctrl[5])               //amominu.d 
    begin
     if ($unsigned(i_riscv_amo_rs1data) < $unsigned(i_riscv_amo_rs2data))
      o_riscv_amo_result= i_riscv_amo_rs1data;
     else 
      o_riscv_amo_result= i_riscv_amo_rs2data;
    end
    else                                    //amominu.w
    begin
     if ($unsigned(i_riscv_amo_rs1data[31:0]) < $unsigned(i_riscv_amo_rs2data[31:0]))
     begin
      word_reg = i_riscv_amo_rs1data[31:0];
      o_riscv_amo_result = { {32 {word_reg[31]}} , word_reg};
     end
     else
     begin
      word_reg = i_riscv_amo_rs2data[31:0];
      o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg}; 
     end 
   end
  end 

   //MAXU operation
   5'b11100: begin
    if (!i_riscv_amo_ctrl[5])               //amomaxu.d 
    begin
     if ($unsigned(i_riscv_amo_rs1data) > $unsigned(i_riscv_amo_rs2data))
      o_riscv_amo_result= i_riscv_amo_rs1data;
     else 
      o_riscv_amo_result= i_riscv_amo_rs2data;
    end
    else                                    //amomaxu.w
    begin
     if ($unsigned(i_riscv_amo_rs1data[31:0]) > $unsigned(i_riscv_amo_rs2data[31:0]))
     begin
      word_reg = i_riscv_amo_rs1data[31:0];
      o_riscv_amo_result = { {32 {word_reg[31]}} , word_reg};
     end
     else
     begin
      word_reg = i_riscv_amo_rs2data[31:0];
      o_riscv_amo_result= { {32 {word_reg[31]}} , word_reg}; 
     end 
    end
   end 
   endcase
   else 
    o_riscv_amo_result = 64'b0;
   end 
  end

  endmodule 