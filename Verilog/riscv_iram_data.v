(* rom_style = "block" *)
module riscv_iram_data #(
  parameter DATA_WIDTH  = 128                    ,
  parameter CACHE_SIZE  = 4*(2**10)              , //64 * (2**10)
  parameter MEM_SIZE    = 4*CACHE_SIZE           , //128*(2**20)
  parameter DATAPBLOCK  = 16                     ,
  parameter CACHE_DEPTH = CACHE_SIZE/DATAPBLOCK  , //  4096
  parameter ADDR        = $clog2(MEM_SIZE)       , //    27 bits
  parameter BYTE_OFF    = $clog2(DATAPBLOCK)     , //     4 bits
  parameter INDEX       = $clog2(CACHE_DEPTH)    , //    12 bits
  parameter TAG         = ADDR - BYTE_OFF - INDEX, //    11 bits
  parameter S_ADDR      = 23
) (
  input  wire                  clk     ,
  input  wire                  rden    ,
  input  wire [    S_ADDR-1:0] addr    ,
  output wire [DATA_WIDTH-1:0] data_out
);

  wire [(S_ADDR+4)-1:0] base_addr              ;
  reg  [           7:0] mem      [0:MEM_SIZE-1];

  // initialize the memory
  initial
    begin
      $readmemh("instructions.txt",mem);
    end

  // mapping the byte addressable memory into block cache
  assign base_addr = {addr,4'b0000};

  // output data retrieving
  reg [7:0] byte0_out,  byte1_out,  byte2_out,  byte3_out,
    byte4_out,  byte5_out,  byte6_out,  byte7_out,
      byte8_out,  byte9_out,  byte10_out, byte11_out,
        byte12_out, byte13_out, byte14_out, byte15_out;

  // read technique
  always @(posedge clk)
    begin
      if(rden)
        begin
          byte0_out  <= mem[base_addr+'d0]   ;
          byte1_out  <= mem[base_addr+'d1]   ;
          byte2_out  <= mem[base_addr+'d2]   ;
          byte3_out  <= mem[base_addr+'d3]   ;
          byte4_out  <= mem[base_addr+'d4]   ;
          byte5_out  <= mem[base_addr+'d5]   ;
          byte6_out  <= mem[base_addr+'d6]   ;
          byte7_out  <= mem[base_addr+'d7]   ;
          byte8_out  <= mem[base_addr+'d8]   ;
          byte9_out  <= mem[base_addr+'d9]   ;
          byte10_out <= mem[base_addr+'d10]  ;
          byte11_out <= mem[base_addr+'d11]  ;
          byte12_out <= mem[base_addr+'d12]  ;
          byte13_out <= mem[base_addr+'d13]  ;
          byte14_out <= mem[base_addr+'d14]  ;
          byte15_out <= mem[base_addr+'d15]  ;
        end
    end

  // output data
  assign data_out = { byte15_out, byte14_out, byte13_out, byte12_out,
    byte11_out, byte10_out, byte9_out , byte8_out ,
    byte7_out , byte6_out , byte5_out , byte4_out ,
    byte3_out , byte2_out , byte1_out , byte0_out };

endmodule