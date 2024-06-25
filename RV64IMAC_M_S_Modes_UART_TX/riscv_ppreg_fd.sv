  module riscv_ppreg_fd(
    input  logic        i_riscv_fd_clk          ,
    input  logic        i_riscv_fd_rst          ,
    input  logic        i_riscv_fd_flush        ,
    input  logic        i_riscv_fd_en           ,
    input  logic [63:0] i_riscv_fd_pc_f         ,
    input  logic [31:0] i_riscv_fd_inst_f       ,
    input  logic [63:0] i_riscv_fd_pcplus4_f    ,
    input  logic        i_riscv_fd_cillegal_inst_f,
    input  logic [15:0] i_riscv_fd_cinst_f      ,
    output logic [15:0] o_riscv_fd_cinst_d      ,
    output logic [63:0] o_riscv_fd_pc_d         ,
    output logic [31:0] o_riscv_fd_inst_d       ,
    output logic [63:0] o_riscv_fd_pcplus4_d    ,
    output logic [4:0]  o_riscv_fd_rs1_d        ,
    output logic        o_riscv_fd_cillegal_inst_d,
    output logic [11:0] o_riscv_fd_constimm12_d 
  );
  
  always_ff @(posedge i_riscv_fd_clk or posedge i_riscv_fd_rst)
    begin:f_d_pff_wirte
      if(i_riscv_fd_rst)
        begin
          o_riscv_fd_pc_d             <=  64'b0;
          o_riscv_fd_inst_d           <=  32'b0;
          o_riscv_fd_pcplus4_d        <=  64'b0;
          o_riscv_fd_rs1_d            <=  5'b0;
          o_riscv_fd_constimm12_d     <=  12'b0;
          o_riscv_fd_cillegal_inst_d  <=  1'b0; 
          o_riscv_fd_cinst_d          <=  'b0;
        end
      else if(i_riscv_fd_flush)
        begin
          o_riscv_fd_pc_d             <=  i_riscv_fd_pc_f;
          o_riscv_fd_inst_d           <=  32'b0;
          o_riscv_fd_pcplus4_d        <=  64'b0;
          o_riscv_fd_rs1_d            <=  5'b0;
          o_riscv_fd_constimm12_d     <=  12'b0;
          o_riscv_fd_cillegal_inst_d  <= 1'b0;
          o_riscv_fd_cinst_d          <=  'b0;
        end
       else if (!i_riscv_fd_en)
         begin
          o_riscv_fd_pc_d             <=  i_riscv_fd_pc_f;
          o_riscv_fd_inst_d           <=  i_riscv_fd_inst_f;
          o_riscv_fd_pcplus4_d        <=  i_riscv_fd_pcplus4_f;
          o_riscv_fd_rs1_d            <=  i_riscv_fd_inst_f[19:15];
          o_riscv_fd_constimm12_d     <=  i_riscv_fd_inst_f[31:20];
          o_riscv_fd_cillegal_inst_d  <=  i_riscv_fd_cillegal_inst_f;
          o_riscv_fd_cinst_d          <=  i_riscv_fd_cinst_f;
         end 
    end
 endmodule