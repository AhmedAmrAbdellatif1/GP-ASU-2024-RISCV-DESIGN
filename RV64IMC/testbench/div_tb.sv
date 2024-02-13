`include "pkg.svh"

module div_tb(); 
    longint A;
    longint B;
    longint Y;
    enum logic [2:0] {off=3'b0xx,div=3'b100,divu=3'b101,rem=3'b110,remu=3'b111} ctrl_div;

    import ranges::*;
  
    initial
    begin
        ctrl_div=div;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            if( (A==INT64_MIN)&&(B==-'sd1))
              continue;
            if( (B=='sd0) )
              continue; 
            div_verify();
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl_div=divu;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            if( (A==INT64_MIN)&&(B==-'sd1))
              continue;
            if( (B=='sd0) )
              continue; 
            div_verify();
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl_div=rem;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            if( (A==INT64_MIN)&&(B==-'sd1))
              continue;
            if( (B=='sd0) )
              continue; 
            div_verify();
            #1;
        end
        #5;
        /////////////////////////////////////////////////////////////////////////////
        ctrl_div=remu;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            if( (A==INT64_MIN)&&(B==-'sd1))
              continue;
            if( (B=='sd0) )
              continue; 
            div_verify();
            #1;
        end
        /////////////////////////////////////////////////////////////////////////////
        ctrl_div=off;
        for (i = 1; i < NO_TESTS+1; i++) begin
            A = $signed($urandom_range(INT64_MIN, INT64_MAX));
            B = $signed($urandom_range(INT64_MIN, INT64_MAX));
            if( (A==INT64_MIN)&&(B==-'sd1))
              continue;
            if( (B=='sd0) )
              continue; 
            div_verify();
            #1;
        end
        /////////////////////////////////////////////////////////////////////////////
        div_by_zero();
        /////////////////////////////////////////////////////////////////////////////
        overflow();
        /////////////////////////////////////////////////////////////////////////////
        #1 $stop;
    end
riscv_divider DUT  (
    .i_riscv_div_rs1data(A),
    .i_riscv_div_rs2data(B),
    .o_riscv_div_result(Y),
    .i_riscv_div_divctrl(ctrl_div)
);
  `include "divMethods.sv"
endmodule
