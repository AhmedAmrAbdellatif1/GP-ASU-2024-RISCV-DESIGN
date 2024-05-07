module uart_rx_parity #(parameter
  WIDTH = 8,
  EVEN  = 0,
  ODD   = 1
) (
  input       [WIDTH-1:0] data    ,
  input  logic             par_type,
  input  logic             par_bit ,
  input  logic             enable  ,
  output logic              error
);

  logic data_xor;
  // calculate parity with the extracted data
  always_comb
    begin
      if(enable)
        case(par_type)
          EVEN : begin
            if(par_bit == (data_xor))
              error = 1'b0;
            else
              error = 1'b1;
          end
          ODD : begin
            if(par_bit == (~data_xor))
              error = 1'b0;
            else
              error = 1'b1;
          end
        endcase
      else
        error = 1'b0;
    end

  assign data_xor = ^data;
endmodule