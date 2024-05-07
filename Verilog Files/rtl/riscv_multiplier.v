module riscv_multiplier (
    input  wire                 i_riscv_mul_clk      ,
    input  wire                 i_riscv_mul_rst      ,
    input  wire signed [63:0]   i_riscv_mul_rs1data  ,
    input  wire signed [63:0]   i_riscv_mul_rs2data  ,
    input  wire        [3:0]    i_riscv_mul_mulctrl  ,
    output reg signed [63:0]   o_riscv_mul_product  ,
    output reg                 o_riscv_mul_valid
  );

  reg signed [129:0] z,next_z,z_temp;
  reg                valid,next_valid;
  reg                next_state,pres_state;
  reg         [1:0]  temp,next_temp;                   
  reg         [6:0]  count,next_count;                 
  wire                i_riscv_mul_start;
  reg signed  [64:0] x,y;

  parameter idle =1'b0;
  parameter start=1'b1;

  assign i_riscv_mul_start = i_riscv_mul_mulctrl[3];


  //////////////////////////////////  multiplicend & multiplier //////////////////
  always @(*)
  begin
    case(i_riscv_mul_mulctrl) 
      4'b1110:
      begin //mulhu
        x={1'b0,i_riscv_mul_rs1data[63:0]}; //multiplicend
        y={1'b0,i_riscv_mul_rs2data[63:0]}; //multiplier
      end

      4'b1111:
      begin   //mulhsu
        x={i_riscv_mul_rs1data[63],i_riscv_mul_rs1data[63:0]};
        y={1'b0,i_riscv_mul_rs2data[63:0]};
      end

      4'b1000:  //mulw
      begin
        x={   {33{1'b0}},i_riscv_mul_rs1data[31:0]};
        y={   {33{1'b0}},i_riscv_mul_rs2data[31:0]};
      end
      default:
      begin
        x={i_riscv_mul_rs1data[63],i_riscv_mul_rs1data[63:0]};
        y={i_riscv_mul_rs2data[63],i_riscv_mul_rs2data[63:0]};
      end
    endcase
  end

  always @(posedge i_riscv_mul_clk or posedge i_riscv_mul_rst)
  begin
    if(i_riscv_mul_rst)
    begin
      z<='b0;
      o_riscv_mul_valid<=0;
      pres_state<=0;
      temp<=0;
      valid<=0;
      count<=0;
      o_riscv_mul_product<=0;
    end
    else 
    begin
      z<=next_z;
      o_riscv_mul_valid<=next_valid;
      valid<=next_valid;
      pres_state<=next_state;
      temp<=next_temp;
      count<=next_count;
      if(next_valid)
      begin
        case(i_riscv_mul_mulctrl)
          4'b1100:  o_riscv_mul_product<=next_z[63:0];
          4'b1101:  o_riscv_mul_product<=next_z[127:64];
          4'b1110:  o_riscv_mul_product<=next_z[127:64];
          4'b1111:  o_riscv_mul_product<=next_z[127:64];
          4'b1000:  o_riscv_mul_product<= { {32{next_z[31]}} ,next_z[31:0]};

          default: o_riscv_mul_product<=0;
        endcase
      end
    end 
  end

  always @(*)
  begin
    case (pres_state)
      idle:
      begin
        next_count='b0;
        next_valid=1'b0;
        if(i_riscv_mul_start&&!valid)
        begin
            next_state=start;
            next_temp={y[0],1'b0};                         //initial q_1=0
            next_z={1'b0,y};
        end
        else
        begin
            next_state=pres_state;
            next_temp=0;
            next_z=0;
        end
      end
          
      start:
      begin
        case(temp)
          2'b10: z_temp={z[129:65]-x,z[64:0]};
          2'b01: z_temp={z[129:65]+x,z[64:0]};
          default : z_temp={z[129:65],z[64:0]};
        endcase
        next_temp={y[count+1],y[count]};
        next_count=count+1;
        next_z=z_temp>>>1;
        next_valid=(count=='b1000000)?1'b1:1'b0;
        next_state=(count=='b1000000)? idle:pres_state;
      end     
    endcase
  end
endmodule