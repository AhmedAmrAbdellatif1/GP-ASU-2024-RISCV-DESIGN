//******************************************************************************************//
//  Description:                                                                            //
//  ------------                                                                            //
//  It is N-bit Bit-Gray Code Converter                                                     //
//                                                                                          //
//******************************************************************************************//

module uart_fifo_gray_conv #(parameter PTR_WIDTH = 4) (
  input  logic [PTR_WIDTH-1:0] i_fifo_conv_bin_ptr ,
  output logic [PTR_WIDTH-1:0] o_fifo_conv_gray_ptr
);

  // control loop variable
  integer i;

  // conversion always block
  always_comb
  begin
    for(i = 0; i < PTR_WIDTH-1; i = i + 1)
      begin
        o_fifo_conv_gray_ptr[i] = i_fifo_conv_bin_ptr[i] + i_fifo_conv_bin_ptr[i+1];
      end
    o_fifo_conv_gray_ptr[PTR_WIDTH-1] = i_fifo_conv_bin_ptr[PTR_WIDTH-1];    // the MSB is kept the same
  end
endmodule
