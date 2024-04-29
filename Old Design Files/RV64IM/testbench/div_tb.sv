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
    //////////////////////////////////////////////////postive postive///////////////////////////////////
    /************ div ************/
    i = 1;
    div_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, 64'shf591bac363bf033f); // 1
    /************ divu ************/
    i++;
    divu_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, 64'h4ae71018b9145894); // 2
    /************ rem ************/
    i++;
    rem_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, 0); // 3
    /************ remu ************/
    i++;
    remu_test(-64'sh1F4ACFB5D4C2F643, 64'sh3, 64'h1); // 4

    /////////////////////////////////////////////////////negative negative////////////////////////////////
	/************ div ************/
    i ++;
    div_test(-64'sd77, -64'sd33, 64'sd2); // 1
    /************ divu ************/
    i++;
    divu_test(-64'sd77, -64'sd33,0); // 2
    /************ rem ************/
    i++;
    rem_test(-64'sd77, -64'sd33,-64'sd11); // 3
    /************ remu ************/
    i++;
    remu_test(-64'sd77, -64'sd33,-64'sd77);// 4
	
 /////////////////////////////////////////////////////negative positive///////////////////////////////
	/************ div ************/
    i ++;
    div_test(-64'sd6843, 64'sd336, -64'sd20); // 1
    /************ divu ************/
    i++;
    divu_test(-64'sd6843, 64'sd336, 64'sd54901024028897454); // 2
    /************ rem ************/
    i++;
    rem_test(-64'sd6843, 64'sd336, -64'sd123); // 3
    /************ remu ************/
    i++;
    remu_test(-64'sd6843, 64'sd336, 64'sd229);// 4

///////////////////////////////////////////////////// positive negative///////////////////////////////
	/************ div ************/
    i ++;
    div_test(64'sd6843, -64'sd336, -64'sd20); // 1
    /************ divu ************/
    i++;
    divu_test(64'sd6843, -64'sd336,0); // 2
    /************ rem ************/
    i++;
    rem_test(64'sd6843, -64'sd336, 64'sd123); // 3
    /************ remu ************/
    i++;
    remu_test(64'sd6843, -64'sd336, 64'sd6843);// 4


  ///////////////////////////////////////////mix to check/////////////////////////
 i++;
    divu_test(64'shf6528949d637, -64'sh6354ab3476d,0); // 2 
 i++;
    remu_test(64'shf6528949d637, -64'sh6354ab3476d, 64'sh0000f6528949d637);// 4
i++;
    divu_test(-64'shf6528949d637, -64'sh6354ab3476d,0); // 2 
 i++;
    remu_test(-64'shf6528949d637, -64'sh6354ab3476d, 64'shffff09ad76b629c9);// 4
 i++;
    divu_test(-64'sd9283736201837, -64'sd764572638,0); // 2 
 i++;
    remu_test(-64'sd9283736201837, -64'sd764572638, 64'shfffff78e76339593);// 4
    i++;
    divu_test(64'shf675da43689, -64'sd764572638,0); // 2 
 i++;
    remu_test(64'shf675da43689, -64'sd764572638, 64'sh0f675da43689);// 4



	////////////////////////////////////test divide by 0////////////////
     /************ div ************/
    i ++;
    div_test(-64'sh1F4ACFB5D4C2F643, 0, -64'sh1); // 1
    /************ divu ************/
    i++;
    divu_test(-64'sh1F4ACFB5D4C2F643, 0, 64'hFFFFFFFFFFFFFFFF); // 2
    /************ rem ************/
    i++;
    rem_test(-64'sh1F4ACFB5D4C2F643, 0,-64'sh1F4ACFB5D4C2F643 ); // 3
    /************ remu ************/
    i++;
    remu_test(-64'sh1F4ACFB5D4C2F643, 0, -64'sh1F4ACFB5D4C2F643); // 4
	///////////////////////////////test overflow////////////////
     i ++;
    div_test(64'sh8000000000000000, -'sh1, 64'sh8000000000000000); // 1
	 /************ rem ************/
    i++;
    rem_test(64'sh8000000000000000,-'sh1,0 ); // 3

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
