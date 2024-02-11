  module riscv_fd_ppreg(
    input  logic        i_riscv_fd_clk,
    input  logic        i_riscv_fd_rst,
    input  logic        i_riscv_fd_flush,
    input  logic        i_riscv_fd_en,
    input  logic [63:0] i_riscv_fd_pc_f,
    input  logic [31:0] i_riscv_fd_inst_f,
    input  logic [63:0] i_riscv_fd_pcplus4_f,
    output logic [63:0] o_riscv_fd_pc_d,
    output logic [31:0] o_riscv_fd_inst_d,
    output logic [63:0] o_riscv_fd_pcplus4_d
  );
  
  always_ff @(posedge i_riscv_fd_clk or posedge i_riscv_fd_rst)
    begin:f_d_pff_wirte
      if(i_riscv_fd_rst)
        begin
          o_riscv_fd_pc_d      <=64'b0;
          o_riscv_fd_inst_d    <=32'b0;
          o_riscv_fd_pcplus4_d <=64'b0; 
        end
    else
      begin
     if(i_riscv_fd_flush)
        begin
          o_riscv_fd_pc_d      <=64'b0;
          o_riscv_fd_inst_d    <=32'b0;
          o_riscv_fd_pcplus4_d <=64'b0; 
        end
      else if (i_riscv_fd_en)
        begin
         o_riscv_fd_pc_d      <=o_riscv_fd_pc_d;
         o_riscv_fd_inst_d    <=o_riscv_fd_inst_d;
         o_riscv_fd_pcplus4_d <=o_riscv_fd_pcplus4_d; 
        end
          
       else
         begin
          o_riscv_fd_pc_d      <= i_riscv_fd_pc_f;
          o_riscv_fd_inst_d    <= i_riscv_fd_inst_f;
          o_riscv_fd_pcplus4_d <= i_riscv_fd_pcplus4_f;
         end 
    end
  end
  endmodule
