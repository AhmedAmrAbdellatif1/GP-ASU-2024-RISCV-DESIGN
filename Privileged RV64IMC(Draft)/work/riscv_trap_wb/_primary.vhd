library verilog;
use verilog.vl_types.all;
entity riscv_trap_wb is
    port(
        i_riscv_trap_gototrap: in     vl_logic;
        i_riscv_trap_returnfromtrap: in     vl_logic;
        o_riscv_trap_flush: out    vl_logic;
        o_riscv_trap_pcsel: out    vl_logic_vector(1 downto 0)
    );
end riscv_trap_wb;
