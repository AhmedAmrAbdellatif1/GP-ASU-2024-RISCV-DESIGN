module riscv_trap_wb (
  input  wire       i_riscv_trap_gototrap      , //high when going to trap (if exception/interrupt detected)
  input  wire [1:0] i_riscv_trap_returnfromtrap, //high when returning from trap (via mret)
  input  wire       i_riscv_trap_icache_stall  ,
  output reg        o_riscv_trap_flush         , //flush all previous stages
  output reg  [1:0] o_riscv_trap_pcsel
);

  always @(*) begin

    if(i_riscv_trap_gototrap && !i_riscv_trap_icache_stall) begin
      o_riscv_trap_pcsel = 2'b01;
      o_riscv_trap_flush = 1'b1;
    end

    else if((i_riscv_trap_returnfromtrap == 'd1) && !i_riscv_trap_icache_stall) begin
      o_riscv_trap_pcsel = 2'b10 ;
      o_riscv_trap_flush = 1'b1 ;
    end

    else if((i_riscv_trap_returnfromtrap == 'd2) && !i_riscv_trap_icache_stall) begin
      o_riscv_trap_pcsel = 2'b11 ;
      o_riscv_trap_flush = 1'b1 ;
    end

    else begin //normal operation
      o_riscv_trap_pcsel = 2'b00 ;
      o_riscv_trap_flush = 1'b0 ;
    end

  end

endmodule