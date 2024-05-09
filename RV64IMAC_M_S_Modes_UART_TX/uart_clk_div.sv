module uart_clk_div (
  input  logic        i_clk_div_ref_clk ,
  input  logic        i_clk_div_rst_n   ,
  input  logic        i_clk_div_clk_en  ,
  input  logic [19:0] i_clk_div_ratio   ,
  output logic        o_clk_div_baud_clk
);

  logic        flag   ; // for non-50% duty cycle in case of odd ratio
  logic        div_clk;
  logic [19:0] counter;

  logic [19:0] half               ;
  logic        CLK_DIV_EN         ; // the actual enable signal for the divider
  logic        odd                ; // defining the type of the ratio
  logic        even_toggle        ; // condition when the even ratio toggles
  logic        odd_toggle_high    ; // condition when the odd ratio toggles HL
  logic        odd_toggle_low     ; // condition when the odd ratio toggles LH
  logic        toggling_conditions; // conditions of toggeling combined


  // generating for ratio = 0 or 1
  always_comb
    begin
      if(CLK_DIV_EN)
        o_clk_div_baud_clk = div_clk;
      else
        o_clk_div_baud_clk = i_clk_div_ref_clk;
    end

  // sequential always block
  always @(posedge i_clk_div_ref_clk, negedge i_clk_div_rst_n)
    begin
      // reset state
      if(!i_clk_div_rst_n)  begin
        div_clk <= 0;
        counter <= 0;
        flag    <= 0;
      end
      // enabled state
      else if(CLK_DIV_EN)
        begin
          if(toggling_conditions)
            begin
              div_clk <= ~div_clk;
              flag    <= ~flag;
              counter <= 'b0;
            end
          else
            begin
              counter <= counter+1'b1;
            end
        end

      // not enabled state
      else
        begin
          div_clk <= 'b0;
        end
    end

// corner case resolve
  assign CLK_DIV_EN = (i_clk_div_clk_en            &&        // if clock divider is enabled
    (i_clk_div_ratio != 'b0) &&        // if the divider ratio not equal zero
    (i_clk_div_ratio != 'b1)    );     // if the divider ratio not equal one

// whether the ratio odd or even
  assign odd = (i_clk_div_ratio[0]);

// whether the counter reaches half of the ratio
  assign half = (i_clk_div_ratio/2) - 'b1;

  assign even_toggle         = (!odd) && (counter == half);
  assign odd_toggle_high     = (odd)  && (flag)  && (counter == half);
  assign odd_toggle_low      = (odd)  && (!flag) &&( counter == (half+'b1));
  assign toggling_conditions = even_toggle || odd_toggle_high || odd_toggle_low;

endmodule