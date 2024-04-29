module riscv_fstage (
  input   wire         i_riscv_fstage_clk      ,
  input   wire         i_riscv_fstage_rst      ,
  input   wire         i_riscv_fstage_stallpc  ,
  input   wire         i_riscv_fstage_pcsrc    ,
  input   wire [63:0]  i_riscv_fstage_aluexe   ,
  input   wire [63:0]  i_riscv_fstage_sepc     ,    //<--- TRAPS AND CSR  
  input   wire [31:0]  i_riscv_fstage_inst     ,  
  input   wire [1:0]   i_riscv_fstage_pcsel    ,    //<--- TRAPS AND CSR    
  input   wire [63:0]  i_riscv_fstage_mtvec    ,    //<--- TRAPS AND CSR    
  input   wire [63:0]  i_riscv_fstage_mepc     ,    //<--- TRAPS AND CSR    
  output  wire [63:0]  o_riscv_fstage_pc       ,
  output  wire [31:0]  o_riscv_fstage_inst     ,
  output  wire [63:0]  o_riscv_fstage_pcplus4  ,
  output  wire         o_riscv_fstage_cillegal_inst  //<--- TRAPS AND CSR    
  );

  wire [63:0]  riscv_fstage_pc;
  wire [63:0]  riscv_pcadder1_operand;
  wire [63:0]  o_riscv_fstage_pcmux_trap;  //<--- TRAPS AND CSR 
  wire [63:0]  o_riscv_pcmux_nextpc;       //<--- TRAPS AND CSR

/************************ PC MUX ************************/
  riscv_mux2 u_pcmux (
    .i_riscv_mux2_sel (i_riscv_fstage_pcsrc)    ,
    .i_riscv_mux2_in0 (o_riscv_fstage_pcplus4)  ,
    .i_riscv_mux2_in1 (i_riscv_fstage_aluexe)   ,
    .o_riscv_mux2_out (o_riscv_pcmux_nextpc)
  );

/************************ Program Counter ************************/
  riscv_pc u_riscv_pc (
    .i_riscv_pc_clk     (i_riscv_fstage_clk)        ,
    .i_riscv_pc_rst     (i_riscv_fstage_rst)        ,
    .i_riscv_pc_stallpc (i_riscv_fstage_stallpc)    ,
    .i_riscv_pc_nextpc  (o_riscv_fstage_pcmux_trap) , //<--- TRAPS AND CSR
    .o_riscv_pc_pc      (o_riscv_fstage_pc)
  );

/************************ PC Adder ************************/
  riscv_pcadder u_riscv_pcadder (
    .i_riscv_pcadder_size       (riscv_pcadder1_operand)    ,
    .i_riscv_pcadder_pc         (o_riscv_fstage_pc)         ,
    .o_riscv_pcadder_pcplussize (o_riscv_fstage_pcplus4)
  );
/************************ PC Adder Mux ************************/
  riscv_mux2 u_pcmuxadder(
    .i_riscv_mux2_sel (riscv_fstage_addermuxsel && !o_riscv_fstage_cillegal_inst)  ,
    .i_riscv_mux2_in0 (64'd4)                     ,
    .i_riscv_mux2_in1 (64'd2)                     ,
    .o_riscv_mux2_out (riscv_pcadder1_operand)
  );
/************************ Compressed Decoder ************************/
  riscv_compressed_decoder u_top_cdecoder(
    .i_riscv_cdecoder_inst          (i_riscv_fstage_inst)       ,
    .o_riscv_cdecoder_inst          (o_riscv_fstage_inst)       ,
    .o_riscv_cdecoder_compressed    (riscv_fstage_addermuxsel)  ,
    .o_riscv_cdecoder_cillegal_inst (o_riscv_fstage_cillegal_inst)
  );

/************************ PC Trap Mux ************************/
  riscv_mux4 u_pcmuxfortrap (
    .i_riscv_mux4_sel (i_riscv_fstage_pcsel)        ,   
    .i_riscv_mux4_in0 (o_riscv_pcmux_nextpc)        ,  //<=
    .i_riscv_mux4_in1 (i_riscv_fstage_mtvec)        ,  
    .i_riscv_mux4_in2 (i_riscv_fstage_mepc)         , 
    .i_riscv_mux4_in3 (i_riscv_fstage_sepc)         ,
    .o_riscv_mux4_out (o_riscv_fstage_pcmux_trap) 
  );

endmodule