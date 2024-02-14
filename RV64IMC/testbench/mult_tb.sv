`include "pkg.svh"

module mult_tb();
    longint A;
    longint B;
    longint Y;
    enum logic [2:0] {off=3'b0xx,mul=3'b100,mulh=3'b101,mulhu=3'b110,mulhsu=3'b111} ctrl_mul;
    import ranges::*;

    initial
    begin
        ctrl_mul=mul;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            mul_verify();
            counter++;
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl_mul=mulh;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            mul_verify();
            counter++;
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl_mul=mulhu;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            mul_verify();
            counter++;
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl_mul=mulhsu;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            mul_verify();
            counter++;
            #1;
        end
        /////////////////////////////////////////////////////////////////////////////
        ctrl_mul=off;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            mul_verify();
            counter++;
            #1;
        end
        #5
        if(!failed.triggered) $display("RAN %4d TESTS WITH NO ERRORS!", counter); 
    end

riscv_multiplier DUT  (
    .i_riscv_mul_rs1data(A),
    .i_riscv_mul_rs2data(B),
    .o_riscv_mul_product(Y),
    .i_riscv_mul_mulctrl(ctrl_mul)
);
  `include "mulMethods.sv"
endmodule
