module dram #(
    parameter AWIDTH  = 23,
    parameter DWIDTH  = 128,
    parameter MEM_DEPTH = 128 * (2**20)
  )
  (
    input   logic                   clk                     ,
    input   logic                   wren                    ,
    input   logic                   rden                    ,
    input   logic [AWIDTH-1:0]      addr                    ,
    input   logic [DWIDTH-1:0]      data_in                 ,
    output  logic [DWIDTH-1:0]      data_out                ,
    output  logic                   mem_ready
  );

  logic [(AWIDTH+4)-1:0] base_addr;
  logic [7:0] mem [0:MEM_DEPTH-1];
  logic [1:0] counter;

  int i;

  // initialize the memory
  initial begin
    for(i=0;i<MEM_DEPTH;i++)
      mem[i] <= 'b0;
      //$readmemh("hex_data.txt",mem);
  end

  // mapping the byte addressable memory into block cache
  assign base_addr = {addr,4'b0000};

  // counter to model latency
  always_ff @(posedge clk) begin
    if((wren || rden) && !(counter == 2'b11)) begin
      counter   <= counter + 1'b1;
      mem_ready <= 1'b0;
    end
    else if(counter == 2'b11) begin
      counter   <= 2'b0;
      mem_ready <= 1'b1;
    end
    else begin
      counter   <= 2'b0;
      mem_ready <= 1'b0;
    end
  end

  // write and read technique
  always_ff @(posedge clk) begin
    if(wren && !rden) begin
        mem[base_addr+'d0]  <= data_in[7:0];
        mem[base_addr+'d1]  <= data_in[15:8];
        mem[base_addr+'d2]  <= data_in[23:16];
        mem[base_addr+'d3]  <= data_in[31:24];
        mem[base_addr+'d4]  <= data_in[39:32];
        mem[base_addr+'d5]  <= data_in[47:40];
        mem[base_addr+'d6]  <= data_in[55:48];
        mem[base_addr+'d7]  <= data_in[63:56];
        mem[base_addr+'d8]  <= data_in[71:64];
        mem[base_addr+'d9]  <= data_in[79:72];
        mem[base_addr+'d10] <= data_in[87:80];
        mem[base_addr+'d11] <= data_in[95:88];
        mem[base_addr+'d12] <= data_in[103:96];
        mem[base_addr+'d13] <= data_in[111:104];
        mem[base_addr+'d14] <= data_in[119:112];
        mem[base_addr+'d15] <= data_in[127:120];
    end
    else if(rden && !wren) begin
        data_out[7:0]       <= mem[base_addr+'d0];
        data_out[15:8]      <= mem[base_addr+'d1];
        data_out[23:16]     <= mem[base_addr+'d2];
        data_out[31:24]     <= mem[base_addr+'d3];
        data_out[39:32]     <= mem[base_addr+'d4];
        data_out[47:40]     <= mem[base_addr+'d5];
        data_out[55:48]     <= mem[base_addr+'d6];
        data_out[63:56]     <= mem[base_addr+'d7];
        data_out[71:64]     <= mem[base_addr+'d8];
        data_out[79:72]     <= mem[base_addr+'d9];
        data_out[87:80]     <= mem[base_addr+'d10];
        data_out[95:88]     <= mem[base_addr+'d11];
        data_out[103:96]    <= mem[base_addr+'d12];
        data_out[111:104]   <= mem[base_addr+'d13];
        data_out[119:112]   <= mem[base_addr+'d14];
        data_out[127:120]   <= mem[base_addr+'d15];
    end
  end

endmodule