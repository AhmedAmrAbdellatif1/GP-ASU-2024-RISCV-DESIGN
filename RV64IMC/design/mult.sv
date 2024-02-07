module riscv_multiplier(
input  logic signed [63:0]   i_riscv_mul_rs1data,
input  logic signed [63:0]   i_riscv_mul_rs2data,
input  logic        [2:0]    i_riscv_mul_mulctrl,
output logic signed [63:0]   o_riscv_mul_product
);

logic signed [127:0]  result;
integer i;


always @(*)
begin
    o_riscv_mul_product=0;
    result=0; 
    case (i_riscv_mul_mulctrl)

    3'b100:begin                               //mul
    for (i=0; i<64; i=i+1)
    begin
        if(i_riscv_mul_rs2data[i]==1'b1)
        result=result+ (i_riscv_mul_rs1data<<i);
        else
            result=result+128'b0;
    end
    o_riscv_mul_product=result[63:0];
    end

     3'b101:begin                               //mulh
    for (i=0; i<64; i=i+1)
    begin
        if(i_riscv_mul_rs2data[i]==1'b1)
        result=result+ (i_riscv_mul_rs1data<<i);
        else
            result=result+128'b0;
    end
    o_riscv_mul_product=result[127:64];
    end

     3'b110:begin                               //mulhu
    for (i=0; i<64; i=i+1)
    begin
        if(($unsigned(i_riscv_mul_rs2data[i]))==1'b1)
        result=result+ (($unsigned(i_riscv_mul_rs1data))<<i);
        else
            result=result+128'b0;
    end
    o_riscv_mul_product=result[127:64];

    end

 3'b111:begin                               //mulhsu
    for (i=0; i<64; i=i+1)
    begin
        if(($unsigned(i_riscv_mul_rs2data[i]))==1'b1)
        result=result+ (i_riscv_mul_rs1data<<i);
        else
            result=result+128'b0;
    end
    o_riscv_mul_product=result[127:64];
 end

 default:  begin     
    result=0;
    o_riscv_mul_product=64'b0;
    end
    endcase

end 
endmodule 