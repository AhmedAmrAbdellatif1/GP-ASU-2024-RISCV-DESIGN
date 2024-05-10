module uart_rst_sync #( parameter NUM_STAGES = 2)
  ( input   logic    CLK   ,         // Clock Signal
    input   logic    RST   ,         // Active Low Async Reset
    output  logic    SYNC_RST  );    // Active Low synchronized Reset
    
    // intermediate synchronizer FFs
    logic [NUM_STAGES-1:0]  sync_dff ;
    
    // generate control loop index
    integer i;

    always @(posedge RST or posedge CLK)
    begin
      if(RST)
        sync_dff <= 'b1;
      else
      begin
        for(i = 0; i < NUM_STAGES; i = i + 1)
        begin
          if(i==0)
            sync_dff[i] <= 1'b0;
          else
            sync_dff[i] <= sync_dff[i-1];
        end
      end
    end
    
    // output
    assign SYNC_RST = sync_dff[NUM_STAGES-1];
    
endmodule
