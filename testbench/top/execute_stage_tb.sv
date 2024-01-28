/**********************************************************/
/* Stage Name: Execute                                  */
/* Last Modified Date: 25/12/2023                       */
/* By: Rana Mohamed                                     */
/**********************************************************/
`timescale 1ns/1ns

module riscv_top_tb();

/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;

  integer k ;

/************** Internal Signals Declaration **************/
  logic        clk,rst;
  logic [63:0] op1 ;
  logic [63:0] op2 ;
  logic [63:0] result ;

/********************* Initial Blocks *********************/
 initial begin : proc_execute
  #CLK_PERIOD;
  #CLK_PERIOD;
  @(negedge clk)


  k = 1 ;  
  execute_stage_check ('d0, 'h100000, 'h100000) ;  //1  //auipc x6, 0x100 
  #CLK_PERIOD;
  k ++ ;
  execute_stage_check ('d0, 'd10, 'd10) ;          //2  //addi x8, x0, 10
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d0, 'd20, 'd20) ;          //3  //addi x9, x0, 20
  #CLK_PERIOD;
  k ++ ;   
  execute_stage_check ('d0, 'd0, 'd0) ;            //4  //sd x6, 0(x0)
  #CLK_PERIOD;
  k ++ ;
  execute_stage_check ('b0, 'd0, 'd0) ;            //5  //ld x7, 0(x0)
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d10, 'd20, 'd30) ;         //6  //add x10, x8, x9             
  #CLK_PERIOD;
  k ++ ;  
  /*execute_stage_check ('d0, 'd10, 'd10) ; */     //7  //lui x5, 0x20000
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d0, 'd18, 'd18) ;          //8  //addiw x4, x0, 18
  #CLK_PERIOD; 
  k ++ ;  
  execute_stage_check ('d10, 'd20, 'd1) ;          //9  //sltu x3, x8, x9 
  #CLK_PERIOD; 
  k ++ ; 
  execute_stage_check ('h24, -'sd20, 'd16) ;       //10  //bne x6, x7, -20 
   #CLK_PERIOD;


 //Testing Hazards : Case (1)
  k ++ ; 
  execute_stage_check ('d0, 'd15, 'd15) ;          //11  //addi x8, x0, 15 
  #CLK_PERIOD;
  k ++ ;   
  execute_stage_check ('d15, 'd20, -'sd5) ;        //12  //sub x27, x8, x9  --> rs1 value forwarded
  #CLK_PERIOD;
  k ++ ;
  execute_stage_check ('d20, 'd15, 'd31) ;         //13  //or x29, x9, x8  --> rs2 value forwarded
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d20, 'd2, 'd80) ;          //14  //slliw x28, x9, 2             
  #CLK_PERIOD;
  k ++ ;  
  execute_stage_check ('d0, 'd0, 'd0) ;            //15  //nop
  #CLK_PERIOD;

 //Testing Hazards : Case (2)
  k ++ ;  
  execute_stage_check ('d0, 'd30, 'd30) ;          //16  //addi x9, x0, 30
  #CLK_PERIOD; 
  k ++ ;  
  execute_stage_check ('d20, 'd20, 'd40) ;         //17  //add  x0, x9, x9  --> rs1,rs2 value not forwarded (rdaddr = 0x0)
 
 
  
  #(10*CLK_PERIOD) ;
  $stop ;
 
 end

  /** Reseting Block **/
  initial begin : proc_reseting
    rst = 1'b1;
    #CLK_PERIOD;
    rst = 1'b0;
  end

  /** Clock Generation Block **/
  initial begin  
    clk = 1'b1;
    forever begin
      #HALF_PERIOD clk = ~clk;
    end
  end

/******************** Tasks & Functions *******************/

 assign op1 = DUT.u_top_datapath.u_riscv_estage.o_riscv_OperandmuxA_OperandALUA ;
 assign op2 = DUT.u_top_datapath.u_riscv_estage.o_riscv_OperandmuxB_OperandALUB ;
 assign result = DUT.u_top_datapath.u_riscv_estage.o_riscv_estage_aluresult ;

 task execute_stage_check ;
  input [63:0] in1 ;
  input [63:0] in2 ;
  input [63:0] expected_result ;

  begin
    if ((op1 != in1)||(op2 != in2)||(result != expected_result))
      $display("[%2d] test failed. Expected: 0x%2h, Actual: 0x%2h", k, expected_result, result);
   else 
      $display("[%2d] test passed. Expected: 0x%2h, Actual: 0x%2h", k, expected_result, result);
    end 
  endtask



/******************** DUT Instantiation *******************/

  riscv_top DUT
  (
    .i_riscv_clk(clk),
    .i_riscv_rst(rst)
  );
endmodule