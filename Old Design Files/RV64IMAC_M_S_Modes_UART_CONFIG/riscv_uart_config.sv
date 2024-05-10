module riscv_uart_config (
  input  logic        i_riscv_config_clk              ,
  input  logic        i_riscv_config_rst              ,
  input  logic        i_riscv_uart_tx_busy            ,
  input  logic [19:0] i_riscv_config_baud_divisor     ,
  input  logic        i_riscv_config_baud_divisor_wren,
  input  logic [ 1:0] i_riscv_config_parity           ,
  input  logic        i_riscv_config_parity_wren      ,
  output logic [19:0] o_riscv_config_baud_divisor     ,
  output logic        o_riscv_config_parity_en        ,
  output logic        o_riscv_config_parity_type
);

  /********************************** Internal Registers **********************************/
  logic [19:0] config_baud_divisor;
  logic        config_parity_en   ;
  logic        config_parity_type ;

  /********************************** Sequential Always ***********************************/
  always_ff @(posedge i_riscv_config_clk or posedge i_riscv_config_rst) begin
    if(i_riscv_config_rst)
      begin
        config_baud_divisor <= 'd6945;
        config_parity_en    <= 1'b1;
        config_parity_type  <= 1'b0;
      end
    else if(i_riscv_config_baud_divisor_wren)
      begin
        if(i_riscv_config_baud_divisor >= 'd3473)
          config_baud_divisor <= 'd6945;
        else if((i_riscv_config_baud_divisor <= 'd3473) && (i_riscv_config_baud_divisor > 'd1737))
          config_baud_divisor <= 'd3473;
        else if((i_riscv_config_baud_divisor <= 'd1737) && (i_riscv_config_baud_divisor > 'd869))
          config_baud_divisor <= 'd1737;
        else if((i_riscv_config_baud_divisor <= 'd869) && (i_riscv_config_baud_divisor > 'd579))
          config_baud_divisor <= 'd869;
        else if((i_riscv_config_baud_divisor <= 'd579) && (i_riscv_config_baud_divisor > 'd290))
          config_baud_divisor <= 'd579;
        else if((i_riscv_config_baud_divisor <= 'd290) && (i_riscv_config_baud_divisor > 'd145))
          config_baud_divisor <= 'd290;
        else if((i_riscv_config_baud_divisor <= 'd145) && (i_riscv_config_baud_divisor > 'd73))
          config_baud_divisor <= 'd145;
        else if((i_riscv_config_baud_divisor <= 'd73) && (i_riscv_config_baud_divisor > 'd37))
          config_baud_divisor <= 'd73;
        else if((i_riscv_config_baud_divisor <= 'd37))
          config_baud_divisor <= 'd37;
      end
    else if(i_riscv_config_parity_wren)
      begin
        config_parity_en   <= i_riscv_config_parity[0];
        config_parity_type <= i_riscv_config_parity[1];
      end
  end

  /********************************* Output Assignment *********************************/
  always_ff @(posedge i_riscv_config_clk or posedge i_riscv_config_rst) begin
    if(i_riscv_config_rst)
      begin
        o_riscv_config_baud_divisor <= 'd6945;
        o_riscv_config_parity_en    <= 1'b1;
        o_riscv_config_parity_type  <= 1'b0;
      end
    else if(!i_riscv_uart_tx_busy)
      begin
        o_riscv_config_baud_divisor <= config_baud_divisor;
        o_riscv_config_parity_en    <= config_parity_en   ;
        o_riscv_config_parity_type  <= config_parity_type ;
      end
  end

endmodule
