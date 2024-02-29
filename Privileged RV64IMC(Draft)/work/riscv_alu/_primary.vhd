library verilog;
use verilog.vl_types.all;
entity riscv_alu is
    port(
        i_riscv_alu_ctrl: in     vl_logic_vector(5 downto 0);
        i_riscv_alu_rs1data: in     vl_logic_vector(63 downto 0);
        i_riscv_alu_rs2data: in     vl_logic_vector(63 downto 0);
        o_riscv_alu_result: out    vl_logic_vector(63 downto 0)
    );
end riscv_alu;
