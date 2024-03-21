module riscv_lsu (
    input  logic               i_riscv_lsu_clk,
    input  logic               i_riscv_lsu_rst,
    input  logic  [63:0]       i_riscv_lsu_address,        //rs1
    input  logic  [63:0]       i_riscv_lsu_alu_result,
    input  logic  [1:0]        i_riscv_lsu_LR, // [1] bit indicates LR or not, [0] indicates word or double word
    input  logic  [1:0]        i_riscv_lsu_SC, // [1] bit indicates SC or not, [0] indicates word or double word
    input  logic               i_riscv_lsu_AMO,
    input  logic               i_riscv_lsu_memwrite,
    input  logic               i_riscv_lsu_memread,
    input  logic               i_riscv_lsu_goto_trap,            //output of CSR
    input  logic               i_riscv_lsu_return_trap,          //output of CSR
    input  logic               i_riscv_lsu_misalignment,
    output logic               o_riscv_lsu_memwrite_en,
    output logic               o_riscv_lsu_memread_en,
    output logic  [63:0]       o_riscv_lsu_mem_address,
    output logic               o_riscv_lsu_sc_rdvalue
  );
  typedef enum logic [4:0] {
            NORMAL_READ  = 5'b10000,
            NORMAL_WRITE = 5'b01000,
            LR           = 5'b00100,
            SC           = 5'b00010,
            AMO          = 5'b00001
          } CTRL ;

  //--------------------------------------//
  logic [63:0]  reserv_addr  ;
  logic         reserv_valid ;
  logic         LR_word      ;
  logic [4:0]   sel;
  //--------------------------------------//
  assign sel = {i_riscv_lsu_memread,i_riscv_lsu_memwrite, i_riscv_lsu_LR, i_riscv_lsu_SC,i_riscv_lsu_AMO};

  always@ (posedge i_riscv_lsu_clk or posedge i_riscv_lsu_rst)
  begin
    if(i_riscv_lsu_rst)
    begin
      reserv_addr             <='b0 ;
      reserv_valid            <='b0 ;
      LR_word                 <='b0 ;
    end
    else
    begin
      if(i_riscv_lsu_LR[1])
      begin    //Load Reserved operation
        reserv_valid            <= 1 ;
        reserv_addr             <= i_riscv_lsu_address ;

        if(i_riscv_lsu_LR[0])
          LR_word                <= 1'b1;
        else
          LR_word                <= 1'b0;
      end


      else if (i_riscv_lsu_SC[1])
      begin   //Store Conditional operation, any SC validates the reservation
        reserv_valid            <= 0 ;
        reserv_addr             <= 0 ;
      end

      else if(i_riscv_lsu_memwrite && reserv_valid) // Normal Stores
      begin
        if(LR_word && (i_riscv_lsu_address[63:2] == reserv_addr [63:2]))
        begin
          reserv_valid  <= 0 ;
          reserv_addr   <= 0 ;
        end

        else if (!LR_word && (i_riscv_lsu_address[63:3] == reserv_addr [63:3]))
        begin
          reserv_valid  <= 0 ;
          reserv_addr   <= 0 ;
        end
      end
    end
  end


  always_comb //combinational for outputs
  begin
    if (i_riscv_lsu_SC[1])
    begin   //Store Conditional operation

      if((i_riscv_lsu_address ==  reserv_addr) && reserv_valid && (LR_word == i_riscv_lsu_SC [0]))
      begin
        o_riscv_lsu_sc_rdvalue = 'b0  ;
        //   o_riscv_lsu_memwrite_en = i_riscv_lsu_memwrite  ;
      end
      else
      begin
        o_riscv_lsu_sc_rdvalue = 'b1  ;
        // o_riscv_lsu_memwrite_en = 1'b0  ;
      end
    end
    else
    begin
      o_riscv_lsu_sc_rdvalue = 'b0  ;
      //  o_riscv_lsu_memwrite_en = i_riscv_lsu_memwrite;
    end

    always_comb
    begin
      case(sel)

        NORMAL_READ:
        begin
          o_riscv_lsu_memread_en= i_riscv_lsu_memread && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_memwrite_en= 0;
          o_riscv_lsu_mem_address=i_riscv_lsu_alu_result;
        end

        NORMAL_WRITE:
        begin
          o_riscv_lsu_memread_en= 0;
          o_riscv_lsu_memwrite_en=i_riscv_lsu_memwrite && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_mem_address=i_riscv_lsu_alu_result;
        end

        LR :
        begin
          o_riscv_lsu_memread_en= i_riscv_lsu_LR[1]  && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_memwrite_en= 0;
          o_riscv_lsu_mem_address=i_riscv_lsu_address;
        end

        SC :
        begin
          o_riscv_lsu_memread_en= 0;
          o_riscv_lsu_mem_address=i_riscv_lsu_address;
          if((i_riscv_lsu_address ==  reserv_addr) && reserv_valid && (LR_word == i_riscv_lsu_SC [0]) &&i_riscv_lsu_SC[1] && !i_riscv_lsu_goto_trap  && !i_riscv_lsu_return_trap)
            o_riscv_lsu_memwrite_en= 1;
          else
            o_riscv_lsu_memwrite_en= 0;
        end

        AMO:
        begin
          o_riscv_lsu_memread_en= i_riscv_lsu_memread && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_memwrite_en= 0;
          o_riscv_lsu_mem_address=i_riscv_lsu_address;
        end

        default:
        begin
          o_riscv_lsu_memread_en  = 1'b0;
          o_riscv_lsu_memwrite_en = 1'b0;
          o_riscv_lsu_mem_address =  'b0;
        end


      endcase
    end
  end


endmodule
