library verilog;
use verilog.vl_types.all;
entity riscv_dm is
    generic(
        MEM_DEPTH       : integer := 64
    );
    port(
        i_riscv_dm_clk_n: in     vl_logic;
        i_riscv_dm_rst  : in     vl_logic;
        i_riscv_dm_wen  : in     vl_logic;
        i_riscv_dm_sel  : in     vl_logic_vector(1 downto 0);
        i_riscv_dm_wdata: in     vl_logic_vector(63 downto 0);
        i_riscv_dm_waddr: in     vl_logic_vector(63 downto 0);
        o_riscv_dm_rdata: out    vl_logic_vector(63 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_DEPTH : constant is 1;
end riscv_dm;
