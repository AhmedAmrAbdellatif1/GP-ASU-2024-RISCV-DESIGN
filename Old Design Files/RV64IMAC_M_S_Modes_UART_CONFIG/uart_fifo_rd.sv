//******************************************************************************************//
//  Description:                                                                            //
//  ------------                                                                            //
//  It is responsible for calculation of read address (o_fifo_rd_raddr) and generation of o_fifo_rd_empty flag  //
//                                                                                          //
//******************************************************************************************//

module uart_fifo_rd #(parameter PTR_WIDTH = 4) (
  input  logic                 i_fifo_rd_clk      ,
  input  logic                 i_fifo_rd_rst    ,
  input  logic                 i_fifo_rd_rinc     ,
  input  logic [PTR_WIDTH-1:0] i_fifo_rd_wptr_conv,
  input  logic [PTR_WIDTH-1:0] i_fifo_rd_rptr_conv,
  output logic [PTR_WIDTH-1:0] o_fifo_rd_rptr     ,
  output logic [PTR_WIDTH-2:0] o_fifo_rd_raddr    ,
  output logic                 o_fifo_rd_empty
);

  // empty flag declaration
  logic EMPTY_FLAG;

  // empty calculation always block
  always @(posedge i_fifo_rd_clk or posedge i_fifo_rd_rst)
    begin
      if(i_fifo_rd_rst)
        o_fifo_rd_empty <= 1'b1;
      else if(EMPTY_FLAG)
        o_fifo_rd_empty <= 1'b1;
      else
        o_fifo_rd_empty <= 1'b0;
    end

  // read address increment always block
  always @(posedge i_fifo_rd_clk or posedge i_fifo_rd_rst)
    begin
      if(i_fifo_rd_rst)
        o_fifo_rd_rptr <= 'b0;
      else if(!o_fifo_rd_empty && i_fifo_rd_rinc)
        o_fifo_rd_rptr <= o_fifo_rd_rptr + 1'b1;
    end

  // the read address is the LSBs of the pointer
  assign o_fifo_rd_raddr = o_fifo_rd_rptr[PTR_WIDTH-2:0];

  // empty flag condition
  // when both pointers, including the MSBs are equal
  assign EMPTY_FLAG = (i_fifo_rd_rptr_conv == i_fifo_rd_wptr_conv);

endmodule
