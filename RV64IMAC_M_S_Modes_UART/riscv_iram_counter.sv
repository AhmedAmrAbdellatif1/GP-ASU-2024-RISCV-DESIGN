module riscv_iram_counter 
  (
    input   logic clk       ,
    input   logic rden      ,
    output  logic mem_ready 
  );
  
  logic [1:0] counter;

  always_ff @(posedge clk)
  begin
    if((rden) && !(counter == 2'b11))
    begin
      counter   <= counter + 1'b1;
      mem_ready <= 1'b0;
    end
    else if(counter == 2'b11)
    begin
      counter   <= 2'b0;
      mem_ready <= 1'b1;
    end
    else
    begin
      counter   <= 2'b0;
      mem_ready <= 1'b0;
    end
  end

endmodule