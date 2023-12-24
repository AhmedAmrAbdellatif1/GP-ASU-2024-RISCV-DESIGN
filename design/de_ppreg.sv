  module riscv_de_ppreg(
      input  logic          i_riscv_de_clk,
      input  logic          i_riscv_de_rst,
      input  logic  [63:0]  i_riscv_de_pc_d,
      input  logic  [4:0]   i_riscv_de_rs1addr_d,
      input  logic  [63:0]  i_riscv_de_rs1data_d,
      input  logic  [63:0]  i_riscv_de_rs2data_d,
      input  logic  [4:0]   i_riscv_de_rs2addr_d,
      input  logic  [4:0]   i_riscv_de_rdaddr_d,
      input  logic  [63:0]  i_riscv_de_extendedimm_d,
      input  logic  [2:0]   i_riscv_de_b_condition_d,
      input  logic          i_riscv_de_oprnd2sel_d,
      input  logic  [1:0]   i_riscv_de_storesrc_d,
      input  logic  [4:0]   i_riscv_de_alucontrol_d,
      input  logic          i_riscv_de_oprnd1sel_d,
      input  logic          i_riscv_de_memwrite_d,
      input  logic  [2:0]   i_riscv_de_memext_d,
      input  logic  [1:0]   i_riscv_de_resultsrc_d,
      input  logic          i_riscv_de_regwrite_d,
      input  logic  [63:0]  i_riscv_de_pcplus4_d,
      output logic  [63:0]  o_riscv_de_pc_e,
      output logic  [63:0]  o_riscv_de_pcplus4_e,
      output logic  [4:0]   o_riscv_de_rs1addr_e,
      output logic  [63:0]  o_riscv_de_rs1data_e,
      output logic  [63:0]  o_riscv_de_rs2data_e,
      output logic  [4:0]   o_riscv_de_rs2addr_e,
      output logic  [4:0]   o_riscv_de_rdaddr_e,
      output logic  [63:0]  o_riscv_de_extendedimm_e,
      output logic  [2:0]   o_riscv_de_b_condition_e,
      output logic          o_riscv_de_oprnd2sel_e,
      output logic  [1:0]   o_riscv_de_storesrc_e,
      output logic  [4:0]   o_riscv_de_alucontrol_e,
      output logic          o_riscv_de_oprnd1sel_e,
      output logic          o_riscv_de_memwrite_e,
      output logic  [2:0]   o_riscv_de_memext_e,
      output logic  [1:0]   o_riscv_de_resultsrc_e,
      output logic          o_riscv_de_regwrite_e
  );
    always_ff @(posedge i_riscv_de_clk or posedge i_riscv_de_rst )
      begin:de_pff_write_proc
        if(i_riscv_de_rst)
        begin
           o_riscv_de_pc_e          <= 64'b0;
           o_riscv_de_pcplus4_e     <= 64'b0;
           o_riscv_de_rs1addr_e     <= 64'b0;
           o_riscv_de_rs1data_e     <= 64'b0;
           o_riscv_de_rs2data_e     <= 64'b0;
           o_riscv_de_rs2addr_e     <= 64'b0;
           o_riscv_de_rdaddr_e      <= 64'b0;
           o_riscv_de_extendedimm_e <= 64'b0;
           o_riscv_de_b_condition_e <= 64'b0;
           o_riscv_de_oprnd2sel_e   <= 64'b0;
           o_riscv_de_storesrc_e    <= 64'b0;
           o_riscv_de_alucontrol_e  <= 64'b0;
           o_riscv_de_oprnd1sel_e   <= 64'b0;
           o_riscv_de_memwrite_e    <= 64'b0;
           o_riscv_de_memext_e      <= 64'b0;
           o_riscv_de_resultsrc_e   <= 64'b0;
           o_riscv_de_regwrite_e    <= 64'b0;
        end
      else
        begin
           o_riscv_de_pc_e          <= i_riscv_de_pc_d;
           o_riscv_de_pcplus4_e     <= i_riscv_de_pcplus4_d;
           o_riscv_de_rs1addr_e     <= i_riscv_de_rs1addr_d;
           o_riscv_de_rs1data_e     <= i_riscv_de_rs1data_d;
           o_riscv_de_rs2data_e     <= i_riscv_de_rs2data_d;
           o_riscv_de_rs2addr_e     <= i_riscv_de_rs2addr_d;
           o_riscv_de_rdaddr_e      <= i_riscv_de_rdaddr_d;
           o_riscv_de_extendedimm_e <= i_riscv_de_extendedimm_d;
           o_riscv_de_b_condition_e <= i_riscv_de_b_condition_d;
           o_riscv_de_oprnd2sel_e   <= i_riscv_de_oprnd2sel_d;
           o_riscv_de_storesrc_e    <= i_riscv_de_storesrc_d;
           o_riscv_de_alucontrol_e  <= i_riscv_de_alucontrol_d;
           o_riscv_de_oprnd1sel_e   <= i_riscv_de_oprnd1sel_d;
           o_riscv_de_memwrite_e    <= i_riscv_de_memwrite_d;
           o_riscv_de_memext_e      <= i_riscv_de_memext_d;
           o_riscv_de_resultsrc_e   <= i_riscv_de_resultsrc_d;
           o_riscv_de_regwrite_e    <= i_riscv_de_regwrite_d;       
        end
      end
  endmodule
