module riscv_debouncer_timer #(parameter FINAL_VALUE = 255) (
  input  logic clk    ,
  input  logic reset,
  input  logic enable ,
  output logic done
);

  localparam BITS = $clog2(FINAL_VALUE);

  logic [BITS-1:0] Q_reg ;
  logic [BITS-1:0] Q_next;

  always @(posedge clk, posedge reset)
    begin
      if (reset)
        Q_reg <= 'b0;
      else if(enable)
        Q_reg <= Q_next;
      else
        Q_reg <= Q_reg;
    end

  // Next state logic
  assign done = (Q_reg == FINAL_VALUE);

  always_comb
    Q_next = done? 'b0: Q_reg + 1;


endmodule