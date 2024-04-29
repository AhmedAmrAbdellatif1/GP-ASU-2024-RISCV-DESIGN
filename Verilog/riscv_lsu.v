module riscv_lsu 
  #(  
    parameter CLINT           = 'h2000000           ,
    parameter CLINT_MTIMECMP  = CLINT + 'h4000      ,
    parameter CLINT_MTIME     = CLINT + 'hBFF8       // cycles since boot
  )
  (
    input   wire            i_riscv_lsu_clk          ,
    input   wire            i_riscv_lsu_rst          ,
    input   wire            i_riscv_lsu_globstall    ,
    input   wire  [63:0]    i_riscv_lsu_address      , //  rs1
    input   wire  [63:0]    i_riscv_lsu_alu_result   ,
    input   wire  [1:0]     i_riscv_lsu_lr           , //  [1] bit indicates LR or not, [0] indicates word or double word
    input   wire  [1:0]     i_riscv_lsu_sc           , //  [1] bit indicates SC or not, [0] indicates word or double word
    input   wire            i_riscv_lsu_amo          ,
    input   wire            i_riscv_lsu_dcache_wren  ,
    input   wire            i_riscv_lsu_dcache_rden  ,
    input   wire            i_riscv_lsu_goto_trap    , //  output of CSR
    input   wire  [1:0]     i_riscv_lsu_return_trap  , //  output of CSR
    input   wire            i_riscv_lsu_misalignment , //  <-- not added in the reg
    output  reg            o_riscv_lsu_dcache_wren  ,
    output  reg            o_riscv_lsu_dcache_rden  ,
    output  reg  [63:0]    o_riscv_lsu_phy_address  ,
    output  reg  [63:0]    o_riscv_lsu_sc_rdvalue   ,
    output  reg            o_riscv_lsu_timer_wren   ,
    output  reg            o_riscv_lsu_timer_rden   ,
    output  reg  [1:0]     o_riscv_lsu_timer_regsel 
  );

  //****************** internal signals declaration ******************//
  reg [63:0]  reserv_addr     ;
  reg         reserv_valid    ;
  reg         lr_word         ;
  wire [4:0]   case_sel        ;
  wire         sc_success_flag ;

  //****************** enum declaration ******************//
  localparam  NORMAL_READ  = 5'b10000,
              NORMAL_WRITE = 5'b01000,
              LR           = 5'b00100,
              SC           = 5'b00010,
              AMO          = 5'b00001;

  /**********************************************/
  localparam  MTIME     = 2'b01,
              MTIMECMP  = 2'b10;

  //****************** Internal Connections ******************//
  assign case_sel         = { i_riscv_lsu_dcache_rden,
                              i_riscv_lsu_dcache_wren,
                              i_riscv_lsu_lr[1],
                              i_riscv_lsu_sc[1],
                              i_riscv_lsu_amo};

  assign sc_success_flag  = ( (i_riscv_lsu_address ==  reserv_addr) &&
                              (reserv_valid)                        &&
                              (lr_word == i_riscv_lsu_sc [0])       &&
                              (i_riscv_lsu_sc[1])                   &&
                              (!i_riscv_lsu_goto_trap )             &&
                              (!i_riscv_lsu_return_trap));

  //****************** Procedural Blocks ******************//
  always @(posedge i_riscv_lsu_clk or posedge i_riscv_lsu_rst)
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
      if(i_riscv_lsu_lr[1])
      begin    
        reserv_addr   <= i_riscv_lsu_address ;
        reserv_valid  <= 1'b1 ;
        lr_word       <=  (i_riscv_lsu_lr[0])?  1'b1:1'b0;
      end

      //Store Conditional operation, any SC validates the reservation
      else if (i_riscv_lsu_sc[1])
      begin   
        reserv_valid  <= 1'b0 ;
        reserv_addr   <=  'b0 ;
      end
      
    end
  end

  //****************** Combinational for outputs ******************//
  //--> Value written to Rd
  always @(*)
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
  always @(*)
  begin
    if((i_riscv_lsu_alu_result == CLINT_MTIME) || (i_riscv_lsu_alu_result == CLINT_MTIMECMP))
    begin
      o_riscv_lsu_dcache_rden   = 1'b0;
      o_riscv_lsu_dcache_wren   = 1'b0;
      o_riscv_lsu_phy_address   =  'b0;
    end
    else
    begin
      case(case_sel)  
        NORMAL_READ:
        begin
          o_riscv_lsu_dcache_rden   = i_riscv_lsu_dcache_rden && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_dcache_wren   = 1'b0;
          o_riscv_lsu_phy_address   = i_riscv_lsu_alu_result;
        end

        NORMAL_WRITE:
        begin
          o_riscv_lsu_dcache_rden   = 1'b0;
          o_riscv_lsu_dcache_wren   = i_riscv_lsu_dcache_wren && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_phy_address   = i_riscv_lsu_alu_result;
        end

        LR :
        begin
          o_riscv_lsu_dcache_rden   = i_riscv_lsu_lr[1]  && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_dcache_wren   = 1'b0;
          o_riscv_lsu_phy_address   = i_riscv_lsu_address;
        end

        SC :
        begin
          o_riscv_lsu_dcache_rden   = 1'b0;
          o_riscv_lsu_dcache_wren   = (sc_success_flag)? 1'b1:1'b0;
          o_riscv_lsu_phy_address   = i_riscv_lsu_address;
        end

        AMO:
        begin
          o_riscv_lsu_dcache_rden   = i_riscv_lsu_dcache_rden && !i_riscv_lsu_goto_trap && !i_riscv_lsu_return_trap;
          o_riscv_lsu_dcache_wren   = 1'b0;
          o_riscv_lsu_phy_address   = i_riscv_lsu_address;
        end

        default:
        begin
          o_riscv_lsu_dcache_rden   = 1'b0;
          o_riscv_lsu_dcache_wren   = 1'b0;
          o_riscv_lsu_phy_address   =  'b0;
        end
      endcase
    end
  end

  // --> Timer Interrupt signals
  always @(*)
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

  always @(*)
  begin
    case(i_riscv_lsu_alu_result)
      CLINT_MTIME:    o_riscv_lsu_timer_regsel = MTIME;
      CLINT_MTIMECMP: o_riscv_lsu_timer_regsel = MTIMECMP;
      default:        o_riscv_lsu_timer_regsel = 2'b00;
    endcase
  end
endmodule
