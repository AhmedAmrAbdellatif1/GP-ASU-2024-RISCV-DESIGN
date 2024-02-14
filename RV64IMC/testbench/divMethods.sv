////////////////////////////////////////////////////////////////////////////////////////////////////////////
function logic signed [63:0] div_result (logic signed [63:0] a, logic signed [63:0] b, logic [2:0] sel);
    if (sel == 3'b100) begin
        div_result = a/b;
    end
    else if (sel == 3'b101) begin
        div_result = $unsigned(a) / $unsigned(b);
    end
    else if (sel == 3'b110) begin
        div_result = a%b;
    end
    else if (sel == 3'b111) begin
        div_result = $unsigned(a) % $unsigned(b);
    end
    else begin
        div_result = 0;
    end
endfunction

task div_verify();
    logic signed [63:0] temp;
    begin
    temp = div_result(A,B,ctrl_div);
    #1
    if(Y != temp)
        $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl_div,A,B,Y,temp);
    end
endtask

task div_by_zero();
  B = 'sd0;
  ctrl_div=div;
    for(i=0; i<NO_TESTS+1; i++)
    begin
      A = $signed($urandom_range(INT64_MIN, INT64_MAX));
      #1 counter++;
      if(Y!=-'sd1)
        $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl_div,A,B,Y,-'sd1);
    end
  #5
  ctrl_div=divu;
    for(i=0; i<NO_TESTS+1; i++)
    begin
      A = $signed($urandom_range(INT64_MIN, INT64_MAX));
      #1 counter++;
      if(Y!=((2**64)-1))
        $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl_div,A,B,Y,((2**64)-1));
    end
  #5
  ctrl_div=rem;
    for(i=0; i<NO_TESTS+1; i++)
    begin
      A = $signed($urandom_range(INT64_MIN, INT64_MAX));
      #1 counter++;
      if(Y!=A)
        $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl_div,A,B,Y,A);
    end
  #5
  ctrl_div=remu;
    for(i=0; i<NO_TESTS+1; i++)
    begin
      A = $signed($urandom_range(INT64_MIN, INT64_MAX));
      #1 counter++;
      if(Y!=A) begin
        $display("[%4d] %s failed: rs1=0x%h     rs2=0x%h    rd=0x%h     expected=0x%h",i,ctrl_div,A,B,Y,A);
        ->failed;
      end
    end
endtask

task overflow();
  A = INT64_MIN;
  B = -'sd1;
  ctrl_div=div;
  #1 counter++;
  if(Y!=INT64_MIN) begin
    $display("[    ] %s OVERFLOW failed",ctrl_div);
    ->failed;
  end
  
  #5
  ctrl_div=rem;
  #1 counter++;
  if(Y!=0) begin
     $display("[    ] %s OVERFLOW failed",ctrl_div);
    ->failed;
  end
endtask