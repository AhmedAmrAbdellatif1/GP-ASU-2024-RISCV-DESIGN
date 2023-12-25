`timescale 1ns/1ps

module riscv_rf_tb();
 
 
/*********************** Parameters ***********************/
  parameter CLK_PERIOD = 50;
  parameter HALF_PERIOD = CLK_PERIOD/2;
  parameter WIDTH = 64;
  parameter DEPTH = 32;
  parameter ADDR = 5 ;

/************** Internal Signals Declaration **************/
logic              clk_n;
logic              rst;
logic              regwrite;
logic  [ADDR-1:0]  rs1addr;
logic  [ADDR-1:0]  rs2addr;
logic  [WIDTH-1:0] rddata;
logic  [ADDR-1:0]  rdaddr;
logic  [WIDTH-1:0] rs1data;
logic  [WIDTH-1:0] rs2data; 

integer       i;

  /** Clock Generation Block **/
  initial begin : proc_clock
    clk_n = 1'b1;
    forever begin
      #HALF_PERIOD clk_n = ~clk_n;
    end
  end
initial
begin
Reset();
  // writing checking
regwrite='b1;
rddata= 'b111;
rdaddr='b101;

#CLK_PERIOD
for(i=0;i<DEPTH;i=i+1) // check that only the address 101 is written in it
  begin
    $display("Register %d: %d",i,dut.rf[i]); 
  end
      CheckEquality("Register Write", rddata, dut.rf[rdaddr]);
      CheckEquality("Register SP intialization", 'h000000007ffffff0, dut.rf[2]); //checking SP intialization
   
   regwrite='b0;
   rdaddr='b111;
    
    #CLK_PERIOD
  CheckEquality("Register Write & regwrite=0", 0, dut.rf[rdaddr]);  
    regwrite='b1;  
    
    
#CLK_PERIOD
for(i=0;i<DEPTH;i=i+1) // check that every address can be written in
  begin
    rdaddr = i;
    rddata= i;
    #CLK_PERIOD
    $display("Register %d: %d",i,dut.rf[i]); 
    CheckEquality("Register", rddata, dut.rf[rdaddr]);
  end
    #CLK_PERIOD
    rdaddr = 0;  // check that Register 0 cant be written in
    rddata= 'b10101010;
    #CLK_PERIOD
    CheckEquality("Register 0", 0, dut.rf[0]);
    $display("Register 0 %d",dut.rf[0]); 
    
    //Reading Checking
    rs2addr = 'b101;
    rs1addr = 'b1111;
    regwrite = 'b1;
    #CLK_PERIOD
for(i=0;i<DEPTH;i=i+1) // check that every rs1 address can be read succsfully
  begin
    rs1addr = i;
    #CLK_PERIOD
    $display("Register %d: %d",i,dut.rf[i]); 
    CheckEquality("Register", rs1data, dut.rf[rs1addr]);    
  end 
      #CLK_PERIOD
for(i=0;i<DEPTH;i=i+1) // check that every rs2 address can be read succsfully
  begin
    rs2addr = i;
    #CLK_PERIOD
    $display("Register %d: %d",i,dut.rf[i]); 
    CheckEquality("Read Register", rs2data, dut.rf[rs2addr]);    
  end 
  
  // checking reading register zero 
  rs2addr = 0;
  rs1addr = 0;
  #CLK_PERIOD
  CheckEquality("Read Rs1 Register 0", rs1data, 0);
  CheckEquality("Read Rs2 Register 0", rs2data, 0);
  // checking writting and reading at the same time at same register
   rs1addr = 'b111;
   rdaddr = 'b111;
   regwrite=1'b1;
   rddata = 'b1111;
   #CLK_PERIOD
  CheckEquality("write then read same register", rddata, rs1data);
   
  
#100  
$stop;
 end


/******************** Tasks & Functions *******************/
task CheckEquality(string signal_name, logic [WIDTH-1:0] A, logic [WIDTH-1:0] B);
    if (A === B)
      begin
      $display("%s Success", signal_name);
      end
    else
      begin
      $display("%s Failure", signal_name);
      end
endtask

task Reset();
 #CLK_PERIOD
 rst=1'b1;
 #CLK_PERIOD
 rst=1'b0;
endtask

riscv_rf dut( 
    .i_riscv_rf_clk_n(clk_n),
    .i_riscv_rf_regwrite(regwrite),
    .i_riscv_rf_rs1addr(rs1addr),
    .i_riscv_rf_rs2addr(rs2addr),
    .o_riscv_rf_rs1data(rs1data),
    .o_riscv_rf_rs2data(rs2data),
    .i_riscv_rf_rddata(rddata),
    .i_riscv_rf_rst(rst),
    .i_riscv_rf_rdaddr(rdaddr)
); 
endmodule





