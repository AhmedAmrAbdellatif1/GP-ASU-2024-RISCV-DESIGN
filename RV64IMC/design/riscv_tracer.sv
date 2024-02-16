module riscv_tracer #(parameter dwidth=64,iwidth=32,awidth=5) (
input  logic                i_riscv_clk         ,
input  logic                i_riscv_rst         ,
input  logic [iwidth-1:0]   i_riscv_trc_inst     ,
input  logic [awidth-1:0]   i_riscv_trc_rdaddr   ,
input  logic [dwidth-1:0]   i_riscv_trc_rddata   );

  // internal registers
  logic [iwidth-1:0]   reg_riscv_trc_inst     ;
  logic [awidth-1:0]   reg_riscv_trc_rdaddr   ;
  logic [dwidth-1:0]   reg_riscv_trc_rddata   ;


 always_ff @(posedge i_riscv_clk or posedge i_riscv_rst )
    begin:tracer_proc
      if(i_riscv_rst)
        begin
         reg_riscv_trc_inst   <='b0;
         reg_riscv_trc_rdaddr <='b0;
         reg_riscv_trc_rddata <='b0;
        end
      else
        begin
         reg_riscv_trc_inst   <= i_riscv_trc_inst;
         reg_riscv_trc_rdaddr <= i_riscv_trc_rdaddr;
         reg_riscv_trc_rddata <= i_riscv_trc_rddata;
        end
    end
  endmodule 