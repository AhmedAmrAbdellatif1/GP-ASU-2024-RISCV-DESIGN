module riscv_trap_wb (
  input  logic       i_riscv_trap_gototrap      , //high when going to trap (if exception/interrupt detected)
  input  logic [1:0] i_riscv_trap_returnfromtrap, //high when returning from trap (via mret)
  input  logic       i_riscv_trap_icache_stall  ,
  output logic       o_riscv_trap_flush         , //flush all previous stages
  output logic [1:0] o_riscv_trap_pcsel
  );

  always_comb begin

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