module riscv_lsu (
    input   logic            i_riscv_lsu_clk          ,
    input   logic            i_riscv_lsu_rst          ,
    input   logic            i_riscv_lsu_globstall    ,
    input   logic  [63:0]    i_riscv_lsu_address      , //rs1
    input   logic  [63:0]    i_riscv_lsu_alu_result   ,
    input   logic  [1:0]     i_riscv_lsu_LR           , // [1] bit indicates LR or not, [0] indicates word or double word
    input   logic  [1:0]     i_riscv_lsu_SC           , // [1] bit indicates SC or not, [0] indicates word or double word
    input   logic            i_riscv_lsu_AMO          ,
    input   logic            i_riscv_lsu_memwrite     ,
    input   logic            i_riscv_lsu_memread      ,
    input   logic            i_riscv_lsu_goto_trap    ,   //output of CSR
    input   logic  [1:0]     i_riscv_lsu_return_trap  ,   //output of CSR
    input   logic            i_riscv_lsu_misalignment ,   //<-- not added in the logic
    output  logic            o_riscv_lsu_memwrite_en  ,
    output  logic            o_riscv_lsu_memread_en   ,
    output  logic  [63:0]    o_riscv_lsu_mem_address  ,
    output  logic  [63:0]    o_riscv_lsu_sc_rdvalue
  );

  //****************** internal signals declaration ******************//
  logic [63:0]  reserv_addr     ;
  logic         reserv_valid    ;
  logic         lr_word         ;
  logic [4:0]   case_sel        ;
  logic         sc_success_flag ;

  //****************** enum declaration ******************//
  typedef enum logic [4:0] {
            NORMAL_READ  = 5'b10000,
            NORMAL_WRITE = 5'b01000,
            LR           = 5'b00100,
            SC           = 5'b00010,
            AMO          = 5'b00001
          } CTRL ;

  //****************** Internal Connections ******************//
  assign case_sel         = { i_riscv_lsu_memread,
                              i_riscv_lsu_memwrite,
                              i_riscv_lsu_LR[1],
                              i_riscv_lsu_SC[1],
                              i_riscv_lsu_AMO};

  assign sc_success_flag  = ( (i_riscv_lsu_address ==  reserv_addr) &&
                              (reserv_valid)                        &&
                              (lr_word == i_riscv_lsu_SC [0])       &&
                              (i_riscv_lsu_SC[1])                   &&
                              (!i_riscv_lsu_goto_trap )             &&
                              (!i_riscv_lsu_return_trap));

  //****************** Procedural Blocks ******************//
  always_ff @(posedge i_riscv_lsu_clk or posedge i_riscv_lsu_rst)
  begin
    if(i_riscv_lsu_rst)
    begin
      reserv_addr   <=   'b0 ;
      reserv_valid  <=  1'b0 ;
      lr_word       <=  1'b0 ;
    end
    else if(!i_riscv_lsu_globstall)
    begin

      //Load Reserved operation
      if(i_riscv_lsu_LR[1])
      begin    
        reserv_addr   <= i_riscv_lsu_address ;
        reserv_valid  <= 1'b1 ;
        lr_word       <=  (i_riscv_lsu_LR[0])?  1'b1:1'b0;
      end

      //Store Conditional operation, any SC validates the reservation
      else if (i_riscv_lsu_SC[1])
      begin   
        reserv_valid  <= 1'b0 ;
        reserv_addr   <=  'b0 ;
      end
      
    end
  end

  //****************** Combinational for outputs ******************//
  //--> Value written to Rd
  always_comb
  begin
    //Store Conditional operation
    if (i_riscv_lsu_SC[1])
    begin   
      if((i_riscv_lsu_address ==  reserv_addr) && reserv_valid && (lr_word == i_riscv_lsu_SC[0]))  // we removed  && (lr_word == i_riscv_lsu_SC [0])
      begin
        o_riscv_lsu_sc_rdvalue = 'b0  ;
      end
      else
      begin
        o_riscv_lsu_sc_rdvalue = 'b1  ;
      end
    end
    else
    begin
      o_riscv_lsu_sc_rdvalue = 'b0  ;
    end
  end

  //--> Data cache signals
  always_comb
  begin
    case(case_sel)
      NORMAL_READ:
      begin
        o_riscv_lsu_memread_en  = i_riscv_lsu_memread && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
        o_riscv_lsu_memwrite_en = 1'b0;
        o_riscv_lsu_mem_address = i_riscv_lsu_alu_result;
      end

      NORMAL_WRITE:
      begin
        o_riscv_lsu_memread_en  = 1'b0;
        o_riscv_lsu_memwrite_en = i_riscv_lsu_memwrite && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
        o_riscv_lsu_mem_address = i_riscv_lsu_alu_result;
      end

      LR :
      begin
        o_riscv_lsu_memread_en  = i_riscv_lsu_LR[1]  && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
        o_riscv_lsu_memwrite_en = 1'b0;
        o_riscv_lsu_mem_address = i_riscv_lsu_address;
      end

      SC :
      begin
        o_riscv_lsu_memread_en  = 1'b0;
        o_riscv_lsu_memwrite_en = (sc_success_flag)? 1'b1:1'b0;
        o_riscv_lsu_mem_address = i_riscv_lsu_address;
      end

      AMO:
      begin
        o_riscv_lsu_memread_en  = i_riscv_lsu_memread && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
        o_riscv_lsu_memwrite_en = 1'b0;
        o_riscv_lsu_mem_address = i_riscv_lsu_address;
      end

      default:
      begin
        o_riscv_lsu_memread_en  = 1'b0;
        o_riscv_lsu_memwrite_en = 1'b0;
        o_riscv_lsu_mem_address =  'b0;
      end
    endcase
  end
endmodule
