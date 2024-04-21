module riscv_divider(
input                          i_riscv_div_clk,
input                          i_riscv_div_rst,
input  logic          [3:0]    i_riscv_div_divctrl,
input  logic  signed  [63:0]   i_riscv_div_rs2data, i_riscv_div_rs1data,
output logic  signed  [63:0]   o_riscv_div_result,
output logic                   o_riscv_div_valid
);

(* dont_touch = "yes" *) logic signed [127:0] Z,next_Z,Z_temp,Z_temp1;
(* dont_touch = "yes" *) logic valid,next_valid;
logic next_state, pres_state;
logic [5:0] count,next_count;
logic start;
assign start=i_riscv_div_divctrl[3];

logic signed [63:0] rs1_copy,rs2_copy;
logic signed [63:0] X,Y;
logic signed [31:0] z2c; // <<------------

parameter IDLE = 1'b0;
parameter START = 1'b1;

////////////////////////////////////////////operand 1//////////////////////////////
always_comb
begin
     if(!i_riscv_div_divctrl[0]&&i_riscv_div_rs1data[63] && i_riscv_div_divctrl[2])             //div,rem and signed numbers
       begin
		     rs1_copy=i_riscv_div_rs1data;
			 X=~rs1_copy+1;
       end

	   else if (!i_riscv_div_divctrl[0] && !i_riscv_div_divctrl[2])                           //divw,remw
	    begin
            rs1_copy={ {32 {i_riscv_div_rs1data[31]}} ,i_riscv_div_rs1data[31:0]}; 		
			if(i_riscv_div_rs1data[31])
		      X=~rs1_copy+1;
			else
			  X=rs1_copy;
	     end

		else if (i_riscv_div_divctrl[0] && !i_riscv_div_divctrl[2])                           //divuw,remuw
		begin
			  rs1_copy={ {32 {1'b0}} ,i_riscv_div_rs1data[31:0]}; 
              X=rs1_copy;
		end
		
      else 
        begin
			rs1_copy=i_riscv_div_rs1data;
            X=rs1_copy;
            end
end

////////////////////////////////////////////operand 2////////////////////////////////
always_comb
begin
     if(!i_riscv_div_divctrl[0]&&i_riscv_div_rs2data[63] && i_riscv_div_divctrl[2])             //div,rem and signed numbers
       begin
		     rs2_copy=i_riscv_div_rs2data;
             Y=~rs2_copy+1;
       end

	   else if (!i_riscv_div_divctrl[0] && !i_riscv_div_divctrl[2])                           //divw,remw
	    begin
            rs2_copy={ {32 {i_riscv_div_rs2data[31]}} ,i_riscv_div_rs2data[31:0]};
			if(i_riscv_div_rs2data[31])
		      Y=~rs2_copy+1;
			else
			  Y=rs2_copy;
	     end

		else if (i_riscv_div_divctrl[0] && !i_riscv_div_divctrl[2])                           //divuw,remuw
		begin
			  rs2_copy={ {32 {1'b0}} ,i_riscv_div_rs2data[31:0]};
              Y=rs2_copy;
		end

      else
        begin
			rs2_copy=i_riscv_div_rs2data;
            Y=rs2_copy;
            end
end


////////////////////////////////////////////////////////////output////////////////////////////
always_comb
begin
if(valid)
begin
case(i_riscv_div_divctrl)

4'b1100 :begin                               ///div
if (i_riscv_div_rs2data==0)              //division by 0
	o_riscv_div_result =-1;
	else if ((i_riscv_div_rs1data==-(2**63))&&(i_riscv_div_rs2data==-1) )        //overflow
	o_riscv_div_result=i_riscv_div_rs1data ;
	else begin
    if (i_riscv_div_rs1data[63]==i_riscv_div_rs2data[63])
	begin
	o_riscv_div_result = Z[63:0];
	end
	else 
	begin
	o_riscv_div_result = ~Z[63:0]+1;
	end
         end
end

4'b1000 :begin                               ///divw
if (i_riscv_div_rs2data[31:0]==0)              //division by 0
	o_riscv_div_result =-1;
	else if ((rs1_copy==-(2**63))&&(rs2_copy==-1) )        //overflow
	o_riscv_div_result=rs1_copy ;
	else begin
    if (rs1_copy[63]==rs2_copy[63])
	begin
	o_riscv_div_result = { {32 {Z[31]}},Z[31:0]};
	end
	else 
	begin
		z2c = ~(Z[31:0])+1;  // <<------------
	o_riscv_div_result = {{32{z2c[31]}},z2c}; // <<------------
	end
         end
end


4'b1101:                                  //divu
begin
    if (i_riscv_div_rs2data==0)              //division by 0
			o_riscv_div_result= (2**64)-1;
			else  begin
    if(i_riscv_div_rs2data[63])
		begin  
		if({1'b0,i_riscv_div_rs2data}>{1'b0,i_riscv_div_rs1data})
		o_riscv_div_result=0;
		else 
		 o_riscv_div_result=1;
		end
	else
   o_riscv_div_result = Z[63:0];
end
end

4'b1001:                                  //divuw
begin
    if (i_riscv_div_rs2data[31:0]==0)              //division by 0
			o_riscv_div_result= (2**64)-1;
			else  begin
    if(rs2_copy[63])
		begin  
		if({1'b0,rs2_copy}>{1'b0,rs1_copy})
		o_riscv_div_result=0;
		else 
		 o_riscv_div_result=1;
		end
	else
   o_riscv_div_result = { {32 {Z[31]}},Z[31:0]};
end
end


4'b1110: 
      begin                                 //rem
	        if (i_riscv_div_rs2data==0)              //division by 0
	        o_riscv_div_result=i_riscv_div_rs1data;
			else if ((i_riscv_div_rs1data==-(2**63))&&(i_riscv_div_rs2data==-1) )        //overflow
	        o_riscv_div_result=0 ; 

			else begin
    if (i_riscv_div_rs1data[63])
	begin
	o_riscv_div_result = ~Z[127:64]+1;
	end
	else 
	begin
	o_riscv_div_result = Z[127:64];
	end
end
end

4'b1010: 
      begin                                 //remw
	        if (i_riscv_div_rs2data[31:0]==0)              //division by 0
	        o_riscv_div_result=rs1_copy;
			else if ((rs1_copy==-(2**63))&&(rs2_copy==-1) )        //overflow
	        o_riscv_div_result=0 ; 

			else begin
    if (rs1_copy[63])
	begin
	o_riscv_div_result = ~ ({ {32 {Z[96]}},Z[96:64]})+1;
	end
	else 
	begin
	o_riscv_div_result = { {32 {Z[96]}},Z[96:64]};
	end
end
end



4'b1111:                                                //remu
    begin
		    if (i_riscv_div_rs2data==0)              //division by 0
	        o_riscv_div_result=i_riscv_div_rs1data;

			else begin
     if(i_riscv_div_rs2data[63])
			begin  
				if({1'b0,i_riscv_div_rs2data}>{1'b0,i_riscv_div_rs1data})
		    o_riscv_div_result=i_riscv_div_rs1data;
			else 
			o_riscv_div_result={1'b0,i_riscv_div_rs1data}-{1'b0,i_riscv_div_rs2data};
	        end
			else 
		    o_riscv_div_result = Z[127:64];
end
    end

4'b1011:                                               //remuw
    begin
		    if (i_riscv_div_rs2data[31:0]==0)              //division by 0
//	        o_riscv_div_result=i_riscv_div_rs1data;
           	o_riscv_div_result = { {32 {i_riscv_div_rs1data[31]}},i_riscv_div_rs1data[31:0]};
			else begin
    if(rs2_copy[31])
			begin  
				if({1'b0,rs2_copy}>{1'b0,rs1_copy})
		    	o_riscv_div_result={ {32 {i_riscv_div_rs1data[31]}},i_riscv_div_rs1data[31:0]};	
				else 
					o_riscv_div_result={1'b0,rs1_copy}-{1'b0,rs2_copy};
	    end
		else 
		    o_riscv_div_result = { {32 {Z[96]}},Z[96:64]};
end
    end

default: o_riscv_div_result=0;
endcase
end
else  o_riscv_div_result=0;
end

///////////////////////////////////////////////////////////////////////fsm//////////////////////////
always @ (posedge i_riscv_div_clk or posedge i_riscv_div_rst)
begin
if(i_riscv_div_rst)
begin
  Z          <= 'd0;
  o_riscv_div_valid      <= 'b0;
  pres_state <= 'b0;
  count      <= 'd0;
  valid<=0;
end
else 
begin
  Z          <= next_Z;
  valid     <= next_valid;
  pres_state <= next_state;
  count      <= next_count;
  o_riscv_div_valid<=next_valid;
end
end

always @ (*)
begin 
case(pres_state)
IDLE:
begin
next_count = 'b0;
next_valid = 'b0;
if(start&&!valid)
begin
    next_state = START;
    next_Z     = {64'd0,X};
end
else
begin
    next_state = pres_state;
    next_Z     = 'd0;
end
end

START:
begin
next_count = count + 1'b1;
Z_temp     = Z << 1;
Z_temp1    = {Z_temp[127:64]-Y,Z_temp[63:0]};
next_Z     = Z_temp1[127] ? {Z_temp[127:64],Z_temp[63:1],1'b0} : 
                          {Z_temp1[127:64],Z_temp[63:1],1'b1};
next_valid = (&count) ? 1'b1 : 1'b0; 
next_state = (&count) ? IDLE : pres_state;	
end
endcase
end
endmodule