module riscv_timer_irq (
    input   wire         i_riscv_timer_clk     ,
    input   wire         i_riscv_timer_rst     ,
    input   wire         i_riscv_timer_wren    ,
    input   wire         i_riscv_timer_rden    ,
    input   wire [1:0]   i_riscv_timer_regsel  ,
    input   wire [63:0]  i_riscv_timer_wdata   ,
    output  wire [63:0]  o_riscv_timer_time    ,
    output  reg [63:0]  o_riscv_timer_rdata   ,
    output  reg         o_riscv_timer_irq   
  );

  /**********************************************/
  reg [63:0] mtime    ;
  reg [63:0] mtimecmp ;

  /**********************************************/
  localparam  MTIME     = 2'b01,
              MTIMECMP  = 2'b10;

  /**********************************************/
  assign o_riscv_timer_time     = mtime;

  /**********************************************/
  always @( posedge i_riscv_timer_clk or posedge i_riscv_timer_rst )
  begin : riscv_mtime_proc
    if(i_riscv_timer_rst)
      mtime <= 64'b0;
    else if(i_riscv_timer_wren && (i_riscv_timer_regsel == MTIME))
      mtime <= i_riscv_timer_wdata;
    else
      mtime <= mtime + 1'b1;
  end

  /**********************************************/
  always @( posedge i_riscv_timer_clk or posedge i_riscv_timer_rst )
  begin : riscv_mtimecmp_proc
    if(i_riscv_timer_rst)
      mtimecmp <= 64'b0;
    else if(i_riscv_timer_wren && (i_riscv_timer_regsel == MTIMECMP))
      mtimecmp <= i_riscv_timer_wdata;
  end

  /**********************************************/
  always @(*)
  begin
    if( (mtimecmp) && (mtime >= mtimecmp) )
      o_riscv_timer_irq = 1'b1;
    else
      o_riscv_timer_irq = 1'b0;
  end

  /**********************************************/
  always @(*)
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