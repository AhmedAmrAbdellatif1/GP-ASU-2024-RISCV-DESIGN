module riscv_branch

    (
            input  logic         [3:0]      i_riscv_branch_cond    , 
            input  logic signed [ 63:0 ]    i_riscv_branch_rs1data ,   
            input  logic signed [ 63:0 ]    i_riscv_branch_rs2data , 
            output logic signed             o_riscv_branch_taken
    );
   

 logic LT,GT,EQ;
//logic negelect ;
//logic [2:0] check_condotion ; 
//assign {negelect,check_condotion} = i_riscv_branch_cond  ;

typedef enum logic [2:0] {beq = 0 , bne = 1 , blt=4 , bge = 5 , bltu=6,bgeu=7} States ;

assign EQ = (i_riscv_branch_rs1data==i_riscv_branch_rs2data)? 1:0;  
  
always @(*) 
begin 
    case (i_riscv_branch_cond[1])


        1 : begin
                assign LT = ($unsigned(i_riscv_branch_rs1data) < $unsigned(i_riscv_branch_rs2data)) ? 1:0;
                //assign GT = ($unsigned(i_riscv_branch_rs1data) > $unsigned(i_riscv_branch_rs2data)) ? 1:0;
                assign GT = (~LT) && (~EQ) ? 1:0;
            end 
        0 : begin
                assign LT = (i_riscv_branch_rs1data < i_riscv_branch_rs2data) ? 1:0;
                //assign GT = (i_riscv_branch_rs1data > i_riscv_branch_rs2data) ? 1:0;
                assign GT = (~LT) && (~EQ) ? 1:0;
            end
    endcase
end



always @(*) 

    begin

        /*if (rst)
                                               
            o_riscv_branch_taken=0;
        else  */
        
        if (i_riscv_branch_cond[3]) 
            begin
       
                case (i_riscv_branch_cond[2:0])
                
                //equlaity , non equality doesnt mean either signed/unsigned 
                    beq:  assign o_riscv_branch_taken =  (  EQ )    ? 1 : 0 ;  //beq
                    bne:  assign o_riscv_branch_taken =  ( ~EQ )    ? 1 : 0 ;  //bne
                //signed
                    blt:  assign o_riscv_branch_taken =  ( LT )     ? 1 : 0 ;  //blt  
                    bge:  assign o_riscv_branch_taken = (GT || EQ ) ? 1 : 0 ;  //bge
                //unsigned
                    bltu:  assign o_riscv_branch_taken =  ( LT )     ? 1 : 0 ;  //bltu
                    bgeu:  assign o_riscv_branch_taken = (GT || EQ ) ? 1 : 0 ;  //bgeu
                    default:        o_riscv_branch_taken = 0 ;

                endcase     
            end    

        else 
                o_riscv_branch_taken=0 ;
        

    end

/*always @(*) 
begin 
    case (i_riscv_branch_cond[1])

        1 : begin
                assign LT = (i_riscv_branch_rs1data < i_riscv_branch_rs2data) ? 1:0;
                assign GT = (i_riscv_branch_rs1data > i_riscv_branch_rs2data) ? 1:0;
            end 
        0 : begin
                assign LT = ($signed(i_riscv_branch_rs1data) < $signed(i_riscv_branch_rs2data)) ? 1:0;
                assign GT = ($signed(i_riscv_branch_rs1data) > $signed(i_riscv_branch_rs2data)) ? 1:0;
            end
    endcase
end*/
            
     endmodule



     
