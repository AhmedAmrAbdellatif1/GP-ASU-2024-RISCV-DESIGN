/**********************************************************/
/* Module Name: riscv_hazardunit                        */
/* Last Modified Date: 24/12/2023                       */
/* By: Rana Mohamed                                     */
/**********************************************************/
`timescale 1ns/1ns

module riscv_hazardunit_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

  integer i;

/************** Internal Signals Declaration **************/
  logic [4:0]  i_riscv_hzrdu_rs1addr_d;
  logic [4:0]  i_riscv_hzrdu_rs2addr_d;
  logic [4:0]  i_riscv_hzrdu_rs1addr_e;
  logic [4:0]  i_riscv_hzrdu_rs2addr_e;
  logic [4:0]  i_riscv_hzrdu_rdaddr_e;
  logic [4:0]  i_riscv_hzrdu_rdaddr_m;
  logic [4:0]  i_riscv_hzrdu_rdaddr_w;
  logic [1:0]  i_riscv_hzrdu_resultsrc_e;
  logic        i_riscv_hzrdu_pcsrc;
  logic        i_riscv_hzrdu_regw_m;
  logic        i_riscv_hzrdu_regw_w;
  logic        i_riscv_hzrdu_memw_m;
  logic        i_riscv_hzrdu_memw_d;
  logic [1:0]  o_riscv_hzrdu_fwda; 
  logic [1:0]  o_riscv_hzrdu_fwdb; 
  logic        o_riscv_hzrdu_stallpc; 
  logic        o_riscv_hzrdu_stallfd;   
  logic        o_riscv_hzrdu_flushfd; 
  logic        o_riscv_hzrdu_flushde; 

    

    
/********************* Initial Blocks *********************/
  initial begin : proc_testing
   i_riscv_hzrdu_rs1addr_d = 5'b0;
   i_riscv_hzrdu_rs2addr_d = 5'b0;
   i_riscv_hzrdu_rs1addr_e = 5'b0;
   i_riscv_hzrdu_rs2addr_e = 5'b0;
   i_riscv_hzrdu_rdaddr_e = 5'b0;
   i_riscv_hzrdu_rdaddr_m = 5'b0;
   i_riscv_hzrdu_rdaddr_w = 5'b0;
   i_riscv_hzrdu_resultsrc_e = 2'b0;
   i_riscv_hzrdu_pcsrc = 1'b0;
   i_riscv_hzrdu_regw_m = 1'b0;
   i_riscv_hzrdu_regw_w = 1'b0;
   i_riscv_hzrdu_memw_m = 1'b0;
   i_riscv_hzrdu_memw_d = 1'b0;



   
   #CLK_PERIOD;
   
   
// Test 1: rs1 forwarded from memory stage 
 i = 1;
 rs1_forward (4'd30, 4'd30, 4'd11, 1'b1, 1'b0, 2'b01) ;  //1 //rs1 forwarded
 i++;
 rs1_forward (4'd30, 4'd30, 4'd30, 1'b1, 1'b1, 2'b01) ;  //2 //mem stage priority 
 i++;
 rs1_forward (4'd30, 4'd30, 4'd11, 1'b0, 1'b0, 2'b0) ;   //3 //regw_m = 0 , won't wb in rf 
 i++; 
 rs1_forward (4'd30, 4'd11, 4'd30, 1'b1, 1'b0, 2'b0) ;   //4 //different addresses
 i++;
 rs1_forward (4'd30, 4'd00, 4'd11, 1'b1, 1'b0, 2'b0) ;   //5 //rd address is X0
 i++;
  

// Test 2: rs1 forwarded from writeback stage 
 rs1_forward (4'd30, 4'd10, 4'd30, 1'b0, 1'b1, 2'b10) ; //6 //rs1 forwarded
 i++;
 rs1_forward (4'd30, 4'd10, 4'd30, 1'b1, 1'b0, 2'b0) ;  //7 //regw_m = 0 , won't wb in rf
 i++; 
 rs1_forward (4'd30, 4'd20, 4'd10, 1'b1, 1'b1, 2'b0) ;  //8 //different addresses
 i++;
 rs1_forward (4'd30, 4'd6, 4'd00, 1'b1, 1'b0, 2'b0) ;   //9 //rd address is X0
 i++;


// Test 3: rs2 forwarded from memory stage 
 i = 1;
 rs2_forward (4'd30, 4'd30, 4'd11, 1'b1, 1'b0, 2'b01) ;  //10 //rs2 forwarded
 i++;
 rs2_forward (4'd30, 4'd30, 4'd30, 1'b1, 1'b1, 2'b01) ;  //11 //mem stage priority 
 i++;
 rs2_forward (4'd30, 4'd30, 4'd11, 1'b0, 1'b0, 2'b0) ;   //12 //regw_m = 0 , won't wb in rf 
 i++; 
 rs2_forward (4'd30, 4'd11, 4'd30, 1'b1, 1'b0, 2'b0) ;   //13 //different addresses
 i++;
 rs2_forward (4'd30, 4'd00, 4'd11, 1'b1, 1'b0, 2'b0) ;   //14 //rd address is X0
 i++;


// Test 4: rs2 forwarded from writeback stage 
 rs2_forward (4'd30, 4'd10, 4'd30, 1'b0, 1'b1, 2'b10) ; //15 //rs2 forwarded
 i++;
 rs2_forward (4'd30, 4'd10, 4'd30, 1'b1, 1'b0, 2'b0) ;  //16 //regw_m = 0 , won't wb in rf
 i++; 
 rs2_forward (4'd30, 4'd20, 4'd10, 1'b1, 1'b1, 2'b0) ;  //17 //different addresses
 i++;
 rs2_forward (4'd30, 4'd6, 4'd00, 1'b1, 1'b0, 2'b0) ;   //18 //rd address is X0
 i++;

// Test 5: stalling and flushing
 i = 1;
 stall_flush (4'd30, 4'd10, 4'd30, 2'b10, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1) ; //19 //pc stall
 i++;
 stall_flush (4'd30, 4'd10, 4'd10, 2'b10, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1) ; //20 //pc stall
 i++;
 stall_flush (4'd30, 4'd10, 4'd20, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1) ; //21 //pc flush //different addresses but pcsrc =1
 i++; 
 stall_flush (4'd30, 4'd30, 4'd20, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0) ; //22 //no stall
 i++;
 stall_flush (4'd30, 4'd10, 4'd30, 2'b11, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1) ; //23 //no stall 
 i++;


    #(10*CLK_PERIOD);

     $stop;
     
  end



/******************** Tasks & Functions *******************/
task rs1_forward ; 
  input [4:0]  rs1addr_e ;
  input [4:0]  rdaddr_m ;
  input [4:0]  rdaddr_w ;
  input        regw_m ;
  input        regw_w ;
  input [1:0] expected_out ;
    
  begin 
   i_riscv_hzrdu_rs1addr_e = rs1addr_e;
   i_riscv_hzrdu_rdaddr_m = rdaddr_m ;
   i_riscv_hzrdu_rdaddr_w = rdaddr_w; 
   i_riscv_hzrdu_regw_m = regw_m ;
   i_riscv_hzrdu_regw_w = regw_w;

   #CLK_PERIOD;

   if (o_riscv_hzrdu_fwda !== expected_out) 
   $display("[%2d] rs1_forward failed" , i);
   else
   $display("[%2d] rs1_forward passed" , i);
 end
endtask


task rs2_forward ; 
  input [4:0]  rs2addr_e ;
  input [4:0]  rdaddr_m ;
  input [4:0]  rdaddr_w ;
  input        regw_m ;
  input        regw_w ;
  input [1:0] expected_out ;
    
  begin 
   i_riscv_hzrdu_rs2addr_e = rs2addr_e;
   i_riscv_hzrdu_rdaddr_m = rdaddr_m ;
   i_riscv_hzrdu_rdaddr_w = rdaddr_w; 
   i_riscv_hzrdu_regw_m = regw_m ;
   i_riscv_hzrdu_regw_w = regw_w;

   #CLK_PERIOD;

   if (o_riscv_hzrdu_fwdb !== expected_out) 
   $display("[%2d] rs2_forward failed" , i);
   else
   $display("[%2d] rs2_forward passed" , i);
 end
endtask
  

task stall_flush ; 
  input [4:0]  rs1addr_d ;
  input [4:0]  rs2addr_d ;
  input [4:0]  rdaddr_e ;
  input [1:0]  resultsrc_e  ;
  input        pcsrc ;
  input        expected_out1 ; //stall pc
  input        expected_out2 ; //stall fd
  input        expected_out3 ; //flush fd
  input        expected_out4 ; //flush de

    
  begin 
   i_riscv_hzrdu_rs1addr_d = rs1addr_d;
   i_riscv_hzrdu_rs2addr_d = rs2addr_d;
   i_riscv_hzrdu_rdaddr_e = rdaddr_e;
   i_riscv_hzrdu_resultsrc_e = resultsrc_e;
   i_riscv_hzrdu_pcsrc = pcsrc ;

   #CLK_PERIOD;

   if ((o_riscv_hzrdu_stallpc !== expected_out1) && (o_riscv_hzrdu_stallfd !== expected_out2) && (o_riscv_hzrdu_flushfd !== expected_out3) && (o_riscv_hzrdu_flushde !== expected_out4)) 
   $display("[%2d] stall_flush failed" , i);
   else
   $display("[%2d] stall_flush passed", i);
 end
endtask 


/******************** DUT Instantiation *******************/

  riscv_hazardunit DUT
  (
    .* 
  );
  

endmodule