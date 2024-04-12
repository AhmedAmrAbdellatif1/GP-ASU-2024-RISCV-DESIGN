module riscv_tracer #(parameter dwidth=64,iwidth=32,awidth=5,cwidth=16) (
  input  logic                i_riscv_clk         ,
  input  logic                i_riscv_rst         ,
  input  logic [iwidth-1:0]   i_riscv_trc_inst    ,
  input  logic [cwidth-1:0]   i_riscv_trc_cinst   ,
  input  logic [awidth-1:0]   i_riscv_trc_rdaddr  ,
  input  logic [dwidth-1:0]   i_riscv_trc_memaddr ,
  input  logic [dwidth-1:0]   i_riscv_trc_pc      ,
  input  logic [dwidth-1:0]   i_riscv_trc_store   ,
  input  logic [dwidth-1:0]   i_riscv_trc_rddata  );

  // internal registers
  logic [iwidth-1:0]   reg_riscv_trc_inst     ;
  logic [cwidth-1:0]   reg_riscv_trc_cinst    ;
  logic [awidth-1:0]   reg_riscv_trc_rdaddr   ;
  logic [dwidth-1:0]   reg_riscv_trc_memaddr  ;
  logic [dwidth-1:0]   reg_riscv_trc_pc       ;
  logic [dwidth-1:0]   reg_riscv_trc_store    ;
  logic [dwidth-1:0]   reg_riscv_trc_rddata   ;


 always_ff @(posedge i_riscv_clk or posedge i_riscv_rst )
    begin:tracer_proc
      if(i_riscv_rst)
        begin
         reg_riscv_trc_inst     <='b0;
         reg_riscv_trc_cinst    <='b0;
         reg_riscv_trc_rdaddr   <='b0;
         reg_riscv_trc_memaddr  <='b0;
         reg_riscv_trc_pc       <='b0;
         reg_riscv_trc_store    <='b0;
         reg_riscv_trc_rddata   <='b0;
        end
      else
        begin
         reg_riscv_trc_inst     <= i_riscv_trc_inst;
         reg_riscv_trc_cinst    <= i_riscv_trc_cinst;
         reg_riscv_trc_rdaddr   <= i_riscv_trc_rdaddr;
         reg_riscv_trc_rddata   <= i_riscv_trc_rddata;
         reg_riscv_trc_memaddr  <= i_riscv_trc_memaddr;
         reg_riscv_trc_pc       <= i_riscv_trc_pc;
         reg_riscv_trc_store    <= i_riscv_trc_store;
         reg_riscv_trc_rddata   <= i_riscv_trc_rddata;
        end
    end
endmodule 