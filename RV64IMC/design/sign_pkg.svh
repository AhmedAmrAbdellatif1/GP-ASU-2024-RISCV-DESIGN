package sign_pkg;
  function logic [64:0] as_signed (logic signed [63:0] data);
      as_signed = {data[63], data};
  endfunction

  function logic [64:0] as_unsigned (logic signed [63:0] data);
      as_unsigned = {1'b0, data};
  endfunction

  function logic [32:0] as_signedw (logic signed [31:0] data);
      as_signedw = {data[31], data};
  endfunction

  function logic [32:0] as_unsignedw (logic signed [31:0] data);
      as_unsignedw = {1'b0, data};
  endfunction
endpackage