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
  logic [4:0]  i_riscv_hzrdu_rdaddr_m;
  logic [4:0]  i_riscv_hzrdu_rdaddr_w;
  logic [1:0]  i_riscv_hzrdu_resultsrc_e;
  logic [1:0]  i_riscv_hzrdu_resultsrc_m;
  logic [1:0]  i_riscv_hzrdu_resultsrc_w;
  logic        i_riscv_hzrdu_pcsrc;
  logic        i_riscv_hzrdu_regw_m;
  logic        i_riscv_hzrdu_regw_w;
  logic        i_riscv_hzrdu_op1sel;
  logic        i_riscv_hzrdu_op2sel;
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
   i_riscv_hzrdu_rdaddr_m = 5'b0;
   i_riscv_hzrdu_rdaddr_w = 5'b0;
   i_riscv_hzrdu_resultsrc_e = 2'b0;
   i_riscv_hzrdu_resultsrc_m = 2'b0;
   i_riscv_hzrdu_resultsrc_w = 2'b0;
   i_riscv_hzrdu_pcsrc = 1'b0;
   i_riscv_hzrdu_regw_m = 1'b0;
   i_riscv_hzrdu_regw_w = 1'b0;
   i_riscv_hzrdu_op1sel = 1'b0;
   i_riscv_hzrdu_op2sel = 1'b0;


   
   #CLK_PERIOD;
   
   
