
  module riscv_rf(
    input   logic            i_riscv_rf_clk_n,
    input   logic            i_riscv_rf_rst,
    input   logic            i_riscv_rf_regwrite,
    input   logic  [4:0]     i_riscv_rf_rs1addr,
    input   logic  [4:0]     i_riscv_rf_rs2addr,
    input   logic  [4:0]     i_riscv_rf_rdaddr,
    input   logic  [63:0]    i_riscv_rf_rddata,
    output  logic  [63:0]    o_riscv_rf_rs1data,
    output  logic  [63:0]    o_riscv_rf_rs2data
  );
  logic [63:0] rf [31:0];
  integer i ;
  assign o_riscv_rf_rs1data = (i_riscv_rf_rs1addr == 0) ? 0 : rf[i_riscv_rf_rs1addr];
  assign o_riscv_rf_rs2data = (i_riscv_rf_rs2addr == 0) ? 0 : rf[i_riscv_rf_rs2addr];


  always_ff @(posedge i_riscv_rf_rst or negedge i_riscv_rf_clk_n ) 
    begin:rf_write_proc
      if(i_riscv_rf_rst)
        begin
          for (i=0; i<32; i=i+1) 
            begin
              if(i!=21)
                rf[i]<=64'b0;
              else
                rf[21] <= 'h0800b6980;
            end
        end         
      else
        if(i_riscv_rf_regwrite && (i_riscv_rf_rdaddr!=0))
          rf[i_riscv_rf_rdaddr]<=i_riscv_rf_rddata;
        else;
    end
  endmodule