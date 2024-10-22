module riscv_lsu #(
  parameter UART_BASE      = 'h10000000    ,
  parameter GPIOU_BASE     = 'h20000000    ,
  parameter GPIOL_BASE     = 'h20000008    ,
  parameter BUT1_BASE      = 'h20000010    ,
  parameter BUT2_BASE      = 'h20000018    ,
  parameter BUT3_BASE      = 'h20000020    ,
  parameter LED_BASE       = 'h30000000    ,
  parameter SEG_BASE       = 'h40000000    ,
  parameter CLINT          = 'h2000000     ,
  parameter CLINT_MTIMECMP = CLINT + 'h4000,
  parameter CLINT_MTIME    = CLINT + 'hBFF8  // cycles since boot
) (
  input  logic        i_riscv_lsu_clk           ,
  input  logic        i_riscv_lsu_rst           ,
  input  logic        i_riscv_lsu_globstall     ,
  input  logic [63:0] i_riscv_lsu_address       , //  rs1
  input  logic [63:0] i_riscv_lsu_alu_result    ,
  input  logic [ 1:0] i_riscv_lsu_lr            , //  [1] bit indicates LR or not, [0] indicates word or double word
  input  logic [ 1:0] i_riscv_lsu_sc            , //  [1] bit indicates SC or not, [0] indicates word or double word
  input  logic        i_riscv_lsu_amo           ,
  input  logic        i_riscv_lsu_dcache_wren   ,
  input  logic        i_riscv_lsu_dcache_rden   ,
  input  logic        i_riscv_lsu_goto_trap     , //  output of CSR
  input  logic [ 1:0] i_riscv_lsu_return_trap   , //  output of CSR
  input  logic        i_riscv_lsu_misalignment  , //  <-- not added in the logic
  output logic        o_riscv_lsu_dcache_wren   ,
  output logic        o_riscv_lsu_dcache_rden   ,
  output logic [63:0] o_riscv_lsu_phy_address   ,
  output logic [63:0] o_riscv_lsu_sc_rdvalue    ,
  output logic        o_riscv_lsu_timer_wren    ,
  output logic        o_riscv_lsu_timer_rden    ,
  output logic [ 1:0] o_riscv_lsu_timer_regsel  ,
  output logic        o_riscv_lsu_uart_tx_valid ,
  output logic        o_riscv_lsu_seg_en        ,
  output logic        o_riscv_lsu_led_en        ,
  output logic [ 2:0] o_riscv_lsu_mstage_mux_sel
);

  //****************** internal signals declaration ******************//
  logic [63:0] reserv_addr              ;
  logic        reserv_valid             ;
  logic        lr_word                  ;
  logic [ 4:0] case_sel                 ;
  logic        sc_success_flag          ;
  logic        memory_mapped_instruction;

  //****************** enum declaration ******************//
  typedef enum logic [4:0] {
    NORMAL_READ  = 5'b10000,
    NORMAL_WRITE = 5'b01000,
    LR           = 5'b00100,
    SC           = 5'b00010,
    AMO          = 5'b00001
  } CTRL ;

  /**********************************************/
  typedef enum logic [1:0] {
    MTIME    = 2'b01,
    MTIMECMP = 2'b10
  } timer_address ;

  //****************** Internal Connections ******************//
  assign case_sel = { i_riscv_lsu_dcache_rden,
    i_riscv_lsu_dcache_wren,
    i_riscv_lsu_lr[1],
    i_riscv_lsu_sc[1],
    i_riscv_lsu_amo};

  assign sc_success_flag = ( (i_riscv_lsu_address ==  reserv_addr) &&
    (reserv_valid)                        &&
    (lr_word == i_riscv_lsu_sc [0])       &&
    (i_riscv_lsu_sc[1])                   &&
    (!i_riscv_lsu_goto_trap )             &&
    (!i_riscv_lsu_return_trap));

  //****************** Procedural Blocks ******************//
  always_ff @(posedge i_riscv_lsu_clk or posedge i_riscv_lsu_rst)
    begin
      if(i_riscv_lsu_rst)
        begin
          reserv_addr  <= 'b0 ;
          reserv_valid <= 1'b0 ;
          lr_word      <= 1'b0 ;
        end
      else if(!i_riscv_lsu_globstall)
        begin

          //Load Reserved operation
          if(i_riscv_lsu_lr[1])
            begin
              reserv_addr  <= i_riscv_lsu_address ;
              reserv_valid <= 1'b1 ;
              lr_word      <= (i_riscv_lsu_lr[0])?  1'b1:1'b0;
            end

          //Store Conditional operation, any SC validates the reservation
          else if (i_riscv_lsu_sc[1])
            begin
              reserv_valid <= 1'b0 ;
              reserv_addr  <= 'b0 ;
            end

        end
    end

  //****************** Combinational for outputs ******************//
  //--> Value written to Rd
  always_comb
    begin
      //Store Conditional operation
      if (i_riscv_lsu_sc[1])
        begin
          if((i_riscv_lsu_address ==  reserv_addr) && reserv_valid && (lr_word == i_riscv_lsu_sc[0]))  // we removed  && (lr_word == i_riscv_lsu_sc [0])
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
      if(memory_mapped_instruction)
        begin
          o_riscv_lsu_dcache_rden = 1'b0;
          o_riscv_lsu_dcache_wren = 1'b0;
          o_riscv_lsu_phy_address = 'b0;
        end
      else
        begin
          case(case_sel)
            NORMAL_READ :
              begin
                o_riscv_lsu_dcache_rden = i_riscv_lsu_dcache_rden && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
                o_riscv_lsu_dcache_wren = 1'b0;
                o_riscv_lsu_phy_address = i_riscv_lsu_alu_result;
              end

            NORMAL_WRITE :
              begin
                o_riscv_lsu_dcache_rden = 1'b0;
                o_riscv_lsu_dcache_wren = i_riscv_lsu_dcache_wren && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
                o_riscv_lsu_phy_address = i_riscv_lsu_alu_result;
              end

            LR :
              begin
                o_riscv_lsu_dcache_rden = i_riscv_lsu_lr[1]  && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
                o_riscv_lsu_dcache_wren = 1'b0;
                o_riscv_lsu_phy_address = i_riscv_lsu_address;
              end

            SC :
              begin
                o_riscv_lsu_dcache_rden = 1'b0;
                o_riscv_lsu_dcache_wren = (sc_success_flag)? 1'b1:1'b0;
                o_riscv_lsu_phy_address = i_riscv_lsu_address;
              end

            AMO :
              begin
                o_riscv_lsu_dcache_rden = i_riscv_lsu_dcache_rden && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
                o_riscv_lsu_dcache_wren = 1'b0;
                o_riscv_lsu_phy_address = i_riscv_lsu_address;
              end

            default :
              begin
                o_riscv_lsu_dcache_rden = 1'b0;
                o_riscv_lsu_dcache_wren = 1'b0;
                o_riscv_lsu_phy_address = 'b0;
              end
          endcase
        end
    end

  // --> Timer Interrupt signals
  always_comb
    begin
      if((i_riscv_lsu_alu_result == CLINT_MTIME) || (i_riscv_lsu_alu_result == CLINT_MTIMECMP))
        begin
          o_riscv_lsu_timer_wren = i_riscv_lsu_dcache_wren;
          o_riscv_lsu_timer_rden = i_riscv_lsu_dcache_rden;
        end
      else
        begin
          o_riscv_lsu_timer_wren = 1'b0;
          o_riscv_lsu_timer_rden = 1'b0;
        end
    end

  always_comb
    begin
      case(i_riscv_lsu_alu_result)
        CLINT_MTIME    : o_riscv_lsu_timer_regsel = MTIME;
        CLINT_MTIMECMP : o_riscv_lsu_timer_regsel = MTIMECMP;
        default        : o_riscv_lsu_timer_regsel = 2'b00;
      endcase
    end

  // --> UART signals
  always_comb
    begin
      if((i_riscv_lsu_alu_result == UART_BASE))
        begin
          o_riscv_lsu_uart_tx_valid = i_riscv_lsu_dcache_wren;
        end
      else
        begin
          o_riscv_lsu_uart_tx_valid = 1'b0;
        end
    end

  // --> SEGMENT signals
  always_comb
    begin
      if((i_riscv_lsu_alu_result == SEG_BASE))
        begin
          o_riscv_lsu_seg_en = i_riscv_lsu_dcache_wren;
        end
      else
        begin
          o_riscv_lsu_seg_en = 1'b0;
        end
    end


  // --> LEDS signals
  always_comb
    begin
      if((i_riscv_lsu_alu_result == LED_BASE))
        begin
          o_riscv_lsu_led_en = i_riscv_lsu_dcache_wren;
        end
      else
        begin
          o_riscv_lsu_led_en = 1'b0;
        end
    end

  // --> Memory Stage LOADED DATA Mux Selector
  always_comb
    begin
      if(o_riscv_lsu_timer_rden)
        o_riscv_lsu_mstage_mux_sel = 'd1;
      else if((i_riscv_lsu_alu_result == GPIOU_BASE) && i_riscv_lsu_dcache_rden)
        o_riscv_lsu_mstage_mux_sel = 'd2;
      else if((i_riscv_lsu_alu_result == GPIOL_BASE) && i_riscv_lsu_dcache_rden)
        o_riscv_lsu_mstage_mux_sel = 'd3;
      else if((i_riscv_lsu_alu_result == BUT1_BASE) && i_riscv_lsu_dcache_rden)
        o_riscv_lsu_mstage_mux_sel = 'd4;
      else if((i_riscv_lsu_alu_result == BUT2_BASE) && i_riscv_lsu_dcache_rden)
        o_riscv_lsu_mstage_mux_sel = 'd5;
      else if((i_riscv_lsu_alu_result == BUT3_BASE) && i_riscv_lsu_dcache_rden)
        o_riscv_lsu_mstage_mux_sel = 'd6;
      else
        o_riscv_lsu_mstage_mux_sel = 'd0;
    end


  assign memory_mapped_instruction = ( (i_riscv_lsu_alu_result == CLINT_MTIME)     ||
    (i_riscv_lsu_alu_result == CLINT_MTIMECMP)  ||
    (i_riscv_lsu_alu_result == UART_BASE)       ||
    (i_riscv_lsu_alu_result == GPIOU_BASE)       ||
    (i_riscv_lsu_alu_result == GPIOL_BASE)       ||
    (i_riscv_lsu_alu_result == BUT1_BASE)       ||
    (i_riscv_lsu_alu_result == BUT2_BASE)       ||
    (i_riscv_lsu_alu_result == BUT3_BASE)       ||
    (i_riscv_lsu_alu_result == LED_BASE)        ||
    (i_riscv_lsu_alu_result == SEG_BASE)        );



endmodule
