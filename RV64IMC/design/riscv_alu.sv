//`include "sign_pkg.svh"

module riscv_alu(
   input  logic        [5:0]      i_riscv_alu_ctrl,
   input  logic signed [63:0]     i_riscv_alu_rs1data,
   input  logic signed [63:0]     i_riscv_alu_rs2data,
   output logic signed [63:0]     o_riscv_alu_result
   );

logic [31:0] word_reg;
logic [63:0] result;
//logic [3:0] operation;                    
//assign operation= i_riscv_alu_ctrl[3:0];

 // import sign_pkg::*;

always_comb 
begin
  if(!i_riscv_alu_ctrl[5])
    begin
      o_riscv_alu_result = 'b0;
    end
    else
      begin
  case(i_riscv_alu_ctrl[3:0])
    
// Addition operation
4'b0000: begin
if (!i_riscv_alu_ctrl[4])               //add rs1+rs2 
  o_riscv_alu_result=i_riscv_alu_rs1data+i_riscv_alu_rs2data;
else                                   // addw rs1+rs2
  begin
  word_reg=i_riscv_alu_rs1data[31:0] +i_riscv_alu_rs2data[31:0];
  o_riscv_alu_result= { {32 {word_reg[31]}} , word_reg};
  end 
      end

//Subtraction operation
4'b0001: begin
if (!i_riscv_alu_ctrl[4])               //sub rs1+rs2 
  o_riscv_alu_result=i_riscv_alu_rs1data-i_riscv_alu_rs2data;
else                                   // subw rs1+rs2
  begin
  word_reg=i_riscv_alu_rs1data[31:0] -i_riscv_alu_rs2data[31:0];
  o_riscv_alu_result= { {32 {word_reg[31]}} , word_reg};
  end 
  end
  
//Shift left logical operation
4'b0010: begin
if (!i_riscv_alu_ctrl[4])               
  o_riscv_alu_result=i_riscv_alu_rs1data << i_riscv_alu_rs2data[5:0] ;
else                                   
  begin
  word_reg=i_riscv_alu_rs1data[31:0] << i_riscv_alu_rs2data[4:0];
  o_riscv_alu_result= { {32 {word_reg[31]}} , word_reg};
  end 
      end
      
//Set less than operation signed  (rs1<rs2)? 1:0 
4'b0011:  begin
   o_riscv_alu_result= (i_riscv_alu_rs1data < i_riscv_alu_rs2data)? 64'b1:64'b0; 
       end
 
//Set less than operation unsigned 
4'b0100:  begin
/*
  if(i_riscv_alu_rs1data[63])
   o_riscv_alu_result=(i_riscv_alu_rs1data < i_riscv_alu_rs2data)? 64'b0:64'b1;
 else
   o_riscv_alu_result=(i_riscv_alu_rs1data < i_riscv_alu_rs2data)? 64'b1:64'b0;
  */
  
  o_riscv_alu_result= ($unsigned(i_riscv_alu_rs1data) < $unsigned(i_riscv_alu_rs2data))? 64'b1:64'b0; 
       end
       
  //xor  
4'b0101: o_riscv_alu_result=i_riscv_alu_rs1data^i_riscv_alu_rs2data;

//Shift right logical operation
4'b0110: begin
if (!i_riscv_alu_ctrl[4])               
  o_riscv_alu_result=i_riscv_alu_rs1data >> i_riscv_alu_rs2data[5:0] ;
else                                   
  begin
  word_reg=i_riscv_alu_rs1data[31:0] >> i_riscv_alu_rs2data[4:0];
  o_riscv_alu_result= { {32 {word_reg[31]}} , word_reg};
  end 
      end
      
//Shift right arithmetic operation
4'b0111: begin
if (!i_riscv_alu_ctrl[4])               
  o_riscv_alu_result=i_riscv_alu_rs1data >>> i_riscv_alu_rs2data[5:0] ;
else                                   
  begin
  word_reg= $signed(i_riscv_alu_rs1data[31:0]) >>> i_riscv_alu_rs2data[4:0];
  o_riscv_alu_result= { {32 {word_reg[31]}} , word_reg};
  end 
      end

//OR 
4'b1000: o_riscv_alu_result=i_riscv_alu_rs1data|i_riscv_alu_rs2data;

//AND 
4'b1001: o_riscv_alu_result=i_riscv_alu_rs1data&i_riscv_alu_rs2data;

//JALR  rs1+imm & lsb=0 
4'b1010: begin
  result=(i_riscv_alu_rs1data+i_riscv_alu_rs2data) ;
  o_riscv_alu_result= {result[63:1],1'b0};
      end 
default:  o_riscv_alu_result=64'b0;
endcase
end

end
endmodule