// Test 1: rs1 forwarded from memory stage 
 i = 1;
 rs1_forward ( 4'd30, 4'd30, 4'd11, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b01) ; //1 //rs1 forwarded
 i++;
 rs1_forward ( 4'd30, 4'd30, 4'd11, 2'b01, 2'b00, 1'b0, 1'b0, 1'b0, 2'b0) ;  //2  //regw_m = 0 , won't wb in rf
 i++;
 rs1_forward ( 4'd30, 4'd30, 4'd11, 2'b10, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //3  //resultsrc_m = 10 , not from alu 
 i++; 
 rs1_forward ( 4'd30, 4'd11, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //4  //different addresses
 i++;
 rs1_forward ( 4'd30, 4'd00, 4'd11, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //5  //rd address is X0
 i++;
 rs1_forward ( 4'd30, 4'd30, 4'd11, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;  //6  //op1sel is pc 
 i++;


// Test 2: rs1 forwarded from writeback stage 
 i = 1;
 rs1_forward ( 4'd30, 4'd10, 4'd30, 2'b00, 2'b01, 1'b0, 1'b1, 1'b0, 2'b10) ; //7 //rs1 forwarded
 i++;
 rs1_forward ( 4'd30, 4'd10, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //8  //regw_w = 0 , won't wb in rf
 i++;
 rs1_forward ( 4'd30, 4'd10, 4'd30, 2'b11, 2'b10, 1'b1, 1'b0, 1'b0, 2'b0) ;  //9  //resultsrc_w = 10 , not from alu 
 i++; 
 rs1_forward ( 4'd30, 4'd30, 4'd10, 2'b01, 2'b01, 1'b1, 1'b1, 1'b0, 2'b0) ;  //10  //different addresses
 i++;
 rs1_forward ( 4'd30, 4'd6, 4'd00, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //11  //rd address is X0
 i++;
 rs1_forward ( 4'd30, 4'd10, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;  //12  //op1sel is pc 
 i++;
 
 

// Test 3: rs2 forwarded from memory stage 
 i = 1;
 rs2_forward ( 4'd30, 4'd30, 4'd11, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b01) ; //13 //rs2 forwarded
 i++;
 rs2_forward ( 4'd30, 4'd30, 4'd11, 2'b01, 2'b00, 1'b0, 1'b0, 1'b1, 2'b0) ;  //14  //regw_m = 0 , won't wb in rf
 i++;
 rs2_forward ( 4'd30, 4'd30, 4'd11, 2'b10, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;  //15  //resultsrc_m = 10 , not from alu 
 i++; 
 rs2_forward ( 4'd30, 4'd11, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;  //16  //different addresses
 i++;
 rs2_forward ( 4'd30, 4'd00, 4'd11, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;  //17  //rd address is X0
 i++;
 rs2_forward ( 4'd30, 4'd30, 4'd11, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //18  //op2sel is imm 
 i++;


// Test 4: rs2 forwarded from writeback stage 
 i = 1;
 rs2_forward ( 4'd30, 4'd10, 4'd30, 2'b00, 2'b01, 1'b0, 1'b1, 1'b1, 2'b10) ; //19 //rs2 forwarded
 i++;
 rs2_forward ( 4'd30, 4'd10, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;  //20  //regw_w = 0 , won't wb in rf
 i++;
 rs2_forward ( 4'd30, 4'd10, 4'd30, 2'b11, 2'b10, 1'b1, 1'b0, 1'b1, 2'b0) ;  //21  //resultsrc_w = 10 , not from alu 
 i++; 
 rs2_forward ( 4'd30, 4'd30, 4'd10, 2'b01, 2'b01, 1'b1, 1'b1, 1'b1, 2'b0) ;  //22  //different addresses
 i++;
 rs2_forward ( 4'd30, 4'd6, 4'd00, 2'b01, 2'b00, 1'b1, 1'b0, 1'b1, 2'b0) ;   //23  //rd address is X0
 i++;
 rs2_forward ( 4'd30, 4'd10, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //24  //op2sel is pc 
 i++;

// Test 5: stalling
 i = 1;
 stall ( 4'd30, 4'd10, 4'd30, 4'd20, 2'b10, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0) ; //25 //pc stall
 i++;
 stall ( 4'd30, 4'd10, 4'd20, 4'd10, 2'b10, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0) ; //26 //pc stall
 i++;
 stall ( 4'd30, 4'd10, 4'd20, 4'd10, 2'b10, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1) ; //27 //pc stall and flush
 i++; 
 stall ( 4'd30, 4'd10, 4'd20, 4'd15, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1) ; //28 //different addresses but pcsrc =1
 i++;
 stall ( 4'd30, 4'd10, 4'd30, 4'd15, 2'b11, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0) ; //29 //no stall 
 i++;
 stall ( 4'd30, 4'd10, 4'd30, 2'b01, 2'b00, 1'b1, 1'b0, 1'b0, 2'b0) ;  //30  //op2sel is pc 
 i++;


   input [4:0]  rs1addr_d ;
  input [4:0]  rs2addr_d ;
  input [4:0]  rs1addr_e ;
  input [4:0]  rs2addr_e ;

  input [1:0]  resultsrc_e  ;
  input        pcsrc ;
  input [1:0] expected_out1 ; //stall pc
  input [1:0] expected_out2 ; //stall fd
  input [1:0] expected_out3 ; //flush fd
  input [1:0] expected_out4 ; //flush de

    #(10*CLK_PERIOD);

     $stop;
     
  end



/******************** Tasks & Functions *******************/
task rs1_forward ; 
  input [4:0]  rs1addr_e ;
  input [4:0]  rdaddr_m ;
  input [4:0]  rdaddr_w ;
  input [1:0]  resultsrc_m  ;
  input [1:0]  resultsrc_w  ;
  input        regw_m ;
  input        regw_w ;
  input        op1sel ;
  input [1:0] expected_out ;
    
  begin 
   i_riscv_hzrdu_rs1addr_e = rs1addr_e;
   i_riscv_hzrdu_rdaddr_m = rdaddr_m ;
   i_riscv_hzrdu_rdaddr_w = rdaddr_w; 
   i_riscv_hzrdu_resultsrc_m = resultsrc_m;
   i_riscv_hzrdu_resultsrc_w = resultsrc_w;
   i_riscv_hzrdu_regw_m = regw_m ;
   i_riscv_hzrdu_regw_w = regw_w;
   i_riscv_hzrdu_op1sel = op1sel ;

   #CLK_PERIOD;

   if (o_riscv_hzrdu_fwda !== expected_out) 
   $display("rs1_forward failed");
   else
   $display("rs1_forward passed");
 end
endtask


task rs2_forward ; 
  input [4:0]  rs2addr_e ;
  input [4:0]  rdaddr_m ;
  input [4:0]  rdaddr_w ;
  input [1:0]  resultsrc_m  ;
  input [1:0]  resultsrc_w  ;
  input        regw_m ;
  input        regw_w ;
  input        op2sel ;
  input [1:0] expected_out ;
    
  begin 
   i_riscv_hzrdu_rs2addr_e = rs2addr_e;
   i_riscv_hzrdu_rdaddr_m = rdaddr_m ;
   i_riscv_hzrdu_rdaddr_w = rdaddr_w; 
   i_riscv_hzrdu_resultsrc_m = resultsrc_m;
   i_riscv_hzrdu_resultsrc_w = resultsrc_w;
   i_riscv_hzrdu_regw_m = regw_m ;
   i_riscv_hzrdu_regw_w = regw_w;
   i_riscv_hzrdu_op2sel = op2sel;

   #CLK_PERIOD;

   if (o_riscv_hzrdu_fwdb !== expected_out) 
   $display("rs2_forward failed");
   else
   $display("rs2_forward passed");
 end
endtask
  

task stall ; 
  input [4:0]  rs1addr_d ;
  input [4:0]  rs2addr_d ;
  input [4:0]  rs1addr_e ;
  input [4:0]  rs2addr_e ;
  input [1:0]  resultsrc_e  ;
  input        pcsrc ;
  input        expected_out1 ; //stall pc
  input        expected_out2 ; //stall fd
  input        expected_out3 ; //flush fd
  input        expected_out4 ; //flush de

    
  begin 
   i_riscv_hzrdu_rs1addr_d = rs1addr_d;
   i_riscv_hzrdu_rs2addr_d = rs2addr_d;
   i_riscv_hzrdu_rs1addr_e = rs1addr_e;
   i_riscv_hzrdu_rs2addr_e = rs2addr_e;
   i_riscv_hzrdu_resultsrc_e = resultsrc_e;
   i_riscv_hzrdu_pcsrc = pcsrc ;

   #CLK_PERIOD;

   if ((o_riscv_hzrdu_stallpc !== expected_out1) && (o_riscv_hzrdu_stallfd !== expected_out2) && (o_riscv_hzrdu_flushfd !== expected_out3) && (o_riscv_hzrdu_flushde !== expected_out4)) 
   $display("stall failed");
   else
   $display("stall passed");
 end
endtask 


/******************** DUT Instantiation *******************/

  riscv_hazardunit DUT
  (
    .i_riscv_hzrdu_rs1addr_d(i_riscv_hzrdu_rs1addr_d),
    .i_riscv_hzrdu_rs2addr_d(i_riscv_hzrdu_rs2addr_d),
    .i_riscv_hzrdu_rs1addr_e(i_riscv_hzrdu_rs1addr_e),
    .i_riscv_hzrdu_rs2addr_e(i_riscv_hzrdu_rs2addr_e),
    .i_riscv_hzrdu_rdaddr_m(i_riscv_hzrdu_rdaddr_m),
    .i_riscv_hzrdu_rdaddr_w(i_riscv_hzrdu_rdaddr_w),
    .i_riscv_hzrdu_resultsrc_e(i_riscv_hzrdu_resultsrc_e),
    .i_riscv_hzrdu_resultsrc_m(i_riscv_hzrdu_resultsrc_m),
    .i_riscv_hzrdu_resultsrc_w(i_riscv_hzrdu_resultsrc_w),
    .i_riscv_hzrdu_pcsrc(i_riscv_hzrdu_pcsrc),
    .i_riscv_hzrdu_regw_m(i_riscv_hzrdu_regw_m),
    .i_riscv_hzrdu_regw_w(i_riscv_hzrdu_regw_w),
    .i_riscv_hzrdu_op1sel(i_riscv_hzrdu_op1sel),
    .i_riscv_hzrdu_op2sel(i_riscv_hzrdu_op2sel),
    .o_riscv_hzrdu_fwda(o_riscv_hzrdu_fwda),
    .o_riscv_hzrdu_fwdb(o_riscv_hzrdu_fwdb),
    .o_riscv_hzrdu_stallpc(o_riscv_hzrdu_stallpc), 
    .o_riscv_hzrdu_stallfd(o_riscv_hzrdu_stallfd),   
    .o_riscv_hzrdu_flushfd(o_riscv_hzrdu_flushfd), 
    .o_riscv_hzrdu_flushde(o_riscv_hzrdu_flushde) 
  );
  

endmodule