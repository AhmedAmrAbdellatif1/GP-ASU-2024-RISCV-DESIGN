library verilog;
use verilog.vl_types.all;
entity riscv_divider is
    generic(
        IDLE            : vl_logic := Hi0;
        START           : vl_logic := Hi1
    );
    port(
        i_riscv_div_clk : in     vl_logic;
        i_riscv_div_rst : in     vl_logic;
        i_riscv_div_divctrl: in     vl_logic_vector(3 downto 0);
        i_riscv_div_rs2data: in     vl_logic_vector(63 downto 0);
        i_riscv_div_rs1data: in     vl_logic_vector(63 downto 0);
        o_riscv_div_result: out    vl_logic_vector(63 downto 0);
        o_riscv_div_valid: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of START : constant is 1;
end riscv_divider;
