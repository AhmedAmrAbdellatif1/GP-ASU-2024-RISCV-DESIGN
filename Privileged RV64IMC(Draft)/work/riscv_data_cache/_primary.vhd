library verilog;
use verilog.vl_types.all;
entity riscv_data_cache is
    generic(
        DATA_WIDTH      : integer := 128;
        MEM_SIZE        : integer := 1024;
        CACHE_SIZE      : integer := 64;
        DATAPBLOCK      : integer := 16;
        CACHE_DEPTH     : vl_notype;
        ADDR            : vl_notype;
        BYTE_OFF        : vl_notype;
        INDEX           : vl_notype;
        TAG             : vl_notype
    );
    port(
        i_riscv_dcache_clk: in     vl_logic;
        i_riscv_dcache_rst: in     vl_logic;
        i_riscv_dcache_cpu_wren: in     vl_logic;
        i_riscv_dcache_cpu_rden: in     vl_logic;
        i_riscv_dcache_store_src: in     vl_logic_vector(1 downto 0);
        i_riscv_dcache_phys_addr: in     vl_logic_vector(63 downto 0);
        i_riscv_dcache_cpu_data_in: in     vl_logic_vector(63 downto 0);
        o_riscv_dcache_cpu_data_out: out    vl_logic_vector(63 downto 0);
        o_riscv_dcache_cpu_stall: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_SIZE : constant is 1;
    attribute mti_svvh_generic_type of CACHE_SIZE : constant is 1;
    attribute mti_svvh_generic_type of DATAPBLOCK : constant is 1;
    attribute mti_svvh_generic_type of CACHE_DEPTH : constant is 3;
    attribute mti_svvh_generic_type of ADDR : constant is 3;
    attribute mti_svvh_generic_type of BYTE_OFF : constant is 3;
    attribute mti_svvh_generic_type of INDEX : constant is 3;
    attribute mti_svvh_generic_type of TAG : constant is 3;
end riscv_data_cache;
