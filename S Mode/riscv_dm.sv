  module riscv_dm (
    input  logic         i_riscv_dm_clk_n,
    input  logic         i_riscv_dm_rst, 
    input  logic         i_riscv_dm_wen,
    input  logic  [1:0]  i_riscv_dm_sel,
    input  logic  [63:0] i_riscv_dm_wdata,
    input  logic  [63:0] i_riscv_dm_waddr,
    output logic  [63:0] o_riscv_dm_rdata
  );
  parameter MEM_SIZE = 64 ;
  logic [7:0]  dmemo [0:MEM_SIZE-1];//the the byte address bus is 64 bit and the width of of each memory location is 1 byte 
  logic [63:0] byte0_addr;
  logic [63:0] byte1_addr;
  logic [63:0] byte2_addr;
  logic [63:0] byte3_addr;
  logic [63:0] byte4_addr;    ////// holding the address of each byte of a double word input/output.
  logic [63:0] byte5_addr;
  logic [63:0] byte6_addr;
  logic [63:0] byte7_addr;
  integer i;
  
  always_comb 
    begin:byte_address_proc
       byte0_addr=i_riscv_dm_waddr;
       byte1_addr=i_riscv_dm_waddr+'b001;
       byte2_addr=i_riscv_dm_waddr+'b010;
       byte3_addr=i_riscv_dm_waddr+'b011;
       byte4_addr=i_riscv_dm_waddr+'b100;
       byte5_addr=i_riscv_dm_waddr+'b101;
       byte6_addr=i_riscv_dm_waddr+'b110;
       byte7_addr=i_riscv_dm_waddr+'b111;
    end
  
  always_comb
    begin:read_proc
      o_riscv_dm_rdata={dmemo[byte7_addr],dmemo[byte6_addr],dmemo[byte5_addr],dmemo[byte4_addr],dmemo[byte3_addr],dmemo[byte2_addr],dmemo[byte1_addr],dmemo[byte0_addr]};
    end
  
  always_ff@(posedge i_riscv_dm_rst or negedge i_riscv_dm_clk_n)  
    begin:write_proc
      if(i_riscv_dm_rst)
        begin
          for (i=0; i<MEM_SIZE; i=i+1)
            dmemo[i]<=8'b0;
        end
      else if (i_riscv_dm_wen) 
        begin
          case(i_riscv_dm_sel)
            2'b00:dmemo[byte0_addr]<=i_riscv_dm_wdata[7:0];//to store single byte
            2'b01:begin
                    dmemo[byte0_addr]<=i_riscv_dm_wdata[7:0];//to store 2 bytes 
                    dmemo[byte1_addr]<=i_riscv_dm_wdata[15:8];
                  end 
            2'b10:begin
                    dmemo[byte0_addr]<=i_riscv_dm_wdata[7:0];
                    dmemo[byte1_addr]<=i_riscv_dm_wdata[15:8];
                    dmemo[byte2_addr]<=i_riscv_dm_wdata[23:16];//to store 4 bytes (single word) 
                    dmemo[byte3_addr]<=i_riscv_dm_wdata[31:24];
                  end         
            2'b11:begin
                    dmemo[byte0_addr]<=i_riscv_dm_wdata[7:0];
                    dmemo[byte1_addr]<=i_riscv_dm_wdata[15:8];
                    dmemo[byte2_addr]<=i_riscv_dm_wdata[23:16];
                    dmemo[byte3_addr]<=i_riscv_dm_wdata[31:24];
                    dmemo[byte4_addr]<=i_riscv_dm_wdata[39:32];//to store 8 bytes (double word)
                    dmemo[byte5_addr]<=i_riscv_dm_wdata[47:40];
                    dmemo[byte6_addr]<=i_riscv_dm_wdata[55:48];
                    dmemo[byte7_addr]<=i_riscv_dm_wdata[63:56];
                  end                               
          endcase
        end 
      else; 
    end
  endmodule

       
        
