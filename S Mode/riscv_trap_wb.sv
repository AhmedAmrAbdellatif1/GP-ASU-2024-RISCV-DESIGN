module riscv_trap_wb 
 (
  input  logic       i_riscv_trap_gototrap      , //high when going to trap (if exception/interrupt detected)
  input  logic [1:0] i_riscv_trap_returnfromtrap, //high when returning from trap (via mret)
  input  logic       i_riscv_trap_icache_stall  ,
  input  logic        i_riscv_trap_reconfig_pip  ,
  output logic       o_riscv_trap_flush         , //flush all previous stages
  output logic [2:0] o_riscv_trap_pcsel         

 );

  always_comb begin

    if(i_riscv_trap_gototrap && !i_riscv_trap_icache_stall) begin
      o_riscv_trap_pcsel = 3'b001; 
      o_riscv_trap_flush = 1'b1;
    end

    else if((i_riscv_trap_returnfromtrap == 'd1) && !i_riscv_trap_icache_stall) begin
      o_riscv_trap_pcsel = 3'b010 ; 
      o_riscv_trap_flush = 1'b1 ;
    end

    else if((i_riscv_trap_returnfromtrap == 'd2) && !i_riscv_trap_icache_stall) begin
      o_riscv_trap_pcsel = 3'b011 ;
      o_riscv_trap_flush = 1'b1 ;
    end 
    else if ((i_riscv_trap_reconfig_pip) && !i_riscv_trap_icache_stall)
    begin 
      o_riscv_trap_pcsel = 3'b100 ;
      o_riscv_trap_flush = 1'b1 ;
    end


    else begin //normal operation
      o_riscv_trap_pcsel = 3'b000 ;
      o_riscv_trap_flush = 1'b0 ;
    end

  end

endmodule
