
  module riscv_rf(
    input   logic            i_riscv_rf_clk_n     ,
    input   logic            i_riscv_rf_regwrite  ,
    input   logic  [4:0]     i_riscv_rf_rs1addr   ,
    input   logic  [4:0]     i_riscv_rf_rs2addr   ,
    input   logic  [4:0]     i_riscv_rf_rdaddr    ,
    input   logic  [63:0]    i_riscv_rf_rddata    ,
    output  logic  [63:0]    o_riscv_rf_rs1data   ,
    output  logic  [63:0]    o_riscv_rf_rs2data
  );

    integer i ;

    logic [63:0] rf [1:31];

    assign o_riscv_rf_rs1data = (i_riscv_rf_rs1addr == 5'b0) ? 64'b0 : rf[i_riscv_rf_rs1addr];
    assign o_riscv_rf_rs2data = (i_riscv_rf_rs2addr == 5'b0) ? 64'b0 : rf[i_riscv_rf_rs2addr];

    initial
    begin
      for (i=1; i<32; i=i+1) 
            rf[i]<=64'b0;
    end

  always @(negedge i_riscv_rf_clk_n) 
    begin:rf_write_proc
      if(i_riscv_rf_regwrite && (i_riscv_rf_rdaddr!=0))
        rf[i_riscv_rf_rdaddr]<=i_riscv_rf_rddata;
    end
  endmodule