module riscv_dcache_data #(
    parameter INDEX       = 12,
    parameter DWIDTH      = 128,
    parameter CACHE_DEPTH = 4096,
    parameter BYTE_OFFSET = 4
  )
  (
    input   logic                    clk                     ,     
    input   logic                    wren                    ,
    input   logic                    rden                    ,
    input   logic [INDEX-1:0]        index                   ,
    input   logic [3:0]              byte_offset             , 
    input   logic [1:0]              storesrc                ,
    input   logic                    mem_in                  ,
    input   logic [DWIDTH-1:0]       data_in                 ,
    output  logic [DWIDTH-1:0]       data_out                

  );

  logic [DWIDTH-1:0] dcache [0:CACHE_DEPTH-1];
  logic [(DWIDTH/2)-1:0] strdouble;

  assign strdouble = data_in[(DWIDTH/2)-1:0];

  always_ff @(negedge clk) begin
    if(wren && !rden) begin
      if(mem_in)
        dcache[index] <= data_in;
      else begin
        case(storesrc)
          2'b00:begin/// 16 case for each byte 
           case (byte_offset)
             4'b0000:dcache[index][7:0]     <=strdouble[7:0];
             4'b0001:dcache[index][15:8]    <=strdouble[7:0];
             4'b0010:dcache[index][23:16]   <=strdouble[7:0];
             4'b0011:dcache[index][31:24]   <=strdouble[7:0];
             4'b0100:dcache[index][39:32]   <=strdouble[7:0];
             4'b0101:dcache[index][47:40]   <=strdouble[7:0];
             4'b0110:dcache[index][55:48]   <=strdouble[7:0];
             4'b0111:dcache[index][63:56]   <=strdouble[7:0];
             4'b1000:dcache[index][71:64]   <=strdouble[7:0];
             4'b1001:dcache[index][79:72]   <=strdouble[7:0];
             4'b1010:dcache[index][87:80]   <=strdouble[7:0];
             4'b1011:dcache[index][95:88]   <=strdouble[7:0];
             4'b1100:dcache[index][103:96]  <=strdouble[7:0];
             4'b1101:dcache[index][111:104] <=strdouble[7:0];
             4'b1110:dcache[index][119:112] <=strdouble[7:0];
             4'b1111:dcache[index][127:120] <=strdouble[7:0]; 
           endcase
          end
          2'b01:begin// 8 cases for half word access 
           case (byte_offset[3:1])  
             3'b000:dcache[index][15:0]    <=strdouble[15:0];
             3'b001:dcache[index][31:16]   <=strdouble[15:0];
             3'b010:dcache[index][47:32]   <=strdouble[15:0];
             3'b011:dcache[index][63:48]   <=strdouble[15:0];
             3'b100:dcache[index][79:64]   <=strdouble[15:0];
             3'b101:dcache[index][95:80]   <=strdouble[15:0];
             3'b110:dcache[index][111:96]  <=strdouble[15:0];
             3'b111:dcache[index][127:112] <=strdouble[15:0];
          endcase
          end
          2'b10:begin// 4 cases for word access
          case (byte_offset[3:2])  
            2'b00:dcache[index][31:0]   <=strdouble[31:0];
            2'b01:dcache[index][63:32]  <=strdouble[31:0];
            2'b10:dcache[index][95:64]  <=strdouble[31:0];
            2'b11:dcache[index][127:96] <=strdouble[31:0];
          endcase
          end      
          2'b11:begin// 2 cases for double word access
          case (byte_offset[3])  
            1'b0:dcache[index][63:0]   <=strdouble[63:0];
            1'b1:dcache[index][127:64] <=strdouble[63:0];
          endcase
          end                
        
        endcase

      
      end

    end
  end
  
  assign data_out = dcache[index];

endmodule