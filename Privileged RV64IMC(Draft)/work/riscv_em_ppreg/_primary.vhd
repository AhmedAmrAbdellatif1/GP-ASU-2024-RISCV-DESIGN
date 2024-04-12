library verilog;
use verilog.vl_types.all;
entity riscv_em_ppreg is
    generic(
        width           : integer := 64
    );
    port(
        i_riscv_em_clk  : in     vl_logic;
        i_riscv_em_rst  : in     vl_logic;
        i_riscv_em_en   : in     vl_logic;
        i_riscv_em_regw_e: in     vl_logic;
        i_riscv_em_resultsrc_e: in     vl_logic_vector(1 downto 0);
        i_riscv_em_storesrc_e: in     vl_logic_vector(1 downto 0);
        i_riscv_em_memext_e: in     vl_logic_vector(2 downto 0);
        i_riscv_em_pcplus4_e: in     vl_logic_vector(63 downto 0);
        i_riscv_em_result_e: in     vl_logic_vector(63 downto 0);
        i_riscv_em_storedata_e: in     vl_logic_vector(63 downto 0);
        i_riscv_em_rdaddr_e: in     vl_logic_vector(4 downto 0);
        i_riscv_em_imm_e: in     vl_logic_vector(63 downto 0);
        i_riscv_de_opcode_e: in     vl_logic_vector(6 downto 0);
        o_riscv_em_regw_m: out    vl_logic;
        o_riscv_em_resultsrc_m: out    vl_logic_vector(1 downto 0);
        o_riscv_em_storesrc_m: out    vl_logic_vector(1 downto 0);
        o_riscv_em_memext_m: out    vl_logic_vector(2 downto 0);
        o_riscv_em_pcplus4_m: out    vl_logic_vector(63 downto 0);
        o_riscv_em_result_m: out    vl_logic_vector(63 downto 0);
        o_riscv_em_storedata_m: out    vl_logic_vector(63 downto 0);
        o_riscv_em_rdaddr_m: out    vl_logic_vector(4 downto 0);
        o_riscv_em_imm_m: out    vl_logic_vector(63 downto 0);
        o_riscv_de_opcode_m: out    vl_logic_vector(6 downto 0);
        i_riscv_em_flush: in     vl_logic;
        i_riscv_em_ecall_m_e: in     vl_logic;
        i_riscv_em_csraddress_e: in     vl_logic_vector(11 downto 0);
        i_riscv_em_illegal_inst_e: in     vl_logic;
        i_riscv_em_iscsr_e: in     vl_logic;
        i_riscv_em_csrop_e: in     vl_logic_vector(2 downto 0);
        i_riscv_em_addressalu_e: in     vl_logic_vector(63 downto 0);
        i_riscv_em_inst_addr_misaligned_e: in     vl_logic;
        i_riscv_em_load_addr_misaligned_e: in     vl_logic;
        i_riscv_em_store_addr_misaligned_e: in     vl_logic;
        i_riscv_em_csrwritedata_e: in     vl_logic_vector;
        o_riscv_em_ecall_m_m: out    vl_logic;
        o_riscv_em_csraddress_m: out    vl_logic_vector(11 downto 0);
        o_riscv_em_illegal_inst_m: out    vl_logic;
        o_riscv_em_iscsr_m: out    vl_logic;
        o_riscv_em_csrop_m: out    vl_logic_vector(2 downto 0);
        o_riscv_em_addressalu_m: out    vl_logic_vector(63 downto 0);
        o_riscv_em_inst_addr_misaligned_m: out    vl_logic;
        o_riscv_em_load_addr_misaligned_m: out    vl_logic;
        o_riscv_em_store_addr_misaligned_m: out    vl_logic;
        o_riscv_em_csrwritedata_m: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end riscv_em_ppreg;
