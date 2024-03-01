module FF_negedge #(parameter width = 64)

(
  input clk ,rst  ,
  input       [width-1:0] csr_in  ,
 output logic [width-1:0] csr_out  


);


always @(negedge clk or posedge rst)
begin
  if (rst)
  csr_out <= 'b0 ;
else 
 csr_out <= csr_in ;
   

end 

endmodule




