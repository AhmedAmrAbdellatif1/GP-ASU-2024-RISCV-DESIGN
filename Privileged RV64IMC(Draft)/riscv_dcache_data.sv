module data_array #(
    parameter INDEX       = 12,
    parameter DWIDTH      = 128,
    parameter CACHE_DEPTH = 4096,
    parameter BYTE_OFFSET = 4
  )
  (
    input   logic                    clk           ,
    input   logic                    wren          ,
    input   logic                    rden          ,
    input   logic [INDEX-1:0]        index         ,
    input   logic [3:0]              byte_offset   ,
    input   logic [1:0]              storesrc      ,
    input   logic [1:0]              loadsrc       ,
    input   logic                    mem_in        ,
    input   logic                    mem_out       ,
    input   logic [DWIDTH-1:0]       data_in       ,
    output  logic [DWIDTH-1:0]       data_out                
  );

  logic [DWIDTH-1:0] dcache [0:CACHE_DEPTH-1];  // data cache array
  logic [(DWIDTH/2)-1:0] strdouble;             // intermediate signal to store the data

  assign strdouble = data_in[(DWIDTH/2)-1:0];   // strdouble is the LSB double-word of the input data

  ///  ************************************  sequential store  ************************************ ///
  always_ff @(negedge clk) begin
    if(wren && !rden) begin // in case of store
      if(mem_in) // in case of allocating data from memory to cache
        dcache[index] <= data_in;
      else begin
        case(storesrc)
          2'b00:begin // sb
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
          2'b01:begin // sh
            case (byte_offset)
              4'b0000:dcache[index][15:0]    <=strdouble[15:0];
              4'b0001:dcache[index][23:8]    <=strdouble[15:0];
              4'b0010:dcache[index][31:16]   <=strdouble[15:0];
              4'b0011:dcache[index][39:24]   <=strdouble[15:0];
              4'b0100:dcache[index][47:32]   <=strdouble[15:0];
              4'b0101:dcache[index][55:40]   <=strdouble[15:0];
              4'b0110:dcache[index][63:48]   <=strdouble[15:0];
              4'b0111:dcache[index][71:56]   <=strdouble[15:0];
              4'b1000:dcache[index][79:64]   <=strdouble[15:0];
              4'b1001:dcache[index][87:72]   <=strdouble[15:0];
              4'b1010:dcache[index][95:80]   <=strdouble[15:0];
              4'b1011:dcache[index][103:88]  <=strdouble[15:0];
              4'b1100:dcache[index][111:96]  <=strdouble[15:0];
              4'b1101:dcache[index][119:104] <=strdouble[15:0];
              4'b1110:dcache[index][127:112] <=strdouble[15:0];

              4'b1111:{dcache[index+1'b1][8:0],dcache[index][127:120]} <=strdouble[15:0]; //<--- Sectioning
            endcase
          end
          2'b10:begin // sw 
            case (byte_offset)
              4'b0000:dcache[index][31:0]    <=strdouble[31:0];
              4'b0001:dcache[index][39:8]    <=strdouble[31:0];
              4'b0010:dcache[index][47:16]   <=strdouble[31:0];
              4'b0011:dcache[index][55:24]   <=strdouble[31:0];
              4'b0100:dcache[index][63:32]   <=strdouble[31:0];
              4'b0101:dcache[index][71:40]   <=strdouble[31:0];
              4'b0110:dcache[index][79:48]   <=strdouble[31:0];
              4'b0111:dcache[index][87:56]   <=strdouble[31:0];
              4'b1000:dcache[index][95:64]   <=strdouble[31:0];
              4'b1001:dcache[index][103:72]  <=strdouble[31:0];
              4'b1010:dcache[index][111:80]  <=strdouble[31:0];
              4'b1011:dcache[index][119:88]  <=strdouble[31:0];
              4'b1100:dcache[index][127:96]  <=strdouble[31:0];

              4'b1101:{dcache[index+1'b1][7:0],dcache[index][127:104]}  <=strdouble[31:0];  //<--- Sectioning
              4'b1110:{dcache[index+1'b1][15:0],dcache[index][127:112]} <=strdouble[31:0]; //<--- Sectioning
              4'b1111:{dcache[index+1'b1][23:0],dcache[index][127:120]} <=strdouble[31:0]; //<--- Sectioning
            endcase
          end      
          2'b11:begin //sd
            case (byte_offset)
              4'b0000:dcache[index][63:0]     <=strdouble;
              4'b0001:dcache[index][71:8]     <=strdouble;
              4'b0010:dcache[index][79:16]    <=strdouble;
              4'b0011:dcache[index][87:24]    <=strdouble;
              4'b0100:dcache[index][95:32]    <=strdouble;
              4'b0101:dcache[index][103:40]   <=strdouble;
              4'b0110:dcache[index][111:48]   <=strdouble;
              4'b0111:dcache[index][119:56]   <=strdouble;
              4'b1000:dcache[index][127:64]   <=strdouble;

              4'b1001:{dcache[index+1'b1][7:0],dcache[index][127:72]}   <=strdouble; //<--- Sectioning
              4'b1010:{dcache[index+1'b1][15:0],dcache[index][127:80]}  <=strdouble; //<--- Sectioning
              4'b1011:{dcache[index+1'b1][23:0],dcache[index][127:88]}  <=strdouble; //<--- Sectioning 
              4'b1100:{dcache[index+1'b1][31:0],dcache[index][127:96]}  <=strdouble; //<--- Sectioning
              4'b1101:{dcache[index+1'b1][39:0],dcache[index][127:104]} <=strdouble; //<--- Sectioning
              4'b1110:{dcache[index+1'b1][47:0],dcache[index][127:112]} <=strdouble; //<--- Sectioning
              4'b1111:{dcache[index+1'b1][55:0],dcache[index][127:120]} <=strdouble; //<--- Sectioning
            endcase
          end                
        endcase      
      end
    end
  end
  ///  ************************************  combinational load  ************************************ ///
  always_comb begin
      if(rden && !wren) begin
        if(mem_out) begin
          data_out = dcache[index];
        end
        else begin
          case(loadsrc)
            2'b00:begin // lb/lbu
              case (byte_offset)
                4'b0000:data_out = dcache[index][7:0]     ;
                4'b0001:data_out = dcache[index][15:8]    ;
                4'b0010:data_out = dcache[index][23:16]   ;
                4'b0011:data_out = dcache[index][31:24]   ;
                4'b0100:data_out = dcache[index][39:32]   ;
                4'b0101:data_out = dcache[index][47:40]   ;
                4'b0110:data_out = dcache[index][55:48]   ;
                4'b0111:data_out = dcache[index][63:56]   ;
                4'b1000:data_out = dcache[index][71:64]   ;
                4'b1001:data_out = dcache[index][79:72]   ;
                4'b1010:data_out = dcache[index][87:80]   ;
                4'b1011:data_out = dcache[index][95:88]   ;
                4'b1100:data_out = dcache[index][103:96]  ;
                4'b1101:data_out = dcache[index][111:104] ;
                4'b1110:data_out = dcache[index][119:112] ;
                4'b1111:data_out = dcache[index][127:120] ;
              endcase
            end
            2'b01:begin // lh/lhu
              case (byte_offset)
                4'b0000:data_out = dcache[index][15:0]    ;
                4'b0001:data_out = dcache[index][23:8]    ;
                4'b0010:data_out = dcache[index][31:16]   ;
                4'b0011:data_out = dcache[index][39:24]   ;
                4'b0100:data_out = dcache[index][47:32]   ;
                4'b0101:data_out = dcache[index][55:40]   ;
                4'b0110:data_out = dcache[index][63:48]   ;
                4'b0111:data_out = dcache[index][71:56]   ;
                4'b1000:data_out = dcache[index][79:64]   ;
                4'b1001:data_out = dcache[index][87:72]   ;
                4'b1010:data_out = dcache[index][95:80]   ;
                4'b1011:data_out = dcache[index][103:88]  ;
                4'b1100:data_out = dcache[index][111:96]  ;
                4'b1101:data_out = dcache[index][119:104] ;
                4'b1110:data_out = dcache[index][127:112] ;
                4'b1111:data_out = {dcache[index+1'b1][8:0],dcache[index][127:120]}; //<--- Sectioning
              endcase
            end
            2'b10:begin // lw/lwu
              case (byte_offset)
                4'b0000:data_out = dcache[index][31:0]    ;
                4'b0001:data_out = dcache[index][39:8]    ;
                4'b0010:data_out = dcache[index][47:16]   ;
                4'b0011:data_out = dcache[index][55:24]   ;
                4'b0100:data_out = dcache[index][63:32]   ;
                4'b0101:data_out = dcache[index][71:40]   ;
                4'b0110:data_out = dcache[index][79:48]   ;
                4'b0111:data_out = dcache[index][87:56]   ;
                4'b1000:data_out = dcache[index][95:64]   ;
                4'b1001:data_out = dcache[index][103:72]  ;
                4'b1010:data_out = dcache[index][111:80]  ;
                4'b1011:data_out = dcache[index][119:88]  ;
                4'b1100:data_out = dcache[index][127:96]  ;
                4'b1101:data_out = {dcache[index+1'b1][7:0],dcache[index][127:104]}  ; //<--- Sectioning
                4'b1110:data_out = {dcache[index+1'b1][15:0],dcache[index][127:112]} ; //<--- Sectioning
                4'b1111:data_out = {dcache[index+1'b1][23:0],dcache[index][127:120]} ; //<--- Sectioning
              endcase
            end      
            2'b11:begin //ld
              case (byte_offset)
                4'b0000:data_out = dcache[index][63:0]     ;
                4'b0001:data_out = dcache[index][71:8]     ;
                4'b0010:data_out = dcache[index][79:16]    ;
                4'b0011:data_out = dcache[index][87:24]    ;
                4'b0100:data_out = dcache[index][95:32]    ;
                4'b0101:data_out = dcache[index][103:40]   ;
                4'b0110:data_out = dcache[index][111:48]   ;
                4'b0111:data_out = dcache[index][119:56]   ;
                4'b1000:data_out = dcache[index][127:64]   ;
                4'b1001:data_out = {dcache[index+1'b1][7:0],dcache[index][127:72]}   ; //<--- Sectioning
                4'b1010:data_out = {dcache[index+1'b1][15:0],dcache[index][127:80]}  ; //<--- Sectioning
                4'b1011:data_out = {dcache[index+1'b1][23:0],dcache[index][127:88]}  ; //<--- Sectioning 
                4'b1100:data_out = {dcache[index+1'b1][31:0],dcache[index][127:96]}  ; //<--- Sectioning
                4'b1101:data_out = {dcache[index+1'b1][39:0],dcache[index][127:104]} ; //<--- Sectioning
                4'b1110:data_out = {dcache[index+1'b1][47:0],dcache[index][127:112]} ; //<--- Sectioning
                4'b1111:data_out = {dcache[index+1'b1][55:0],dcache[index][127:120]} ; //<--- Sectioning
              endcase
            end                
          endcase
        end
    end
    else
      data_out = 'b0; // in case of no reading
  end
endmodule