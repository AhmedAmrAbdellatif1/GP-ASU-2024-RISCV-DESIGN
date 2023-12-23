/**********************************************************/
/* Module Name: riscv_alu (Arithmetic logic unit)    */
/* Last Modified Date: 21/12/2023                    */
/* By: Rana Mohamed                                  */
/**********************************************************/
`timescale 1ns/1ns

module riscv_alu_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

  integer i;

/************** Internal Signals Declaration **************/
  logic        [4:0]  i_riscv_alu_ctrl;
  logic signed [63:0] i_riscv_alu_rs1data;
  logic signed [63:0] i_riscv_alu_rs2data;
  logic signed [63:0] o_riscv_alu_result;
 
/********************* Initial Blocks *********************/
 // Testbench initialization
  initial begin : proc_testing
    i_riscv_alu_ctrl = 5'b0;
    i_riscv_alu_rs1data = 64'b0;
    i_riscv_alu_rs2data = 64'b0;

    #CLK_PERIOD;

    // Run test cases
    i = 1;
    /************ add ************/
    add_test(64'h300, 64'h230, 64'h530); // 1
    i++;
    add_test('sd12268, 'sd45973, 'sd58241); // 2
    i++;
    add_test('sd51279, -'sd38166, 'sd13113); // 3
    i++;
    add_test(-'sd61581, 'sd34976, -'sd26605); // 4
    i++;
    add_test(-'sd1289, -'sd5023, -'sd6312); // 5
    i++;
    add_test('sh886431DBF4092325, 'sh17FD2488CB26BEE6, 'shA0615664BF2FE20B); // 6
    i++;
    add_test('shFFFFFFFFFFFFFFFF, 'sh1, 'sh0); // 7
    i++;

    /************ sub ************/
    sub_test(64'd780, 64'd300, 64'd480); // 8
    i++;
    sub_test('sd12268, 'sd45973, -'sd33705); // 9
    i++;
    sub_test('sd51279, -'sd38166, 'sd89445); // 10
    i++;
    sub_test(-'sd61581, 'sd34976, -'sd96557); // 11
    i++;
    sub_test(-'sd1289, -'sd5023, 'sd3734); // 12
    i++;

    /************ sll ************/
    sll_test('sd12268,'d1,'sd24536); // 13
    i++;
    sll_test('sd51279,'d2,'sd205116); // 14
    i++;
    sll_test(-'sd61581,'d3,-'sd492648); // 15
    i++;
    sll_test(-'sd1289,'d255,'h8000000000000000); // 16
    i++;

    /************ slt ************/
    slt_test('sd12268,'sd45973,'sd1); // 17
    i++;
    slt_test('sd51279,-'sd38166,'sd0); // 18
    i++;
    slt_test(-'sd61581,'sd34976,'sd1); // 19
    i++;
    slt_test(-'sd1289,-'sd5023,'sd0); // 20
    i++;

    /************ sltu ************/
    sltu_test('sd12268,'sd45973,'sd1); // 21
    i++;
    sltu_test('sd51279,-'sd38166,'sd1); // 22
    i++;
    sltu_test(-'sd61581,'sd34976,'sd0); // 23
    i++;
    sltu_test(-'sd1289,-'sd5023,'sd0); // 24
    i++;

    /************ xor ************/
    xor_test('sd12268,'sd45973,'sd40057); // 25
    i++;
    xor_test('sd51279,-'sd38166,-'sd23899); // 26
    i++;
    xor_test(-'sd61581,'sd34976,-'sd30765); // 27
    i++;
    xor_test(-'sd1289,-'sd5023,'sd5782); // 28
    i++;

    /************ srl ************/
    srl_test('sd12268,'d1,'sd6134); // 29
    i++;
    srl_test('sd51279,'d2,'sd12819); // 30
    i++;
    srl_test(-'sd61581,'d3,64'sh1FFFFFFFFFFFE1EE); // 31
    i++;
    srl_test(-'sd1289,'d4,64'shFFFFFFFFFFFFFAF); // 32
    i++;

    /************ sra ************/
    sra_test('sd12268,'d1,'sd6134); // 33
    i++;
    sra_test('sd51279,'d2,'sd12819); // 34
    i++;
    sra_test(-'sd61581,'d3,-'sd7698); // 35
    i++;
    sra_test(-'sd1289,'d4,-'sd81); // 36
    i++;

    /************ or ************/
    or_test('sd12268,'sd45973,'sd49149); // 37
    i++;
    or_test('sd51279,-'sd38166,-'sd5393); // 38
    i++;
    or_test(-'sd61581,'sd34976,-'sd28685); // 39
    i++;
    or_test(-'sd1289,-'sd5023,-'sd265); // 40
    i++;

    /************ and ************/
    and_test('sd12268,'sd45973,'sd9092); // 41
    i++;
    and_test('sd51279,-'sd38166,'sd18506); // 42
    i++;
    and_test(-'sd61581,'sd34976,'sd2080); // 43
    i++;
    and_test(-'sd1289,-'sd5023,-'sd6047); // 44
    i++;

    /************ jalr ************/
    jalr_test('sd12268,'sd45973,'sd58240); // 45
    i++;
    jalr_test('sd51279,-'sd38166,'sd13112); // 46
    i++;
    jalr_test(-'sd61581,'sd34976,-'sd26606); // 47
    i++;
    jalr_test(-'sd1289,-'sd5023,-'sd6312); // 48
    i++;

    /************ addw ************/
    addw_test('h166D0D2A6FA83EF0,'h16C45C2364CB265,'hFFFFFFFFA5F4F155); // 49
    i++;
    addw_test('h084760DA96D6FEE,'hD70A0561E19C47FC,'hFFFFFFFF8B09B7EA); // 50
    i++;
    addw_test('hB9DB66F2117B2978,'h6810A5D2D5909A9,'h000000003ED43321); // 51
    i++;
    addw_test('hFBC8A34FA13AB781,'hA6955F953DE170C1,'hFFFFFFFFDF1C2842); // 52
    i++;

    /************ subw ************/
    subw_test('h166D0D2A6FA83EF0,'h16C45C2364CB265,'h0000000395B8C8B); // 53
    i++;
    subw_test('h084760DA96D6FEE,'hD70A0561E19C47FC,'hFFFFFFFFC7D127F2); // 54
    i++;
    subw_test('hB9DB66F2117B2978,'h6810A5D2D5909A9,'hFFFFFFFFE4221FCF); // 55
    i++;
    subw_test('hFBC8A34FA13AB781,'hA6955F953DE170C1,'h0000000635946C0); // 56
    i++;


    /************ sllw ************/
    sllw_test('h166D0D2A6FA83EF0,'d10,'hFFFFFFFFA0FBC000); // 57
    i++;
    sllw_test('h084760DA96D6FEE,'d20,'hFFFFFFFFFEE00000); // 58
    i++;
    sllw_test('hB9DB66F2117B2978,'d5,'h000000002F652F00); // 59
    i++;
    sllw_test('hFBC8A34FA13AB781,'d7,'hFFFFFFFF9D5BC080); // 60
    i++;

    /************ srlw ************/
    srlw_test('h166D0D2A6FA83EF0,'d10,'h00000000001BEA0F); // 61
    i++;
    srlw_test('h084760DA96D6FEE,'d20,'h0000000000000A96); // 62
    i++;
    srlw_test('hB9DB66F2117B2978,'d5,'h00000000008BD94B); // 63
    i++;
    srlw_test('hFBC8A34FA13AB781,'d7,'h000000000142756F); // 64
    i++;

    /************ sraw ************/
    sraw_test('h166D0D2A6FA83EF0,'d4,'h0000000006FA83EF); // 65
    i++;
    sraw_test('h084760DA96D6FEE,'d8,'h0000000000A96D6F); // 66
    i++;
    sraw_test('hB9DB66F2117B2978,'d16,'h000000000000117B); // 67
    i++;
    sraw_test('hFBC8A34FA13AB781,'d32,'h0); // 68
    i++;

  #1000 $stop; // Stop simulation after all test cases are executed
    
  end 
 
/******************** Tasks & Functions *******************/
  // Task to perform ALU operation and check result
  task run_alu_test ;
    input string op_name; 
    input [4:0] ctrl; 
    input [63:0] rs1; 
    input [63:0] rs2; 
    input [63:0] expected_result ;
    
    begin
    i_riscv_alu_ctrl = ctrl;
    i_riscv_alu_rs1data = rs1;
    i_riscv_alu_rs2data = rs2;
    #CLK_PERIOD;

    if (o_riscv_alu_result !== expected_result)
      $display("[%2d] %s operation failed. Expected: %0h, Actual: %0h", i, op_name, expected_result, o_riscv_alu_result);
   else 
      $display("[%2d] %s operation passed. Expected: %0h, Actual: %0h", i, op_name, expected_result, o_riscv_alu_result);
    end 
  endtask

  
    // Task to perform add test
    task add_test ;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result; 
     begin 
      run_alu_test("add", 5'b00000, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform sub test
    task sub_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("sub", 5'b00001, rs1, rs2, expected_result);
    end 
    endtask
    

    // Task to perform sll test
    task sll_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin 
      run_alu_test("sll", 5'b00010, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform slt test
    task slt_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("slt", 5'b00011, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform sltu test
    task sltu_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("sltu", 5'b00100, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform xor test
    task xor_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("xor", 5'b00101, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform srl test
    task srl_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("srl", 5'b00110, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform sra test
    task sra_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("sra", 5'b00111, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform or test
    task or_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("or", 5'b01000, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform and test
    task and_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("and", 5'b01001, rs1, rs2, expected_result);
    end 
    endtask


    // Task to perform jalr test
    task jalr_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("jalr", 5'b01010, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform addw test
    task addw_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("addw", 5'b10000, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform subw test
    task subw_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("subw", 5'b10001, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform sllw test
    task sllw_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("sllw", 5'b10010, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform srlw test
    task srlw_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("srlw", 5'b10110, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform sraw test
    task sraw_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("sraw", 5'b10111, rs1, rs2, expected_result);
    end 
    endtask


   

/******************** DUT Instantiation *******************/

  riscv_alu DUT
  (
    .i_riscv_alu_ctrl(i_riscv_alu_ctrl),
    .i_riscv_alu_rs1data(i_riscv_alu_rs1data),
    .i_riscv_alu_rs2data(i_riscv_alu_rs2data),
    .o_riscv_alu_result(o_riscv_alu_result)
  );

endmodule
