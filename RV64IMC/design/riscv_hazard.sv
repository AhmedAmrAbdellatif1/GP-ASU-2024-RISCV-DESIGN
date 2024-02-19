module riscv_hazardunit
//Combitional civuit no clk
//res_Src make 1 bit in document + stall pc make 2bits
 (
   input       [4:0]    i_riscv_hzrdu_rs1addr_d ,
                        i_riscv_hzrdu_rs2addr_d ,
                        i_riscv_hzrdu_rs1addr_e ,
                        i_riscv_hzrdu_rs2addr_e ,
                        i_riscv_hzrdu_rdaddr_m  ,
                        i_riscv_hzrdu_rdaddr_w , 
      input [6:0]       i_riscv_hzrdu_opcode_m,
     input              i_riscv_hzrdu_pcsrc ,
                        i_riscv_hzrdu_regw_m   ,
                        i_riscv_hzrdu_regw_w  ,
    // input op1,op2
   input       [1:0]   i_riscv_hzrdu_resultsrc_e   ,
  
   output logic  [1:0]   o_riscv_hzrdu_fwda  , 
                       o_riscv_hzrdu_fwdb , //Concept behind Forwarding unit

     output logic          o_riscv_hzrdu_stallpc  ,
                       o_riscv_hzrdu_stallfd  ,
                       o_riscv_hzrdu_flushfd ,
                       o_riscv_hzrdu_flushde ,
   //extra Siganls
    input      [4:0]     i_riscv_hzrdu_rdaddr_e ,
   // input                i_riscv_hzrdu_memw_m ,
   // input                i_riscv_hzrdu_memw_d 
  //output reg           o_riscv_hzrdu_fw_dc

/////////////////////////////////multiply &division/////////////////
input  logic                  i_riscv_hzrdu_mul_en,
input  logic                  i_riscv_hzrdu_div_en,
input  logic                  i_riscv_hzrdu_valid,
output logic                 o_riscv_hzrdu_stallde,
output logic                 o_riscv_hzrdu_stallem,
output logic                 o_riscv_hzrdu_stallmw
 );

logic m_stall;
assign m_stall=(i_riscv_hzrdu_mul_en || i_riscv_hzrdu_div_en)&!i_riscv_hzrdu_valid;

//Note : needing of mem_Asserted >>not useful i thimk if it is implented as priority mux will not check 2nd condition if 1st is satisfied
//assign mem_asserted_data_hazard = ( i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && i_riscv_hzrdu_regw_m && i_riscv_hzrdu_rdaddr_m ;

always @(*)

    begin 
       /*if(~rst_n) begin
             <= 0;
        end else begin */

        if      ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_m ) &&
                (i_riscv_hzrdu_regw_m ) && (i_riscv_hzrdu_rdaddr_e !=0)  &&
                (i_riscv_hzrdu_rdaddr_m !=0) && i_riscv_hzrdu_opcode_m == 7'b0110111 )
                    begin
                      o_riscv_hzrdu_fwdb = 3 ;
                    end

    
      else if      ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_m ) &&
                (i_riscv_hzrdu_regw_m ) && (i_riscv_hzrdu_rdaddr_e !=0)  &&
                (i_riscv_hzrdu_rdaddr_m !=0) )
                    begin
                      o_riscv_hzrdu_fwdb = 2  ;
                    end

        else if ( (i_riscv_hzrdu_rs2addr_e == i_riscv_hzrdu_rdaddr_w ) &&
                (i_riscv_hzrdu_regw_w )        && (i_riscv_hzrdu_rdaddr_e !=0)   &&
                (i_riscv_hzrdu_rdaddr_w !=0 ) )
                    begin
                      o_riscv_hzrdu_fwdb = 1 ;
                    end
        else 

                      o_riscv_hzrdu_fwdb = 0 ; 
    
    end


