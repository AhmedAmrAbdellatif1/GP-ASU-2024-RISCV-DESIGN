//******************************************************************************************//
//  Description:                                                                            //
//  ------------                                                                            //
//  It is responsible for calculation of write address (raddr) and generation of o_fifo_wr_full flag  //
//                                                                                          //
//******************************************************************************************//

module uart_fifo_wr #(parameter PTR_WIDTH = 4) (
  input  logic                 i_fifo_wr_clk      ,
  input  logic                 i_fifo_wr_rst    ,
  input  logic                 i_fifo_wr_winc     ,
  input  logic [PTR_WIDTH-1:0] i_fifo_wr_wptr_conv,
  input  logic [PTR_WIDTH-1:0] i_fifo_wr_rptr_conv,
  output logic [PTR_WIDTH-1:0] o_fifo_wr_wptr     ,
  output logic [PTR_WIDTH-2:0] o_fifo_wr_waddr    ,
  output logic                 o_fifo_wr_full
);

  // full flag declaration
  logic FULL_FLAG;

  // full calculation always block
  always @(posedge i_fifo_wr_clk or posedge i_fifo_wr_rst)
    begin
      if(i_fifo_wr_rst)
        o_fifo_wr_full <= 1'b0;
      else if(FULL_FLAG)
        o_fifo_wr_full <= 1'b1;
      else
        o_fifo_wr_full <= 1'b0;
    end

  // write address increment always block
  always @(posedge i_fifo_wr_clk or posedge i_fifo_wr_rst)
    begin
      if(i_fifo_wr_rst)
        o_fifo_wr_wptr <= 'b0;
      else if(i_fifo_wr_winc)
        o_fifo_wr_wptr <= o_fifo_wr_wptr + 1'b1;
    end

  // the write address is the LSBs of the pointer
  assign o_fifo_wr_waddr = o_fifo_wr_wptr[PTR_WIDTH-2:0];

  // full flag condition
  // when both pointers, except the MSBs, are equal
  assign FULL_FLAG =  (i_fifo_wr_rptr_conv[PTR_WIDTH-1]   != i_fifo_wr_wptr_conv[PTR_WIDTH-1]) &&
                      (i_fifo_wr_rptr_conv[PTR_WIDTH-2]   != i_fifo_wr_wptr_conv[PTR_WIDTH-2])  &&
                      (i_fifo_wr_rptr_conv[PTR_WIDTH-3:0] == i_fifo_wr_wptr_conv[PTR_WIDTH-3:0]);
endmodule
