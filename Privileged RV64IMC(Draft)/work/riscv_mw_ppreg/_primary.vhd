library verilog;
use verilog.vl_types.all;
entity riscv_mw_ppreg is
    port(
        i_riscv_mw_clk  : in     vl_logic;
        i_riscv_mw_rst  : in     vl_logic;
        i_riscv_mw_en   : in     vl_logic;
        i_riscv_mw_pcplus4_m: in     vl_logic_vector(63 downto 0);
        i_riscv_mw_result_m: in     vl_logic_vector(63 downto 0);
        i_riscv_mw_uimm_m: in     vl_logic_vector(63 downto 0);
        i_riscv_mw_memload_m: in     vl_logic_vector(63 downto 0);
        i_riscv_mw_rdaddr_m: in     vl_logic_vector(4 downto 0);
        i_riscv_mw_resultsrc_m: in     vl_logic_vector(1 downto 0);
        i_riscv_mw_regw_m: in     vl_logic;
        o_riscv_mw_pcplus4_wb: out    vl_logic_vector(63 downto 0);
        o_riscv_mw_result_wb: out    vl_logic_vector(63 downto 0);
        o_riscv_mw_uimm_wb: out    vl_logic_vector(63 downto 0);
        o_riscv_mw_memload_wb: out    vl_logic_vector(63 downto 0);
        o_riscv_mw_rdaddr_wb: out    vl_logic_vector(4 downto 0);
        o_riscv_mw_resultsrc_wb: out    vl_logic_vector(1 downto 0);
        o_riscv_mw_regw_wb: out    vl_logic;
        i_riscv_mw_flush: in     vl_logic;
        i_riscv_mw_csrout_m: in     vl_logic_vector(63 downto 0);
        i_riscv_mw_iscsr_m: in     vl_logic;
        i_riscv_mw_gototrap_m: in     vl_logic;
        i_riscv_mw_returnfromtrap_m: in     vl_logic;
        o_riscv_mw_csrout_wb: out    vl_logic_vector(63 downto 0);
        o_riscv_mw_iscsr_wb: out    vl_logic;
        o_riscv_mw_gototrap_wb: out    vl_logic;
        o_riscv_mw_returnfromtrap_wb: out    vl_logic
    );
end riscv_mw_ppreg;
