module riscv_hazardunit (
   input  logic   [4:0]   i_riscv_hzrdu_rs1addr_d     ,
   input  logic   [4:0]   i_riscv_hzrdu_rs2addr_d     ,
   input  logic   [4:0]   i_riscv_hzrdu_rs1addr_e     ,
   input  logic   [4:0]   i_riscv_hzrdu_rs2addr_e     ,
   input  logic   [4:0]   i_riscv_hzrdu_rdaddr_m      ,
   input  logic   [4:0]   i_riscv_hzrdu_rdaddr_w      ,
   input  logic   [6:0]   i_riscv_hzrdu_opcode_m      ,
   input  logic           i_riscv_hzrdu_pcsrc         ,
   input  logic           i_riscv_hzrdu_regw_m        ,
   input  logic           i_riscv_hzrdu_regw_w        ,
   input  logic   [1:0]   i_riscv_hzrdu_resultsrc_e   ,
   input  logic   [4:0]   i_riscv_hzrdu_rdaddr_e      ,
   input  logic           i_riscv_dcahe_stall_m       ,     //<--------------
   input  logic           i_riscv_hzrdu_mul_en        , 
   input  logic           i_riscv_hzrdu_div_en        ,
   input  logic           i_riscv_hzrdu_valid         ,
   output logic   [1:0]   o_riscv_hzrdu_fwda          , 
   output logic   [1:0]   o_riscv_hzrdu_fwdb          , 
   output logic           o_riscv_hzrdu_stallpc       ,
   output logic           o_riscv_hzrdu_stallfd       ,
   output logic           o_riscv_hzrdu_flushfd       ,
   output logic           o_riscv_hzrdu_flushde       ,
   output logic           o_riscv_hzrdu_stallde       ,
   output logic           o_riscv_hzrdu_stallem       ,
   output logic           o_riscv_hzrdu_stallmw       );

  logic m_stall,glob_stall;

  assign m_stall=(i_riscv_hzrdu_mul_en || i_riscv_hzrdu_div_en)&!i_riscv_hzrdu_valid;
  assign glob_stall= (i_riscv_dcahe_stall_m) | m_stall;

always @(*)
  begin 
    if  ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_m ) &&
          (i_riscv_hzrdu_regw_m ) && (i_riscv_hzrdu_rdaddr_m !=0) && i_riscv_hzrdu_opcode_m == 7'b0110111 )
      begin
        o_riscv_hzrdu_fwdb = 3 ;
      end


  else if ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_m ) && (i_riscv_hzrdu_regw_m ) && (i_riscv_hzrdu_rdaddr_m !=0) )
      begin
        o_riscv_hzrdu_fwdb = 2  ;
      end

  else if ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_w ) &&
            (i_riscv_hzrdu_regw_w ) && (i_riscv_hzrdu_rdaddr_w !=0 ) )
      begin
        o_riscv_hzrdu_fwdb = 1 ;
      end
  
  else 
      o_riscv_hzrdu_fwdb = 0 ; 
  end


always @(*)
  begin 
    if ( (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && 
         (i_riscv_hzrdu_regw_m) && (i_riscv_hzrdu_rdaddr_m !=0) && i_riscv_hzrdu_opcode_m == 7'b0110111 )
      begin
        o_riscv_hzrdu_fwda  = 3  ;
      end

  else if ( (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && 
            (i_riscv_hzrdu_regw_m) && (i_riscv_hzrdu_rdaddr_m !=0) )
    begin
      o_riscv_hzrdu_fwda  = 2  ;
    end

  else if ( i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_w && 
          i_riscv_hzrdu_regw_w && (i_riscv_hzrdu_rdaddr_w !=0 ) )
    begin
      o_riscv_hzrdu_fwda  = 1 ;
    end
  else 
    o_riscv_hzrdu_fwda  = 0 ; 
  end

always @(*) 
  begin 
    if ( ( (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e  ) && 
            i_riscv_hzrdu_resultsrc_e == 2'b10 ) || m_stall)
        begin
          o_riscv_hzrdu_stallpc = 1 ;
          o_riscv_hzrdu_stallfd = 1 ;
        end
    else     
        begin
          o_riscv_hzrdu_stallpc = 0 ;
          o_riscv_hzrdu_stallfd = 0 ;  
        end
  end

  always @(*)
    begin
      if( ( (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e  ) && 
          i_riscv_hzrdu_resultsrc_e == 2'b10 ) || i_riscv_hzrdu_pcsrc )
          o_riscv_hzrdu_flushde = 1 ;
      else
          o_riscv_hzrdu_flushde = 0 ;        
    end

assign o_riscv_hzrdu_flushfd =  ( i_riscv_hzrdu_pcsrc )? 1 : 0 ;

///////////////////////////////mult/div stalling/////////////////////
always_comb
  begin
    if(glob_stall)
    begin
      o_riscv_hzrdu_stallmw=1;
      o_riscv_hzrdu_stallem=1;
      o_riscv_hzrdu_stallde=1;
    end
  else
  begin
      o_riscv_hzrdu_stallmw=0;
      o_riscv_hzrdu_stallem=0;
      o_riscv_hzrdu_stallde=0;
    end
  end
endmodule