module riscv_branch (
  input  logic         [3:0]      i_riscv_branch_cond    , 
  input  logic signed [ 63:0 ]    i_riscv_branch_rs1data ,   
  input  logic signed [ 63:0 ]    i_riscv_branch_rs2data , 
  output logic signed             o_riscv_branch_taken
  );

  logic EQ,LT,LTU;

  assign EQ  = (i_riscv_branch_rs1data==i_riscv_branch_rs2data)? 1:0;
  assign LT  = (i_riscv_branch_rs1data<i_riscv_branch_rs2data)? 1:0;
  assign LTU = ($unsigned(i_riscv_branch_rs1data)<$unsigned(i_riscv_branch_rs2data))? 1:0;

  always @(*) 
    begin
        if (i_riscv_branch_cond[3]) 
          begin
            case (i_riscv_branch_cond[2:0])
            //equality , non equality doesnt mean either signed/unsigned 
                3'b000:   o_riscv_branch_taken =  (  EQ )    ? 1 : 0 ;  //beq
                3'b001:   o_riscv_branch_taken =  ( ~EQ )    ? 1 : 0 ;  //bne
            //signed
                3'b100:   o_riscv_branch_taken =  (  LT )    ? 1 : 0 ;  //blt  
                3'b101:   o_riscv_branch_taken =  ( ~LT )    ? 1 : 0 ;  //bge
            //unsigned
                3'b110:   o_riscv_branch_taken =  (  LTU )   ? 1 : 0 ;  //bltu
                3'b111:   o_riscv_branch_taken =  ( ~LTU )   ? 1 : 0 ;  //bgeu
                default:  o_riscv_branch_taken = 0 ;
            endcase     
          end    
        else 
          o_riscv_branch_taken=0 ;
    end
endmodule



     
