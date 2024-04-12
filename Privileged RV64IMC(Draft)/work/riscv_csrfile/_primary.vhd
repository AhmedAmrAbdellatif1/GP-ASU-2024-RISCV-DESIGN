library verilog;
use verilog.vl_types.all;
entity riscv_csrfile is
    generic(
        MXLEN           : integer := 64;
        support_supervisor: integer := 0;
        support_user    : integer := 0
    );
    port(
        i_riscv_csr_clk : in     vl_logic;
        i_riscv_csr_rst : in     vl_logic;
        i_riscv_csr_address: in     vl_logic_vector(11 downto 0);
        i_riscv_csr_op  : in     vl_logic_vector(2 downto 0);
        i_riscv_csr_wdata: in     vl_logic_vector;
        o_riscv_csr_rdata: out    vl_logic_vector;
        i_riscv_csr_external_int: in     vl_logic;
        i_riscv_csr_timer_int: in     vl_logic;
        i_riscv_csr_illegal_inst: in     vl_logic;
        i_riscv_csr_ecall_u: in     vl_logic;
        i_riscv_csr_ecall_s: in     vl_logic;
        i_riscv_csr_ecall_m: in     vl_logic;
        i_riscv_csr_inst_addr_misaligned: in     vl_logic;
        i_riscv_csr_load_addr_misaligned: in     vl_logic;
        i_riscv_csr_store_addr_misaligned: in     vl_logic;
        o_riscv_csr_return_address: out    vl_logic_vector;
        o_riscv_csr_trap_address: out    vl_logic_vector;
        o_riscv_csr_gotoTrap_cs: out    vl_logic;
        o_riscv_csr_returnfromTrap_cs: out    vl_logic;
        i_riscv_csr_pc  : in     vl_logic_vector(63 downto 0);
        i_riscv_csr_addressALU: in     vl_logic_vector(63 downto 0);
        o_riscv_csr_privlvl: out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MXLEN : constant is 1;
    attribute mti_svvh_generic_type of support_supervisor : constant is 1;
    attribute mti_svvh_generic_type of support_user : constant is 1;
end riscv_csrfile;
