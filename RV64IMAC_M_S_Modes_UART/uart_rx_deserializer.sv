module uart_rx_deserializer #(parameter WIDTH     = 8) (
  input  logic             clk           ,
  input  logic             rst           ,
  input  logic             enable        ,
  input  logic             sampled_bit   ,
  input  logic             success       ,
  output logic             data_valid    ,
  output logic [WIDTH-1:0] sampled_stream,
  output logic [WIDTH-1:0] parallel_data
);

  // shifter and counter always block
  always @(posedge clk, negedge rst)
    begin
      if(!rst)
        begin
          sampled_stream <= 'b0;
        end
      else if(enable)
        begin
          sampled_stream <= {sampled_bit,sampled_stream[7:1]};
        end
    end

  always @(posedge clk, negedge rst)
    begin
      if(!rst)
        begin
          parallel_data <= 'b0;
          data_valid    <= 'b0;
        end
      else if(success)
        begin
          parallel_data <= sampled_stream;
          data_valid    <= 'b1;
        end
      else if(!success)
        begin
          data_valid <= 'b0;
        end
    end
endmodule
