module riscv_button_debouncer_delayed (
  input  logic clk, reset,
  input  logic noisy    ,
  output logic debounced
);

  logic timer_done ;
  logic timer_reset;

  riscv_button_debouncer_fsm FSM0 (
    .clk        (clk        ),
    .reset      (reset      ),
    .noisy      (noisy      ),
    .timer_done (timer_done ),
    .timer_reset(timer_reset),
    .debounced  (debounced  )
  );

  // 20 ms timer
  riscv_debouncer_timer #(.FINAL_VALUE(1_999_999)) T0 (
    .clk   (clk         ),
    .reset (timer_reset ),
    .enable(~timer_reset),
    .done  (timer_done  )
  );
endmodule