module riscv_tracer #(parameter dwidth=64,iwidth=32,awidth=5,cwidth=16) (
  input   logic                i_riscv_clk         ,
  input   logic                i_riscv_rst         ,
  input   logic [iwidth-1:0]   i_riscv_trc_inst    ,
  input   logic [cwidth-1:0]   i_riscv_trc_cinst   ,
  input   logic [awidth-1:0]   i_riscv_trc_rdaddr  ,
  input   logic [dwidth-1:0]   i_riscv_trc_memaddr ,
  input   logic [dwidth-1:0]   i_riscv_trc_pc      ,
  input   logic [dwidth-1:0]   i_riscv_trc_store   ,
  input   logic [dwidth-1:0]   i_riscv_trc_rddata  );
  
  //output  logic [iwidth-1:0]   o_riscv_trc_inst    ,
  //output  logic [cwidth-1:0]   o_riscv_trc_cinst   ,
  //output  logic [awidth-1:0]   o_riscv_trc_rdaddr  ,
  //output  logic [dwidth-1:0]   o_riscv_trc_memaddr ,
  //output  logic [dwidth-1:0]   o_riscv_trc_pc      ,
  //output  logic [dwidth-1:0]   o_riscv_trc_store   ,
  //output  logic [dwidth-1:0]   o_riscv_trc_rddata  );

  // internal registers
  (* dont_touch = "yes" *) logic [iwidth-1:0]   reg_riscv_trc_inst     ;
  (* dont_touch = "yes" *) logic [cwidth-1:0]   reg_riscv_trc_cinst    ;
  (* dont_touch = "yes" *) logic [awidth-1:0]   reg_riscv_trc_rdaddr   ;
  (* dont_touch = "yes" *) logic [dwidth-1:0]   reg_riscv_trc_memaddr  ;
  (* dont_touch = "yes" *) logic [dwidth-1:0]   reg_riscv_trc_pc       ;
  (* dont_touch = "yes" *) logic [dwidth-1:0]   reg_riscv_trc_store    ;
  (* dont_touch = "yes" *) logic [dwidth-1:0]   reg_riscv_trc_rddata   ;


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

    assign o_riscv_trc_inst     = i_riscv_trc_inst    ;
    assign o_riscv_trc_cinst    = i_riscv_trc_cinst   ;
    assign o_riscv_trc_rdaddr   = i_riscv_trc_rdaddr  ;
    assign o_riscv_trc_memaddr  = i_riscv_trc_memaddr ;
    assign o_riscv_trc_pc       = i_riscv_trc_pc      ;
    assign o_riscv_trc_store    = i_riscv_trc_store   ;
    assign o_riscv_trc_rddata   = i_riscv_trc_rddata  ;


endmodule 