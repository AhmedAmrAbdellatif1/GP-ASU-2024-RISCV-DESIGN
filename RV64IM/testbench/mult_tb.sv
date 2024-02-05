module mult_tb();
logic signed [63:0]   rs1_tb;
logic signed [63:0]   rs2_tb;
logic signed [127:0]  product_tb;
logic        [2:0]    MULControl_tb;

multiplier DUT (
    .rs1(rs1_tb),
    .rs2(rs2_tb),
    .product(product_tb),
    .MULControl(MULControl_tb)
);
initial
begin
    rs1_tb=0;
    rs2_tb='d66;
    MULControl_tb='b100;
    #20
    rs1_tb= 'sd1;
    rs2_tb= 'sd66;
    #20
    rs1_tb= -'sd25;
    rs2_tb= -'sd4;
    #20
    rs1_tb= -'sd1;
    rs2_tb= 'sd66;
    #20
    rs1_tb= -'sd40;
    rs2_tb= 'sd40;
    #20
    rs1_tb= 'sd900000000000000;
    rs2_tb= 'sd9800;

    #50
    $stop;
end
endmodule
