module multiplier(
input  logic signed [63:0]   rs1,
input  logic signed [63:0]   rs2,
input  logic        [2:0]    MULControl,
output logic signed [127:0]  product
);

logic signed [127:0]  result;

integer i;
always @(*)
begin
    product=0;
    result=0; 
    case (MULControl)

    3'b100:begin                               //mul
    for (i=0; i<64; i=i+1)
    begin
        if(rs2[i]==1'b1)
        result=result+ (rs1<<i);
        else
            result=result+128'b0;
    end
    product=result[63:0];
    end
    

    endcase

end 
endmodule 