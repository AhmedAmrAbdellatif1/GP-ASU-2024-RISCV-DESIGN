library verilog;
use verilog.vl_types.all;
entity riscv_fd_ppreg is
    port(
        i_riscv_fd_clk  : in     vl_logic;
        i_riscv_fd_rst  : in     vl_logic;
        i_riscv_fd_flush: in     vl_logic;
        i_riscv_fd_en   : in     vl_logic;
        i_riscv_fd_pc_f : in     vl_logic_vector(63 downto 0);
        i_riscv_fd_inst_f: in     vl_logic_vector(31 downto 0);
        i_riscv_fd_pcplus4_f: in     vl_logic_vector(63 downto 0);
        o_riscv_fd_pc_d : out    vl_logic_vector(63 downto 0);
        o_riscv_fd_inst_d: out    vl_logic_vector(31 downto 0);
        o_riscv_fd_pcplus4_d: out    vl_logic_vector(63 downto 0);
        o_riscv_fd_rs1_d: out    vl_logic_vector(4 downto 0);
        o_riscv_fd_constimm12_d: out    vl_logic_vector(11 downto 0)
    );
end riscv_fd_ppreg;
