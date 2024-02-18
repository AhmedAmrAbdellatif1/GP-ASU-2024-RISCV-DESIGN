module riscv_divider(
input                          i_riscv_div_clk,
input                          i_riscv_div_rst,
input  logic          [2:0]    i_riscv_div_divctrl,
input  logic  signed  [63:0]   i_riscv_div_rs2data, i_riscv_div_rs1data,
output logic  signed  [63:0]   o_riscv_div_result,
output logic                   o_riscv_div_valid
);

logic signed [127:0] Z,next_Z,Z_temp,Z_temp1;
logic next_state, pres_state;
logic [5:0] count,next_count;
logic next_valid;
logic start;
assign start=i_riscv_div_divctrl[2];

logic signed [63:0] X,Y;

parameter IDLE = 1'b0;
parameter START = 1'b1;


always_comb
begin
     if(!i_riscv_div_divctrl[0]&&i_riscv_div_rs1data[63])
       begin
             X=~i_riscv_div_rs1data+1;
       end
      else 
        begin
            X=i_riscv_div_rs1data;
            end
end

always_comb
begin
     if(!i_riscv_div_divctrl[0]&&i_riscv_div_rs2data[63])
       begin
             Y=~i_riscv_div_rs2data+1;
       end
      else 
        begin
            Y=i_riscv_div_rs2data;
            end
end


always_comb
begin	
case(i_riscv_div_divctrl)
3'b100 :begin                               ///div
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
 
3'b101:                                  //divu
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


3'b110: 
      begin                                 //rem
	        if (i_riscv_div_rs2data==0)              //division by 0
	        o_riscv_div_result=i_riscv_div_rs1data;
			else if ((i_riscv_div_rs1data==-(2**63))&&(i_riscv_div_rs2data==-1) )        //overflow
	        o_riscv_div_result=0 ; 

			else begin
    if (i_riscv_div_rs1data[63]&& !(|Z[127:64]))
	begin
	o_riscv_div_result = ~Z[127:64]+1;
	end
	else 
	begin
	o_riscv_div_result = Z[127:64];
	end
end
end

3'b111:
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

default: o_riscv_div_result=0;

endcase
end


always @ (posedge i_riscv_div_clk or negedge i_riscv_div_rst)
begin
if(!i_riscv_div_rst)
begin
  Z          <= 'd0;
  o_riscv_div_valid      <= 'b0;
  pres_state <= 'b0;
  count      <= 'd0;
end
else 
begin
  Z          <= next_Z;
  o_riscv_div_valid      <= next_valid;
  pres_state <= next_state;
  count      <= next_count;
end
end

always @ (*)
begin 
case(pres_state)
IDLE:
begin
next_count = 'b0;
next_valid = 'b0;
if(start)
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