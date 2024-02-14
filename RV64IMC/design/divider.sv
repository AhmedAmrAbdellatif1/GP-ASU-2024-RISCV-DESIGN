module riscv_divider(
input  logic          [2:0]    i_riscv_div_divctrl,
input  logic  signed  [63:0]   i_riscv_div_rs2data, i_riscv_div_rs1data,
output logic  signed  [63:0]   o_riscv_div_result
);


// Variables
integer i;
logic    [64:0] i_riscv_div_rs2data_copy;
logic    [64:0] i_riscv_div_rs1data_copy;
logic    [64:0] temp;


always_comb 
begin
	temp = 0;
	///////////////////////////////////////divider/////////////////////////
	if(!i_riscv_div_divctrl[0]&&i_riscv_div_rs2data[63])
	i_riscv_div_rs2data_copy = ~i_riscv_div_rs2data+1;
	else if (i_riscv_div_divctrl[0])
	i_riscv_div_rs2data_copy={0,i_riscv_div_rs2data};
    else
	i_riscv_div_rs2data_copy=i_riscv_div_rs2data;
  ////////////////////////////////////dividend/////////////////////////////
   if (!i_riscv_div_divctrl[0]&&i_riscv_div_rs1data[63])
	i_riscv_div_rs1data_copy = ~i_riscv_div_rs1data+1;
	else if (i_riscv_div_divctrl[0])
	i_riscv_div_rs1data_copy = {0,i_riscv_div_rs1data};
	else
	i_riscv_div_rs1data_copy = i_riscv_div_rs1data;


	for(i = 0;i < 64;i = i + 1)
	begin
		temp = {temp[62:0], i_riscv_div_rs1data_copy[63]};
		i_riscv_div_rs1data_copy[63:1] = i_riscv_div_rs1data_copy[62:0];
		/*
			* Substract the i_riscv_div_rs2data Register from the Remainder Register and
			* plave the result in remainder register (temp variable here!)
		*/
		temp = temp - i_riscv_div_rs2data_copy;
		// Compare the Sign of Remainder Register (temp)
		if(temp[63] == 1)
		begin
		/*
			* Restore original value by adding the i_riscv_div_rs2data Register to the
			* Remainder Register and placing the sum in Remainder Register.
			* Shift Quatient by 1 and Add 0 to last bit.
		*/
			i_riscv_div_rs1data_copy[0] = 0;
			temp = temp + i_riscv_div_rs2data_copy;
		end
		else
		begin
		/*
			* Shift Quatient to left.
			* Set right most bit to 1.
		*/
			i_riscv_div_rs1data_copy[0] = 1;
		end
	end



	//////////////////////////////////////control////////////////////////////
	case (i_riscv_div_divctrl)

    /////////////////////////////////////////div////////////////////
	3'b100: begin
	if (i_riscv_div_rs2data==0)              //division by 0
	o_riscv_div_result =-1;
	else if ((i_riscv_div_rs1data==-(2**63))&&(i_riscv_div_rs2data==-1) )        //overflow
	o_riscv_div_result=i_riscv_div_rs1data ;
	else begin
	if (i_riscv_div_rs1data[63]==i_riscv_div_rs2data[63])
	begin
	o_riscv_div_result = i_riscv_div_rs1data_copy;
	end
	else 
	begin
	o_riscv_div_result = ~i_riscv_div_rs1data_copy+1;
	end
	end

	end
  /////////////////////////////////////////divu////////////////////
	3'b101: begin                             //divu
			if (i_riscv_div_rs2data==0)              //division by 0
			o_riscv_div_result= (2**64)-1;
			else
			begin
		    if(i_riscv_div_rs2data[63])
			begin  
				if({0,i_riscv_div_rs2data}>{0,i_riscv_div_rs1data})
		    o_riscv_div_result=0;
			else 
			 o_riscv_div_result=1;
			end
			else
			o_riscv_div_result=(i_riscv_div_rs1data_copy);
	        end    
	end
   /////////////////////////////////////////rem////////////////////
	3'b110: begin                                 //rem
	        if (i_riscv_div_rs2data==0)              //division by 0
	        o_riscv_div_result=i_riscv_div_rs1data;
			else if ((i_riscv_div_rs1data==-(2**63))&&(i_riscv_div_rs2data==-1) )        //overflow
	        o_riscv_div_result=0 ; 

			else begin
            if (i_riscv_div_rs1data[63])          //remainder same sign as dividend
            o_riscv_div_result=~temp+1;         //2's complement
            else
            o_riscv_div_result=temp;
	        end
	end

   /////////////////////////////////////////remu////////////////////
	3'b111: begin
		    if (i_riscv_div_rs2data==0)              //division by 0
	        o_riscv_div_result=i_riscv_div_rs1data;

			else begin
		
		  if(i_riscv_div_rs2data[63])
			begin  
				if({0,i_riscv_div_rs2data}>{0,i_riscv_div_rs1data})
		    o_riscv_div_result=i_riscv_div_rs1data;
			else 
			o_riscv_div_result={0,i_riscv_div_rs1data}-{0,i_riscv_div_rs2data};
	        end
			else 
			o_riscv_div_result=temp;
	end
	end

	default: o_riscv_div_result=0;
	endcase
end

endmodule