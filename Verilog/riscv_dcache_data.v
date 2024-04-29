(* ram_style = "block" *)
module riscv_dcache_data #(
    parameter INDEX       = 12,
    parameter DWIDTH      = 128,
    parameter CACHE_DEPTH = 4096,
    parameter BYTE_OFFSET = 4
  )
  (
    input   wire                    clk          , //  negative edge clock signal
    input   wire                    wren         , //  cache write enable
    input   wire                    rden         , //  cache read enable
    input   wire [INDEX-1:0]        index        , //  input index
    input   wire [3:0]              byte_offset  , //  input byte offset to determine the storing position
    input   wire [1:0]              storesrc     , //  input storesrc to determine the type of store
    input   wire                    mem_in       , //  input signal to decide the data coming from CPU or DRAM
    input   wire [DWIDTH-1:0]       data_in      , //  input data bus
    output  wire [DWIDTH-1:0]       data_out       //  output data bus
  );

  // for loop variable
  integer i;

  // input data buffer
  wire [63:0] data_buffer;

  // distribute the input data along the buffer to assure correct storing
  assign data_buffer = (storesrc == 2'b00)? {8{data_in[7:0]}} : 
                       (storesrc == 2'b01)? {4{data_in[15:0]}}:
                       (storesrc == 2'b10)? {2{data_in[31:0]}}:
                       (storesrc == 2'b11)? data_in[63:0]     : 'b0;

  // accessing byte flags declaration
  wire byte0_flag,   byte1_flag,   byte2_flag,   byte3_flag,
        byte4_flag,   byte5_flag,   byte6_flag,   byte7_flag,
        byte8_flag,   byte9_flag,   byte10_flag,  byte11_flag,
        byte12_flag,  byte13_flag,  byte14_flag,  byte15_flag;

  // output data retrieving
  reg [7:0] byte0_out,  byte1_out,  byte2_out,  byte3_out,
              byte4_out,  byte5_out,  byte6_out,  byte7_out,
              byte8_out,  byte9_out,  byte10_out, byte11_out,
              byte12_out, byte13_out, byte14_out, byte15_out;

  // Block RAM of 16 bytes per block
  reg [7:0] byte0  [0:CACHE_DEPTH-1];
  reg [7:0] byte1  [0:CACHE_DEPTH-1];
  reg [7:0] byte2  [0:CACHE_DEPTH-1];
  reg [7:0] byte3  [0:CACHE_DEPTH-1];
  reg [7:0] byte4  [0:CACHE_DEPTH-1];
  reg [7:0] byte5  [0:CACHE_DEPTH-1];
  reg [7:0] byte6  [0:CACHE_DEPTH-1];
  reg [7:0] byte7  [0:CACHE_DEPTH-1];
  reg [7:0] byte8  [0:CACHE_DEPTH-1];
  reg [7:0] byte9  [0:CACHE_DEPTH-1];
  reg [7:0] byte10 [0:CACHE_DEPTH-1];
  reg [7:0] byte11 [0:CACHE_DEPTH-1];
  reg [7:0] byte12 [0:CACHE_DEPTH-1];
  reg [7:0] byte13 [0:CACHE_DEPTH-1];
  reg [7:0] byte14 [0:CACHE_DEPTH-1];
  reg [7:0] byte15 [0:CACHE_DEPTH-1];

  // initialize the cache with zeroes
  initial begin
    for(i=0; i<CACHE_DEPTH; i++) begin
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

  // negative edge synchronous write
  always @(negedge clk) begin
    if(wren && !rden) begin
      if(mem_in) begin
        byte0[index]  <= data_in[7:0];
        byte1[index]  <= data_in[15:8];
        byte2[index]  <= data_in[23:16];
        byte3[index]  <= data_in[31:24];
        byte4[index]  <= data_in[39:32];
        byte5[index]  <= data_in[47:40];
        byte6[index]  <= data_in[55:48];
        byte7[index]  <= data_in[63:56];
        byte8[index]  <= data_in[71:64];
        byte9[index]  <= data_in[79:72];
        byte10[index] <= data_in[87:80];
        byte11[index] <= data_in[95:88];
        byte12[index] <= data_in[103:96];
        byte13[index] <= data_in[111:104];
        byte14[index] <= data_in[119:112];
        byte15[index] <= data_in[127:120];
      end
      else
        if(byte0_flag)
          byte0[index]  <= data_buffer[7:0];
        if(byte1_flag)                  
          byte1[index]  <= data_buffer[15:8];
        if(byte2_flag)                  
          byte2[index]  <= data_buffer[23:16];
        if(byte3_flag)                  
          byte3[index]  <= data_buffer[31:24];
        if(byte4_flag)                  
          byte4[index]  <= data_buffer[39:32];
        if(byte5_flag)                  
          byte5[index]  <= data_buffer[47:40];
        if(byte6_flag)                   
          byte6[index]  <= data_buffer[55:48];
        if(byte7_flag)                  
          byte7[index]  <= data_buffer[63:56];
        if(byte8_flag)                  
          byte8[index]  <= data_buffer[7:0];
        if(byte9_flag)                  
          byte9[index]  <= data_buffer[15:8];
        if(byte10_flag)                  
          byte10[index] <= data_buffer[23:16];
        if(byte11_flag)                  
          byte11[index] <= data_buffer[31:24];
        if(byte12_flag)                  
          byte12[index] <= data_buffer[39:32];
        if(byte13_flag)                  
          byte13[index] <= data_buffer[47:40];
        if(byte14_flag)                  
          byte14[index] <= data_buffer[55:48];
        if(byte15_flag)                  
          byte15[index] <= data_buffer[63:56];
    end
  end
  
  // negative edge synchronous read
  always @(negedge clk) begin
    byte0_out   <= byte0[index];
    byte1_out   <= byte1[index];
    byte2_out   <= byte2[index];
    byte3_out   <= byte3[index];
    byte4_out   <= byte4[index];
    byte5_out   <= byte5[index];
    byte6_out   <= byte6[index];
    byte7_out   <= byte7[index];
    byte8_out   <= byte8[index];
    byte9_out   <= byte9[index];
    byte10_out  <= byte10[index];
    byte11_out  <= byte11[index];
    byte12_out  <= byte12[index];
    byte13_out  <= byte13[index];
    byte14_out  <= byte14[index];
    byte15_out  <= byte15[index];
  end

  // output data
  assign data_out = { byte15_out, byte14_out, byte13_out, byte12_out,
                      byte11_out, byte10_out, byte9_out,  byte8_out,
                      byte7_out,  byte6_out,  byte5_out,  byte4_out,
                      byte3_out,  byte2_out,  byte1_out,  byte0_out };

  // bytes enable flags
  assign byte0_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0000))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b000))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b00))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte1_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0001))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b000))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b00))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte2_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0010))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b001))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b00))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte3_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0011))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b001))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b00))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte4_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0100))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b010))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b01))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte5_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0101))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b010))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b01))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte6_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0110))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b011))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b01))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte7_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b0111))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b011))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b01))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b0))   ) && (wren && !mem_in));

          
  assign byte8_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1000))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b100))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b10))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte9_flag  = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1001))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b100))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b10))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte10_flag = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1010))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b101))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b10))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte11_flag = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1011))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b101))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b10))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte12_flag = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1100))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b110))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b11))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte13_flag = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1101))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b110))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b11))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte14_flag = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1110))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b111))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b11))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

          
  assign byte15_flag = (( ((storesrc == 2'b00) && (byte_offset      == 4'b1111))  ||
                          ((storesrc == 2'b01) && (byte_offset[3:1] == 3'b111))   ||
                          ((storesrc == 2'b10) && (byte_offset[3:2] == 2'b11))    ||
                          ((storesrc == 2'b11) && (byte_offset[3]   == 1'b1))   ) && (wren && !mem_in));

endmodule