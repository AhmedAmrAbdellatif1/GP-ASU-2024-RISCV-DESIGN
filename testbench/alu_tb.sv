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

  reg [31:0]word_reg;   

/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_alu_ctrl = 5'b0;
   i_riscv_alu_rs1data = 64'b0;
   i_riscv_alu_rs2data = 64'b0;

 #CLK_PERIOD ;
 
 //double word operation alu_ctrl[4]=0 

 //testing add (1) operation  
   i_riscv_alu_ctrl = 5'b00000;
   i_riscv_alu_rs1data = 'sd300;
   i_riscv_alu_rs2data = 'sd230;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  'sd530 )
    $display ("add opertion (1) failed");
   #CLK_PERIOD;
   
 //testing add (2) operation  
   i_riscv_alu_ctrl = 5'b00000;
   i_riscv_alu_rs1data = 'sd300;
   i_riscv_alu_rs2data = -'sd230;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  'sd70 )
    $display ("add opertion (11) failed");
   #CLK_PERIOD;

 //testing sub (1) operation  
   i_riscv_alu_ctrl = 5'b00001;
   i_riscv_alu_rs1data = 64'd780;
   i_riscv_alu_rs2data = 64'd300;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  (i_riscv_alu_rs1data - i_riscv_alu_rs2data))
    $display ("sub opertion (1) failed");
   #CLK_PERIOD;

 //testing sll (1) operation  
   i_riscv_alu_ctrl = 5'b00010;
   i_riscv_alu_rs1data = 64'd780;
   i_riscv_alu_rs2data = 64'd30;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  (i_riscv_alu_rs1data << i_riscv_alu_rs2data[5:0]))
    $display ("sll opertion (1) failed") ;
   #CLK_PERIOD;

 //testing slt signed operation  
   i_riscv_alu_ctrl = 5'b00011;
   i_riscv_alu_rs1data = - 64'sd780;
   i_riscv_alu_rs2data = - 64'sd300;
   #CLK_PERIOD;
   if (o_riscv_alu_result != 0)
    $display ("slt signed opertion failed");
   #CLK_PERIOD;
   i_riscv_alu_ctrl = 5'b00011;
   i_riscv_alu_rs1data = 64'sd50;
   i_riscv_alu_rs2data = 64'sd300;
   #CLK_PERIOD;
   if (o_riscv_alu_result != 1)
    $display ("slt signed opertion failed");
   #CLK_PERIOD;


 //testing slt unsigned operation  
   i_riscv_alu_ctrl = 5'b00100;
   i_riscv_alu_rs1data = 64'd780;
   i_riscv_alu_rs2data = 64'd300;
   #CLK_PERIOD;
   if (o_riscv_alu_result != 0)
    $display ("slt unsigned opertion failed");
   #CLK_PERIOD;
   i_riscv_alu_ctrl = 5'b00100;
   i_riscv_alu_rs1data = 64'd50;
   i_riscv_alu_rs2data = 64'd300;
   #CLK_PERIOD;
   if (o_riscv_alu_result != 1)
    $display ("slt unsigned opertion failed");
   #CLK_PERIOD;

 //testing xor (1) operation  
   i_riscv_alu_ctrl = 5'b00101;
   i_riscv_alu_rs1data = 64'd80;
   i_riscv_alu_rs2data = 64'd30;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  (i_riscv_alu_rs1data ^ i_riscv_alu_rs2data))
    $display ("xor opertion (1) failed");
   #CLK_PERIOD;

 //testing sra (1) operation  
   i_riscv_alu_ctrl = 5'b00111;
   i_riscv_alu_rs1data = 64'd800;
   i_riscv_alu_rs2data = 64'd30;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  (i_riscv_alu_rs1data >> i_riscv_alu_rs2data [5:0]))
    $display ("sra opertion (1) failed") ;
   #CLK_PERIOD;

 //testing or operation  
   i_riscv_alu_ctrl = 5'b01000;
   i_riscv_alu_rs1data = 64'd80;
   i_riscv_alu_rs2data = 64'd30;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  (i_riscv_alu_rs1data | i_riscv_alu_rs2data))
    $display ("or opertion failed") ;
   #CLK_PERIOD;

 //testing and operation  
   i_riscv_alu_ctrl = 5'b01001;
   i_riscv_alu_rs1data = 64'd80;
   i_riscv_alu_rs2data = 64'd30;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  (i_riscv_alu_rs1data & i_riscv_alu_rs2data))
    $display ("and opertion failed") ;
   #CLK_PERIOD;

 //testing Jalr operation  
   i_riscv_alu_ctrl = 5'b01010;
   i_riscv_alu_rs1data = 64'd53;
   i_riscv_alu_rs2data = 64'd32;
   #CLK_PERIOD;
   if (o_riscv_alu_result != 64'd84  )
    $display ("jalr opertion failed") ;
   #CLK_PERIOD;


// word operation alu_ctrl[4]=1

 //testing add (2) operation  
   i_riscv_alu_ctrl = 5'b10000;
   i_riscv_alu_rs1data = 64'd4398046511000;
   i_riscv_alu_rs2data = 64'd4398046000000;
   #CLK_PERIOD;
   word_reg = i_riscv_alu_rs1data[31:0] + i_riscv_alu_rs2data[31:0];
    if (o_riscv_alu_result != ({ {32 {word_reg[31]}} , word_reg}));
     $display ("add opertion (2) failed") ;
   #CLK_PERIOD;

 //testing sub (2) operation  
   i_riscv_alu_ctrl = 5'b10001;
   i_riscv_alu_rs1data = 64'd4398046511000;
   i_riscv_alu_rs2data = 64'd4398046000000;
   #CLK_PERIOD;
   word_reg=i_riscv_alu_rs1data[31:0] - i_riscv_alu_rs2data[31:0];
   if (o_riscv_alu_result != ({ {32 {word_reg[31]}} , word_reg}));
     $display ("sub opertion (2) failed") ;
   #CLK_PERIOD;

 //testing sll (2) operation  
   i_riscv_alu_ctrl = 5'b10010;
   i_riscv_alu_rs1data = 64'd4398046511000;
   i_riscv_alu_rs2data = 64'd4398046000000;
   #CLK_PERIOD;
   word_reg = i_riscv_alu_rs1data[31:0] << i_riscv_alu_rs2data[5:0];
   if (o_riscv_alu_result != ({ {32 {word_reg[31]}} , word_reg}));
     $display ("sll opertion (2) failed") ;
   #CLK_PERIOD;

 //testing xor (2) operation  
   i_riscv_alu_ctrl = 5'b10101;
   i_riscv_alu_rs1data = 64'd4398046511000;
   i_riscv_alu_rs2data = 64'd4398046000000;
   #CLK_PERIOD;
   word_reg = i_riscv_alu_rs1data[31:0] ^ i_riscv_alu_rs2data[31:0];
   if (o_riscv_alu_result != ({ {32 {word_reg[31]}} , word_reg}));
     $display ("xor opertion (2) failed") ;
   #CLK_PERIOD;

 //testing sra (2) operation  
   i_riscv_alu_ctrl = 5'b10111;
   i_riscv_alu_rs1data = 64'd4398046511000;
   i_riscv_alu_rs2data = 64'd4398046000000;
   #CLK_PERIOD;
   word_reg = i_riscv_alu_rs1data[31:0] >> i_riscv_alu_rs2data[5:0];
   if (o_riscv_alu_result != ({ {32 {word_reg[31]}} , word_reg}));
     $display ("sra opertion (2) failed") ; 
   #CLK_PERIOD;


   
 //double word operation alu_ctrl[4]=0 //corner cases

 //testing add (3) operation  
   i_riscv_alu_ctrl = 5'b00000;
   i_riscv_alu_rs1data = 64'hFFFFFFFFFFFFFFFF;  //addtion with overflow
   i_riscv_alu_rs2data = 64'hFFFFFFFFFFFFFFFF;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  - 64'sd9223372036854775808)
    $display ("add opertion (3) failed");
   #CLK_PERIOD;
   
 //testing add (3) operation  
   i_riscv_alu_ctrl = 5'b00000;
   i_riscv_alu_rs1data = 64'hFFFFFFFFFFFFFFFF;  //addtion with overflow
   i_riscv_alu_rs2data = 64'hFFFFFFFFFFFFFFFF;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  - 64'sd9223372036854775808)
    $display ("add opertion (3) failed");
   #CLK_PERIOD;

 //testing sub (3) operation  
   i_riscv_alu_ctrl = 5'b00001;
   i_riscv_alu_rs1data = -64'sd9223372036854775808;
   i_riscv_alu_rs2data = 64'd1;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  64'd9223372036854775807)
    $display ("sub opertion (3) failed");
   #CLK_PERIOD;

 //testing xor (2) operation  
   i_riscv_alu_ctrl = 5'b00101;
   i_riscv_alu_rs1data = 64'hAAAAAAAAAAAAAAAA;
   i_riscv_alu_rs2data = 64'h5555555555555555;
   #CLK_PERIOD;
   if (o_riscv_alu_result != 64'hFFFFFFFFFFFFFFFF)
    $display ("xor opertion (2) failed") ;
   #CLK_PERIOD;

 //testing or (2) operation  
   i_riscv_alu_ctrl = 5'b01000;
   i_riscv_alu_rs1data = 64'hFFFFFFFFFFFFFFFF;
   i_riscv_alu_rs2data = 64'h0000000000000001;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  64'hFFFFFFFFFFFFFFFF)
    $display ("or opertion (2) failed") ;
   #CLK_PERIOD;

 //testing and (2) operation  
   i_riscv_alu_ctrl = 5'b01001;
   i_riscv_alu_rs1data = 64'hFFFFFFFFFFFFFFFF;
   i_riscv_alu_rs2data = 64'h0000000000000001;
   #CLK_PERIOD;
   if (o_riscv_alu_result !=  64'h0000000000000001 )
    $display ("and opertion (2) failed");
   #CLK_PERIOD;
  
  
   #(10*CLK_PERIOD);
    
    $stop ;

  end

/******************** DUT Instantiation *******************/

  riscv_alu DUT
  (
    .i_riscv_alu_ctrl(i_riscv_alu_ctrl),
    .i_riscv_alu_rs1data(i_riscv_alu_rs1data),
    .i_riscv_alu_rs2data(i_riscv_alu_rs2data),
    .o_riscv_alu_result(o_riscv_alu_result)
  );

endmodule
