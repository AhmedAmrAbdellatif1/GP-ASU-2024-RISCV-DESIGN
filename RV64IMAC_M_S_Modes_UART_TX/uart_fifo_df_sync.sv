module uart_fifo_df_sync #(parameter BUS_WIDTH = 4, NUM_STAGES = 2) (
  input  logic                 i_fifo_dfsync_clk  ,
  input  logic                 i_fifo_dfsync_rst_n,
  input  logic [BUS_WIDTH-1:0] i_fifo_dfsync_async,
  output logic [BUS_WIDTH-1:0] o_fifo_dfsync_sync
);

  // intermediate synchronizer FFs
  logic [BUS_WIDTH-1:0] sync_dff[NUM_STAGES-1:0];

  // control loop index
  integer i;

  always @(negedge i_fifo_dfsync_rst_n or posedge i_fifo_dfsync_clk)
    begin
      if(!i_fifo_dfsync_rst_n)
        for(i = 0; i < NUM_STAGES; i = i + 1)
          sync_dff[i] <= 'b0;
      else
        begin
          for(i = 0; i < NUM_STAGES; i = i + 1)
            begin
              if(i == 0)
                sync_dff[i] <= i_fifo_dfsync_async;
              else
                sync_dff[i] <= sync_dff[i-1];
            end
        end
    end

  // output
  assign o_fifo_dfsync_sync = sync_dff[NUM_STAGES-1];
  
endmodule