module uart_rx_top #(parameter
  WIDTH        = 8                       ,
  PAR_MAX      = 11                      ,
  MAX_PRESCALE = 32                      ,
  FRAME_WIDTH  = ($clog2(PAR_MAX) + 1)   ,
  PRSC_WIDTH   = ($clog2(MAX_PRESCALE)+1)
) (
  input  wire                  i_clk          ,
  input  wire                  i_rst_n        ,
  input  wire [PRSC_WIDTH-1:0] i_prescale     ,
  input  wire                  i_serial_data  ,
  input  wire                  i_parity_enable,
  input  wire                  i_parity_type  ,
  output wire                  o_data_valid   ,
  output wire                  o_parity_error ,
  output wire                  o_stop_error   ,
  output wire [     WIDTH-1:0] o_parallel_data
);

  // internal signal declaration
  wire [FRAME_WIDTH-2:0] x_bit_cnt     ; // from uart_rx_edge to FSM
  wire [ PRSC_WIDTH-2:0] x_edge_cnt    ; // from uart_rx_edge to uart_rx_sampling
  wire                   x_samp_done   ; // from uart_rx_edge to FSM
  wire                   x_sampled_bit ; // from uart_rx_sampling to uart_rx_parity, uart_rx_start, uart_rx_stop & uart_rx_deserializer
  wire                   x_strt_glitch ; // from uart_rx_start to FSM
  wire                   x_samp_cnt_en ; // from FSM to uart_rx_sampling & uart_rx_edge
  wire                   x_deser_en    ; // from FSM to uart_rx_deserializer
  wire                   x_success_sig ; // from FSM to uart_rx_deserializer
  wire                   x_par_chk_en  ; // from FSM to uart_rx_parity
  wire                   x_strt_chk_en ; // from FSM to uart_rx_start
  wire                   x_stp_chk_en  ; // from FSM to uart_rx_stop
  wire [      WIDTH-1:0] x_sampled_data; // from uart_rx_deserializer to uart_rx_parity

  uart_rx_fsm u_uart_rx_fsm (
    .clk           (i_clk          ),
    .rst           (i_rst_n        ),
    .RX_IN         (i_serial_data  ),
    .bit_cnt       (x_bit_cnt      ),
    .done_sampling (x_samp_done    ),
    .par_en        (i_parity_enable),
    .par_err       (o_parity_error ),
    .start_glitch  (x_strt_glitch  ),
    .stop_err      (o_stop_error   ),
    .par_check_en  (x_par_chk_en   ),
    .start_check_en(x_strt_chk_en  ),
    .stop_check_en (x_stp_chk_en   ),
    .samp_cnt_en   (x_samp_cnt_en  ),
    .deser_en      (x_deser_en     ),
    .data_valid    (x_success_sig  )
  );

  uart_rx_edge u_uart_rx_edge (
    .clk      (i_clk          ),
    .rst      (i_rst_n        ),
    .enable   (x_samp_cnt_en  ),
    .prescale (i_prescale     ),
    .parity_en(i_parity_enable),
    .bit_cnt  (x_bit_cnt      ),
    .edge_max (x_samp_done    ),
    .edge_cnt (x_edge_cnt     )
  );

  uart_rx_sampling u_uart_rx_sampling (
    .clk        (i_clk                     ),
    .rst        (i_rst_n                   ),
    .serial_data(i_serial_data             ),
    .counter    (x_edge_cnt                ),
    .enable     (x_samp_cnt_en             ),
    .sampled_bit(x_sampled_bit             ),
    .prescale   (i_prescale[PRSC_WIDTH-1:1])
  );


  uart_rx_deserializer u_uart_rx_deserializer (
    .clk           (i_clk          ),
    .rst           (i_rst_n        ),
    .sampled_bit   (x_sampled_bit  ),
    .enable        (x_deser_en     ),
    .success       (x_success_sig  ),
    .data_valid    (o_data_valid   ),
    .sampled_stream(x_sampled_data ),
    .parallel_data (o_parallel_data)
  );


  uart_rx_start u_uart_rx_start (
    .enable           (x_strt_chk_en),
    .sampled_start_bit(x_sampled_bit),
    .glitch           (x_strt_glitch)
  );

  uart_rx_stop u_uart_rx_stop (
    .enable          (x_stp_chk_en ),
    .sampled_stop_bit(x_sampled_bit),
    .error           (o_stop_error )
  );

  uart_rx_parity u_uart_rx_parity (
    .data    (x_sampled_data),
    .par_type(i_parity_type ),
    .par_bit (x_sampled_bit ),
    .enable  (x_par_chk_en  ),
    .error   (o_parity_error)
  );


endmodule