always @(*)

    begin 
        /*if(~rst_n) begin
             <= 0;
        end else begin */

        if      ( (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && 
                (i_riscv_hzrdu_regw_m) && (i_riscv_hzrdu_rdaddr_e !=0)    &&
                (i_riscv_hzrdu_rdaddr_m !=0) && i_riscv_hzrdu_opcode_m == 7'b0110111 )
                   begin
                     o_riscv_hzrdu_fwda  = 3  ;
                   end

      else if      ( (i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_m) && 
                (i_riscv_hzrdu_regw_m) && (i_riscv_hzrdu_rdaddr_e !=0)    &&
                (i_riscv_hzrdu_rdaddr_m !=0) )
                   begin
                     o_riscv_hzrdu_fwda  = 2  ;
                   end

        else if ( i_riscv_hzrdu_rs1addr_e == i_riscv_hzrdu_rdaddr_w && 
                i_riscv_hzrdu_regw_w && 
                (i_riscv_hzrdu_rdaddr_w !=0 ) && (i_riscv_hzrdu_rdaddr_e !=0) 
               )
                   begin
                     o_riscv_hzrdu_fwda  = 1 ;
                   end
        else 

                     o_riscv_hzrdu_fwda  = 0 ; 
    end


always @(*) 

    begin 
        /*if(~rst_n) 
         <= 0; else */
   
       /* if      ( ( (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rs1addr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rs1addr_e  ) && 
                i_riscv_hzrdu_resultsrc == 2'b10 ) || 
                i_riscv_hzrdu_pcsrc  ) //Condition For branch hazard */
         if      ( ( (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e  ) && 
                i_riscv_hzrdu_resultsrc_e == 2'b10 ) || m_stall) //Condition For branch hazard 
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
           if     ( ( (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e  ) && 
                i_riscv_hzrdu_resultsrc_e == 2'b10 ) || i_riscv_hzrdu_pcsrc ) //Condition For branch hazard   
                o_riscv_hzrdu_flushde = 1 ;
            else
                o_riscv_hzrdu_flushde = 0 ;        
        end


/*  supporting lw sw hazardalways @(*) 

    begin 
        /*if(~rst_n) 
         <= 0; else 
   
        if      ( ( (i_riscv_hzrdu_rs1addr_d == i_riscv_hzrdu_rdaddr_e ||  i_riscv_hzrdu_rs2addr_d == i_riscv_hzrdu_rdaddr_e  ) && 
                i_riscv_hzrdu_resultsrc == 2'b10 && i_risc_hzrdu_memwrite_d !=1) //dont stall if it is sw instruction || 
                i_riscv_hzrdu_pcsrc  ) //Condition For branch hazard

                  begin
                    o_riscv_hzrdu_stallpc = 1 ; 
                    o_riscv_hzrdu_stallfd = 1 ;  
                    o_riscv_hzrdu_flushde = 1 ; 
                  end
 
        else     
                  begin
                    o_riscv_hzrdu_stallpc = 0 ;
                    o_riscv_hzrdu_stallfd = 0 ;  
                    o_riscv_hzrdu_flushde = 0 ; 
                  end


    end    */


   /* supporting lw sw hazard 
   always @(*)

    begin 
        /*if(~rst_n) begin
             <= 0;
        end else begin */
/*
        if      ( (i_riscv_hzrdu_rs2addr_m == i_riscv_hzrdu_rdaddr_w) && 
               // (i_riscv_hzrdu_regw_m )
                 (i_riscv_hzrdu_regw_w ) && (i_risc_hzrdu_memwrite_m = 1 );
                (i_riscv_hzrdu_rdaddr_m !=0) )
                   begin
                     o_riscv_hzrdu_fw_dc  = 1  ;
                   end

        else 

                     o_riscv_hzrdu_fw_dc  = 0 ; 
    end
*/


assign o_riscv_hzrdu_flushfd =  ( i_riscv_hzrdu_pcsrc )? 1 : 0 ;

/*assign o_riscv_hzrdu_flushde = (i_riscv_hzrdu_pcsrc)?1:0 ;
assign o_riscv_hzrdu_stallfd = (i_riscv_hzrdu_pcsrc)?1:0;*/

///////////////////////////////mult/div stalling/////////////////////
always_comb
begin
  if(m_stall)
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




