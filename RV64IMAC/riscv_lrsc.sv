module riscv_lrsc(
    input  logic               i_riscv_lrsc_clk,
    input  logic               i_riscv_lrsc_rst,
    input  logic  [63:0]       i_riscv_lrsc_address,
    input  logic  [1:0]        i_riscv_lrsc_LR, // [1] bit indicates LR or not, [0] indicates word or double word
    input  logic  [1:0]        i_riscv_lrsc_SC, // [1] bit indicates SC or not, [0] indicates word or double word
    input  logic               i_riscv_lrsc_memwrite,
    output logic               o_riscv_lrsc_memwrite_o,
    output logic               o_riscv_lrsc_sc_rdvalue
  );
  //--------------------------------------//
  logic [63:0]  reserv_addr  ;
  logic         reserv_valid ;
  logic         LR_word      ;
  //--------------------------------------//
  always@ (posedge i_riscv_lrsc_clk or posedge i_riscv_lrsc_rst)
  begin

    if(i_riscv_lrsc_rst)
    begin
      reserv_addr             <='b0 ;
      reserv_valid            <='b0 ;
      LR_word                 <='b0 ;
    end
    else
    begin
      if(i_riscv_lrsc_LR[1])
      begin    //Load Reserved operation
        reserv_valid            <= 1 ;
        reserv_addr             <= i_riscv_lrsc_address ;

        if(i_riscv_lrsc_LR[0])
          LR_word                <= 1'b1;
        else
          LR_word                <= 1'b0;
      end


      else if (i_riscv_lrsc_SC[1])
      begin   //Store Conditional operation, any SC validates the reservation
        reserv_valid            <= 0 ;
        reserv_addr             <= 0 ;
      end

      else if(i_riscv_lrsc_memwrite && reserv_valid) // Normal Stores
      begin
        if(LR_word && (i_riscv_lrsc_address[63:2] == reserv_addr [63:2]))
        begin
          reserv_valid  <= 0 ;
          reserv_addr   <= 0 ;
        end

        else if (!LR_word && (i_riscv_lrsc_address[63:3] == reserv_addr [63:3]))
        begin
          reserv_valid  <= 0 ;
          reserv_addr   <= 0 ;
        end
      end
    end
  end


  always_comb //combinational for outputs
  begin
    if (i_riscv_lrsc_SC[1])
    begin   //Store Conditional operation

      if((i_riscv_lrsc_address ==  reserv_addr) && reserv_valid && (LR_word == i_riscv_lrsc_SC [0]))
      begin
        o_riscv_lrsc_sc_rdvalue = 'b0  ;
        o_riscv_lrsc_memwrite_o = i_riscv_lrsc_memwrite  ;
      end
      else
      begin
        o_riscv_lrsc_sc_rdvalue = 'b1  ;
        o_riscv_lrsc_memwrite_o = 1'b0  ;
      end
    end
    else
    begin
      o_riscv_lrsc_sc_rdvalue = 'b0  ;
      o_riscv_lrsc_memwrite_o = i_riscv_lrsc_memwrite;
    end

  end


endmodule
