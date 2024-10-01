module riscv_button_debouncer_fsm (
  input  logic clk, reset ,
  input  logic noisy, timer_done,
  output logic timer_reset, debounced
);

  logic [1:0] state_reg ;
  logic [1:0] state_next;
  parameter   s0 = 0,
              s1 = 1,
              s2 = 2,
              s3 = 3;

  // Sequential state register
  always @(posedge clk, posedge reset)
    begin
      if (reset)
        state_reg <= 0;
      else
        state_reg <= state_next;
    end

  // Next state logic
  always_comb
    begin
      state_next = state_reg;
      case(state_reg)
        s0 : if (~noisy)
          state_next = s0;
        else if (noisy)
          state_next = s1;
        s1 : if (~noisy)
          state_next = s0;
        else if (noisy & ~timer_done)
          state_next = s1;
        else if (noisy & timer_done)
          state_next = s2;
        s2 : if (~noisy)
          state_next = s3;
        else if (noisy)
          state_next = s2;
        s3 : if (noisy)
          state_next = s2;
        else if (~noisy & ~timer_done)
          state_next = s3;
        else if (~noisy & timer_done)
          state_next = s0;
        default : state_next = s0;
      endcase
    end

  // output logic
  assign timer_reset = (state_reg == s0) | (state_reg == s2);
  assign debounced   = (state_reg == s2) | (state_reg == s3);

endmodule