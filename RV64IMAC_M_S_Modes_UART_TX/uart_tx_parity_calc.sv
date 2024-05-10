module uart_tx_parity_calc #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] P_DATA    ,
  input  logic             PAR_TYP   ,
  input  logic             CLK       ,
  input  logic             RST       ,
  input  logic             PAR_EN    ,
  input  logic             Data_Valid,
  output logic             par_bit
);

  logic [WIDTH-1:0] data;

  localparam EVEN = 1'b0;
  localparam ODD  = 1'b1;

  always @(posedge CLK, negedge RST)
    begin
      if(!RST)
        data <= 'b0;
      else if(Data_Valid)
        data <= P_DATA;
    end

  always_comb
    begin
      if(PAR_EN)
        par_bit = (PAR_TYP)? ~^data : ^data;
      else
        par_bit = 1'b0;
    end

endmodule
