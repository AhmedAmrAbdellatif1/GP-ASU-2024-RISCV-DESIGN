module riscv_multiplier(
input  logic signed [63:0]   i_riscv_mul_rs1data,
input  logic signed [63:0]   i_riscv_mul_rs2data,
input  logic        [2:0]    i_riscv_mul_mulctrl,
output logic signed [63:0]   o_riscv_mul_product
);

logic signed [127:0]  result,result_copy;
integer i;
logic signed [127:0] rs1_copy,rs2_copy;

always @(*)
begin
    o_riscv_mul_product=0;
    result=0; 

    /////////////////////////////////////////operand 1////////////////////
    if ((i_riscv_mul_mulctrl==3'b100 ||i_riscv_mul_mulctrl==3'b101 )&& i_riscv_mul_rs1data[63])
    begin
        rs1_copy=~i_riscv_mul_rs1data+1;
    end
    else if (i_riscv_mul_mulctrl==3'b111 && i_riscv_mul_rs1data[63]) begin
        rs1_copy=~i_riscv_mul_rs1data+1;
    end
    else if (i_riscv_mul_mulctrl==3'b110 && i_riscv_mul_rs1data[63])
    rs1_copy=$unsigned(i_riscv_mul_rs1data);
    else
    begin
        rs1_copy=i_riscv_mul_rs1data;
    end

//////////////////////////////////////////operand 2//////////////////////////////////////

 if ((i_riscv_mul_mulctrl==3'b100 ||i_riscv_mul_mulctrl==3'b101 )&& i_riscv_mul_rs2data[63])
    begin  
        rs2_copy=~i_riscv_mul_rs2data+1;
    end
    else if ((i_riscv_mul_mulctrl==3'b110||i_riscv_mul_mulctrl==3'b111) && i_riscv_mul_rs2data[63])
    rs2_copy=$unsigned(i_riscv_mul_rs2data);
else 
 rs2_copy=i_riscv_mul_rs2data;

//////////////////////////////////////////////////////////algorithm//////////////////////////
   for (i=0; i<64; i=i+1)
    begin
        if(rs2_copy[i]==1'b1)
        result=result+ (rs1_copy<<i);
        else
          begin
            result=result+128'b0;
          end
    end
result_copy=~result+1;

///////////////////////////////////////controls////////////////////////////////////
case (i_riscv_mul_mulctrl)
3'b100: begin if(i_riscv_mul_rs2data[63] == i_riscv_mul_rs1data[63])
          o_riscv_mul_product=result[63:0];
         else 
         o_riscv_mul_product=result_copy[63:0];
        end 

3'b101: begin if(i_riscv_mul_rs2data[63] == i_riscv_mul_rs1data[63])
          o_riscv_mul_product=result[127:64];
         else 
          o_riscv_mul_product=result_copy[127:64];
        end 

3'b110: o_riscv_mul_product=result[127:64];

3'b111: begin if(i_riscv_mul_rs1data[63] )
          o_riscv_mul_product=result_copy[127:64];
         else 
          o_riscv_mul_product=result[127:64];
        end 
        
default: o_riscv_mul_product=0;

endcase
end








endmodule