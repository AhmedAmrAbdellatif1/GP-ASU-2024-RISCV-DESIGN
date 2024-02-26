/**********************************************************/
/* Module Name: data_cache                           */
/* Last Modified Date: 24/2/2024                     */
/* By: Rana Mohamed                                  */
/**********************************************************/
`timescale 1ns/1ps

module data_cache_tb();

/*********************** Parameters ***********************/
    parameter CLK_PERIOD  = 50                        ;
    parameter HALF_PERIOD = CLK_PERIOD/2              ;
    parameter DATA_WIDTH  = 128                       ;
    parameter MEM_SIZE    = 2**10                     ;
    parameter CACHE_SIZE  = 2**6                      ;   
    parameter DATAPBLOCK  = 16                        ;
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK     ;   //  4096
    parameter ADDR        = $clog2(MEM_SIZE)          ;   //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)        ;   //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)       ;   //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX   ;   //    11 bits

  integer i;

/************** Internal Signals Declaration **************/
  logic                   clk;
  logic                   rst;
  logic                   cpu_wren;
  logic                   cpu_rden;
  logic [ADDR-1:0]        phys_addr;
  logic [DATA_WIDTH-1:0]  cpu_data_in;
  logic [DATA_WIDTH-1:0]  cpu_data_out;
  logic                   cpu_stall;
 
/********************* Initial Blocks *********************/

 // Clock generation
  initial begin
    clk = 0;
    forever #HALF_PERIOD clk = ~clk;
  end


 // Testbench initialization
  initial begin : proc_testing 
    clk = 'b0 ;
    rst = 'b0 ;
    cpu_wren = 'b0 ;
    cpu_rden = 'b0 ;
    phys_addr = 'b0 ;
    cpu_data_in = 'b0 ;

    #CLK_PERIOD;


  reset_values();
 
  read_cpu  ('d0);		    //read miss , valid = 0 
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD;
  cpu_rden = 'b0 ;
  #CLK_PERIOD;
  
  #CLK_PERIOD;
  read_cpu  ('d0);		    //read hit 

    // Test 1: Read Hit


    // Test 2: Read Miss


    // Test 3: Write Hit
 

    // Test 4: Write Miss



    $stop; // Stop simulation at the end of the testbench
  end
/******************** Tasks & Functions *******************/

task reset_values ();
begin
  clk = 'b1 ;
  rst = 'b1 ;
  cpu_wren = 'b0 ;
  cpu_rden = 'b0 ;
  phys_addr = 'b0 ;
  cpu_data_in = 'b0 ;
  #1  
  rst = 1'b0;
end
endtask

task write_cpu (input [ADDR-1:0]addr, input [DATA_WIDTH-1:0]data);
begin
  #CLK_PERIOD 
  phys_addr = addr; 
  cpu_wren = 'b1; 
  cpu_data_in = data; //write to cache 
  #CLK_PERIOD 
  phys_addr = 'b0 ;
  cpu_wren = 'b0 ;
  cpu_data_in = 'b0 ;
end
endtask

task read_cpu (input [ADDR-1:0]addr);
begin
  #CLK_PERIOD
  phys_addr = addr; 
  cpu_rden = 'b1;  //read from cache
  #CLK_PERIOD 
  phys_addr = 'b0 ;
  cpu_rden = 'b1 ; 
end 
endtask


/******************** DUT Instantiation *******************/

  data_cache DUT
  (
    .clk(clk),
    .rst(rst),
    .cpu_wren(cpu_wren),
    .cpu_rden(cpu_rden),
    .phys_addr(phys_addr),
    .cpu_data_in(cpu_data_in),
    .cpu_data_out(cpu_data_out),
    .cpu_stall(cpu_stall)
  );

endmodule

