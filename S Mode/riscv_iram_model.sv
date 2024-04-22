module riscv_iram_model 
  import my_pkg::*;
  (
    input   logic               clk       ,
    input   logic               rden      ,
    input   logic [S_ADDR-1:0]  addr      ,
    input   logic [DATA_WIDTH-1:0]  data_in   ,
    output  logic [DATA_WIDTH-1:0]  data_out  ,
    output  logic               mem_ready 
  );

  logic [(S_ADDR+4)-1:0] base_addr;
  logic [7:0] mem [0:MEM_SIZE-1];
  logic [1:0] counter;

  int i;

  // initialize the memory
  initial
  begin
    $readmemh("instructions.txt",mem);
  end

  // mapping the byte addressable memory into block cache
  assign base_addr = {addr,4'b0000};

  // counter to model latency
  always_ff @(posedge clk)
  begin
    if((rden) && !(counter == 2'b11))
    begin
      counter   <= counter + 1'b1;
      mem_ready <= 1'b0;
    end
    else if(counter == 2'b11)
    begin
      counter   <= 2'b0;
      mem_ready <= 1'b1;
    end
    else
    begin
      counter   <= 2'b0;
      mem_ready <= 1'b0;
    end
  end

  // write and read technique
  always_ff @(posedge clk)
  begin
    if(rden)
    begin
      data_out[7:0]     <= mem[base_addr+'d0];
      data_out[15:8]    <= mem[base_addr+'d1];
      data_out[23:16]   <= mem[base_addr+'d2];
      data_out[31:24]   <= mem[base_addr+'d3];
      data_out[39:32]   <= mem[base_addr+'d4];
      data_out[47:40]   <= mem[base_addr+'d5];
      data_out[55:48]   <= mem[base_addr+'d6];
      data_out[63:56]   <= mem[base_addr+'d7];
      data_out[71:64]   <= mem[base_addr+'d8];
      data_out[79:72]   <= mem[base_addr+'d9];
      data_out[87:80]   <= mem[base_addr+'d10];
      data_out[95:88]   <= mem[base_addr+'d11];
      data_out[103:96]  <= mem[base_addr+'d12];
      data_out[111:104] <= mem[base_addr+'d13];
      data_out[119:112] <= mem[base_addr+'d14];
      data_out[127:120] <= mem[base_addr+'d15];
    end
  end

endmodule
