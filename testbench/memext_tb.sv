/**********************************************************/
/* Module Name:                                           */
/* Last Modified Date:                                    */
/* By:   Abdelarhaman                                     */
/**********************************************************/
`timescale 1ns/1ns;

module riscv_memext_tb();

/*********************** Parameters ***********************/
  parameter DELAY =50;
  parameter TEST_NUM = 100;
  parameter BYTE_SIZE =8;
  parameter HALF_WORD_SIZE= 16;
  parameter WORD_SIZE =32;
  parameter DOUBLE_WORD_SIZE = 64;
/************** Internal Signals Declaration **************/
  logic  [2:0]  sel;
  logic  [63:0] data;
  logic  [63:0] out;
  logic  [63:0] data_random [99:0];
  integer i;
/********************* Initial Blocks *********************/
  initial begin : proc_testing
    $readmemh("100_random_64bits.txt",data_random);
    
    //Load Byte 
    sel = 000; //signed load byte
    Signed_random_inputs_BYTE();
    #DELAY
    sel = 100;
    Unsigned_random_inputs_BYTE();
    #DELAY
    //Half word
    sel = 001;
    Signed_random_inputs_HALFWORD();
    #DELAY
    sel = 101;
    Unsigned_random_inputs_HalfWord();
    #DELAY
    //Word
    sel = 010;
    Signed_random_inputs_Word();
    #DELAY
    sel = 110;
    Unsigned_random_inputs_Word();
    // Double word
    sel = 011;
    Unsigned_random_inputs_Doubleword();
  
   #DELAY 
   $stop; 
  end
  
  


/******************** Tasks & Functions *******************/
task Signed_random_inputs_BYTE();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
     data = data_random[i]; 
      #DELAY
      if(out !== {{56{data[7]}},{data[7:0]}})
        $display("BYTE %b error_signed out = %b",data,out);
     end
endtask

task Unsigned_random_inputs_BYTE();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
    data = data_random[i]; 
      #DELAY
      if((out !== {{56{0}},{data[7:0]}}))
        $display("BYTE %b error_unsigned out = %b",data,out);
     end
  
endtask

task Signed_random_inputs_HALFWORD();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
    data = data_random[i]; 
      #DELAY
      if(out !== {{48{data[15]}},{data[15:0]}})
        $display("Half WORD %b error_signed out = %b",data,out);
     end
  
endtask


task Unsigned_random_inputs_HalfWord();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
       data = data_random[i]; 
      #DELAY
      if((out !== {{48{0}},{data[15:0]}}))
        $display("Half word %b error_unsigned out = %b",data,out);
     end
  
endtask


task Signed_random_inputs_Word();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
      data = data_random[i]; 
      #DELAY
      if(out !== {{32{data[31]}},{data[31:0]}})
        $display("Word %b error_signed out = %b",data,out);
     end
endtask
  
task Unsigned_random_inputs_Word();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
      data = data_random[i]; 
      #DELAY
      if((out !== {{32{0}},{data[31:0]}}))
        $display("Word %b error_unsigned out = %b",data,out);
     end
  
endtask
task Unsigned_random_inputs_Doubleword();
    for(i=0;i<TEST_NUM;i=i+1)
      begin
      data = data_random[i]; 
      #DELAY
      if(out !== data)
        $display("Doubleword %b error_unsigned out = %b",data,out);
     end
  
endtask


/******************** DUT Instantiation *******************/

  riscv_memext DUT
  (
    .i_riscv_memext_sel(sel),
    .i_riscv_memext_data(data),
    .o_riscv_memext_loaded(out)
  );
endmodule




