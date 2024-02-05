module mult_tb();

    typedef enum logic [2:0] {mul=3'b100,mulh=3'b101,mulhu=3'b110,mulhsu=3'b111} TEST ;

    logic signed [63:0]   A;
    logic signed [63:0]   B;
    logic signed [63:0]   Y;
    TEST                  ctrl;

    initial
    begin
        A='sd2199023257131;
        B='sd3377699720527872;
        ctrl=mul;
        #1
        if(Y != 'sd5333387858713509888)
            $display("[PP] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != 'sd1241776128)
            $display("[PP] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sd1241776128)
            $display("[PP] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != 'sd1241776128)
            $display("[PP] mulhsu failed");
        #5
        //////////////////////////////////
        A=-'sd17592186042837;
        B='sd12384898975268864;
        ctrl=mul;
        #1
        if(Y != 'sd1109011408239984640)
            $display("[NP] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != 'sd258211840)
            $display("[NP] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sd258211840)
            $display("[NP] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != 'sd258211840)
            $display("[NP] mulhsu failed");
        #5
        //////////////////////////////////
        A=-'sd21990232553941;
        B=-'sd25895697857380352;
        ctrl=mul;
        #1
        if(Y != -'sd3995818769384472576)
            $display("[NN] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != -'sd930349056)
            $display("[NN] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sd3364618240)
            $display("[NN] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != -'sd930349056)
            $display("[NN] mulhsu failed");
        #5
        //////////////////////////////////
        A='sd35184372090411;
        B=-'sd19140298416324608;
        ctrl=mul;
        #1
        if(Y != 'sd6670956948042547200)
            $display("[PN] mul failed");
        #1
        ctrl=mulh;
        #1
        if(Y != 'sd1553203200)
            $display("[PN] mulh failed");
        #1
        ctrl=mulhu;
        #1
        if(Y != 'sd1553203200)
            $display("[PN] mulhu failed");
        #1
        ctrl=mulhsu;
        #1
        if(Y != 'sd1553203200)
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
