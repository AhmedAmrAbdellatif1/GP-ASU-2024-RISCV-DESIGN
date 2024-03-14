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
  input  logic           i_riscv_dcahe_stall_m       ,
  input  logic           i_riscv_icahe_stall_m       ,
  input  logic           i_riscv_hzrdu_mul_en        , 
  input  logic           i_riscv_hzrdu_div_en        ,
  input  logic           i_riscv_hzrdu_valid         ,
  input  logic           i_riscv_hzrdu_iscsr_e       , //<--- TRAPS AND CSR
  input  logic           i_riscv_hzrdu_iscsr_d       , //<--- TRAPS AND CSR
  input  logic           i_riscv_hzrdu_iscsr_w       , //<--- TRAPS AND CSR
  input logic            i_riscv_hzrdu_iscsr_m       , //<--- TRAPS AND CSR
  input logic    [4:0]   i_riscv_hzrdu_rs1addr_m     , //<--- TRAPS AND CSR
  output logic           o_riscv_hzrdu_passwb        , //<--- TRAPS AND CSR
  output logic   [1:0]   o_riscv_hzrdu_fwda          , 
  output logic   [1:0]   o_riscv_hzrdu_fwdb          , 
  output logic           o_riscv_hzrdu_stallpc       ,
  output logic           o_riscv_hzrdu_stallfd       ,
  output logic           o_riscv_hzrdu_flushfd       ,
  output logic           o_riscv_hzrdu_flushde       ,
  output logic           o_riscv_hzrdu_stallde       ,
  output logic           o_riscv_hzrdu_stallem       ,
  output logic           o_riscv_hzrdu_stallmw       ,
  output logic           o_riscv_hzrdu_globstall
  );

  logic m_stall,glob_stall;

/************************ Flags ************************/
  assign m_stall    = (i_riscv_hzrdu_mul_en || i_riscv_hzrdu_div_en)  & (!i_riscv_hzrdu_valid);
  assign glob_stall = ((i_riscv_dcahe_stall_m) || (m_stall) || (i_riscv_icahe_stall_m));
  assign o_riscv_hzrdu_globstall = glob_stall;

/************************ Forward Mux A ************************/
  always @(*)
    begin 
      if (  (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && 
            (i_riscv_hzrdu_regw_m) &&
            (i_riscv_hzrdu_rdaddr_m != 0  ) &&
            (i_riscv_hzrdu_opcode_m == 7'b0110111) )
        begin
          o_riscv_hzrdu_fwda = 'd3  ;
        end

      else if ( (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && 
                (i_riscv_hzrdu_regw_m) &&
                (i_riscv_hzrdu_rdaddr_m != 0  ) )
        begin
          o_riscv_hzrdu_fwda  = 'd2  ;
        end

      else if ( (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_w) && 
                (i_riscv_hzrdu_regw_w) &&
                (i_riscv_hzrdu_rdaddr_w != 0 ) )
        begin
          o_riscv_hzrdu_fwda  = 'd1 ;
        end

      else 
          o_riscv_hzrdu_fwda  = 'd0 ; 
  end

/************************ Forward Mux B ************************/
  always @(*)
    begin 
      if  ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_m ) &&
            (i_riscv_hzrdu_regw_m ) &&
            (i_riscv_hzrdu_rdaddr_m != 0 ) &&
            (i_riscv_hzrdu_opcode_m == 7'b0110111) )
          begin
            o_riscv_hzrdu_fwdb = 'd3 ;
          end
  
      else if ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_m ) &&
                (i_riscv_hzrdu_regw_m ) &&
                (i_riscv_hzrdu_rdaddr_m != 0 ) )
          begin
            o_riscv_hzrdu_fwdb = 'd2  ;
          end
  
      else if ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_w ) &&
                (i_riscv_hzrdu_regw_w ) &&
                (i_riscv_hzrdu_rdaddr_w != 0 ) )
          begin
            o_riscv_hzrdu_fwdb = 'd1 ;
          end
          
      else 
          o_riscv_hzrdu_fwdb = 'd0 ; 
    end
          
/************************ Stalling ************************/
  always_comb 
  begin 
    if (  ( (  (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e) ||
               ( (i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e) && (!i_riscv_hzrdu_iscsr_d) ) ) && 
            (i_riscv_hzrdu_resultsrc_e == 2'b10 || ( i_riscv_hzrdu_iscsr_e == 1'b1 &&  ~i_riscv_hzrdu_iscsr_d  ))) ||
        glob_stall)
        begin
          o_riscv_hzrdu_stallpc = 1'b1 ;
          o_riscv_hzrdu_stallfd = 1'b1 ;
        end
    else     
        begin
          o_riscv_hzrdu_stallpc = 1'b0 ;
          o_riscv_hzrdu_stallfd = 1'b0 ;  
        end
  end

  always_comb
  begin
    if(glob_stall)
      begin
        o_riscv_hzrdu_stallmw = 1'b1  ;
        o_riscv_hzrdu_stallem = 1'b1  ;
        o_riscv_hzrdu_stallde = 1'b1  ;
      end
    else
      begin
        o_riscv_hzrdu_stallmw = 1'b0 ;
        o_riscv_hzrdu_stallem = 1'b0 ;
        o_riscv_hzrdu_stallde = 1'b0 ;
      end
  end

/************************ Flushing ************************/
  always_comb
  begin
    if( (((i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e  ) && 
          ( i_riscv_hzrdu_resultsrc_e == 2'b10 ||  ( i_riscv_hzrdu_iscsr_e == 1'b1 && ~i_riscv_hzrdu_iscsr_d ))
          ) || i_riscv_hzrdu_pcsrc )  && !glob_stall)
        o_riscv_hzrdu_flushde = 1'b1  ;
    else
        o_riscv_hzrdu_flushde = 1'b0  ;        
  end

assign o_riscv_hzrdu_flushfd =  ( i_riscv_hzrdu_pcsrc && !glob_stall)? 1'b1 : 1'b0 ;

/************************ CSR ************************/

  always_comb
  begin
    if (  (i_riscv_hzrdu_iscsr_m == 1'b1) &&
          (i_riscv_hzrdu_iscsr_w == 1'b1) &&
          (i_riscv_hzrdu_rdaddr_w == i_riscv_hzrdu_rs1addr_m))
        o_riscv_hzrdu_passwb = 1'b1 ;
    else
        o_riscv_hzrdu_passwb = 1'b0 ;        
  end
endmodule
