module uart_tx_serializer #(parameter
  WIDTH      = 8                ,
  COUNT_BITS = ($clog2(WIDTH)+1)
) (
  input  logic [WIDTH-1:0] P_DATA  ,
  input  logic             ser_en  ,
  input  logic             CLK     ,
  input  logic             RST     ,
  output logic             ser_data,
  output logic             ser_done
);

  logic [COUNT_BITS-1:0] counter  ; // combinational logic output counter
  logic [COUNT_BITS-1:0] counter_r; // sequential logic output counter
  logic [     WIDTH-1:0] data     ;

  // uart_tx_serializer sequential always block
  always @(posedge CLK, posedge RST)
    begin
      if(RST)
        begin
          ser_data <= 1'b1;
          data     <= 'b0;
        end
      else if(!ser_en)
        begin
          ser_data <= 1'b1;
          data     <= P_DATA;
        end
      else if(ser_en && !ser_done)
        {data[WIDTH-2:0],ser_data} <= data;
    end

  // counter sequential always block
  always @(posedge CLK, posedge RST)
    begin
      if(RST)
        counter_r <= WIDTH;
      else
        counter_r <= counter;
    end

  // counter combinational always block
  always_comb
  begin
    if(ser_en && counter_r)
      begin
        counter  = counter_r - 1'b1;
        ser_done = 1'b0;
      end
    else if (ser_en && !counter_r)
      begin
        counter  = 1'b0;
        ser_done = 1'b1;
      end
    else
      begin
        counter  = WIDTH;
        ser_done = 1'b0;
      end
  end
endmodule