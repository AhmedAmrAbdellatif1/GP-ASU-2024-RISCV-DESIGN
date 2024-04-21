module riscv_timer_irq (
    input   logic         i_riscv_timer_clk     ,
    input   logic         i_riscv_timer_rst     ,
    input   logic         i_riscv_timer_wren    ,
    input   logic         i_riscv_timer_rden    ,
    input   logic [1:0]   i_riscv_timer_regsel  ,
    input   logic [63:0]  i_riscv_timer_wdata   ,
    output  logic [63:0]  o_riscv_timer_rdata   ,
    output  logic [63:0]  o_riscv_timer_time    ,
    output  logic [63:0]  o_riscv_timer_timecmp ,
    output  logic         o_riscv_timer_irq   
  );

  /**********************************************/
  logic [63:0] mtime    ;
  logic [63:0] mtimecmp ;

  /**********************************************/
  typedef enum logic [1:0] {
    MTIME     = 2'b01,
    MTIMECMP  = 2'b10
  } timer_address ;

  /**********************************************/
  assign o_riscv_timer_time     = mtime;
  assign o_riscv_timer_timecmp  = mtimecmp;

  /**********************************************/
  always_ff @( posedge i_riscv_timer_clk or posedge i_riscv_timer_rst )
  begin : riscv_mtime_proc
    if(i_riscv_timer_rst)
      mtime <= 64'b0;
    else if(i_riscv_timer_wren && (i_riscv_timer_regsel == MTIME))
      mtime <= i_riscv_timer_wdata;
    else
      mtime <= mtime + 1'b1;
  end

  /**********************************************/
  always_ff @( posedge i_riscv_timer_clk or posedge i_riscv_timer_rst )
  begin : riscv_mtimecmp_proc
    if(i_riscv_timer_rst)
      mtimecmp <= 64'b0;
    else if(i_riscv_timer_wren && (i_riscv_timer_regsel == MTIMECMP))
      mtimecmp <= i_riscv_timer_wdata;
  end

  /**********************************************/
  always_comb
  begin
    if( (mtimecmp) && (mtime >= mtimecmp) )
      o_riscv_timer_irq = 1'b1;
    else
      o_riscv_timer_irq = 1'b0;
  end

  /**********************************************/
  always_comb
  begin
    if(i_riscv_timer_rden)
    begin
      case(i_riscv_timer_regsel)
        MTIME:    o_riscv_timer_rdata = mtime     ;
        MTIMECMP: o_riscv_timer_rdata = mtimecmp  ;
        default:  o_riscv_timer_rdata = 64'b0     ;
      endcase
    end
    else
      o_riscv_timer_rdata = 64'b0;
  end

endmodule