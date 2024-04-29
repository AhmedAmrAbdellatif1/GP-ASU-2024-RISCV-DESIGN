module riscv_hazardunit (
  input  wire   [4:0]  i_riscv_hzrdu_rs1addr_d     ,
  input  wire   [4:0]  i_riscv_hzrdu_rs2addr_d     ,
  input  wire   [4:0]  i_riscv_hzrdu_rs1addr_e     ,
  input  wire   [4:0]  i_riscv_hzrdu_rs2addr_e     ,
  input  wire   [4:0]  i_riscv_hzrdu_rdaddr_m      ,
  input  wire   [4:0]  i_riscv_hzrdu_rdaddr_w      ,
  input  wire   [6:0]  i_riscv_hzrdu_opcode_m      ,
  input  wire          i_riscv_hzrdu_pcsrc         ,
  input  wire          i_riscv_hzrdu_regw_m        ,
  input  wire          i_riscv_hzrdu_regw_w        ,
  input  wire   [2:0]  i_riscv_hzrdu_resultsrc_e   ,
  input  wire   [4:0]  i_riscv_hzrdu_rdaddr_e      ,
  input  wire          i_riscv_dcahe_stall_m       ,
  input  wire          i_riscv_icahe_stall_m       ,
  input  wire          i_riscv_hzrdu_mul_en        , 
  input  wire          i_riscv_hzrdu_div_en        ,
  input  wire          i_riscv_hzrdu_valid         ,
  input  wire          i_riscv_hzrdu_iscsr_e       , //<--- TRAPS AND CSR
  input  wire          i_riscv_hzrdu_iscsr_d       , //<--- TRAPS AND CSR
  input  wire          i_riscv_hzrdu_iscsr_w       , //<--- TRAPS AND CSR
  input  wire          i_riscv_hzrdu_iscsr_m       , //<--- TRAPS AND CSR
  input  wire  [4:0]   i_riscv_hzrdu_rs1addr_m     , //<--- TRAPS AND CSR
  output reg           o_riscv_hzrdu_passwb        , //<--- TRAPS AND CSR
  output reg   [1:0]   o_riscv_hzrdu_fwda          , 
  output reg   [1:0]   o_riscv_hzrdu_fwdb          , 
  output reg           o_riscv_hzrdu_stallpc       ,
  output reg           o_riscv_hzrdu_stallfd       ,
  output reg           o_riscv_hzrdu_flushde       ,
  output reg           o_riscv_hzrdu_stallde       ,
  output reg           o_riscv_hzrdu_stallem       ,
  output reg           o_riscv_hzrdu_stallmw       ,
  output wire          o_riscv_hzrdu_flushfd       ,
  output wire          o_riscv_hzrdu_globstall
  );

  wire m_stall,glob_stall;

/************************ Flags ************************/
  assign o_riscv_hzrdu_globstall  = glob_stall;
  assign m_stall                  = ( i_riscv_hzrdu_mul_en      || i_riscv_hzrdu_div_en)  &&  (!i_riscv_hzrdu_valid);
  assign glob_stall               = ((i_riscv_dcahe_stall_m)    || (m_stall) || (i_riscv_icahe_stall_m));

  assign branch_flush             =   i_riscv_hzrdu_pcsrc;

  assign rs1_dependency_de        = ( i_riscv_hzrdu_rs1addr_d   == i_riscv_hzrdu_rdaddr_e);
  assign rs2_dependency_de        = ((i_riscv_hzrdu_rs2addr_d   == i_riscv_hzrdu_rdaddr_e) && (!i_riscv_hzrdu_iscsr_d));
  assign load_dependency          = ( i_riscv_hzrdu_resultsrc_e == 2'b10);
  assign csr_dependency_de        = ( i_riscv_hzrdu_iscsr_e     && ~i_riscv_hzrdu_iscsr_d );

  assign rs2_dependency_em        = ((i_riscv_hzrdu_rs2addr_e   == i_riscv_hzrdu_rdaddr_m ) && (!i_riscv_hzrdu_iscsr_e));
  assign rs2_dependency_ew        = ((i_riscv_hzrdu_rs2addr_e   == i_riscv_hzrdu_rdaddr_w ) && (!i_riscv_hzrdu_iscsr_e));

  assign rs1_dependency_em        = (i_riscv_hzrdu_rs1addr_e    == i_riscv_hzrdu_rdaddr_m);
  assign rs1_dependency_ew        = (i_riscv_hzrdu_rs1addr_e    == i_riscv_hzrdu_rdaddr_w);

/************************ Forward Mux A ************************/
  always @(*)
    begin 
      if (  (rs1_dependency_em) && 
            (i_riscv_hzrdu_regw_m) &&
            (i_riscv_hzrdu_rdaddr_m != 0  ) &&
            (i_riscv_hzrdu_opcode_m == 7'b0110111) )
        begin
          o_riscv_hzrdu_fwda = 'd3  ;
        end

      else if ( (rs1_dependency_em) && 
                (i_riscv_hzrdu_regw_m) &&
                (i_riscv_hzrdu_rdaddr_m != 0  ) )
        begin
          o_riscv_hzrdu_fwda  = 'd2  ;
        end

      else if ( (rs1_dependency_ew) && 
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
      if  ( (rs2_dependency_em ) &&
            (i_riscv_hzrdu_regw_m ) &&
            (i_riscv_hzrdu_rdaddr_m != 0 ) &&
            (i_riscv_hzrdu_opcode_m == 7'b0110111) )
          begin
            o_riscv_hzrdu_fwdb = 'd3 ;
          end
  
      else if ( (rs2_dependency_em ) &&
                (i_riscv_hzrdu_regw_m ) &&
                (i_riscv_hzrdu_rdaddr_m != 0 ) )
          begin
            o_riscv_hzrdu_fwdb = 'd2  ;
          end
  
      else if ( (rs2_dependency_ew ) &&
                (i_riscv_hzrdu_regw_w ) &&
                (i_riscv_hzrdu_rdaddr_w != 0 ) )
          begin
            o_riscv_hzrdu_fwdb = 'd1 ;
          end
          
      else 
          o_riscv_hzrdu_fwdb = 'd0 ; 
    end
          
/************************ Stalling ************************/
  always @(*) 
  begin 
    if( ((rs1_dependency_de || rs2_dependency_de) && (load_dependency || csr_dependency_de)) || glob_stall)
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

  always @(*)
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
  always @(*)
  begin
    if( ((rs1_dependency_de || rs2_dependency_de) && (load_dependency || csr_dependency_de) || branch_flush) && !glob_stall)
        o_riscv_hzrdu_flushde = 1'b1  ;
    else
        o_riscv_hzrdu_flushde = 1'b0  ;
  end

assign o_riscv_hzrdu_flushfd =  (branch_flush && !glob_stall)? 1'b1 : 1'b0 ;

/************************ CSR ************************/
  always @(*)
  begin
    if ((i_riscv_hzrdu_iscsr_m == 1'b1) &&
        (i_riscv_hzrdu_iscsr_w == 1'b1) &&
        (i_riscv_hzrdu_rdaddr_w == i_riscv_hzrdu_rs1addr_m))
        o_riscv_hzrdu_passwb = 1'b1 ;
    else
        o_riscv_hzrdu_passwb = 1'b0 ;
  end
endmodule