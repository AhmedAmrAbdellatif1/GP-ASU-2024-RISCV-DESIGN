library verilog;
use verilog.vl_types.all;
entity riscv_branch is
    port(
        i_riscv_branch_cond: in     vl_logic_vector(3 downto 0);
        i_riscv_branch_rs1data: in     vl_logic_vector(63 downto 0);
        i_riscv_branch_rs2data: in     vl_logic_vector(63 downto 0);
        o_riscv_branch_taken: out    vl_logic
    );
end riscv_branch;
