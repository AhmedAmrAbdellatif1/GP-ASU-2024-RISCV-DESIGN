module mult_tb();
    longint A;
    longint B;
    longint Y;
    enum  logic [2:0] {mul=3'b100,mulh=3'b101,mulhu=3'b110,mulhsu=3'b111} ctrl;

    initial
    begin
        A='sh58000001FE;
        B='shB800000000;
        ctrl=mul;
        #1
        if(Y != 'sh00016E9000000000)
            $display("[PP] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != 'sh3F40)
            $display("[PP] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sh3F40)
            $display("[PP] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != 'sh3F40)
            $display("[PP] mulhsu failed");
        #5
        //////////////////////////////////
        A='sh58000001FE;
        B='shB800000000;
        ctrl=mul;
        #1
        if(Y != 'sh1109011408239984640)
            $display("[NP] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != 'sh258211840)
            $display("[NP] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sh258211840)
            $display("[NP] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != 'sh258211840)
            $display("[NP] mulhsu failed");
        #5
        //////////////////////////////////
        A='sh58000001FE;
        B='shB800000000;
        ctrl=mul;
        #1
        if(Y != -'sh3995818769384472576)
            $display("[NN] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != -'sh930349056)
            $display("[NN] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sh3364618240)
            $display("[NN] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != -'sh930349056)
            $display("[NN] mulhsu failed");
        #5
        //////////////////////////////////
        A='sh58000001FE;
        B='shB800000000;
        ctrl=mul;
        #1
        if(Y != 'sh6670956948042547200)
            $display("[PN] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != 'sh1553203200)
            $display("[PN] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sh1553203200)
            $display("[PN] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != 'sh1553203200)
            $display("[PN] mulhsu failed");
        #5
        //////////////////////////////////
        #5
        $stop;
    end

multiplier DUT (
    .rs1(A),
    .rs2(B),
    .product(Y),
    .MULControl(ctrl)
);

endmodule
