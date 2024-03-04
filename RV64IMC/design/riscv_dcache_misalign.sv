module riscv_dcache_misalign #(parameter OFFSET = 4)(
  input   logic               wren,rden   ,
  input   logic               stall       ,
  input   logic [1:0]         load_src    ,
  input   logic [1:0]         store_src   ,
  input   logic [OFFSET-1:0]  byte_offset ,
  output  logic               misaligned
);

  always_comb begin
    if(wren && !rden) begin
      case(store_src)
        2'b00: misaligned = 1'b0;                             // byte case
        2'b01: misaligned = (byte_offset>'d14)? 1'b1:1'b0;    // half-word case
        2'b10: misaligned = (byte_offset>'d12)? 1'b1:1'b0;    // word case
        2'b11: misaligned = (byte_offset>'d8) ? 1'b1:1'b0;    // double-word case
      endcase
    end
    else if(!wren && rden) begin
      case(load_src)
        2'b00: misaligned = 1'b0;                             // byte case
        2'b01: misaligned = (byte_offset>'d14)? 1'b1:1'b0;    // half-word case
        2'b10: misaligned = (byte_offset>'d12)? 1'b1:1'b0;    // word case
        2'b11: misaligned = (byte_offset>'d8) ? 1'b1:1'b0;    // double-word case
      endcase
    end
    else begin
      misaligned = 1'b0;
    end
  end
endmodule