//documentation
// the whole block is read cobinationally and same for the block after the indexed one and the output 32_bit instruction is determinded by 
//--the byte offset and missalignment at top module
//index_sel=0: the block is written at the real index
//index_sel=1: the block is written at the following index for missalignment
(* ram_style = "block" *)
module riscv_icache_inst #(
    parameter INDEX       = 12,
    parameter DWIDTH      = 128,
    parameter IWIDTH      = 32,
    parameter CACHE_DEPTH = 4096,
    parameter BYTE_OFFSET = 4
  )
  (
    input   logic                    clk              , 
    input   logic                    wren             , //  input from ram
    input   logic                    rden             , //  for cpu out
    input   logic                    index_sel        , //  used to identify the written block from ram to cache is the addressed one or the one after it for alignment
    input   logic [INDEX-1:0]        index            , 
    input   logic [INDEX-1:0]        index_missallign , //  index of the following block (used for missalignment)
    input   logic [DWIDTH-1:0]       data_in          , 
    output  logic [DWIDTH-1:0]       data_out         , //  total block and word selection done in top module 
    output  logic [DWIDTH-1:0]       data_out_align     //  the block of the following index (used for missalignment)  
  );
  
  // select which index to use to be synthesizable
  logic [INDEX-1:0] which_index;

  assign which_index = (index_sel)? index_missallign:index;

  // Block RAM of 16 bytes per block
  logic [7:0] byte0  [0:CACHE_DEPTH-1];
  logic [7:0] byte1  [0:CACHE_DEPTH-1];
  logic [7:0] byte2  [0:CACHE_DEPTH-1];
  logic [7:0] byte3  [0:CACHE_DEPTH-1];
  logic [7:0] byte4  [0:CACHE_DEPTH-1];
  logic [7:0] byte5  [0:CACHE_DEPTH-1];
  logic [7:0] byte6  [0:CACHE_DEPTH-1];
  logic [7:0] byte7  [0:CACHE_DEPTH-1];
  logic [7:0] byte8  [0:CACHE_DEPTH-1];
  logic [7:0] byte9  [0:CACHE_DEPTH-1];
  logic [7:0] byte10 [0:CACHE_DEPTH-1];
  logic [7:0] byte11 [0:CACHE_DEPTH-1];
  logic [7:0] byte12 [0:CACHE_DEPTH-1];
  logic [7:0] byte13 [0:CACHE_DEPTH-1];
  logic [7:0] byte14 [0:CACHE_DEPTH-1];
  logic [7:0] byte15 [0:CACHE_DEPTH-1];

  // output aligned data buffer
  logic [7:0] byte0_out,  byte1_out,  byte2_out,  byte3_out,
              byte4_out,  byte5_out,  byte6_out,  byte7_out,
              byte8_out,  byte9_out,  byte10_out, byte11_out,
              byte12_out, byte13_out, byte14_out, byte15_out;

  // output misaligned data buffer
  logic [7:0] byte0_out_mis,  byte1_out_mis,  byte2_out_mis,  byte3_out_mis,
              byte4_out_mis,  byte5_out_mis,  byte6_out_mis,  byte7_out_mis,
              byte8_out_mis,  byte9_out_mis,  byte10_out_mis, byte11_out_mis,
              byte12_out_mis, byte13_out_mis, byte14_out_mis, byte15_out_mis;

  // negative edge synchronous write
  always_ff @(negedge clk) begin
    if(wren) begin
        byte0[which_index]  <=  data_in[7:0];
        byte1[which_index]  <=  data_in[15:8];
        byte2[which_index]  <=  data_in[23:16];
        byte3[which_index]  <=  data_in[31:24];
        byte4[which_index]  <=  data_in[39:32];
        byte5[which_index]  <=  data_in[47:40];
        byte6[which_index]  <=  data_in[55:48];
        byte7[which_index]  <=  data_in[63:56];
        byte8[which_index]  <=  data_in[71:64];
        byte9[which_index]  <=  data_in[79:72];
        byte10[which_index] <=  data_in[87:80];
        byte11[which_index] <=  data_in[95:88];
        byte12[which_index] <=  data_in[103:96];
        byte13[which_index] <=  data_in[111:104];
        byte14[which_index] <=  data_in[119:112];
        byte15[which_index] <=  data_in[127:120];
    end
  end
  
  // negative edge synchronous read for aligned data
  always_ff @(negedge clk) begin
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

  // negative edge synchronous read for misaligned data
  always_ff @(negedge clk) begin
    byte0_out_mis   <= byte0[index_missallign];
    byte1_out_mis   <= byte1[index_missallign];
    byte2_out_mis   <= byte2[index_missallign];
    byte3_out_mis   <= byte3[index_missallign];
    byte4_out_mis   <= byte4[index_missallign];
    byte5_out_mis   <= byte5[index_missallign];
    byte6_out_mis   <= byte6[index_missallign];
    byte7_out_mis   <= byte7[index_missallign];
    byte8_out_mis   <= byte8[index_missallign];
    byte9_out_mis   <= byte9[index_missallign];
    byte10_out_mis  <= byte10[index_missallign];
    byte11_out_mis  <= byte11[index_missallign];
    byte12_out_mis  <= byte12[index_missallign];
    byte13_out_mis  <= byte13[index_missallign];
    byte14_out_mis  <= byte14[index_missallign];
    byte15_out_mis  <= byte15[index_missallign];
  end

  // output aligned data
  assign data_out = { byte15_out, byte14_out, byte13_out, byte12_out,
                      byte11_out, byte10_out, byte9_out,  byte8_out,
                      byte7_out,  byte6_out,  byte5_out,  byte4_out,
                      byte3_out,  byte2_out,  byte1_out,  byte0_out };

  // output misaligned data
  assign data_out_align = { byte15_out_mis, byte14_out_mis, byte13_out_mis, byte12_out_mis,
                            byte11_out_mis, byte10_out_mis, byte9_out_mis,  byte8_out_mis,
                            byte7_out_mis,  byte6_out_mis,  byte5_out_mis,  byte4_out_mis,
                            byte3_out_mis,  byte2_out_mis,  byte1_out_mis,  byte0_out_mis };
endmodule