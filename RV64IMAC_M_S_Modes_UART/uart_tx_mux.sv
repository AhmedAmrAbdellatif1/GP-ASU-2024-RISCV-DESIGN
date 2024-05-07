module uart_tx_mux (
  input  logic       start_bit,
  input  logic       stop_bit ,
  input  logic       ser_data ,
  input  logic       par_bit  ,
  input  logic [1:0] mux_sel  ,
  output logic       TX_OUT
);

  // mux selector encoding
  localparam mux_start  = 2'b00;
  localparam mux_serial = 2'b01;
  localparam mux_parity = 2'b10;
  localparam mux_stop   = 2'b11;

  always_comb
    begin
      case(mux_sel)
        mux_start  : TX_OUT  = start_bit;
        mux_serial : TX_OUT  = ser_data;
        mux_parity : TX_OUT  = par_bit;
        mux_stop   : TX_OUT  = stop_bit;

        //default:    TX_OUT  = 1'b1;

      endcase
    end
endmodule
