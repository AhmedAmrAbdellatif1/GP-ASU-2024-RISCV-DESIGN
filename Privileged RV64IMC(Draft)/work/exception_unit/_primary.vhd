library verilog;
use verilog.vl_types.all;
entity exception_unit is
    port(
        i_riscv_exception_opcode: in     vl_logic_vector(6 downto 0);
        i_riscv_exception_icu_result: in     vl_logic_vector(63 downto 0);
        i_riscv_exception_branch_taken: in     vl_logic;
        i_riscv_exception_load_sel: in     vl_logic_vector(2 downto 0);
        i_riscv_exception_store_sel: in     vl_logic_vector(1 downto 0);
        o_riscv_exception_store_addr_misaligned: out    vl_logic;
        o_riscv_exception_load_addr_misaligned: out    vl_logic;
        o_riscv_exception_inst_addr_misaligned: out    vl_logic
    );
end exception_unit;
