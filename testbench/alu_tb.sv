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

/************** Internal Signals Declaration **************/
  logic [4:0]  i_riscv_alu_ctrl;
  logic [63:0] i_riscv_alu_rs1data;
  logic [63:0] i_riscv_alu_rs2data;
  logic [63:0] o_riscv_alu_result;
 
/********************* Initial Blocks *********************/
 // Testbench initialization
  initial begin : proc_testing
    i_riscv_alu_ctrl = 5'b0;
    i_riscv_alu_rs1data = 64'b0;
    i_riscv_alu_rs2data = 64'b0;

    #CLK_PERIOD;


    // Run test cases
    add_test(64'h300, 64'h230, 64'h530);
    add_test('sd12268, 'sd45973, 'sd58241);
    add_test('sd51279, -'sd38166, 'sd13113);
    add_test(-'sd61581, 'sd34976, -'sd26605);
    add_test(-'sd1289, -'sd5023, -'sd6312);
    add_test('sh886431DBF4092325, 'sh17FD2488CB26BEE6, 'shA0615664BF2FE20B);
    add_test('shFFFFFFFFFFFFFFFF, 'sh1, 'sh0);

    sub_test(64'd780, 64'd300, 64'd480);
    sub_test('sd12268, 'sd45973, -'sd33705);
    sub_test('sd51279, -'sd38166, 'sd89445);
    sub_test(-'sd61581, 'sd34976, -'sd96557);
    sub_test(-'sd1289, -'sd5023, 'sd3734);

    sll_test('sd12268,'d1,'sd24536);
    sll_test('sd51279,'d2,'sd205116);
    sll_test(-'sd61581,'d3,-'sd492648);
    sll_test(-'sd1289,'d4,-'sd20624);

    slt_test('sd12268,'sd45973,'sd1);
    slt_test('sd51279,-'sd38166,'sd0);
    slt_test(-'sd61581,'sd34976,'sd1);
    slt_test(-'sd1289,-'sd5023,'sd0);

    sltu_test('sd12268,'sd45973,'sd1);
    sltu_test('sd51279,-'sd38166,'sd1);
    sltu_test(-'sd61581,'sd34976,'sd1);
    sltu_test(-'sd1289,-'sd5023,'sd0);

    xor_test('sd12268,'sd45973,'sd40057);
    xor_test('sd51279,-'sd38166,-'sd23899);
    xor_test(-'sd61581,'sd34976,-'sd30765);
    xor_test(-'sd1289,-'sd5023,'sd5782);

    srl_test('sd12268,'d1,'sd6134);
    srl_test('sd51279,'d2,'sd12819);
    srl_test(-'sd61581,'d3,64'sh1FFFFFFFFFFFE1EE);
    srl_test(-'sd1289,'d4,64'shFFFFFFFFFFFFFAF);

    sra_test('sd12268,'d1,'sd6134);
    sra_test('sd51279,'d2,'sd12819);
    sra_test(-'sd61581,'d3,-'sd7698);
    sra_test(-'sd1289,'d4,-'sd81);

    or_test('sd12268,'sd45973,'sd49149);
    or_test('sd51279,-'sd38166,-'sd5393);
    or_test(-'sd61581,'sd34976,-'sd28685);
    or_test(-'sd1289,-'sd5023,-'sd265);

    and_test('sd12268,'sd45973,'sd9092);
    and_test('sd51279,-'sd38166,'sd18506);
    and_test(-'sd61581,'sd34976,'sd2080);
    and_test(-'sd1289,-'sd5023,-'sd6047);

    jalr_test('sd12268,'sd45973,'sd58240);
    jalr_test('sd51279,-'sd38166,'sd13112);
    jalr_test(-'sd61581,'sd34976,-'sd26606);
    jalr_test(-'sd1289,-'sd5023,-'sd6312);



    

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
      $display("%s operation failed. Expected: %0h, Actual: %0h", op_name, expected_result, o_riscv_alu_result);
      
    end 
  endtask

 

    // Task to perform add test
    task add_test ;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result; 
     begin 
      run_alu_test("Add", 5'b00000, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform sub test
    task sub_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin
      run_alu_test("Sub", 5'b00001, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform sll test
    task sll_test;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result;
    begin 
      run_alu_test("Sll", 5'b00010, rs1, rs2, expected_result);
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


    // Add more tasks for other ALU operations as needed








/******************** DUT Instantiation *******************/

  riscv_alu DUT
  (
    .i_riscv_alu_ctrl(i_riscv_alu_ctrl),
    .i_riscv_alu_rs1data(i_riscv_alu_rs1data),
    .i_riscv_alu_rs2data(i_riscv_alu_rs2data),
    .o_riscv_alu_result(o_riscv_alu_result)
  );

endmodule
