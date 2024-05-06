//******************************************************************************************//
//  Description:                                                                            //
//  ------------                                                                            //
//  It's the FIFO memory buffer that is accessed by both the write and read clock domains.  //
//  This buffer is most likely a synchronous dual-port RAM or register file                 //
//                                                                                          //
//******************************************************************************************//

module uart_fifo_mem_ctrl #(parameter FIFO_DEPTH = 8, parameter PTR_WIDTH = ($clog2(FIFO_DEPTH)+1)) (
  input  logic [          7:0] i_mem_ctrl_wdata  ,
  input  logic                 i_mem_ctrl_wclk_en,
  input  logic [PTR_WIDTH-2:0] i_mem_ctrl_waddr  ,
  input  logic [PTR_WIDTH-2:0] i_mem_ctrl_raddr  ,
  input  logic                 i_mem_ctrl_wclk   ,
  input  logic                 i_mem_ctrl_wrst_n ,
  output logic [          7:0] o_mem_ctrl_rdata
);

  // FIFO Memory declaration
  logic [7:0] FIFO[FIFO_DEPTH-1:0];

  // control loop index
  integer i;

  // write-port memory
  always @(posedge i_mem_ctrl_wclk or negedge i_mem_ctrl_wrst_n)
    begin
      if(!i_mem_ctrl_wrst_n)
        begin
          for(i = 0; i < FIFO_DEPTH; i = i + 1)
            begin
              FIFO[i] <= 'b0;
            end
        end
      else if(i_mem_ctrl_wclk_en)
        FIFO[i_mem_ctrl_waddr] <= i_mem_ctrl_wdata;
    end

  // read-port memory
  assign o_mem_ctrl_rdata = FIFO[i_mem_ctrl_raddr];
endmodule