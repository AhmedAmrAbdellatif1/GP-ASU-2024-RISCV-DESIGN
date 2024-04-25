(* ram_style = "block" *)
module riscv_dram_data
  #(  
    parameter DATA_WIDTH  = 128                     ,
    parameter CACHE_SIZE  = 4*(2**10)               ,   //64 * (2**10)   
    parameter MEM_SIZE    = 4*(2**10)               ,   //128*(2**20) 
    parameter DATAPBLOCK  = 16                      ,
    parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK   ,   //  4096
    parameter ADDR        = $clog2(MEM_SIZE)        ,   //    27 bits
    parameter BYTE_OFF    = $clog2(DATAPBLOCK)      ,   //     4 bits
    parameter INDEX       = $clog2(CACHE_DEPTH)     ,   //    12 bits
    parameter TAG         = ADDR - BYTE_OFF - INDEX ,   //    11 bits
    parameter S_ADDR      = ADDR - BYTE_OFF    
  )
  (
    input   logic                   clk       ,
    input   logic                   wren      ,
    input   logic                   rden      ,
    input   logic [S_ADDR-1:0]      addr      ,
    input   logic [DATA_WIDTH-1:0]  data_in   ,
    output  logic [DATA_WIDTH-1:0]  data_out  
  );

  // for loop variable
  integer i;

  // mapping the byte addressable memory into block cache
  assign base_addr = {addr,4'b0000};

  // accessing byte flags declaration
  logic byte0_flag,   byte1_flag,   byte2_flag,   byte3_flag,
        byte4_flag,   byte5_flag,   byte6_flag,   byte7_flag,
        byte8_flag,   byte9_flag,   byte10_flag,  byte11_flag,
        byte12_flag,  byte13_flag,  byte14_flag,  byte15_flag;

  // output data retrieving
  logic [7:0] byte0_out,  byte1_out,  byte2_out,  byte3_out,
              byte4_out,  byte5_out,  byte6_out,  byte7_out,
              byte8_out,  byte9_out,  byte10_out, byte11_out,
              byte12_out, byte13_out, byte14_out, byte15_out;

  // Block RAM of 16 bytes per block
  logic [7:0] byte0  [0:MEM_SIZE-1];
  logic [7:0] byte1  [0:MEM_SIZE-1];
  logic [7:0] byte2  [0:MEM_SIZE-1];
  logic [7:0] byte3  [0:MEM_SIZE-1];
  logic [7:0] byte4  [0:MEM_SIZE-1];
  logic [7:0] byte5  [0:MEM_SIZE-1];
  logic [7:0] byte6  [0:MEM_SIZE-1];
  logic [7:0] byte7  [0:MEM_SIZE-1];
  logic [7:0] byte8  [0:MEM_SIZE-1];
  logic [7:0] byte9  [0:MEM_SIZE-1];
  logic [7:0] byte10 [0:MEM_SIZE-1];
  logic [7:0] byte11 [0:MEM_SIZE-1];
  logic [7:0] byte12 [0:MEM_SIZE-1];
  logic [7:0] byte13 [0:MEM_SIZE-1];
  logic [7:0] byte14 [0:MEM_SIZE-1];
  logic [7:0] byte15 [0:MEM_SIZE-1];

  // initialize the cache with zeroes
  initial begin
    for(i=0; i<MEM_SIZE; i++) begin
      byte0 [i] = 'b0;
      byte1 [i] = 'b0;
      byte2 [i] = 'b0;
      byte3 [i] = 'b0;
      byte4 [i] = 'b0;
      byte5 [i] = 'b0;
      byte6 [i] = 'b0;
      byte7 [i] = 'b0;
      byte8 [i] = 'b0;
      byte9 [i] = 'b0;
      byte10[i] = 'b0;
      byte11[i] = 'b0;
      byte12[i] = 'b0;
      byte13[i] = 'b0;
      byte14[i] = 'b0;
      byte15[i] = 'b0;  
    end
  end

  // posedge edge synchronous write
  always_ff @(posedge clk) begin
    if(wren && !rden) begin
      byte0[base_addr]  <= data_in[7:0];
      byte1[base_addr]  <= data_in[15:8];
      byte2[base_addr]  <= data_in[23:16];
      byte3[base_addr]  <= data_in[31:24];
      byte4[base_addr]  <= data_in[39:32];
      byte5[base_addr]  <= data_in[47:40];
      byte6[base_addr]  <= data_in[55:48];
      byte7[base_addr]  <= data_in[63:56];
      byte8[base_addr]  <= data_in[71:64];
      byte9[base_addr]  <= data_in[79:72];
      byte10[base_addr] <= data_in[87:80];
      byte11[base_addr] <= data_in[95:88];
      byte12[base_addr] <= data_in[103:96];
      byte13[base_addr] <= data_in[111:104];
      byte14[base_addr] <= data_in[119:112];
      byte15[base_addr] <= data_in[127:120];
    end
  end
  
  // posedge edge synchronous read
  always_ff @(posedge clk) begin
    byte0_out   <= byte0[base_addr];
    byte1_out   <= byte1[base_addr];
    byte2_out   <= byte2[base_addr];
    byte3_out   <= byte3[base_addr];
    byte4_out   <= byte4[base_addr];
    byte5_out   <= byte5[base_addr];
    byte6_out   <= byte6[base_addr];
    byte7_out   <= byte7[base_addr];
    byte8_out   <= byte8[base_addr];
    byte9_out   <= byte9[base_addr];
    byte10_out  <= byte10[base_addr];
    byte11_out  <= byte11[base_addr];
    byte12_out  <= byte12[base_addr];
    byte13_out  <= byte13[base_addr];
    byte14_out  <= byte14[base_addr];
    byte15_out  <= byte15[base_addr];
  end

  // output data
  assign data_out = { byte15_out, byte14_out, byte13_out, byte12_out,
                      byte11_out, byte10_out, byte9_out,  byte8_out,
                      byte7_out,  byte6_out,  byte5_out,  byte4_out,
                      byte3_out,  byte2_out,  byte1_out,  byte0_out };

endmodule