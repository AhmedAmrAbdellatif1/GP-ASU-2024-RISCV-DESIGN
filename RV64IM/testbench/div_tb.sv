`timescale 1ns/1ns

module riscv_divider_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

  integer i;

/************** Internal Signals Declaration **************/
  logic        [2:0] i_riscv_div_divctrl;
  logic signed [63:0] i_riscv_div_rs1data, i_riscv_div_rs2data;
  logic signed [63:0] o_riscv_div_result;


/********************* Initial Blocks *********************/
 // Testbench initialization
  initial begin : proc_testing
    i_riscv_div_divctrl = 3'b0;
    i_riscv_div_rs1data = 64'b0;
    i_riscv_div_rs2data = 64'b0;

    #CLK_PERIOD;


    // Run test cases
    /************ div ************/
    i = 1;
    div_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, -64'shA461C20C4C35F77); // 1
    /************ divu ************/
    i++;
    divu_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, 64'h96BE3DF37BFA9F87); // 2
    /************ rem ************/
    i++;
    rem_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, -64'sh1); // 3
    /************ remu ************/
    i++;
    remu_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, 64'hFFFFFFFFFFFFFFFF); // 4
    

   #1000 $stop; // Stop simulation after all test cases are executed
    
  end 


/******************** Tasks & Functions *******************/
  // Task to perform Div operation and check result
  task run_div_test ;
    input string op_name; 
    input [2:0]  ctrl; 
    input [63:0] rs1; 
    input [63:0] rs2; 
    input [63:0] expected_result;
    
    begin
    i_riscv_div_divctrl = ctrl;
    i_riscv_div_rs1data = rs1;
    i_riscv_div_rs2data = rs2;
    #CLK_PERIOD;

    if (o_riscv_div_result !== expected_result)
      $display("[%2d] %s operation failed. Expected: %0h, Actual: %0h", i, op_name, expected_result, o_riscv_div_result);
   else 
      $display("[%2d] %s operation passed. Expected: %0h, Actual: %0h", i, op_name, expected_result, o_riscv_div_result);
    end 
  endtask

  
    // Task to perform signed div test
    task div_test ;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result; 
     begin 
      run_div_test("div", 3'b100, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform unsigned divu test
    task divu_test ;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result; 
     begin 
      run_div_test("divu", 3'b101, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform signed rem test
    task rem_test ;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result; 
     begin 
      run_div_test("rem", 3'b110, rs1, rs2, expected_result);
    end 
    endtask

    // Task to perform unsigned remu test
    task remu_test ;
    input [63:0] rs1;
    input [63:0] rs2;
    input [63:0] expected_result; 
     begin 
      run_div_test("remu", 3'b111, rs1, rs2, expected_result);
    end 
    endtask

/******************** DUT Instantiation *******************/
  riscv_divider  DUT 
  (
    .i_riscv_div_rs1data(i_riscv_div_rs1data),
    .i_riscv_div_rs2data(i_riscv_div_rs2data),
    .i_riscv_div_divctrl(i_riscv_div_divctrl),
    .o_riscv_div_result(o_riscv_div_result)
  );
  

endmodule







