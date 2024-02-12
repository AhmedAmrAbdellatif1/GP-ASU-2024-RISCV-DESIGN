module mult_tb();
    longint A;
    longint B;
    longint Y;
    enum logic [2:0] {mul=3'b100,mulh=3'b101,mulhu=3'b110,mulhsu=3'b111} ctrl;
    int i;


    initial
    begin
        /*ctrl=mul;
        for (i = 0; i < 10; i++) begin
            A = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            B = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            mul_verify();
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl=mulh;
        for (i = 0; i < 10; i++) begin
            A = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            B = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            mul_verify();
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl=mulhu;
        for (i = 0; i < 10; i++) begin
            A = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            B = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            mul_verify();
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl=mulhsu;
        for (i = 0; i < 10; i++) begin
            A = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            B = $signed($urandom_range(64'h8000000000000000, 64'h7FFFFFFFFFFFFFFF));
            mul_verify();
            #1;
        end*/
        ctrl=mulhsu;
        A = (-'sd5)<<32;
        B = (-'sd2)<<32;
        mul_verify();
        #1 $stop; 
    end

    function logic signed [63:0] result (logic signed [63:0] a, logic signed [63:0] b, logic [2:0] sel);
        logic [127:0] intrnl;
        logic [63:0] b_unsigned;
        if (sel == 3'b100) begin
            intrnl = a*b;
            result = intrnl[63:0];
        end
        else if (sel == 3'b101) begin
            intrnl = a*b;
            result = intrnl[127:64];
        end
        else if (sel == 3'b110) begin
            intrnl = $unsigned(a)*$unsigned(b);
            result = intrnl[127:64];
        end
        else if (sel == 3'b111) begin
            b_unsigned = $unsigned(b);
            intrnl = a*b_unsigned;
            result = intrnl[127:64];
        end
        else begin
            result = 0;
        end
    endfunction

    task mul_verify();
        logic signed [63:0] temp;
        begin
        temp = result(A,B,ctrl);
        #1
        if(Y != temp)
            $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl,A,B,Y,temp);
        end
    endtask

riscv_multiplier DUT  (
    .i_riscv_mul_rs1data(A),
    .i_riscv_mul_rs2data(B),
    .o_riscv_mul_product(Y),
    .i_riscv_mul_mulctrl(ctrl)
);

endmodule
