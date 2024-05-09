module uart_tx_top #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] P_DATA    ,
  input  logic             DATA_VALID,
  input  logic             PAR_EN    ,
  input  logic             PAR_TYP   ,
  input  logic             CLK       ,
  input  logic             RST       ,
  output logic             TX_OUT    ,
  output logic             Busy
);

  // internal signals declaration
  logic       ser_done;
  logic       ser_data;
  logic       ser_en  ;
  logic       par_bit ;
  logic [1:0] mux_sel ;


  // module instantiations
  uart_tx_serializer u_uart_tx_serializer (
    .P_DATA  (P_DATA  ),
    .ser_en  (ser_en  ),
    .CLK     (CLK     ),
    .RST     (RST     ),
    .ser_data(ser_data),
    .ser_done(ser_done)
  );

  uart_tx_fsm u_uart_tx_fsm (
    .Data_Valid(DATA_VALID),
    .PAR_EN    (PAR_EN    ),
    .ser_done  (ser_done  ),
    .CLK       (CLK       ),
    .RST       (RST       ),
    .ser_en    (ser_en    ),
    .busy      (Busy      ),
    .mux_sel   (mux_sel   )
  );


  uart_tx_parity_calc u_uart_tx_parity_calc (
    .P_DATA    (P_DATA ),
    .PAR_TYP   (PAR_TYP),
    .CLK       (CLK    ),
    .RST       (RST    ),
    .Data_Valid(!Busy  ),
    .PAR_EN    (PAR_EN ),
    .par_bit   (par_bit)
  );

  uart_tx_mux u_uart_tx_mux (
    .start_bit(1'b0    ),
    .stop_bit (1'b1    ),
    .ser_data (ser_data),
    .par_bit  (par_bit ),
    .mux_sel  (mux_sel ),
    .TX_OUT   (TX_OUT  )
  );
endmodule