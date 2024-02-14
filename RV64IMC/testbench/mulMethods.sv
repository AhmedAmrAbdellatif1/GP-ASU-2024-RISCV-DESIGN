////////////////////////////////////////////////////////////////////////////////////////////////////////////
function logic signed [63:0] mul_result (logic signed [63:0] a, logic signed [63:0] b, logic [2:0] sel);
    logic [127:0] intrnl;
    if (sel == 3'b100) begin
        intrnl = a*b;
        mul_result = intrnl[63:0];
    end
    else if (sel == 3'b101) begin
        intrnl = a*b;
        mul_result = intrnl[127:64];
    end
    else if (sel == 3'b110) begin
        intrnl = $unsigned(a)*$unsigned(b);
        mul_result = intrnl[127:64];
    end
    else if (sel == 3'b111) begin
        intrnl = {{64{a[63]}},a}*{{64{1'b0}},b};
        mul_result = intrnl[127:64];
    end
    else begin
        mul_result = 0;
    end
endfunction

task mul_verify();
    logic signed [63:0] temp;
    begin
    temp = mul_result(A,B,ctrl_mul);
    #1
    if(Y != temp) begin
        $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl_mul,A,B,Y,temp);
        ->failed;
    end
    end
endtask